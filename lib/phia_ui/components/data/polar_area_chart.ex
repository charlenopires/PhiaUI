defmodule PhiaUi.Components.PolarAreaChart do
  @moduledoc """
  Polar area chart — pure SVG, zero JS.

  Each data point occupies an equal angular slice. The radius of each slice
  is proportional to its value. Based on Chart.js PolarAreaController pattern.

  ## Examples

      <.polar_area_chart data={[
        %{label: "Speed", value: 80},
        %{label: "Power", value: 65},
        %{label: "Endurance", value: 90},
        %{label: "Agility", value: 75},
        %{label: "Recovery", value: 70}
      ]} />
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]
  alias PhiaUi.Components.Data.ChartHelpers

  @cx 150.0
  @cy 150.0
  @r_max 120.0
  @vw 360
  @vh 320

  attr :data, :list, required: true, doc: "List of `%{label, value}` (and optional `:color`)."
  attr :colors, :list, default: [], doc: "Override default palette."
  attr :max, :any, default: nil, doc: "Maximum value for radius scaling. Auto-detected if nil."
  attr :spacing, :integer, default: 2, doc: "Gap in pixels between slices."
  attr :show_grid, :boolean, default: true, doc: "Show concentric circle grid."
  attr :show_labels, :boolean, default: true, doc: "Show axis labels."
  attr :animate, :boolean, default: true
  attr :animation_duration, :integer, default: 600
  attr :class, :string, default: nil
  attr :rest, :global

  def polar_area_chart(assigns) do
    data = assigns.data
    n = length(data)
    max_val = assigns.max || if(data == [], do: 100, else: Enum.max_by(data, & &1.value).value)
    max_val = max(max_val, 1)

    # Equal-angle slices
    slice_angle = if n > 0, do: 2 * :math.pi() / n, else: 0
    # Start from top
    start_angle = -:math.pi() / 2

    # Angular gap
    angle_gap = if assigns.spacing > 0 and @r_max > 0, do: assigns.spacing / @r_max, else: 0.0

    slices =
      data
      |> Enum.with_index()
      |> Enum.map(fn {item, i} ->
        a = start_angle + i * slice_angle + angle_gap / 2
        b = start_angle + (i + 1) * slice_angle - angle_gap / 2

        radius = item.value / max_val * @r_max

        path = polar_arc_path(@cx, @cy, radius, a, b)
        color = Map.get(item, :color) || ChartHelpers.chart_color(i, assigns.colors)

        %{
          path: path,
          color: color,
          label: item.label,
          value: item.value,
          delay_ms: i * 60
        }
      end)

    # Concentric grid circles (25%, 50%, 75%, 100%)
    grid_levels = [0.25, 0.5, 0.75, 1.0]

    grid_circles =
      Enum.map(grid_levels, fn level ->
        %{r: Float.round(@r_max * level, 2), label: round(max_val * level)}
      end)

    # Axis labels positioned beyond the edge
    label_r = @r_max + 16

    axis_labels =
      data
      |> Enum.with_index()
      |> Enum.map(fn {item, i} ->
        mid_angle = start_angle + (i + 0.5) * slice_angle
        x = @cx + label_r * :math.cos(mid_angle)
        y = @cy + label_r * :math.sin(mid_angle)

        anchor =
          cond do
            :math.cos(mid_angle) > 0.1 -> "start"
            :math.cos(mid_angle) < -0.1 -> "end"
            true -> "middle"
          end

        %{label: item.label, x: Float.round(x, 2), y: Float.round(y, 2), anchor: anchor}
      end)

    assigns =
      assigns
      |> assign(:slices, slices)
      |> assign(:grid_circles, grid_circles)
      |> assign(:axis_labels, axis_labels)
      |> assign(:cx, @cx)
      |> assign(:cy, @cy)
      |> assign(:viewbox, "0 0 #{@vw} #{@vh}")

    ~H"""
    <div
      class={cn(["w-full", if(@animate, do: "phia-chart-animate", else: ""), @class])}
      {@rest}
    >
      <svg viewBox={@viewbox} aria-hidden="true" class="w-full h-full overflow-visible">
        <%!-- Concentric grid circles --%>
        <g :if={@show_grid}>
          <circle
            :for={g <- @grid_circles}
            cx={@cx}
            cy={@cy}
            r={g.r}
            fill="none"
            stroke="currentColor"
            stroke-width="0.5"
            class="text-border"
          />
        </g>

        <%!-- Grid labels --%>
        <g :if={@show_grid && @show_labels}>
          <text
            :for={g <- @grid_circles}
            x={@cx + 4}
            y={@cy - g.r + 4}
            font-size="8"
            class="fill-muted-foreground"
          >{g.label}</text>
        </g>

        <%!-- Polar area slices --%>
        <path
          :for={slice <- @slices}
          d={slice.path}
          fill={slice.color}
          fill-opacity="0.75"
          stroke={slice.color}
          stroke-width="1"
          style={
            if @animate do
              "transform-box: fill-box; transform-origin: center; animation: phia-dot-pop #{@animation_duration}ms ease-out #{slice.delay_ms}ms both"
            else
              ""
            end
          }
        />

        <%!-- Axis labels --%>
        <g :if={@show_labels}>
          <text
            :for={al <- @axis_labels}
            x={al.x}
            y={al.y}
            text-anchor={al.anchor}
            dominant-baseline="middle"
            font-size="9"
            class="fill-muted-foreground"
          >{al.label}</text>
        </g>
      </svg>
    </div>
    """
  end

  # Polar arc path — wedge from center with variable radius
  defp polar_arc_path(cx, cy, r, start_angle, end_angle) do
    x1 = cx + r * :math.cos(start_angle)
    y1 = cy + r * :math.sin(start_angle)
    x2 = cx + r * :math.cos(end_angle)
    y2 = cy + r * :math.sin(end_angle)
    large = if end_angle - start_angle > :math.pi(), do: 1, else: 0

    [
      "M #{f(cx)} #{f(cy)}",
      "L #{f(x1)} #{f(y1)}",
      "A #{f(r)} #{f(r)} 0 #{large} 1 #{f(x2)} #{f(y2)}",
      "Z"
    ]
    |> Enum.join(" ")
  end

  defp f(v), do: Float.round(v * 1.0, 2)
end
