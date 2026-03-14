defmodule PhiaUi.Components.RadialBarChart do
  @moduledoc """
  Radial bar chart with concentric arc rings — pure SVG, zero JS.

  Each ring represents one metric. The arc length is proportional to
  value/max. Rings animate in with staggered fade.

  ## Examples

      <.radial_bar_chart data={[
        %{label: "CPU",    value: 72, max: 100, color: "oklch(0.60 0.20 240)"},
        %{label: "Memory", value: 45, max: 100, color: "oklch(0.70 0.18 145)"},
        %{label: "Disk",   value: 88, max: 100, color: "oklch(0.65 0.22 30)"}
      ]} />

      <.radial_bar_chart
        data={[%{label: "Sales", value: 8500, max: 10000}]}
        size={:lg}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers

  # Ring geometry
  @cx 110.0
  @cy 110.0
  @r_start 35.0
  @ring_gap 14.0
  @stroke_w 10.0
  @vw 280
  @vh 220

  attr :data, :list,
    required: true,
    doc: "List of `%{label, value, max}` (and optional `:color`)."

  attr :size, :atom,
    default: :default,
    values: [:sm, :default, :lg],
    doc: "Overall chart size class."

  attr :animate, :boolean, default: true
  attr :animation_duration, :integer, default: 700
  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def radial_bar_chart(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"
    rings =
      assigns.data
      |> Enum.with_index()
      |> Enum.map(fn {item, i} ->
        r = @r_start + i * @ring_gap
        circ = 2 * :math.pi() * r
        ratio = item.value / max(item.max, 1) |> min(1.0) |> max(0.0)
        dash = Float.round(ratio * circ, 2)
        gap = Float.round(circ - dash, 2)
        track = Float.round(circ, 2)

        # Rotate to start from top (-90deg = top)
        # stroke-dashoffset = circ/4 positions start at top
        offset = Float.round(circ / 4, 2)

        color =
          Map.get(item, :color) ||
            ChartHelpers.chart_color(i, [])

        %{
          r: Float.round(r, 2),
          dash: dash,
          gap: gap,
          track: track,
          offset: offset,
          color: color,
          label: item.label,
          value: item.value,
          max: item.max,
          delay_ms: i * 80
        }
      end)

    assigns =
      assigns
      |> assign(:rings, rings)
      |> assign(:cx, @cx)
      |> assign(:cy, @cy)
      |> assign(:stroke_w, @stroke_w)
      |> assign(:viewbox, "0 0 #{@vw} #{@vh}")
      |> assign(:chart_id, chart_id)

    ~H"""
    <div
      class={cn(["w-full", if(@animate, do: "phia-chart-animate", else: ""), size_class(@size), @class])}
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
      >
        <title :if={@title}>{@title}</title>
        <desc :if={@description} id={"#{@chart_id}-desc"}>{@description}</desc>
        <%!-- Track rings (full circle, muted) --%>
        <circle
          :for={ring <- @rings}
          cx={@cx}
          cy={@cy}
          r={ring.r}
          fill="none"
          stroke="currentColor"
          stroke-width={@stroke_w}
          stroke-dasharray={"#{ring.track} #{ring.track}"}
          stroke-dashoffset={ring.offset}
          class="text-muted-foreground opacity-15"
        />

        <%!-- Value arcs --%>
        <circle
          :for={ring <- @rings}
          cx={@cx}
          cy={@cy}
          r={ring.r}
          fill="none"
          stroke={ring.color}
          stroke-width={@stroke_w}
          stroke-linecap="round"
          stroke-dasharray={"#{ring.dash} #{ring.gap}"}
          stroke-dashoffset={ring.offset}
          style={
            if @animate do
              "animation: phia-fade-in #{@animation_duration}ms ease-out #{ring.delay_ms}ms both"
            else
              ""
            end
          }
        />

        <%!-- Labels (right side) --%>
        <g :for={{ring, i} <- Enum.with_index(@rings)}>
          <circle cx="225" cy={8 + i * 18} r="4" fill={ring.color} />
          <text
            x="234"
            y={9 + i * 18}
            font-size="8.5"
            dominant-baseline="middle"
            class="fill-foreground"
          >{ring.label}</text>
          <text
            x="272"
            y={9 + i * 18}
            font-size="8"
            text-anchor="end"
            dominant-baseline="middle"
            class="fill-muted-foreground"
          >{ring.value}/{ring.max}</text>
        </g>
      </svg>
    </div>
    """
  end

  defp size_class(:sm), do: "h-36"
  defp size_class(:default), do: "h-48"
  defp size_class(:lg), do: "h-64"
end
