defmodule PhiaUi.Components.ScheduleView do
  @moduledoc """
  Calendly-style availability schedule grid.

  Renders a tabular week view where columns are days and rows are time slots.
  Each slot can be: available (clickable), booked (gray, disabled), or selected
  (primary highlight). Unlike CalendarWeekView (px-positioned events),
  ScheduleView is a booking availability grid for scheduling appointments.

  ## Example

      <.schedule_view
        week_start={~D[2026-03-09]}
        start_hour={9}
        end_hour={17}
        step_minutes={30}
        availability={%{~D[2026-03-09] => ["09:00", "09:30", "10:00"]}}
        booked_slots={%{~D[2026-03-09] => ["09:30"]}}
        selected_slot={%{date: ~D[2026-03-09], time: "10:00"}}
        on_select="select_slot"
        days_count={5}
      />
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :week_start, :any, required: true
  attr :start_hour, :integer, default: 8
  attr :end_hour, :integer, default: 18
  attr :step_minutes, :integer, default: 30
  attr :availability, :map, default: %{}
  attr :booked_slots, :map, default: %{}
  attr :selected_slot, :map, default: nil
  attr :on_select, :string, default: nil
  attr :days_count, :integer, default: 5, values: [5, 7]
  attr :class, :string, default: nil
  attr :rest, :global

  def schedule_view(assigns) do
    days = build_days(assigns.week_start, assigns.days_count)
    time_slots = build_time_slots(assigns.start_hour, assigns.end_hour, assigns.step_minutes)

    assigns =
      assigns
      |> assign(:days, days)
      |> assign(:time_slots, time_slots)

    ~H"""
    <div
      class={cn(["bg-background rounded-2xl border border-border shadow-sm overflow-auto", @class])}
      {@rest}
    >
      <table class="w-full border-collapse text-sm">
        <%!-- Header row: empty corner + day columns --%>
        <thead>
          <tr>
            <th class="w-16 min-w-[4rem] border-b border-border bg-muted/30 p-2 text-xs font-medium text-muted-foreground text-center">
              Time
            </th>
            <th
              :for={day <- @days}
              class="border-b border-border bg-muted/30 p-2 text-xs font-medium text-foreground text-center min-w-[80px]"
            >
              <div class="font-semibold">{day.weekday}</div>
              <div class="text-muted-foreground font-normal">{day.label}</div>
            </th>
          </tr>
        </thead>
        <%!-- Body: one row per time slot --%>
        <tbody>
          <tr :for={slot <- @time_slots} class="border-b border-border/50 last:border-b-0">
            <td class="w-16 border-r border-border/50 p-1 text-xs text-muted-foreground text-center bg-muted/10 font-mono">
              {slot}
            </td>
            <td
              :for={day <- @days}
              class={slot_cell_class(day.date, slot, @availability, @booked_slots, @selected_slot)}
              phx-click={slot_click_event(day.date, slot, @availability, @booked_slots, @on_select)}
              phx-value-date={if slot_clickable?(day.date, slot, @availability, @booked_slots), do: Date.to_iso8601(day.date)}
              phx-value-time={if slot_clickable?(day.date, slot, @availability, @booked_slots), do: slot}
            >
              <span :if={slot_is_selected?(day.date, slot, @selected_slot)} class="text-xs font-semibold">
                ✓
              </span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Data builders
  # ---------------------------------------------------------------------------

  defp build_days(week_start, days_count) do
    0..(days_count - 1)
    |> Enum.map(fn offset ->
      date = Date.add(week_start, offset)
      %{
        date: date,
        weekday: Calendar.strftime(date, "%a"),
        label: Calendar.strftime(date, "%-m/%-d")
      }
    end)
  end

  defp build_time_slots(start_hour, end_hour, step_minutes) do
    total_slots = div((end_hour - start_hour) * 60, step_minutes)

    0..(total_slots - 1)
    |> Enum.map(fn i ->
      total_minutes = start_hour * 60 + i * step_minutes
      h = div(total_minutes, 60)
      m = rem(total_minutes, 60)
      :io_lib.format("~2..0B:~2..0B", [h, m]) |> to_string()
    end)
  end

  # ---------------------------------------------------------------------------
  # Slot state helpers
  # ---------------------------------------------------------------------------

  defp slot_state(date, time, availability, booked_slots, selected_slot) do
    cond do
      slot_is_selected?(date, time, selected_slot) -> :selected
      slot_is_booked?(date, time, booked_slots) -> :booked
      slot_is_available?(date, time, availability) -> :available
      true -> :unavailable
    end
  end

  defp slot_is_selected?(_date, _time, nil), do: false
  defp slot_is_selected?(date, time, %{date: sel_date, time: sel_time}),
    do: date == sel_date and time == sel_time

  defp slot_is_booked?(date, time, booked_slots) do
    times = Map.get(booked_slots, date, [])
    time in times
  end

  defp slot_is_available?(date, time, availability) do
    times = Map.get(availability, date, [])
    time in times
  end

  defp slot_clickable?(date, time, availability, booked_slots) do
    slot_is_available?(date, time, availability) and not slot_is_booked?(date, time, booked_slots)
  end

  defp slot_click_event(date, time, availability, booked_slots, on_select) do
    if is_binary(on_select) and slot_clickable?(date, time, availability, booked_slots) do
      on_select
    end
  end

  # ---------------------------------------------------------------------------
  # CSS class helpers
  # ---------------------------------------------------------------------------

  defp slot_cell_class(date, time, availability, booked_slots, selected_slot) do
    state = slot_state(date, time, availability, booked_slots, selected_slot)
    base = "border-r border-border/30 last:border-r-0 h-9 text-center transition-colors"

    state_class =
      case state do
        :selected -> "bg-primary text-primary-foreground cursor-default"
        :booked -> "bg-muted opacity-60 cursor-not-allowed"
        :available -> "bg-background hover:bg-primary/5 cursor-pointer"
        :unavailable -> "bg-background"
      end

    cn([base, state_class])
  end

end
