defmodule PhiaUi.Components.TableGroup do
  @moduledoc """
  Grouped table body with a sticky-ish group header row.

  Provides two components for visually grouping table rows under a labeled
  section header. Useful for categorised data (e.g. grouped by status, region,
  or date). Collapse/expand of groups is controlled by the LiveView.

  ## Sub-components

  | Function              | HTML element | Purpose                              |
  |-----------------------|--------------|--------------------------------------|
  | `table_group/1`       | `<tbody>`    | Wrapper that groups related rows     |
  | `table_group_header/1`| `<tr>`       | Full-width label row for the group   |

  ## Example

      <.table>
        <.table_header>
          <.table_row>
            <.table_head>Name</.table_head>
            <.table_head>Status</.table_head>
          </.table_row>
        </.table_header>

        <.table_group>
          <.table_group_header label="Active" count={3} />
          <.table_row :for={u <- @active_users}>
            <.table_cell>{u.name}</.table_cell>
            <.table_cell>Active</.table_cell>
          </.table_row>
        </.table_group>

        <.table_group>
          <.table_group_header label="Inactive" count={2} />
          <.table_row :for={u <- @inactive_users}>
            <.table_cell>{u.name}</.table_cell>
            <.table_cell>Inactive</.table_cell>
          </.table_row>
        </.table_group>
      </.table>

  ## Collapsible groups

  When you set `on_toggle` on `table_group_header/1`, a chevron button appears:

      <.table_group_header
        label="Advanced"
        count={length(@advanced_items)}
        on_toggle="toggle_group"
        row_id="advanced"
        collapsed={@collapsed_groups["advanced"]}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # table_group/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the `<tbody>`")

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<tbody>` element")

  slot(:inner_block,
    required: true,
    doc: "`table_group_header/1` followed by `table_row/1` children"
  )

  @doc """
  Renders a `<tbody>` that logically groups a set of rows.

  The `group` CSS class is applied so descendant selectors (`group-hover:*`)
  work for row-level interactions. Wrap multiple groups inside a `<.table>`
  to build a categorised table.

  ## Example

      <.table_group>
        <.table_group_header label="Q1 2026" count={5} />
        <.table_row :for={r <- @q1_rows}>
          <.table_cell>{r.name}</.table_cell>
        </.table_row>
      </.table_group>
  """
  def table_group(assigns) do
    ~H"""
    <tbody class={cn(["group", @class])} {@rest}>
      {render_slot(@inner_block)}
    </tbody>
    """
  end

  # ---------------------------------------------------------------------------
  # table_group_header/1
  # ---------------------------------------------------------------------------

  attr(:label, :string, required: true, doc: "Group label text displayed in the header row")

  attr(:col_span, :integer,
    default: 100,
    doc: "Number of columns this header spans. Default 100 spans all columns."
  )

  attr(:collapsed, :boolean,
    default: false,
    doc: "When `true`, the chevron points right (collapsed). Controlled by LiveView."
  )

  attr(:on_toggle, :string,
    default: nil,
    doc: """
    When set, renders a chevron `<button>` that fires this event on click.
    Receives `phx-value-id` set to `row_id`.
    """
  )

  attr(:row_id, :string,
    default: nil,
    doc: "Group identifier sent as `phx-value-id` when the collapse toggle is clicked"
  )

  attr(:count, :integer,
    default: nil,
    doc: "Optional item count badge displayed to the right of the label"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the `<tr>`")

  @doc """
  Renders a full-width group header row inside a `table_group/1`.

  The header uses a subtle `bg-muted/30` background, uppercase letter-spacing,
  and small font to visually distinguish it from data rows without being heavy.

  When `on_toggle` is provided, a chevron button appears on the left. The
  chevron points right (collapsed) when `collapsed={true}` and down when
  `collapsed={false}`.

  ## Example

      <%# Static header with count %>
      <.table_group_header label="Active" count={@active_count} />

      <%# Collapsible header %>
      <.table_group_header
        label="Advanced Settings"
        on_toggle="toggle_group"
        row_id="advanced"
        collapsed={@collapsed_groups["advanced"]}
      />
  """
  def table_group_header(assigns) do
    ~H"""
    <tr class={@class}>
      <td colspan={@col_span} class="p-0">
        <div class="flex items-center gap-2 bg-muted/30 px-4 py-2 text-xs font-semibold uppercase tracking-wider text-muted-foreground">
          <button
            :if={@on_toggle}
            type="button"
            phx-click={@on_toggle}
            phx-value-id={@row_id}
            class="inline-flex items-center justify-center transition-colors hover:text-foreground"
            aria-label={if @collapsed, do: "Expand group", else: "Collapse group"}
          >
            <.icon
              name="chevron-down"
              size={:xs}
              class={cn(["transition-transform duration-200", @collapsed && "-rotate-90"])}
            />
          </button>
          <span>{@label}</span>
          <span
            :if={@count}
            class="rounded-full bg-muted px-1.5 py-0.5 text-[10px] font-normal leading-none"
          >
            {@count}
          </span>
        </div>
      </td>
    </tr>
    """
  end
end
