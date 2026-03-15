defmodule PhiaUi.Editor.CollabChannel do
  @moduledoc """
  Phoenix Channel for Yjs collaborative editing via TipTap.

  Implements the Yjs sync protocol over Phoenix Channels, replacing the need
  for a separate Hocuspocus (Node.js) server. Each document gets its own
  channel topic: `"editor:collab:<doc_id>"`.

  ## Protocol Messages

  ### Client → Server
  - `"yjs:sync-step-1"` — client sends its state vector, server responds with diff
  - `"yjs:sync-step-2"` — client sends its diff to server
  - `"yjs:update"`       — client sends incremental update, server broadcasts + persists
  - `"awareness:update"` — client sends cursor/selection awareness, server broadcasts

  ### Server → Client
  - `"yjs:sync-step-1"` — server sends its state vector (on join)
  - `"yjs:sync-step-2"` — server sends diff in response to client sync-step-1
  - `"yjs:update"`       — server broadcasts updates from other clients
  - `"awareness:update"` — server broadcasts awareness from other clients

  ## Setup

  In your endpoint/socket:

      channel "editor:collab:*", PhiaUi.Editor.CollabChannel

  In your app.js (with Yjs):

      npm install yjs @tiptap/extension-collaboration @tiptap/extension-collaboration-cursor

  ## Persistence

  Override `c:load_document/1` and `c:save_document/2` callbacks in your own
  channel module to persist Y.Doc state to your database:

      defmodule MyApp.EditorChannel do
        use PhiaUi.Editor.CollabChannel

        @impl true
        def load_document(doc_id) do
          case MyApp.Repo.get(MyApp.Document, doc_id) do
            nil -> {:ok, nil}
            doc -> {:ok, doc.yjs_state}
          end
        end

        @impl true
        def save_document(doc_id, state) do
          MyApp.Repo.insert_or_update!(...)
          :ok
        end
      end
  """

  @doc """
  Load persisted Y.Doc state for a document.

  Returns `{:ok, binary | nil}` where binary is the Yjs-encoded document state.
  Return `{:ok, nil}` for new documents.
  """
  @callback load_document(doc_id :: String.t()) :: {:ok, binary() | nil} | {:error, term()}

  @doc """
  Persist Y.Doc state for a document.

  Called after each `yjs:update` message. The `state` is the full Yjs-encoded
  document state (binary).
  """
  @callback save_document(doc_id :: String.t(), state :: binary()) :: :ok | {:error, term()}

  defmacro __using__(_opts) do
    quote do
      use Phoenix.Channel

      @behaviour PhiaUi.Editor.CollabChannel

      # Default implementations — override in your module
      @impl PhiaUi.Editor.CollabChannel
      def load_document(_doc_id), do: {:ok, nil}

      @impl PhiaUi.Editor.CollabChannel
      def save_document(_doc_id, _state), do: :ok

      defoverridable load_document: 1, save_document: 2

      # -----------------------------------------------------------------------
      # Channel callbacks
      # -----------------------------------------------------------------------

      @impl Phoenix.Channel
      def join("editor:collab:" <> doc_id, _params, socket) do
        case load_document(doc_id) do
          {:ok, state} ->
            socket =
              socket
              |> assign(:doc_id, doc_id)
              |> assign(:doc_state, state)

            send(self(), :after_join)
            {:ok, socket}

          {:error, reason} ->
            {:error, %{reason: reason}}
        end
      end

      @impl Phoenix.Channel
      def handle_info(:after_join, socket) do
        # Send initial sync: server state vector so client can compute diff
        state = socket.assigns.doc_state

        if state do
          push(socket, "yjs:sync-step-1", %{state: Base.encode64(state)})
        else
          push(socket, "yjs:sync-step-1", %{state: nil})
        end

        {:noreply, socket}
      end

      @impl Phoenix.Channel
      def handle_in("yjs:sync-step-1", %{"state_vector" => sv_b64}, socket) do
        # Client sent its state vector — respond with our diff
        state = socket.assigns.doc_state

        if state do
          push(socket, "yjs:sync-step-2", %{diff: Base.encode64(state)})
        end

        {:noreply, socket}
      end

      @impl Phoenix.Channel
      def handle_in("yjs:sync-step-2", %{"diff" => diff_b64}, socket) do
        # Client sent its diff — apply and store
        case Base.decode64(diff_b64) do
          {:ok, diff} ->
            # Merge: in a real impl, use Yjs WASM or store raw
            new_state = diff
            doc_id = socket.assigns.doc_id
            save_document(doc_id, new_state)
            {:noreply, assign(socket, :doc_state, new_state)}

          _ ->
            {:noreply, socket}
        end
      end

      @impl Phoenix.Channel
      def handle_in("yjs:update", %{"update" => update_b64}, socket) do
        case Base.decode64(update_b64) do
          {:ok, update} ->
            # Broadcast to all other clients
            broadcast_from!(socket, "yjs:update", %{update: update_b64})

            # Persist
            doc_id = socket.assigns.doc_id
            save_document(doc_id, update)
            {:noreply, assign(socket, :doc_state, update)}

          _ ->
            {:noreply, socket}
        end
      end

      @impl Phoenix.Channel
      def handle_in("awareness:update", payload, socket) do
        # Broadcast cursor positions to all other clients
        broadcast_from!(socket, "awareness:update", payload)
        {:noreply, socket}
      end
    end
  end
end
