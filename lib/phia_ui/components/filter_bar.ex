defmodule PhiaUi.Components.FilterBar do
  @moduledoc """
  FilterBar component for PhiaUI.

  A horizontal toolbar for composing table/list filters. Combines search input,
  select dropdowns, boolean toggles, and a reset button into a cohesive filter
  UI. Each sub-component is independently usable and composable.

  ## Sub-components

  - `filter_bar/1` — root flex wrapper
  - `filter_search/1` — text/search input with search icon
  - `filter_select/1` — labelled native select dropdown
  - `filter_toggle/1` — checkbox toggle with label
  - `filter_reset/1` — reset/clear button

  ## Example

      <.filter_bar>
        <.filter_search placeholder="Search users…" on_search="search_users" />
        <.filter_select
          label="Status"
          name="status"
          options={[{"All", ""}, {"Active", "active"}, {"Inactive", "inactive"}]}
          value={@filter_status}
          on_change="filter_status"
        />
        <.filter_toggle
          label="Archived"
          name="archived"
          checked={@show_archived}
          on_change="toggle_archived"
        />
        <.filter_reset on_click="reset_filters" />
      </.filter_bar>

  ## LiveView handlers

      def handle_event("search_users", %{"value" => q}, socket) do
        {:noreply, assign(socket, search_query: q)}
      end

      def handle_event("filter_status", %{"status" => status}, socket) do
        {:noreply, assign(socket, filter_status: status)}
      end

      def handle_event("toggle_archived", %{"archived" => checked}, socket) do
        {:noreply, assign(socket, show_archived: checked == "true")}
      end

      def handle_event("reset_filters", _params, socket) do
        {:noreply, assign(socket, search_query: "", filter_status: "", show_archived: false)}
      end
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # filter_bar/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root wrapper")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root div")

  slot(:inner_block,
    required: true,
    doc: "filter_search/filter_select/filter_toggle/filter_reset children"
  )

  @doc """
  Renders the filter bar container.

  A flex row that wraps all filter sub-components. Typically placed above a
  `data_grid/1` or `table/1`.
  """
  def filter_bar(assigns) do
    ~H"""
    <div
      class={cn(["flex flex-wrap items-center gap-2", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # filter_search/1
  # ---------------------------------------------------------------------------

  attr(:placeholder, :string, default: "Search…", doc: "Input placeholder text")
  attr(:on_search, :string, required: true, doc: "phx-change event fired on input change")
  attr(:value, :string, default: "", doc: "Current search value")
  attr(:name, :string, default: "search", doc: "Input name attribute")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the input wrapper")

  @doc """
  Renders a search input with a magnifier icon.

  Fires `on_search` via `phx-change` on every keystroke (debounce recommended).
  """
  def filter_search(assigns) do
    ~H"""
    <div class={cn(["relative flex items-center", @class])} {@rest}>
      <span class="pointer-events-none absolute left-2.5 text-muted-foreground">
        <.icon name="search" size={:xs} />
      </span>
      <input
        type="search"
        name={@name}
        value={@value}
        placeholder={@placeholder}
        phx-change={@on_search}
        class={cn([
          "h-9 w-full min-w-[180px] rounded-md border border-input bg-background",
          "pl-8 pr-3 text-sm text-foreground placeholder:text-muted-foreground",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
        ])}
      />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # filter_select/1
  # ---------------------------------------------------------------------------

  attr(:label, :string, required: true, doc: "Visible label for the select")
  attr(:name, :string, required: true, doc: "Select name attribute")

  attr(:options, :list,
    required: true,
    doc: "List of {label, value} tuples rendered as <option> elements"
  )

  attr(:value, :string, default: "", doc: "Currently selected value")
  attr(:on_change, :string, required: true, doc: "phx-change event fired on selection change")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the wrapper div")

  @doc """
  Renders a labelled native select dropdown.

  Fires `on_change` via `phx-change`. Options are `{label, value}` tuples.
  """
  def filter_select(assigns) do
    ~H"""
    <div class={cn(["flex items-center gap-1.5", @class])} {@rest}>
      <span class="text-sm text-muted-foreground">{@label}</span>
      <select
        name={@name}
        phx-change={@on_change}
        class={cn([
          "h-9 rounded-md border border-input bg-background px-3 pr-8 text-sm",
          "text-foreground focus-visible:outline-none focus-visible:ring-2",
          "focus-visible:ring-ring"
        ])}
      >
        <option :for={{opt_label, opt_value} <- @options} value={opt_value} selected={opt_value == @value}>
          {opt_label}
        </option>
      </select>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # filter_toggle/1
  # ---------------------------------------------------------------------------

  attr(:label, :string, required: true, doc: "Label text displayed beside the checkbox")
  attr(:name, :string, required: true, doc: "Checkbox name attribute")
  attr(:checked, :boolean, default: false, doc: "Whether the toggle is checked")
  attr(:on_change, :string, required: true, doc: "phx-change event fired on toggle change")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the label element")

  @doc """
  Renders a checkbox toggle with a visible label.

  Fires `on_change` via `phx-change` when the checkbox state changes.
  """
  def filter_toggle(assigns) do
    ~H"""
    <label class={cn(["flex cursor-pointer items-center gap-1.5 text-sm text-foreground", @class])} {@rest}>
      <input
        type="checkbox"
        name={@name}
        checked={@checked}
        phx-change={@on_change}
        class="h-4 w-4 rounded border-border accent-primary"
      />
      {@label}
    </label>
    """
  end

  # ---------------------------------------------------------------------------
  # filter_reset/1
  # ---------------------------------------------------------------------------

  attr(:on_click, :string, required: true, doc: "phx-click event fired on button press")
  attr(:label, :string, default: nil, doc: "Button label (defaults to 'Reset')")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the button")

  @doc """
  Renders a reset/clear button.

  Fires `on_click` via `phx-click` to reset all active filters.
  """
  def filter_reset(assigns) do
    assigns = assign_new(assigns, :label, fn -> nil end)

    ~H"""
    <button
      type="button"
      phx-click={@on_click}
      class={cn([
        "inline-flex h-9 items-center gap-1.5 rounded-md px-3 text-sm",
        "text-muted-foreground hover:bg-muted hover:text-foreground transition-colors",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
        @class
      ])}
      {@rest}
    >
      <.icon name="x" size={:xs} />
      {@label || "Reset"}
    </button>
    """
  end
end
