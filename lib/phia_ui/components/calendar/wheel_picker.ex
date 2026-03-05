defmodule PhiaUi.Components.WheelPicker do
  @moduledoc """
  Drum roll / iOS-style scroll wheel picker component.

  Each column shows 5 visible items at a time: the center item is the selected
  value (large, bold, full opacity). Adjacent rows are progressively smaller and
  more transparent, and gradient overlays at the top and bottom create the
  classic drum-wheel illusion. Zero JavaScript — all state is managed server-side.

  ## Column map keys

  Each entry in `columns` must be a map with:

  | Key              | Type    | Description                          |
  |------------------|---------|--------------------------------------|
  | `:name`          | string  | Column identifier (used in events)   |
  | `:items`         | list    | All selectable string values         |
  | `:selected`      | string  | Currently selected value             |

  Clicking a non-selected visible item fires the `on_change` event with
  `phx-value-column` (column name) and `phx-value-value` (new value).

  ## Examples

      <%!-- Single-column month picker --%>
      <.wheel_picker
        columns={[%{name: "month", items: @months, selected: @month}]}
        on_change="month_changed"
      />

      <%!-- Multi-column date picker --%>
      <.wheel_picker
        columns={[
          %{name: "month", items: @months, selected: @month},
          %{name: "day",   items: @days,   selected: @day},
          %{name: "year",  items: @years,  selected: @year}
        ]}
        on_change="date_changed"
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  @doc """
  Renders an iOS-style drum-roll wheel picker.

  ## Attributes

  * `columns` (required) — list of column maps, each with `:name`, `:items`,
    and `:selected` keys.
  * `on_change` — LiveView event name fired when a non-selected item is clicked.
    The event receives `phx-value-column` and `phx-value-value`.
  * `separator` — when `true` (default) a vertical divider line separates
    adjacent columns via Tailwind's `divide-x` utility.
  * `class` — additional CSS classes merged onto the wrapper element.
  * `rest` — any other HTML attributes forwarded to the root `<div>`.
  """

  attr :columns, :list, required: true,
    doc: "List of column maps (%{name:, items:, selected:})"

  attr :on_change, :string, default: nil,
    doc: "LiveView event name for column value changes"

  attr :separator, :boolean, default: true,
    doc: "Show divider line between columns (divide-x)"

  attr :class, :string, default: nil,
    doc: "Additional CSS classes applied to the wrapper"

  attr :rest, :global,
    doc: "HTML attributes forwarded to the root element"

  def wheel_picker(assigns) do
    ~H"""
    <div
      class={cn([
        "flex items-stretch rounded-xl border border-border bg-background overflow-hidden",
        @separator && "divide-x divide-border",
        @class
      ])}
      {@rest}
    >
      <div :for={col <- @columns} class="relative flex flex-col items-center w-32 overflow-hidden" style="height: 180px;">
        <%!-- Top gradient overlay --%>
        <div class="absolute inset-x-0 top-0 h-16 bg-gradient-to-b from-background to-transparent z-10 pointer-events-none" />
        <%!-- Bottom gradient overlay --%>
        <div class="absolute inset-x-0 bottom-0 h-16 bg-gradient-to-t from-background to-transparent z-10 pointer-events-none" />
        <%!-- Center highlight bar --%>
        <div class="absolute inset-x-2 top-1/2 -translate-y-1/2 h-10 bg-muted/60 rounded-lg z-0" />
        <%!-- Visible items --%>
        <div class="relative z-10 flex flex-col items-center justify-center w-full h-full">
          <div
            :for={item <- visible_items(col.items, col.selected)}
            class={item_class(item.offset)}
            phx-click={if item.offset != 0 && @on_change, do: @on_change}
            phx-value-column={if item.offset != 0 && @on_change, do: col.name}
            phx-value-value={if item.offset != 0 && @on_change, do: item.value}
          >
            {item.value}
          </div>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  @doc false
  defp visible_items(items, selected) do
    idx = Enum.find_index(items, &(&1 == selected)) || 0
    total = length(items)

    Enum.map(-2..2, fn offset ->
      real_idx = rem(idx + offset + total, total)

      %{
        value: Enum.at(items, real_idx),
        offset: offset
      }
    end)
  end

  @doc false
  defp item_class(0),
    do:
      "text-lg font-bold text-foreground opacity-100 cursor-default py-2 text-center w-full"

  defp item_class(off) when off in [-1, 1],
    do:
      "text-sm text-muted-foreground opacity-70 cursor-pointer hover:opacity-90 py-1 text-center w-full"

  defp item_class(_),
    do:
      "text-xs text-muted-foreground opacity-40 cursor-pointer hover:opacity-60 py-1 text-center w-full"
end
