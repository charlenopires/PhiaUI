defmodule PhiaUi.Components.Collab.CollabEditor do
  @moduledoc """
  Composite collaborative editor widget.

  Composes the full collaboration experience: status bar, TipTap editor,
  cursor overlay, thread sidebar, floating composer, and version badge.
  This is the "just give me a collaborative editor" convenience component.

  ## Example

      <.collab_editor
        id="doc-editor"
        doc_id="doc-123"
        current_user={%{id: "u1", name: "Alice", color: "#E53E3E", avatar_url: nil}}
        users={@online_users}
        threads={@threads}
        typing_users={@typing_users}
        connection_status={@connection_status}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Collab.Presence
  alias PhiaUi.Components.Collab.Cursor
  alias PhiaUi.Components.Collab.Thread
  alias PhiaUi.Components.Collab.VersionHistory

  # --------------------------------------------------------------------------
  # collab_editor/1
  # --------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :doc_id, :string, required: true
  attr :current_user, :map, required: true
  attr :users, :list, default: []
  attr :threads, :list, default: []
  attr :typing_users, :list, default: []
  attr :versions, :list, default: []
  attr :notifications, :list, default: []
  attr :connection_status, :atom, default: :connected, values: [:connected, :reconnecting, :offline]
  attr :cursors, :list, default: []
  attr :show_threads, :boolean, default: true
  attr :show_cursors, :boolean, default: true
  attr :show_version_history, :boolean, default: false
  attr :show_notifications, :boolean, default: false
  attr :show_status_bar, :boolean, default: true
  attr :editor_placeholder, :string, default: "Start writing..."
  attr :editor_min_height, :string, default: "400px"
  attr :active_version_id, :string, default: nil
  attr :version_changes, :list, default: []
  attr :last_saved_at, :any, default: nil
  attr :has_unsaved, :boolean, default: false
  attr :mention_suggestions, :list, default: []
  attr :show_mention_dropdown, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  slot :toolbar_extra, doc: "Extra toolbar items injected into the editor toolbar"

  @doc """
  Renders a complete collaborative editing experience.

  Composes status bar, editor, cursors, threads, and version history
  into a single widget. Toggle features via boolean attrs.
  """
  def collab_editor(assigns) do
    assigns =
      assigns
      |> assign_new(:thread_panel_open, fn -> assigns.show_threads end)
      |> assign_new(:version_panel_open, fn -> assigns.show_version_history end)

    ~H"""
    <div
      id={@id}
      data-collab-editor
      data-doc-id={@doc_id}
      class={cn([
        "flex flex-col rounded-xl border border-border bg-background shadow-sm",
        @class
      ])}
      {@rest}
    >
      <%!-- Status bar --%>
      <Presence.collab_status_bar
        :if={@show_status_bar}
        id={"#{@id}-status-bar"}
        connection_status={@connection_status}
        users={@users}
        typing_users={@typing_users}
      >
        <:extra>
          <%!-- Thread toggle --%>
          <button
            :if={@show_threads}
            type="button"
            phx-click="collab:toggle:threads"
            class="inline-flex items-center gap-1.5 rounded-md px-2.5 py-1 text-xs font-medium text-muted-foreground hover:bg-accent hover:text-accent-foreground transition-colors"
            title="Toggle threads panel"
          >
            <svg class="h-3.5 w-3.5" viewBox="0 0 16 16" fill="none">
              <path d="M2 3h12M2 6.5h8M2 10h10M2 13.5h6" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" />
            </svg>
            <span>Threads</span>
            <span
              :if={unresolved_count(@threads) > 0}
              class="inline-flex items-center justify-center rounded-full bg-primary px-1.5 text-[10px] font-semibold text-primary-foreground"
            >
              {unresolved_count(@threads)}
            </span>
          </button>

          <%!-- Version history toggle --%>
          <button
            type="button"
            phx-click="collab:toggle:versions"
            class="inline-flex items-center gap-1.5 rounded-md px-2.5 py-1 text-xs font-medium text-muted-foreground hover:bg-accent hover:text-accent-foreground transition-colors"
            title="Version history"
          >
            <svg class="h-3.5 w-3.5" viewBox="0 0 16 16" fill="none">
              <circle cx="8" cy="8" r="6" stroke="currentColor" stroke-width="1.4" />
              <path d="M8 5v3l2 2" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round" />
            </svg>
            <span>History</span>
          </button>
        </:extra>
      </Presence.collab_status_bar>

      <%!-- Main content area: editor + optional side panels --%>
      <div class="flex flex-1 overflow-hidden">
        <%!-- Editor area --%>
        <div class="relative flex-1 min-w-0">
          <%!-- Editor content area (TipTap mounts here) --%>
          <div
            id={"#{@id}-editor-container"}
            phx-hook="PhiaTipTap"
            data-content=""
            data-placeholder={@editor_placeholder}
            data-extensions={Jason.encode!([:starter_kit, :placeholder, :collaboration])}
            data-on-update="editor:update"
            data-on-selection="editor:selection"
            data-content-format="json"
            data-collab-enabled="true"
            data-collab-doc-id={@doc_id}
            data-collab-user-id={@current_user.id}
            data-collab-user-name={@current_user.name}
            data-collab-user-color={@current_user.color}
            class="flex flex-col"
          >
            <%!-- Toolbar --%>
            <div class="border-b border-border px-2 py-1.5">
              {render_slot(@toolbar_extra)}
            </div>

            <%!-- Content area --%>
            <div
              data-tiptap-content
              class="prose prose-sm max-w-none flex-1 px-4 py-3 focus:outline-none dark:prose-invert"
              style={"min-height: #{@editor_min_height}"}
            />

            <%!-- Hidden input for form submission --%>
            <input type="hidden" id={"#{@id}-value"} name={@doc_id} value="" data-tiptap-hidden />
          </div>

          <%!-- Cursor overlay --%>
          <Cursor.collab_cursors_overlay
            :if={@show_cursors}
            id={"#{@id}-cursors"}
            cursors={@cursors}
          />
        </div>

        <%!-- Thread sidebar panel --%>
        <div
          :if={@show_threads && @thread_panel_open}
          class="w-80 shrink-0 border-l border-border overflow-y-auto bg-background"
        >
          <Thread.collab_thread_list
            id={"#{@id}-threads"}
            threads={@threads}
            current_user_id={@current_user.id}
          />
        </div>

        <%!-- Version history panel --%>
        <VersionHistory.version_panel
          :if={@version_panel_open}
          id={"#{@id}-versions"}
          versions={@versions}
          active_version_id={@active_version_id}
          changes={@version_changes}
        />
      </div>

      <%!-- Footer: version badge --%>
      <div class="flex items-center justify-between border-t border-border px-4 py-1.5">
        <VersionHistory.version_badge
          id={"#{@id}-version-badge"}
          last_saved_at={@last_saved_at}
          has_unsaved={@has_unsaved}
        />

        <div class="flex items-center gap-2 text-xs text-muted-foreground">
          <span data-tiptap-word-count>0 words</span>
        </div>
      </div>
    </div>
    """
  end

  defp unresolved_count(threads) when is_list(threads) do
    Enum.count(threads, fn t -> !Map.get(t, :resolved, false) end)
  end

  defp unresolved_count(_), do: 0
end
