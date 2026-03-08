defmodule PhiaUi.Components.Data.XyChart do
  @moduledoc """
  Composable XY chart container with auto-scaling.

  Inspired by visx's `XYChart` — auto-computes domains from all series data,
  creates scales, and renders grid, axes, legend, annotations, and mixed
  series types (bar + line on the same chart).

  ## Examples

      <.xy_chart
        width={400}
        height={300}
        series={[
          %{name: "Revenue", type: :bar, data: [%{label: "Q1", value: 200}, %{label: "Q2", value: 280}]},
          %{name: "Trend",   type: :line, data: [%{label: "Q1", value: 190}, %{label: "Q2", value: 270}]}
        ]}
        show_grid={true}
        show_legend={true}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartAxisHelpers
  alias PhiaUi.Components.Data.ChartCoord
  alias PhiaUi.Components.Data.ChartSeriesRegistry
  alias PhiaUi.Components.Data.ChartViewport

  @default_padding %{top: 16, right: 16, bottom: 40, left: 44}

  attr :width, :integer, default: 400, doc: "SVG viewport width."
  attr :height, :integer, default: 300, doc: "SVG viewport height."

  attr :padding, :map,
    default: %{},
    doc: "Padding `%{top, right, bottom, left}`. Merges with defaults."

  attr :series, :list,
    default: [],
    doc: """
    List of series maps: `%{name, type, data, color}`.
    - `type` — `:bar`, `:line`, `:area`, or `:scatter` (default `:line`)
    - `data` — `[%{label, value}]`
    - `color` — optional override color
    """

  attr :x_scale_type, :atom,
    default: :band,
    values: [:linear, :band, :time, :log],
    doc: "Scale type for X axis."

  attr :y_scale_type, :atom,
    default: :linear,
    values: [:linear, :log],
    doc: "Scale type for Y axis."

  attr :colors, :list, default: [], doc: "Override default color palette."
  attr :show_grid, :boolean, default: true, doc: "Show horizontal grid lines."
  attr :show_x_axis, :boolean, default: true, doc: "Show X axis."
  attr :show_y_axis, :boolean, default: true, doc: "Show Y axis."
  attr :show_legend, :boolean, default: false, doc: "Show legend below chart."
  attr :animate, :boolean, default: true, doc: "Enable animations."
  attr :animation_duration, :integer, default: 600, doc: "Animation duration in ms."
  attr :bar_radius, :integer, default: 2, doc: "Corner radius for bars."
  attr :stroke_width, :integer, default: 2, doc: "Line stroke width."
  attr :class, :string, default: nil
  attr :rest, :global

  def xy_chart(assigns) do
    pad = Map.merge(@default_padding, assigns.padding)
    vp = ChartViewport.build(
      vw: assigns.width, vh: assigns.height,
      pl: pad.left, pr: pad.right, pt: pad.top, pb: pad.bottom
    )

    series = assigns.series

    {coord, categories, y_ticks, {_y_min, _y_max}} =
      ChartCoord.auto_cartesian(series,
        viewport: vp,
        x_type: assigns.x_scale_type,
        y_type: assigns.y_scale_type
      )

    # Build visual elements for each series
    bar_series = Enum.filter(series, fn s -> Map.get(s, :type, :line) == :bar end)
    n_bar_series = length(bar_series)

    elements =
      series
      |> Enum.with_index()
      |> Enum.flat_map(fn {s, si} ->
        color = Map.get(s, :color) || ChartHelpers.chart_color(si, assigns.colors)
        type = Map.get(s, :type, :line)
        bar_idx = if type == :bar, do: Enum.find_index(bar_series, &(&1.name == s.name)) || 0, else: 0

        ChartSeriesRegistry.render(type, s.data, coord, [
          color: color,
          series_index: si,
          bar_index: bar_idx,
          n_bar_series: n_bar_series,
          animate: assigns.animate,
          animation_duration: assigns.animation_duration,
          bar_radius: assigns.bar_radius,
          stroke_width: assigns.stroke_width
        ])
      end)

    bars = Enum.filter(elements, &(&1.type == :bar))
    lines = Enum.filter(elements, &(&1.type == :line))
    areas = Enum.filter(elements, &(&1.type == :area))
    scatters = Enum.filter(elements, &(&1.type == :scatter))

    # Y-axis tick rendering
    y_tick_entries =
      Enum.map(y_ticks, fn tick ->
        py = coord.y_scale.(tick)
        %{py: Float.round(py * 1.0, 2), label: ChartAxisHelpers.format_tick(tick * 1.0)}
      end)

    # X-axis label rendering
    x_label_entries =
      categories
      |> Enum.with_index()
      |> Enum.map(fn {cat, _i} ->
        px = coord.x_scale.(cat)
        %{label: to_string(cat), px: Float.round(px * 1.0, 2)}
      end)

    # Legend items
    legend_items =
      series
      |> Enum.with_index()
      |> Enum.map(fn {s, si} ->
        color = Map.get(s, :color) || ChartHelpers.chart_color(si, assigns.colors)
        type = Map.get(s, :type, :line)
        shape = case type do
          :bar -> :square
          :scatter -> :circle
          _ -> :line
        end
        %{label: s.name, color: color, shape: shape}
      end)

    cw = vp.cw
    ch = vp.ch

    assigns =
      assigns
      |> assign(:pad, pad)
      |> assign(:cw, cw)
      |> assign(:ch, ch)
      |> assign(:bars, bars)
      |> assign(:lines, lines)
      |> assign(:areas, areas)
      |> assign(:scatters, scatters)
      |> assign(:y_tick_entries, y_tick_entries)
      |> assign(:x_label_entries, x_label_entries)
      |> assign(:legend_items, legend_items)
      |> assign(:viewbox, ChartViewport.viewbox(vp))

    ~H"""
    <div class={cn(["w-full", if(@animate, do: "phia-chart-animate", else: ""), @class])} {@rest}>
      <svg
        viewBox={@viewbox}
        aria-hidden="true"
        class="w-full h-full overflow-visible"
        style={"--phia-chart-dur: #{@animation_duration}ms"}
      >
        <%!-- Grid lines --%>
        <g :if={@show_grid}>
          <line
            :for={t <- @y_tick_entries}
            x1={@pad.left}
            y1={t.py}
            x2={@pad.left + @cw}
            y2={t.py}
            stroke="currentColor"
            stroke-width="0.5"
            class="text-border"
          />
        </g>

        <%!-- Y-axis labels --%>
        <g :if={@show_y_axis}>
          <text
            :for={t <- @y_tick_entries}
            x={@pad.left - 4}
            y={t.py}
            text-anchor="end"
            dominant-baseline="middle"
            font-size="9"
            class="fill-muted-foreground"
          >{t.label}</text>
        </g>

        <%!-- X-axis labels --%>
        <g :if={@show_x_axis}>
          <text
            :for={e <- @x_label_entries}
            x={e.px}
            y={@pad.top + @ch + 14}
            text-anchor="middle"
            font-size="9"
            class="fill-muted-foreground"
          >{e.label}</text>
        </g>

        <%!-- Area fills --%>
        <path
          :for={area <- @areas}
          d={area.path_d}
          fill={area.color}
          opacity="0.15"
          style={area.anim_style}
        />

        <%!-- Bars --%>
        <rect
          :for={bar <- @bars}
          x={bar.x}
          y={bar.y}
          width={bar.w}
          height={bar.h}
          rx={@bar_radius}
          fill={bar.color}
          style={bar.anim_style}
        />

        <%!-- Lines --%>
        <polyline
          :for={line <- @lines}
          points={line.points}
          fill="none"
          stroke={line.color}
          stroke-width={@stroke_width}
          stroke-linecap="round"
          stroke-linejoin="round"
          style={line.anim_style}
        />

        <%!-- Scatter points --%>
        <circle
          :for={dot <- @scatters}
          cx={dot.cx}
          cy={dot.cy}
          r={dot.r}
          fill={dot.color}
          style={dot.anim_style}
        />
      </svg>

      <%!-- Legend --%>
      <div
        :if={@show_legend && @legend_items != []}
        class="flex flex-wrap gap-3 justify-center mt-2 text-xs"
        role="list"
        aria-label="Chart legend"
      >
        <div :for={item <- @legend_items} class="flex items-center gap-1.5" role="listitem">
          <span
            :if={item.shape == :square}
            class="inline-block size-2.5 rounded-sm shrink-0"
            style={"background-color: #{item.color}"}
          />
          <span
            :if={item.shape == :line}
            class="inline-block w-3 h-0.5 rounded-full shrink-0"
            style={"background-color: #{item.color}"}
          />
          <span
            :if={item.shape == :circle}
            class="inline-block size-2.5 rounded-full shrink-0"
            style={"background-color: #{item.color}"}
          />
          <span class="text-muted-foreground">{item.label}</span>
        </div>
      </div>
    </div>
    """
  end

end
