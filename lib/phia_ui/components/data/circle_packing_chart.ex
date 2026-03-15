defmodule PhiaUi.Components.CirclePackingChart do
  @moduledoc """
  Circle packing chart — pure SVG, zero JS.

  Renders nested circles representing hierarchical or flat data where each
  circle's area is proportional to its value. Uses spiral-based placement
  from `ChartMathHelpers.pack_circles/2`.

  ## Examples

      <.circle_packing_chart data={[
        %{label: "JavaScript", value: 65},
        %{label: "Python", value: 45},
        %{label: "Elixir", value: 25},
        %{label: "Rust", value: 20},
        %{label: "Go", value: 15}
      ]} />

      <.circle_packing_chart
        data={[%{label: "A", value: 100}, %{label: "B", value: 60}]}
        colors={["oklch(0.60 0.20 240)", "oklch(0.65 0.22 30)"]}
        show_labels={false}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartMathHelpers
  alias PhiaUi.Components.Data.ChartTheme

  attr :data, :list, default: [], doc: "Flat data: `[%{label, value}]`."
  attr :colors, :list, default: [], doc: "Override default palette. CSS color strings."
  attr :animate, :boolean, default: true, doc: "Enable entrance animations."
  attr :animation_duration, :integer, default: 600, doc: "Animation duration in ms."
  attr :show_labels, :boolean, default: true, doc: "Show labels inside circles."
  attr :theme, :map, default: %{}, doc: "Chart theme overrides (see ChartTheme)."
  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def circle_packing_chart(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"
    theme = ChartTheme.merge(assigns.theme)
    size = 300
    r = size / 2 - 10

    packed = ChartMathHelpers.pack_circles(assigns.data, r)

    colored =
      packed
      |> Enum.with_index()
      |> Enum.map(fn {c, i} ->
        %{
          cx: f(c.cx + size / 2),
          cy: f(c.cy + size / 2),
          r: c.r,
          label: c.label,
          value: c.value,
          color: ChartHelpers.chart_color(i, assigns.colors),
          delay: i * 50
        }
      end)

    assigns =
      assigns
      |> assign(:chart_id, chart_id)
      |> assign(:viewbox, "0 0 #{size} #{size}")
      |> assign(:circles, colored)
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
        <circle
          :for={c <- @circles}
          cx={c.cx}
          cy={c.cy}
          r={c.r}
          fill={c.color}
          fill-opacity="0.7"
          stroke={c.color}
          stroke-width="1"
          style={
            if @animate,
              do:
                "transform-box: fill-box; transform-origin: center; animation: phia-dot-pop #{@animation_duration}ms ease-out #{c.delay}ms both",
              else: ""
          }
        />
        <text
          :for={c <- @circles}
          :if={@show_labels && c.r > 15}
          x={c.cx}
          y={c.cy}
          text-anchor="middle"
          dominant-baseline="middle"
          font-size={min(c.r * 0.5, 12)}
          class="fill-white"
          style="pointer-events: none"
        >
          {c.label}
        </text>
      </svg>
    </div>
    """
  end

  defp f(v), do: Float.round(v * 1.0, 2)
end
