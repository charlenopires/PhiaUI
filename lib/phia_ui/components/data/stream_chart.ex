defmodule PhiaUi.Components.StreamChart do
  @moduledoc """
  Stream graph (ThemeRiver) — pure SVG, zero JS.

  Renders stacked areas with wiggle baseline centering, creating a flowing
  stream-like visualization. Useful for showing how categories evolve over time.

  ## Examples

      <.stream_chart series={[
        %{name: "Product A", data: [%{label: "Jan", value: 10}, %{label: "Feb", value: 15}]},
        %{name: "Product B", data: [%{label: "Jan", value: 20}, %{label: "Feb", value: 12}]},
        %{name: "Product C", data: [%{label: "Jan", value: 8},  %{label: "Feb", value: 18}]}
      ]} />

      <.stream_chart
        data={[%{label: "Q1", value: 30}, %{label: "Q2", value: 45}, %{label: "Q3", value: 25}]}
        fill_opacity={0.8}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartMathHelpers
  alias PhiaUi.Components.Data.ChartViewport
  alias PhiaUi.Components.Data.ChartTheme

  attr :data, :list, default: [], doc: "Single-series shorthand: `[%{label, value}]`."

  attr :series, :list,
    default: [],
    doc: "Multi-series: `[%{name, data: [%{label, value}]}]`. Overrides `:data` when present."

  attr :colors, :list, default: [], doc: "Override default palette. CSS color strings."
  attr :fill_opacity, :float, default: 0.7, doc: "Fill opacity for stream areas (0.0-1.0)."
  attr :animate, :boolean, default: true, doc: "Enable entrance animations."
  attr :animation_duration, :integer, default: 800, doc: "Animation duration in ms."
  attr :show_labels, :boolean, default: true, doc: "Show x-axis labels."
  attr :theme, :map, default: %{}, doc: "Chart theme overrides (see ChartTheme)."
  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def stream_chart(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"
    series = ChartHelpers.normalize_series(assigns.data, assigns.series)
    vp = ChartViewport.build()
    theme = ChartTheme.merge(assigns.theme)
    n_points = series |> List.first(%{data: []}) |> Map.get(:data, []) |> length()

    # Compute wiggle baseline offsets
    baselines = ChartMathHelpers.wiggle_baseline(series)

    # Stack the series with cumulative bases
    stacked = ChartMathHelpers.stack_series(series)

    # Compute y domain including baseline offsets
    {all_tops, all_bottoms} = compute_y_bounds(stacked, baselines)

    y_min = if all_bottoms == [], do: 0, else: Enum.min(all_bottoms)
    y_max = if all_tops == [], do: 10, else: Enum.max(all_tops)
    y_range = max(y_max - y_min, 1)

    x0 = vp.pl * 1.0
    x1 = (vp.pl + vp.cw) * 1.0
    px_top = vp.pt * 1.0
    px_bot = (vp.pt + vp.ch) * 1.0
    px_range = px_bot - px_top

    stream_areas =
      stacked
      |> Enum.with_index()
      |> Enum.map(fn {s, si} ->
        color = ChartHelpers.chart_color(si, assigns.colors)
        count = length(s.data)

        top_points =
          s.data
          |> Enum.with_index()
          |> Enum.map(fn {item, di} ->
            base_offset = Enum.at(baselines, di, 0.0)
            px_x = x0 + di / max(count - 1, 1) * (x1 - x0)
            val = item.base + item.value + base_offset
            px_y = px_bot - (val - y_min) / y_range * px_range
            {f(px_x), f(px_y)}
          end)

        bottom_points =
          s.data
          |> Enum.with_index()
          |> Enum.map(fn {item, di} ->
            base_offset = Enum.at(baselines, di, 0.0)
            px_x = x0 + di / max(count - 1, 1) * (x1 - x0)
            val = item.base + base_offset
            px_y = px_bot - (val - y_min) / y_range * px_range
            {f(px_x), f(px_y)}
          end)
          |> Enum.reverse()

        path = build_area_path(top_points, bottom_points)
        %{path: path, color: color, delay: si * 80}
      end)

    x_labels =
      series
      |> List.first(%{data: []})
      |> Map.get(:data, [])
      |> Enum.with_index()
      |> Enum.map(fn {item, i} ->
        px = f(x0 + i / max(n_points - 1, 1) * (x1 - x0))
        %{label: item.label, px: px, py: px_bot + 14}
      end)

    assigns =
      assigns
      |> assign(:chart_id, chart_id)
      |> assign(:viewbox, ChartViewport.viewbox(vp))
      |> assign(:stream_areas, stream_areas)
      |> assign(:x_labels, x_labels)
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
        <path
          :for={area <- @stream_areas}
          d={area.path}
          fill={area.color}
          fill-opacity={@fill_opacity}
          stroke="none"
          style={
            if @animate,
              do:
                "animation: phia-fade-in #{@animation_duration}ms ease-out #{area.delay}ms both",
              else: ""
          }
        />
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
      </svg>
    </div>
    """
  end

  defp compute_y_bounds(stacked, baselines) do
    all_tops =
      for s <- stacked, {item, i} <- Enum.with_index(s.data) do
        base_offset = Enum.at(baselines, i, 0.0)
        item.base + item.value + base_offset
      end

    all_bottoms =
      for s <- stacked, {item, i} <- Enum.with_index(s.data) do
        base_offset = Enum.at(baselines, i, 0.0)
        item.base + base_offset
      end

    {all_tops, all_bottoms}
  end

  defp build_area_path(top_points, bottom_points) do
    top_part = Enum.map_join(top_points, " L ", fn {x, y} -> "#{x} #{y}" end)
    bottom_part = Enum.map_join(bottom_points, " L ", fn {x, y} -> "#{x} #{y}" end)
    {fx, fy} = List.first(top_points, {0, 0})
    "M #{fx} #{fy} L #{top_part} L #{bottom_part} Z"
  end

  defp f(v), do: Float.round(v * 1.0, 2)
end
