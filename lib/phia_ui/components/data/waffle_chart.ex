defmodule PhiaUi.Components.WaffleChart do
  @moduledoc """
  Waffle chart — pure SVG, zero JS.

  Renders a 10x10 grid of cells filled proportionally per category.
  Each cell represents 1% of the total when using default 10x10 grid.

  ## Examples

      <.waffle_chart data={[
        %{label: "Chrome", value: 65},
        %{label: "Firefox", value: 20},
        %{label: "Safari", value: 15}
      ]} />

      <.waffle_chart
        data={[%{label: "Yes", value: 72}, %{label: "No", value: 28}]}
        colors={["oklch(0.60 0.20 240)", "oklch(0.60 0.25 0)"]}
        cell_size={24}
        cell_gap={3}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartTheme

  attr :data, :list, default: [], doc: "Category data: `[%{label, value}]`."
  attr :colors, :list, default: [], doc: "Override default palette. CSS color strings."
  attr :cell_size, :integer, default: 20, doc: "Size of each cell in pixels."
  attr :cell_gap, :integer, default: 2, doc: "Gap between cells in pixels."
  attr :rows, :integer, default: 10, doc: "Number of rows in the grid."
  attr :cols, :integer, default: 10, doc: "Number of columns in the grid."
  attr :animate, :boolean, default: true, doc: "Enable entrance animations."
  attr :animation_duration, :integer, default: 600, doc: "Animation duration in ms."
  attr :theme, :map, default: %{}, doc: "Chart theme overrides (see ChartTheme)."
  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def waffle_chart(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"
    theme = ChartTheme.merge(assigns.theme)
    total_cells = assigns.rows * assigns.cols
    total_value = assigns.data |> Enum.map(& &1.value) |> Enum.sum() |> max(1)

    # Assign cells to categories proportionally
    {cells, _} =
      assigns.data
      |> Enum.with_index()
      |> Enum.map_reduce(0, fn {item, i}, used ->
        count = round(item.value / total_value * total_cells)
        count = min(count, total_cells - used)
        color = ChartHelpers.chart_color(i, assigns.colors)

        cell_list =
          if count > 0 do
            Enum.map(used..(used + count - 1)//1, fn idx ->
              row = div(idx, assigns.cols)
              col = rem(idx, assigns.cols)
              x = col * (assigns.cell_size + assigns.cell_gap)
              y = (assigns.rows - 1 - row) * (assigns.cell_size + assigns.cell_gap)
              %{x: x, y: y, color: color, delay: idx * 10}
            end)
          else
            []
          end

        {cell_list, used + count}
      end)

    all_cells = List.flatten(cells)
    w = assigns.cols * (assigns.cell_size + assigns.cell_gap) - assigns.cell_gap
    h = assigns.rows * (assigns.cell_size + assigns.cell_gap) - assigns.cell_gap
    viewbox = "0 0 #{w} #{h}"

    legend_items =
      assigns.data
      |> Enum.with_index()
      |> Enum.map(fn {item, i} ->
        %{label: item.label, color: ChartHelpers.chart_color(i, assigns.colors)}
      end)

    assigns =
      assigns
      |> assign(:chart_id, chart_id)
      |> assign(:viewbox, viewbox)
      |> assign(:cells, all_cells)
      |> assign(:legend_items, legend_items)
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
        <rect
          :for={cell <- @cells}
          x={cell.x}
          y={cell.y}
          width={@cell_size}
          height={@cell_size}
          rx="2"
          fill={cell.color}
          style={
            if @animate,
              do:
                "transform-box: fill-box; transform-origin: center; animation: phia-dot-pop #{@animation_duration}ms ease-out #{cell.delay}ms both",
              else: ""
          }
        />
      </svg>
      <div :if={@legend_items != []} class="flex flex-wrap gap-3 justify-center mt-2 text-xs">
        <div :for={item <- @legend_items} class="flex items-center gap-1.5">
          <span
            class="inline-block size-2.5 rounded-sm shrink-0"
            style={"background-color: #{item.color}"}
          />
          <span class="text-muted-foreground">{item.label}</span>
        </div>
      </div>
    </div>
    """
  end
end
