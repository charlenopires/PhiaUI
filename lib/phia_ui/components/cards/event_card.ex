defmodule PhiaUi.Components.EventCard do
  @moduledoc """
  Card component for displaying an event with a date badge, time, location,
  attendee avatars, and optional actions slot.
  """

  use Phoenix.Component

  import PhiaUi.Components.Avatar, only: [avatar: 1, avatar_image: 1, avatar_fallback: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:title, :string, required: true, doc: "Event title")

  attr(:month, :string, default: nil, doc: "Abbreviated month label, e.g. \"JAN\"")

  attr(:day, :string, default: nil, doc: "Day of month, e.g. \"15\"")

  attr(:time, :string, default: nil, doc: "Event time string, e.g. \"2:00 PM\"")

  attr(:location, :string, default: nil, doc: "Event location or meeting link label")

  attr(:virtual, :boolean, default: false, doc: "When true, shows a video icon instead of map-pin")

  attr(:attendees, :list,
    default: [],
    doc: "List of attendee maps with :src and :name keys"
  )

  attr(:max_attendees, :integer,
    default: 3,
    doc: "Maximum number of attendee avatars to show before overflow"
  )

  attr(:category_color, :atom,
    default: :primary,
    values: [:primary, :blue, :emerald, :amber, :rose, :violet],
    doc: "Color of the left date badge panel"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the outer wrapper")

  attr(:rest, :global, doc: "HTML attributes forwarded to the outer wrapper element")

  slot(:actions, doc: "Optional actions rendered at the bottom of the event card content")

  @doc """
  Renders an event card with a colored date badge and event details.

  ## Examples

      <.event_card
        title="Team Standup"
        month="MAR"
        day="15"
        time="9:00 AM"
        location="Conference Room A"
        category_color={:blue}
        attendees={[%{src: "/avatars/alice.jpg", name: "Alice"}, %{src: nil, name: "Bob"}]}
      />
  """
  def event_card(assigns) do
    visible_attendees = Enum.take(assigns.attendees, assigns.max_attendees)
    overflow = length(assigns.attendees) - length(visible_attendees)
    assigns = assign(assigns, visible_attendees: visible_attendees, overflow: overflow)

    ~H"""
    <div
      class={cn(["overflow-hidden rounded-lg border bg-card text-card-foreground shadow flex flex-row", @class])}
      {@rest}
    >
      <%!-- Left date badge panel --%>
      <div class={cn(["w-16 flex flex-col items-center justify-center rounded-l-lg", category_bg(@category_color)])}>
        <span :if={@month} class="text-xs font-medium uppercase text-white">{@month}</span>
        <span :if={@day} class="text-3xl font-bold text-white">{@day}</span>
      </div>
      <%!-- Right content panel --%>
      <div class="p-4 flex-1 min-w-0">
        <p class="text-base font-semibold truncate">{@title}</p>
        <%!-- Time row --%>
        <div :if={@time} class="flex items-center gap-1.5 mt-1">
          <.icon name="clock" size={:xs} class="text-muted-foreground shrink-0" />
          <span class="text-sm text-muted-foreground">{@time}</span>
        </div>
        <%!-- Location row --%>
        <div :if={@location} class="flex items-center gap-1.5 mt-1">
          <.icon name={location_icon(@virtual)} size={:xs} class="text-muted-foreground shrink-0" />
          <span class="text-sm text-muted-foreground truncate">{@location}</span>
        </div>
        <%!-- Attendees --%>
        <div :if={@visible_attendees != []} class="flex items-center mt-2">
          <div class="flex -space-x-2">
            <.avatar
              :for={attendee <- @visible_attendees}
              size="sm"
              class="ring-2 ring-background"
            >
              <.avatar_image :if={Map.get(attendee, :src)} src={attendee.src} alt={Map.get(attendee, :name, "")} />
              <.avatar_fallback name={Map.get(attendee, :name)} />
            </.avatar>
          </div>
          <span :if={@overflow > 0} class="ml-2 text-xs text-muted-foreground">
            +{@overflow}
          </span>
        </div>
        <%!-- Actions slot --%>
        <div :if={@actions != []} class="mt-3">
          {render_slot(@actions)}
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers — pattern matching only, no case/cond
  # ---------------------------------------------------------------------------

  defp category_bg(:primary), do: "bg-primary"
  defp category_bg(:blue), do: "bg-blue-500"
  defp category_bg(:emerald), do: "bg-emerald-500"
  defp category_bg(:amber), do: "bg-amber-500"
  defp category_bg(:rose), do: "bg-rose-500"
  defp category_bg(:violet), do: "bg-violet-500"

  defp location_icon(true), do: "video"
  defp location_icon(false), do: "map-pin"
end
