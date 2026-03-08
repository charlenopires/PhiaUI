defmodule PhiaUi.Components.DonutChart do
  @moduledoc """
  Donut chart with a center slot — pure SVG, zero JS.

  Uses ring-shaped arc paths (outer + inner radius). Supports a `:center`
  slot for custom content (metric value, icon, etc.).

  ## Examples

      <.donut_chart data={[
        %{label: "Completed", value: 70},
        %{label: "Pending",   value: 20},
        %{label: "Failed",    value: 10}
      ]}>
        <:center>70%</:center>
      </.donut_chart>

      <.donut_chart
        data={[%{label: "Used", value: 80}, %{label: "Free", value: 20}]}
        hole_ratio={0.65}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers

  @r_outer 85
  @cx 110
  @cy 110
  @vw 300
  @vh 220

  attr :data, :list, required: true, doc: "List of `%{label, value}` (and optional `:color`)."
  attr :colors, :list, default: [], doc: "Override default palette."

  attr :hole_ratio, :float,
    default: 0.55,
    doc: "Ratio of inner radius to outer (0.3–0.8). Controls ring thickness."

  attr :show_legend, :boolean, default: true
  attr :animate, :boolean, default: true
  attr :animation_duration, :integer, default: 600

  attr :spacing, :integer,
    default: 0,
    doc: "Gap in pixels between slices (0-8)."

  attr :show_link_labels, :boolean, default: false, doc: "Show leader lines from slices to external labels."
  attr :class, :string, default: nil
  attr :rest, :global

  slot :center, doc: "Content rendered in the donut center (text, value, etc.)."

  def donut_chart(assigns) do
    r_inner = round(@r_outer * assigns.hole_ratio)
    slices =
      ChartHelpers.donut_slices(assigns.data, @cx, @cy, @r_outer, r_inner, assigns.colors,
        spacing: assigns.spacing
      )

    slices_with_labels =
      slices
      |> Enum.with_index()
      |> Enum.map(fn {s, i} ->
        item = Enum.at(assigns.data, i)
        Map.put(s, :label, if(item, do: item.label, else: ""))
      end)

    link_label_slices =
      if assigns.show_link_labels do
        total = assigns.data |> Enum.map(& &1.value) |> Enum.sum() |> max(1)
        start = -:math.pi() / 2

        {slices_info, _} =
          assigns.data
          |> Enum.with_index()
          |> Enum.map_reduce(start, fn {item, i}, acc ->
            ratio = item.value / total
            sweep = ratio * 2 * :math.pi()
            mid = acc + sweep / 2
            color = Map.get(item, :color) || ChartHelpers.chart_color(i, assigns.colors)
            info = %{mid_angle: mid, outer_radius: @r_outer, label: item.label, color: color, cx: @cx, cy: @cy}
            {info, acc + sweep}
          end)

        slices_info
      else
        []
      end

    assigns =
      assigns
      |> assign(:slices, slices_with_labels)
      |> assign(:link_label_slices, link_label_slices)
      |> assign(:cx, @cx)
      |> assign(:cy, @cy)
      |> assign(:viewbox, "0 0 #{@vw} #{@vh}")

    ~H"""
    <div
      class={cn(["w-full", if(@animate, do: "phia-chart-animate", else: ""), @class])}
      {@rest}
    >
      <svg viewBox={@viewbox} aria-hidden="true" class="w-full h-full overflow-visible">
        <%!-- Donut slices --%>
        <path
          :for={slice <- @slices}
          d={slice.path}
          fill={slice.color}
          stroke={donut_slice_stroke(@spacing)}
          stroke-width={donut_slice_stroke_width(@spacing)}
          style={
            if @animate do
              "transform-box: fill-box; transform-origin: center; animation: phia-dot-pop #{@animation_duration}ms ease-out #{slice.delay} both"
            else
              ""
            end
          }
        />

        <%!-- Center slot content --%>
        <foreignObject
          :if={@center != []}
          x={@cx - 50}
          y={@cy - 20}
          width="100"
          height="40"
        >
          <div
            xmlns="http://www.w3.org/1999/xhtml"
            class="flex h-full items-center justify-center text-center text-sm font-semibold"
          >
            {render_slot(@center)}
          </div>
        </foreignObject>

        <%!-- Legend --%>
        <g :if={@show_legend}>
          <g :for={{slice, i} <- Enum.with_index(@slices)}>
            <rect
              x="228"
              y={8 + i * 18}
              width="10"
              height="10"
              rx="2"
              fill={slice.color}
            />
            <text
              x="242"
              y={14 + i * 18}
              font-size="9"
              dominant-baseline="middle"
              class="fill-foreground"
            >{slice.label}</text>
          </g>
        </g>

        <%!-- Arc link labels --%>
        <PhiaUi.Components.Data.ArcLinkLabels.arc_link_labels
          :if={@show_link_labels}
          slices={@link_label_slices}
        />
      </svg>
    </div>
    """
  end

  # When spacing is active, no stroke is needed (the angular gap separates slices).
  defp donut_slice_stroke(spacing) when spacing > 0, do: "none"
  defp donut_slice_stroke(_spacing), do: "var(--color-background, white)"

  defp donut_slice_stroke_width(spacing) when spacing > 0, do: "0"
  defp donut_slice_stroke_width(_spacing), do: "1.5"
end
