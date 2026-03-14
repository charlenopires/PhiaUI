defmodule PhiaUi.Components.BulletChart do
  @moduledoc """
  Bullet chart — progress toward target with colored range bands — pure SVG, zero JS.

  Renders qualitative background ranges, a bar for the actual value, and a
  line marker for the target. Bars animate in on entrance.

  ## Examples

      <.bullet_chart
        value={72}
        target={85}
        ranges={[%{to: 50, color: "oklch(0.80 0.05 0)"}, %{to: 75, color: "oklch(0.88 0.03 0)"}, %{to: 100, color: "oklch(0.94 0.02 0)"}]}
        label="Revenue"
      />

      <.bullet_chart value={340} target={400} ranges={[%{to: 200}, %{to: 350}, %{to: 500}]} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  @vw 400
  @vh 60
  @pl 60
  @pr 20
  @bar_h 16
  @cx_y 30

  attr :value, :any, required: true, doc: "Actual value to display (integer or float)."
  attr :target, :any, required: true, doc: "Target value (shown as a line marker)."
  attr :max, :any, default: nil, doc: "Maximum scale value. Defaults to `max(target * 1.2, value)`."

  attr :ranges, :list,
    default: [],
    doc: """
    Background quality ranges: `[%{to: number, color: string}]`.
    Each range covers from the previous `:to` to this `:to`.
    """

  attr :label, :string, default: nil, doc: "Label shown to the left."
  attr :animate, :boolean, default: true
  attr :animation_duration, :integer, default: 700
  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def bullet_chart(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"

    max_val = assigns.max || max(assigns.target * 1.2, assigns.value) |> max(1)
    chart_w = @vw - @pl - @pr

    range_rects =
      assigns.ranges
      |> Enum.with_index()
      |> Enum.map(fn {r, i} ->
        prev_to = if i == 0, do: 0, else: Enum.at(assigns.ranges, i - 1).to
        from_px = @pl + prev_to / max_val * chart_w
        to_px = @pl + r.to / max_val * chart_w
        w = max(to_px - from_px, 0)

        default_colors = [
          "oklch(0.94 0.01 0)",
          "oklch(0.88 0.02 0)",
          "oklch(0.80 0.04 0)"
        ]

        color = Map.get(r, :color) || Enum.at(default_colors, i, "oklch(0.75 0.04 0)")
        %{x: Float.round(from_px, 2), w: Float.round(w, 2), color: color}
      end)

    value_w = max(assigns.value / max_val * chart_w, 1.0)
    target_x = @pl + assigns.target / max_val * chart_w

    bar_y = @cx_y - @bar_h / 2
    range_y = @cx_y - @bar_h / 2 - 6

    assigns =
      assigns
      |> assign(:range_rects, range_rects)
      |> assign(:value_w, Float.round(value_w, 2))
      |> assign(:target_x, Float.round(target_x, 2))
      |> assign(:chart_w, chart_w)
      |> assign(:bar_y, bar_y)
      |> assign(:bar_h, @bar_h)
      |> assign(:range_y, range_y)
      |> assign(:cx_y, @cx_y)
      |> assign(:pl, @pl)
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
        <%!-- Label --%>
        <text
          :if={@label}
          x={@pl - 4}
          y={@cx_y}
          text-anchor="end"
          dominant-baseline="middle"
          font-size="10"
          class="fill-foreground font-medium"
        >{@label}</text>

        <%!-- Range background bands --%>
        <rect
          :for={r <- @range_rects}
          x={r.x}
          y={@range_y}
          width={r.w}
          height={@bar_h + 12}
          rx="2"
          fill={r.color}
        />

        <%!-- Value bar --%>
        <rect
          x={@pl}
          y={@bar_y}
          width={@value_w}
          height={@bar_h}
          rx="2"
          fill="oklch(0.40 0.05 240)"
          style={
            if @animate do
              "transform-box: fill-box; transform-origin: left; animation: phia-bar-grow-x #{@animation_duration}ms ease-out 200ms both"
            else
              ""
            end
          }
        />

        <%!-- Target marker line --%>
        <line
          x1={@target_x}
          y1={@bar_y - 4}
          x2={@target_x}
          y2={@bar_y + @bar_h + 4}
          stroke="currentColor"
          stroke-width="3"
          stroke-linecap="round"
          class="text-foreground"
        />
      </svg>
    </div>
    """
  end
end
