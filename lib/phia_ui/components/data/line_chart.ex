defmodule PhiaUi.Components.LineChart do
  @moduledoc """
  Single / multi-series line chart — pure SVG, zero JS.

  Lines animate in with a stroke-dashoffset draw effect. Optional dots
  appear with a staggered pop-in. Uses `polyline_length/1` computed
  server-side for precise dasharray values.

  Supports six curve interpolation modes via the `:curve` attribute:
  `:linear` (default, straight segments), `:smooth` (Catmull-Rom splines),
  `:monotone` (monotone cubic — prevents overshoot), `:step_before`,
  `:step_after`, and `:step_middle` (stepped lines).

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

      <.line_chart
        data={[
          %{label: "Jan", value: 120},
          %{label: "Feb", value: 200},
          %{label: "Mar", value: 160}
        ]}
        curve={:smooth}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartAxisHelpers
  alias PhiaUi.Components.Data.ChartViewport
  alias PhiaUi.Components.Data.ChartTheme

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

  attr :curve, :atom,
    default: :linear,
    values: [:linear, :smooth, :monotone, :step_before, :step_after, :step_middle],
    doc:
      "Interpolation mode for the line. `:linear` draws straight segments (polyline), `:smooth` uses Catmull-Rom splines, `:monotone` uses monotone cubic interpolation, and `:step_*` variants draw stepped lines."

  attr :theme, :map, default: %{}, doc: "Chart theme overrides (see ChartTheme)."
  attr :show_point_labels, :boolean, default: false, doc: "Show value labels above data points."

  attr :class, :string, default: nil
  attr :rest, :global

  def line_chart(assigns) do
    vp = ChartViewport.build()
    theme = ChartTheme.merge(assigns.theme)

    series = ChartHelpers.normalize_series(assigns.data, assigns.series)
    first_data = series |> List.first(%{data: []}) |> Map.get(:data, [])
    n_groups = length(first_data)

    {y_ticks, y_min_nice, y_max_nice} = ChartHelpers.compute_y_domain(series)

    # Precompute series line data (polyline for :linear, path for curves)
    curve = assigns.curve

    series_lines =
      series
      |> Enum.with_index()
      |> Enum.map(fn {s, i} ->
        color = ChartHelpers.chart_color(i, assigns.colors)

        if curve == :linear do
          pts =
            ChartHelpers.series_points(
              s.data,
              vp.pl * 1.0,
              (vp.pl + vp.cw) * 1.0,
              y_min_nice,
              y_max_nice,
              vp.pt * 1.0,
              (vp.pt + vp.ch) * 1.0
            )

          line_length = ChartHelpers.polyline_length(pts)

          %{
            type: :polyline,
            points: pts,
            path_d: nil,
            length: Float.round(line_length, 2),
            color: color,
            delay_ms: i * 100
          }
        else
          path_d =
            ChartHelpers.series_path(
              s.data,
              vp.pl * 1.0,
              (vp.pl + vp.cw) * 1.0,
              y_min_nice,
              y_max_nice,
              vp.pt * 1.0,
              (vp.pt + vp.ch) * 1.0,
              curve
            )

          line_length = ChartHelpers.path_length(path_d)

          %{
            type: :path,
            points: nil,
            path_d: path_d,
            length: Float.round(line_length, 2),
            color: color,
            delay_ms: i * 100
          }
        end
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
            px_x = vp.pl + di / max(n_groups - 1, 1) * vp.cw
            py_y = vp.pt + vp.ch - (item.value - y_min_nice) / max(y_max_nice - y_min_nice, 1) * vp.ch

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

    point_labels =
      if assigns.show_point_labels do
        series
        |> Enum.with_index()
        |> Enum.flat_map(fn {s, _i} ->
          s.data
          |> Enum.with_index()
          |> Enum.map(fn {item, di} ->
            px_x = vp.pl + di / max(n_groups - 1, 1) * vp.cw
            py_y = vp.pt + vp.ch - (item.value - y_min_nice) / max(y_max_nice - y_min_nice, 1) * vp.ch

            %{
              x: Float.round(px_x, 2),
              y: Float.round(py_y - theme.point_label.offset, 2),
              label: ChartAxisHelpers.format_tick(item.value * 1.0)
            }
          end)
        end)
      else
        []
      end

    # Precompute tick + label layout
    tick_entries =
      Enum.map(y_ticks, fn tick ->
        py = Float.round(vp.pt + vp.ch - (tick - y_min_nice) / max(y_max_nice - y_min_nice, 1) * vp.ch, 2)
        %{py: py, label: ChartAxisHelpers.format_tick(tick * 1.0)}
      end)

    x_label_entries =
      first_data
      |> Enum.with_index()
      |> Enum.map(fn {item, i} ->
        px = Float.round(vp.pl + i / max(n_groups - 1, 1) * vp.cw, 2)
        %{label: item.label, px: px, py: vp.pt + vp.ch + 14}
      end)

    assigns =
      assigns
      |> assign(:series_lines, series_lines)
      |> assign(:all_dots, all_dots)
      |> assign(:tick_entries, tick_entries)
      |> assign(:x_label_entries, x_label_entries)
      |> assign(:viewbox, ChartViewport.viewbox(vp))
      |> assign(:grid_x1, vp.pl)
      |> assign(:grid_x2, vp.pl + vp.cw)
      |> assign(:theme, theme)
      |> assign(:point_labels, point_labels)

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
            stroke-width={@theme.grid.stroke_width}
            class={@theme.grid.stroke_class}
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
            font-size={@theme.axis.font_size}
            class={@theme.axis.label_class}
          >{t.label}</text>
        </g>

        <%!-- X-axis labels --%>
        <g :if={@show_labels}>
          <text
            :for={e <- @x_label_entries}
            x={e.px}
            y={e.py}
            text-anchor="middle"
            font-size={@theme.axis.font_size}
            class={@theme.axis.label_class}
          >{e.label}</text>
        </g>

        <%!-- Lines (polyline for :linear curve) --%>
        <polyline
          :for={line <- @series_lines}
          :if={line.type == :polyline && line.points != ""}
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
        <%!-- Lines (path for curved interpolations) --%>
        <path
          :for={line <- @series_lines}
          :if={line.type == :path && line.path_d != ""}
          d={line.path_d}
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

        <%!-- Point labels --%>
        <g :if={@show_point_labels}>
          <text
            :for={pl <- @point_labels}
            x={pl.x}
            y={pl.y}
            text-anchor="middle"
            font-size={@theme.point_label.font_size}
            class={@theme.point_label.label_class}
          >{pl.label}</text>
        </g>
      </svg>
    </div>
    """
  end
end
