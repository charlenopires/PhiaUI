defmodule PhiaUi.Components.MentionInput do
  @moduledoc """
  Mention input component for PhiaUI.

  A textarea with `@mention` autocomplete support. When the user types `@`,
  the `PhiaMentionInput` JS hook detects the trigger character and emits a
  `push_event("mention_search", %{query: query})` to the server. The LiveView
  filters the user list, reassigns suggestions, and re-renders the dropdown.
  When a suggestion is selected, the hook inserts a styled chip into the
  textarea and the mentioned user IDs are tracked in a hidden CSV input for
  form submission.

  ## When to use

  Use `MentionInput` anywhere users should be able to tag other users with
  `@username`:

  - Team collaboration comment threads (GitHub/Linear style)
  - Task assignment descriptions
  - Chat messages in a team messenger
  - Document editor annotations
  - Support ticket replies

  ## Anatomy

  | Component          | Element    | Purpose                                             |
  |--------------------|------------|-----------------------------------------------------|
  | `mention_input/1`  | `div`      | Root wrapper (textarea + hook + hidden input + dropdown) |
  | `mention_dropdown/1`| `ul`      | Suggestion listbox — hidden when `open: false`      |
  | `mention_chip/1`   | `span`     | Inline `@name` highlight for server-rendered previews |

  ## How it works

  1. User types `@` in the textarea
  2. `PhiaMentionInput` hook fires `push_event("mention_search", %{query: ""})`
  3. LiveView runs `handle_event("mention_search", ...)` → assigns suggestions
  4. User types more → hook fires `push_event("mention_search", %{query: "ali"})`
  5. LiveView filters and re-assigns suggestions; dropdown opens (`mention_open: true`)
  6. User clicks / arrows to a suggestion → `phx-click="mention_select"`
  7. LiveView appends the ID to `mentioned_ids`; hook inserts a chip into the textarea
  8. On form submit, the hidden input `name_ids` carries the CSV of mentioned IDs

  ## Complete example

      defmodule MyAppWeb.CommentLive do
        use Phoenix.LiveView

        def mount(_params, _session, socket) do
          {:ok, assign(socket,
            mention_suggestions: [],
            mention_open: false,
            mention_search: "",
            mentioned_ids: []
          )}
        end

        # Hook emits push_event; LiveView handles it as a regular event
        def handle_event("mention_search", %{"query" => q}, socket) do
          suggestions =
            Users.search(q, limit: 8)
            |> Enum.map(&%{id: &1.id, name: &1.name, avatar: &1.avatar_url})

          {:noreply, assign(socket,
            mention_suggestions: suggestions,
            mention_open: true,
            mention_search: q
          )}
        end

        def handle_event("mention_select", %{"id" => id, "name" => _name}, socket) do
          ids = [id | socket.assigns.mentioned_ids] |> Enum.uniq()
          {:noreply, assign(socket,
            mentioned_ids: ids,
            mention_open: false,
            mention_search: ""
          )}
        end
      end

      <%!-- Template --%>
      <.mention_input
        id="comment-body"
        name="comment[body]"
        suggestions={@mention_suggestions}
        open={@mention_open}
        search={@mention_search}
        mentioned_ids={@mentioned_ids}
        on_mention="mention_search"
        on_select="mention_select"
        placeholder="Leave a comment… type @ to mention someone"
      />

  ## Displaying resolved mentions in read-only content

  When rendering submitted comment content (e.g. in a feed), use `mention_chip/1`
  to highlight resolved user mentions with the same visual style:

      <p>
        Hey
        <.mention_chip name="Alice" user_id={alice.id} />
        the PR is ready for review.
      </p>

  ## Hook setup

      # app.js
      import PhiaMentionInput from "./hooks/mention_input"
      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaMentionInput }
      })

  ## ARIA

  The `<textarea>` carries `role="combobox"`, `aria-autocomplete="list"`,
  `aria-haspopup="listbox"`, and `aria-expanded` toggled by the `open` assign.
  The dropdown has `role="listbox"`. Each suggestion option has `role="option"`.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # mention_input/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    required: true,
    doc: """
    DOM id for the textarea element. The `PhiaMentionInput` hook is anchored
    to this element and uses it to identify the instance.
    """
  )

  attr(:name, :string,
    required: true,
    doc: """
    Form field name for the textarea content.
    The hidden input for mentioned IDs will be named `\#{name}_ids`.
    """
  )

  attr(:suggestions, :list,
    default: [],
    doc: """
    List of `%{id: string, name: string, avatar: string | nil}` suggestion maps.
    Updated by the LiveView in response to `on_mention` events.
    An empty list renders \"No results\" inside the open dropdown.
    """
  )

  attr(:open, :boolean,
    default: false,
    doc: """
    Whether the suggestion dropdown is currently visible.
    Set to `true` in `handle_event(\"mention_search\", ...)` and
    `false` in `handle_event(\"mention_select\", ...)`.
    """
  )

  attr(:search, :string,
    default: "",
    doc: "Current `@mention` search query typed by the user"
  )

  attr(:value, :string,
    default: "",
    doc: "Current textarea text value (for server-rendered initial content)"
  )

  attr(:mentioned_ids, :list,
    default: [],
    doc: """
    List of already-selected user ID strings.
    Serialised as a comma-separated value in the hidden `name_ids` input
    for form submission and changeset processing.
    """
  )

  attr(:on_mention, :string,
    default: nil,
    doc: """
    Event name that the hook emits via `push_event` when the user types after `@`.
    The LiveView receives `%{"query" => query}`.
    """
  )

  attr(:on_select, :string,
    default: "mention_select",
    doc: """
    `phx-click` event name fired when a suggestion is selected.
    The LiveView receives `%{"id" => user_id, "name" => user_name}`.
    """
  )

  attr(:placeholder, :string,
    default: "Type a message… use @ to mention",
    doc: "Textarea placeholder text"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root wrapper div")

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the root div"
  )

  @doc """
  Renders the mention input widget.

  The root div contains:
  1. A `<textarea>` wired to the `PhiaMentionInput` hook
  2. A hidden `<input>` that holds the CSV of mentioned user IDs
  3. A `mention_dropdown/1` suggestion panel controlled by the `open` assign

  The LiveView controls open/close state and the suggestion list. The hook
  handles `@` detection in the textarea and DOM insertion of `@name` chips.
  """
  def mention_input(assigns) do
    ~H"""
    <div class={cn(["relative", @class])} {@rest}>
      <%!-- Textarea with ARIA combobox role for correct screen reader behaviour --%>
      <textarea
        id={@id}
        name={@name}
        phx-hook="PhiaMentionInput"
        role="combobox"
        aria-autocomplete="list"
        aria-haspopup="listbox"
        aria-expanded={to_string(@open)}
        aria-controls={"#{@id}-listbox"}
        data-on-mention={@on_mention}
        data-on-select={@on_select}
        placeholder={@placeholder}
        class={cn([
          "w-full rounded-md border border-input bg-background px-3 py-2",
          "text-sm text-foreground placeholder:text-muted-foreground",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
          "resize-none"
        ])}
      >{@value}</textarea>

      <%!-- Hidden input: carries comma-separated mentioned IDs for changeset submission.
           The hook also writes to this input when chips are added/removed. --%>
      <input
        type="hidden"
        name={"#{@name}_ids"}
        value={Enum.join(@mentioned_ids, ",")}
      />

      <%!-- Suggestion dropdown — rendered via mention_dropdown/1 which has two function heads:
           open: false renders ~H"" (no DOM element), open: true renders the <ul> --%>
      <.mention_dropdown
        id={"#{@id}-listbox"}
        suggestions={@suggestions}
        open={@open}
        on_select={@on_select}
      />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # mention_dropdown/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    default: nil,
    doc: "DOM id for the listbox element — referenced by `aria-controls` on the textarea"
  )

  attr(:suggestions, :list,
    default: [],
    doc: "List of `%{id, name, avatar}` suggestion maps"
  )

  attr(:open, :boolean,
    default: false,
    doc: "Controls dropdown visibility. Uses two function heads: false → empty fragment."
  )

  attr(:on_select, :string,
    default: "mention_select",
    doc: "`phx-click` event name fired when a suggestion is chosen"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the listbox `<ul>`")

  @doc """
  Renders the `@mention` suggestion dropdown.

  Uses two function heads:
  - `open: false` → renders `~H""` (empty fragment — no DOM element at all)
  - `open: true` → renders the `<ul role="listbox">` with suggestion items

  This pattern is preferred over CSS visibility toggling because it keeps the
  DOM clean and prevents screen readers from announcing the hidden list.

  Each suggestion fires `on_select` with `phx-value-id` and `phx-value-name`.
  """
  # open: false — render nothing; no listbox in the DOM
  def mention_dropdown(%{open: false} = assigns) do
    ~H"""
    """
  end

  # open: true — render the suggestion listbox
  def mention_dropdown(assigns) do
    ~H"""
    <ul
      id={@id}
      role="listbox"
      aria-label="Mention suggestions"
      class={cn([
        "absolute z-50 mt-1 w-64 overflow-hidden rounded-md border border-border",
        "bg-background shadow-md",
        @class
      ])}
    >
      <%!-- Empty state when no suggestions match the current query --%>
      <%= if @suggestions == [] do %>
        <li class="px-3 py-2 text-sm text-muted-foreground">No results</li>
      <% else %>
        <li
          :for={suggestion <- @suggestions}
          role="option"
          aria-selected="false"
          class="flex items-center gap-2 px-3 py-2 hover:bg-muted cursor-pointer"
        >
          <button
            type="button"
            phx-click={@on_select}
            phx-value-id={suggestion.id}
            phx-value-name={suggestion.name}
            class="flex flex-1 items-center gap-2 text-left text-sm"
          >
            <%!-- Initials avatar placeholder — shown when no avatar URL is provided --%>
            <span class="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-muted text-xs font-medium text-muted-foreground">
              {mention_initials(suggestion.name)}
            </span>
            <span class="text-foreground">{suggestion.name}</span>
          </button>
        </li>
      <% end %>
    </ul>
    """
  end

  # ---------------------------------------------------------------------------
  # mention_chip/1
  # ---------------------------------------------------------------------------

  attr(:name, :string,
    required: true,
    doc: "Display name of the mentioned user (rendered as `@name`)"
  )

  attr(:user_id, :string,
    required: true,
    doc: "User ID stored in the `data-mention-id` attribute for client-side processing"
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes for the chip span"
  )

  @doc """
  Renders an inline `@mention` highlight chip for server-rendered content.

  Use this component when displaying already-saved content that contains
  resolved mentions — for example, rendering a comment body from the database
  where mentioned user IDs have been resolved to names.

  In client-side mode, the `PhiaMentionInput` hook inserts chips dynamically
  into the textarea. `mention_chip/1` is for the read-only rendering path.

  ## Example

      <p>
        <.mention_chip name="Sarah Lin" user_id={sarah.id} />
        can you review the attached document?
      </p>
  """
  def mention_chip(assigns) do
    ~H"""
    <span
      data-mention-id={@user_id}
      class={cn([
        "inline-flex items-center rounded-sm px-1 py-0.5",
        "bg-primary/10 text-primary font-medium text-sm",
        @class
      ])}
    >
      @{@name}
    </span>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Derive 1 or 2 initials from a full name for the avatar placeholder.
  # E.g. "Sarah Lin" → "SL", "Alice" → "A".
  # Using Enum.take/2 + Enum.map_join/2 instead of a regex keeps this pure Elixir.
  defp mention_initials(name) do
    name
    |> String.split()
    |> Enum.take(2)
    |> Enum.map_join(&String.first/1)
    |> String.upcase()
  end
end
