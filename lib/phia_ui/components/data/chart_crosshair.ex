defmodule PhiaUi.Components.Data.ChartCrosshair do
  @moduledoc """
  Crosshair component for chart hover interaction.

  Maps to Highcharts' crosshair with snap-to-point behavior.
  Renders SVG guide lines that follow the pointer position,
  optionally snapping to the nearest data point.

  ## Examples

      <.chart_crosshair
        id="my-crosshair"
        type={:x}
        chart_area={%{x: 44, y: 16, width: 340, height: 244}}
        points_json={Jason.encode!(points)}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :id, :string, required: true, doc: "Unique identifier (required for hook)."

  attr :type, :atom,
    default: :x,
    values: [:x, :y, :both],
    doc: "Crosshair type: vertical line (:x), horizontal (:y), or both."

  attr :snap, :boolean, default: true, doc: "Snap crosshair to nearest data point."

  attr :chart_area, :map,
    required: true,
    doc: "Chart area bounds: `%{x, y, width, height}`."

  attr :points_json, :string,
    default: "[]",
    doc: "JSON array of `{px, py, label, value}` points for snap-to-point."

  attr :color, :string, default: "currentColor", doc: "Crosshair line color."
  attr :show_label, :boolean, default: false, doc: "Show value label at crosshair position."
  attr :class, :string, default: nil

  def chart_crosshair(assigns) do
    ~H"""
    <g
      id={@id}
      class={cn(["phia-crosshair", @class])}
      phx-hook="PhiaChartCrosshair"
      data-type={@type}
      data-snap={to_string(@snap)}
      data-area-x={@chart_area.x}
      data-area-y={@chart_area.y}
      data-area-w={@chart_area.width}
      data-area-h={@chart_area.height}
      data-points={@points_json}
      data-color={@color}
      data-show-label={to_string(@show_label)}
    >
      <%!-- Vertical crosshair line --%>
      <line
        :if={@type in [:x, :both]}
        data-role="crosshair-x"
        x1={@chart_area.x}
        y1={@chart_area.y}
        x2={@chart_area.x}
        y2={@chart_area.y + @chart_area.height}
        stroke={@color}
        stroke-width="1"
        stroke-dasharray="4 2"
        opacity="0"
        style="pointer-events: none; animation: phia-crosshair-show 150ms ease-out"
      />
      <%!-- Horizontal crosshair line --%>
      <line
        :if={@type in [:y, :both]}
        data-role="crosshair-y"
        x1={@chart_area.x}
        y1={@chart_area.y}
        x2={@chart_area.x + @chart_area.width}
        y2={@chart_area.y}
        stroke={@color}
        stroke-width="1"
        stroke-dasharray="4 2"
        opacity="0"
        style="pointer-events: none; animation: phia-crosshair-show 150ms ease-out"
      />
      <%!-- Snap point indicator --%>
      <circle
        :if={@snap}
        data-role="crosshair-dot"
        cx="0"
        cy="0"
        r="4"
        fill={@color}
        opacity="0"
        style="pointer-events: none"
      />
      <%!-- Invisible overlay rect to capture pointer events --%>
      <rect
        data-role="crosshair-overlay"
        x={@chart_area.x}
        y={@chart_area.y}
        width={@chart_area.width}
        height={@chart_area.height}
        fill="transparent"
        style="cursor: crosshair"
      />
    </g>
    """
  end
end
