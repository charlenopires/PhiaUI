defmodule PhiaUi.Components.ChordChart do
  @moduledoc """
  Chord diagram — pure SVG, zero JS.

  Renders circular arcs connected by ribbons from an adjacency matrix.
  Each node gets an arc proportional to its total flow, and ribbons
  connect nodes with quadratic Bezier curves through the center.

  ## Examples

      <.chord_chart
        matrix={[
          [0, 10, 5, 3],
          [10, 0, 8, 2],
          [5, 8, 0, 6],
          [3, 2, 6, 0]
        ]}
        labels={["Sales", "Marketing", "Engineering", "Support"]}
      />

      <.chord_chart
        matrix={[[0, 20], [15, 0]]}
        labels={["Source", "Target"]}
        ribbon_opacity={0.4}
        arc_width={20}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartMathHelpers
  alias PhiaUi.Components.Data.ChartTheme

  attr :matrix, :list, default: [], doc: "Adjacency matrix (list of lists)."
  attr :labels, :list, default: [], doc: "Label for each row/column."
  attr :colors, :list, default: [], doc: "Override default palette. CSS color strings."
  attr :arc_width, :integer, default: 16, doc: "Width of outer arcs in pixels."
  attr :ribbon_opacity, :float, default: 0.5, doc: "Fill opacity for ribbon paths."
  attr :animate, :boolean, default: true, doc: "Enable entrance animations."
  attr :animation_duration, :integer, default: 800, doc: "Animation duration in ms."
  attr :theme, :map, default: %{}, doc: "Chart theme overrides (see ChartTheme)."
  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def chord_chart(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"
    theme = ChartTheme.merge(assigns.theme)
    size = 300
    cx = size / 2
    cy = size / 2
    outer_r = size / 2 - 20
    inner_r = outer_r - assigns.arc_width

    layout =
      if assigns.matrix != [] and assigns.labels != [] do
        ChartMathHelpers.chord_layout(assigns.matrix, assigns.labels)
      else
        %{arcs: [], ribbons: []}
      end

    arcs =
      layout.arcs
      |> Enum.with_index()
      |> Enum.map(fn {arc, i} ->
        color = ChartHelpers.chart_color(i, assigns.colors)
        path = arc_segment(cx, cy, inner_r, outer_r, arc.start_angle, arc.end_angle)
        mid_angle = (arc.start_angle + arc.end_angle) / 2
        lx = cx + (outer_r + 12) * :math.cos(mid_angle)
        ly = cy + (outer_r + 12) * :math.sin(mid_angle)
        %{path: path, color: color, label: arc.label, lx: f(lx), ly: f(ly), delay: i * 40}
      end)

    ribbons =
      layout.ribbons
      |> Enum.with_index()
      |> Enum.map(fn {ribbon, i} ->
        src = ribbon.source_arc
        tgt = ribbon.target_arc
        color_idx = Enum.find_index(assigns.labels, &(&1 == ribbon.source)) || i
        color = ChartHelpers.chart_color(color_idx, assigns.colors)
        path = ribbon_path(cx, cy, inner_r, src.start_angle, src.end_angle, tgt.start_angle, tgt.end_angle)
        %{path: path, color: color, delay: i * 30}
      end)

    assigns =
      assigns
      |> assign(:chart_id, chart_id)
      |> assign(:viewbox, "0 0 #{size} #{size}")
      |> assign(:arcs, arcs)
      |> assign(:ribbons, ribbons)
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
          :for={ribbon <- @ribbons}
          d={ribbon.path}
          fill={ribbon.color}
          fill-opacity={@ribbon_opacity}
          style={
            if @animate,
              do:
                "animation: phia-fade-in #{@animation_duration}ms ease-out #{ribbon.delay}ms both",
              else: ""
          }
        />
        <path
          :for={arc <- @arcs}
          d={arc.path}
          fill={arc.color}
          style={
            if @animate,
              do:
                "animation: phia-fade-in #{@animation_duration}ms ease-out #{arc.delay}ms both",
              else: ""
          }
        />
        <text
          :for={arc <- @arcs}
          x={arc.lx}
          y={arc.ly}
          text-anchor="middle"
          dominant-baseline="middle"
          font-size={@theme.axis.font_size}
          class={@theme.axis.label_class}
        >
          {arc.label}
        </text>
      </svg>
    </div>
    """
  end

  defp arc_segment(cx, cy, inner_r, outer_r, a, b) do
    ox1 = cx + outer_r * :math.cos(a)
    oy1 = cy + outer_r * :math.sin(a)
    ox2 = cx + outer_r * :math.cos(b)
    oy2 = cy + outer_r * :math.sin(b)
    ix1 = cx + inner_r * :math.cos(b)
    iy1 = cy + inner_r * :math.sin(b)
    ix2 = cx + inner_r * :math.cos(a)
    iy2 = cy + inner_r * :math.sin(a)
    large = if b - a > :math.pi(), do: 1, else: 0

    "M #{f(ox1)} #{f(oy1)} A #{f(outer_r)} #{f(outer_r)} 0 #{large} 1 #{f(ox2)} #{f(oy2)} L #{f(ix1)} #{f(iy1)} A #{f(inner_r)} #{f(inner_r)} 0 #{large} 0 #{f(ix2)} #{f(iy2)} Z"
  end

  defp ribbon_path(cx, cy, r, sa1, sa2, ta1, ta2) do
    s1x = cx + r * :math.cos(sa1)
    s1y = cy + r * :math.sin(sa1)
    s2x = cx + r * :math.cos(sa2)
    s2y = cy + r * :math.sin(sa2)
    t1x = cx + r * :math.cos(ta1)
    t1y = cy + r * :math.sin(ta1)
    t2x = cx + r * :math.cos(ta2)
    t2y = cy + r * :math.sin(ta2)

    "M #{f(s1x)} #{f(s1y)} Q #{f(cx)} #{f(cy)} #{f(t1x)} #{f(t1y)} A #{f(r)} #{f(r)} 0 0 1 #{f(t2x)} #{f(t2y)} Q #{f(cx)} #{f(cy)} #{f(s2x)} #{f(s2y)} A #{f(r)} #{f(r)} 0 0 1 #{f(s1x)} #{f(s1y)} Z"
  end

  defp f(v), do: Float.round(v * 1.0, 2)
end
