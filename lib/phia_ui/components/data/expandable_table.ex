defmodule PhiaUi.Components.ExpandableTable do
  @moduledoc """
  Expandable table rows with collapsible detail panels.

  Pairs two components: `expandable_table_row/1` adds a chevron toggle in the
  first cell, and `expandable_table_detail/1` renders the collapsible detail
  row below it. All expand/collapse state lives in the LiveView.

  ## Sub-components

  | Function                   | HTML element | Purpose                                |
  |----------------------------|--------------|----------------------------------------|
  | `expandable_table_row/1`   | `<tr>`       | Row with expand/collapse chevron cell  |
  | `expandable_table_detail/1`| `<tr>`       | Hidden detail row shown when expanded  |

  ## Example

      defmodule MyAppWeb.OrdersLive do
        use MyAppWeb, :live_view

        def mount(_params, _session, socket) do
          {:ok, assign(socket, expanded_rows: MapSet.new(), orders: Orders.list())}
        end

        def handle_event("toggle_row", %{"id" => id}, socket) do
          expanded =
            if MapSet.member?(socket.assigns.expanded_rows, id),
              do: MapSet.delete(socket.assigns.expanded_rows, id),
              else: MapSet.put(socket.assigns.expanded_rows, id)

          {:noreply, assign(socket, expanded_rows: expanded)}
        end

        def render(assigns) do
          ~H\"\"\"
          <.table>
            <.table_body>
              <%= for order <- @orders do %>
                <.expandable_table_row
                  row_id={to_string(order.id)}
                  expanded={order.id in @expanded_rows}
                  on_toggle="toggle_row"
                >
                  <.table_cell>{order.number}</.table_cell>
                  <.table_cell>{order.customer}</.table_cell>
                  <.table_cell>{order.total}</.table_cell>
                </.expandable_table_row>
                <.expandable_table_detail
                  row_id={to_string(order.id)}
                  expanded={order.id in @expanded_rows}
                >
                  <p class="text-sm text-muted-foreground">Order details for {order.number}</p>
                </.expandable_table_detail>
              <% end %>
            </.table_body>
          </.table>
          \"\"\"
        end
      end

  ## Accessibility

  - The chevron `<button>` has `aria-expanded` set to `"true"` or `"false"`
  - `aria-controls` links the button to the detail row ID (`row-detail-{row_id}`)
  - The detail `<tr>` has a matching `id` for the `aria-controls` reference
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # expandable_table_row/1
  # ---------------------------------------------------------------------------

  attr(:expanded, :boolean,
    default: false,
    doc: "Whether the detail row is currently visible. Controls chevron rotation."
  )

  attr(:on_toggle, :string,
    default: "toggle_row",
    doc: """
    `phx-click` event fired when the expand/collapse button is clicked.
    Receives `phx-value-id` set to `row_id`. Toggle membership in your
    `expanded_rows` set in the handler.
    """
  )

  attr(:row_id, :string,
    required: true,
    doc: """
    Stable identifier for this row. Used for `phx-value-id` and to build the
    `aria-controls` / `id` pair with the matching `expandable_table_detail/1`.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the `<tr>`")

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<tr>` element (e.g. `id`)")

  slot(:inner_block,
    required: true,
    doc: """
    Table data cells (`table_cell/1` or `<td>`) for this row, **excluding**
    the expand toggle cell — that is prepended automatically.
    """
  )

  @doc """
  Renders a `<tr>` with an expand/collapse chevron prepended in the first cell.

  The chevron rotates 90° when `expanded={true}` via a Tailwind transition.
  All interaction state lives in the parent LiveView — this component is
  stateless.

  Pair with `expandable_table_detail/1` using the same `row_id`.

  ## Example

      <.expandable_table_row
        row_id={to_string(order.id)}
        expanded={order.id in @expanded_rows}
        on_toggle="toggle_row"
      >
        <.table_cell>{order.number}</.table_cell>
        <.table_cell>{order.total}</.table_cell>
      </.expandable_table_row>
  """
  def expandable_table_row(assigns) do
    ~H"""
    <tr
      class={cn(["border-b transition-colors hover:bg-muted/50", @class])}
      {@rest}
    >
      <td class="w-10 px-2 py-3">
        <button
          type="button"
          aria-expanded={to_string(@expanded)}
          aria-controls={"row-detail-#{@row_id}"}
          phx-click={@on_toggle}
          phx-value-id={@row_id}
          class="inline-flex h-7 w-7 items-center justify-center rounded transition-colors hover:bg-muted"
        >
          <.icon
            name="chevron-right"
            size={:sm}
            class={cn(["transition-transform duration-200", @expanded && "rotate-90"])}
          />
        </button>
      </td>
      {render_slot(@inner_block)}
    </tr>
    """
  end

  # ---------------------------------------------------------------------------
  # expandable_table_detail/1
  # ---------------------------------------------------------------------------

  attr(:row_id, :string,
    required: true,
    doc: """
    Must match the `row_id` of the paired `expandable_table_row/1`. Used to
    build the `id` attribute that `aria-controls` references.
    """
  )

  attr(:expanded, :boolean,
    default: false,
    doc: "When `false` (default) the row is hidden via `hidden` class. Controlled by LiveView."
  )

  attr(:col_span, :integer,
    default: 100,
    doc: "Number of columns this detail row spans. Default 100 spans all columns."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the `<tr>`")

  slot(:inner_block,
    required: true,
    doc: "Detail content — can be a nested table, description list, JSON viewer, etc."
  )

  @doc """
  Renders a collapsible detail row below its paired `expandable_table_row/1`.

  When `expanded={false}` the `hidden` class hides the row entirely. When
  `expanded={true}` the row is visible. The `id` matches the `aria-controls`
  reference in the toggle button.

  ## Example

      <.expandable_table_detail
        row_id={to_string(order.id)}
        expanded={order.id in @expanded_rows}
      >
        <div class="rounded-md bg-muted/30 p-4 text-sm">
          <p>Items: {length(order.items)}</p>
          <p>Shipping: {order.shipping_address}</p>
        </div>
      </.expandable_table_detail>
  """
  def expandable_table_detail(assigns) do
    ~H"""
    <tr
      id={"row-detail-#{@row_id}"}
      class={cn(["transition-all", !@expanded && "hidden", @class])}
    >
      <td colspan={@col_span} class="bg-muted/10 px-6 py-4">
        {render_slot(@inner_block)}
      </td>
    </tr>
    """
  end
end
