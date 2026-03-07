defmodule PhiaUi.Components.TreemapChart do
  @moduledoc """
  Hierarchical treemap with squarified tile layout — pure SVG, zero JS.

  Each tile's area is proportional to its value. Tiles animate in with
  staggered fade. Label is clipped to fit within each tile.

  ## Examples

      <.treemap_chart data={[
        %{label: "React",   value: 450},
        %{label: "Vue",     value: 280},
        %{label: "Angular", value: 210},
        %{label: "Svelte",  value: 120},
        %{label: "Solid",   value: 80}
      ]} />

      <.treemap_chart
        data={[%{label: "A", value: 60}, %{label: "B", value: 40}]}
        colors={["oklch(0.60 0.20 240)", "oklch(0.65 0.22 30)"]}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers

  @vw 400
  @vh 280

  attr :data, :list, required: true, doc: "List of `%{label, value}` (and optional `:color`)."
  attr :colors, :list, default: [], doc: "Override default palette."
  attr :animate, :boolean, default: true
  attr :animation_duration, :integer, default: 500
  attr :class, :string, default: nil
  attr :rest, :global

  def treemap_chart(assigns) do
    # Add index-based color if not provided
    data_with_colors =
      assigns.data
      |> Enum.with_index()
      |> Enum.map(fn {item, i} ->
        Map.put_new(item, :color, ChartHelpers.chart_color(i, assigns.colors))
      end)

    tiles = ChartHelpers.squarify(data_with_colors, 0.0, 0.0, @vw * 1.0, @vh * 1.0)

    tiles_with_delay =
      tiles
      |> Enum.with_index()
      |> Enum.map(fn {tile, i} ->
        Map.put(tile, :delay_ms, i * 40)
      end)

    assigns =
      assigns
      |> assign(:tiles, tiles_with_delay)
      |> assign(:viewbox, "0 0 #{@vw} #{@vh}")

    ~H"""
    <div
      class={cn(["w-full", if(@animate, do: "phia-chart-animate", else: ""), @class])}
      {@rest}
    >
      <svg viewBox={@viewbox} aria-hidden="true" class="w-full h-full overflow-visible">
        <%!-- Tiles --%>
        <g :for={tile <- @tiles}>
          <rect
            x={tile.x}
            y={tile.y}
            width={tile.w}
            height={tile.h}
            rx="3"
            fill={tile.item.color}
            fill-opacity="0.85"
            stroke="var(--color-background, white)"
            stroke-width="1.5"
            style={
              if @animate do
                "animation: phia-fade-in #{@animation_duration}ms ease-out #{tile.delay_ms}ms both"
              else
                ""
              end
            }
          />
          <%!-- Label (only if tile is big enough) --%>
          <text
            :if={tile.w >= 40 && tile.h >= 20}
            x={tile.x + tile.w / 2}
            y={tile.y + tile.h / 2}
            text-anchor="middle"
            dominant-baseline="middle"
            font-size={min(tile.h / 4, 12)}
            fill="white"
            font-weight="500"
          >{tile.item.label}</text>
        </g>
      </svg>
    </div>
    """
  end
end
