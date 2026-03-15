defmodule PhiaUi.Components.RidgelineChart do
  @moduledoc """
  Ridgeline chart (joy plot) — pure SVG, zero JS.

  Renders multiple overlapping density distributions stacked vertically.
  Each row shows a Gaussian KDE of the given values. Useful for comparing
  distributions across categories.

  ## Examples

      <.ridgeline_chart data={[
        %{label: "Group A", values: [1, 2, 3, 3, 4, 5, 5, 5, 6, 7]},
        %{label: "Group B", values: [3, 4, 5, 5, 6, 7, 7, 8, 9, 10]},
        %{label: "Group C", values: [0, 1, 1, 2, 2, 3, 4, 5, 6, 8]}
      ]} />

      <.ridgeline_chart
        data={[%{label: "2024", values: [...]}, %{label: "2025", values: [...]}]}
        overlap={0.6}
        fill_opacity={0.5}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartMathHelpers
  alias PhiaUi.Components.Data.ChartViewport
  alias PhiaUi.Components.Data.ChartTheme

  attr :data, :list,
    default: [],
    doc: "Distribution data: `[%{label, values: [numbers]}]`."

  attr :colors, :list, default: [], doc: "Override default palette. CSS color strings."
  attr :overlap, :float, default: 0.5, doc: "Overlap factor between distributions (0-1)."
  attr :fill_opacity, :float, default: 0.6, doc: "Fill opacity for density areas."
  attr :resolution, :integer, default: 50, doc: "Number of KDE evaluation points."
  attr :bandwidth, :any, default: nil, doc: "KDE bandwidth (nil for Silverman's rule)."
  attr :animate, :boolean, default: true, doc: "Enable entrance animations."
  attr :animation_duration, :integer, default: 800, doc: "Animation duration in ms."
  attr :show_labels, :boolean, default: true, doc: "Show row labels."
  attr :theme, :map, default: %{}, doc: "Chart theme overrides (see ChartTheme)."
  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def ridgeline_chart(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"
    vp = ChartViewport.build(vh: 400, pb: 30)
    theme = ChartTheme.merge(assigns.theme)
    n = length(assigns.data)

    all_values = Enum.flat_map(assigns.data, & &1.values)
    x_min = if all_values == [], do: 0, else: Enum.min(all_values)
    x_max = if all_values == [], do: 10, else: Enum.max(all_values)
    x_range = max(x_max - x_min, 1)

    row_height = vp.ch / max(n, 1) * (1 + assigns.overlap)

    ridges =
      assigns.data
      |> Enum.with_index()
      |> Enum.reverse()
      |> Enum.map(fn {item, i} ->
        color = ChartHelpers.chart_color(i, assigns.colors)
        kde = ChartMathHelpers.kernel_density(item.values, assigns.resolution, assigns.bandwidth)
        max_density = kde |> Enum.map(& &1.y) |> Enum.max(fn -> 1 end)

        baseline_y = vp.pt + (n - 1 - i) * (vp.ch / max(n, 1))

        points =
          Enum.map(kde, fn %{x: x, y: y} ->
            px = vp.pl + (x - x_min) / x_range * vp.cw
            py = baseline_y - y / max(max_density, 0.001) * (row_height * 0.8)
            {f(px), f(py)}
          end)

        {fx, _fy} = List.first(points, {vp.pl * 1.0, baseline_y * 1.0})
        {lx, _ly} = List.last(points, {(vp.pl + vp.cw) * 1.0, baseline_y * 1.0})
        top = Enum.map_join(points, " L ", fn {x, y} -> "#{x} #{y}" end)
        path = "M #{f(fx)} #{f(baseline_y)} L #{top} L #{f(lx)} #{f(baseline_y)} Z"

        %{
          path: path,
          color: color,
          label: item.label,
          baseline_y: f(baseline_y),
          delay: i * 100
        }
      end)

    label_x = vp.pl - 4

    assigns =
      assigns
      |> assign(:chart_id, chart_id)
      |> assign(:viewbox, ChartViewport.viewbox(vp))
      |> assign(:ridges, ridges)
      |> assign(:label_x, label_x)
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
          :for={ridge <- @ridges}
          d={ridge.path}
          fill={ridge.color}
          fill-opacity={@fill_opacity}
          stroke={ridge.color}
          stroke-width="1"
          style={
            if @animate,
              do:
                "animation: phia-fade-in #{@animation_duration}ms ease-out #{ridge.delay}ms both",
              else: ""
          }
        />
        <g :if={@show_labels}>
          <text
            :for={ridge <- @ridges}
            x={@label_x}
            y={ridge.baseline_y}
            text-anchor="end"
            dominant-baseline="middle"
            font-size={@theme.axis.font_size}
            class={@theme.axis.label_class}
          >
            {ridge.label}
          </text>
        </g>
      </svg>
    </div>
    """
  end

  defp f(v), do: Float.round(v * 1.0, 2)
end
