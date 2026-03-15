defmodule PhiaUi.Components.LollipopChart do
  @moduledoc """
  Lollipop chart — pure SVG, zero JS.

  Thin stems with dot endpoints, a lightweight alternative to bar charts.
  Supports vertical and horizontal orientations.

  ## Examples

      <.lollipop_chart data={[
        %{label: "A", value: 120},
        %{label: "B", value: 80},
        %{label: "C", value: 150}
      ]} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartAxisHelpers
  alias PhiaUi.Components.Data.ChartViewport
  alias PhiaUi.Components.Data.ChartTheme

  attr :data, :list, default: [], doc: "Single-series shorthand: `[%{label, value}]`."

  attr :series, :list,
    default: [],
    doc: "Multi-series: `[%{name, data: [%{label, value}]}]`. Overrides `:data` when present."

  attr :variant, :atom,
    default: :vertical,
    values: [:vertical, :horizontal],
    doc: "Chart orientation."

  attr :colors, :list, default: [], doc: "Override default palette. CSS color strings."
  attr :dot_radius, :integer, default: 5, doc: "Radius of dot endpoints in pixels."
  attr :stem_width, :integer, default: 2, doc: "Width of stem lines in pixels."
  attr :show_grid, :boolean, default: true, doc: "Show grid lines."
  attr :show_labels, :boolean, default: true, doc: "Show axis tick labels."
  attr :animate, :boolean, default: true, doc: "Enable entrance animations."
  attr :animation_duration, :integer, default: 600, doc: "Animation duration in ms."
  attr :theme, :map, default: %{}, doc: "Chart theme overrides (see ChartTheme)."
  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def lollipop_chart(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"
    series = ChartHelpers.normalize_series(assigns.data, assigns.series)
    vp = ChartViewport.build()
    theme = ChartTheme.merge(assigns.theme)
    first_data = series |> List.first(%{data: []}) |> Map.get(:data, [])
    n = length(first_data)

    {y_ticks, _y_min, y_max_nice} = ChartHelpers.compute_y_domain(series, include_negative: false)

    lollipops =
      series
      |> Enum.with_index()
      |> Enum.flat_map(fn {s, si} ->
        color = ChartHelpers.chart_color(si, assigns.colors)

        s.data
        |> Enum.with_index()
        |> Enum.map(fn {item, gi} ->
          if assigns.variant == :horizontal do
            py = vp.pt + (gi + 0.5) * (vp.ch / max(n, 1))
            px = vp.pl + item.value / max(y_max_nice, 1) * vp.cw

            %{
              x1: f(vp.pl * 1.0),
              y1: f(py),
              x2: f(px),
              y2: f(py),
              cx: f(px),
              cy: f(py),
              color: color,
              delay: gi * 60
            }
          else
            px = vp.pl + (gi + 0.5) * (vp.cw / max(n, 1))
            py = vp.pt + vp.ch - item.value / max(y_max_nice, 1) * vp.ch
            base_y = vp.pt + vp.ch

            %{
              x1: f(px),
              y1: f(base_y * 1.0),
              x2: f(px),
              y2: f(py),
              cx: f(px),
              cy: f(py),
              color: color,
              delay: gi * 60
            }
          end
        end)
      end)

    tick_lines =
      Enum.map(y_ticks, fn tick ->
        py = f(vp.pt + vp.ch - tick / max(y_max_nice, 1) * vp.ch)
        %{py: py, label: ChartAxisHelpers.format_tick(tick * 1.0)}
      end)

    x_labels =
      first_data
      |> Enum.with_index()
      |> Enum.map(fn {item, i} ->
        if assigns.variant == :horizontal do
          py = vp.pt + (i + 0.5) * (vp.ch / max(n, 1))
          %{label: item.label, px: vp.pl - 4, py: f(py), anchor: "end", baseline: "middle"}
        else
          px = vp.pl + (i + 0.5) * (vp.cw / max(n, 1))
          %{label: item.label, px: f(px), py: vp.pt + vp.ch + 14, anchor: "middle", baseline: "auto"}
        end
      end)

    assigns =
      assigns
      |> assign(:chart_id, chart_id)
      |> assign(:viewbox, ChartViewport.viewbox(vp))
      |> assign(:lollipops, lollipops)
      |> assign(:tick_lines, tick_lines)
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
        <%!-- Grid lines (vertical orientation only) --%>
        <g :if={@show_grid && @variant == :vertical}>
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
        <%!-- Axis labels --%>
        <g :if={@show_labels}>
          <text
            :for={t <- @tick_lines}
            :if={@variant == :vertical}
            x={@grid_x1 - 4}
            y={t.py}
            text-anchor="end"
            dominant-baseline="middle"
            font-size={@theme.axis.font_size}
            class={@theme.axis.label_class}
          >
            {t.label}
          </text>
          <text
            :for={e <- @x_labels}
            x={e.px}
            y={e.py}
            text-anchor={e.anchor}
            dominant-baseline={e.baseline}
            font-size={@theme.axis.font_size}
            class={@theme.axis.label_class}
          >
            {e.label}
          </text>
        </g>
        <%!-- Stems and dots --%>
        <g :for={lp <- @lollipops}>
          <line
            x1={lp.x1}
            y1={lp.y1}
            x2={lp.x2}
            y2={lp.y2}
            stroke={lp.color}
            stroke-width={@stem_width}
            style={
              if @animate,
                do:
                  "animation: phia-fade-in #{@animation_duration}ms ease-out #{lp.delay}ms both",
                else: ""
            }
          />
          <circle
            cx={lp.cx}
            cy={lp.cy}
            r={@dot_radius}
            fill={lp.color}
            style={
              if @animate,
                do:
                  "transform-box: fill-box; transform-origin: center; animation: phia-dot-pop #{@animation_duration}ms ease-out #{lp.delay + 100}ms both",
                else: ""
            }
          />
        </g>
      </svg>
    </div>
    """
  end

  defp f(v), do: Float.round(v * 1.0, 2)
end
