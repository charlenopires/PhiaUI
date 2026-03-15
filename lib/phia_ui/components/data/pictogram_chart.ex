defmodule PhiaUi.Components.PictogramChart do
  @moduledoc """
  Pictogram chart — pure SVG, zero JS.

  Grid of repeated symbols representing proportional values.
  Each symbol represents a unit fraction of the total. Categories
  are distinguished by color, filling the grid left-to-right,
  bottom-to-top.

  ## Examples

      <.pictogram_chart
        data={[
          %{label: "Completed", value: 72},
          %{label: "Remaining", value: 28}
        ]}
      />

      <.pictogram_chart
        data={[
          %{label: "Chrome", value: 65},
          %{label: "Firefox", value: 20},
          %{label: "Safari", value: 15}
        ]}
        symbol={:square}
        cols={10}
        total={100}
        colors={["oklch(0.60 0.20 240)", "oklch(0.70 0.18 145)", "oklch(0.65 0.22 30)"]}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartTheme

  attr :data, :list, default: [], doc: "Category data: `[%{label, value}]`."
  attr :colors, :list, default: [], doc: "Override default palette. CSS color strings."
  attr :total, :integer, default: 100, doc: "Total number of symbols in the grid."
  attr :cols, :integer, default: 10, doc: "Number of columns in the grid."
  attr :symbol_size, :integer, default: 16, doc: "Size of each symbol in pixels."
  attr :symbol_gap, :integer, default: 4, doc: "Gap between symbols in pixels."
  attr :symbol, :atom, default: :circle, values: [:circle, :square, :person], doc: "Symbol shape."
  attr :animate, :boolean, default: true, doc: "Enable entrance animations."
  attr :animation_duration, :integer, default: 600, doc: "Animation duration in ms."
  attr :theme, :map, default: %{}, doc: "Chart theme overrides (see ChartTheme)."
  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def pictogram_chart(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"
    theme = ChartTheme.merge(assigns.theme)
    total_value = assigns.data |> Enum.map(& &1.value) |> Enum.sum() |> max(1)
    cell = assigns.symbol_size + assigns.symbol_gap

    {icons, _} =
      assigns.data
      |> Enum.with_index()
      |> Enum.map_reduce(0, fn {item, i}, used ->
        count = round(item.value / total_value * assigns.total)
        count = min(count, assigns.total - used)
        color = ChartHelpers.chart_color(i, assigns.colors)

        symbols =
          if count > 0 do
            Enum.map(used..(used + count - 1)//1, fn idx ->
              col = rem(idx, assigns.cols)
              row = div(idx, assigns.cols)
              x = col * cell
              y = row * cell
              %{x: x, y: y, color: color, delay: idx * 8}
            end)
          else
            []
          end

        {symbols, used + count}
      end)

    all_icons = List.flatten(icons)
    rows = div(assigns.total - 1, assigns.cols) + 1
    w = assigns.cols * cell - assigns.symbol_gap
    h = rows * cell - assigns.symbol_gap
    half = assigns.symbol_size / 2.0

    legend_items =
      assigns.data
      |> Enum.with_index()
      |> Enum.map(fn {item, i} ->
        %{label: item.label, color: ChartHelpers.chart_color(i, assigns.colors)}
      end)

    is_circle = assigns.symbol == :circle
    is_person = assigns.symbol == :person

    assigns =
      assigns
      |> assign(:chart_id, chart_id)
      |> assign(:viewbox, "0 0 #{w} #{h}")
      |> assign(:icons, all_icons)
      |> assign(:legend_items, legend_items)
      |> assign(:theme, theme)
      |> assign(:half, f(half))
      |> assign(:is_circle, is_circle)
      |> assign(:is_person, is_person)

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
        <%= if @is_person do %>
          <g :for={icon <- @icons}>
            <circle
              cx={icon.x + @half}
              cy={icon.y + @half * 0.3}
              r={@half * 0.28}
              fill={icon.color}
              style={
                if @animate,
                  do:
                    "transform-box: fill-box; transform-origin: center; animation: phia-dot-pop #{@animation_duration}ms ease-out #{icon.delay}ms both",
                  else: ""
              }
            />
            <path
              d={"M #{icon.x + @half * 0.35} #{icon.y + @symbol_size * 0.95} L #{icon.x + @half * 0.35} #{icon.y + @half * 0.7} Q #{icon.x + @half} #{icon.y + @half * 0.5} #{icon.x + @half * 1.65} #{icon.y + @half * 0.7} L #{icon.x + @half * 1.65} #{icon.y + @symbol_size * 0.95}"}
              fill={icon.color}
              style={
                if @animate,
                  do:
                    "transform-box: fill-box; transform-origin: center; animation: phia-dot-pop #{@animation_duration}ms ease-out #{icon.delay}ms both",
                  else: ""
              }
            />
          </g>
        <% else %>
          <%= if @is_circle do %>
            <circle
              :for={icon <- @icons}
              cx={icon.x + @half}
              cy={icon.y + @half}
              r={@half * 0.85}
              fill={icon.color}
              style={
                if @animate,
                  do:
                    "transform-box: fill-box; transform-origin: center; animation: phia-dot-pop #{@animation_duration}ms ease-out #{icon.delay}ms both",
                  else: ""
              }
            />
          <% else %>
            <rect
              :for={icon <- @icons}
              x={icon.x}
              y={icon.y}
              width={@symbol_size}
              height={@symbol_size}
              rx="2"
              fill={icon.color}
              style={
                if @animate,
                  do:
                    "transform-box: fill-box; transform-origin: center; animation: phia-dot-pop #{@animation_duration}ms ease-out #{icon.delay}ms both",
                  else: ""
              }
            />
          <% end %>
        <% end %>
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

  defp f(v), do: Float.round(v * 1.0, 2)
end
