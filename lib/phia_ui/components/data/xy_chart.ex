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
  alias PhiaUi.Components.Data.ChartScales

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
    - `type` — `:bar`, `:line`, or `:area` (default `:line`)
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
    cw = assigns.width - pad.left - pad.right
    ch = assigns.height - pad.top - pad.bottom

    series = assigns.series
    categories = extract_categories(series)
    {y_min, y_max} = compute_y_domain(series)
    y_ticks = ChartAxisHelpers.nice_ticks(y_min, max(y_max, 1), 5)
    y_min_nice = Enum.min(y_ticks)
    y_max_nice = Enum.max(y_ticks)

    # Build scales
    x_scale_result = build_x_scale(assigns.x_scale_type, categories, pad.left, pad.left + cw)

    y_scale =
      case assigns.y_scale_type do
        :log -> ChartScales.log_scale(max(y_min_nice, 0.1), y_max_nice, pad.top + ch, pad.top)
        _ -> ChartScales.linear_scale(y_min_nice, y_max_nice, pad.top + ch, pad.top)
      end

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

        build_elements(type, s.data, x_scale_result, y_scale, color, si, bar_idx, n_bar_series, cw, ch, pad, assigns)
      end)

    bars = Enum.filter(elements, &(&1.type == :bar))
    lines = Enum.filter(elements, &(&1.type == :line))
    areas = Enum.filter(elements, &(&1.type == :area))

    # Y-axis tick rendering
    y_tick_entries =
      Enum.map(y_ticks, fn tick ->
        py = y_scale.(tick)
        %{py: Float.round(py * 1.0, 2), label: ChartAxisHelpers.format_tick(tick * 1.0)}
      end)

    # X-axis label rendering
    x_label_entries =
      categories
      |> Enum.with_index()
      |> Enum.map(fn {cat, _i} ->
        px = x_scale_result.scale.(cat)
        %{label: to_string(cat), px: Float.round(px * 1.0, 2)}
      end)

    # Legend items
    legend_items =
      series
      |> Enum.with_index()
      |> Enum.map(fn {s, si} ->
        color = Map.get(s, :color) || ChartHelpers.chart_color(si, assigns.colors)
        shape = if Map.get(s, :type, :line) == :bar, do: :square, else: :line
        %{label: s.name, color: color, shape: shape}
      end)

    assigns =
      assigns
      |> assign(:pad, pad)
      |> assign(:cw, cw)
      |> assign(:ch, ch)
      |> assign(:bars, bars)
      |> assign(:lines, lines)
      |> assign(:areas, areas)
      |> assign(:y_tick_entries, y_tick_entries)
      |> assign(:x_label_entries, x_label_entries)
      |> assign(:legend_items, legend_items)
      |> assign(:viewbox, "0 0 #{assigns.width} #{assigns.height}")

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
          <span class="text-muted-foreground">{item.label}</span>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------

  defp extract_categories(series) do
    series
    |> Enum.flat_map(fn s -> Enum.map(s.data, & &1.label) end)
    |> Enum.uniq()
  end

  defp compute_y_domain(series) do
    all_values = Enum.flat_map(series, fn s -> Enum.map(s.data, & &1.value) end)

    if all_values == [] do
      {0, 10}
    else
      y_max = Enum.max(all_values)
      y_min = min(0, Enum.min(all_values))
      {y_min, y_max}
    end
  end

  defp build_x_scale(:band, categories, range_min, range_max) do
    ChartScales.band_scale(categories, range_min, range_max)
  end

  defp build_x_scale(:linear, categories, range_min, range_max) do
    n = length(categories)
    scale = ChartScales.linear_scale(0, max(n - 1, 1), range_min, range_max)
    positions = categories |> Enum.with_index() |> Enum.map(fn {c, i} -> {c, scale.(i)} end) |> Map.new()

    %{
      positions: positions,
      bandwidth: (range_max - range_min) / max(n, 1) * 0.8,
      scale: fn cat -> Map.get(positions, cat, (range_min + range_max) / 2) end
    }
  end

  defp build_x_scale(_type, categories, range_min, range_max) do
    build_x_scale(:band, categories, range_min, range_max)
  end

  defp build_elements(:bar, data, x_scale, y_scale, color, _si, bar_idx, n_bar, _cw, _ch, _pad, assigns) do
    bw = Map.get(x_scale, :bandwidth, 20)
    bar_w = bw / max(n_bar, 1)

    data
    |> Enum.with_index()
    |> Enum.map(fn {item, gi} ->
      cx = x_scale.scale.(item.label)
      x = cx - bw / 2 + bar_idx * bar_w
      y_top = y_scale.(item.value)
      y_base = y_scale.(0)
      h = abs(y_base - y_top)

      %{
        type: :bar,
        x: Float.round(x, 2),
        y: Float.round(min(y_top, y_base), 2),
        w: Float.round(bar_w, 2),
        h: Float.round(max(h, 1.0), 2),
        color: color,
        anim_style: bar_anim(assigns.animate, assigns.animation_duration, gi * 60)
      }
    end)
  end

  defp build_elements(:line, data, x_scale, y_scale, color, si, _bi, _nb, _cw, _ch, _pad, assigns) do
    points =
      data
      |> Enum.map(fn item ->
        px = x_scale.scale.(item.label)
        py = y_scale.(item.value)
        "#{Float.round(px * 1.0, 2)},#{Float.round(py * 1.0, 2)}"
      end)
      |> Enum.join(" ")

    line_length = ChartHelpers.polyline_length(points)

    [%{
      type: :line,
      points: points,
      color: color,
      anim_style: line_anim(assigns.animate, assigns.animation_duration, si * 100, line_length)
    }]
  end

  defp build_elements(:area, data, x_scale, y_scale, color, si, _bi, _nb, _cw, _ch, _pad, assigns) do
    coords =
      Enum.map(data, fn item ->
        px = x_scale.scale.(item.label)
        py = y_scale.(item.value)
        {Float.round(px * 1.0, 2), Float.round(py * 1.0, 2)}
      end)

    baseline = Float.round(y_scale.(0) * 1.0, 2)

    path_d =
      if coords == [] do
        ""
      else
        {first_x, _} = hd(coords)
        {last_x, _} = List.last(coords)
        line = Enum.map_join(coords, " L ", fn {x, y} -> "#{x} #{y}" end)
        "M #{first_x} #{baseline} L #{line} L #{last_x} #{baseline} Z"
      end

    [%{
      type: :area,
      path_d: path_d,
      color: color,
      anim_style: if(assigns.animate, do: "animation: phia-fade-in #{assigns.animation_duration}ms ease-out #{si * 100}ms both", else: "")
    }]
  end

  defp bar_anim(false, _dur, _delay), do: ""

  defp bar_anim(true, dur, delay),
    do: "transform-box: fill-box; transform-origin: bottom; animation: phia-bar-grow #{dur}ms ease-out #{delay}ms both"

  defp line_anim(false, _dur, _delay, _len), do: ""

  defp line_anim(true, dur, delay, len),
    do: "stroke-dasharray: #{len}; stroke-dashoffset: #{len}; animation: phia-line-draw #{dur}ms ease-out #{delay}ms forwards"
end
