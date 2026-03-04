defmodule PhiaUi.Components.Combobox do
  @moduledoc """
  Combobox component with search/filter for PhiaUI.

  A searchable selection widget that renders as a trigger button + dropdown
  panel. Filtering is server-side: the parent LiveView handles the search event
  and passes back a filtered `options` list. No client-side JS hook is required
  for basic functionality.

  ## Sub-components

  - `combobox/1` — standalone combobox (trigger + dropdown panel)
  - `form_combobox/1` — `Phoenix.HTML.FormField`-integrated variant with hidden
    input and changeset error display

  ## When to use

  Use `combobox/1` when a `<select>` element would have too many options and
  users benefit from typing to filter — country pickers, user selectors,
  product/SKU selectors, time-zone pickers, etc.

  For simple short lists (< 10 items), use a native `filter_select/1` instead.

  ## Three-event model

  The parent LiveView must handle exactly three events:

  | Event            | When fired                       | Payload                   |
  |------------------|----------------------------------|---------------------------|
  | `on_toggle`      | Trigger button clicked           | none (params ignored)     |
  | `on_search`      | User types in the search input   | `%{"query" => string}`    |
  | `on_change`      | User selects an option           | `%{"value" => string}`    |

  ## Complete example — country selector

      defmodule MyAppWeb.ProfileLive do
        use Phoenix.LiveView

        @countries [
          %{value: "us", label: "United States"},
          %{value: "gb", label: "United Kingdom"},
          %{value: "de", label: "Germany"},
          %{value: "fr", label: "France"},
          # ... etc.
        ]

        def mount(_params, _session, socket) do
          {:ok, assign(socket,
            country: nil,
            country_open: false,
            country_search: ""
          )}
        end

        def handle_event("toggle-country", _params, socket) do
          {:noreply, update(socket, :country_open, &(!&1))}
        end

        def handle_event("search-country", %{"query" => q}, socket) do
          {:noreply, assign(socket, country_search: q)}
        end

        def handle_event("pick-country", %{"value" => v}, socket) do
          {:noreply, assign(socket,
            country: v,
            country_open: false,
            country_search: ""
          )}
        end

        # Filter the options server-side based on search query
        defp filtered_countries(search) do
          query = String.downcase(search)
          Enum.filter(@countries, &String.contains?(String.downcase(&1.label), query))
        end
      end

      <%!-- Template --%>
      <.combobox
        id="country-picker"
        options={filtered_countries(@country_search)}
        value={@country}
        open={@country_open}
        search={@country_search}
        placeholder="Select a country..."
        on_toggle="toggle-country"
        on_search="search-country"
        on_change="pick-country"
      />

  ## Form-integrated example

      <.form for={@form} phx-submit="save">
        <.form_combobox
          id="timezone-picker"
          field={@form[:timezone]}
          options={filtered_timezones(@timezone_search)}
          value={@selected_timezone}
          open={@timezone_open}
          search={@timezone_search}
          placeholder="Select timezone..."
          on_toggle="toggle-tz"
          on_search="search-tz"
          on_change="pick-tz"
        />
        <.button type="submit">Save</.button>
      </.form>

  ## Options format

  Options can be passed in two formats:

      # Map format (preferred)
      options={[%{value: "us", label: "United States"}, ...]}

      # Tuple format (compatible with Phoenix.HTML.Form select helpers)
      options={[{"United States", "us"}, {"Germany", "de"}, ...]}

  Both formats are normalised internally to `%{value: string, label: string}`.

  ## ARIA

  The trigger button has `aria-haspopup="listbox"` and `aria-expanded` toggled
  with the `open` assign. The dropdown has `role="listbox"` and each option has
  `role="option"` with `aria-selected`. Keyboard navigation (Escape / Enter /
  arrow keys) requires the optional `PhiaCombobox` JS hook.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:id, :string, required: true, doc: "Unique combobox DOM id")

  attr(:value, :string,
    default: nil,
    doc: "Currently selected value string, or `nil` when nothing is selected"
  )

  attr(:placeholder, :string,
    default: "Select an option...",
    doc: "Trigger button text shown when no value is selected"
  )

  attr(:search_placeholder, :string,
    default: "Search...",
    doc: "Placeholder text for the search input inside the dropdown"
  )

  attr(:options, :list,
    default: [],
    doc: """
    List of options in either format:
    - `%{value: string, label: string}` maps
    - `{label, value}` 2-tuples (compatible with Phoenix.HTML.Form)

    Pass a pre-filtered subset when the LiveView handles `on_search`.
    """
  )

  attr(:open, :boolean,
    default: false,
    doc: "Whether the dropdown panel is currently visible. Controlled by the LiveView."
  )

  attr(:search, :string,
    default: "",
    doc: "Current search query — used for client-side label filtering when `options` is static"
  )

  attr(:on_change, :string,
    default: "combobox-change",
    doc: """
    `phx-click` event name emitted when a user selects an option.
    The LiveView receives `%{"value" => value}`.
    """
  )

  attr(:on_search, :string,
    default: "combobox-search",
    doc: """
    `phx-change` event name emitted by the search input.
    The LiveView receives `%{"query" => query}`.
    Use this to filter `options` server-side and re-assign.
    """
  )

  attr(:on_toggle, :string,
    default: "combobox-toggle",
    doc: """
    `phx-click` event name emitted when the trigger button is clicked.
    The LiveView should toggle the `open` assign: `update(socket, :open, &(!&1))`.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via `cn/1`")

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the root div"
  )

  @doc """
  Renders a combobox with a trigger button and searchable dropdown.

  The component is fully server-driven: `open`, `search`, `value`, and
  `options` are all controlled by the LiveView. On each re-render, the
  `options` list is normalised and filtered by the current `search` query
  for cases where all options are passed statically (no server-side filtering).

  For large option lists (hundreds of items), handle `on_search` in the LiveView
  and pass a pre-filtered `options` list instead of relying on client-side filtering.
  """
  def combobox(assigns) do
    assigns =
      assigns
      # Filter options by search query (client-side path for small option lists).
      # For large lists, pass pre-filtered options from the LiveView instead.
      |> assign(:filtered_options, filter_options(assigns.options, assigns.search))
      # Resolve the display label for the currently selected value.
      |> assign(:selected_label, find_label(assigns.options, assigns.value))

    ~H"""
    <div
      id={@id}
      class={cn(["relative w-full", @class])}
      {@rest}
    >
      <%!-- Trigger button — shows selected label or placeholder --%>
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
        <%!-- Muted text when no value is selected --%>
        <span class={cn([is_nil(@value) && "text-muted-foreground"])}>
          {@selected_label || @placeholder}
        </span>
        <span class="ml-2 opacity-50">&#8595;</span>
      </button>

      <%!-- Dropdown panel — conditionally rendered (no hidden DOM element) --%>
      <div
        :if={@open}
        id={"#{@id}-listbox"}
        role="listbox"
        class={cn([
          "absolute z-50 mt-1 w-full rounded-md border bg-popover shadow-md",
          "text-popover-foreground overflow-hidden"
        ])}
      >
        <%!-- Search input — fires on_search on every keystroke --%>
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

        <%!-- Options list — scrollable, max 240px --%>
        <div class="max-h-60 overflow-y-auto p-1">
          <%!-- Empty state when no options match the search query --%>
          <div
            :if={@filtered_options == []}
            class="py-6 text-center text-sm text-muted-foreground"
          >
            No options found.
          </div>
          <%!-- Each option fires on_change with its value --%>
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
              # Highlight the currently selected option with a subtle background
              @value == option.value && "bg-accent/50"
            ])}
          >
            <%!-- Checkmark indicates the currently selected item --%>
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
    doc: """
    `Phoenix.HTML.FormField` struct from `@form[:field_name]`.
    Provides `id`, `name`, and `errors` for form integration.
    """
  )

  attr(:id, :string, required: true, doc: "Unique combobox DOM id")

  attr(:value, :any,
    default: nil,
    doc: "Currently selected value (string or nil)"
  )

  attr(:placeholder, :string,
    default: "Select an option...",
    doc: "Trigger button placeholder text"
  )

  attr(:search_placeholder, :string,
    default: "Search...",
    doc: "Placeholder text for the search input"
  )

  attr(:options, :list, default: [], doc: "Options list (same format as `combobox/1`)")
  attr(:open, :boolean, default: false, doc: "Whether the dropdown is visible")
  attr(:search, :string, default: "", doc: "Current search query")

  attr(:on_change, :string,
    default: "combobox-change",
    doc: "`phx-click` event for option selection"
  )

  attr(:on_search, :string,
    default: "combobox-search",
    doc: "`phx-change` event for search input"
  )

  attr(:on_toggle, :string,
    default: "combobox-toggle",
    doc: "`phx-click` event for the trigger button"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")

  @doc """
  Renders a combobox integrated with `Phoenix.HTML.FormField`.

  Injects a `<input type="hidden">` bound to `field.name` so the selected
  value is included in `phx-submit` form payloads. Changeset errors from
  `field.errors` are displayed as destructive text below the widget.

  ## Example

      <.form_combobox
        id="assignee-picker"
        field={@form[:assignee_id]}
        options={@team_members}
        value={@selected_assignee}
        open={@assignee_open}
        search={@assignee_search}
        placeholder="Assign to..."
        on_toggle="toggle-assignee"
        on_search="search-assignee"
        on_change="pick-assignee"
      />
  """
  def form_combobox(assigns) do
    ~H"""
    <div>
      <%!-- Hidden input carries the selected value string for changeset submission --%>
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
      <%!-- Changeset validation errors --%>
      <div :if={@field.errors != []}>
        <p :for={error <- @field.errors} class="mt-1 text-sm text-destructive">
          {elem(error, 0)}
        </p>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers — pure functions, no case/cond
  # ---------------------------------------------------------------------------

  # When search is empty, return all options without filtering.
  defp filter_options(options, ""), do: normalize_options(options)

  # When search has a value, case-insensitively filter by label substring.
  defp filter_options(options, search) do
    query = String.downcase(search)

    options
    |> normalize_options()
    |> Enum.filter(&String.contains?(String.downcase(&1.label), query))
  end

  # Normalise both supported formats to %{value: string, label: string}.
  defp normalize_options(options), do: Enum.map(options, &normalize_option/1)

  # Already in map format — pass through unchanged.
  defp normalize_option(%{value: _, label: _} = opt), do: opt

  # Tuple format {label, value} — convert to map.
  defp normalize_option({label, value}),
    do: %{value: to_string(value), label: to_string(label)}

  # Find the display label for the currently selected value.
  defp find_label(_options, nil), do: nil

  defp find_label(options, value) do
    options
    |> normalize_options()
    |> Enum.find(&(&1.value == value))
    |> extract_label()
  end

  # No matching option found — return nil so placeholder is shown.
  defp extract_label(nil), do: nil
  defp extract_label(%{label: label}), do: label
end
