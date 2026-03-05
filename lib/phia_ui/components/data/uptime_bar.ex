defmodule PhiaUi.Components.UptimeBar do
  @moduledoc """
  Uptime status bar — a row of colored segments indicating service health over time.

  Inspired by Instastatus and Statuspage.io. Each segment represents a time period
  (hour, day, or week) with a color conveying its health status:

  | Status      | Color  | Tailwind class  |
  |-------------|--------|-----------------|
  | `:up`       | Green  | `bg-green-500`  |
  | `:down`     | Red    | `bg-red-500`    |
  | `:degraded` | Yellow | `bg-yellow-500` |

  The overall uptime percentage is computed server-side from the segment list.
  Native browser tooltips (`title` attribute) reveal date/status details on hover —
  no JavaScript required.

  ## Examples

      <%!-- Static 90-day bar --%>
      <.uptime_bar segments={@daily_statuses} />

      <%!-- Custom period --%>
      <.uptime_bar segments={@hourly_statuses} days={7} />

      <%!-- With labels (shown as native tooltip) --%>
      <.uptime_bar segments={
        Enum.map(@log, fn entry ->
          %{status: entry.status, label: Date.to_iso8601(entry.date)}
        end)
      } />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:segments, :list,
    default: [],
    doc:
      "List of segment maps. Each map must have `:status` (`:up | :down | :degraded`). " <>
        "Optional `:label` string is shown as a native browser tooltip on hover."
  )

  attr(:days, :integer,
    default: 90,
    doc: "Number of days represented (used for the '90 days ago' label). Default: `90`."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root element.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>` element.")

  @doc """
  Renders a horizontal uptime bar with colored segments and an uptime percentage.

  ## Example

      <.uptime_bar segments={@statuses} days={90} />
  """
  def uptime_bar(assigns) do
    total = length(assigns.segments)
    up_count = Enum.count(assigns.segments, &(Map.get(&1, :status) == :up))
    uptime = if total == 0, do: 100.0, else: Float.round(up_count / total * 100, 1)
    last_idx = max(total - 1, 0)

    assigns =
      assigns
      |> assign(:uptime, uptime)
      |> assign(:last_idx, last_idx)

    ~H"""
    <div class={cn(["w-full", @class])} {@rest}>
      <%!-- Segment bar --%>
      <div class="flex gap-0.5">
        <div
          :for={{segment, idx} <- Enum.with_index(@segments)}
          title={segment_title(segment)}
          class={cn([
            "h-8 flex-1",
            segment_color(Map.get(segment, :status)),
            rounding(idx, @last_idx)
          ])}
        />
      </div>
      <%!-- Footer: period labels + uptime % --%>
      <div class="mt-2 flex items-center justify-between text-sm text-muted-foreground">
        <span>{@days} days ago</span>
        <span class="font-medium">{@uptime}% uptime</span>
        <span>Today</span>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Rounded caps: single segment → fully round; first/last → one-sided caps; middle → no rounding
  defp rounding(idx, last_idx) when idx == 0 and idx == last_idx, do: "rounded-full"
  defp rounding(0, _last_idx), do: "rounded-l-full"
  defp rounding(idx, last_idx) when idx == last_idx, do: "rounded-r-full"
  defp rounding(_idx, _last_idx), do: ""

  defp segment_color(:up), do: "bg-green-500"
  defp segment_color(:down), do: "bg-red-500"
  defp segment_color(:degraded), do: "bg-yellow-500"
  defp segment_color(_), do: "bg-green-500"

  # Prefer explicit label, fall back to status atom string, then empty.
  defp segment_title(%{label: label}), do: label
  defp segment_title(%{status: status}), do: to_string(status)
  defp segment_title(_), do: ""
end
