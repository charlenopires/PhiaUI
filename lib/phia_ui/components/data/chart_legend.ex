defmodule PhiaUi.Components.Data.ChartLegend do
  @moduledoc """
  Composable chart legend components.

  Renders as HTML (not SVG) — place below or beside the chart SVG.

  ## Examples

      <.chart_legend
        items={[
          %{label: "Revenue", color: "oklch(0.60 0.20 240)"},
          %{label: "Cost", color: "oklch(0.65 0.22 30)"}
        ]}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # Chart Legend
  # ---------------------------------------------------------------------------

  @doc """
  Renders a legend with color swatches and labels.

  ## Attrs
  - `items` — list of `%{label, color}` or `%{label, color, shape}` maps
  - `position` — layout direction
  - `class` — additional CSS classes
  """
  attr :items, :list, required: true, doc: "List of `%{label, color}` maps."

  attr :position, :atom,
    default: :bottom,
    values: [:top, :bottom, :left, :right],
    doc: "Legend position determines layout direction."

  attr :class, :string, default: nil

  def chart_legend(assigns) do
    direction =
      case assigns.position do
        pos when pos in [:top, :bottom] -> "flex-row flex-wrap"
        _ -> "flex-col"
      end

    assigns = assign(assigns, :direction, direction)

    ~H"""
    <div
      class={cn(["flex gap-3 text-xs", @direction, @class])}
      role="list"
      aria-label="Chart legend"
    >
      <.chart_legend_item
        :for={item <- @items}
        label={item.label}
        color={item.color}
        shape={Map.get(item, :shape, :square)}
      />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Chart Legend Item
  # ---------------------------------------------------------------------------

  @doc """
  Individual legend entry with swatch and label.
  """
  attr :label, :string, required: true
  attr :color, :string, required: true

  attr :shape, :atom,
    default: :square,
    values: [:square, :circle, :line],
    doc: "Swatch shape."

  attr :class, :string, default: nil

  def chart_legend_item(assigns) do
    ~H"""
    <div class={cn(["flex items-center gap-1.5", @class])} role="listitem">
      <span
        :if={@shape == :square}
        class="inline-block size-2.5 rounded-sm shrink-0"
        style={"background-color: #{@color}"}
      />
      <span
        :if={@shape == :circle}
        class="inline-block size-2.5 rounded-full shrink-0"
        style={"background-color: #{@color}"}
      />
      <span
        :if={@shape == :line}
        class="inline-block w-3 h-0.5 rounded-full shrink-0"
        style={"background-color: #{@color}"}
      />
      <span class="text-muted-foreground">{@label}</span>
    </div>
    """
  end
end
