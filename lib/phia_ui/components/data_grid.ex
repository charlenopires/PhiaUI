defmodule PhiaUi.Components.DataGrid do
  @moduledoc """
  Feature-rich data table with server-side sorting, pagination, toolbar,
  column visibility toggling, and row selection — all stateless.

  Every sub-component is a pure render function. All state (sort direction,
  current page, selected row IDs, visible columns) lives in your LiveView
  assigns. Events are sent via `phx-click` / `phx-change` and handled with
  standard `handle_event/3` callbacks.

  The `data_grid_body/1` element is **LiveView Streams compatible**: add
  `phx-update="stream"` to enable incremental DOM patching for large datasets.

  ## Sub-components

  | Component                  | HTML element | Purpose                                        |
  |----------------------------|--------------|------------------------------------------------|
  | `data_grid/1`              | `div > table`| Scrollable outer container                     |
  | `data_grid_head/1`         | `th`         | Column header; optional sort button            |
  | `data_grid_body/1`         | `tbody`      | Data rows; accepts `phx-update="stream"`       |
  | `data_grid_row/1`          | `tr`         | Row with hover state and optional styling      |
  | `data_grid_cell/1`         | `td`         | Data cell with consistent `px-4 py-3` padding  |
  | `data_grid_toolbar/1`      | `div`        | Flex toolbar for search, filters, actions      |
  | `data_grid_pagination/1`   | `nav`        | First/prev/next/last + rows-per-page selector  |
  | `data_grid_column_toggle/1`| `div`        | Dropdown checklist to show/hide columns        |
  | `data_grid_row_checkbox/1` | `td`         | Row selection checkbox cell                    |
  | `data_grid_select_all/1`   | `th`         | Select-all checkbox header cell                |

  ## Sort direction lifecycle

  Sort directions are represented as atoms in Elixir (`:none`, `:asc`, `:desc`)
  but arrive as **strings** from `phx-value` (`"asc"`, `"desc"`, `"none"`).
  The `next_dir/1` helper cycles the direction on each click:

      :none → :asc → :desc → :none

  In your `handle_event` always convert with `String.to_existing_atom/1`:

      def handle_event("sort", %{"key" => key, "dir" => dir}, socket) do
        {:noreply, assign(socket, sort_key: key, sort_dir: String.to_existing_atom(dir))}
      end

  The use of `String.to_existing_atom/1` (not `String.to_atom/1`) is safe
  because the only possible values are `:asc`, `:desc`, and `:none`, which
  are already atoms defined in this module.

  ## Complete example with streams and sorting

      defmodule MyAppWeb.UsersLive do
        use MyAppWeb, :live_view

        def mount(_params, _session, socket) do
          socket =
            socket
            |> assign(sort_key: "name", sort_dir: :asc)
            |> assign(page: 1, total_pages: 10, page_size: 20)
            |> assign(selected_ids: MapSet.new())
            |> assign(columns: [
                 %{key: "name",  label: "Name",  visible: true},
                 %{key: "email", label: "Email", visible: true},
                 %{key: "role",  label: "Role",  visible: true},
                 %{key: "plan",  label: "Plan",  visible: false}
               ])
            |> stream(:users, Accounts.list_users(sort: "name", dir: :asc))

          {:ok, socket}
        end

        def handle_event("sort", %{"key" => key, "dir" => dir}, socket) do
          dir_atom = String.to_existing_atom(dir)
          users = Accounts.list_users(sort: key, dir: dir_atom)

          socket =
            socket
            |> assign(sort_key: key, sort_dir: dir_atom)
            |> stream(:users, users, reset: true)

          {:noreply, socket}
        end

        def handle_event("paginate", %{"page" => page}, socket) do
          page_int = String.to_integer(page)
          users = Accounts.list_users(page: page_int, page_size: socket.assigns.page_size)

          socket =
            socket
            |> assign(page: page_int)
            |> stream(:users, users, reset: true)

          {:noreply, socket}
        end

        def handle_event("page_size", %{"value" => size}, socket) do
          size_int = String.to_integer(size)
          users = Accounts.list_users(page: 1, page_size: size_int)

          socket =
            socket
            |> assign(page: 1, page_size: size_int)
            |> stream(:users, users, reset: true)

          {:noreply, socket}
        end

        def handle_event("select_row", %{"id" => id}, socket) do
          id_int = String.to_integer(id)
          selected =
            if MapSet.member?(socket.assigns.selected_ids, id_int),
              do: MapSet.delete(socket.assigns.selected_ids, id_int),
              else: MapSet.put(socket.assigns.selected_ids, id_int)

          {:noreply, assign(socket, selected_ids: selected)}
        end

        def handle_event("select_all", _params, socket) do
          # Toggle: if any selected, deselect all; otherwise select all visible IDs
          selected =
            if MapSet.size(socket.assigns.selected_ids) > 0,
              do: MapSet.new(),
              else: MapSet.new(Enum.map(socket.assigns.streams.users, fn {_, u} -> u.id end))

          {:noreply, assign(socket, selected_ids: selected)}
        end

        def handle_event("toggle_column", %{"column" => key}, socket) do
          columns =
            Enum.map(socket.assigns.columns, fn col ->
              if col.key == key, do: %{col | visible: !col.visible}, else: col
            end)

          {:noreply, assign(socket, columns: columns)}
        end

        def render(assigns) do
          ~H\"\"\"
          <.data_grid_toolbar>
            <input
              type="text"
              placeholder="Search users…"
              phx-change="search"
              phx-debounce="300"
              class="h-8 rounded-md border border-input bg-background px-3 text-sm w-64"
            />
            <div class="ml-auto flex items-center gap-2">
              <.data_grid_column_toggle
                id="user-col-toggle"
                columns={@columns}
                on_toggle="toggle_column"
              />
            </div>
          </.data_grid_toolbar>

          <.data_grid>
            <thead>
              <tr>
                <.data_grid_select_all
                  checked={MapSet.size(@selected_ids) == length(@streams.users)}
                  indeterminate={MapSet.size(@selected_ids) > 0 and MapSet.size(@selected_ids) < length(@streams.users)}
                  on_check="select_all"
                />
                <.data_grid_head sort_key="name"  sort_dir={if @sort_key == "name",  do: @sort_dir, else: :none} on_sort="sort">Name</.data_grid_head>
                <.data_grid_head sort_key="email" sort_dir={if @sort_key == "email", do: @sort_dir, else: :none} on_sort="sort">Email</.data_grid_head>
                <.data_grid_head sort_key="role"  sort_dir={if @sort_key == "role",  do: @sort_dir, else: :none} on_sort="sort">Role</.data_grid_head>
                <.data_grid_head>Actions</.data_grid_head>
              </tr>
            </thead>
            <.data_grid_body id="users-body" phx-update="stream">
              <.data_grid_row
                :for={{dom_id, user} <- @streams.users}
                id={dom_id}
                class={if user.id in @selected_ids, do: "bg-muted/70"}
              >
                <.data_grid_row_checkbox
                  row_id={to_string(user.id)}
                  checked={user.id in @selected_ids}
                  on_check="select_row"
                />
                <.data_grid_cell><%= user.name %></.data_grid_cell>
                <.data_grid_cell><%= user.email %></.data_grid_cell>
                <.data_grid_cell><%= user.role %></.data_grid_cell>
                <.data_grid_cell>
                  <.button variant={:ghost} size={:sm} phx-click="edit_user" phx-value-id={user.id}>
                    Edit
                  </.button>
                </.data_grid_cell>
              </.data_grid_row>
            </.data_grid_body>
          </.data_grid>

          <.data_grid_pagination
            current_page={@page}
            total_pages={@total_pages}
            page_size={@page_size}
            on_page="paginate"
            on_page_size="page_size"
          />
          \"\"\"
        end
      end

  ## Accessibility

  - Sortable headers emit `aria-sort` (`"ascending"`, `"descending"`, `"none"`)
  - Row checkboxes use `role="checkbox"` and `aria-checked`
  - Select-all uses `aria-checked="mixed"` for indeterminate state
  - Pagination uses `<nav aria-label="Table pagination">` and `aria-label` on each button
  """

  use Phoenix.Component

  alias Phoenix.LiveView.JS

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # data_grid/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, default: nil, doc: "Optional ID for the outer wrapper div; used to build the aria-live status region ID")

  attr(:status_message, :string,
    default: "",
    doc: "Screen reader announcement for sort/filter/page changes. E.g.: 'Sorted by Name, ascending'"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the outer overflow wrapper")

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the `<table>` element (e.g. `aria-label`, `data-*`)"
  )

  slot(:inner_block, required: true, doc: "Table structure: thead, data_grid_body/1, tfoot")

  @doc """
  Renders the scrollable `<table>` container.

  The outer `<div>` has `overflow-auto` to handle wide tables on small screens
  without breaking the page layout. The table itself is `w-full caption-bottom
  text-sm` so it fills its container and uses bottom-positioned captions.

  ## Example

      <.data_grid>
        <thead>...</thead>
        <.data_grid_body id="rows" phx-update="stream">
          ...
        </.data_grid_body>
      </.data_grid>
  """
  def data_grid(assigns) do
    ~H"""
    <div id={@id} class={cn(["w-full overflow-auto", @class])}>
      <span
        role="status"
        aria-live="polite"
        aria-atomic="true"
        class="sr-only"
        id={if @id, do: "#{@id}-status"}
      >
        {@status_message}
      </span>
      <table class="w-full caption-bottom text-sm" {@rest}>
        <%= render_slot(@inner_block) %>
      </table>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # data_grid_head/1
  # ---------------------------------------------------------------------------

  attr(:sort_key, :string,
    default: nil,
    doc: """
    Column key sent as `phx-value-key` when the sort button is clicked.
    When `nil`, the header renders as plain non-interactive text (no sort button).
    Use the same string your LiveView will receive in `handle_event("sort", ...)`.
    """
  )

  attr(:sort_dir, :atom,
    default: :none,
    values: [:none, :asc, :desc],
    doc: """
    Current sort direction for this column. Pass `:none` for all columns
    except the currently sorted one. Controls the `aria-sort` attribute and
    which chevron icon is displayed. The **next** direction (sent on click)
    cycles: `:none → :asc → :desc → :none`.
    """
  )

  attr(:on_sort, :string,
    default: "sort",
    doc: """
    `phx-click` event name fired when the sort button is clicked. Receives
    two `phx-value` params: `key` (the column key) and `dir` (the next
    direction as a string: `"asc"`, `"desc"`, or `"none"`).
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)

  slot(:inner_block, required: true, doc: "Column header label text")

  @doc """
  Renders a `<th>` column header with optional sort button.

  When `:sort_key` is set, the header content is wrapped in a `<button>` that:
  - Fires `:on_sort` via `phx-click`
  - Sends `phx-value-key={sort_key}` and `phx-value-dir={next_direction}`
  - Renders a sort direction icon (`chevrons-up-down`, `chevron-up`, or `chevron-down`)
  - Sets `aria-sort` on the `<th>` for screen reader announcements

  Without `:sort_key`, renders a plain, non-interactive header cell suitable
  for action columns or columns where sorting is not meaningful.

  ## Example

      <%!-- Sortable column --%>
      <.data_grid_head sort_key="name" sort_dir={@sort[:name]} on_sort="sort">
        Name
      </.data_grid_head>

      <%!-- Non-sortable actions column --%>
      <.data_grid_head>Actions</.data_grid_head>
  """
  def data_grid_head(assigns) do
    ~H"""
    <th
      aria-sort={if @sort_key, do: aria_sort(@sort_dir)}
      class={cn([
        "h-11 px-4 text-left align-middle text-xs font-medium text-muted-foreground uppercase tracking-wider",
        # When this th contains a checkbox, remove right padding to align with td counterpart
        "[&:has([role=checkbox])]:pr-0",
        @class
      ])}
      {@rest}
    >
      <%= if @sort_key do %>
        <%!-- Sort button sends the NEXT direction so the LiveView just assigns
            what it receives — no direction-toggle logic needed server-side --%>
        <button
          type="button"
          phx-click={@on_sort}
          phx-value-key={@sort_key}
          phx-value-dir={next_dir(@sort_dir)}
          class="inline-flex items-center gap-1 hover:text-foreground transition-colors"
        >
          <%= render_slot(@inner_block) %>
          <.sort_icon dir={@sort_dir} />
        </button>
      <% else %>
        <%= render_slot(@inner_block) %>
      <% end %>
    </th>
    """
  end

  # ---------------------------------------------------------------------------
  # data_grid_body/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")

  attr(:rest, :global,
    doc: """
    HTML attributes forwarded to the `<tbody>` element. The most important
    use is `phx-update="stream"` for LiveView Streams:

        <.data_grid_body id="users" phx-update="stream">
          <.data_grid_row :for={{dom_id, user} <- @streams.users} id={dom_id}>
            ...
          </.data_grid_row>
        </.data_grid_body>

    When using streams, `id` is also required on the `<tbody>` itself.
    """
  )

  slot(:inner_block, required: true, doc: "data_grid_row/1 children")

  @doc """
  Renders the `<tbody>` element.

  The `[&_tr:last-child]:border-0` rule removes the bottom border from the
  last row so the table does not appear to have a double border with the
  pagination row below it.

  Supports `phx-update="stream"` for incremental LiveView Streams updates.
  Always provide an `id` attribute when using streams so LiveView can track
  the element across patches.

  ## Example

      <.data_grid_body id="user-rows" phx-update="stream">
        <.data_grid_row :for={{dom_id, user} <- @streams.users} id={dom_id}>
          <.data_grid_cell><%= user.name %></.data_grid_cell>
        </.data_grid_row>
      </.data_grid_body>
  """
  def data_grid_body(assigns) do
    ~H"""
    <tbody class={cn(["[&_tr:last-child]:border-0", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </tbody>
    """
  end

  # ---------------------------------------------------------------------------
  # data_grid_row/1
  # ---------------------------------------------------------------------------

  attr(:class, :string,
    default: nil,
    doc: """
    Additional CSS classes for conditional row styling (e.g. `"bg-amber-50"`
    to highlight rows with warnings). Applied after the base hover styles.
    """
  )

  attr(:rest, :global,
    doc: """
    HTML attributes forwarded to the `<tr>` element. When using LiveView
    Streams, pass `id={dom_id}` here so LiveView can identify the row.
    """
  )

  slot(:inner_block, required: true, doc: "data_grid_cell/1 and data_grid_row_checkbox/1 children")

  @doc """
  Renders a `<tr>` table row with hover state.

  Rows have `hover:bg-muted/50` for a subtle highlight on pointer-over and
  `transition-colors` so the background change is smooth. The base
  `border-b border-border` creates row dividers.

  ## Example

      <.data_grid_row id={dom_id} class={if user.suspended, do: "opacity-50"}>
        <.data_grid_cell><%= user.name %></.data_grid_cell>
      </.data_grid_row>
  """
  def data_grid_row(assigns) do
    ~H"""
    <tr
      class={cn([
        "border-b border-border transition-colors hover:bg-muted/50",
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </tr>
    """
  end

  # ---------------------------------------------------------------------------
  # data_grid_cell/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the cell")

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the `<td>` element (e.g. `colspan`, `rowspan`)"
  )

  slot(:inner_block, required: true, doc: "Cell content — text, badges, buttons, avatars, etc.")

  @doc """
  Renders a `<td>` data cell with consistent `px-4 py-3` padding.

  The `[&:has([role=checkbox])]:pr-0` rule removes right padding from cells
  containing a checkbox (`data_grid_row_checkbox/1`), keeping checkboxes
  visually aligned with the select-all header.

  ## Example

      <.data_grid_cell>John Smith</.data_grid_cell>
      <.data_grid_cell class="text-right font-mono">$1,234.56</.data_grid_cell>
      <.data_grid_cell>
        <.badge variant={:secondary}><%= user.role %></.badge>
      </.data_grid_cell>
  """
  def data_grid_cell(assigns) do
    ~H"""
    <td
      class={cn(["px-4 py-3 align-middle [&:has([role=checkbox])]:pr-0", @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </td>
    """
  end

  # ---------------------------------------------------------------------------
  # data_grid_toolbar/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the toolbar wrapper")
  attr(:rest, :global)

  slot(:inner_block,
    required: true,
    doc: """
    Toolbar content — typically a search input on the left and action buttons
    (column toggle, filters, export) on the right. Use `ml-auto` on the right
    group to push it to the trailing edge.
    """
  )

  @doc """
  Renders a flex toolbar row positioned above the data grid.

  The toolbar uses `flex items-center justify-between` with `gap-2` so that
  left-side controls (search, filters) and right-side controls (column toggle,
  export) sit at opposite ends naturally.

  ## Example

      <.data_grid_toolbar>
        <input type="text" placeholder="Search…" phx-change="search" phx-debounce="300"
               class="h-8 w-64 rounded-md border border-input bg-background px-3 text-sm" />
        <div class="ml-auto flex items-center gap-2">
          <.data_grid_column_toggle id="col-toggle" columns={@columns} on_toggle="toggle_column" />
          <.button variant={:outline} size={:sm} phx-click="export">Export CSV</.button>
        </div>
      </.data_grid_toolbar>
  """
  def data_grid_toolbar(assigns) do
    ~H"""
    <div class={cn(["flex items-center justify-between gap-2 py-2", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # data_grid_pagination/1
  # ---------------------------------------------------------------------------

  attr(:current_page, :integer,
    required: true,
    doc: "Current page number (1-indexed). Controls disabled state of prev/first buttons."
  )

  attr(:total_pages, :integer,
    required: true,
    doc: "Total number of pages. Controls disabled state of next/last buttons."
  )

  attr(:page_size, :integer,
    default: 10,
    doc: "Currently active page size — used to pre-select the correct option in the size selector."
  )

  attr(:page_size_options, :list,
    default: [10, 20, 50, 100],
    doc: """
    Available rows-per-page options for the `<select>` element. Each option
    renders as `<option value={n}>{n}</option>`. Default: `[10, 20, 50, 100]`.
    """
  )

  attr(:on_page, :string,
    default: "paginate",
    doc: """
    `phx-click` event fired by all navigation buttons (first, prev, next, last).
    Receives `phx-value-page` set to the target page number as a string.
    Handle with: `String.to_integer(page)`.
    """
  )

  attr(:on_page_size, :string,
    default: "page_size",
    doc: """
    `phx-change` event fired when the rows-per-page selector changes.
    Receives `%{"value" => "20"}`. Handle with: `String.to_integer(size)`.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the nav element")
  attr(:rest, :global)

  @doc """
  Renders a full-featured pagination navigation bar.

  Includes:
  - **Rows per page** selector (left side) — fires `on_page_size` via `phx-change`
  - **Page counter** display: "Page X of Y"
  - **First / Prev / Next / Last** buttons — fire `on_page` via `phx-click`

  Navigation buttons are automatically disabled (pointer-events-none + opacity-50)
  when they would navigate out of range:
  - First and Prev are disabled on page 1
  - Next and Last are disabled on the last page

  ## Example

      <.data_grid_pagination
        current_page={@page}
        total_pages={@total_pages}
        page_size={@page_size}
        page_size_options={[10, 25, 50]}
        on_page="paginate"
        on_page_size="change_page_size"
      />

  ## LiveView handlers

      def handle_event("paginate", %{"page" => page}, socket) do
        {:noreply, assign(socket, page: String.to_integer(page))}
      end

      def handle_event("change_page_size", %{"value" => size}, socket) do
        {:noreply, assign(socket, page: 1, page_size: String.to_integer(size))}
      end
  """
  def data_grid_pagination(assigns) do
    # Extract button class to a precomputed assign to avoid repeating the
    # long class string four times in the template
    assigns = assign(assigns, :btn_class, pagination_btn_class())

    ~H"""
    <nav
      aria-label="Table pagination"
      class={cn(["flex items-center justify-between gap-4 px-2 py-4", @class])}
      {@rest}
    >
      <%!-- Left side: rows-per-page selector --%>
      <div class="flex items-center gap-2">
        <span class="text-sm text-muted-foreground">Rows per page</span>
        <select
          aria-label="Rows per page"
          phx-change={@on_page_size}
          class="h-8 rounded-md border border-input bg-background px-2 text-sm focus:outline-none focus:ring-2 focus:ring-ring"
        >
          <option :for={opt <- @page_size_options} value={opt} selected={opt == @page_size}>
            {opt}
          </option>
        </select>
      </div>
      <%!-- Right side: page counter + navigation buttons --%>
      <div class="flex items-center gap-3">
        <span class="text-sm text-muted-foreground">
          Page {@current_page} of {@total_pages}
        </span>
        <div class="flex items-center gap-1">
          <button
            type="button"
            aria-label="First page"
            disabled={@current_page <= 1}
            phx-click={@on_page}
            phx-value-page={1}
            class={cn([@btn_class, @current_page <= 1 && "pointer-events-none opacity-50"])}
          >
            <.icon name="chevrons-left" size={:sm} />
          </button>
          <button
            type="button"
            aria-label="Previous page"
            disabled={@current_page <= 1}
            phx-click={@on_page}
            phx-value-page={@current_page - 1}
            class={cn([@btn_class, @current_page <= 1 && "pointer-events-none opacity-50"])}
          >
            <.icon name="chevron-left" size={:sm} />
          </button>
          <button
            type="button"
            aria-label="Next page"
            disabled={@current_page >= @total_pages}
            phx-click={@on_page}
            phx-value-page={@current_page + 1}
            class={cn([@btn_class, @current_page >= @total_pages && "pointer-events-none opacity-50"])}
          >
            <.icon name="chevron-right" size={:sm} />
          </button>
          <button
            type="button"
            aria-label="Last page"
            disabled={@current_page >= @total_pages}
            phx-click={@on_page}
            phx-value-page={@total_pages}
            class={cn([@btn_class, @current_page >= @total_pages && "pointer-events-none opacity-50"])}
          >
            <.icon name="chevrons-right" size={:sm} />
          </button>
        </div>
      </div>
    </nav>
    """
  end

  # ---------------------------------------------------------------------------
  # data_grid_column_toggle/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    required: true,
    doc: """
    Unique element ID. Used to build the dropdown menu ID (e.g. `"my-grid-menu"`)
    and as the toggle target for `JS.toggle/1`. Must be unique on the page.
    """
  )

  attr(:columns, :list,
    required: true,
    doc: """
    List of column definition maps. Each map must have:
    - `key` — String used as `phx-value-column` when the checkbox is clicked
    - `label` — Human-readable column name shown in the dropdown
    - `visible` — Boolean controlling the checked state of the checkbox

    Example: `[%{key: "name", label: "Name", visible: true}, ...]`
    """
  )

  attr(:on_toggle, :string,
    default: "toggle_column",
    doc: """
    `phx-click` event fired when a column checkbox is toggled. Receives
    `phx-value-column` set to the column `key`. Handle with:

        def handle_event("toggle_column", %{"column" => key}, socket) do
          columns = Enum.map(socket.assigns.columns, fn col ->
            if col.key == key, do: %{col | visible: !col.visible}, else: col
          end)
          {:noreply, assign(socket, columns: columns)}
        end
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the wrapper div")

  @doc """
  Renders a column-visibility toggle button with a dropdown checklist.

  Clicking the "Columns" button calls `JS.toggle/1` to show/hide a dropdown
  menu listing all columns with checkboxes. Checking/unchecking a box fires
  `on_toggle` with `phx-value-column` set to the column key. All visibility
  state is managed in the LiveView — this component is stateless.

  The dropdown is positioned `absolute right-0 top-10` so it opens below
  and to the right of the button. Ensure the parent has `position: relative`
  (the wrapper div adds this automatically).

  ## Example

      <.data_grid_column_toggle
        id="user-columns"
        columns={@columns}
        on_toggle="toggle_column"
      />
  """
  def data_grid_column_toggle(assigns) do
    ~H"""
    <div class={cn(["relative", @class])} id={@id}>
      <button
        type="button"
        aria-label="Toggle columns"
        phx-click={JS.toggle(to: "##{@id}-menu")}
        class="inline-flex h-8 items-center gap-2 rounded-md border border-input bg-background px-3 text-sm hover:bg-accent hover:text-accent-foreground transition-colors"
      >
        <.icon name="settings-2" size={:sm} />
        Columns
      </button>
      <%!-- Dropdown starts hidden; JS.toggle flips between hidden/block --%>
      <div
        id={"#{@id}-menu"}
        class="absolute right-0 top-10 z-50 hidden min-w-[150px] rounded-md border border-border bg-popover p-1 shadow-md"
      >
        <label
          :for={col <- @columns}
          class="flex cursor-pointer items-center gap-2 rounded px-2 py-1.5 text-sm hover:bg-accent"
        >
          <input
            type="checkbox"
            checked={col.visible}
            phx-click={@on_toggle}
            phx-value-column={col.key}
            aria-label={col.label}
            class="h-4 w-4 rounded border-border accent-primary"
          />
          {col.label}
        </label>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # data_grid_row_checkbox/1
  # ---------------------------------------------------------------------------

  attr(:row_id, :string,
    required: true,
    doc: """
    Row identifier sent as `phx-value-id` when the checkbox is clicked.
    Typically the record's database ID as a string: `to_string(user.id)`.
    Your `handle_event` receives it as a string and should convert back with
    `String.to_integer/1` or pattern-match directly.
    """
  )

  attr(:checked, :boolean,
    default: false,
    doc: """
    Whether this row is currently selected. Derive from your LiveView state:
    `checked={user.id in @selected_ids}` (for `MapSet`) or
    `checked={user.id in @selected_ids}` (for a plain list).
    """
  )

  attr(:on_check, :string,
    default: "select_row",
    doc: """
    `phx-click` event fired when the checkbox is toggled. Receives
    `phx-value-id` set to `row_id`. Toggle the ID in/out of your selection
    set in the handler.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the `<td>` wrapper")

  @doc """
  Renders a `<td>` selection checkbox for an individual data grid row.

  The checkbox cell has a fixed width (`w-10`) and minimal padding (`p-2`)
  to stay compact. The `role="checkbox"` attribute enables the CSS rule
  `[&:has([role=checkbox])]:pr-0` on parent cells to trim padding.

  Pass `checked={row_id in @selected_ids}` and maintain the selected set in
  your LiveView. There is no internal state here.

  ## Example

      <.data_grid_row_checkbox
        row_id={to_string(user.id)}
        checked={user.id in @selected_ids}
        on_check="select_row"
      />
  """
  def data_grid_row_checkbox(assigns) do
    ~H"""
    <td class={cn(["p-2 align-middle w-10", @class])}>
      <input
        type="checkbox"
        role="checkbox"
        aria-checked={to_string(@checked)}
        aria-label="Select row"
        checked={@checked}
        phx-click={@on_check}
        phx-value-id={@row_id}
        class="h-4 w-4 rounded border-border accent-primary"
      />
    </td>
    """
  end

  # ---------------------------------------------------------------------------
  # data_grid_select_all/1
  # ---------------------------------------------------------------------------

  attr(:checked, :boolean,
    default: false,
    doc: """
    Whether all visible rows are selected. Set to `true` when every row ID
    is in `@selected_ids`.
    """
  )

  attr(:indeterminate, :boolean,
    default: false,
    doc: """
    When `true`, renders `aria-checked="mixed"` to signal partial selection to
    assistive technology. Set to `true` when some (but not all) rows are
    selected. Takes precedence over `:checked` for the `aria-checked` value.
    """
  )

  attr(:on_check, :string,
    default: "select_all",
    doc: """
    `phx-click` event fired when the checkbox is clicked. Receives no
    `phx-value` params — the handler should toggle between selecting all
    and deselecting all based on current state.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the `<th>` cell")

  @doc """
  Renders a `<th>` select-all checkbox for the data grid header row.

  When `indeterminate` is `true`, `aria-checked` is set to `"mixed"` to
  communicate partial selection to screen readers. This is the WAI-ARIA
  pattern for tri-state checkboxes. Note that the visual indeterminate
  state (the dash inside the checkbox) requires JavaScript on the client
  side — the `PhiaDataGrid` hook (if installed) handles this automatically.

  ## Example

      <.data_grid_select_all
        checked={@all_selected}
        indeterminate={@some_selected}
        on_check="select_all"
      />
  """
  def data_grid_select_all(assigns) do
    ~H"""
    <th class={cn(["h-10 w-10 px-2 align-middle", @class])}>
      <input
        type="checkbox"
        role="checkbox"
        aria-checked={if @indeterminate, do: "mixed", else: to_string(@checked)}
        aria-label="Select all rows"
        checked={@checked}
        phx-click={@on_check}
        class="h-4 w-4 rounded border-border accent-primary"
      />
    </th>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Build the pagination button class once so it is not repeated four times
  # in the template. This is a plain string (not cn/1) since it never needs
  # conditional merging — conditional classes are added at the call site.
  defp pagination_btn_class do
    "inline-flex h-9 w-9 items-center justify-center rounded-md border border-input " <>
      "bg-background hover:bg-accent hover:text-accent-foreground transition-colors"
  end

  # Cycle sort direction on each click: none → asc → desc → none.
  # Returns a STRING, not an atom, because phx-value always sends strings to
  # handle_event/3.  Using a string here means the LiveView can use the value
  # directly without conversion on the client (the hook never touches it).
  # The LiveView handler must call String.to_existing_atom/1 to get the atom back.
  defp next_dir(:none), do: "asc"
  defp next_dir(:asc), do: "desc"
  defp next_dir(:desc), do: "none"

  # Map internal atom to WAI-ARIA aria-sort attribute value.
  # The ARIA spec requires "ascending", "descending", or "none" — not "asc"/"desc".
  defp aria_sort(:none), do: "none"
  defp aria_sort(:asc), do: "ascending"
  defp aria_sort(:desc), do: "descending"

  attr(:dir, :atom, required: true, values: [:none, :asc, :desc])

  # Private sub-component for the sort direction indicator icon.
  # Three function heads instead of a single function with cond/case so that
  # the compiler exhaustiveness-checks the :dir atom values.

  # :none → double chevron indicating the column is sortable but currently unsorted
  defp sort_icon(%{dir: :none} = assigns) do
    ~H"""
    <.icon name="chevrons-up-down" size={:sm} />
    """
  end

  # :asc → single up chevron confirming ascending sort is active
  defp sort_icon(%{dir: :asc} = assigns) do
    ~H"""
    <.icon name="chevron-up" size={:sm} />
    """
  end

  # :desc → single down chevron confirming descending sort is active
  defp sort_icon(%{dir: :desc} = assigns) do
    ~H"""
    <.icon name="chevron-down" size={:sm} />
    """
  end
end
