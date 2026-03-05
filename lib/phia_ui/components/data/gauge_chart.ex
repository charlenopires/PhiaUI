defmodule PhiaUi.Components.GaugeChart do
  @moduledoc """
  Semi-circular (180°) SVG gauge chart.

  Displays a value within a range as a partial arc, flat at the bottom.
  Commonly used in health dashboards, performance metrics, and analytics.
  Distinct from `CircularProgress` which is a full 360° ring.

  Zero JavaScript — SVG arc computed server-side using `stroke-dasharray`.

  ## Examples

      <.gauge_chart value={78} max={100} label="Mental Health Score" color={:blue} />

      <.gauge_chart value={150} max={200} label="Cholesterol" color={:orange} size={:lg} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # SVG geometry constants
  @r 45
  @cx 60
  @cy 60
  @half_circ 141.37

  # ---------------------------------------------------------------------------
  # Attributes
  # ---------------------------------------------------------------------------

  attr(:value, :integer, required: true, doc: "Current value (0..max).")
  attr(:max, :integer, default: 100, doc: "Maximum value for normalization.")
  attr(:label, :string, default: nil, doc: "Optional label shown below the value.")

  attr(:color, :atom,
    default: :blue,
    values: [:blue, :green, :orange, :red, :purple],
    doc: "Color of the filled arc."
  )

  attr(:size, :atom,
    default: :default,
    values: [:sm, :default, :lg],
    doc: "Size of the gauge: `:sm` (h-24 w-24), `:default` (h-32 w-32), `:lg` (h-40 w-40)."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root element.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>` element.")

  # ---------------------------------------------------------------------------
  # Component
  # ---------------------------------------------------------------------------

  def gauge_chart(assigns) do
    assigns =
      assigns
      |> assign(:arc_d, "M #{@cx - @r},#{@cy} A #{@r},#{@r} 0 0,1 #{@cx + @r},#{@cy}")
      |> assign(:filled_dash, arc_length(assigns.value, assigns.max))
      |> assign(:half_circ, @half_circ)

    ~H"""
    <div class={cn(["flex flex-col items-center", @class])} {@rest}>
      <div class={size_class(@size)}>
        <svg viewBox="0 0 120 70" aria-hidden="true" class="w-full h-full overflow-visible">
          <%!-- Track arc (always full 180°, muted) --%>
          <path
            d={@arc_d}
            fill="none"
            stroke="currentColor"
            stroke-width="10"
            stroke-linecap="round"
            class="text-muted-foreground opacity-20"
          />

          <%!-- Value arc (partial, colored) --%>
          <path
            d={@arc_d}
            fill="none"
            stroke="currentColor"
            stroke-width="10"
            stroke-linecap="round"
            stroke-dasharray={"#{@filled_dash} #{@half_circ}"}
            stroke-dashoffset="0"
            class={arc_color_class(@color)}
          />

          <%!-- Center value --%>
          <text
            x="60"
            y="52"
            text-anchor="middle"
            dominant-baseline="middle"
            font-size="18"
            font-weight="bold"
            class="fill-foreground"
          >
            {@value}
          </text>

          <%!-- Optional label below value --%>
          <text
            :if={@label}
            x="60"
            y="64"
            text-anchor="middle"
            dominant-baseline="middle"
            font-size="7"
            class="fill-muted-foreground"
          >
            {@label}
          </text>
        </svg>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp arc_length(_value, max) when max <= 0, do: 0.0

  defp arc_length(value, max) do
    clamped = value |> max(0) |> min(max)
    Float.round(@half_circ * clamped / max, 2)
  end

  defp size_class(:sm), do: "h-24 w-24"
  defp size_class(:default), do: "h-32 w-32"
  defp size_class(:lg), do: "h-40 w-40"

  defp arc_color_class(:blue), do: "text-blue-500"
  defp arc_color_class(:green), do: "text-green-500"
  defp arc_color_class(:orange), do: "text-orange-500"
  defp arc_color_class(:red), do: "text-red-500"
  defp arc_color_class(:purple), do: "text-purple-500"
end
