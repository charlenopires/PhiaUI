defmodule PhiaUi.Components.Data.ChartTooltip do
  @moduledoc """
  Pre-positioned tooltip shell rendered as `<foreignObject>` inside SVG — pure SVG, zero JS.

  Provides a styled container for tooltip content that can be positioned
  at any point within a chart SVG. Content is passed via the inner block slot.

  ## Examples

      <.chart_tooltip x={100} y={50}>
        <span>Revenue: $350</span>
      </.chart_tooltip>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartTheme

  attr :x, :any, required: true, doc: "X position in SVG coordinates."
  attr :y, :any, required: true, doc: "Y position in SVG coordinates."
  attr :visible, :boolean, default: true, doc: "Whether the tooltip is visible."
  attr :width, :integer, default: 120, doc: "Tooltip width in px."
  attr :height, :integer, default: 40, doc: "Tooltip height in px."
  attr :theme, :map, default: %{}, doc: "Chart theme overrides."
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  def chart_tooltip(assigns) do
    theme = ChartTheme.merge(assigns.theme)

    # Offset based on tooltip dimensions to center above the point
    fo_x = assigns.x - assigns.width / 2
    fo_y = assigns.y - assigns.height - 4

    assigns =
      assigns
      |> assign(:fo_x, fo_x)
      |> assign(:fo_y, fo_y)
      |> assign(:tooltip_class, cn([
        "rounded-md px-2 py-1 text-xs shadow-md",
        theme.tooltip.bg_class,
        theme.tooltip.text_class,
        theme.tooltip.border_class,
        assigns.class
      ]))

    ~H"""
    <foreignObject
      :if={@visible}
      x={@fo_x}
      y={@fo_y}
      width={@width}
      height={@height}
      {@rest}
    >
      <div xmlns="http://www.w3.org/1999/xhtml" class={@tooltip_class}>
        {render_slot(@inner_block)}
      </div>
    </foreignObject>
    """
  end
end
