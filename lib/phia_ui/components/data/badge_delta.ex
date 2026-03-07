defmodule PhiaUi.Components.BadgeDelta do
  @moduledoc """
  Delta badge — a colored pill showing a metric trend with an icon.

  Inspired by Tremor `BadgeDelta`, Ant Design `Tag` with trend, MUI trend chips.
  Common in dashboards to highlight KPI changes at a glance.

  ## Examples

      <.badge_delta value="+12.3%" delta_type={:increase} />
      <.badge_delta value="-5%" delta_type={:decrease} size={:lg} />
      <.badge_delta value="0%" delta_type={:unchanged} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  attr(:value, :string, required: true, doc: "Display string, e.g. \"+12.3%\" or \"-5%\".")

  attr(:delta_type, :atom,
    default: :unchanged,
    values: [:increase, :moderate_increase, :decrease, :moderate_decrease, :unchanged],
    doc: "Controls icon and color scheme."
  )

  attr(:size, :atom,
    default: :default,
    values: [:xs, :sm, :default, :lg],
    doc: "Badge size."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<span>`.")

  def badge_delta(assigns) do
    ~H"""
    <span
      class={cn([
        "inline-flex items-center rounded-full font-medium",
        color_class(@delta_type),
        size_class(@size),
        @class
      ])}
      {@rest}
    >
      <.icon name={icon_name(@delta_type)} class="shrink-0" />
      {@value}
    </span>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers — pattern-matched, no case/cond
  # ---------------------------------------------------------------------------

  defp icon_name(:increase), do: "arrow-up"
  defp icon_name(:decrease), do: "arrow-down"
  defp icon_name(:unchanged), do: "minus"
  defp icon_name(:moderate_increase), do: "trending-up"
  defp icon_name(:moderate_decrease), do: "trending-down"

  defp color_class(:increase),
    do: "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400"

  defp color_class(:moderate_increase),
    do: "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400"

  defp color_class(:decrease),
    do: "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400"

  defp color_class(:moderate_decrease),
    do: "bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-400"

  defp color_class(:unchanged),
    do: "bg-gray-100 text-gray-600 dark:bg-gray-800 dark:text-gray-400"

  defp size_class(:xs), do: "text-xs px-1.5 py-0.5 gap-0.5"
  defp size_class(:sm), do: "text-xs px-2 py-0.5 gap-1"
  defp size_class(:default), do: "text-sm px-2.5 py-1 gap-1"
  defp size_class(:lg), do: "text-base px-3 py-1.5 gap-1.5"
end
