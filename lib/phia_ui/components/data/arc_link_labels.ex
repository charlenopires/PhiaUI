defmodule PhiaUi.Components.Data.ArcLinkLabels do
  @moduledoc """
  Leader lines from pie/donut slices to external labels — pure SVG, zero JS.

  Inspired by Nivo's arcLinkLabels. For each slice, renders a 3-segment
  polyline (radial → elbow → horizontal) with a text label at the end.

  Designed to be composed inside pie/donut chart SVG.

  ## Examples

      <.arc_link_labels slices={[
        %{mid_angle: -1.57, outer_radius: 90, label: "Direct", color: "oklch(0.60 0.20 240)", cx: 110, cy: 110}
      ]} />
  """

  use Phoenix.Component

  alias PhiaUi.Components.Data.ChartMathHelpers

  attr :slices, :list, required: true,
    doc: "List of `%{mid_angle, outer_radius, label, color, cx, cy}` for each slice."
  attr :offset, :integer, default: 12, doc: "Radial offset from outer edge in px."
  attr :straight_length, :integer, default: 16, doc: "Horizontal line length in px."
  attr :font_size, :string, default: "9"
  attr :class, :string, default: nil
  attr :rest, :global

  def arc_link_labels(assigns) do
    labels =
      Enum.map(assigns.slices, fn slice ->
        r = slice.outer_radius + assigns.offset
        {px, py} = ChartMathHelpers.polar_to_cartesian(r, slice.mid_angle, slice.cx, slice.cy)

        # Determine direction (left or right of center)
        side = if :math.cos(slice.mid_angle) >= 0, do: :right, else: :left
        h_dir = if side == :right, do: 1, else: -1
        end_x = px + h_dir * assigns.straight_length
        anchor = if side == :right, do: "start", else: "end"

        %{
          polyline: "#{f(px)},#{f(py)} #{f(px + h_dir * 4)},#{f(py)} #{f(end_x)},#{f(py)}",
          label_x: end_x + h_dir * 3,
          label_y: py,
          label: slice.label,
          color: slice.color,
          anchor: anchor
        }
      end)

    assigns = assign(assigns, :labels, labels)

    ~H"""
    <g {@rest}>
      <g :for={lbl <- @labels}>
        <polyline
          points={lbl.polyline}
          fill="none"
          stroke={lbl.color}
          stroke-width="1"
          stroke-opacity="0.6"
        />
        <text
          x={lbl.label_x}
          y={lbl.label_y}
          text-anchor={lbl.anchor}
          dominant-baseline="middle"
          font-size={@font_size}
          class={@class || "fill-muted-foreground"}
        >{lbl.label}</text>
      </g>
    </g>
    """
  end

  defp f(v), do: Float.round(v * 1.0, 2)
end
