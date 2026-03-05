defmodule PhiaUi.Components.CalendarTimePicker do
  @moduledoc """
  Calendar + scrollable time slot picker for date-and-time selection.

  Combines a `calendar/1` grid (left) with a scrollable list of time slots
  (right) so users can pick both a date and a time in a single panel.
  Zero JavaScript — the time list uses CSS `overflow-y-auto`. Calendar
  keyboard navigation is provided by the `PhiaCalendar` hook (same as
  `calendar/1`).

  ## State management

  The parent LiveView owns all state and handles events:

  - `calendar-prev-month` / `calendar-next-month` — month navigation (from inner calendar)
  - `on_date_change` event — fired when a day is clicked
  - `on_time_change` event — fired when a time slot is clicked, sends `%{"time" => "HH:MM"}`
  - `on_cancel` / `on_confirm` — Cancel/Done button events

  ## Example

      <.calendar_time_picker
        id="booking-time"
        current_month={@current_month}
        date_value={@selected_date}
        time_value={@selected_time}
        on_date_change="date-picked"
        on_time_change="time-picked"
        on_cancel="cancel-picker"
        on_confirm="confirm-picker"
      />

  ## Time slots

  Slots are generated server-side from `start_hour` to `end_hour` with `step`
  minutes between each slot. Default: 9 AM–9 PM, 30-minute intervals.
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Calendar, only: [calendar: 1]

  attr(:id, :string, required: true, doc: "Unique DOM id prefix")
  attr(:current_month, :any, required: true, doc: "Currently displayed month (`Date.t()`)")
  attr(:date_value, :any, default: nil, doc: "Selected date (`Date.t()`) or nil")
  attr(:time_value, :string, default: nil, doc: "Selected time in `\"HH:MM\"` format or nil")
  attr(:start_hour, :integer, default: 9, doc: "First time slot hour (0–23)")
  attr(:end_hour, :integer, default: 21, doc: "Last time slot hour (exclusive, 0–24)")
  attr(:step, :integer, default: 30, doc: "Minutes between time slots")
  attr(:on_date_change, :string, default: "calendar-change", doc: "Event for day click")
  attr(:on_time_change, :string, default: "calendar-time-change", doc: "Event for time slot click")
  attr(:on_cancel, :string, default: "calendar-time-cancel", doc: "Cancel button event")
  attr(:on_confirm, :string, default: "calendar-time-confirm", doc: "Done button event")
  attr(:show_actions, :boolean, default: true, doc: "Show Cancel / Done buttons")
  attr(:class, :string, default: nil)

  def calendar_time_picker(assigns) do
    assigns =
      assign(assigns, :time_slots, build_time_slots(assigns.start_hour, assigns.end_hour, assigns.step))

    ~H"""
    <div class={cn(["w-fit rounded-lg border border-border bg-card shadow-sm", @class])}>
      <div class="flex divide-x divide-border">
        <%!-- Left: calendar grid --%>
        <div>
          <.calendar
            id={"#{@id}-cal"}
            current_month={@current_month}
            value={@date_value}
            on_change={@on_date_change}
          />
        </div>

        <%!-- Right: scrollable time slot list --%>
        <div
          class="flex w-36 flex-col gap-1 overflow-y-auto p-2"
          style="max-height: 280px;"
          aria-label="Time slots"
        >
          <button
            :for={slot <- @time_slots}
            type="button"
            phx-click={@on_time_change}
            phx-value-time={slot.value}
            class={cn([
              "rounded-md px-3 py-1.5 text-left text-sm transition-colors hover:bg-accent",
              slot.value == @time_value && "bg-primary text-primary-foreground hover:bg-primary"
            ])}
          >
            {slot.label}
          </button>
        </div>
      </div>

      <%!-- Actions footer --%>
      <div :if={@show_actions} class="flex justify-end gap-2 border-t border-border px-4 py-3">
        <button
          type="button"
          phx-click={@on_cancel}
          class="inline-flex h-9 items-center rounded-md border border-input bg-background px-4 text-sm font-medium hover:bg-accent"
        >
          Cancel
        </button>
        <button
          type="button"
          phx-click={@on_confirm}
          class="inline-flex h-9 items-center rounded-md bg-primary px-4 text-sm font-medium text-primary-foreground hover:bg-primary/90"
        >
          Done
        </button>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Time slot builder
  # ---------------------------------------------------------------------------

  defp build_time_slots(start_hour, end_hour, step) do
    start_min = start_hour * 60
    end_min = end_hour * 60

    start_min
    |> Stream.iterate(&(&1 + step))
    |> Enum.take_while(&(&1 < end_min))
    |> Enum.map(fn total_min ->
      h = div(total_min, 60)
      m = rem(total_min, 60)

      value =
        "#{Integer.to_string(h) |> String.pad_leading(2, "0")}:#{Integer.to_string(m) |> String.pad_leading(2, "0")}"

      %{value: value, label: format_slot_time(h, m)}
    end)
  end

  defp format_slot_time(0, m),
    do: "12:#{String.pad_leading(Integer.to_string(m), 2, "0")} AM"

  defp format_slot_time(h, m) when h < 12,
    do: "#{h}:#{String.pad_leading(Integer.to_string(m), 2, "0")} AM"

  defp format_slot_time(12, m),
    do: "12:#{String.pad_leading(Integer.to_string(m), 2, "0")} PM"

  defp format_slot_time(h, m),
    do: "#{h - 12}:#{String.pad_leading(Integer.to_string(m), 2, "0")} PM"
end
