defmodule PhiaUi.Components.Collab.Composer do
  @moduledoc """
  Composer Suite — 3 components for comment input with @mention support.

  ## Components

  - `collab_composer/1`          — Rich text comment input with @mention trigger (PhiaCollabComposer hook)
  - `collab_mention_suggest/1`   — Dropdown list of @mention suggestions
  - `collab_floating_composer/1` — Absolutely-positioned composer at document anchor point
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Collab.CollabHelpers

  # ============================================================================
  # collab_composer/1
  # ============================================================================

  @doc """
  Renders a comment composer with @mention support.

  Uses the `PhiaCollabComposer` JS hook for real-time @mention detection,
  Enter-to-submit (Shift+Enter for newline), and basic Markdown shortcuts
  (Ctrl+B for bold, Ctrl+I for italic).

  ## Attributes

  - `:id` — unique identifier (required)
  - `:thread_id` — associated thread ID (nil for new threads)
  - `:placeholder` — input placeholder text
  - `:on_submit` — event name when submitting a comment
  - `:mention_suggestions` — list of user maps for the mention dropdown
  - `:show_mention_dropdown` — whether the mention dropdown is visible

  The mention dropdown is positioned below the textarea and shows matching
  users as the user types after "@".
  """
  attr :id, :string, required: true
  attr :thread_id, :string, default: nil
  attr :placeholder, :string, default: "Write a comment..."
  attr :on_submit, :string, default: "collab:comment:create"
  attr :mention_suggestions, :list, default: []
  attr :show_mention_dropdown, :boolean, default: false
  attr :class, :string, default: nil

  def collab_composer(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn(["relative", @class])}
      phx-hook="PhiaCollabComposer"
      data-on-submit={@on_submit}
      data-thread-id={@thread_id}
    >
      <div class="flex items-end gap-2 p-3">
        <div class="flex-1 relative">
          <textarea
            data-composer-input
            rows="1"
            placeholder={@placeholder}
            class={
              cn([
                "w-full resize-none rounded-lg border border-input bg-background px-3 py-2 text-sm",
                "placeholder:text-muted-foreground",
                "focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-1",
                "min-h-[38px] max-h-32"
              ])
            }
            aria-label="Comment input"
          />

          <%!-- Mention dropdown --%>
          <.collab_mention_suggest
            id={"#{@id}-mentions"}
            suggestions={@mention_suggestions}
            visible={@show_mention_dropdown}
          />
        </div>

        <%!-- Send button --%>
        <button
          type="button"
          class={
            cn([
              "inline-flex items-center justify-center size-9 rounded-lg shrink-0",
              "bg-primary text-primary-foreground",
              "hover:bg-primary/90 transition-colors",
              "disabled:opacity-50 disabled:pointer-events-none"
            ])
          }
          aria-label="Send comment"
          data-composer-submit
        >
          <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="m22 2-7 20-4-9-9-4z" />
            <path d="M22 2 11 13" />
          </svg>
        </button>
      </div>

      <%!-- Formatting hint --%>
      <div class="flex items-center gap-3 px-3 pb-2 text-[10px] text-muted-foreground">
        <span>Enter to send</span>
        <span>Shift+Enter for new line</span>
        <span>@ to mention</span>
      </div>
    </div>
    """
  end

  # ============================================================================
  # collab_mention_suggest/1
  # ============================================================================

  @doc """
  Renders a dropdown of @mention suggestions.

  Each suggestion shows a small avatar (or initials circle) and the user name.
  Clicking a suggestion inserts the mention into the composer.
  """
  attr :id, :string, required: true
  attr :suggestions, :list, default: []
  attr :visible, :boolean, default: false
  attr :on_select, :string, default: "collab:mention:select"
  attr :class, :string, default: nil

  def collab_mention_suggest(assigns) do
    ~H"""
    <div
      id={@id}
      class={
        cn([
          "absolute left-0 bottom-full z-50 mb-1 w-full max-h-48 overflow-y-auto",
          "rounded-lg border border-border bg-popover shadow-lg",
          if(@visible and @suggestions != [], do: "block", else: "hidden"),
          @class
        ])
      }
      role="listbox"
      aria-label="Mention suggestions"
    >
      <div
        :for={user <- @suggestions}
        class="flex items-center gap-2 px-3 py-2 cursor-pointer hover:bg-accent hover:text-accent-foreground transition-colors"
        role="option"
        phx-click={@on_select}
        phx-value-user-id={user.id}
        phx-value-name={user.name}
        data-mention-option
      >
        <%= if user[:avatar_url] do %>
          <img
            src={user.avatar_url}
            alt={user.name}
            class="size-6 rounded-full object-cover"
          />
        <% else %>
          <div
            class="size-6 rounded-full flex items-center justify-center text-[10px] font-semibold text-white"
            style={"background-color: #{CollabHelpers.collab_color(user.id)}"}
          >
            {CollabHelpers.user_initials(user.name)}
          </div>
        <% end %>

        <span class="text-sm font-medium truncate">{user.name}</span>
      </div>

      <div
        :if={@visible and @suggestions == []}
        class="px-3 py-2 text-sm text-muted-foreground"
      >
        No users found
      </div>
    </div>
    """
  end

  # ============================================================================
  # collab_floating_composer/1
  # ============================================================================

  @doc """
  Renders a composer positioned at a specific document anchor point.

  Used to create new threads at a specific location in the document.
  The composer is absolutely positioned at `(x, y)` coordinates.
  """
  attr :id, :string, required: true
  attr :x, :any, default: 0
  attr :y, :any, default: 0
  attr :thread_id, :string, default: nil
  attr :on_submit, :string, default: "collab:comment:create"
  attr :mention_suggestions, :list, default: []
  attr :show_mention_dropdown, :boolean, default: false
  attr :class, :string, default: nil

  def collab_floating_composer(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn(["absolute z-50 w-80 rounded-lg border border-border bg-card shadow-lg overflow-hidden", @class])}
      style={"left: #{@x}px; top: #{@y}px;"}
    >
      <div class="flex items-center gap-2 px-3 py-2 bg-muted/50 border-b border-border text-sm font-medium text-foreground">
        <svg class="size-4 text-muted-foreground" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
        </svg>
        New comment
      </div>

      <.collab_composer
        id={"#{@id}-composer"}
        thread_id={@thread_id}
        on_submit={@on_submit}
        mention_suggestions={@mention_suggestions}
        show_mention_dropdown={@show_mention_dropdown}
      />
    </div>
    """
  end
end
