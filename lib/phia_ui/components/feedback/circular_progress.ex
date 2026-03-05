defmodule PhiaUi.Components.CircularProgress do
  @moduledoc """
  Radial/circular progress indicator rendered as an SVG arc.

  A pure SVG component — no JavaScript required. Commonly used in dashboards,
  KPI cards, profile completion widgets, and performance gauges.

  ## Anatomy

  | Element    | Role                                           |
  |------------|------------------------------------------------|
  | Root `<div>` | Accessible container with ARIA progressbar role |
  | `<svg>`    | Scaled SVG viewport, rotated -90° so arc starts at top |
  | Track `<circle>` | Full-circumference muted background ring  |
  | Arc `<circle>`   | Partial arc conveying the progress value  |
  | Center label | Percentage or custom slot content          |

  ## How the arc works

  The arc uses `stroke-dasharray` set to the full circumference (≈ 263.89 for
  radius 42) and `stroke-dashoffset` to reveal only the appropriate portion:

      offset = circumference - (value / 100) × circumference

  At `value=0` the offset equals the full circumference (arc hidden).
  At `value=100` the offset is `0.0` (full arc visible).

  ## Examples

      <%!-- Basic usage --%>
      <.circular_progress value={72} />

      <%!-- Custom size and color --%>
      <.circular_progress value={48} size="lg" color="stroke-green-500" />

      <%!-- Custom center label via slot --%>
      <.circular_progress value={90}>
        <:label>
          <span class="text-xs font-semibold text-green-600">Done</span>
        </:label>
      </.circular_progress>

      <%!-- Thicker ring, no text --%>
      <.circular_progress value={33} thickness={12} show_label={false} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # SVG arc geometry — computed once at compile time.
  # The arc circle has radius 42 within a 100×100 viewBox (cx=cy=50).
  # Leaving 8px of padding on each side accommodates stroke widths up to 16.
  @radius 42
  @circumference Float.round(2 * :math.pi() * @radius, 2)

  attr(:value, :integer,
    default: 0,
    doc: "Progress percentage from 0 to 100."
  )

  attr(:size, :string,
    default: "default",
    values: ~w(sm default lg xl),
    doc:
      "Ring diameter. One of `\"sm\"` (64px), `\"default\"` (96px), `\"lg\"` (128px), `\"xl\"` (160px)."
  )

  attr(:color, :string,
    default: "stroke-primary",
    doc: "Tailwind `stroke-*` class applied to the progress arc, e.g. `\"stroke-green-500\"`."
  )

  attr(:thickness, :integer,
    default: 8,
    doc: "SVG `stroke-width` for both the track and arc circles. Default: `8`."
  )

  attr(:show_label, :boolean,
    default: true,
    doc:
      "When `true` (default), renders the percentage value in the ring center. Ignored when a `:label` slot is provided."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root element.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>` element.")

  slot(:label,
    doc: "Custom content rendered in the ring center. When provided, overrides `:show_label`."
  )

  @doc """
  Renders a circular/radial progress indicator.

  ## Example

      <.circular_progress value={65} size="lg" color="stroke-blue-500" />
  """
  def circular_progress(assigns) do
    assigns =
      assigns
      |> assign(:circumference, @circumference)
      |> assign(:radius, @radius)
      |> assign(:offset, arc_offset(assigns.value))

    ~H"""
    <div
      role="progressbar"
      aria-valuenow={@value}
      aria-valuemin={0}
      aria-valuemax={100}
      class={cn(["relative inline-flex items-center justify-center", size_class(@size), @class])}
      {@rest}
    >
      <svg viewBox="0 0 100 100" class="w-full h-full -rotate-90" aria-hidden="true">
        <%!-- Track: full-circumference background ring --%>
        <circle
          cx="50"
          cy="50"
          r={@radius}
          fill="none"
          class="stroke-muted"
          stroke-width={@thickness}
        />
        <%!-- Arc: partial ring representing progress --%>
        <circle
          cx="50"
          cy="50"
          r={@radius}
          fill="none"
          class={@color}
          stroke-width={@thickness}
          stroke-dasharray={@circumference}
          stroke-dashoffset={@offset}
          stroke-linecap="round"
        />
      </svg>
      <%!-- Center content --%>
      <div class="absolute inset-0 flex items-center justify-center">
        <%= if @label != [] do %>
          {render_slot(@label)}
        <% else %>
          <span :if={@show_label} class={cn(["font-medium tabular-nums", label_size_class(@size)])}>
            {@value}%
          </span>
        <% end %>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Computes the stroke-dashoffset so that the visible arc represents `value`%.
  # At value=0 the offset equals the full circumference (nothing visible).
  # At value=100 the offset is 0.0 (entire circumference visible).
  defp arc_offset(value) do
    Float.round(@circumference - @circumference * value / 100, 2)
  end

  defp size_class("sm"), do: "h-16 w-16"
  defp size_class("default"), do: "h-24 w-24"
  defp size_class("lg"), do: "h-32 w-32"
  defp size_class("xl"), do: "h-40 w-40"

  defp label_size_class("sm"), do: "text-xs"
  defp label_size_class("default"), do: "text-sm"
  defp label_size_class("lg"), do: "text-base"
  defp label_size_class("xl"), do: "text-lg"
end
