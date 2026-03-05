defmodule PhiaUi.Components.SparklineCard do
  @moduledoc """
  Compact metric card with an inline SVG sparkline.

  Renders a title, large value, optional delta badge, and a minimal polyline
  chart — no axes, no labels, pure trend visualization. Ideal for dashboards
  where space is limited and direction/trend is more important than precision.

  Zero JavaScript — SVG `<polyline>` points are computed server-side.

  ## Examples

      <.sparkline_card
        title="Revenue"
        value="$12,400"
        data={[4200, 6100, 5800, 7200, 8900, 12400]}
        delta="+32%"
        trend={:up}
      />

      <.sparkline_card
        title="Bounce Rate"
        value="45%"
        data={[62, 58, 54, 50, 48, 45]}
        delta="-17%"
        trend={:down}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:title, :string, required: true, doc: "Metric label shown above the value.")
  attr(:value, :string, required: true, doc: "Large primary value string (e.g. \"$1,240\").")
  attr(:data, :list, required: true, doc: "List of numbers used to draw the sparkline.")

  attr(:delta, :string,
    default: nil,
    doc: "Optional percentage change string (e.g. \"+12.4%\"). Omitted when nil."
  )

  attr(:trend, :atom,
    default: :neutral,
    values: [:up, :down, :neutral],
    doc: "Determines sparkline and delta color. `:up` = green, `:down` = red, `:neutral` = muted."
  )

  attr(:width, :integer, default: 120, doc: "SVG width in pixels.")
  attr(:height, :integer, default: 40, doc: "SVG height in pixels.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root card element.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>` element.")

  def sparkline_card(assigns) do
    assigns = assign(assigns, :points, build_points(assigns.data, assigns.width, assigns.height))

    ~H"""
    <div
      class={cn(["rounded-xl border border-border bg-card p-4 shadow-sm", @class])}
      {@rest}
    >
      <p class="text-sm text-muted-foreground">{@title}</p>
      <div class="mt-1 flex items-end justify-between gap-2">
        <div>
          <p class="text-2xl font-bold tracking-tight">{@value}</p>
          <span :if={@delta} class={cn(["mt-1 inline-block text-xs font-medium", trend_color(@trend)])}>
            {@delta}
          </span>
        </div>
        <svg
          width={@width}
          height={@height}
          viewBox={"0 0 #{@width} #{@height}"}
          preserveAspectRatio="none"
          aria-hidden="true"
        >
          <polyline
            :if={@points != ""}
            points={@points}
            fill="none"
            stroke={stroke_color(@trend)}
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          />
        </svg>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp build_points([], _w, _h), do: ""
  defp build_points([_single], w, h), do: "0,#{h / 2} #{w},#{h / 2}"

  defp build_points(data, w, h) do
    min_v = Enum.min(data)
    max_v = Enum.max(data)
    range = if max_v == min_v, do: 1, else: max_v - min_v

    count = length(data)
    padding = 2

    data
    |> Enum.with_index()
    |> Enum.map_join(" ", fn {v, i} ->
      x = Float.round(i / (count - 1) * w, 2)
      y = Float.round(padding + (1 - (v - min_v) / range) * (h - padding * 2), 2)
      "#{x},#{y}"
    end)
  end

  # green-500
  defp stroke_color(:up), do: "rgb(34 197 94)"
  # red-500
  defp stroke_color(:down), do: "rgb(239 68 68)"
  # zinc-400 (muted)
  defp stroke_color(:neutral), do: "rgb(161 161 170)"

  defp trend_color(:up), do: "text-green-600"
  defp trend_color(:down), do: "text-red-600"
  defp trend_color(:neutral), do: "text-muted-foreground"
end
