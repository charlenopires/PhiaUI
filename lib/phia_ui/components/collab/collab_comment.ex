defmodule PhiaUi.Components.Collab.CollabComment do
  @moduledoc """
  Collaboration Comment Suite — 6 components for rendering and interacting
  with comments in a collaborative editing context.

  ## Components

  - `collab_comment/1`          — Single comment with avatar, body, reactions, actions
  - `collab_comment_body/1`     — Comment body with rendered @mentions
  - `collab_comment_reactions/1` — Emoji reaction bar
  - `collab_comment_actions/1`  — Edit/Delete action dropdown
  - `collab_comment_pin/1`      — Pin marker for document annotations
  - `collab_comment_indicator/1` — Margin indicator showing comment count
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Collab.CollabHelpers

  # ============================================================================
  # collab_comment/1
  # ============================================================================

  @doc """
  Renders a single collaboration comment.

  Displays an avatar on the left, and the comment body, header (name + time),
  action menu, and reactions bar on the right.

  ## Attributes

  - `:id` — unique identifier (required)
  - `:comment` — comment map with keys: `id`, `user_id`, `user_name`, `user_color`,
    `user_avatar_url`, `body`, `created_at`, `edited_at`, `reactions`, `thread_id`
  - `:current_user_id` — ID of the viewing user, for edit/delete permissions
  - `:editable` — whether the comment can be edited
  - `:on_edit` — event name for edit action
  - `:on_delete` — event name for delete action
  - `:on_react` — event name for reaction action

  ## Slots

  - `:header_extra` — extra content after the header line
  - `:footer_extra` — extra content after the reactions
  """
  attr :id, :string, required: true
  attr :comment, :map, required: true
  attr :current_user_id, :string, default: nil
  attr :editable, :boolean, default: false
  attr :on_edit, :string, default: "collab:comment:edit"
  attr :on_delete, :string, default: "collab:comment:delete"
  attr :on_react, :string, default: "collab:comment:react"
  attr :class, :string, default: nil
  attr :rest, :global

  slot :header_extra
  slot :footer_extra

  def collab_comment(assigns) do
    can_edit = assigns.editable and assigns.comment.user_id == assigns.current_user_id
    can_delete = assigns.comment.user_id == assigns.current_user_id
    initials = CollabHelpers.user_initials(assigns.comment[:user_name])
    color = assigns.comment[:user_color] || CollabHelpers.collab_color(assigns.comment.user_id)
    relative_time = CollabHelpers.format_relative_time(assigns.comment[:created_at])

    edited =
      assigns.comment[:edited_at] != nil and assigns.comment[:edited_at] != assigns.comment[:created_at]

    reactions = assigns.comment[:reactions] || []

    assigns =
      assigns
      |> assign(:can_edit, can_edit)
      |> assign(:can_delete, can_delete)
      |> assign(:initials, initials)
      |> assign(:color, color)
      |> assign(:relative_time, relative_time)
      |> assign(:edited, edited)
      |> assign(:reactions_list, reactions)

    ~H"""
    <div
      id={@id}
      class={cn(["group flex gap-3 p-3 rounded-lg hover:bg-muted/50 transition-colors", @class])}
      data-comment-id={@comment.id}
      {@rest}
    >
      <%!-- Avatar --%>
      <div class="shrink-0">
        <%= if @comment[:user_avatar_url] do %>
          <img
            src={@comment.user_avatar_url}
            alt={@comment[:user_name] || "User"}
            class="size-8 rounded-full object-cover ring-2 ring-background"
          />
        <% else %>
          <div
            class="size-8 rounded-full flex items-center justify-center text-xs font-semibold text-white ring-2 ring-background"
            style={"background-color: #{@color}"}
          >
            {@initials}
          </div>
        <% end %>
      </div>

      <%!-- Body area --%>
      <div class="flex-1 min-w-0">
        <%!-- Header --%>
        <div class="flex items-center gap-2 mb-1">
          <span class="text-sm font-semibold text-foreground truncate">
            {@comment[:user_name] || "Anonymous"}
          </span>
          <span class="text-xs text-muted-foreground shrink-0">{@relative_time}</span>
          <span :if={@edited} class="text-xs text-muted-foreground italic">(edited)</span>
          <%= for extra <- @header_extra do %>
            {render_slot(extra)}
          <% end %>
          <div class="ml-auto opacity-0 group-hover:opacity-100 transition-opacity">
            <.collab_comment_actions
              id={"#{@id}-actions"}
              comment_id={@comment.id}
              can_edit={@can_edit}
              can_delete={@can_delete}
              on_edit={@on_edit}
              on_delete={@on_delete}
            />
          </div>
        </div>

        <%!-- Comment body --%>
        <.collab_comment_body body={@comment.body} />

        <%!-- Reactions --%>
        <.collab_comment_reactions
          :if={@reactions_list != []}
          id={"#{@id}-reactions"}
          reactions={@reactions_list}
          on_react={@on_react}
        />

        <%!-- Footer extra --%>
        <%= for extra <- @footer_extra do %>
          {render_slot(extra)}
        <% end %>
      </div>
    </div>
    """
  end

  # ============================================================================
  # collab_comment_body/1
  # ============================================================================

  @doc """
  Renders the comment body text with @mentions highlighted.

  Mention format in raw text: `@[Display Name](user_id)`.
  Rendered as a styled span with the display name.
  """
  attr :body, :string, required: true
  attr :class, :string, default: nil

  def collab_comment_body(assigns) do
    parts = build_body_parts(assigns.body || "")
    assigns = assign(assigns, :parts, parts)

    ~H"""
    <div class={cn(["text-sm text-foreground leading-relaxed whitespace-pre-wrap break-words", @class])}>
      <%= for part <- @parts do %>
        <%= case part do %>
          <% {:mention, name} -> %>
            <span class="font-medium text-primary bg-primary/10 rounded px-0.5">@{name}</span>
          <% {:text, text} -> %>
            {text}
        <% end %>
      <% end %>
    </div>
    """
  end

  defp build_body_parts(text) do
    regex = ~r/@\[([^\]]+)\]\(([^)]+)\)/

    case Regex.split(regex, text, include_captures: true) do
      parts when is_list(parts) ->
        Enum.map(parts, fn segment ->
          case Regex.run(regex, segment) do
            [_full, name, _user_id] -> {:mention, name}
            _ -> {:text, segment}
          end
        end)
        |> Enum.reject(fn {_type, val} -> val == "" end)
    end
  end

  # ============================================================================
  # collab_comment_reactions/1
  # ============================================================================

  @doc """
  Renders a row of emoji reaction pills.

  Each reaction shows the emoji and count. Active reactions (where the
  current user has reacted) are highlighted. Includes a "+" button to
  add a new reaction.
  """
  attr :id, :string, required: true
  attr :reactions, :list, default: []
  attr :on_react, :string, default: "collab:comment:react"
  attr :class, :string, default: nil

  def collab_comment_reactions(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn(["flex flex-wrap items-center gap-1 mt-2", @class])}
      role="group"
      aria-label="Reactions"
    >
      <button
        :for={reaction <- @reactions}
        type="button"
        phx-click={@on_react}
        phx-value-emoji={reaction.emoji}
        class={
          cn([
            "inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-xs border transition-colors",
            "hover:bg-muted",
            if(reaction[:reacted],
              do: "bg-primary/10 border-primary/30 text-primary",
              else: "bg-background border-border text-muted-foreground"
            )
          ])
        }
        aria-label={"React with #{reaction.emoji}"}
        aria-pressed={to_string(reaction[:reacted] || false)}
      >
        <span>{reaction.emoji}</span>
        <span>{reaction.count}</span>
      </button>

      <button
        type="button"
        phx-click={@on_react}
        phx-value-emoji="add"
        class="inline-flex items-center justify-center size-6 rounded-full border border-dashed border-border text-muted-foreground hover:bg-muted hover:border-solid transition-colors"
        aria-label="Add reaction"
      >
        <svg class="size-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M12 5v14M5 12h14" />
        </svg>
      </button>
    </div>
    """
  end

  # ============================================================================
  # collab_comment_actions/1
  # ============================================================================

  @doc """
  Renders a three-dot action menu for a comment with edit and delete options.

  Only shows actions the current user is permitted to perform.
  """
  attr :id, :string, required: true
  attr :comment_id, :string, required: true
  attr :can_edit, :boolean, default: false
  attr :can_delete, :boolean, default: false
  attr :on_edit, :string, default: "collab:comment:edit"
  attr :on_delete, :string, default: "collab:comment:delete"
  attr :class, :string, default: nil

  def collab_comment_actions(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn(["relative inline-flex", @class])}
      :if={@can_edit or @can_delete}
      data-comment-actions
    >
      <button
        type="button"
        class="inline-flex items-center justify-center size-7 rounded-md text-muted-foreground hover:bg-muted hover:text-foreground transition-colors"
        aria-label="Comment actions"
        aria-haspopup="true"
        phx-click={
          Phoenix.LiveView.JS.toggle(
            to: "##{@id}-dropdown",
            in: {"ease-out duration-100", "opacity-0 scale-95", "opacity-100 scale-100"},
            out: {"ease-in duration-75", "opacity-100 scale-100", "opacity-0 scale-95"}
          )
        }
      >
        <svg class="size-4" viewBox="0 0 24 24" fill="currentColor">
          <circle cx="12" cy="5" r="1.5" />
          <circle cx="12" cy="12" r="1.5" />
          <circle cx="12" cy="19" r="1.5" />
        </svg>
      </button>

      <div
        id={"#{@id}-dropdown"}
        class="hidden absolute right-0 top-full z-50 mt-1 w-36 rounded-md border border-border bg-popover shadow-md py-1"
        role="menu"
      >
        <button
          :if={@can_edit}
          type="button"
          role="menuitem"
          class="flex w-full items-center gap-2 px-3 py-1.5 text-sm text-popover-foreground hover:bg-accent hover:text-accent-foreground transition-colors"
          phx-click={@on_edit}
          phx-value-comment-id={@comment_id}
        >
          <svg class="size-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M17 3a2.85 2.85 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z" />
          </svg>
          Edit
        </button>

        <button
          :if={@can_delete}
          type="button"
          role="menuitem"
          class="flex w-full items-center gap-2 px-3 py-1.5 text-sm text-destructive hover:bg-destructive/10 transition-colors"
          phx-click={@on_delete}
          phx-value-comment-id={@comment_id}
        >
          <svg class="size-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M3 6h18M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2" />
          </svg>
          Delete
        </button>
      </div>
    </div>
    """
  end

  # ============================================================================
  # collab_comment_pin/1
  # ============================================================================

  @doc """
  Renders a small colored pin marker for document annotations.

  Displays as a colored circle with optional count badge. Used to mark
  specific locations in a document that have associated comments.
  """
  attr :id, :string, required: true
  attr :color, :string, default: "#6366F1"
  attr :count, :any, default: nil
  attr :active, :boolean, default: false
  attr :class, :string, default: nil

  def collab_comment_pin(assigns) do
    ~H"""
    <div
      id={@id}
      class={
        cn([
          "relative inline-flex items-center justify-center cursor-pointer",
          @class
        ])
      }
      data-comment-pin
    >
      <div
        class={
          cn([
            "size-4 rounded-full border-2 border-background shadow-sm transition-transform",
            if(@active, do: "scale-125 ring-2 ring-primary/30", else: "hover:scale-110")
          ])
        }
        style={"background-color: #{@color}"}
      />
      <span
        :if={@count && @count > 0}
        class="absolute -top-1.5 -right-1.5 flex items-center justify-center size-4 rounded-full bg-foreground text-background text-[10px] font-bold leading-none"
      >
        {@count}
      </span>
    </div>
    """
  end

  # ============================================================================
  # collab_comment_indicator/1
  # ============================================================================

  @doc """
  Renders a margin indicator showing comment count for a document line or block.

  Appears in the document margin/gutter to indicate that comments exist
  for the adjacent content.
  """
  attr :id, :string, required: true
  attr :count, :integer, default: 0
  attr :active, :boolean, default: false
  attr :on_click, :string, default: "collab:comment:show"
  attr :class, :string, default: nil

  def collab_comment_indicator(assigns) do
    ~H"""
    <button
      id={@id}
      type="button"
      phx-click={@on_click}
      class={
        cn([
          "inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-xs font-medium transition-colors cursor-pointer",
          if(@active,
            do: "bg-primary text-primary-foreground",
            else: "bg-muted text-muted-foreground hover:bg-primary/10 hover:text-primary"
          ),
          @class
        ])
      }
      aria-label={"#{@count} comments"}
      data-comment-indicator
    >
      <svg class="size-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
      </svg>
      <span :if={@count > 0}>{@count}</span>
    </button>
    """
  end
end
