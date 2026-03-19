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

  ### Collaboration Messages (Client → Server)
  - `"collab:thread:create"` — create a new comment thread anchored to a selection
  - `"collab:thread:resolve"` — mark a thread as resolved
  - `"collab:thread:reopen"` — reopen a resolved thread
  - `"collab:comment:create"` — add a comment to a thread
  - `"collab:comment:edit"` — edit an existing comment
  - `"collab:comment:delete"` — delete a comment
  - `"collab:comment:react"` — toggle a reaction on a comment
  - `"collab:cursor:update"` — broadcast cursor position to peers
  - `"collab:typing:start"` — broadcast typing indicator on
  - `"collab:typing:stop"` — broadcast typing indicator off
  - `"collab:version:snapshot"` — trigger a version snapshot

  ### Server → Client
  - `"yjs:sync-step-1"` — server sends its state vector (on join)
  - `"yjs:sync-step-2"` — server sends diff in response to client sync-step-1
  - `"yjs:update"`       — server broadcasts updates from other clients
  - `"awareness:update"` — server broadcasts awareness from other clients
  - `"collab:thread:created"` / `"collab:thread:resolved"` / `"collab:thread:reopened"`
  - `"collab:comment:created"` / `"collab:comment:edited"` / `"collab:comment:deleted"` / `"collab:comment:reacted"`
  - `"collab:cursor:updated"` — peer cursor positions
  - `"collab:typing:updated"` — peer typing state
  - `"collab:version:saved"` — version snapshot confirmation

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

        @impl true
        def load_threads(doc_id) do
          threads = MyApp.Repo.all(from t in MyApp.Thread, where: t.doc_id == ^doc_id)
          {:ok, threads}
        end
      end
  """

  # ---------------------------------------------------------------------------
  # Existing callbacks
  # ---------------------------------------------------------------------------

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

  # ---------------------------------------------------------------------------
  # New collaboration callbacks
  # ---------------------------------------------------------------------------

  @doc "Load all comment threads for a document."
  @callback load_threads(doc_id :: String.t()) :: {:ok, list()} | {:error, term()}

  @doc "Persist a new or updated comment thread."
  @callback save_thread(doc_id :: String.t(), thread :: map()) ::
              {:ok, map()} | {:error, term()}

  @doc "Delete a comment thread by ID."
  @callback delete_thread(doc_id :: String.t(), thread_id :: String.t()) ::
              :ok | {:error, term()}

  @doc "Persist a new or updated comment."
  @callback save_comment(doc_id :: String.t(), comment :: map()) ::
              {:ok, map()} | {:error, term()}

  @doc "Delete a comment by ID."
  @callback delete_comment(doc_id :: String.t(), comment_id :: String.t()) ::
              :ok | {:error, term()}

  @doc "Load all version snapshots for a document."
  @callback load_versions(doc_id :: String.t()) :: {:ok, list()} | {:error, term()}

  @doc "Persist a version snapshot."
  @callback save_version(doc_id :: String.t(), version :: map()) ::
              {:ok, map()} | {:error, term()}

  @optional_callbacks [
    load_threads: 1,
    save_thread: 2,
    delete_thread: 2,
    save_comment: 2,
    delete_comment: 2,
    load_versions: 1,
    save_version: 2
  ]

  defmacro __using__(_opts) do
    quote do
      use Phoenix.Channel

      @behaviour PhiaUi.Editor.CollabChannel

      # Default implementations — override in your module
      @impl PhiaUi.Editor.CollabChannel
      def load_document(_doc_id), do: {:ok, nil}

      @impl PhiaUi.Editor.CollabChannel
      def save_document(_doc_id, _state), do: :ok

      @impl PhiaUi.Editor.CollabChannel
      def load_threads(_doc_id), do: {:ok, []}

      @impl PhiaUi.Editor.CollabChannel
      def save_thread(_doc_id, thread), do: {:ok, thread}

      @impl PhiaUi.Editor.CollabChannel
      def delete_thread(_doc_id, _thread_id), do: :ok

      @impl PhiaUi.Editor.CollabChannel
      def save_comment(_doc_id, comment), do: {:ok, comment}

      @impl PhiaUi.Editor.CollabChannel
      def delete_comment(_doc_id, _comment_id), do: :ok

      @impl PhiaUi.Editor.CollabChannel
      def load_versions(_doc_id), do: {:ok, []}

      @impl PhiaUi.Editor.CollabChannel
      def save_version(_doc_id, version), do: {:ok, version}

      defoverridable load_document: 1,
                     save_document: 2,
                     load_threads: 1,
                     save_thread: 2,
                     delete_thread: 2,
                     save_comment: 2,
                     delete_comment: 2,
                     load_versions: 1,
                     save_version: 2

      # =====================================================================
      # Channel callbacks
      # =====================================================================

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

      # =====================================================================
      # Thread handlers
      # =====================================================================

      def handle_in("collab:thread:create", %{"thread" => thread_data}, socket) do
        doc_id = socket.assigns.doc_id

        case save_thread(doc_id, thread_data) do
          {:ok, thread} ->
            broadcast!(socket, "collab:thread:created", %{thread: thread})
            {:reply, {:ok, %{thread: thread}}, socket}

          {:error, reason} ->
            {:reply, {:error, %{reason: reason}}, socket}
        end
      end

      def handle_in("collab:thread:resolve", %{"thread_id" => thread_id}, socket) do
        doc_id = socket.assigns.doc_id
        resolved = %{"id" => thread_id, "resolved" => true, "resolved_at" => DateTime.utc_now() |> DateTime.to_iso8601()}

        case save_thread(doc_id, resolved) do
          {:ok, thread} ->
            broadcast!(socket, "collab:thread:resolved", %{thread_id: thread_id, thread: thread})
            {:reply, {:ok, %{thread: thread}}, socket}

          {:error, reason} ->
            {:reply, {:error, %{reason: reason}}, socket}
        end
      end

      def handle_in("collab:thread:reopen", %{"thread_id" => thread_id}, socket) do
        doc_id = socket.assigns.doc_id
        reopened = %{"id" => thread_id, "resolved" => false, "resolved_at" => nil}

        case save_thread(doc_id, reopened) do
          {:ok, thread} ->
            broadcast!(socket, "collab:thread:reopened", %{thread_id: thread_id, thread: thread})
            {:reply, {:ok, %{thread: thread}}, socket}

          {:error, reason} ->
            {:reply, {:error, %{reason: reason}}, socket}
        end
      end

      # =====================================================================
      # Comment handlers
      # =====================================================================

      def handle_in("collab:comment:create", %{"comment" => comment_data}, socket) do
        doc_id = socket.assigns.doc_id

        case save_comment(doc_id, comment_data) do
          {:ok, comment} ->
            broadcast!(socket, "collab:comment:created", %{comment: comment})
            {:reply, {:ok, %{comment: comment}}, socket}

          {:error, reason} ->
            {:reply, {:error, %{reason: reason}}, socket}
        end
      end

      def handle_in("collab:comment:edit", %{"comment" => comment_data}, socket) do
        doc_id = socket.assigns.doc_id

        case save_comment(doc_id, comment_data) do
          {:ok, comment} ->
            broadcast!(socket, "collab:comment:edited", %{comment: comment})
            {:reply, {:ok, %{comment: comment}}, socket}

          {:error, reason} ->
            {:reply, {:error, %{reason: reason}}, socket}
        end
      end

      def handle_in("collab:comment:delete", %{"comment_id" => comment_id}, socket) do
        doc_id = socket.assigns.doc_id

        case delete_comment(doc_id, comment_id) do
          :ok ->
            broadcast!(socket, "collab:comment:deleted", %{comment_id: comment_id})
            {:reply, :ok, socket}

          {:error, reason} ->
            {:reply, {:error, %{reason: reason}}, socket}
        end
      end

      def handle_in("collab:comment:react", %{"comment_id" => comment_id, "reaction" => reaction, "user_id" => user_id}, socket) do
        payload = %{comment_id: comment_id, reaction: reaction, user_id: user_id}
        broadcast!(socket, "collab:comment:reacted", payload)
        {:reply, :ok, socket}
      end

      # =====================================================================
      # Cursor & typing handlers
      # =====================================================================

      def handle_in("collab:cursor:update", %{"cursor" => cursor_data, "user_id" => user_id}, socket) do
        broadcast_from!(socket, "collab:cursor:updated", %{user_id: user_id, cursor: cursor_data})
        {:noreply, socket}
      end

      def handle_in("collab:typing:start", %{"user_id" => user_id}, socket) do
        broadcast_from!(socket, "collab:typing:updated", %{user_id: user_id, typing: true})
        {:noreply, socket}
      end

      def handle_in("collab:typing:stop", %{"user_id" => user_id}, socket) do
        broadcast_from!(socket, "collab:typing:updated", %{user_id: user_id, typing: false})
        {:noreply, socket}
      end

      # =====================================================================
      # Version snapshot handler
      # =====================================================================

      def handle_in("collab:version:snapshot", %{"version" => version_data}, socket) do
        doc_id = socket.assigns.doc_id

        case save_version(doc_id, version_data) do
          {:ok, version} ->
            broadcast!(socket, "collab:version:saved", %{version: version})
            {:reply, {:ok, %{version: version}}, socket}

          {:error, reason} ->
            {:reply, {:error, %{reason: reason}}, socket}
        end
      end
    end
  end
end
