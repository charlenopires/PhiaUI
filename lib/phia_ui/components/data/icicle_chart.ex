defmodule PhiaUi.Components.IcicleChart do
  @moduledoc """
  Icicle chart — pure SVG, zero JS.

  Renders a hierarchical horizontal partition chart where the root spans the
  full width and children subdivide the row below. Depth is shown top-to-bottom.

  ## Examples

      <.icicle_chart data={[
        %{label: "Root", value: 100, children: [
          %{label: "A", value: 60, children: [
            %{label: "A1", value: 30, children: []},
            %{label: "A2", value: 30, children: []}
          ]},
          %{label: "B", value: 40, children: []}
        ]}
      ]} />

      <.icicle_chart
        data={[%{label: "Total", value: 200, children: [...]}]}
        row_height={36}
        gap={2}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartTheme

  attr :data, :list,
    default: [],
    doc: "Hierarchical data: `[%{label, value, children: [...]}]`."

  attr :colors, :list, default: [], doc: "Override default palette. CSS color strings."
  attr :row_height, :integer, default: 30, doc: "Height of each depth row in pixels."
  attr :gap, :integer, default: 1, doc: "Gap between tiles in pixels."
  attr :animate, :boolean, default: true, doc: "Enable entrance animations."
  attr :animation_duration, :integer, default: 600, doc: "Animation duration in ms."
  attr :theme, :map, default: %{}, doc: "Chart theme overrides (see ChartTheme)."
  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def icicle_chart(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"
    theme = ChartTheme.merge(assigns.theme)
    width = 400
    total = sum_values(assigns.data)

    tiles = layout_icicle(assigns.data, 0, 0, width, assigns.row_height, assigns.gap, total, 0)

    max_depth =
      if tiles == [],
        do: 1,
        else: (tiles |> Enum.map(& &1.depth) |> Enum.max()) + 1

    height = max_depth * (assigns.row_height + assigns.gap)

    colored_tiles =
      tiles
      |> Enum.with_index()
      |> Enum.map(fn {tile, i} ->
        tile
        |> Map.put(:color, ChartHelpers.chart_color(tile.color_idx, assigns.colors))
        |> Map.put(:delay, i * 20)
      end)

    assigns =
      assigns
      |> assign(:chart_id, chart_id)
      |> assign(:viewbox, "0 0 #{width} #{height}")
      |> assign(:tiles, colored_tiles)
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
        <g :for={tile <- @tiles}>
          <rect
            x={tile.x}
            y={tile.y}
            width={max(tile.w - @gap, 1)}
            height={@row_height}
            rx="2"
            fill={tile.color}
            style={
              if @animate,
                do:
                  "transform-box: fill-box; transform-origin: top; animation: phia-fade-in #{@animation_duration}ms ease-out #{tile.delay}ms both",
                else: ""
            }
          />
          <text
            :if={tile.w > 30}
            x={tile.x + 4}
            y={tile.y + @row_height / 2}
            dominant-baseline="middle"
            font-size="8"
            class="fill-white"
            style="pointer-events: none"
          >
            {tile.label}
          </text>
        </g>
      </svg>
    </div>
    """
  end

  defp sum_values(data) do
    Enum.reduce(data, 0, fn item, acc ->
      v = Map.get(item, :value, 0)
      children = Map.get(item, :children, [])
      acc + max(v, if(children != [], do: sum_values(children), else: 0))
    end)
  end

  defp layout_icicle(data, x, y, w, row_h, gap, total, color_idx) do
    {tiles, _, _} =
      Enum.reduce(data, {[], x, color_idx}, fn item, {acc, cx, ci} ->
        v = max(Map.get(item, :value, 0), sum_values(Map.get(item, :children, [])))
        tile_w = v / max(total, 1) * w

        tile = %{
          x: f(cx),
          y: y,
          w: f(tile_w),
          label: item.label,
          depth: div(y, row_h + gap),
          color_idx: ci
        }

        children = Map.get(item, :children, [])

        child_tiles =
          if children != [] do
            layout_icicle(children, cx, y + row_h + gap, tile_w, row_h, gap, v, ci)
          else
            []
          end

        {acc ++ [tile | child_tiles], cx + tile_w, ci + 1}
      end)

    tiles
  end

  defp f(v), do: Float.round(v * 1.0, 2)
end
