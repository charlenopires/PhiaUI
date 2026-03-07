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

  attr(:zones, :list,
    default: [],
    doc: """
    Optional colored zones rendered as arc segments behind the value arc.
    Each zone: `%{from: number, to: number, color: atom}`.
    Same color atoms as `:color`.
    """
  )

  attr(:threshold, :any,
    default: nil,
    doc: "Optional numeric threshold marker rendered as a radial line on the arc."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root element.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>` element.")

  slot(:center_label,
    doc: "Optional slot to override the center label text rendered below the value."
  )

  # ---------------------------------------------------------------------------
  # Component
  # ---------------------------------------------------------------------------

  def gauge_chart(assigns) do
    arc_d = "M #{@cx - @r},#{@cy} A #{@r},#{@r} 0 0,1 #{@cx + @r},#{@cy}"

    zones_meta =
      Enum.map(assigns.zones, fn z ->
        zone_length = Float.round((z.to - z.from) / max(assigns.max, 1) * @half_circ, 2)
        zone_offset = Float.round(@half_circ - z.from / max(assigns.max, 1) * @half_circ, 2)
        Map.merge(z, %{zone_length: zone_length, zone_offset: zone_offset})
      end)

    threshold_line =
      if assigns.threshold do
        angle = :math.pi() * assigns.threshold / max(assigns.max, 1)
        x_end = Float.round(@cx + @r * :math.cos(:math.pi() - angle), 2)
        y_end = Float.round(@cy - @r * :math.sin(angle), 2)
        %{x1: @cx, y1: @cy, x2: x_end, y2: y_end}
      else
        nil
      end

    assigns =
      assigns
      |> assign(:arc_d, arc_d)
      |> assign(:filled_dash, arc_length(assigns.value, assigns.max))
      |> assign(:half_circ, @half_circ)
      |> assign(:zones_meta, zones_meta)
      |> assign(:threshold_line, threshold_line)

    ~H"""
    <div class={cn(["flex flex-col items-center", @class])} {@rest}>
      <div class={size_class(@size)}>
        <svg viewBox="0 0 120 70" aria-hidden="true" class="w-full h-full overflow-visible">
          <%!-- Zone arcs (rendered first, behind value arc) --%>
          <path
            :for={zone <- @zones_meta}
            d={@arc_d}
            fill="none"
            stroke="currentColor"
            stroke-width="10"
            stroke-linecap="butt"
            stroke-dasharray={"#{zone.zone_length} #{@half_circ}"}
            stroke-dashoffset={zone.zone_offset}
            class={arc_color_class(zone.color)}
          />

          <%!-- Track arc (always full 180°, muted) — shown only when no zones --%>
          <path
            :if={@zones == []}
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

          <%!-- Threshold marker (radial line from center to arc edge) --%>
          <line
            :if={@threshold_line}
            x1={@threshold_line.x1}
            y1={@threshold_line.y1}
            x2={@threshold_line.x2}
            y2={@threshold_line.y2}
            stroke="currentColor"
            stroke-width="2"
            class="text-foreground"
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

          <%!-- Label: slot takes precedence over attr --%>
          <text
            :if={@center_label != [] || @label}
            x="60"
            y="64"
            text-anchor="middle"
            dominant-baseline="middle"
            font-size="7"
            class="fill-muted-foreground"
          >
            <%= if @center_label != [], do: render_slot(@center_label), else: @label %>
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
