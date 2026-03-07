defmodule PhiaUi.Components.MeterGroup do
  @moduledoc """
  Meter group — a labeled collection of progress meters.

  Inspired by PrimeReact `MeterGroup`. Shows multiple metrics, each with its own
  label, value, max, and color. Useful for storage usage, resource allocation,
  budget tracking, and multi-category comparisons.

  ## Examples

      <.meter_group meters={[
        %{label: "Photos", value: 30, max: 100, color: :blue},
        %{label: "Videos", value: 45, max: 100, color: :purple},
        %{label: "Files",  value: 15, max: 100, color: :green}
      ]} />

      <.meter_group meters={@disk_usage} size={:lg} total_label="Total used: 90 GB" />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:meters, :list,
    required: true,
    doc:
      "List of meter maps: `%{label: string, value: number, max: number, color: atom}`."
  )

  attr(:total_label, :string,
    default: nil,
    doc: "Optional summary label shown below all meters."
  )

  attr(:size, :atom,
    default: :default,
    values: [:sm, :default, :lg],
    doc: "Controls bar height."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root element.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>`.")

  def meter_group(assigns) do
    ~H"""
    <div class={cn(["w-full", @class])} {@rest}>
      <dl class="space-y-3">
        <div :for={meter <- @meters} class="space-y-1">
          <div class="flex items-center justify-between text-sm">
            <dt class="flex items-center gap-1.5 text-muted-foreground">
              <span class={cn(["inline-block h-2.5 w-2.5 rounded-sm", meter_color(meter.color)])} />
              {meter.label}
            </dt>
            <dd class="font-medium text-foreground">
              {meter.value}/{meter.max}
            </dd>
          </div>
          <div class={cn(["w-full rounded-full bg-muted overflow-hidden", bar_height(@size)])}>
            <div
              class={cn([meter_color(meter.color), bar_height(@size), "rounded-full"])}
              style={"width: #{meter_pct(meter.value, meter.max)}%"}
              role="progressbar"
              aria-valuenow={meter.value}
              aria-valuemin="0"
              aria-valuemax={meter.max}
            />
          </div>
        </div>
      </dl>
      <p :if={@total_label} class="mt-3 text-xs text-muted-foreground">
        {@total_label}
      </p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp bar_height(:sm), do: "h-1.5"
  defp bar_height(:default), do: "h-2.5"
  defp bar_height(:lg), do: "h-4"

  defp meter_color(:blue), do: "bg-blue-500"
  defp meter_color(:green), do: "bg-green-500"
  defp meter_color(:red), do: "bg-red-500"
  defp meter_color(:orange), do: "bg-orange-500"
  defp meter_color(:purple), do: "bg-purple-500"
  defp meter_color(:pink), do: "bg-pink-500"
  defp meter_color(:yellow), do: "bg-yellow-500"
  defp meter_color(:teal), do: "bg-teal-500"
  defp meter_color(:indigo), do: "bg-indigo-500"
  defp meter_color(:cyan), do: "bg-cyan-500"
  defp meter_color(_), do: "bg-gray-400"

  defp meter_pct(value, max) when max > 0,
    do: Float.round(min(value / max * 100, 100), 1)

  defp meter_pct(_value, _max), do: 0.0
end
