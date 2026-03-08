defmodule PhiaUi.Components.Data.ChartLayer do
  @moduledoc """
  SVG grouping component with z-index convention for chart layering.

  Inspired by Recharts' z-index layering — wraps chart elements in `<g>` groups
  with documentary z-values. SVG paints in DOM order, so the parent must sort
  layers by z-value before rendering.

  ## Standard z-values (Recharts convention)
  - grid: -100
  - area: 100
  - bar: 300
  - line: 400
  - axis: 500
  - scatter: 600
  - label: 2000

  ## Examples

      <.chart_layer z={-100}>
        <%!-- grid lines --%>
      </.chart_layer>

      <.chart_layer z={400}>
        <%!-- line series --%>
      </.chart_layer>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :z, :integer, default: 0, doc: "Documentary z-index value. SVG paints in DOM order."
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def chart_layer(assigns) do
    ~H"""
    <g class={cn([@class])} data-z={@z} {@rest}>
      {render_slot(@inner_block)}
    </g>
    """
  end
end
