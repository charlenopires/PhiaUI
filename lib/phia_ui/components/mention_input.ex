defmodule PhiaUi.Components.MentionInput do
  @moduledoc """
  Mention input component for PhiaUI.

  A textarea with `@mention` autocomplete support. When the user types `@`,
  the `PhiaMentionInput` hook emits a `push_event("mention_search", %{query: q})`
  to the server. The LiveView filters suggestions and re-assigns them. When a
  suggestion is selected, a highlight chip is inserted and the mentioned IDs
  are tracked in a hidden CSV input for form submission.

  ## Sub-components

  - `mention_input/1` — root wrapper (textarea + hook + hidden input + dropdown)
  - `mention_dropdown/1` — suggestion list (role=listbox), visible only when `open=true`
  - `mention_chip/1` — inline `@name` highlight span for server-rendered previews

  ## Example

      <.mention_input
        id="comment-field"
        name="comment"
        suggestions={@mention_suggestions}
        open={@mention_open}
        search={@mention_search}
        mentioned_ids={@mentioned_ids}
        on_mention="mention_search"
        on_select="mention_select"
        placeholder="Leave a comment… type @ to mention someone"
      />

  ## LiveView handlers

      def handle_event("mention_search", %{"query" => q}, socket) do
        suggestions = filter_users(q)
        {:noreply, assign(socket, mention_suggestions: suggestions, mention_open: true, mention_search: q)}
      end

      def handle_event("mention_select", %{"id" => id, "name" => name}, socket) do
        ids = [id | socket.assigns.mentioned_ids]
        {:noreply, assign(socket, mentioned_ids: ids, mention_open: false, mention_search: "")}
      end

  ## Hook setup

      import PhiaMentionInput from "./hooks/mention_input"
      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaMentionInput }
      })

  ## ARIA

  The `<textarea>` carries `role="combobox"`, `aria-autocomplete="list"`,
  `aria-haspopup="listbox"`, and `aria-expanded` toggled by the `open` assign.
  The dropdown has `role="listbox"`. Each suggestion has `role="option"`.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # mention_input/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "DOM id — also used for the PhiaMentionInput hook")
  attr(:name, :string, required: true, doc: "Form field name (hidden input will use name_ids)")

  attr(:suggestions, :list,
    default: [],
    doc: "List of %{id: string, name: string, avatar: string | nil} suggestion maps"
  )

  attr(:open, :boolean, default: false, doc: "Whether the suggestion dropdown is visible")
  attr(:search, :string, default: "", doc: "Current @mention search term")
  attr(:value, :string, default: "", doc: "Current textarea text value")

  attr(:mentioned_ids, :list,
    default: [],
    doc: "List of already-selected user IDs, serialised as CSV in the hidden input"
  )

  attr(:on_mention, :string,
    default: nil,
    doc: "phx-change event fired by the hook when the user types after @"
  )

  attr(:on_select, :string,
    default: "mention_select",
    doc: "phx-click event fired when a suggestion is chosen"
  )

  attr(:placeholder, :string,
    default: "Type a message… use @ to mention",
    doc: "Textarea placeholder text"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root wrapper")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root div")

  @doc """
  Renders the mention input widget.

  Wraps a `<textarea>` with the `PhiaMentionInput` hook, a hidden input for
  tracked IDs, and the `mention_dropdown/1` panel. The LiveView controls open/close
  and suggestions; the hook handles `@` detection and DOM insertion of chips.
  """
  def mention_input(assigns) do
    ~H"""
    <div class={cn(["relative", @class])} {@rest}>
      <%!-- Textarea --%>
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

      <%!-- Hidden input — stores comma-separated mentioned IDs for form submission --%>
      <input
        type="hidden"
        name={"#{@name}_ids"}
        value={Enum.join(@mentioned_ids, ",")}
      />

      <%!-- Suggestion dropdown --%>
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

  attr(:id, :string, default: nil, doc: "DOM id for the listbox element (for aria-controls)")
  attr(:suggestions, :list, default: [], doc: "List of %{id, name, avatar} suggestion maps")
  attr(:open, :boolean, default: false, doc: "Controls visibility of the dropdown")
  attr(:on_select, :string, default: "mention_select", doc: "phx-click event for selection")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")

  @doc """
  Renders the `@mention` suggestion dropdown.

  Hidden when `open` is false. Each suggestion fires `on_select` with
  `phx-value-id` and `phx-value-name` for server-side processing.
  """
  def mention_dropdown(%{open: false} = assigns) do
    ~H"""
    """
  end

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
            <%!-- Avatar placeholder or initials --%>
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

  attr(:name, :string, required: true, doc: "Display name of the mentioned user")
  attr(:user_id, :string, required: true, doc: "User ID stored as data attribute")
  attr(:class, :string, default: nil, doc: "Additional CSS classes for the chip span")

  @doc """
  Renders an inline `@mention` highlight chip for server-rendered previews.

  In client-side mode, the `PhiaMentionInput` hook inserts chips into the
  contenteditable area. This component is for static server-rendered contexts
  where you want to display resolved mentions in read-only content.
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

  defp mention_initials(name) do
    name
    |> String.split()
    |> Enum.take(2)
    |> Enum.map_join(&String.first/1)
    |> String.upcase()
  end
end
