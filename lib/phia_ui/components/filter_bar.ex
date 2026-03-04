defmodule PhiaUi.Components.FilterBar do
  @moduledoc """
  FilterBar component for PhiaUI.

  A horizontal toolbar for composing table and list filters. Combines a
  full-text search input, labelled select dropdowns, checkbox toggles, and a
  reset button into a cohesive, accessible filter UI.

  Each sub-component is independently usable — you can mix and match them in
  any combination above a `data_grid/1` or `table/1`.

  ## When to use

  Use `FilterBar` for "simple" filter scenarios where users can select from
  predefined options or type a search query. For power users who need to build
  complex multi-condition queries (AND/OR, operators), use `FilterBuilder`
  instead.

  ## Anatomy

  | Component        | Element  | Purpose                                      |
  |------------------|----------|----------------------------------------------|
  | `filter_bar/1`   | `div`    | Flex row wrapper for all filter sub-components |
  | `filter_search/1`| `input`  | Full-text search with magnifier icon         |
  | `filter_select/1`| `select` | Labelled native dropdown for enum filters    |
  | `filter_toggle/1`| `input`  | Checkbox toggle for boolean filters          |
  | `filter_reset/1` | `button` | Clear all active filters                     |

  ## Complete example — user management table

      <.filter_bar>
        <.filter_search
          placeholder="Search by name or email…"
          on_search="search_users"
          value={@search_query}
        />
        <.filter_select
          label="Role"
          name="role"
          options={[
            {"All roles", ""},
            {"Admin", "admin"},
            {"Editor", "editor"},
            {"Viewer", "viewer"}
          ]}
          value={@filter_role}
          on_change="filter_role"
        />
        <.filter_select
          label="Status"
          name="status"
          options={[{"All", ""}, {"Active", "active"}, {"Suspended", "suspended"}]}
          value={@filter_status}
          on_change="filter_status"
        />
        <.filter_toggle
          label="Show archived"
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

      def handle_event("filter_role", %{"role" => role}, socket) do
        {:noreply, assign(socket, filter_role: role)}
      end

      def handle_event("filter_status", %{"status" => status}, socket) do
        {:noreply, assign(socket, filter_status: status)}
      end

      def handle_event("toggle_archived", %{"archived" => checked}, socket) do
        {:noreply, assign(socket, show_archived: checked == "true")}
      end

      def handle_event("reset_filters", _params, socket) do
        {:noreply, assign(socket,
          search_query: "",
          filter_role: "",
          filter_status: "",
          show_archived: false
        )}
      end

  ## Debouncing search

  Pair `filter_search/1` with `phx-debounce` on the input to avoid a server
  round-trip on every keystroke:

      <.filter_search
        on_search="search_users"
        value={@query}
        rest={%{"phx-debounce" => "300"}}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # filter_bar/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root wrapper")

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the root div"
  )

  slot(:inner_block,
    required: true,
    doc: "`filter_search/1`, `filter_select/1`, `filter_toggle/1`, and/or `filter_reset/1` children"
  )

  @doc """
  Renders the filter bar container.

  A flex-wrap row that holds all filter sub-components. The `flex-wrap` means
  filters gracefully reflow to a second line on smaller screens.

  Typically placed directly above a `data_grid/1` or `table/1`:

      <.filter_bar class="mb-4">
        <.filter_search ... />
        <.filter_select ... />
      </.filter_bar>
      <.data_grid rows={@filtered_rows} columns={@columns} />
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

  attr(:placeholder, :string,
    default: "Search…",
    doc: "Input placeholder text shown when the field is empty"
  )

  attr(:on_search, :string,
    required: true,
    doc: """
    `phx-change` event name fired on every keystroke.
    The LiveView receives `%{"search" => query}` (or whatever `:name` is set to).
    Add `phx-debounce="300"` via `:rest` to reduce server round-trips.
    """
  )

  attr(:value, :string,
    default: "",
    doc: "Controlled value — pass the current search query assign from the LiveView"
  )

  attr(:name, :string,
    default: "search",
    doc: "Input `name` attribute — the param key the LiveView receives on `phx-change`"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the input wrapper")

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the input wrapper div (e.g. `phx-debounce=\"300\"`)"
  )

  @doc """
  Renders a full-text search input with a magnifier icon.

  Fires `on_search` via `phx-change` on every keystroke. Add `phx-debounce`
  to your LiveView form or via `:rest` to debounce.

  ## Example

      <.filter_search
        placeholder="Search invoices…"
        on_search="search_invoices"
        value={@search_query}
      />
  """
  def filter_search(assigns) do
    ~H"""
    <div class={cn(["relative flex items-center", @class])} {@rest}>
      <%!-- Magnifier icon — pointer-events-none so it doesn't capture clicks --%>
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

  attr(:label, :string,
    required: true,
    doc: "Visible label rendered to the left of the dropdown (e.g. \"Status\", \"Role\")"
  )

  attr(:name, :string,
    required: true,
    doc: "Select `name` attribute — the param key the LiveView receives on `phx-change`"
  )

  attr(:options, :list,
    required: true,
    doc: """
    List of `{label, value}` tuples rendered as `<option>` elements.
    Convention: `{"All", ""}` as the first option clears the filter.

        options={[{"All", ""}, {"Active", "active"}, {"Inactive", "inactive"}]}
    """
  )

  attr(:value, :string,
    default: "",
    doc: "Currently selected value — used to set the `selected` attribute on the matching option"
  )

  attr(:on_change, :string,
    required: true,
    doc: """
    `phx-change` event name fired when the user changes the selection.
    The LiveView receives `%{name => value}` where name is `:name`.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the wrapper div")

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the wrapper div"
  )

  @doc """
  Renders a labelled native select dropdown.

  The label is rendered as muted text to the left of the `<select>`. Native
  `<select>` elements are used (not custom dropdowns) to preserve browser
  accessibility, mobile behaviour, and keyboard navigation for free.

  ## Example

      <.filter_select
        label="Priority"
        name="priority"
        options={[{"All", ""}, {"Critical", "critical"}, {"High", "high"}, {"Low", "low"}]}
        value={@filter_priority}
        on_change="filter_priority"
      />
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
        <%!-- `selected={opt_value == @value}` sets the correct initial option
             after LiveView re-renders (the browser does not reset <select> state) --%>
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

  attr(:label, :string,
    required: true,
    doc: "Label text displayed beside the checkbox (e.g. \"Show archived\", \"Mine only\")"
  )

  attr(:name, :string,
    required: true,
    doc: "Checkbox `name` attribute — the param key the LiveView receives"
  )

  attr(:checked, :boolean,
    default: false,
    doc: "Whether the checkbox is currently checked — bind to a LiveView boolean assign"
  )

  attr(:on_change, :string,
    required: true,
    doc: """
    `phx-change` event name. The LiveView receives `%{name => "true" | "false"}`.
    Note: HTML checkbox values are strings, so compare with `== \"true\"`.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the label element")

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the `<label>` wrapper element"
  )

  @doc """
  Renders a checkbox toggle with a visible inline label.

  Fires `on_change` via `phx-change` when the checkbox state changes.
  The entire label text is clickable (clicking the text toggles the checkbox).

  ## Example

      <.filter_toggle
        label="My tasks only"
        name="mine_only"
        checked={@mine_only}
        on_change="toggle_mine_only"
      />

      # LiveView handler
      def handle_event("toggle_mine_only", %{"mine_only" => v}, socket) do
        {:noreply, assign(socket, mine_only: v == "true")}
      end
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

  attr(:on_click, :string,
    required: true,
    doc: """
    `phx-click` event name fired when the reset button is pressed.
    The LiveView handler should reset all filter assigns to their default values.
    """
  )

  attr(:label, :string,
    default: nil,
    doc: "Button label text. Defaults to \"Reset\" when nil."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the button")

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the `<button>` element"
  )

  @doc """
  Renders a reset / clear-all button for the filter bar.

  Fires `on_click` via `phx-click`. The handler should reset all filter assigns
  to their defaults (empty string, false, nil) and re-apply the query.

  ## Example

      <.filter_reset on_click="reset_filters" />

      # Or with a custom label
      <.filter_reset on_click="clear_all" label="Clear all filters" />

      # LiveView handler
      def handle_event("reset_filters", _params, socket) do
        {:noreply, assign(socket, query: "", status: "", archived: false)}
      end
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
