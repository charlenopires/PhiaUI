defmodule PhiaUi.Components.SankeyChart do
  @moduledoc """
  Sankey flow diagram — pure SVG, zero JS.

  Shows flows between nodes as variable-width links.
  Node rectangles are positioned in columns, links are cubic Bezier paths.

  ## Examples

      <.sankey_chart data={%{
        nodes: [%{id: "a", label: "Source"}, %{id: "b", label: "Target"}],
        links: [%{source: "a", target: "b", value: 100}]
      }} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartMathHelpers
  alias PhiaUi.Components.Data.ChartViewport
  alias PhiaUi.Components.Data.ChartTheme

  attr :data, :map,
    default: %{nodes: [], links: []},
    doc: "Flow data: `%{nodes: [%{id, label}], links: [%{source, target, value}]}`."

  attr :colors, :list, default: [], doc: "Override default palette. CSS color strings."
  attr :node_width, :integer, default: 16, doc: "Width of node rectangles in pixels."
  attr :node_padding, :integer, default: 8, doc: "Vertical padding between nodes in same column."
  attr :link_opacity, :float, default: 0.4, doc: "Fill opacity for link paths."
  attr :animate, :boolean, default: true, doc: "Enable entrance animations."
  attr :animation_duration, :integer, default: 800, doc: "Animation duration in ms."
  attr :theme, :map, default: %{}, doc: "Chart theme overrides (see ChartTheme)."
  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def sankey_chart(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"
    vp = ChartViewport.build(vw: 500, vh: 300, pl: 8, pr: 8, pt: 8, pb: 8)
    theme = ChartTheme.merge(assigns.theme)

    layout =
      if assigns.data.nodes != [] and assigns.data.links != [] do
        ChartMathHelpers.sankey_layout(assigns.data, vp.cw, vp.ch)
      else
        %{nodes: [], links: []}
      end

    # Assign colors to nodes
    colored_nodes =
      layout.nodes
      |> Enum.with_index()
      |> Enum.map(fn {node, i} ->
        Map.put(node, :color, ChartHelpers.chart_color(i, assigns.colors))
      end)

    # Build link colors from source node color
    node_color_map = Map.new(colored_nodes, fn n -> {n.id, n.color} end)

    colored_links =
      layout.links
      |> Enum.with_index()
      |> Enum.map(fn {link, i} ->
        color = Map.get(node_color_map, link.source, ChartHelpers.chart_color(i, assigns.colors))
        Map.put(link, :color, color)
      end)

    assigns =
      assigns
      |> assign(:chart_id, chart_id)
      |> assign(:viewbox, ChartViewport.viewbox(vp))
      |> assign(:nodes, colored_nodes)
      |> assign(:links, colored_links)
      |> assign(:theme, theme)
      |> assign(:vp, vp)

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
        <g transform={"translate(#{@vp.pl}, #{@vp.pt})"}>
          <%!-- Links --%>
          <path
            :for={{link, i} <- Enum.with_index(@links)}
            d={link.path}
            fill={link.color}
            fill-opacity={@link_opacity}
            stroke="none"
            style={
              if @animate,
                do:
                  "animation: phia-sankey-flow #{@animation_duration}ms ease-out #{i * 40}ms both",
                else: ""
            }
          />
          <%!-- Nodes --%>
          <rect
            :for={{node, i} <- Enum.with_index(@nodes)}
            x={node.x}
            y={node.y}
            width={node.width}
            height={node.height}
            fill={node.color}
            rx="2"
            style={
              if @animate,
                do:
                  "transform-box: fill-box; transform-origin: center; animation: phia-fade-in #{@animation_duration}ms ease-out #{i * 30}ms both",
                else: ""
            }
          />
          <%!-- Node labels --%>
          <text
            :for={node <- @nodes}
            x={node.x + node.width + 4}
            y={node.y + node.height / 2}
            dominant-baseline="middle"
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
end
