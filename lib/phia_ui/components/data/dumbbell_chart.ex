defmodule PhiaUi.Components.DumbbellChart do
  @moduledoc """
  Dumbbell chart — pure SVG, zero JS.

  Shows before/after comparison with two dots connected by a bar.
  Horizontal orientation: categories on Y-axis, values on X-axis.

  ## Examples

      <.dumbbell_chart data={[
        %{label: "2023", start_value: 65, end_value: 85},
        %{label: "2024", start_value: 70, end_value: 92}
      ]} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartAxisHelpers
  alias PhiaUi.Components.Data.ChartViewport
  alias PhiaUi.Components.Data.ChartTheme

  attr :data, :list, default: [], doc: "Data: `[%{label, start_value, end_value}]`."
  attr :start_color, :string, default: "oklch(0.65 0.20 300)", doc: "Fill color for start dots."
  attr :end_color, :string, default: "oklch(0.60 0.20 240)", doc: "Fill color for end dots."
  attr :bar_color, :string, default: "oklch(0.75 0.05 0)", doc: "Stroke color for connecting bar."
  attr :dot_radius, :integer, default: 5, doc: "Radius of dot endpoints in pixels."
  attr :show_grid, :boolean, default: true, doc: "Show X-axis grid lines."
  attr :show_labels, :boolean, default: true, doc: "Show axis tick labels."
  attr :animate, :boolean, default: true, doc: "Enable entrance animations."
  attr :animation_duration, :integer, default: 600, doc: "Animation duration in ms."
  attr :theme, :map, default: %{}, doc: "Chart theme overrides (see ChartTheme)."
  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def dumbbell_chart(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"
    vp = ChartViewport.build()
    theme = ChartTheme.merge(assigns.theme)
    n = length(assigns.data)

    all_values = Enum.flat_map(assigns.data, fn d -> [d.start_value, d.end_value] end)
    x_min = if all_values == [], do: 0, else: min(0, Enum.min(all_values))
    x_max = if all_values == [], do: 10, else: Enum.max(all_values)
    x_ticks = ChartAxisHelpers.nice_ticks(x_min, max(x_max, 1), 5)
    x_min_nice = Enum.min(x_ticks)
    x_max_nice = Enum.max(x_ticks)
    x_range = max(x_max_nice - x_min_nice, 1)

    dumbbells =
      assigns.data
      |> Enum.with_index()
      |> Enum.map(fn {item, i} ->
        py = vp.pt + (i + 0.5) * (vp.ch / max(n, 1))
        px_start = vp.pl + (item.start_value - x_min_nice) / x_range * vp.cw
        px_end = vp.pl + (item.end_value - x_min_nice) / x_range * vp.cw
        %{py: f(py), px_start: f(px_start), px_end: f(px_end), label: item.label, delay: i * 80}
      end)

    x_tick_entries =
      Enum.map(x_ticks, fn tick ->
        px = f(vp.pl + (tick - x_min_nice) / x_range * vp.cw)
        %{px: px, label: ChartAxisHelpers.format_tick(tick * 1.0)}
      end)

    assigns =
      assigns
      |> assign(:chart_id, chart_id)
      |> assign(:viewbox, ChartViewport.viewbox(vp))
      |> assign(:dumbbells, dumbbells)
      |> assign(:x_tick_entries, x_tick_entries)
      |> assign(:grid_y1, vp.pt)
      |> assign(:grid_y2, vp.pt + vp.ch)
      |> assign(:bottom_y, vp.pt + vp.ch + 14)
      |> assign(:label_x, vp.pl - 4)
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
        <%!-- Vertical grid lines --%>
        <g :if={@show_grid}>
          <line
            :for={t <- @x_tick_entries}
            x1={t.px}
            y1={@grid_y1}
            x2={t.px}
            y2={@grid_y2}
            stroke="currentColor"
            stroke-width={@theme.grid.stroke_width}
            class={@theme.grid.stroke_class}
          />
        </g>
        <%!-- X axis labels (bottom) --%>
        <g :if={@show_labels}>
          <text
            :for={t <- @x_tick_entries}
            x={t.px}
            y={@bottom_y}
            text-anchor="middle"
            font-size={@theme.axis.font_size}
            class={@theme.axis.label_class}
          >
            {t.label}
          </text>
          <%!-- Y axis labels (category names) --%>
          <text
            :for={db <- @dumbbells}
            x={@label_x}
            y={db.py}
            text-anchor="end"
            dominant-baseline="middle"
            font-size={@theme.axis.font_size}
            class={@theme.axis.label_class}
          >
            {db.label}
          </text>
        </g>
        <%!-- Dumbbell elements --%>
        <g :for={db <- @dumbbells}>
          <%!-- Connecting bar --%>
          <line
            x1={db.px_start}
            y1={db.py}
            x2={db.px_end}
            y2={db.py}
            stroke={@bar_color}
            stroke-width="3"
            style={
              if @animate,
                do:
                  "animation: phia-fade-in #{@animation_duration}ms ease-out #{db.delay}ms both",
                else: ""
            }
          />
          <%!-- Start dot --%>
          <circle
            cx={db.px_start}
            cy={db.py}
            r={@dot_radius}
            fill={@start_color}
            style={
              if @animate,
                do:
                  "transform-box: fill-box; transform-origin: center; animation: phia-dot-pop #{@animation_duration}ms ease-out #{db.delay + 100}ms both",
                else: ""
            }
          />
          <%!-- End dot --%>
          <circle
            cx={db.px_end}
            cy={db.py}
            r={@dot_radius}
            fill={@end_color}
            style={
              if @animate,
                do:
                  "transform-box: fill-box; transform-origin: center; animation: phia-dot-pop #{@animation_duration}ms ease-out #{db.delay + 150}ms both",
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
