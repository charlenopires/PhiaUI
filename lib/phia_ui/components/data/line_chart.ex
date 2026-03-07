defmodule PhiaUi.Components.LineChart do
  @moduledoc """
  Single / multi-series line chart — pure SVG, zero JS.

  Lines animate in with a stroke-dashoffset draw effect. Optional dots
  appear with a staggered pop-in. Uses `polyline_length/1` computed
  server-side for precise dasharray values.

  ## Examples

      <.line_chart data={[
        %{label: "Jan", value: 120},
        %{label: "Feb", value: 200},
        %{label: "Mar", value: 160}
      ]} />

      <.line_chart
        series={[
          %{name: "2023", data: [%{label: "Q1", value: 100}, %{label: "Q2", value: 200}]},
          %{name: "2024", data: [%{label: "Q1", value: 140}, %{label: "Q2", value: 280}]}
        ]}
        show_dots={true}
        colors={["oklch(0.60 0.20 240)", "oklch(0.65 0.22 30)"]}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartAxisHelpers

  @vw 400
  @vh 300
  @pl 44
  @pr 16
  @pt 16
  @pb 40
  @cw @vw - @pl - @pr
  @ch @vh - @pt - @pb

  attr :data, :list, default: [], doc: "Single-series: `[%{label, value}]`."

  attr :series, :list,
    default: [],
    doc: "Multi-series: `[%{name, data: [%{label, value}]}]`."

  attr :colors, :list, default: [], doc: "Override default palette."
  attr :show_dots, :boolean, default: false, doc: "Render data point circles."
  attr :show_grid, :boolean, default: true, doc: "Render horizontal grid lines."
  attr :show_labels, :boolean, default: true, doc: "Render axis labels."
  attr :stroke_width, :integer, default: 2, doc: "Line stroke width in px."
  attr :animate, :boolean, default: true, doc: "Enable entrance animations."
  attr :animation_duration, :integer, default: 800, doc: "Animation duration in ms."
  attr :class, :string, default: nil
  attr :rest, :global

  def line_chart(assigns) do
    series = ChartHelpers.normalize_series(assigns.data, assigns.series)
    first_data = series |> List.first(%{data: []}) |> Map.get(:data, [])
    n_groups = length(first_data)

    all_values = series |> Enum.flat_map(fn s -> Enum.map(s.data, & &1.value) end)
    y_max = if all_values == [], do: 10, else: Enum.max(all_values)
    y_min = if all_values == [], do: 0, else: min(0, Enum.min(all_values))
    y_ticks = ChartAxisHelpers.nice_ticks(y_min, max(y_max, 1), 5)
    y_max_nice = Enum.max(y_ticks)
    y_min_nice = Enum.min(y_ticks)

    # Precompute series polyline data
    series_lines =
      series
      |> Enum.with_index()
      |> Enum.map(fn {s, i} ->
        pts =
          ChartHelpers.series_points(
            s.data,
            @pl * 1.0,
            (@pl + @cw) * 1.0,
            y_min_nice,
            y_max_nice,
            @pt * 1.0,
            (@pt + @ch) * 1.0
          )

        line_length = ChartHelpers.polyline_length(pts)
        color = ChartHelpers.chart_color(i, assigns.colors)

        %{
          points: pts,
          length: Float.round(line_length, 2),
          color: color,
          delay_ms: i * 100
        }
      end)

    # Flatten all dots into a single list for rendering
    all_dots =
      if assigns.show_dots do
        series
        |> Enum.with_index()
        |> Enum.flat_map(fn {s, i} ->
          color = ChartHelpers.chart_color(i, assigns.colors)

          s.data
          |> Enum.with_index()
          |> Enum.map(fn {item, di} ->
            px_x = @pl + di / max(n_groups - 1, 1) * @cw
            py_y = @pt + @ch - (item.value - y_min_nice) / max(y_max_nice - y_min_nice, 1) * @ch

            %{
              cx: Float.round(px_x, 2),
              cy: Float.round(py_y, 2),
              color: color,
              delay: i * 100 + di * 40
            }
          end)
        end)
      else
        []
      end

    # Precompute tick + label layout
    tick_entries =
      Enum.map(y_ticks, fn tick ->
        py = Float.round(@pt + @ch - (tick - y_min_nice) / max(y_max_nice - y_min_nice, 1) * @ch, 2)
        %{py: py, label: ChartAxisHelpers.format_tick(tick * 1.0)}
      end)

    x_label_entries =
      first_data
      |> Enum.with_index()
      |> Enum.map(fn {item, i} ->
        px = Float.round(@pl + i / max(n_groups - 1, 1) * @cw, 2)
        %{label: item.label, px: px, py: @pt + @ch + 14}
      end)

    assigns =
      assigns
      |> assign(:series_lines, series_lines)
      |> assign(:all_dots, all_dots)
      |> assign(:tick_entries, tick_entries)
      |> assign(:x_label_entries, x_label_entries)
      |> assign(:viewbox, "0 0 #{@vw} #{@vh}")
      |> assign(:grid_x1, @pl)
      |> assign(:grid_x2, @pl + @cw)

    ~H"""
    <div
      class={cn(["w-full", if(@animate, do: "phia-chart-animate", else: ""), @class])}
      {@rest}
    >
      <svg viewBox={@viewbox} aria-hidden="true" class="w-full h-full overflow-visible">
        <%!-- Grid lines --%>
        <g :if={@show_grid}>
          <line
            :for={t <- @tick_entries}
            x1={@grid_x1}
            y1={t.py}
            x2={@grid_x2}
            y2={t.py}
            stroke="currentColor"
            stroke-width="0.5"
            class="text-border"
          />
        </g>

        <%!-- Y-axis labels --%>
        <g :if={@show_labels}>
          <text
            :for={t <- @tick_entries}
            x={@grid_x1 - 4}
            y={t.py}
            text-anchor="end"
            dominant-baseline="middle"
            font-size="9"
            class="fill-muted-foreground"
          >{t.label}</text>
        </g>

        <%!-- X-axis labels --%>
        <g :if={@show_labels}>
          <text
            :for={e <- @x_label_entries}
            x={e.px}
            y={e.py}
            text-anchor="middle"
            font-size="9"
            class="fill-muted-foreground"
          >{e.label}</text>
        </g>

        <%!-- Lines --%>
        <polyline
          :for={line <- @series_lines}
          :if={line.points != ""}
          points={line.points}
          fill="none"
          stroke={line.color}
          stroke-width={@stroke_width}
          stroke-linecap="round"
          stroke-linejoin="round"
          style={
            if @animate do
              "stroke-dasharray: #{line.length}; stroke-dashoffset: #{line.length}; animation: phia-line-draw #{@animation_duration}ms ease-out #{line.delay_ms}ms forwards"
            else
              ""
            end
          }
        />

        <%!-- Dots --%>
        <circle
          :for={dot <- @all_dots}
          cx={dot.cx}
          cy={dot.cy}
          r="3"
          fill={dot.color}
          style={
            if @animate do
              "transform-box: fill-box; transform-origin: center; animation: phia-dot-pop #{@animation_duration}ms ease-out #{dot.delay}ms both"
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
