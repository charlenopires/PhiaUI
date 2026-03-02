defmodule PhiaUi.Components.Table do
  @moduledoc """
  Composable Table component for dense data grids in dashboards.

  Provides 8 independent sub-components following the shadcn/ui Table anatomy.

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
  > For large datasets, combine with `phx-viewport-top` / `phx-viewport-bottom`
  > for infinite scroll pagination.

  ## Sub-components

  | Function         | Element     | Purpose                    |
  |------------------|-------------|----------------------------|
  | `table/1`        | `div>table` | Scrollable outer container |
  | `table_header/1` | `thead`     | Column header section      |
  | `table_body/1`   | `tbody`     | Data rows section          |
  | `table_footer/1` | `tfoot`     | Summary / totals section   |
  | `table_row/1`    | `tr`        | Individual row             |
  | `table_head/1`   | `th`        | Column header cell         |
  | `table_cell/1`   | `td`        | Data cell                  |
  | `table_caption/1`| `caption`   | Accessible table caption   |

  ## Example

      <.table>
        <.table_caption>Monthly revenue</.table_caption>
        <.table_header>
          <.table_row>
            <.table_head>Month</.table_head>
            <.table_head>Revenue</.table_head>
            <.table_head>Growth</.table_head>
          </.table_row>
        </.table_header>
        <.table_body>
          <.table_row>
            <.table_cell>January</.table_cell>
            <.table_cell>$12,340</.table_cell>
            <.table_cell>+8%</.table_cell>
          </.table_row>
          <.table_row selected={true}>
            <.table_cell>February</.table_cell>
            <.table_cell>$14,200</.table_cell>
            <.table_cell>+15%</.table_cell>
          </.table_row>
        </.table_body>
        <.table_footer>
          <.table_row>
            <.table_cell>Total</.table_cell>
            <.table_cell>$26,540</.table_cell>
            <.table_cell></...></.table_cell>
          </.table_row>
        </.table_footer>
      </.table>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # table/1
  # ---------------------------------------------------------------------------

  attr :class, :string, default: nil, doc: "Additional CSS classes for the outer wrapper"
  attr :rest, :global, doc: "HTML attributes forwarded to the outer div"
  slot :inner_block, required: true, doc: "Table content (thead, tbody, tfoot, caption)"

  @doc "Renders a scrollable table container."
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

  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to thead"
  slot :inner_block, required: true, doc: "Header rows"

  @doc "Renders the `<thead>` section."
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

  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to tbody (use phx-update for streams)"
  slot :inner_block, required: true, doc: "Data rows"

  @doc "Renders the `<tbody>` section. Supports LiveView Streams via `phx-update`."
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

  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to tfoot"
  slot :inner_block, required: true, doc: "Footer rows (totals, summaries)"

  @doc "Renders the `<tfoot>` section."
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

  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :selected, :boolean, default: false, doc: "Marks row as selected (adds data-state=selected)"
  attr :rest, :global, doc: "HTML attributes forwarded to tr"
  slot :inner_block, required: true, doc: "Row cells"

  @doc "Renders a `<tr>` row with optional selected state."
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

  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to th"
  slot :inner_block, required: true, doc: "Header cell content"

  @doc "Renders a `<th>` column header cell."
  def table_head(assigns) do
    ~H"""
    <th
      class={cn(["h-10 px-2 text-left align-middle font-medium text-muted-foreground", @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </th>
    """
  end

  # ---------------------------------------------------------------------------
  # table_cell/1
  # ---------------------------------------------------------------------------

  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to td"
  slot :inner_block, required: true, doc: "Cell content"

  @doc "Renders a `<td>` data cell."
  def table_cell(assigns) do
    ~H"""
    <td class={cn(["p-2 align-middle", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </td>
    """
  end

  # ---------------------------------------------------------------------------
  # table_caption/1
  # ---------------------------------------------------------------------------

  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to caption"
  slot :inner_block, required: true, doc: "Caption text"

  @doc "Renders a `<caption>` for accessible table labelling."
  def table_caption(assigns) do
    ~H"""
    <caption class={cn(["mt-4 text-sm text-muted-foreground", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </caption>
    """
  end
end
