defmodule PhiaUi.Components.CalendarWeekView do
  @moduledoc """
  Week-view calendar with time axis and absolute-positioned event blocks.

  Renders a 7-column time grid where events are positioned by their start time
  and sized by duration. No JavaScript — all positioning computed server-side.

  ## Layout

  - Left column: timezone label + hour labels (07:00–21:00)
  - 7 day columns: day number, month+weekday subtitle, time grid with events

  ## Event format

      events = [
        %{date: ~D[2024-04-25], time: "09:00", end_time: "12:00", label: "standup", color: "green"},
        %{date: ~D[2024-04-26], time: "13:00", duration_minutes: 90, label: "review", color: "orange"},
      ]

  Supported colors: `"green"`, `"orange"`, `"blue"`, `"red"`, `"purple"`, `"gray"`.
  Any other value falls back to `bg-primary`.

  ## Pill label format

  `"{time} ({label})"` when `:label` is present, otherwise just `"{time}"`.

  ## Example

      <.calendar_week_view
        week_start={~D[2024-04-25]}
        events={@events}
        timezone="GMT+5"
        view="week"
        on_view_change="cal-view"
        on_event_click="cal-event"
      />
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  @px_per_hour 60
  @view_labels ~w(Month Week Day List)
  @month_names ~w(January February March April May June July August September October November December)

  attr(:week_start, :any, required: true, doc: "First day of the week to display (`Date.t()`)")
  attr(:events, :list, default: [], doc: "List of event maps. Each must have `:date` and `:time`.")
  attr(:start_hour, :integer, default: 7, doc: "First hour shown on the time axis (0–23).")
  attr(:end_hour, :integer, default: 22, doc: "Last hour (exclusive) on the time axis (1–24).")

  attr(:timezone, :string,
    default: nil,
    doc: "Timezone label shown top-left, e.g. \"GMT+5\"."
  )

  attr(:view, :string,
    default: "week",
    values: ~w(month week day list),
    doc: "Currently active view — used to highlight the matching button in the switcher."
  )

  attr(:on_view_change, :string,
    default: nil,
    doc: "LiveView event name fired when a view switcher button is clicked. Sends `phx-value-view`."
  )

  attr(:on_event_click, :string,
    default: nil,
    doc:
      "LiveView event name fired when an event block is clicked. Sends `phx-value-date`, `phx-value-time`, `phx-value-label`."
  )

  attr(:on_slot_click, :string,
    default: nil,
    doc:
      "LiveView event name fired when an empty time slot is clicked. Sends `phx-value-date`."
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def calendar_week_view(assigns) do
    days = Enum.map(0..6, fn offset -> Date.add(assigns.week_start, offset) end)
    hours = Enum.to_list(assigns.start_hour..(assigns.end_hour - 1))
    total_height = (assigns.end_hour - assigns.start_hour) * @px_per_hour
    month_label = Enum.at(@month_names, assigns.week_start.month - 1)

    assigns =
      assigns
      |> assign(:days, days)
      |> assign(:hours, hours)
      |> assign(:total_height, total_height)
      |> assign(:month_label, month_label)
      |> assign(:view_labels, @view_labels)
      |> assign(:px_per_hour, @px_per_hour)

    ~H"""
    <div class={cn(["w-full select-none", @class])} {@rest}>
      <%!-- Header: title + view switcher --%>
      <div class="mb-4 flex items-center justify-between">
        <h2 class="text-xl font-semibold">{@month_label} {@week_start.year}</h2>

        <div class="flex overflow-hidden rounded-lg border border-border bg-muted/30">
          <button
            :for={label <- @view_labels}
            type="button"
            phx-click={@on_view_change}
            phx-value-view={String.downcase(label)}
            class={cn([
              "px-3 py-1.5 text-sm font-medium transition-colors hover:bg-accent",
              String.downcase(label) == @view && "bg-background shadow-sm"
            ])}
          >
            {label}
          </button>
        </div>
      </div>

      <%!-- Week grid --%>
      <div class="overflow-x-auto rounded-lg border border-border">
        <div class="flex min-w-[700px]">
          <%!-- Left: time axis --%>
          <div class="w-20 shrink-0 border-r border-border">
            <%!-- Timezone header cell --%>
            <div class="flex h-16 items-center justify-center border-b border-border px-2">
              <span :if={@timezone} class="text-xs font-medium text-muted-foreground">
                {@timezone}
              </span>
            </div>
            <%!-- Hour labels --%>
            <div class="relative" style={"height: #{@total_height}px;"}>
              <div
                :for={hour <- @hours}
                class="absolute flex w-full items-start justify-end pr-2"
                style={"top: #{(hour - @start_hour) * @px_per_hour}px; height: #{@px_per_hour}px;"}
              >
                <span class="-mt-2.5 text-xs text-muted-foreground">
                  {format_hour(hour)}
                </span>
              </div>
            </div>
          </div>

          <%!-- Day columns --%>
          <div class="flex flex-1">
            <div
              :for={day <- @days}
              class="flex flex-1 flex-col border-r border-border last:border-r-0"
            >
              <%!-- Day header --%>
              <div class="flex h-16 flex-col items-center justify-center border-b border-border px-1">
                <span class="text-2xl font-semibold leading-none">{day.day}</span>
                <span class="mt-0.5 text-xs text-muted-foreground">
                  {day_subtitle(day)}
                </span>
              </div>

              <%!-- Time body — relative container for grid lines + events --%>
              <div
                class="relative"
                style={"height: #{@total_height}px;"}
                phx-click={@on_slot_click}
                phx-value-date={Date.to_iso8601(day)}
              >
                <%!-- Hour grid lines --%>
                <div
                  :for={hour <- @hours}
                  class="absolute w-full border-b border-border"
                  style={"top: #{(hour - @start_hour) * @px_per_hour}px; height: #{@px_per_hour}px;"}
                />

                <%!-- Events --%>
                <div
                  :for={event <- events_for_day(@events, day)}
                  class={cn([
                    "absolute left-1 right-1 overflow-hidden rounded px-1.5 py-1 text-xs font-medium text-white",
                    event_color_class(Map.get(event, :color))
                  ])}
                  style={event_style(event, @start_hour)}
                  phx-click={@on_event_click}
                  phx-value-date={Date.to_iso8601(day)}
                  phx-value-time={Map.get(event, :time, "")}
                  phx-value-label={Map.get(event, :label, "")}
                >
                  {event_label(event)}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp format_hour(h) when h < 10, do: "0#{h}:00"
  defp format_hour(h), do: "#{h}:00"

  defp day_subtitle(date) do
    month_abbr = Calendar.strftime(date, "%b")
    weekday = Calendar.strftime(date, "%A")
    "#{month_abbr}, #{weekday}"
  end

  defp events_for_day(events, date) do
    Enum.filter(events, &(Map.get(&1, :date) == date))
  end

  defp event_label(event) do
    time = Map.get(event, :time, "")
    label = Map.get(event, :label)

    if label && label != "" do
      "#{time} (#{label})"
    else
      time
    end
  end

  defp event_style(event, start_hour) do
    time = Map.get(event, :time, "#{start_hour}:00")
    {sh, sm} = parse_time(time)

    duration =
      cond do
        Map.has_key?(event, :end_time) ->
          {eh, em} = parse_time(event.end_time)
          eh * 60 + em - (sh * 60 + sm)

        Map.has_key?(event, :duration_minutes) ->
          event.duration_minutes

        true ->
          60
      end

    top = (sh - start_hour) * @px_per_hour + div(sm * @px_per_hour, 60)
    height = max(div(duration * @px_per_hour, 60), 20)

    "top: #{top}px; height: #{height}px;"
  end

  defp parse_time(time_str) do
    case String.split(time_str, ":") do
      [h, m] -> {String.to_integer(h), String.to_integer(m)}
      _ -> {0, 0}
    end
  end

  defp event_color_class("green"), do: "bg-green-500"
  defp event_color_class("orange"), do: "bg-orange-500"
  defp event_color_class("blue"), do: "bg-blue-500"
  defp event_color_class("red"), do: "bg-red-500"
  defp event_color_class("purple"), do: "bg-purple-500"
  defp event_color_class("gray"), do: "bg-gray-400 text-gray-700"
  defp event_color_class(_), do: "bg-primary"
end
