defmodule PhiaUi.Components.RadarChart do
  @moduledoc """
  Spider / radar chart — pure SVG, zero JS.

  Plots multi-dimensional data on a polar grid. Each series is rendered as a
  filled polygon that fades in on entrance.

  ## Examples

      <.radar_chart
        data={[
          %{axis: "Speed",     value: 80},
          %{axis: "Power",     value: 65},
          %{axis: "Endurance", value: 90},
          %{axis: "Agility",   value: 75},
          %{axis: "Recovery",  value: 70}
        ]}
      />

      <.radar_chart
        series={[
          %{name: "2023", data: [%{axis: "Q1", value: 80}, %{axis: "Q2", value: 60}]},
          %{name: "2024", data: [%{axis: "Q1", value: 90}, %{axis: "Q2", value: 75}]}
        ]}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers

  @cx 150.0
  @cy 140.0
  @r 110.0
  @vw 320
  @vh 290

  attr :data, :list,
    default: [],
    doc: "Single-series: `[%{axis, value}]`."

  attr :series, :list,
    default: [],
    doc: "Multi-series: `[%{name, data: [%{axis, value}]}]`."

  attr :max, :any, default: 100, doc: "Maximum axis value (integer or float)."
  attr :colors, :list, default: [], doc: "Override default palette."
  attr :show_grid, :boolean, default: true, doc: "Show concentric polygon grid."
  attr :animate, :boolean, default: true
  attr :animation_duration, :integer, default: 700
  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def radar_chart(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"
    series =
      cond do
        assigns.series != [] -> assigns.series
        assigns.data != [] -> [%{name: "Series 1", data: assigns.data}]
        true -> []
      end

    axes =
      case series do
        [] -> []
        [first | _] -> Enum.map(first.data, & &1.axis)
      end

    n = length(axes)

    # Axis angles: start from top (-pi/2), evenly spaced
    angles =
      Enum.map(0..(max(n - 1, 0)), fn i ->
        -:math.pi() / 2 + i / max(n, 1) * 2 * :math.pi()
      end)

    # Grid levels (20%, 40%, 60%, 80%, 100%)
    grid_levels = [0.2, 0.4, 0.6, 0.8, 1.0]

    grid_polygons =
      Enum.map(grid_levels, fn level ->
        points =
          angles
          |> Enum.map(fn a ->
            x = @cx + @r * level * :math.cos(a)
            y = @cy + @r * level * :math.sin(a)
            "#{Float.round(x, 2)},#{Float.round(y, 2)}"
          end)
          |> Enum.join(" ")

        points
      end)

    # Axis lines (from center to edge)
    axis_lines =
      Enum.map(angles, fn a ->
        %{
          x1: @cx,
          y1: @cy,
          x2: Float.round(@cx + @r * :math.cos(a), 2),
          y2: Float.round(@cy + @r * :math.sin(a), 2)
        }
      end)

    # Axis labels (slightly beyond edge)
    label_r = @r + 14

    axis_labels =
      axes
      |> Enum.with_index()
      |> Enum.map(fn {ax, i} ->
        a = Enum.at(angles, i)
        x = @cx + label_r * :math.cos(a)
        y = @cy + label_r * :math.sin(a)

        anchor =
          cond do
            :math.cos(a) > 0.1 -> "start"
            :math.cos(a) < -0.1 -> "end"
            true -> "middle"
          end

        %{label: ax, x: Float.round(x, 2), y: Float.round(y, 2), anchor: anchor}
      end)

    # Series polygons
    series_polygons =
      series
      |> Enum.with_index()
      |> Enum.map(fn {s, si} ->
        points =
          s.data
          |> Enum.with_index()
          |> Enum.map(fn {item, i} ->
            a = Enum.at(angles, i, 0.0)
            ratio = item.value / max(assigns.max, 1)
            x = @cx + @r * ratio * :math.cos(a)
            y = @cy + @r * ratio * :math.sin(a)
            "#{Float.round(x, 2)},#{Float.round(y, 2)}"
          end)
          |> Enum.join(" ")

        %{
          points: points,
          color: ChartHelpers.chart_color(si, assigns.colors),
          delay_ms: si * 120
        }
      end)

    assigns =
      assigns
      |> assign(:series_polygons, series_polygons)
      |> assign(:grid_polygons, grid_polygons)
      |> assign(:axis_lines, axis_lines)
      |> assign(:axis_labels, axis_labels)
      |> assign(:viewbox, "0 0 #{@vw} #{@vh}")
      |> assign(:chart_id, chart_id)

    ~H"""
    <div
      class={cn(["w-full", if(@animate, do: "phia-chart-animate", else: ""), @class])}
      {@rest}
    >
      <div :if={@title} class="mb-2">
        <h3 class="text-sm font-medium text-foreground">{@title}</h3>
        <p :if={@description} class="text-xs text-muted-foreground">{@description}</p>
      </div>
      <svg
        viewBox={@viewbox}
        role={if(@title, do: "img", else: nil)}
        aria-label={@title}
        aria-describedby={if(@description, do: "#{@chart_id}-desc", else: nil)}
        aria-hidden={if(@title, do: nil, else: "true")}
        class="w-full h-full overflow-visible"
      >
        <title :if={@title}>{@title}</title>
        <desc :if={@description} id={"#{@chart_id}-desc"}>{@description}</desc>
        <%!-- Grid polygons --%>
        <g :if={@show_grid}>
          <polygon
            :for={pts <- @grid_polygons}
            points={pts}
            fill="none"
            stroke="currentColor"
            stroke-width="0.5"
            class="text-border"
          />
          <%!-- Axis lines --%>
          <line
            :for={al <- @axis_lines}
            x1={al.x1}
            y1={al.y1}
            x2={al.x2}
            y2={al.y2}
            stroke="currentColor"
            stroke-width="0.5"
            class="text-border"
          />
        </g>

        <%!-- Axis labels --%>
        <text
          :for={al <- @axis_labels}
          x={al.x}
          y={al.y}
          text-anchor={al.anchor}
          dominant-baseline="middle"
          font-size="9"
          class="fill-muted-foreground"
        >{al.label}</text>

        <%!-- Series polygons --%>
        <polygon
          :for={sp <- @series_polygons}
          :if={sp.points != ""}
          points={sp.points}
          fill={sp.color}
          fill-opacity="0.25"
          stroke={sp.color}
          stroke-width="2"
          stroke-linejoin="round"
          style={
            if @animate do
              "animation: phia-fade-in #{@animation_duration}ms ease-out #{sp.delay_ms}ms both"
            else
              ""
            end
          }
        />
      </svg>
    </div>
    """
  end
end
