defmodule PhiaUi.Components.PieChart do
  @moduledoc """
  Pie chart with arc-path slices — pure SVG, zero JS.

  Each slice fades and scales in with a staggered `phia-dot-pop` animation.
  Supports an optional legend.

  ## Examples

      <.pie_chart data={[
        %{label: "Direct",   value: 40},
        %{label: "Organic",  value: 30},
        %{label: "Referral", value: 20},
        %{label: "Other",    value: 10}
      ]} />

      <.pie_chart
        data={[%{label: "A", value: 60}, %{label: "B", value: 40}]}
        colors={["oklch(0.60 0.20 240)", "oklch(0.65 0.22 30)"]}
        show_legend={true}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers

  @r 90
  @cx 110
  @cy 110
  @vw 300
  @vh 220

  attr :data, :list, required: true, doc: "List of `%{label, value}` (and optional `:color`)."
  attr :colors, :list, default: [], doc: "Override default palette."
  attr :show_labels, :boolean, default: false, doc: "Render percentage labels on slices."
  attr :show_legend, :boolean, default: true, doc: "Render color legend."
  attr :animate, :boolean, default: true, doc: "Enable entrance animations."
  attr :animation_duration, :integer, default: 600, doc: "Animation duration in ms."
  attr :class, :string, default: nil
  attr :rest, :global

  def pie_chart(assigns) do
    slices = ChartHelpers.pie_slices(assigns.data, @cx, @cy, @r, assigns.colors)

    # Add label info
    total = assigns.data |> Enum.map(& &1.value) |> Enum.sum() |> max(1)

    slices_with_labels =
      slices
      |> Enum.with_index()
      |> Enum.map(fn {s, i} ->
        item = Enum.at(assigns.data, i)
        pct = Float.round(item.value / total * 100, 1)
        Map.merge(s, %{label: item.label, pct: pct})
      end)

    assigns =
      assigns
      |> assign(:slices, slices_with_labels)
      |> assign(:viewbox, "0 0 #{@vw} #{@vh}")

    ~H"""
    <div
      class={cn(["w-full", if(@animate, do: "phia-chart-animate", else: ""), @class])}
      {@rest}
    >
      <svg viewBox={@viewbox} aria-hidden="true" class="w-full h-full overflow-visible">
        <%!-- Pie slices --%>
        <path
          :for={slice <- @slices}
          d={slice.path}
          fill={slice.color}
          stroke="var(--color-background, white)"
          stroke-width="1"
          style={
            if @animate do
              "transform-box: fill-box; transform-origin: center; animation: phia-dot-pop #{@animation_duration}ms ease-out #{slice.delay} both; #{slice.delay}"
            else
              ""
            end
          }
        />

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
      </svg>
    </div>
    """
  end
end
