defmodule PhiaUi.Editor.CollabServer do
  @moduledoc """
  GenServer managing a single collaborative document via Operational Transform.

  Each document gets its own `CollabServer` process that maintains the
  authoritative document state, version counter, and operation history.
  Clients submit operations along with their last-known version; the server
  transforms against any intervening operations before applying.

  ## Architecture

  ```
  Client A ──apply_op──> CollabServer ──broadcast──> PubSub ──> Client B
  Client B ──apply_op──> CollabServer ──broadcast──> PubSub ──> Client A
  ```

  ## State

    - `:doc_id` — unique document identifier
    - `:content` — current document text (string)
    - `:version` — monotonically increasing integer (starts at 0)
    - `:history` — list of `{version, delta, client_id}` tuples (newest first)
    - `:clients` — `MapSet` of connected client identifiers

  ## Usage

      # Start a server for a document
      {:ok, pid} = PhiaUi.Editor.CollabServer.start_link(doc_id: "doc-123")

      # Client submits an operation
      {:ok, transformed_op, new_version} =
        PhiaUi.Editor.CollabServer.apply_op(pid, [%{retain: 5}, %{insert: "!"}], 0)

      # Read current state
      {"Hello!", 1} = PhiaUi.Editor.CollabServer.get_document(pid)

  ## PubSub Broadcasting

  After each successful operation, the server broadcasts on
  `"collab:doc:<doc_id>"` via `Phoenix.PubSub` (configured in
  `:phia_ui, :collab_pubsub`). The broadcast payload is:

      %{
        event: :op_applied,
        doc_id: doc_id,
        op: transformed_delta,
        version: new_version,
        client_id: client_id
      }

  ## History Pruning

  History is capped at 1000 entries. Older entries are discarded to
  bound memory usage. Clients that fall behind by more than 1000 versions
  must re-fetch the full document.
  """

  use GenServer

  require Logger

  alias PhiaUi.Editor.OtEngine

  @max_history 1000

  # ==========================================================================
  # Struct
  # ==========================================================================

  defstruct [
    :doc_id,
    content: "",
    version: 0,
    history: [],
    clients: MapSet.new()
  ]

  @type t :: %__MODULE__{
          doc_id: String.t(),
          content: String.t(),
          version: non_neg_integer(),
          history: [{non_neg_integer(), list(), String.t() | nil}],
          clients: MapSet.t()
        }

  # ==========================================================================
  # Public API
  # ==========================================================================

  @doc """
  Start a `CollabServer` process for a document.

  ## Options

    - `:doc_id` (required) — unique document identifier
    - `:initial_content` — starting document text (default `""`)
    - `:name` — process name (defaults to `via_tuple(doc_id)` using the
      `PhiaUi.Collab.RoomRegistry` if available, otherwise the pid)
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    doc_id = Keyword.fetch!(opts, :doc_id)
    name = Keyword.get(opts, :name, default_name(doc_id))
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @doc """
  Submit a delta operation from a client.

  The `client_version` is the version the client's delta was composed against.
  The server transforms the delta against all operations that occurred between
  `client_version` and the current server version, then applies the result.

  Returns `{:ok, transformed_delta, new_version}` on success, or
  `{:error, reason}` if the operation cannot be applied.

  ## Parameters

    - `server` — pid or registered name
    - `delta` — list of OT operations
    - `client_version` — the version the client is based on
    - `client_id` — optional identifier for the submitting client
  """
  @spec apply_op(GenServer.server(), list(), non_neg_integer(), String.t() | nil) ::
          {:ok, list(), non_neg_integer()} | {:error, term()}
  def apply_op(server, delta, client_version, client_id \\ nil) do
    GenServer.call(server, {:apply_op, delta, client_version, client_id})
  end

  @doc """
  Get the current document content and version.

  Returns `{content, version}`.
  """
  @spec get_document(GenServer.server()) :: {String.t(), non_neg_integer()}
  def get_document(server) do
    GenServer.call(server, :get_document)
  end

  @doc """
  Get the current document version.
  """
  @spec get_version(GenServer.server()) :: non_neg_integer()
  def get_version(server) do
    GenServer.call(server, :get_version)
  end

  @doc """
  Register a client as connected to this document.

  Used for tracking active collaborators. Purely informational.
  """
  @spec join(GenServer.server(), String.t()) :: :ok
  def join(server, client_id) do
    GenServer.cast(server, {:join, client_id})
  end

  @doc """
  Unregister a client from this document.
  """
  @spec leave(GenServer.server(), String.t()) :: :ok
  def leave(server, client_id) do
    GenServer.cast(server, {:leave, client_id})
  end

  @doc """
  Get the set of connected client identifiers.
  """
  @spec get_clients(GenServer.server()) :: MapSet.t()
  def get_clients(server) do
    GenServer.call(server, :get_clients)
  end

  @doc """
  Get operations from the history since a given version.

  Returns a list of `{version, delta, client_id}` tuples in ascending
  version order. If the requested version is older than the oldest entry
  in history, returns `{:error, :version_too_old}`.
  """
  @spec get_ops_since(GenServer.server(), non_neg_integer()) ::
          {:ok, [{non_neg_integer(), list(), String.t() | nil}]} | {:error, :version_too_old}
  def get_ops_since(server, since_version) do
    GenServer.call(server, {:get_ops_since, since_version})
  end

  # ==========================================================================
  # GenServer Callbacks
  # ==========================================================================

  @impl GenServer
  def init(opts) do
    doc_id = Keyword.fetch!(opts, :doc_id)
    initial_content = Keyword.get(opts, :initial_content, "")

    state = %__MODULE__{
      doc_id: doc_id,
      content: initial_content,
      version: 0,
      history: [],
      clients: MapSet.new()
    }

    Logger.debug("CollabServer started for doc #{doc_id}")

    {:ok, state}
  end

  @impl GenServer
  def handle_call({:apply_op, delta, client_version, client_id}, _from, state) do
    case do_apply_op(state, delta, client_version, client_id) do
      {:ok, transformed_delta, new_state} ->
        broadcast_op(new_state.doc_id, transformed_delta, new_state.version, client_id)
        {:reply, {:ok, transformed_delta, new_state.version}, new_state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call(:get_document, _from, state) do
    {:reply, {state.content, state.version}, state}
  end

  def handle_call(:get_version, _from, state) do
    {:reply, state.version, state}
  end

  def handle_call(:get_clients, _from, state) do
    {:reply, state.clients, state}
  end

  def handle_call({:get_ops_since, since_version}, _from, state) do
    if since_version < state.version - Kernel.length(state.history) do
      {:reply, {:error, :version_too_old}, state}
    else
      ops =
        state.history
        |> Enum.filter(fn {v, _delta, _cid} -> v > since_version end)
        |> Enum.sort_by(fn {v, _delta, _cid} -> v end)

      {:reply, {:ok, ops}, state}
    end
  end

  @impl GenServer
  def handle_cast({:join, client_id}, state) do
    {:noreply, %{state | clients: MapSet.put(state.clients, client_id)}}
  end

  def handle_cast({:leave, client_id}, state) do
    {:noreply, %{state | clients: MapSet.delete(state.clients, client_id)}}
  end

  # ==========================================================================
  # Private Helpers
  # ==========================================================================

  defp do_apply_op(state, delta, client_version, client_id) do
    with :ok <- validate_version(state, client_version),
         {:ok, transformed} <- transform_against_history(state, delta, client_version),
         {:ok, new_content} <- OtEngine.apply(state.content, transformed) do
      new_version = state.version + 1

      new_history =
        [{new_version, transformed, client_id} | state.history]
        |> Enum.take(@max_history)

      new_state = %{state |
        content: new_content,
        version: new_version,
        history: new_history
      }

      {:ok, transformed, new_state}
    end
  end

  defp validate_version(state, client_version) do
    oldest_available = state.version - Kernel.length(state.history)

    cond do
      client_version > state.version ->
        {:error, "client version #{client_version} is ahead of server version #{state.version}"}

      client_version < oldest_available ->
        {:error, "client version #{client_version} is too old; oldest available is #{oldest_available}"}

      true ->
        :ok
    end
  end

  defp transform_against_history(state, delta, client_version) do
    # Get all ops that happened after the client's version, in order
    pending_ops =
      state.history
      |> Enum.filter(fn {v, _d, _c} -> v > client_version end)
      |> Enum.sort_by(fn {v, _d, _c} -> v end)

    # Transform the incoming delta against each pending op sequentially
    Enum.reduce_while(pending_ops, {:ok, delta}, fn {_v, server_op, _c}, {:ok, current_delta} ->
      case OtEngine.transform(server_op, current_delta, :left) do
        {:ok, transformed} -> {:cont, {:ok, transformed}}
        {:error, _} = err -> {:halt, err}
      end
    end)
  end

  defp broadcast_op(doc_id, delta, version, client_id) do
    pubsub = Application.get_env(:phia_ui, :collab_pubsub, PhiaUi.PubSub)
    topic = "collab:doc:#{doc_id}"

    payload = %{
      event: :op_applied,
      doc_id: doc_id,
      op: delta,
      version: version,
      client_id: client_id
    }

    # Best-effort broadcast; ignore errors if PubSub is not started
    try do
      Phoenix.PubSub.broadcast(pubsub, topic, payload)
    rescue
      _ -> :ok
    end

    :ok
  end

  defp default_name(doc_id) do
    # Use Registry if available, otherwise fall back to a via tuple
    # that will work if the registry is started
    {:via, Registry, {PhiaUi.Collab.RoomRegistry, {:collab_server, doc_id}}}
  end
end
