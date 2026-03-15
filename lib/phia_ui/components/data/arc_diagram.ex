defmodule PhiaUi.Components.ArcDiagram do
  @moduledoc """
  Arc diagram — pure SVG, zero JS.

  Nodes arranged on a horizontal baseline with curved arcs connecting
  related nodes. Arc height is proportional to the distance between
  source and target nodes, and stroke width scales with link value.

  ## Examples

      <.arc_diagram
        nodes={["A", "B", "C", "D"]}
        links={[
          %{source: "A", target: "C", value: 3},
          %{source: "B", target: "D", value: 1}
        ]}
      />

      <.arc_diagram
        nodes={["Alpha", "Beta", "Gamma"]}
        links={[%{source: "Alpha", target: "Gamma", value: 2}]}
        colors={["oklch(0.60 0.20 240)", "oklch(0.65 0.22 30)"]}
        node_radius={8}
        show_labels={true}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartTheme

  attr :nodes, :list, default: [], doc: "List of node labels: `[\"A\", \"B\", \"C\"]`."
  attr :links, :list, default: [], doc: "Links: `[%{source: \"A\", target: \"B\", value: 1}]`."
  attr :colors, :list, default: [], doc: "Override default palette. CSS color strings."
  attr :node_radius, :integer, default: 6, doc: "Radius of node circles in pixels."
  attr :link_opacity, :float, default: 0.4, doc: "Opacity for link arcs (0.0–1.0)."
  attr :animate, :boolean, default: true, doc: "Enable entrance animations."
  attr :animation_duration, :integer, default: 800, doc: "Animation duration in ms."
  attr :show_labels, :boolean, default: true, doc: "Show node labels below the baseline."
  attr :theme, :map, default: %{}, doc: "Chart theme overrides (see ChartTheme)."
  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def arc_diagram(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"
    theme = ChartTheme.merge(assigns.theme)
    n = length(assigns.nodes)
    width = 400
    height = 200
    baseline_y = height - 30
    padding = 40

    node_positions =
      assigns.nodes
      |> Enum.with_index()
      |> Enum.map(fn {label, i} ->
        x =
          if n <= 1 do
            width / 2.0
          else
            padding + i / (n - 1) * (width - 2 * padding)
          end

        %{
          label: label,
          x: f(x),
          y: baseline_y,
          color: ChartHelpers.chart_color(i, assigns.colors),
          delay: i * 40
        }
      end)

    pos_map = Map.new(node_positions, fn nd -> {nd.label, nd.x} end)

    arcs =
      assigns.links
      |> Enum.with_index()
      |> Enum.map(fn {link, i} ->
        sx = Map.get(pos_map, link.source, 0.0)
        tx = Map.get(pos_map, link.target, 0.0)
        mid_x = (sx + tx) / 2
        arc_height = abs(tx - sx) * 0.4

        path =
          "M #{f(sx)} #{baseline_y} Q #{f(mid_x)} #{f(baseline_y - arc_height)} #{f(tx)} #{baseline_y}"

        color = ChartHelpers.chart_color(i, assigns.colors)
        width_val = max(Map.get(link, :value, 1) * 1.5, 1.0)

        %{path: path, color: color, width: f(width_val), delay: i * 30}
      end)

    assigns =
      assigns
      |> assign(:chart_id, chart_id)
      |> assign(:viewbox, "0 0 #{width} #{height}")
      |> assign(:node_positions, node_positions)
      |> assign(:arcs, arcs)
      |> assign(:baseline_y, baseline_y)
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
          :for={arc <- @arcs}
          d={arc.path}
          fill="none"
          stroke={arc.color}
          stroke-width={arc.width}
          stroke-opacity={@link_opacity}
          style={
            if @animate,
              do:
                "animation: phia-fade-in #{@animation_duration}ms ease-out #{arc.delay}ms both",
              else: ""
          }
        />
        <circle
          :for={node <- @node_positions}
          cx={node.x}
          cy={node.y}
          r={@node_radius}
          fill={node.color}
          style={
            if @animate,
              do:
                "transform-box: fill-box; transform-origin: center; animation: phia-dot-pop #{@animation_duration}ms ease-out #{node.delay}ms both",
              else: ""
          }
        />
        <g :if={@show_labels}>
          <text
            :for={node <- @node_positions}
            x={node.x}
            y={node.y + @node_radius + 12}
            text-anchor="middle"
            font-size={@theme.axis.font_size}
            class={@theme.axis.label_class}
          >
            {node.label}
          </text>
        </g>
      </svg>
    </div>
    """
  end

  defp f(v), do: Float.round(v * 1.0, 2)
end
