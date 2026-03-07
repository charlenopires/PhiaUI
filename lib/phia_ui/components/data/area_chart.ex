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

  @vw 400
  @vh 300
  @pl 44
  @pr 16
  @pt 16
  @pb 40
  @cw @vw - @pl - @pr
  @ch @vh - @pt - @pb

  attr :data, :list, default: [], doc: "Single-series: `[%{label, value}]`."
  attr :series, :list, default: [], doc: "Multi-series: `[%{name, data: [%{label, value}]}]`."

  attr :variant, :atom,
    default: :default,
    values: [:default, :stacked],
    doc: "`:default` overlays areas; `:stacked` accumulates them."

  attr :colors, :list, default: [], doc: "Override default palette."
  attr :fill_opacity, :float, default: 0.2, doc: "Area fill opacity (0.0–1.0)."
  attr :show_grid, :boolean, default: true
  attr :show_labels, :boolean, default: true
  attr :animate, :boolean, default: true
  attr :animation_duration, :integer, default: 800
  attr :class, :string, default: nil
  attr :rest, :global

  def area_chart(assigns) do
    series = ChartHelpers.normalize_series(assigns.data, assigns.series)
    first_data = series |> List.first(%{data: []}) |> Map.get(:data, [])
    n_groups = length(first_data)

    all_values = series |> Enum.flat_map(fn s -> Enum.map(s.data, & &1.value) end)
    y_max_raw = if all_values == [], do: 10, else: Enum.max(all_values)
    y_ticks = ChartAxisHelpers.nice_ticks(0, max(y_max_raw, 1), 5)
    y_max_nice = Enum.max(y_ticks)

    px_bot = @pt + @ch
    px_top = @pt * 1.0
    x0 = @pl * 1.0
    x1 = (@pl + @cw) * 1.0

    series_areas =
      series
      |> Enum.with_index()
      |> Enum.map(fn {s, i} ->
        pts =
          ChartHelpers.series_points(s.data, x0, x1, 0, y_max_nice, px_top, px_bot * 1.0)

        line_len = ChartHelpers.polyline_length(pts)

        # Build closed polygon for area fill
        area_path = build_area_path(s.data, x0, x1, y_max_nice, px_top, px_bot * 1.0, n_groups)

        color = ChartHelpers.chart_color(i, assigns.colors)

        %{
          points: pts,
          area_path: area_path,
          line_len: Float.round(line_len, 2),
          color: color,
          delay_ms: i * 100
        }
      end)

    tick_entries =
      Enum.map(y_ticks, fn tick ->
        py = Float.round(px_bot - tick / max(y_max_nice, 1) * @ch, 2)
        %{py: py, label: ChartAxisHelpers.format_tick(tick * 1.0)}
      end)

    x_label_entries =
      first_data
      |> Enum.with_index()
      |> Enum.map(fn {item, i} ->
        px = Float.round(x0 + i / max(n_groups - 1, 1) * @cw, 2)
        %{label: item.label, px: px, py: px_bot + 14}
      end)

    assigns =
      assigns
      |> assign(:series_areas, series_areas)
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
        <%!-- Grid --%>
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

        <%!-- Y labels --%>
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

        <%!-- X labels --%>
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

        <%!-- Area fills --%>
        <path
          :for={{area, idx} <- Enum.with_index(@series_areas)}
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

        <%!-- Lines --%>
        <polyline
          :for={area <- @series_areas}
          :if={area.points != ""}
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
      </svg>
    </div>
    """
  end

  defp build_area_path([], _x0, _x1, _y_max, _px_top, _px_bot, _n), do: ""

  defp build_area_path(data, x0, x1, y_max, px_top, px_bot, _n_groups) do
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
