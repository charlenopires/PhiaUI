defmodule PhiaUi.Components.ParetoChart do
  @moduledoc """
  Pareto chart — pure SVG, zero JS.

  Combines descending bars with a cumulative percentage line.
  Shows the 80/20 principle visually with an optional threshold line.

  ## Examples

      <.pareto_chart data={[
        %{label: "Bug A", value: 45},
        %{label: "Bug B", value: 30},
        %{label: "Bug C", value: 15},
        %{label: "Bug D", value: 10}
      ]} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartAxisHelpers
  alias PhiaUi.Components.Data.ChartViewport
  alias PhiaUi.Components.Data.ChartTheme

  attr :data, :list, default: [], doc: "Data: `[%{label, value}]` — auto-sorted descending."
  attr :colors, :list, default: [], doc: "Override default palette. CSS color strings."
  attr :bar_color, :string, default: "oklch(0.60 0.20 240)", doc: "Fill color for bars."
  attr :line_color, :string, default: "oklch(0.60 0.25 0)", doc: "Stroke color for cumulative line."

  attr :show_threshold, :boolean, default: true, doc: "Show 80% threshold line."
  attr :threshold_pct, :float, default: 80.0, doc: "Threshold percentage value."
  attr :show_grid, :boolean, default: true, doc: "Show Y-axis grid lines."
  attr :show_labels, :boolean, default: true, doc: "Show axis tick labels."
  attr :animate, :boolean, default: true, doc: "Enable entrance animations."
  attr :animation_duration, :integer, default: 600, doc: "Animation duration in ms."
  attr :border_radius, :integer, default: 2, doc: "Corner radius for bars in pixels."
  attr :theme, :map, default: %{}, doc: "Chart theme overrides (see ChartTheme)."
  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def pareto_chart(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"
    vp = ChartViewport.build()
    theme = ChartTheme.merge(assigns.theme)

    # Sort descending and compute cumulative percentages
    sorted = Enum.sort_by(assigns.data, & &1.value, :desc)
    total = sorted |> Enum.map(& &1.value) |> Enum.sum() |> max(1)
    n = length(sorted)

    bars_data =
      sorted
      |> Enum.with_index()
      |> Enum.map(fn {item, i} ->
        %{label: item.label, value: item.value, index: i}
      end)

    {cumulative_pcts, _} =
      Enum.map_reduce(sorted, 0.0, fn item, acc ->
        new_acc = acc + item.value
        pct = new_acc / total * 100.0
        {Float.round(pct, 2), new_acc}
      end)

    # Y domain for bars (left axis)
    y_max = if sorted == [], do: 10, else: hd(sorted).value
    y_ticks = ChartAxisHelpers.nice_ticks(0, max(y_max, 1), 5)
    y_max_nice = Enum.max(y_ticks)

    group_w = vp.cw / max(n, 1)
    bar_w = group_w * 0.7

    bars =
      Enum.map(bars_data, fn bar ->
        h = max(bar.value / max(y_max_nice, 1) * vp.ch, 1.0)
        x = vp.pl + bar.index * group_w + (group_w - bar_w) / 2
        y = vp.pt + vp.ch - h

        %{x: f(x), y: f(y), w: f(bar_w), h: f(h), delay: bar.index * 60}
      end)

    # Cumulative line points (right axis: 0-100%)
    line_points =
      cumulative_pcts
      |> Enum.with_index()
      |> Enum.map(fn {pct, i} ->
        px_x = vp.pl + (i + 0.5) * group_w
        px_y = vp.pt + vp.ch - pct / 100.0 * vp.ch
        "#{f(px_x)},#{f(px_y)}"
      end)
      |> Enum.join(" ")

    line_length =
      if line_points != "", do: ChartHelpers.polyline_length(line_points), else: 0.0

    # Threshold line Y position
    threshold_y = f(vp.pt + vp.ch - assigns.threshold_pct / 100.0 * vp.ch)

    # Left axis tick rendering
    tick_lines =
      Enum.map(y_ticks, fn tick ->
        py = f(vp.pt + vp.ch - tick / max(y_max_nice, 1) * vp.ch)
        %{py: py, label: ChartAxisHelpers.format_tick(tick * 1.0)}
      end)

    # Right axis ticks (percentage)
    pct_ticks = [0, 20, 40, 60, 80, 100]

    right_tick_entries =
      Enum.map(pct_ticks, fn pct ->
        py = f(vp.pt + vp.ch - pct / 100.0 * vp.ch)
        %{py: py, label: "#{pct}%"}
      end)

    x_labels =
      sorted
      |> Enum.with_index()
      |> Enum.map(fn {item, i} ->
        %{label: item.label, px: f(vp.pl + (i + 0.5) * group_w), py: vp.pt + vp.ch + 14}
      end)

    assigns =
      assigns
      |> assign(:chart_id, chart_id)
      |> assign(:viewbox, ChartViewport.viewbox(vp))
      |> assign(:bars, bars)
      |> assign(:line_points, line_points)
      |> assign(:line_length, f(line_length))
      |> assign(:threshold_y, threshold_y)
      |> assign(:tick_lines, tick_lines)
      |> assign(:right_tick_entries, right_tick_entries)
      |> assign(:x_labels, x_labels)
      |> assign(:grid_x1, vp.pl)
      |> assign(:grid_x2, vp.pl + vp.cw)
      |> assign(:theme, theme)

    ~H"""
    <div class={cn(["w-full", if(@animate, do: "phia-chart-animate", else: ""), @class])} {@rest}>
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
        <%!-- Grid lines --%>
        <g :if={@show_grid}>
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
        <%!-- Left axis labels (values) --%>
        <g :if={@show_labels}>
          <text
            :for={t <- @tick_lines}
            x={@grid_x1 - 4}
            y={t.py}
            text-anchor="end"
            dominant-baseline="middle"
            font-size={@theme.axis.font_size}
            class={@theme.axis.label_class}
          >
            {t.label}
          </text>
        </g>
        <%!-- Right axis labels (percentages) --%>
        <g :if={@show_labels}>
          <text
            :for={t <- @right_tick_entries}
            x={@grid_x2 + 4}
            y={t.py}
            text-anchor="start"
            dominant-baseline="middle"
            font-size={@theme.axis.font_size}
            class={@theme.axis.label_class}
          >
            {t.label}
          </text>
        </g>
        <%!-- X axis labels --%>
        <g :if={@show_labels}>
          <text
            :for={e <- @x_labels}
            x={e.px}
            y={e.py}
            text-anchor="middle"
            font-size={@theme.axis.font_size}
            class={@theme.axis.label_class}
          >
            {e.label}
          </text>
        </g>
        <%!-- Bars --%>
        <rect
          :for={bar <- @bars}
          x={bar.x}
          y={bar.y}
          width={bar.w}
          height={bar.h}
          rx={@border_radius}
          fill={@bar_color}
          style={
            if @animate,
              do:
                "transform-box: fill-box; transform-origin: bottom; animation: phia-bar-grow #{@animation_duration}ms ease-out #{bar.delay}ms both",
              else: ""
          }
        />
        <%!-- Cumulative percentage line --%>
        <polyline
          :if={@line_points != ""}
          points={@line_points}
          fill="none"
          stroke={@line_color}
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          style={
            if @animate,
              do:
                "stroke-dasharray: #{@line_length}; stroke-dashoffset: #{@line_length}; animation: phia-line-draw #{@animation_duration}ms ease-out 200ms forwards",
              else: ""
          }
        />
        <%!-- Threshold line --%>
        <line
          :if={@show_threshold}
          x1={@grid_x1}
          y1={@threshold_y}
          x2={@grid_x2}
          y2={@threshold_y}
          stroke="currentColor"
          stroke-width="1"
          stroke-dasharray="4 2"
          class="text-muted-foreground"
        />
      </svg>
    </div>
    """
  end

  defp f(v), do: Float.round(v * 1.0, 2)
end
