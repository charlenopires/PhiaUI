defmodule PhiaUi.Collab.CollabRoom do
  @moduledoc """
  GenServer managing a single collaboration room session.

  Started on-demand via `DynamicSupervisor` when the first user joins
  (see `PhiaUi.Collab.RoomManager.join_or_create_room/2`).
  Auto-terminates after an idle timeout (default 30 minutes) when all
  users have left.

  ## Behaviour Callbacks

  Implement the behaviour in your own module to persist room state:

      defmodule MyApp.CollabRoom do
        @behaviour PhiaUi.Collab.CollabRoom

        @impl true
        def on_join(room_id, user), do: {:ok, %{}}

        @impl true
        def on_leave(room_id, user), do: :ok

        @impl true
        def load_room_state(room_id), do: {:ok, %{}}

        @impl true
        def save_room_state(room_id, state), do: :ok
      end

  ## State Structure

  The GenServer state is a `%PhiaUi.Collab.CollabRoom{}` struct containing:

    - `:room_id` — unique identifier for this room
    - `:callback_module` — optional module implementing this behaviour
    - `:users` — map of `user_id => user_entry` for all joined users
    - `:custom_state` — arbitrary map managed via `update_state/2`
    - `:created_at` / `:last_activity_at` — UTC timestamps
    - `:idle_timeout` — milliseconds before an empty room shuts down
  """

  use GenServer

  require Logger

  # ---------------------------------------------------------------------------
  # Behaviour callbacks
  # ---------------------------------------------------------------------------

  @doc "Called when a user joins the room. Return `{:ok, meta}` to attach metadata."
  @callback on_join(room_id :: String.t(), user :: map()) :: {:ok, map()} | {:error, term()}

  @doc "Called when a user leaves the room."
  @callback on_leave(room_id :: String.t(), user :: map()) :: :ok

  @doc "Load persisted room state on startup. Return `{:ok, state_map}` or `{:error, reason}`."
  @callback load_room_state(room_id :: String.t()) :: {:ok, map()} | {:error, term()}

  @doc "Persist room state after each `update_state/2` call."
  @callback save_room_state(room_id :: String.t(), state :: map()) :: :ok | {:error, term()}

  @optional_callbacks [on_join: 2, on_leave: 2, load_room_state: 1, save_room_state: 2]

  @default_idle_timeout :timer.minutes(30)

  # ---------------------------------------------------------------------------
  # Struct
  # ---------------------------------------------------------------------------

  defstruct [
    :room_id,
    :callback_module,
    users: %{},
    custom_state: %{},
    created_at: nil,
    last_activity_at: nil,
    idle_timeout: @default_idle_timeout
  ]

  # ---------------------------------------------------------------------------
  # Public API
  # ---------------------------------------------------------------------------

  @doc """
  Start a `CollabRoom` process linked to the caller.

  ## Options
    - `:room_id` (required) — unique room identifier
    - `:callback_module` — module implementing `CollabRoom` behaviour
    - `:idle_timeout` — milliseconds before empty room shuts down (default 30 min)
  """
  def start_link(opts) do
    room_id = Keyword.fetch!(opts, :room_id)
    name = via_tuple(room_id)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @doc "Join a user to the room. `user` must contain an `:id` key."
  @spec join(String.t(), map()) :: {:ok, map()} | {:error, term()}
  def join(room_id, user) do
    GenServer.call(via_tuple(room_id), {:join, user})
  end

  @doc "Remove a user from the room by user ID."
  @spec leave(String.t(), String.t()) :: :ok
  def leave(room_id, user_id) do
    GenServer.cast(via_tuple(room_id), {:leave, user_id})
  end

  @doc "Get the room's custom state."
  @spec get_state(String.t()) :: {:ok, map()}
  def get_state(room_id) do
    GenServer.call(via_tuple(room_id), :get_state)
  end

  @doc "Get all users currently in the room."
  @spec get_users(String.t()) :: {:ok, [map()]}
  def get_users(room_id) do
    GenServer.call(via_tuple(room_id), :get_users)
  end

  @doc """
  Update the room's custom state by applying `fun` to the current state.

  The function receives the current custom state map and must return the new state map.
  If a callback module with `save_room_state/2` is configured, it is called after the update.
  """
  @spec update_state(String.t(), (map() -> map())) :: :ok
  def update_state(room_id, fun) when is_function(fun, 1) do
    GenServer.call(via_tuple(room_id), {:update_state, fun})
  end

  @doc "Refresh the room's last-activity timestamp to prevent idle shutdown."
  @spec touch(String.t()) :: :ok
  def touch(room_id) do
    GenServer.cast(via_tuple(room_id), :touch)
  end

  @doc "Check whether a room process is running."
  @spec alive?(String.t()) :: boolean()
  def alive?(room_id) do
    case Registry.lookup(PhiaUi.Collab.RoomRegistry, room_id) do
      [{_pid, _}] -> true
      [] -> false
    end
  end

  @doc false
  def via_tuple(room_id) do
    {:via, Registry, {PhiaUi.Collab.RoomRegistry, room_id}}
  end

  # ---------------------------------------------------------------------------
  # GenServer callbacks
  # ---------------------------------------------------------------------------

  @impl GenServer
  def init(opts) do
    room_id = Keyword.fetch!(opts, :room_id)
    callback_module = Keyword.get(opts, :callback_module)
    idle_timeout = Keyword.get(opts, :idle_timeout, @default_idle_timeout)

    now = DateTime.utc_now()

    custom_state =
      if callback_module && function_exported?(callback_module, :load_room_state, 1) do
        case callback_module.load_room_state(room_id) do
          {:ok, state} -> state
          {:error, _reason} -> %{}
        end
      else
        %{}
      end

    state = %__MODULE__{
      room_id: room_id,
      callback_module: callback_module,
      custom_state: custom_state,
      created_at: now,
      last_activity_at: now,
      idle_timeout: idle_timeout
    }

    schedule_idle_check(idle_timeout)

    Logger.debug("CollabRoom started: #{room_id}")
    {:ok, state}
  end

  @impl GenServer
  def handle_call({:join, user}, _from, state) do
    user_id = Map.fetch!(user, :id)
    callback = state.callback_module

    result =
      if callback && function_exported?(callback, :on_join, 2) do
        callback.on_join(state.room_id, user)
      else
        {:ok, %{}}
      end

    case result do
      {:ok, meta} ->
        user_entry = Map.merge(user, %{joined_at: DateTime.utc_now(), meta: meta})
        new_users = Map.put(state.users, user_id, user_entry)
        new_state = %{state | users: new_users, last_activity_at: DateTime.utc_now()}
        {:reply, {:ok, user_entry}, new_state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call(:get_state, _from, state) do
    {:reply, {:ok, state.custom_state}, state}
  end

  def handle_call(:get_users, _from, state) do
    {:reply, {:ok, Map.values(state.users)}, state}
  end

  def handle_call({:update_state, fun}, _from, state) do
    new_custom = fun.(state.custom_state)

    callback = state.callback_module

    if callback && function_exported?(callback, :save_room_state, 2) do
      callback.save_room_state(state.room_id, new_custom)
    end

    new_state = %{state | custom_state: new_custom, last_activity_at: DateTime.utc_now()}
    {:reply, :ok, new_state}
  end

  @impl GenServer
  def handle_cast({:leave, user_id}, state) do
    user = Map.get(state.users, user_id)
    callback = state.callback_module

    if user && callback && function_exported?(callback, :on_leave, 2) do
      callback.on_leave(state.room_id, user)
    end

    new_users = Map.delete(state.users, user_id)
    new_state = %{state | users: new_users, last_activity_at: DateTime.utc_now()}

    if map_size(new_users) == 0 do
      Logger.debug("CollabRoom empty, scheduling idle check: #{state.room_id}")
    end

    {:noreply, new_state}
  end

  def handle_cast(:touch, state) do
    {:noreply, %{state | last_activity_at: DateTime.utc_now()}}
  end

  @impl GenServer
  def handle_info(:check_idle, state) do
    if map_size(state.users) == 0 do
      elapsed = DateTime.diff(DateTime.utc_now(), state.last_activity_at, :millisecond)

      if elapsed >= state.idle_timeout do
        Logger.debug("CollabRoom idle shutdown: #{state.room_id}")
        {:stop, :normal, state}
      else
        remaining = state.idle_timeout - elapsed
        schedule_idle_check(remaining)
        {:noreply, state}
      end
    else
      schedule_idle_check(state.idle_timeout)
      {:noreply, state}
    end
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp schedule_idle_check(timeout) do
    Process.send_after(self(), :check_idle, timeout)
  end
end
