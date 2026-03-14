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

  attr :spacing, :integer,
    default: 0,
    doc: "Gap in pixels between slices (0-8). Matches Chart.js ArcElement spacing pattern."

  attr :corner_radius, :integer,
    default: 0,
    doc: "Border radius for slice corners in pixels. Simulated via round stroke caps."

  attr :show_link_labels, :boolean, default: false, doc: "Show leader lines from slices to external labels."

  attr :show_values, :boolean, default: false, doc: "Show data values alongside labels in the legend."

  attr :active_shape, :boolean,
    default: false,
    doc: "Enable hover expand effect on slices (Recharts activeShape pattern)."

  attr :active_expand, :integer,
    default: 6,
    doc: "Radius expansion in px on hover when active_shape is true."

  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def pie_chart(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"

    slices =
      ChartHelpers.pie_slices(assigns.data, @cx, @cy, @r, assigns.colors,
        spacing: assigns.spacing
      )

    # Add label info
    total = assigns.data |> Enum.map(& &1.value) |> Enum.sum() |> max(1)

    # Compute active (expanded) paths if active_shape is enabled
    active_paths =
      if assigns.active_shape do
        start = -:math.pi() / 2
        spacing = assigns.spacing
        angle_gap = if spacing > 0 and @r > 0, do: spacing / @r, else: 0.0

        {paths, _} =
          assigns.data
          |> Enum.map_reduce(start, fn item, acc ->
            ratio = item.value / total
            sweep = ratio * 2 * :math.pi()
            end_angle = acc + sweep
            a = acc + angle_gap / 2
            b = end_angle - angle_gap / 2
            path = if b > a, do: ChartHelpers.expand_arc_path(@cx, @cy, @r, a, b, assigns.active_expand), else: nil
            {path, end_angle}
          end)

        paths
      else
        []
      end

    slices_with_labels =
      slices
      |> Enum.with_index()
      |> Enum.map(fn {s, i} ->
        item = Enum.at(assigns.data, i)
        pct = Float.round(item.value / total * 100, 1)
        active_path = Enum.at(active_paths, i)
        Map.merge(s, %{label: item.label, pct: pct, active_path: active_path})
      end)

    link_label_slices =
      if assigns.show_link_labels do
        start = -:math.pi() / 2

        {slices_info, _} =
          assigns.data
          |> Enum.with_index()
          |> Enum.map_reduce(start, fn {item, i}, acc ->
            ratio = item.value / total
            sweep = ratio * 2 * :math.pi()
            mid = acc + sweep / 2
            color = Map.get(item, :color) || ChartHelpers.chart_color(i, assigns.colors)
            info = %{mid_angle: mid, outer_radius: @r, label: item.label, color: color, cx: @cx, cy: @cy}
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
        <%!-- Pie slices --%>
        <%= for slice <- @slices do %>
          <%= if @active_shape && slice.active_path do %>
            <PhiaUi.Components.Data.ChartActiveShape.chart_active_shape
              type={:sector}
              path={slice.path}
              active_path={slice.active_path}
              color={slice.color}
            />
          <% else %>
            <path
              d={slice.path}
              fill={slice.color}
              stroke={slice_stroke(slice.color, @spacing, @corner_radius)}
              stroke-width={slice_stroke_width(@spacing, @corner_radius)}
              stroke-linejoin={if @corner_radius > 0, do: "round", else: "miter"}
              stroke-linecap={if @corner_radius > 0, do: "round", else: "butt"}
              style={
                if @animate do
                  "transform-box: fill-box; transform-origin: center; animation: phia-dot-pop #{@animation_duration}ms ease-out #{slice.delay} both; #{slice.delay}"
                else
                  ""
                end
              }
            />
          <% end %>
        <% end %>

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
            >{slice.label}<%= if @show_values do %> ({Enum.at(@data, i).value})<% end %></text>
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

  # When spacing is active, no stroke is needed (the gap itself separates slices).
  # When corner_radius is active, use the slice's own fill color as stroke so the
  # round caps blend seamlessly with the slice.
  defp slice_stroke(_color, spacing, corner_radius) when spacing > 0 and corner_radius > 0,
    do: "none"

  defp slice_stroke(_color, spacing, _corner_radius) when spacing > 0,
    do: "none"

  defp slice_stroke(color, _spacing, corner_radius) when corner_radius > 0,
    do: color

  defp slice_stroke(_color, _spacing, _corner_radius),
    do: "var(--color-background, white)"

  # Stroke width: corner_radius drives a visible same-color stroke for round
  # cap effect; spacing removes the separator stroke entirely.
  defp slice_stroke_width(spacing, _corner_radius) when spacing > 0, do: "0"
  defp slice_stroke_width(_spacing, corner_radius) when corner_radius > 0, do: "#{corner_radius}"
  defp slice_stroke_width(_spacing, _corner_radius), do: "1"
end
