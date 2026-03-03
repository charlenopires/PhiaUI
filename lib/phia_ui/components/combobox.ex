defmodule PhiaUi.Components.Combobox do
  @moduledoc """
  Combobox component with search/filter, built on top of Popover + Command patterns.

  Server-rendered selection widget with real-time filtering. The parent LiveView
  manages open/search state and handles three events:

  - `combobox-toggle` — toggle open/closed
  - `combobox-search` — update the search query (receives `%{"query" => query}`)
  - `combobox-change` — item selected (receives `%{"value" => value}`)

  ## Sub-components

  - `combobox/1` — root widget (trigger + dropdown panel)
  - `form_combobox/1` — `Phoenix.HTML.FormField`-integrated variant

  ## Example

      <.combobox
        id="fruit-picker"
        options={[%{value: "apple", label: "Apple"}, %{value: "banana", label: "Banana"}]}
        value={@selected_fruit}
        open={@combobox_open}
        search={@combobox_search}
        on_change="pick-fruit"
        on_search="search-fruit"
        on_toggle="toggle-fruit"
      />

  ## LiveView handler example

      def handle_event("toggle-fruit", _params, socket) do
        {:noreply, update(socket, :combobox_open, &(!&1))}
      end

      def handle_event("search-fruit", %{"query" => q}, socket) do
        {:noreply, assign(socket, combobox_search: q)}
      end

      def handle_event("pick-fruit", %{"value" => v}, socket) do
        {:noreply, assign(socket, selected_fruit: v, combobox_open: false)}
      end

  ## ARIA

  The trigger button has `aria-haspopup="listbox"` and `aria-expanded` toggled
  with the `open` assign. The dropdown has `role="listbox"` and each option has
  `role="option"` with `aria-selected`.

  ## Keyboard navigation

  Full keyboard support (Escape / Enter / arrow keys) requires the optional
  `PhiaCombobox` JS hook. Without it the component is still fully usable via
  mouse / touch in LiveView.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:id, :string, required: true, doc: "Unique combobox ID")
  attr(:value, :string, default: nil, doc: "Currently selected value")

  attr(:placeholder, :string,
    default: "Select an option...",
    doc: "Placeholder shown when no value is selected"
  )

  attr(:search_placeholder, :string,
    default: "Search...",
    doc: "Placeholder text for the search input"
  )

  attr(:options, :list,
    default: [],
    doc: "List of `%{value: string, label: string}` maps or `{label, value}` keyword tuples"
  )

  attr(:open, :boolean, default: false, doc: "Whether the dropdown panel is visible")
  attr(:search, :string, default: "", doc: "Current search query used for client-side filtering")

  attr(:on_change, :string,
    default: "combobox-change",
    doc: "phx-click event emitted when an option is selected (sends `%{value: value}`)"
  )

  attr(:on_search, :string,
    default: "combobox-search",
    doc: "phx-change event emitted by the search input (sends `%{query: query}`)"
  )

  attr(:on_toggle, :string,
    default: "combobox-toggle",
    doc: "phx-click event emitted when the trigger button is clicked"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root div")

  @doc """
  Renders a combobox with search filtering and server-driven state.

  The parent LiveView handles the three events (`on_toggle`, `on_search`,
  `on_change`) and passes updated `open`, `search`, and `value` assigns back
  on each re-render.

  Accepts both `%{value: v, label: l}` maps and `{label, value}` keyword tuples
  as `:options`.
  """
  def combobox(assigns) do
    assigns =
      assigns
      |> assign(:filtered_options, filter_options(assigns.options, assigns.search))
      |> assign(:selected_label, find_label(assigns.options, assigns.value))

    ~H"""
    <div
      id={@id}
      class={cn(["relative w-full", @class])}
      {@rest}
    >
      <%!-- Trigger button --%>
      <button
        type="button"
        aria-haspopup="listbox"
        aria-expanded={to_string(@open)}
        aria-controls={"#{@id}-listbox"}
        phx-click={@on_toggle}
        class={cn([
          "flex w-full items-center justify-between rounded-md border border-input",
          "bg-background px-3 py-2 text-sm shadow-sm",
          "focus:outline-none focus:ring-2 focus:ring-ring",
          "disabled:cursor-not-allowed disabled:opacity-50"
        ])}
      >
        <span class={cn([is_nil(@value) && "text-muted-foreground"])}>
          {@selected_label || @placeholder}
        </span>
        <span class="ml-2 opacity-50">&#8595;</span>
      </button>

      <%!-- Dropdown panel (conditionally rendered) --%>
      <div
        :if={@open}
        id={"#{@id}-listbox"}
        role="listbox"
        class={cn([
          "absolute z-50 mt-1 w-full rounded-md border bg-popover shadow-md",
          "text-popover-foreground overflow-hidden"
        ])}
      >
        <%!-- Search input --%>
        <div class="flex items-center border-b px-3">
          <input
            type="text"
            value={@search}
            placeholder={@search_placeholder}
            phx-change={@on_search}
            name="query"
            class={cn([
              "flex h-10 w-full bg-transparent py-3 text-sm outline-none",
              "placeholder:text-muted-foreground"
            ])}
          />
        </div>

        <%!-- Options list --%>
        <div class="max-h-60 overflow-y-auto p-1">
          <div
            :if={@filtered_options == []}
            class="py-6 text-center text-sm text-muted-foreground"
          >
            No options found.
          </div>
          <div
            :for={option <- @filtered_options}
            role="option"
            aria-selected={to_string(@value == option.value)}
            phx-click={@on_change}
            phx-value-value={option.value}
            class={cn([
              "relative flex cursor-pointer select-none items-center rounded-sm px-2 py-1.5",
              "text-sm outline-none transition-colors",
              "hover:bg-accent hover:text-accent-foreground",
              @value == option.value && "bg-accent/50"
            ])}
          >
            <span class="mr-2 flex h-4 w-4 items-center justify-center">
              <span :if={@value == option.value}>&#10003;</span>
            </span>
            {option.label}
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr(:field, Phoenix.HTML.FormField,
    required: true,
    doc: "Phoenix.HTML.FormField struct for form integration"
  )

  attr(:id, :string, required: true, doc: "Unique combobox ID")
  attr(:value, :any, default: nil, doc: "Currently selected value (string or nil)")

  attr(:placeholder, :string,
    default: "Select an option...",
    doc: "Placeholder shown when no value is selected"
  )

  attr(:search_placeholder, :string,
    default: "Search...",
    doc: "Placeholder text for the search input"
  )

  attr(:options, :list, default: [], doc: "Options list")
  attr(:open, :boolean, default: false, doc: "Whether the dropdown panel is visible")
  attr(:search, :string, default: "", doc: "Current search query")

  attr(:on_change, :string,
    default: "combobox-change",
    doc: "phx-click event emitted when an option is selected"
  )

  attr(:on_search, :string,
    default: "combobox-search",
    doc: "phx-change event emitted by the search input"
  )

  attr(:on_toggle, :string,
    default: "combobox-toggle",
    doc: "phx-click event emitted when the trigger button is clicked"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1")

  @doc """
  Renders a combobox integrated with `Phoenix.HTML.FormField`.

  Injects a `<input type="hidden">` bound to the field's `name` so the selected
  value is included in `phx-submit` form payloads. Errors from the FormField are
  displayed as destructive text below the widget.
  """
  def form_combobox(assigns) do
    ~H"""
    <div>
      <input type="hidden" id={@field.id} name={@field.name} value={@value || ""} />
      <.combobox
        id={@id}
        value={@value}
        placeholder={@placeholder}
        search_placeholder={@search_placeholder}
        options={@options}
        open={@open}
        search={@search}
        on_change={@on_change}
        on_search={@on_search}
        on_toggle={@on_toggle}
        class={@class}
      />
      <div :if={@field.errors != []}>
        <p :for={error <- @field.errors} class="mt-1 text-sm text-destructive">
          {elem(error, 0)}
        </p>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers — pattern matching only, no case/cond
  # ---------------------------------------------------------------------------

  defp filter_options(options, ""), do: normalize_options(options)

  defp filter_options(options, search) do
    query = String.downcase(search)

    options
    |> normalize_options()
    |> Enum.filter(&String.contains?(String.downcase(&1.label), query))
  end

  defp normalize_options(options), do: Enum.map(options, &normalize_option/1)

  defp normalize_option(%{value: _, label: _} = opt), do: opt

  defp normalize_option({label, value}),
    do: %{value: to_string(value), label: to_string(label)}

  defp find_label(_options, nil), do: nil

  defp find_label(options, value) do
    options
    |> normalize_options()
    |> Enum.find(&(&1.value == value))
    |> extract_label()
  end

  defp extract_label(nil), do: nil
  defp extract_label(%{label: label}), do: label
end
