defmodule PhiaUi.Components.DotPlot do
  @moduledoc """
  Dot plot — pure SVG, zero JS.

  Renders categorical comparison with dots on parallel horizontal rows.
  Each category gets a row, and dots are positioned along the x-axis by value.
  Supports multi-series for comparing groups within each category.

  ## Examples

      <.dot_plot data={[
        %{label: "React", value: 85},
        %{label: "Vue", value: 72},
        %{label: "Svelte", value: 68},
        %{label: "Angular", value: 55}
      ]} />

      <.dot_plot
        series={[
          %{name: "2024", data: [%{label: "Q1", value: 30}, %{label: "Q2", value: 45}]},
          %{name: "2025", data: [%{label: "Q1", value: 38}, %{label: "Q2", value: 52}]}
        ]}
        colors={["oklch(0.60 0.20 240)", "oklch(0.65 0.22 30)"]}
        dot_radius={6}
      />
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

  attr :colors, :list, default: [], doc: "Override default palette. CSS color strings."
  attr :dot_radius, :integer, default: 5, doc: "Dot radius in pixels."
  attr :show_grid, :boolean, default: true, doc: "Show vertical grid lines."
  attr :show_labels, :boolean, default: true, doc: "Show axis and category labels."
  attr :animate, :boolean, default: true, doc: "Enable entrance animations."
  attr :animation_duration, :integer, default: 600, doc: "Animation duration in ms."
  attr :theme, :map, default: %{}, doc: "Chart theme overrides (see ChartTheme)."
  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def dot_plot(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"
    series = ChartHelpers.normalize_series(assigns.data, assigns.series)
    vp = ChartViewport.build()
    theme = ChartTheme.merge(assigns.theme)
    first_data = series |> List.first(%{data: []}) |> Map.get(:data, [])
    categories = Enum.map(first_data, & &1.label)
    n = length(categories)

    all_values = ChartHelpers.extract_all_values(series)
    x_min = if all_values == [], do: 0, else: min(0, Enum.min(all_values))
    x_max = if all_values == [], do: 10, else: Enum.max(all_values)
    x_ticks = ChartAxisHelpers.nice_ticks(x_min, max(x_max, 1), 5)
    x_min_nice = Enum.min(x_ticks)
    x_max_nice = Enum.max(x_ticks)
    x_range = max(x_max_nice - x_min_nice, 1)

    dots =
      series
      |> Enum.with_index()
      |> Enum.flat_map(fn {s, si} ->
        color = ChartHelpers.chart_color(si, assigns.colors)

        s.data
        |> Enum.with_index()
        |> Enum.map(fn {item, gi} ->
          py = vp.pt + (gi + 0.5) * (vp.ch / max(n, 1))
          px = vp.pl + (item.value - x_min_nice) / x_range * vp.cw
          %{cx: f(px), cy: f(py), color: color, delay: gi * 60 + si * 30}
        end)
      end)

    x_tick_entries =
      Enum.map(x_ticks, fn tick ->
        px = f(vp.pl + (tick - x_min_nice) / x_range * vp.cw)
        %{px: px, label: ChartAxisHelpers.format_tick(tick * 1.0)}
      end)

    cat_labels =
      categories
      |> Enum.with_index()
      |> Enum.map(fn {cat, i} ->
        py = vp.pt + (i + 0.5) * (vp.ch / max(n, 1))
        %{label: cat, px: vp.pl - 4, py: f(py)}
      end)

    grid_y1 = vp.pt
    grid_y2 = vp.pt + vp.ch
    bottom_y = vp.pt + vp.ch + 14

    assigns =
      assigns
      |> assign(:chart_id, chart_id)
      |> assign(:viewbox, ChartViewport.viewbox(vp))
      |> assign(:dots, dots)
      |> assign(:x_tick_entries, x_tick_entries)
      |> assign(:cat_labels, cat_labels)
      |> assign(:grid_y1, grid_y1)
      |> assign(:grid_y2, grid_y2)
      |> assign(:bottom_y, bottom_y)
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
          <text
            :for={c <- @cat_labels}
            x={c.px}
            y={c.py}
            text-anchor="end"
            dominant-baseline="middle"
            font-size={@theme.axis.font_size}
            class={@theme.axis.label_class}
          >
            {c.label}
          </text>
        </g>
        <circle
          :for={dot <- @dots}
          cx={dot.cx}
          cy={dot.cy}
          r={@dot_radius}
          fill={dot.color}
          style={
            if @animate,
              do:
                "transform-box: fill-box; transform-origin: center; animation: phia-dot-pop #{@animation_duration}ms ease-out #{dot.delay}ms both",
              else: ""
          }
        />
      </svg>
    </div>
    """
  end

  defp f(v), do: Float.round(v * 1.0, 2)
end
