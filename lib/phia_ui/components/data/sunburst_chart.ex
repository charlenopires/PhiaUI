defmodule PhiaUi.Components.SunburstChart do
  @moduledoc """
  Sunburst chart for hierarchical data — pure SVG, zero JS.

  Renders concentric rings where each arc represents a node in the hierarchy.
  The angular span of each arc is proportional to its value. Children occupy
  the same angular range as their parent but in the next outer ring.

  ## Examples

      <.sunburst_chart data={[
        %{label: "A", value: 40, children: [
          %{label: "A1", value: 25, children: []},
          %{label: "A2", value: 15, children: []}
        ]},
        %{label: "B", value: 30, children: [
          %{label: "B1", value: 30, children: []}
        ]},
        %{label: "C", value: 30, children: []}
      ]} />

      <.sunburst_chart
        data={hierarchy}
        ring_width={25}
        inner_radius={50}
        colors={["oklch(0.60 0.20 240)", "oklch(0.70 0.18 145)", "oklch(0.65 0.22 30)"]}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartMathHelpers
  alias PhiaUi.Components.Data.ChartViewport

  attr :data, :list, default: [], doc: "Hierarchical data: `[%{label, value, children: [...]}]`."
  attr :colors, :list, default: [], doc: "Override default palette. CSS color strings."
  attr :ring_width, :integer, default: 30, doc: "Width of each concentric ring in pixels."
  attr :inner_radius, :integer, default: 40, doc: "Radius of the innermost ring."
  attr :show_grid, :boolean, default: false, doc: "Unused (included for API consistency)."
  attr :show_labels, :boolean, default: true, doc: "Show labels on arcs with sufficient angular span."
  attr :animate, :boolean, default: true, doc: "Enable entrance animations."
  attr :animation_duration, :integer, default: 600, doc: "Animation duration in ms."
  attr :theme, :map, default: %{}, doc: "Chart theme overrides (see ChartTheme)."
  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def sunburst_chart(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"
    polar = ChartViewport.default_polar(vw: 300, vh: 300, cx: 150, cy: 150, r: 130)
    cx = polar.cx
    cy = polar.cy

    # Compute arcs using ChartMathHelpers
    arcs =
      ChartMathHelpers.sunburst_arcs(assigns.data,
        ring_width: assigns.ring_width,
        inner_radius: assigns.inner_radius
      )

    # Build render data for each arc
    arc_renders =
      arcs
      |> Enum.with_index()
      |> Enum.map(fn {arc, i} ->
        color = ChartHelpers.chart_color(arc.depth + i, assigns.colors)
        path = arc_segment_path(cx, cy, arc.inner_r, arc.outer_r, arc.start_angle, arc.end_angle)
        sweep = arc.end_angle - arc.start_angle

        # Label position: mid-angle, mid-radius
        mid_angle = (arc.start_angle + arc.end_angle) / 2
        mid_r = (arc.inner_r + arc.outer_r) / 2
        label_x = cx + mid_r * :math.cos(mid_angle)
        label_y = cy + mid_r * :math.sin(mid_angle)

        # Only show label if arc is wide enough
        show_label = sweep > 0.3

        %{
          path: path,
          color: color,
          label: arc.label,
          label_x: f(label_x),
          label_y: f(label_y),
          show_label: show_label,
          delay_ms: i * 40,
          depth: arc.depth
        }
      end)

    viewbox = "0 0 #{polar.vw} #{polar.vh}"

    assigns =
      assigns
      |> assign(:arcs, arc_renders)
      |> assign(:viewbox, viewbox)
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

        <%!-- Sunburst arcs --%>
        <path
          :for={arc <- @arcs}
          d={arc.path}
          fill={arc.color}
          stroke="var(--color-background, white)"
          stroke-width="1"
          style={arc_anim_style(@animate, @animation_duration, arc.delay_ms)}
        />

        <%!-- Labels --%>
        <g :if={@show_labels}>
          <text
            :for={arc <- @arcs}
            :if={arc.show_label}
            x={arc.label_x}
            y={arc.label_y}
            text-anchor="middle"
            dominant-baseline="central"
            font-size="7"
            class="fill-foreground"
            style={"pointer-events: none; animation-delay: #{arc.delay_ms}ms"}
          >{arc.label}</text>
        </g>
      </svg>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp arc_segment_path(cx, cy, inner_r, outer_r, start_angle, end_angle) do
    # Guard against degenerate arcs
    sweep = end_angle - start_angle

    if sweep < 0.001 do
      ""
    else
      ox1 = cx + outer_r * :math.cos(start_angle)
      oy1 = cy + outer_r * :math.sin(start_angle)
      ox2 = cx + outer_r * :math.cos(end_angle)
      oy2 = cy + outer_r * :math.sin(end_angle)
      ix1 = cx + inner_r * :math.cos(end_angle)
      iy1 = cy + inner_r * :math.sin(end_angle)
      ix2 = cx + inner_r * :math.cos(start_angle)
      iy2 = cy + inner_r * :math.sin(start_angle)
      large = if sweep > :math.pi(), do: 1, else: 0

      "M #{f(ox1)} #{f(oy1)} A #{f(outer_r)} #{f(outer_r)} 0 #{large} 1 #{f(ox2)} #{f(oy2)} L #{f(ix1)} #{f(iy1)} A #{f(inner_r)} #{f(inner_r)} 0 #{large} 0 #{f(ix2)} #{f(iy2)} Z"
    end
  end

  defp arc_anim_style(false, _dur, _delay), do: ""

  defp arc_anim_style(true, dur, delay),
    do:
      "transform-box: fill-box; transform-origin: center; animation: phia-sunburst-arc #{dur}ms ease-out #{delay}ms both"

  defp f(v), do: Float.round(v * 1.0, 2)
end
