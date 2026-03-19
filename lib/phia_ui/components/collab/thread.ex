defmodule PhiaUi.Components.Collab.Thread do
  @moduledoc """
  Thread Suite — 5 components for managing comment threads in collaborative contexts.

  ## Components

  - `collab_thread/1`          — Full thread view: root comment + replies + composer slot
  - `collab_thread_header/1`   — Header bar with resolve/close actions and reply count
  - `collab_thread_list/1`     — Sidebar list of all threads with sort/filter
  - `collab_floating_thread/1` — Absolutely-positioned thread (PhiaFloatingThread hook)
  - `collab_thread_resolved/1` — Collapsed resolved thread with reopen action
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Collab.CollabComment

  alias PhiaUi.Components.Collab.CollabHelpers
  alias PhiaUi.Components.Collab.MentionHelpers
  alias PhiaUi.Components.Collab.ThreadHelpers

  # ============================================================================
  # collab_thread/1
  # ============================================================================

  @doc """
  Renders a full thread view with root comment, replies, and a composer slot.

  The thread displays all comments in chronological order with a header bar
  showing resolve/reopen controls.

  ## Attributes

  - `:thread` — thread map with keys: `id`, `resolved`, `comments` (list of comment maps)
  - `:current_user_id` — ID of the viewing user
  - `:on_resolve` — event name when resolving a thread
  - `:on_reopen` — event name when reopening a resolved thread

  ## Slots

  - `:composer` — slot for a composer component at the bottom of the thread
  """
  attr :id, :string, required: true
  attr :thread, :map, required: true
  attr :current_user_id, :string, default: nil
  attr :on_resolve, :string, default: "collab:thread:resolve"
  attr :on_reopen, :string, default: "collab:thread:reopen"
  attr :class, :string, default: nil

  slot :composer

  def collab_thread(assigns) do
    comments = assigns.thread[:comments] || []
    reply_count = ThreadHelpers.thread_reply_count(assigns.thread)

    assigns =
      assigns
      |> assign(:comments, comments)
      |> assign(:reply_count, reply_count)

    ~H"""
    <div
      id={@id}
      class={cn(["flex flex-col rounded-lg border border-border bg-card shadow-sm overflow-hidden", @class])}
      data-thread-id={@thread.id}
      role="article"
      aria-label={"Comment thread with #{@reply_count} replies"}
    >
      <%!-- Header --%>
      <.collab_thread_header
        id={"#{@id}-header"}
        thread_id={@thread.id}
        resolved={@thread[:resolved] || false}
        reply_count={@reply_count}
        on_resolve={@on_resolve}
        on_reopen={@on_reopen}
      />

      <%!-- Comments --%>
      <div class="flex-1 overflow-y-auto divide-y divide-border/50">
        <.collab_comment
          :for={{comment, idx} <- Enum.with_index(@comments)}
          id={"#{@id}-comment-#{idx}"}
          comment={comment}
          current_user_id={@current_user_id}
          editable={true}
        />
      </div>

      <%!-- Composer slot --%>
      <div :if={@composer != []} class="border-t border-border">
        <%= for c <- @composer do %>
          {render_slot(c)}
        <% end %>
      </div>
    </div>
    """
  end

  # ============================================================================
  # collab_thread_header/1
  # ============================================================================

  @doc """
  Renders the thread header bar with resolve/reopen and close actions.

  Shows a reply count and action buttons. When the thread is resolved,
  the resolve button switches to a reopen button.
  """
  attr :id, :string, required: true
  attr :thread_id, :string, required: true
  attr :resolved, :boolean, default: false
  attr :reply_count, :integer, default: 0
  attr :on_resolve, :string, default: "collab:thread:resolve"
  attr :on_reopen, :string, default: "collab:thread:reopen"
  attr :on_close, :string, default: "collab:thread:close"
  attr :class, :string, default: nil

  def collab_thread_header(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn(["flex items-center justify-between gap-2 px-3 py-2 bg-muted/50 border-b border-border", @class])}
      data-thread-drag-handle
    >
      <div class="flex items-center gap-2 text-sm">
        <span :if={@resolved} class="inline-flex items-center gap-1 text-xs font-medium text-green-600">
          <svg class="size-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M20 6 9 17l-5-5" />
          </svg>
          Resolved
        </span>
        <span class="text-muted-foreground">
          {@reply_count} {if @reply_count == 1, do: "reply", else: "replies"}
        </span>
      </div>

      <div class="flex items-center gap-1">
        <%= if @resolved do %>
          <button
            type="button"
            phx-click={@on_reopen}
            phx-value-thread-id={@thread_id}
            class="inline-flex items-center gap-1 rounded-md px-2 py-1 text-xs font-medium text-muted-foreground hover:bg-muted hover:text-foreground transition-colors"
            aria-label="Reopen thread"
          >
            <svg class="size-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8" />
              <path d="M21 3v5h-5" />
              <path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16" />
              <path d="M8 16H3v5" />
            </svg>
            Reopen
          </button>
        <% else %>
          <button
            type="button"
            phx-click={@on_resolve}
            phx-value-thread-id={@thread_id}
            class="inline-flex items-center gap-1 rounded-md px-2 py-1 text-xs font-medium text-green-600 hover:bg-green-50 transition-colors"
            aria-label="Resolve thread"
          >
            <svg class="size-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M20 6 9 17l-5-5" />
            </svg>
            Resolve
          </button>
        <% end %>

        <button
          type="button"
          phx-click={@on_close}
          phx-value-thread-id={@thread_id}
          class="inline-flex items-center justify-center size-7 rounded-md text-muted-foreground hover:bg-muted hover:text-foreground transition-colors"
          aria-label="Close thread"
        >
          <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M18 6 6 18M6 6l12 12" />
          </svg>
        </button>
      </div>
    </div>
    """
  end

  # ============================================================================
  # collab_thread_list/1
  # ============================================================================

  @doc """
  Renders a sidebar list of all threads with sort and filter controls.

  Each thread item shows a preview of the root comment, reply count, and
  participant avatars. Supports sorting by date, activity, or unresolved-first.
  """
  attr :id, :string, required: true
  attr :threads, :list, default: []
  attr :current_user_id, :string, default: nil
  attr :sort_by, :atom, default: :activity, values: [:date, :activity, :unresolved_first]
  attr :show_resolved, :boolean, default: true
  attr :class, :string, default: nil

  def collab_thread_list(assigns) do
    filtered =
      if assigns.show_resolved do
        assigns.threads
      else
        ThreadHelpers.filter_threads(assigns.threads, resolved: false)
      end

    sorted = ThreadHelpers.sort_threads(filtered, assigns.sort_by)
    assigns = assign(assigns, :sorted_threads, sorted)

    ~H"""
    <div
      id={@id}
      class={cn(["flex flex-col gap-1 overflow-y-auto", @class])}
      role="list"
      aria-label="Comment threads"
    >
      <div :if={@sorted_threads == []} class="flex items-center justify-center py-8 text-sm text-muted-foreground">
        No threads yet
      </div>

      <div
        :for={thread <- @sorted_threads}
        class={
          cn([
            "flex flex-col gap-1 p-3 rounded-lg border border-border/50 cursor-pointer transition-colors",
            "hover:bg-muted/50",
            if(thread[:resolved], do: "opacity-60", else: "")
          ])
        }
        role="listitem"
        phx-click="collab:thread:open"
        phx-value-thread-id={thread.id}
      >
        <%!-- Thread preview --%>
        <div class="flex items-start gap-2">
          <div class="flex-1 min-w-0">
            <% root_comment = List.first(thread.comments || []) %>
            <p :if={root_comment} class="text-sm text-foreground line-clamp-2">
              {MentionHelpers.render_mentions(root_comment.body || "")}
            </p>
            <div class="flex items-center gap-2 mt-1">
              <span class="text-xs text-muted-foreground">
                {CollabHelpers.format_relative_time(thread[:created_at])}
              </span>
              <span class="text-xs text-muted-foreground">
                {ThreadHelpers.thread_reply_count(thread)} replies
              </span>
              <span :if={thread[:resolved]} class="text-xs text-green-600 font-medium">
                Resolved
              </span>
            </div>
          </div>

          <%!-- Participant avatars --%>
          <div class="flex -space-x-1 shrink-0">
            <div
              :for={user_id <- Enum.take(ThreadHelpers.thread_participants(thread), 3)}
              class="size-5 rounded-full border border-background text-[8px] font-bold text-white flex items-center justify-center"
              style={"background-color: #{CollabHelpers.collab_color(user_id)}"}
            >
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # ============================================================================
  # collab_floating_thread/1
  # ============================================================================

  @doc """
  Renders an absolutely-positioned thread panel.

  Anchored to a specific `(x, y)` position within a document or editor.
  Uses the `PhiaFloatingThread` JS hook for drag and click-outside-to-dismiss.
  """
  attr :id, :string, required: true
  attr :thread, :map, required: true
  attr :x, :any, default: 0
  attr :y, :any, default: 0
  attr :current_user_id, :string, default: nil
  attr :class, :string, default: nil

  slot :composer

  def collab_floating_thread(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn(["absolute z-50 w-80 max-h-96 flex flex-col rounded-lg border border-border bg-card shadow-lg overflow-hidden", @class])}
      style={"left: #{@x}px; top: #{@y}px;"}
      phx-hook="PhiaFloatingThread"
      data-thread-id={@thread.id}
      data-x={@x}
      data-y={@y}
    >
      <.collab_thread
        id={"#{@id}-thread"}
        thread={@thread}
        current_user_id={@current_user_id}
      >
        <:composer :for={c <- @composer}>
          {render_slot(c)}
        </:composer>
      </.collab_thread>
    </div>
    """
  end

  # ============================================================================
  # collab_thread_resolved/1
  # ============================================================================

  @doc """
  Renders a collapsed view of a resolved thread.

  Shows a summary with the root comment preview and a reopen button.
  """
  attr :id, :string, required: true
  attr :thread, :map, required: true
  attr :on_reopen, :string, default: "collab:thread:reopen"
  attr :class, :string, default: nil

  def collab_thread_resolved(assigns) do
    root_comment = List.first(assigns.thread[:comments] || [])
    preview = CollabHelpers.truncate_preview(root_comment && root_comment[:body], 80)
    reply_count = ThreadHelpers.thread_reply_count(assigns.thread)

    assigns =
      assigns
      |> assign(:root_comment, root_comment)
      |> assign(:preview, preview)
      |> assign(:reply_count, reply_count)

    ~H"""
    <div
      id={@id}
      class={cn(["flex items-center gap-3 p-3 rounded-lg border border-border/50 bg-muted/30 opacity-70 hover:opacity-100 transition-opacity", @class])}
      data-thread-id={@thread.id}
    >
      <div class="shrink-0">
        <svg class="size-5 text-green-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M20 6 9 17l-5-5" />
        </svg>
      </div>

      <div class="flex-1 min-w-0">
        <p class="text-sm text-muted-foreground truncate">{@preview}</p>
        <span class="text-xs text-muted-foreground">{@reply_count} replies</span>
      </div>

      <button
        type="button"
        phx-click={@on_reopen}
        phx-value-thread-id={@thread.id}
        class="shrink-0 inline-flex items-center gap-1 rounded-md px-2 py-1 text-xs font-medium text-muted-foreground hover:bg-muted hover:text-foreground transition-colors"
        aria-label="Reopen thread"
      >
        Reopen
      </button>
    </div>
    """
  end
end
