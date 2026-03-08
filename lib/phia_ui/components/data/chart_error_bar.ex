defmodule PhiaUi.Components.Data.ChartErrorBar do
  @moduledoc """
  Error bar component for chart uncertainty visualization.

  Maps to Highcharts' errorbar series type. Renders vertical I-beam indicators
  (line + horizontal caps) showing error ranges at each data point.

  ## Examples

      <.chart_error_bar
        data={[
          %{px: 100, py_low: 50, py_high: 150},
          %{px: 200, py_low: 80, py_high: 180}
        ]}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :data, :list,
    required: true,
    doc: "List of `%{px, py_low, py_high}` error bar data points."

  attr :cap_width, :integer, default: 8, doc: "Width of the horizontal caps in pixels."
  attr :color, :string, default: "currentColor", doc: "Error bar color."
  attr :stroke_width, :any, default: 1.5, doc: "Line stroke width."
  attr :animate, :boolean, default: true, doc: "Enable pop-in animation."
  attr :animation_duration, :integer, default: 600, doc: "Animation duration in ms."
  attr :class, :string, default: nil

  def chart_error_bar(assigns) do
    bars =
      assigns.data
      |> Enum.with_index()
      |> Enum.map(fn {point, i} ->
        half_cap = assigns.cap_width / 2

        %{
          px: point.px,
          py_low: point.py_low,
          py_high: point.py_high,
          cap_x1: point.px - half_cap,
          cap_x2: point.px + half_cap,
          anim_style:
            if(assigns.animate,
              do: "transform-origin: center; animation: phia-error-bar-pop #{assigns.animation_duration}ms ease-out #{i * 60}ms both",
              else: ""
            )
        }
      end)

    assigns = assign(assigns, :bars, bars)

    ~H"""
    <g class={cn(["phia-error-bars", @class])}>
      <g :for={bar <- @bars} style={bar.anim_style}>
        <%!-- Vertical line --%>
        <line
          x1={bar.px}
          y1={bar.py_low}
          x2={bar.px}
          y2={bar.py_high}
          stroke={@color}
          stroke-width={@stroke_width}
        />
        <%!-- Top cap --%>
        <line
          x1={bar.cap_x1}
          y1={bar.py_high}
          x2={bar.cap_x2}
          y2={bar.py_high}
          stroke={@color}
          stroke-width={@stroke_width}
        />
        <%!-- Bottom cap --%>
        <line
          x1={bar.cap_x1}
          y1={bar.py_low}
          x2={bar.cap_x2}
          y2={bar.py_low}
          stroke={@color}
          stroke-width={@stroke_width}
        />
      </g>
    </g>
    """
  end
end
