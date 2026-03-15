defmodule PhiaUi.Components.BoxPlot do
  @moduledoc """
  Box-and-whisker plot — pure SVG, zero JS.

  Renders statistical distributions as boxes (Q1-Q3), median lines, whiskers
  (to the most extreme non-outlier data points), and optional outlier dots.
  Supports both raw value lists and pre-computed quartile statistics.

  ## Examples

      <.box_plot data={[
        %{label: "Group A", values: [12, 15, 18, 22, 25, 28, 30, 35, 45]},
        %{label: "Group B", values: [5, 10, 15, 20, 25, 30, 35, 40]}
      ]} />

      <.box_plot data={[
        %{label: "Precomputed", q1: 15.0, median: 22.0, q3: 30.0,
          whisker_low: 12.0, whisker_high: 35.0, outliers: [5.0, 45.0]}
      ]} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartAxisHelpers
  alias PhiaUi.Components.Data.ChartMathHelpers
  alias PhiaUi.Components.Data.ChartViewport
  alias PhiaUi.Components.Data.ChartTheme

  attr :data, :list,
    default: [],
    doc:
      "Raw values: `[%{label, values: [numbers]}]` or pre-computed: `[%{label, q1, median, q3, whisker_low, whisker_high, outliers}]`."

  attr :colors, :list, default: [], doc: "Override default palette. CSS color strings."
  attr :show_outliers, :boolean, default: true, doc: "Show outlier dots beyond whiskers."
  attr :show_grid, :boolean, default: true, doc: "Show Y-axis grid lines."
  attr :show_labels, :boolean, default: true, doc: "Show axis tick labels."
  attr :animate, :boolean, default: true, doc: "Enable entrance animations."
  attr :animation_duration, :integer, default: 600, doc: "Animation duration in ms."
  attr :theme, :map, default: %{}, doc: "Chart theme overrides (see ChartTheme)."
  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def box_plot(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"
    vp = ChartViewport.build()
    theme = ChartTheme.merge(assigns.theme)
    data = assigns.data
    n = length(data)

    # Compute or extract stats for each group
    stats =
      Enum.map(data, fn item ->
        if Map.has_key?(item, :values) do
          qs = ChartMathHelpers.quartiles(item.values)
          Map.put(qs, :label, item.label)
        else
          item
        end
      end)

    # Compute Y domain from all whiskers and outliers
    {y_ticks, y_min, y_max} =
      if n == 0 do
        ticks = ChartAxisHelpers.nice_ticks(0, 10, 5)
        {ticks, Enum.min(ticks), Enum.max(ticks)}
      else
        all_lows =
          Enum.flat_map(stats, fn s ->
            outliers = Map.get(s, :outliers, [])
            [s.whisker_low | outliers]
          end)

        all_highs =
          Enum.flat_map(stats, fn s ->
            outliers = Map.get(s, :outliers, [])
            [s.whisker_high | outliers]
          end)

        min_v = Enum.min(all_lows)
        max_v = Enum.max(all_highs)
        ticks = ChartAxisHelpers.nice_ticks(min_v, max_v, 5)
        {ticks, Enum.min(ticks), Enum.max(ticks)}
      end

    y_range = max(y_max - y_min, 1)

    # Build render data for each box
    box_w = vp.cw / max(n, 1) * 0.5
    cap_w = box_w * 0.6

    boxes =
      stats
      |> Enum.with_index()
      |> Enum.map(fn {s, i} ->
        cx = vp.pl + (i + 0.5) * (vp.cw / max(n, 1))
        color = ChartHelpers.chart_color(i, assigns.colors)

        val_to_y = fn v -> vp.pt + vp.ch - (v - y_min) / y_range * vp.ch end

        q1_y = val_to_y.(s.q1)
        q3_y = val_to_y.(s.q3)
        median_y = val_to_y.(s.median)
        wl_y = val_to_y.(s.whisker_low)
        wh_y = val_to_y.(s.whisker_high)

        outlier_dots =
          if assigns.show_outliers do
            (Map.get(s, :outliers, []))
            |> Enum.map(fn v ->
              %{cx: f(cx), cy: f(val_to_y.(v))}
            end)
          else
            []
          end

        %{
          cx: f(cx),
          box_x: f(cx - box_w / 2),
          box_y: f(q3_y),
          box_w: f(box_w),
          box_h: f(max(q1_y - q3_y, 1.0)),
          median_y: f(median_y),
          median_x1: f(cx - box_w / 2),
          median_x2: f(cx + box_w / 2),
          whisker_high_y: f(wh_y),
          whisker_low_y: f(wl_y),
          cap_x1: f(cx - cap_w / 2),
          cap_x2: f(cx + cap_w / 2),
          q1_y: f(q1_y),
          q3_y: f(q3_y),
          color: color,
          outliers: outlier_dots,
          delay_ms: i * 80,
          label: s.label
        }
      end)

    # Tick rendering data
    tick_lines =
      Enum.map(y_ticks, fn tick ->
        py = vp.pt + vp.ch - (tick - y_min) / y_range * vp.ch
        %{tick: tick, py: f(py), label: ChartAxisHelpers.format_tick(tick * 1.0)}
      end)

    x_label_entries =
      stats
      |> Enum.with_index()
      |> Enum.map(fn {s, i} ->
        px = vp.pl + (i + 0.5) * (vp.cw / max(n, 1))
        %{label: s.label, px: f(px), py: vp.pt + vp.ch + 14}
      end)

    assigns =
      assigns
      |> assign(:boxes, boxes)
      |> assign(:tick_lines, tick_lines)
      |> assign(:x_label_entries, x_label_entries)
      |> assign(:viewbox, ChartViewport.viewbox(vp))
      |> assign(:grid_x1, vp.pl)
      |> assign(:grid_x2, vp.pl + vp.cw)
      |> assign(:theme, theme)
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
        style={"--phia-chart-dur: #{@animation_duration}ms"}
      >
        <title :if={@title}>{@title}</title>
        <desc :if={@description} id={"#{@chart_id}-desc"}>{@description}</desc>

        <%!-- Y-axis grid lines --%>
        <g :if={@show_grid} aria-hidden="true">
          <line
            :for={t <- @tick_lines}
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
            :for={t <- @tick_lines}
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

        <%!-- Box plots --%>
        <g :for={box <- @boxes}>
          <%!-- Upper whisker (Q3 to whisker_high) --%>
          <line
            x1={box.cx}
            y1={box.q3_y}
            x2={box.cx}
            y2={box.whisker_high_y}
            stroke={box.color}
            stroke-width="1"
            stroke-dasharray="3 2"
            style={box_anim_style(@animate, @animation_duration, box.delay_ms)}
          />
          <%!-- Lower whisker (Q1 to whisker_low) --%>
          <line
            x1={box.cx}
            y1={box.q1_y}
            x2={box.cx}
            y2={box.whisker_low_y}
            stroke={box.color}
            stroke-width="1"
            stroke-dasharray="3 2"
            style={box_anim_style(@animate, @animation_duration, box.delay_ms)}
          />
          <%!-- Upper cap --%>
          <line
            x1={box.cap_x1}
            y1={box.whisker_high_y}
            x2={box.cap_x2}
            y2={box.whisker_high_y}
            stroke={box.color}
            stroke-width="1.5"
            style={box_anim_style(@animate, @animation_duration, box.delay_ms)}
          />
          <%!-- Lower cap --%>
          <line
            x1={box.cap_x1}
            y1={box.whisker_low_y}
            x2={box.cap_x2}
            y2={box.whisker_low_y}
            stroke={box.color}
            stroke-width="1.5"
            style={box_anim_style(@animate, @animation_duration, box.delay_ms)}
          />
          <%!-- Box (Q1 to Q3) --%>
          <rect
            x={box.box_x}
            y={box.box_y}
            width={box.box_w}
            height={box.box_h}
            rx="2"
            fill={box.color}
            fill-opacity="0.2"
            stroke={box.color}
            stroke-width="1.5"
            style={box_anim_style(@animate, @animation_duration, box.delay_ms)}
          />
          <%!-- Median line --%>
          <line
            x1={box.median_x1}
            y1={box.median_y}
            x2={box.median_x2}
            y2={box.median_y}
            stroke={box.color}
            stroke-width="2"
            style={box_anim_style(@animate, @animation_duration, box.delay_ms)}
          />
          <%!-- Outliers --%>
          <circle
            :for={o <- box.outliers}
            cx={o.cx}
            cy={o.cy}
            r="3"
            fill={box.color}
            fill-opacity="0.6"
            style={box_anim_style(@animate, @animation_duration, box.delay_ms)}
          />
        </g>
      </svg>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp box_anim_style(false, _dur, _delay), do: ""

  defp box_anim_style(true, dur, delay),
    do:
      "transform-box: fill-box; transform-origin: center; animation: phia-box-pop #{dur}ms ease-out #{delay}ms both"

  defp f(v), do: Float.round(v * 1.0, 2)
end
