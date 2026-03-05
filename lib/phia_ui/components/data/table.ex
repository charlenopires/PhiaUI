defmodule PhiaUi.Components.Table do
  @moduledoc """
  Composable table component following the shadcn/ui anatomy.

  Provides 8 independent sub-components that compose the standard HTML table
  hierarchy. Unlike `data_grid/1` (which adds sorting, pagination, and row
  selection), `Table` is a **pure presentational primitive** — use it when you
  need a well-styled, accessible table without the overhead of interactive state.

  > #### LiveView Streams compatibility {: .tip}
  >
  > This component is designed to work seamlessly with LiveView Streams
  > (`stream/3`, `stream_insert/3`). Use `table_body/1` as the stream container:
  >
  >     <.table_body id="users" phx-update="stream">
  >       <.table_row :for={{dom_id, user} <- @streams.users} id={dom_id}>
  >         <.table_cell><%= user.name %></.table_cell>
  >       </.table_row>
  >     </.table_body>
  >
  > Always set an `id` on `table_body/1` when using `phx-update="stream"` —
  > LiveView requires a stable ID to track the container across patches.
  > For large datasets combine with `phx-viewport-top` / `phx-viewport-bottom`
  > for infinite scroll pagination.

  ## Sub-components

  | Function          | HTML element  | Purpose                                  |
  |-------------------|---------------|------------------------------------------|
  | `table/1`         | `div > table` | Scrollable outer container               |
  | `table_header/1`  | `thead`       | Column header section                    |
  | `table_body/1`    | `tbody`       | Data rows section; streams-compatible    |
  | `table_footer/1`  | `tfoot`       | Totals / summary rows                    |
  | `table_row/1`     | `tr`          | Individual row with optional selection   |
  | `table_head/1`    | `th`          | Column header cell                       |
  | `table_cell/1`    | `td`          | Data cell with consistent padding        |
  | `table_caption/1` | `caption`     | Accessible screen-reader caption         |

  ## When to use Table vs DataGrid

  | Scenario                                               | Use             |
  |--------------------------------------------------------|-----------------|
  | Static or read-only data display                       | `Table`         |
  | Simple lists with LiveView Streams                     | `Table`         |
  | Server-side sorting, pagination, row selection         | `DataGrid`      |
  | Column visibility toggle, toolbar, bulk actions        | `DataGrid`      |

  ## Basic example

      <.table>
        <.table_caption>Monthly revenue by product</.table_caption>
        <.table_header>
          <.table_row>
            <.table_head>Product</.table_head>
            <.table_head>Revenue</.table_head>
            <.table_head>Growth</.table_head>
            <.table_head>Status</.table_head>
          </.table_row>
        </.table_header>
        <.table_body>
          <.table_row>
            <.table_cell>Starter Plan</.table_cell>
            <.table_cell>$12,340</.table_cell>
            <.table_cell>+8%</.table_cell>
            <.table_cell><.badge>Active</.badge></.table_cell>
          </.table_row>
          <.table_row selected={true}>
            <.table_cell>Pro Plan</.table_cell>
            <.table_cell>$48,200</.table_cell>
            <.table_cell>+15%</.table_cell>
            <.table_cell><.badge variant={:default}>Active</.badge></.table_cell>
          </.table_row>
        </.table_body>
        <.table_footer>
          <.table_row>
            <.table_cell class="font-medium">Total</.table_cell>
            <.table_cell class="font-medium">$60,540</.table_cell>
            <.table_cell></.table_cell>
            <.table_cell></.table_cell>
          </.table_row>
        </.table_footer>
      </.table>

  ## LiveView Streams example

      defmodule MyAppWeb.ProductsLive do
        use MyAppWeb, :live_view

        def mount(_params, _session, socket) do
          {:ok, stream(socket, :products, Products.list())}
        end

        def handle_info({:product_updated, product}, socket) do
          # stream_insert/3 patches only the changed row — no full re-render
          {:noreply, stream_insert(socket, :products, product)}
        end

        def render(assigns) do
          ~H\"\"\"
          <.table>
            <.table_header>
              <.table_row>
                <.table_head>Name</.table_head>
                <.table_head>Price</.table_head>
                <.table_head>Stock</.table_head>
              </.table_row>
            </.table_header>
            <.table_body id="products" phx-update="stream">
              <.table_row :for={{dom_id, product} <- @streams.products} id={dom_id}>
                <.table_cell><%= product.name %></.table_cell>
                <.table_cell><%= product.price %></.table_cell>
                <.table_cell><%= product.stock %></.table_cell>
              </.table_row>
            </.table_body>
          </.table>
          \"\"\"
        end
      end
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # table/1
  # ---------------------------------------------------------------------------

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes for the outer wrapper div (e.g. `rounded-md border`)"
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the outer `<div>` wrapper")

  slot(:inner_block,
    required: true,
    doc: "Table structure: `table_header/1`, `table_body/1`, `table_footer/1`, `table_caption/1`"
  )

  @doc """
  Renders a scrollable table container.

  The outer `<div>` has `relative w-full overflow-auto` so that wide tables
  scroll horizontally without breaking the page layout. The `<table>` inside
  uses `w-full caption-bottom text-sm` — it fills the container width and
  places captions below the table.

  ## Example

      <.table class="rounded-md border">
        <.table_header>...</.table_header>
        <.table_body>...</.table_body>
      </.table>
  """
  def table(assigns) do
    ~H"""
    <div class={cn(["relative w-full overflow-auto", @class])} {@rest}>
      <table class="w-full caption-bottom text-sm">
        <%= render_slot(@inner_block) %>
      </table>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # table_header/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to `<thead>`")

  slot(:inner_block,
    required: true,
    doc: "Header rows — typically one `table_row/1` containing `table_head/1` cells"
  )

  @doc """
  Renders the `<thead>` section.

  The `[&_tr]:border-b` rule adds a bottom border to all header rows, creating
  a visual separator between the header and the first data row.

  ## Example

      <.table_header>
        <.table_row>
          <.table_head>Name</.table_head>
          <.table_head>Email</.table_head>
        </.table_row>
      </.table_header>
  """
  def table_header(assigns) do
    ~H"""
    <thead class={cn(["[&_tr]:border-b", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </thead>
    """
  end

  # ---------------------------------------------------------------------------
  # table_body/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")

  attr(:rest, :global,
    doc: """
    HTML attributes forwarded to `<tbody>`. When using LiveView Streams, pass
    `phx-update="stream"` and `id="unique-id"` here:

        <.table_body id="users" phx-update="stream">
    """
  )

  slot(:inner_block,
    required: true,
    doc: "Data rows — `table_row/1` children (static or `:for` loop)"
  )

  @doc """
  Renders the `<tbody>` section. Supports LiveView Streams via `phx-update`.

  The `[&_tr:last-child]:border-0` rule removes the bottom border from the
  last row, preventing a double border at the boundary between the table body
  and the table footer (or the container edge when no footer is present).

  ## Static usage

      <.table_body>
        <.table_row :for={row <- @rows}>
          <.table_cell><%= row.name %></.table_cell>
        </.table_row>
      </.table_body>

  ## Streams usage

      <.table_body id="rows" phx-update="stream">
        <.table_row :for={{dom_id, row} <- @streams.rows} id={dom_id}>
          <.table_cell><%= row.name %></.table_cell>
        </.table_row>
      </.table_body>
  """
  def table_body(assigns) do
    ~H"""
    <tbody class={cn(["[&_tr:last-child]:border-0", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </tbody>
    """
  end

  # ---------------------------------------------------------------------------
  # table_footer/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to `<tfoot>`")

  slot(:inner_block,
    required: true,
    doc: "Footer rows — typically totals, averages, or summary statistics"
  )

  @doc """
  Renders the `<tfoot>` section for totals and summary rows.

  Uses `bg-muted/50 font-medium` to visually distinguish footer rows from
  regular data rows. A top border (`border-t`) separates it from the body.

  ## Example

      <.table_footer>
        <.table_row>
          <.table_cell>Total</.table_cell>
          <.table_cell>$60,540</.table_cell>
          <.table_cell></.table_cell>
        </.table_row>
      </.table_footer>
  """
  def table_footer(assigns) do
    ~H"""
    <tfoot class={cn(["border-t bg-muted/50 font-medium", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </tfoot>
    """
  end

  # ---------------------------------------------------------------------------
  # table_row/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes for conditional row styling")

  attr(:selected, :boolean,
    default: false,
    doc: """
    When `true`, sets `data-state="selected"` on the `<tr>`, which triggers
    the `data-[state=selected]:bg-muted` Tailwind rule to highlight the row.
    Use this for externally managed selection state (e.g. from a form).
    """
  )

  attr(:rest, :global,
    doc: """
    HTML attributes forwarded to `<tr>`. When using streams, pass `id={dom_id}`
    so LiveView can track the element across patches.
    """
  )

  slot(:inner_block,
    required: true,
    doc: "`table_head/1` or `table_cell/1` children"
  )

  @doc """
  Renders a `<tr>` table row.

  All rows have:
  - `border-b` — bottom divider (removed on last child by the tbody rule)
  - `transition-colors` — smooth background transition on hover/selection
  - `hover:bg-muted/50` — subtle hover highlight

  When `selected={true}`, the row gets `data-state="selected"` which activates
  the `data-[state=selected]:bg-muted` style.

  ## Example

      <.table_row selected={user.id in @selected_ids}>
        <.table_cell><%= user.name %></.table_cell>
      </.table_row>
  """
  def table_row(assigns) do
    ~H"""
    <tr
      class={cn(["border-b transition-colors hover:bg-muted/50 data-[state=selected]:bg-muted", @class])}
      data-state={@selected && "selected"}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </tr>
    """
  end

  # ---------------------------------------------------------------------------
  # table_head/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to `<th>`")

  slot(:inner_block,
    required: true,
    doc: "Header cell content — column name, sort button, or checkbox"
  )

  @doc """
  Renders a `<th>` column header cell.

  Uses `text-xs uppercase tracking-wider` for an enterprise-style compact
  header aesthetic. Content is left-aligned by default (`text-left`).

  ## Example

      <.table_head class="text-right">Amount</.table_head>
      <.table_head>Status</.table_head>
  """
  def table_head(assigns) do
    ~H"""
    <th
      class={cn([
        "h-11 px-4 text-left align-middle text-xs font-medium text-muted-foreground uppercase tracking-wider",
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </th>
    """
  end

  # ---------------------------------------------------------------------------
  # table_cell/1
  # ---------------------------------------------------------------------------

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes for padding or alignment overrides"
  )

  attr(:rest, :global,
    doc: "HTML attributes forwarded to `<td>` (e.g. `colspan`, `rowspan`, `data-*`)"
  )

  slot(:inner_block,
    required: true,
    doc: "Cell content — plain text, formatted numbers, badges, buttons, avatars, etc."
  )

  @doc """
  Renders a `<td>` data cell.

  The default `px-4 py-3` padding is consistent with `table_head/1` headers
  so columns align correctly. Use the `:class` attr to override padding or
  alignment for specific columns:

      <%!-- Right-align a numeric column --%>
      <.table_cell class="text-right font-mono tabular-nums">$1,234.56</.table_cell>

      <%!-- Tighter padding for a compact icon-only column --%>
      <.table_cell class="px-2 py-1">
        <.button variant={:ghost} size={:icon}><.icon name="edit" /></.button>
      </.table_cell>
  """
  def table_cell(assigns) do
    ~H"""
    <td class={cn(["px-4 py-3 align-middle", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </td>
    """
  end

  # ---------------------------------------------------------------------------
  # table_caption/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to `<caption>`")

  slot(:inner_block,
    required: true,
    doc: "Caption text describing the table's purpose for screen readers and sighted users"
  )

  @doc """
  Renders a `<caption>` element for accessible table labelling.

  The `caption` element is placed after the table content (`caption-side:
  bottom` via `caption-bottom` on the parent `<table>`). It is visible to all
  users by default — use it for data source attribution, last-updated
  timestamps, or brief table descriptions.

  The `<caption>` element is the preferred way to label a table for
  accessibility because it is directly associated with the table in the
  accessibility tree, unlike an `aria-label` or heading placed outside.

  ## Example

      <.table>
        <.table_caption>Revenue data as of March 2026</.table_caption>
        ...
      </.table>
  """
  def table_caption(assigns) do
    ~H"""
    <caption class={cn(["mt-4 text-sm text-muted-foreground", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </caption>
    """
  end
end
