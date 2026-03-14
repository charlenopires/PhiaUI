defmodule PhiaUi.Components.SlopeChart do
  @moduledoc """
  Slope chart — before/after comparison with diagonal lines — pure SVG, zero JS.

  Useful for showing rank or value changes between two time periods.
  Lines animate in with a dashoffset draw effect.

  ## Examples

      <.slope_chart
        data={[
          %{label: "Product A", from: 80, to: 95},
          %{label: "Product B", from: 60, to: 45},
          %{label: "Product C", from: 75, to: 70}
        ]}
        left_label="2023"
        right_label="2024"
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartAxisHelpers

  @vw 300
  @vh 280
  @px_left 70
  @px_right 230
  @pt 30
  @pb 20

  attr :data, :list, required: true, doc: "List of `%{label, from, to}`."
  attr :left_label, :string, default: "Before"
  attr :right_label, :string, default: "After"
  attr :colors, :list, default: [], doc: "Override default palette."
  attr :animate, :boolean, default: true
  attr :animation_duration, :integer, default: 700
  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def slope_chart(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"

    ch = @vh - @pt - @pb

    all_vals =
      Enum.flat_map(assigns.data, fn d -> [d.from, d.to] end)

    {y_min, y_max} =
      if all_vals == [] do
        {0, 10}
      else
        y_mn = Enum.min(all_vals)
        y_mx = Enum.max(all_vals)
        ticks = ChartAxisHelpers.nice_ticks(y_mn, y_mx, 5)
        {Enum.min(ticks), Enum.max(ticks)}
      end

    y_range = max(y_max - y_min, 1)

    slope_lines =
      assigns.data
      |> Enum.with_index()
      |> Enum.map(fn {item, i} ->
        ly = @pt + ch - (item.from - y_min) / y_range * ch
        ry = @pt + ch - (item.to - y_min) / y_range * ch
        len = :math.sqrt(:math.pow(@px_right - @px_left, 2) + :math.pow(ry - ly, 2))
        color = ChartHelpers.chart_color(i, assigns.colors)

        %{
          x1: @px_left,
          y1: Float.round(ly, 2),
          x2: @px_right,
          y2: Float.round(ry, 2),
          len: Float.round(len, 2),
          color: color,
          label: item.label,
          from_val: item.from,
          to_val: item.to,
          delay_ms: i * 80
        }
      end)

    assigns =
      assigns
      |> assign(:slope_lines, slope_lines)
      |> assign(:header_y, @pt - 12)
      |> assign(:left_x, @px_left)
      |> assign(:right_x, @px_right)
      |> assign(:pt, @pt)
      |> assign(:pb, @pb)
      |> assign(:vh, @vh)
      |> assign(:chart_id, chart_id)
      |> assign(:viewbox, "0 0 #{@vw} #{@vh}")

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
      >
        <title :if={@title}>{@title}</title>
        <desc :if={@description} id={"#{@chart_id}-desc"}>{@description}</desc>
        <%!-- Column headers --%>
        <text
          x={@left_x}
          y={@header_y}
          text-anchor="middle"
          font-size="10"
          font-weight="600"
          class="fill-foreground"
        >{@left_label}</text>
        <text
          x={@right_x}
          y={@header_y}
          text-anchor="middle"
          font-size="10"
          font-weight="600"
          class="fill-foreground"
        >{@right_label}</text>

        <%!-- Axis lines --%>
        <line
          x1={@left_x}
          y1={@pt - 4}
          x2={@left_x}
          y2={@vh - @pb}
          stroke="currentColor"
          stroke-width="1"
          class="text-border"
        />
        <line
          x1={@right_x}
          y1={@pt - 4}
          x2={@right_x}
          y2={@vh - @pb}
          stroke="currentColor"
          stroke-width="1"
          class="text-border"
        />


        <%!-- Slope lines --%>
        <line
          :for={sl <- @slope_lines}
          x1={sl.x1}
          y1={sl.y1}
          x2={sl.x2}
          y2={sl.y2}
          stroke={sl.color}
          stroke-width="2"
          stroke-linecap="round"
          style={
            if @animate do
              "stroke-dasharray: #{sl.len}; stroke-dashoffset: #{sl.len}; animation: phia-line-draw #{@animation_duration}ms ease-out #{sl.delay_ms}ms forwards"
            else
              ""
            end
          }
        />

        <%!-- Left dots + labels --%>
        <g :for={sl <- @slope_lines}>
          <circle cx={sl.x1} cy={sl.y1} r="3" fill={sl.color} />
          <text
            x={sl.x1 - 7}
            y={sl.y1}
            text-anchor="end"
            dominant-baseline="middle"
            font-size="8"
            class="fill-foreground"
          >{sl.label} ({sl.from_val})</text>
        </g>

        <%!-- Right dots + values --%>
        <g :for={sl <- @slope_lines}>
          <circle cx={sl.x2} cy={sl.y2} r="3" fill={sl.color} />
          <text
            x={sl.x2 + 7}
            y={sl.y2}
            text-anchor="start"
            dominant-baseline="middle"
            font-size="8"
            class="fill-foreground"
          >{sl.to_val}</text>
        </g>
      </svg>
    </div>
    """
  end
end
