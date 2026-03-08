defmodule PhiaUi.Components.AreaChart do
  @moduledoc """
  Filled area chart — pure SVG, zero JS.

  Supports a default single/multi-area view and a `:stacked` variant.
  Areas fade in on entrance; the line strokes animate with dashoffset.

  ## Examples

      <.area_chart data={[
        %{label: "Jan", value: 80},
        %{label: "Feb", value: 140},
        %{label: "Mar", value: 110}
      ]} />

      <.area_chart
        series={[
          %{name: "Visitors", data: [%{label: "Mon", value: 100}, %{label: "Tue", value: 200}]},
          %{name: "Signups",  data: [%{label: "Mon", value: 40},  %{label: "Tue", value: 80}]}
        ]}
        variant={:stacked}
        fill_opacity={0.3}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartAxisHelpers
  alias PhiaUi.Components.Data.ChartViewport
  alias PhiaUi.Components.Data.ChartTheme
  alias PhiaUi.Components.Data.ChartMathHelpers

  attr :data, :list, default: [], doc: "Single-series: `[%{label, value}]`."
  attr :series, :list, default: [], doc: "Multi-series: `[%{name, data: [%{label, value}]}]`."

  attr :variant, :atom,
    default: :default,
    values: [:default, :stacked],
    doc: "`:default` overlays areas; `:stacked` accumulates them."

  attr :curve, :atom,
    default: :linear,
    values: [:linear, :smooth, :monotone, :step_before, :step_after, :step_middle],
    doc: "Interpolation curve type for the area outline."

  attr :colors, :list, default: [], doc: "Override default palette."
  attr :fill_opacity, :float, default: 0.2, doc: "Area fill opacity (0.0–1.0)."
  attr :show_grid, :boolean, default: true
  attr :show_labels, :boolean, default: true
  attr :animate, :boolean, default: true
  attr :animation_duration, :integer, default: 800
  attr :theme, :map, default: %{}, doc: "Chart theme overrides (see ChartTheme)."
  attr :show_point_labels, :boolean, default: false, doc: "Show value labels above data points."
  attr :class, :string, default: nil
  attr :rest, :global

  def area_chart(assigns) do
    series = ChartHelpers.normalize_series(assigns.data, assigns.series)
    vp = ChartViewport.build()
    theme = ChartTheme.merge(assigns.theme)
    first_data = series |> List.first(%{data: []}) |> Map.get(:data, [])
    n_groups = length(first_data)

    {y_ticks, y_max_nice} =
      if assigns.variant == :stacked do
        ChartHelpers.compute_stacked_y_domain(series)
      else
        {ticks, _min, max_n} = ChartHelpers.compute_y_domain(series, include_negative: false)
        {ticks, max_n}
      end

    px_bot = (vp.pt + vp.ch) * 1.0
    px_top = vp.pt * 1.0
    x0 = vp.pl * 1.0
    x1 = (vp.pl + vp.cw) * 1.0

    curve = assigns.curve

    series_areas =
      if assigns.variant == :stacked do
        build_stacked_areas(series, x0, x1, y_max_nice, px_top, px_bot, n_groups, curve, assigns.colors)
      else
        build_overlaid_areas(series, x0, x1, y_max_nice, px_top, px_bot, n_groups, curve, assigns.colors)
      end

    # Point labels
    point_labels =
      if assigns.show_point_labels do
        series
        |> Enum.with_index()
        |> Enum.flat_map(fn {s, _i} ->
          s.data
          |> Enum.with_index()
          |> Enum.map(fn {item, di} ->
            px_x = x0 + di / max(n_groups - 1, 1) * vp.cw
            py_y = px_bot - item.value / max(y_max_nice, 1) * vp.ch

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

    tick_entries =
      Enum.map(y_ticks, fn tick ->
        py = Float.round(px_bot - tick / max(y_max_nice, 1) * vp.ch, 2)
        %{py: py, label: ChartAxisHelpers.format_tick(tick * 1.0)}
      end)

    x_label_entries =
      first_data
      |> Enum.with_index()
      |> Enum.map(fn {item, i} ->
        px = Float.round(x0 + i / max(n_groups - 1, 1) * vp.cw, 2)
        %{label: item.label, px: px, py: px_bot + 14}
      end)

    assigns =
      assigns
      |> assign(:series_areas, series_areas)
      |> assign(:tick_entries, tick_entries)
      |> assign(:x_label_entries, x_label_entries)
      |> assign(:point_labels, point_labels)
      |> assign(:viewbox, ChartViewport.viewbox(vp))
      |> assign(:grid_x1, vp.pl)
      |> assign(:grid_x2, vp.pl + vp.cw)
      |> assign(:theme, theme)

    ~H"""
    <div
      class={cn(["w-full", if(@animate, do: "phia-chart-animate", else: ""), @class])}
      {@rest}
    >
      <svg viewBox={@viewbox} aria-hidden="true" class="w-full h-full overflow-visible">
        <%!-- Grid --%>
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

        <%!-- Y labels --%>
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

        <%!-- X labels --%>
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

        <%!-- Area fills --%>
        <path
          :for={area <- @series_areas}
          d={area.area_path}
          fill={area.color}
          fill-opacity={@fill_opacity}
          stroke="none"
          style={
            if @animate do
              "animation: phia-fade-in #{@animation_duration}ms ease-out #{area.delay_ms + 200}ms both"
            else
              ""
            end
          }
        />

        <%!-- Lines (polyline for linear, path for curves) --%>
        <polyline
          :for={area <- @series_areas}
          :if={!area.curved && area.points != ""}
          points={area.points}
          fill="none"
          stroke={area.color}
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          style={
            if @animate do
              "stroke-dasharray: #{area.line_len}; stroke-dashoffset: #{area.line_len}; animation: phia-line-draw #{@animation_duration}ms ease-out #{area.delay_ms}ms forwards"
            else
              ""
            end
          }
        />
        <path
          :for={area <- @series_areas}
          :if={area.curved && area.line_path != ""}
          d={area.line_path}
          fill="none"
          stroke={area.color}
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          style={
            if @animate do
              "stroke-dasharray: #{area.line_len}; stroke-dashoffset: #{area.line_len}; animation: phia-line-draw #{@animation_duration}ms ease-out #{area.delay_ms}ms forwards"
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

  # Overlaid areas — each series area goes from y=0 baseline
  defp build_overlaid_areas(series, x0, x1, y_max, px_top, px_bot, _n_groups, curve, colors) do
    series
    |> Enum.with_index()
    |> Enum.map(fn {s, i} ->
      color = ChartHelpers.chart_color(i, colors)

      if curve == :linear do
        pts = ChartHelpers.series_points(s.data, x0, x1, 0, y_max, px_top, px_bot)
        line_len = ChartHelpers.polyline_length(pts)
        area_path = build_linear_area_path(s.data, x0, x1, y_max, px_top, px_bot)

        %{points: pts, line_path: nil, area_path: area_path, line_len: Float.round(line_len, 2),
          color: color, delay_ms: i * 100, curved: false}
      else
        line_path = ChartHelpers.series_path(s.data, x0, x1, 0, y_max, px_top, px_bot, curve)
        area_path = ChartHelpers.series_area_path(s.data, x0, x1, 0, y_max, px_top, px_bot, curve)
        line_len = ChartHelpers.path_length(line_path)

        %{points: nil, line_path: line_path, area_path: area_path, line_len: Float.round(line_len, 2),
          color: color, delay_ms: i * 100, curved: true}
      end
    end)
  end

  # Stacked areas — each series baseline follows the previous series' top
  defp build_stacked_areas(series, x0, x1, y_max, px_top, px_bot, _n_groups, _curve, colors) do
    stacked = ChartMathHelpers.stack_series(series)
    y_range = max(y_max, 1)
    px_range = px_bot - px_top

    stacked
    |> Enum.with_index()
    |> Enum.map(fn {s, i} ->
      color = ChartHelpers.chart_color(i, colors)
      count = length(s.data)

      top_points =
        s.data
        |> Enum.with_index()
        |> Enum.map(fn {item, di} ->
          px_x = x0 + di / max(count - 1, 1) * (x1 - x0)
          px_y = px_bot - (item.base + item.value) / y_range * px_range
          {Float.round(px_x, 2), Float.round(px_y, 2)}
        end)

      base_points =
        s.data
        |> Enum.with_index()
        |> Enum.map(fn {item, di} ->
          px_x = x0 + di / max(count - 1, 1) * (x1 - x0)
          px_y = px_bot - item.base / y_range * px_range
          {Float.round(px_x, 2), Float.round(px_y, 2)}
        end)
        |> Enum.reverse()

      # Area path: top line forward, base line backward
      top_part = Enum.map_join(top_points, " L ", fn {x, y} -> "#{x} #{y}" end)
      base_part = Enum.map_join(base_points, " L ", fn {x, y} -> "#{x} #{y}" end)
      {fx, fy} = List.first(top_points)
      area_path = "M #{fx} #{fy} L #{top_part} L #{base_part} Z"

      # Line points (top edge only)
      pts = Enum.map_join(top_points, " ", fn {x, y} -> "#{x},#{y}" end)
      line_len = ChartHelpers.polyline_length(pts)

      %{points: pts, line_path: nil, area_path: area_path, line_len: Float.round(line_len, 2),
        color: color, delay_ms: i * 100, curved: false}
    end)
  end

  defp build_linear_area_path([], _x0, _x1, _y_max, _px_top, _px_bot), do: ""

  defp build_linear_area_path(data, x0, x1, y_max, px_top, px_bot) do
    count = length(data)
    y_range = max(y_max, 1)
    px_range = px_bot - px_top

    pts =
      data
      |> Enum.with_index()
      |> Enum.map(fn {item, i} ->
        px_x = x0 + i / max(count - 1, 1) * (x1 - x0)
        px_y = px_bot - item.value / y_range * px_range
        {Float.round(px_x, 2), Float.round(px_y, 2)}
      end)

    {first_x, _} = List.first(pts)
    {last_x, _} = List.last(pts)

    line_part = Enum.map_join(pts, " L ", fn {x, y} -> "#{x} #{y}" end)
    "M #{first_x} #{px_bot} L #{line_part} L #{last_x} #{px_bot} Z"
  end
end
