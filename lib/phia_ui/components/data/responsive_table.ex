defmodule PhiaUi.Components.ResponsiveTable do
  @moduledoc """
  Horizontally scrollable table with responsive `data-label` field metadata.

  On small screens the table scrolls horizontally inside a constrained viewport
  without layout breakage. `responsive_table_field/1` stores the column label
  in `data-label` — useful for CSS-driven mobile card views or assistive tech.

  ## Sub-components

  | Function                   | HTML element | Purpose                               |
  |----------------------------|--------------|---------------------------------------|
  | `responsive_table/1`       | `<div><table>`| Scrollable wrapper + table structure |
  | `responsive_table_row/1`   | `<tr>`       | Standard table row                    |
  | `responsive_table_field/1` | `<td>`       | Cell with accessible `data-label` attr|

  ## Example

      <.responsive_table>
        <:header>
          <.table_row>
            <.table_head>Name</.table_head>
            <.table_head>Email</.table_head>
            <.table_head>Role</.table_head>
            <.table_head>Joined</.table_head>
          </.table_row>
        </:header>

        <.responsive_table_row :for={user <- @users}>
          <.responsive_table_field label="Name">
            <span class="font-medium">{user.name}</span>
          </.responsive_table_field>
          <.responsive_table_field label="Email">{user.email}</.responsive_table_field>
          <.responsive_table_field label="Role">
            <.badge variant={:secondary}>{user.role}</.badge>
          </.responsive_table_field>
          <.responsive_table_field label="Joined">{user.inserted_at}</.responsive_table_field>
        </.responsive_table_row>
      </.responsive_table>

  ## Responsive CSS card view (optional)

  To transform the table into a card stack on mobile, add these utilities to
  your CSS:

      @media (max-width: 767px) {
        .phia-responsive-table thead { display: none; }
        .phia-responsive-table tr { display: block; border: 1px solid; border-radius: 0.5rem; margin-bottom: 0.75rem; }
        .phia-responsive-table td { display: flex; justify-content: space-between; }
        .phia-responsive-table td::before { content: attr(data-label); font-weight: 500; }
      }

  Then add `class="phia-responsive-table"` to `responsive_table/1`.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # responsive_table/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the outer wrapper div")

  attr(:rest, :global, doc: "HTML attributes forwarded to the outer `<div>` (e.g. `class`)")

  slot(:header,
    required: true,
    doc: "Column header row — typically one `table_row/1` with `table_head/1` cells"
  )

  slot(:inner_block,
    required: true,
    doc: "`responsive_table_row/1` children"
  )

  @doc """
  Renders a horizontally scrollable table with header and body slots.

  The outer `<div>` uses `overflow-x-auto` to enable horizontal scrolling on
  narrow viewports without breaking the page layout.

  ## Example

      <.responsive_table>
        <:header>
          <.table_row>
            <.table_head>Name</.table_head>
            <.table_head>Status</.table_head>
          </.table_row>
        </:header>
        <.responsive_table_row :for={item <- @items}>
          <.responsive_table_field label="Name">{item.name}</.responsive_table_field>
          <.responsive_table_field label="Status">{item.status}</.responsive_table_field>
        </.responsive_table_row>
      </.responsive_table>
  """
  def responsive_table(assigns) do
    ~H"""
    <div class={cn(["w-full overflow-x-auto", @class])} {@rest}>
      <table class="w-full caption-bottom text-sm">
        <thead class="[&_tr]:border-b">
          {render_slot(@header)}
        </thead>
        <tbody class="[&_tr:last-child]:border-0">
          {render_slot(@inner_block)}
        </tbody>
      </table>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # responsive_table_row/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the `<tr>`")

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<tr>` (e.g. `id` for streams)")

  slot(:inner_block,
    required: true,
    doc: "`responsive_table_field/1` children"
  )

  @doc """
  Renders a `<tr>` data row inside `responsive_table/1`.

  ## Example

      <.responsive_table_row id={dom_id}>
        <.responsive_table_field label="Name">{user.name}</.responsive_table_field>
        <.responsive_table_field label="Email">{user.email}</.responsive_table_field>
      </.responsive_table_row>
  """
  def responsive_table_row(assigns) do
    ~H"""
    <tr
      class={cn(["border-b transition-colors hover:bg-muted/50", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </tr>
    """
  end

  # ---------------------------------------------------------------------------
  # responsive_table_field/1
  # ---------------------------------------------------------------------------

  attr(:label, :string,
    required: true,
    doc: """
    Column label stored as `data-label` on the `<td>`. Used by CSS to render
    labels in mobile card views via `content: attr(data-label)`.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the `<td>`")

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<td>` element")

  slot(:inner_block,
    required: true,
    doc: "Cell content — plain text, formatted values, badges, etc."
  )

  @doc """
  Renders a `<td>` with a `data-label` attribute for responsive CSS card views.

  Standard padding (`px-4 py-3`) and `align-middle` match the base `table_cell`
  and `data_grid_cell` defaults for visual consistency.

  ## Example

      <.responsive_table_field label="Revenue">
        <span class="font-mono tabular-nums">$12,340</span>
      </.responsive_table_field>
  """
  def responsive_table_field(assigns) do
    ~H"""
    <td
      data-label={@label}
      class={cn(["px-4 py-3 align-middle", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </td>
    """
  end
end
