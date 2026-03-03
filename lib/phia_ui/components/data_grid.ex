defmodule PhiaUi.Components.DataGrid do
  @moduledoc """
  Enhanced table component with server-side column sorting, pagination,
  toolbar, column visibility toggling, and row selection.

  All state (sort direction, current page, selected rows, visible columns) is
  managed in your LiveView — every sub-component is stateless. Streams-compatible.

  ## Sub-components

  - `data_grid/1` — `<table>` wrapper with overflow container
  - `data_grid_head/1` — `<th>` with optional sort button (`:sort_key`, `:sort_dir`)
  - `data_grid_body/1` — `<tbody>`, accepts `phx-update="stream"`
  - `data_grid_row/1` — `<tr>` with `:class` for conditional styling
  - `data_grid_cell/1` — `<td>` with consistent padding
  - `data_grid_toolbar/1` — flex toolbar above the table (search, filters, actions)
  - `data_grid_pagination/1` — pagination nav with previous/next and rows-per-page
  - `data_grid_column_toggle/1` — dropdown to show/hide columns
  - `data_grid_row_checkbox/1` — `<td>` with row selection checkbox
  - `data_grid_select_all/1` — `<th>` with select-all checkbox

  ## Example

      <.data_grid_toolbar>
        <input type="text" placeholder="Search..." phx-change="search" />
        <.data_grid_column_toggle id="col-toggle" columns={@columns} on_toggle="toggle_column" />
      </.data_grid_toolbar>

      <.data_grid>
        <thead>
          <tr>
            <.data_grid_select_all checked={@all_selected} indeterminate={@some_selected} on_check="select_all" />
            <.data_grid_head sort_key="name" sort_dir={@sort_dir} on_sort="sort">
              Name
            </.data_grid_head>
            <.data_grid_head>Actions</.data_grid_head>
          </tr>
        </thead>
        <.data_grid_body id="users" phx-update="stream">
          <.data_grid_row :for={{id, user} <- @streams.users} id={id}>
            <.data_grid_row_checkbox row_id={user.id} checked={user.id in @selected} on_check="select_row" />
            <.data_grid_cell><%= user.name %></.data_grid_cell>
            <.data_grid_cell>...</.data_grid_cell>
          </.data_grid_row>
        </.data_grid_body>
      </.data_grid>

      <.data_grid_pagination current_page={@page} total_pages={@total_pages} on_page="paginate" />

  ## LiveView handlers

      def handle_event("sort", %{"key" => key, "dir" => dir}, socket) do
        {:noreply, assign(socket, sort_key: key, sort_dir: String.to_existing_atom(dir))}
      end

      def handle_event("paginate", %{"page" => page}, socket) do
        {:noreply, assign(socket, page: String.to_integer(page))}
      end

      def handle_event("toggle_column", %{"column" => key}, socket) do
        columns = Enum.map(socket.assigns.columns, fn col ->
          if col.key == key, do: %{col | visible: !col.visible}, else: col
        end)
        {:noreply, assign(socket, columns: columns)}
      end

  """

  use Phoenix.Component

  alias Phoenix.LiveView.JS

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc "Renders the `<table>` wrapper with overflow container."
  def data_grid(assigns) do
    ~H"""
    <div class={cn(["w-full overflow-auto", @class])}>
      <table class="w-full caption-bottom text-sm" {@rest}>
        <%= render_slot(@inner_block) %>
      </table>
    </div>
    """
  end

  attr(:sort_key, :string,
    default: nil,
    doc: "Column key sent with sort event; nil = non-sortable"
  )

  attr(:sort_dir, :atom,
    default: :none,
    values: [:none, :asc, :desc],
    doc: "Current sort direction for this column"
  )

  attr(:on_sort, :string, default: "sort", doc: "phx-click event name for sort")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc """
  Renders a `<th>` column header.

  When `:sort_key` is provided, renders a sort button with the appropriate
  direction icon and `aria-sort`. Clicking fires `:on_sort` with
  `phx-value-key` and `phx-value-dir` (the toggled next direction).
  Without `:sort_key`, renders a plain non-interactive header.
  """
  def data_grid_head(assigns) do
    ~H"""
    <th
      aria-sort={if @sort_key, do: aria_sort(@sort_dir)}
      class={cn([
        "h-11 px-4 text-left align-middle text-xs font-medium text-muted-foreground uppercase tracking-wider",
        "[&:has([role=checkbox])]:pr-0",
        @class
      ])}
      {@rest}
    >
      <%= if @sort_key do %>
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

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc "Renders `<tbody>`. Accepts `phx-update='stream'` for LiveView streams."
  def data_grid_body(assigns) do
    ~H"""
    <tbody class={cn(["[&_tr:last-child]:border-0", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </tbody>
    """
  end

  attr(:class, :string, default: nil, doc: "Additional CSS classes for conditional row styling")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc "Renders a `<tr>` table row."
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

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc "Renders a `<td>` table cell with consistent padding."
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

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc """
  Renders a flex toolbar row above the data grid.

  Use it to host search inputs, filter controls, and the column toggle button.
  """
  def data_grid_toolbar(assigns) do
    ~H"""
    <div class={cn(["flex items-center justify-between gap-2 py-2", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr(:current_page, :integer, required: true, doc: "Current page number (1-indexed)")
  attr(:total_pages, :integer, required: true, doc: "Total number of pages")
  attr(:page_size, :integer, default: 10, doc: "Currently active page size")

  attr(:page_size_options, :list,
    default: [10, 20, 50, 100],
    doc: "Available options for the rows-per-page selector"
  )

  attr(:on_page, :string, default: "paginate", doc: "phx-click event; sends phx-value-page")

  attr(:on_page_size, :string,
    default: "page_size",
    doc: "phx-change event for the size selector"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)

  @doc """
  Renders a pagination nav with first/previous/next/last buttons and a
  rows-per-page selector.

  All navigation fires `on_page` with `phx-value-page` set to the target page
  number. The size selector fires `on_page_size` via `phx-change`.
  """
  def data_grid_pagination(assigns) do
    assigns = assign(assigns, :btn_class, pagination_btn_class())

    ~H"""
    <nav
      aria-label="Table pagination"
      class={cn(["flex items-center justify-between gap-4 px-2 py-4", @class])}
      {@rest}
    >
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
            class={cn([
              @btn_class,
              @current_page <= 1 && "pointer-events-none opacity-50"
            ])}
          >
            <.icon name="chevrons-left" size={:sm} />
          </button>
          <button
            type="button"
            aria-label="Previous page"
            disabled={@current_page <= 1}
            phx-click={@on_page}
            phx-value-page={@current_page - 1}
            class={cn([
              @btn_class,
              @current_page <= 1 && "pointer-events-none opacity-50"
            ])}
          >
            <.icon name="chevron-left" size={:sm} />
          </button>
          <button
            type="button"
            aria-label="Next page"
            disabled={@current_page >= @total_pages}
            phx-click={@on_page}
            phx-value-page={@current_page + 1}
            class={cn([
              @btn_class,
              @current_page >= @total_pages && "pointer-events-none opacity-50"
            ])}
          >
            <.icon name="chevron-right" size={:sm} />
          </button>
          <button
            type="button"
            aria-label="Last page"
            disabled={@current_page >= @total_pages}
            phx-click={@on_page}
            phx-value-page={@total_pages}
            class={cn([
              @btn_class,
              @current_page >= @total_pages && "pointer-events-none opacity-50"
            ])}
          >
            <.icon name="chevrons-right" size={:sm} />
          </button>
        </div>
      </div>
    </nav>
    """
  end

  attr(:id, :string,
    required: true,
    doc: "Unique element ID — used by JS.toggle to show/hide the dropdown"
  )

  attr(:columns, :list,
    required: true,
    doc: "List of `%{key: String.t(), label: String.t(), visible: boolean()}` maps"
  )

  attr(:on_toggle, :string,
    default: "toggle_column",
    doc: "phx-click event; sends phx-value-column"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")

  @doc """
  Renders a column-visibility toggle button with a dropdown checklist.

  Each column checkbox fires `on_toggle` with `phx-value-column` set to the
  column key. Toggle state is managed entirely in the LiveView.

  Requires the `id` attr to be unique on the page — it anchors the JS toggle.
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

  attr(:row_id, :string, required: true, doc: "Row identifier sent as phx-value-id")
  attr(:checked, :boolean, default: false, doc: "Whether this row is selected")
  attr(:on_check, :string, default: "select_row", doc: "phx-click event; sends phx-value-id")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")

  @doc """
  Renders a `<td>` selection checkbox for a data grid row.

  Fires `on_check` with `phx-value-id` set to `row_id`. Track selected IDs
  in the LiveView and pass `checked={row.id in @selected_ids}`.
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

  attr(:checked, :boolean, default: false, doc: "Whether all rows are selected")

  attr(:indeterminate, :boolean,
    default: false,
    doc: "True when some (but not all) rows are selected; renders aria-checked='mixed'"
  )

  attr(:on_check, :string, default: "select_all", doc: "phx-click event for select-all")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")

  @doc """
  Renders a `<th>` select-all checkbox for the data grid header.

  When `indeterminate` is true, `aria-checked` is set to `"mixed"` to signal
  partial selection to screen readers.
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

  defp pagination_btn_class do
    "inline-flex h-8 w-8 items-center justify-center rounded-md border border-input " <>
      "bg-background hover:bg-accent hover:text-accent-foreground transition-colors"
  end

  defp next_dir(:none), do: "asc"
  defp next_dir(:asc), do: "desc"
  defp next_dir(:desc), do: "none"

  defp aria_sort(:none), do: "none"
  defp aria_sort(:asc), do: "ascending"
  defp aria_sort(:desc), do: "descending"

  attr(:dir, :atom, required: true, values: [:none, :asc, :desc])

  defp sort_icon(%{dir: :none} = assigns) do
    ~H"""
    <.icon name="chevrons-up-down" size={:sm} />
    """
  end

  defp sort_icon(%{dir: :asc} = assigns) do
    ~H"""
    <.icon name="chevron-up" size={:sm} />
    """
  end

  defp sort_icon(%{dir: :desc} = assigns) do
    ~H"""
    <.icon name="chevron-down" size={:sm} />
    """
  end
end
