defmodule PhiaUi.Components.ScheduleEventCard do
  @moduledoc """
  ScheduleEventCard component — an event card with a colored left border, title,
  date/time range, optional avatar group, and a category badge.

  Designed for scheduling/calendar sidebar lists.

  ## Categories

  | Category    | Border colour    | Badge colours               |
  |-------------|------------------|-----------------------------|
  | `:meeting`  | blue-500         | bg-blue-100 / text-blue-700 |
  | `:event`    | teal-500         | bg-teal-100 / text-teal-700 |
  | `:leave`    | red-400          | bg-red-100  / text-red-600  |
  | `:default`  | primary          | bg-primary/10 / text-primary|

  ## Examples

      <.schedule_event_card
        title="Team Standup"
        category={:meeting}
        date="2026 / JAN / 15"
        time_range="09:00 AM - 10:00 AM"
        avatars={[%{src: "/avatars/alice.png", name: "Alice"}, "Bob"]}
        max_avatars={3}
      />

      <.schedule_event_card title="Annual Leave" category={:leave} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :title, :string, required: true, doc: "Event title displayed in bold"

  attr :date, :string,
    default: nil,
    doc: "Date string, e.g. \"2022 / JUL / 30\". Omit to hide the date row."

  attr :time_range, :string,
    default: nil,
    doc: "Time range string, e.g. \"09:00 AM - 11:00 AM\". Omit to hide the time row."

  attr :category, :atom,
    default: :default,
    values: [:meeting, :event, :leave, :default],
    doc: "Category determines the left-border and badge colour"

  attr :category_label, :string,
    default: nil,
    doc: "Override the badge text. Falls back to the category name."

  attr :avatars, :list,
    default: [],
    doc: "List of avatar descriptors — strings or %{src: url, name: name} maps"

  attr :max_avatars, :integer,
    default: 3,
    doc: "Maximum number of avatar circles to display before showing an overflow count"

  attr :class, :string, default: nil, doc: "Additional CSS classes merged via cn/1"

  attr :rest, :global, doc: "HTML attributes forwarded to the root element"

  @doc """
  Renders a schedule event card with a coloured left border, title, optional date/time
  rows, stacked avatars and a category badge.
  """
  def schedule_event_card(assigns) do
    ~H"""
    <div
      class={cn([
        "bg-background rounded-xl shadow-sm border border-border overflow-hidden",
        border_class(@category),
        @class
      ])}
      {@rest}
    >
      <div class="px-4 py-3 space-y-1.5">
        <!-- Title -->
        <p class="text-sm font-semibold text-foreground">{@title}</p>

        <!-- Date row -->
        <div :if={@date} class="flex items-center gap-1.5 text-xs text-muted-foreground">
          <span class="i-calendar w-3.5 h-3.5">📅</span>
          <span>{@date}</span>
        </div>

        <!-- Time range row -->
        <div :if={@time_range} class="flex items-center gap-1.5 text-xs text-muted-foreground">
          <span class="i-clock w-3.5 h-3.5">🕐</span>
          <span>{@time_range}</span>
        </div>

        <!-- Bottom: avatars + badge -->
        <div
          :if={@avatars != [] or @category != :default}
          class="flex items-center justify-between pt-1"
        >
          <!-- Stacked avatars -->
          <div class="flex -space-x-1.5">
            <div
              :for={_avatar <- Enum.take(@avatars, @max_avatars)}
              class="flex h-6 w-6 items-center justify-center rounded-full bg-muted border border-background text-xs text-muted-foreground"
            >
              👤
            </div>
            <div
              :if={length(@avatars) > @max_avatars}
              class="flex h-6 w-6 items-center justify-center rounded-full bg-muted border border-background text-xs font-medium text-muted-foreground"
            >
              +{length(@avatars) - @max_avatars}
            </div>
          </div>

          <!-- Category badge -->
          <span class={cn(["rounded-full px-2.5 py-0.5 text-xs font-medium", badge_class(@category)])}>
            {@category_label || default_label(@category)}
          </span>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp border_class(:meeting), do: "border-l-4 border-l-blue-500"
  defp border_class(:event), do: "border-l-4 border-l-teal-500"
  defp border_class(:leave), do: "border-l-4 border-l-red-400"
  defp border_class(_), do: "border-l-4 border-l-primary"

  defp badge_class(:meeting), do: "bg-blue-100 text-blue-700"
  defp badge_class(:event), do: "bg-teal-100 text-teal-700"
  defp badge_class(:leave), do: "bg-red-100 text-red-600"
  defp badge_class(_), do: "bg-primary/10 text-primary"

  defp default_label(:meeting), do: "Meeting"
  defp default_label(:event), do: "Event"
  defp default_label(:leave), do: "Leave"
  defp default_label(_), do: "Event"
end
