# Calendar & Scheduling

PhiaUI's standout feature: **33 server-rendered calendar and scheduling components** covering every date, time, and scheduling pattern in enterprise and consumer software. All calendar geometry is computed server-side using Elixir's `Date` module. State lives in your LiveView; events fire via `phx-click`. No client-side date math.

## Table of Contents

- [Basic Pickers](#basic-pickers)
  - [calendar](#calendar)
  - [date_picker](#date_picker)
  - [date_range_picker](#date_range_picker)
  - [date_field](#date_field)
  - [time_picker](#time_picker)
  - [date_time_picker](#date_time_picker)
  - [month_picker](#month_picker)
  - [year_picker](#year_picker)
  - [week_picker](#week_picker)
  - [week_day_picker](#week_day_picker)
- [Advanced Calendar Views](#advanced-calendar-views)
  - [range_calendar](#range_calendar)
  - [calendar_time_picker](#calendar_time_picker)
  - [date_range_presets](#date_range_presets)
  - [date_strip](#date_strip)
  - [date_card](#date_card)
  - [week_calendar](#week_calendar)
  - [big_calendar](#big_calendar)
  - [calendar_week_view](#calendar_week_view)
  - [wheel_picker](#wheel_picker)
- [Scheduling & Booking](#scheduling--booking)
  - [event_calendar](#event_calendar)
  - [booking_calendar](#booking_calendar)
  - [schedule_view](#schedule_view)
  - [daily_agenda](#daily_agenda)
  - [schedule_event_card](#schedule_event_card)
  - [time_slot_grid](#time_slot_grid)
  - [time_slot_list](#time_slot_list)
  - [time_slider_picker](#time_slider_picker)
  - [multi_select_calendar](#multi_select_calendar)
- [Specialized Displays](#specialized-displays)
  - [heatmap_calendar](#heatmap_calendar)
  - [badge_calendar](#badge_calendar)
  - [streak_calendar](#streak_calendar)
  - [multi_month_calendar](#multi_month_calendar)
  - [countdown_timer](#countdown_timer)

---

## Basic Pickers

### calendar

Server-rendered monthly grid. Single or range selection mode. MON-first by default.

**Hook**: `PhiaCalendar`
**Attrs**: `id`, `value` (Date.t), `on_change`, `mode` (:single/:range), `min`, `max`, `disabled_dates`

```heex
<%!-- Single date selection --%>
<.calendar
  id="booking-cal"
  value={@selected_date}
  on_change="pick-date"
/>

<%!-- With constraints --%>
<.calendar
  id="delivery-cal"
  value={@delivery_date}
  min={Date.utc_today()}
  max={Date.add(Date.utc_today(), 30)}
  disabled_dates={@holiday_dates}
  on_change="pick-delivery"
/>
```

```elixir
def handle_event("pick-date", %{"date" => iso}, socket) do
  {:noreply, assign(socket, selected_date: Date.from_iso8601!(iso))}
end
```

---

### date_picker

Calendar grid opened in a Popover. Formats the selected date in the trigger button.

**Attrs**: `id`, `value`, `on_change`, `format` (e.g. `"%B %d, %Y"`), `placeholder`, `min`, `max`

```heex
<.date_picker
  id="due-date"
  value={@due_date}
  on_change="set-due-date"
  placeholder="Pick a date"
  min={Date.utc_today()}
/>

<%!-- In a form --%>
<.field>
  <.field_label>Publish date</.field_label>
  <.date_picker id="publish-date" value={@publish_date} on_change="set-publish-date" />
</.field>
```

---

### date_range_picker

Dual-calendar popover for selecting a start and end date. Highlights the selected range.

**Hook**: `PhiaDateRangePicker`
**Attrs**: `id`, `from` (Date.t), `to` (Date.t), `on_change`, `min`, `max`, `placeholder_from`, `placeholder_to`

```heex
<.date_range_picker
  id="report-range"
  from={@date_from}
  to={@date_to}
  on_change="set-date-range"
  placeholder_from="Start date"
  placeholder_to="End date"
/>
```

```elixir
def handle_event("set-date-range", %{"from" => from_iso, "to" => to_iso}, socket) do
  {:noreply, assign(socket,
    date_from: Date.from_iso8601!(from_iso),
    date_to: Date.from_iso8601!(to_iso)
  )}
end
```

---

### date_field

Segmented day/month/year inputs with independent keyboard stepping.

**Attrs**: `id`, `value` (Date.t), `on_change`
**FormField variant**: `form_date_field/1`

```heex
<.date_field id="dob" value={@date_of_birth} on_change="set-dob" />
<.form_date_field field={@form[:date_of_birth]} label="Date of birth" />
```

---

### time_picker

Hour/minute/AM-PM selector. 12h or 24h format.

**Attrs**: `id`, `value` (time string "HH:MM"), `on_change`, `format` ("12h"/"24h"), `step` (minutes, default 15)
**FormField variant**: `form_time_picker/1`

```heex
<.time_picker id="appt-time" value={@appointment_time} on_change="set-time" format="12h" />
<.time_picker id="meeting-time" value={@meeting_time} on_change="set-time" format="24h" step={30} />
<.form_time_picker field={@form[:start_time]} label="Start time" format="24h" />
```

---

### date_time_picker

Combined date + time selector in a single popover.

**Attrs**: `id`, `value` (DateTime.t), `on_change`, `format`, `min`, `max`
**FormField variant**: `form_date_time_picker/1`

```heex
<.date_time_picker
  id="event-datetime"
  value={@event_start}
  on_change="set-event-start"
  min={DateTime.utc_now()}
/>

<.form_date_time_picker
  field={@form[:scheduled_at]}
  label="Schedule for"
  min={DateTime.utc_now()}
/>
```

---

### month_picker

12-month pill grid with year navigation.

**Attrs**: `id`, `value` (1–12 or Date.t), `year`, `on_change`
**FormField variant**: `form_month_picker/1`

```heex
<.month_picker id="report-month" value={@selected_month} year={@year} on_change="set-month" />
<.form_month_picker field={@form[:billing_month]} label="Billing month" />
```

---

### year_picker

Scrollable year grid with min/max bounds.

**Attrs**: `id`, `value` (integer), `min_year`, `max_year`, `on_change`
**FormField variant**: `form_year_picker/1`

```heex
<.year_picker id="birth-year" value={@birth_year} min_year={1900} max_year={Date.utc_today().year} on_change="set-year" />
```

---

### week_picker

ISO week selector (W01/2026 format) with week highlighting in the grid.

**Attrs**: `id`, `value` (`%{week: integer, year: integer}`), `on_change`
**FormField variant**: `form_week_picker/1`

```heex
<.week_picker id="sprint-week" value={@sprint_week} on_change="set-sprint-week" />
```

---

### week_day_picker

Mon–Sun pill toggles for recurrence rules and availability schedules. Multi-select.

**Attrs**: `id`, `value` (list of strings, e.g. `["mon", "wed", "fri"]`), `on_change`

```heex
<%!-- Recurring schedule days --%>
<.week_day_picker id="recurring-days" value={@recurring_days} on_change="set-days" />

<%!-- Availability days --%>
<.field>
  <.field_label>Available on</.field_label>
  <.week_day_picker id="availability" value={@available_days} on_change="set-availability" />
</.field>
```

---

## Advanced Calendar Views

### range_calendar

SUN-first month grid with visual range band: start/end circles with half-band fill on edges, full-band on interior days. Blue circular navigation buttons.

**Attrs**: `id`, `from`, `to`, `on_change`, `min`, `max`

```heex
<.range_calendar
  id="vacation-range"
  from={@vacation_from}
  to={@vacation_to}
  on_change="set-vacation"
  min={Date.utc_today()}
/>
```

---

### calendar_time_picker

Full monthly calendar with an inline time selector rendered below the grid in a single component.

**Attrs**: `id`, `value` (DateTime.t), `on_change`, `format`

```heex
<.calendar_time_picker
  id="appt-picker"
  value={@appointment_datetime}
  on_change="set-appointment"
/>
```

---

### date_range_presets

Date range picker extended with preset shortcut buttons.

**Default presets**: Today, Yesterday, Last 7 days, Last 30 days, This month, Last month
**Attrs**: `id`, `from`, `to`, `on_change`, `presets` (optional custom list)

```heex
<%!-- Analytics date range with presets --%>
<.date_range_presets
  id="analytics-range"
  from={@date_from}
  to={@date_to}
  on_change="set-analytics-range"
/>

<%!-- Custom presets --%>
<.date_range_presets
  id="report-range"
  from={@from}
  to={@to}
  on_change="set-range"
  presets={[
    %{label: "This week",    from: Date.beginning_of_week(Date.utc_today()), to: Date.utc_today()},
    %{label: "Last quarter", from: Date.add(Date.utc_today(), -90), to: Date.utc_today()}
  ]}
/>
```

---

### date_strip

Horizontal scrollable row of `date_card/1` components. Auto-scrolls to the selected day using inline JS.

**Attrs**: `id`, `dates` (list of Date.t), `selected` (Date.t), `on_select`

```heex
<%!-- Week strip for a scheduling UI --%>
<.date_strip
  id="week-strip"
  dates={Enum.map(0..6, &Date.add(Date.utc_today(), &1))}
  selected={@selected_date}
  on_select="select-date"
/>
```

---

### date_card

Single day card with 4 visual states.

**States**: `default`, `today`, `selected`, `disabled`
**Attrs**: `date`, `state`, `on_select`

```heex
<div class="grid grid-cols-7 gap-1">
  <.date_card
    :for={day <- @week_days}
    date={day}
    state={day_state(day, @selected_date)}
    on_select="select-day"
  />
</div>
```

```elixir
defp day_state(date, selected) do
  cond do
    date == selected       -> "selected"
    date == Date.utc_today() -> "today"
    Date.before?(date, Date.utc_today()) -> "disabled"
    true -> "default"
  end
end
```

---

### week_calendar

Compact week navigator: month title, prev/next navigation arrows, 7-day strip with selected day pill.

**Attrs**: `id`, `value` (Date.t — selected day), `on_change`

```heex
<.week_calendar id="week-nav" value={@selected_date} on_change="change-week" />
```

---

### big_calendar

Full-page calendar with month/week/day view switcher. MON-first. Event pills (max 3 visible + "+N more" overflow). Sub-component: `big_calendar_event/1`.

**Attrs**: `id`, `events` (list of %{id, title, date, color}), `view` (:month/:week/:day), `date`, `on_view_change`, `on_date_click`, `on_event_click`

```heex
<.big_calendar
  id="main-calendar"
  events={@calendar_events}
  view={@calendar_view}
  date={@calendar_date}
  on_view_change="change-view"
  on_date_click="click-date"
  on_event_click="click-event"
/>
```

```elixir
def handle_event("change-view", %{"view" => view}, socket) do
  {:noreply, assign(socket, calendar_view: String.to_existing_atom(view))}
end

def handle_event("click-date", %{"date" => iso}, socket) do
  date = Date.from_iso8601!(iso)
  events = Events.for_date(date)
  {:noreply, assign(socket, calendar_date: date, day_events: events)}
end
```

---

### calendar_week_view

Week grid with a time axis (Y-axis, 00:00–23:00). Events are absolutely positioned based on `start_time` and `duration` converted to pixel offsets.

**Attrs**: `id`, `events` (list of %{id, title, start_time, duration_minutes, color}), `date` (any day in the week)

```heex
<.calendar_week_view
  id="week-view"
  date={@week_start}
  events={@week_events}
/>
```

---

### wheel_picker

iOS-style scroll-snap wheel picker. Uses `scroll-snap-type: y mandatory` + inline JS for sync.

**Attrs**: `id`, `items` (list), `value`, `on_change`, `columns` (for multi-column pickers)

```heex
<%!-- Simple list --%>
<.wheel_picker id="hour-picker" items={Enum.map(0..23, &String.pad_leading("#{&1}", 2, "0"))}
  value={@hour} on_change="set-hour" />

<%!-- Month/Year picker --%>
<.wheel_picker
  id="month-year"
  columns={[
    %{id: "month", items: ~w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec), value: @month},
    %{id: "year",  items: Enum.map(2020..2030, &to_string/1), value: @year}
  ]}
  on_change="set-month-year"
/>
```

---

## Scheduling & Booking

### event_calendar

Month grid with clickable event pills per day. Day click reveals event list.

**Attrs**: `id`, `events` (list of %{date, title, color}), `on_event_click`, `on_date_click`

```heex
<.event_calendar
  id="events-cal"
  events={@events}
  on_event_click="open-event"
  on_date_click="show-day"
/>
```

---

### booking_calendar

Availability-aware booking calendar. Each date maps to an availability status.

**Attrs**: `id`, `availability` (%{Date.t => :available | :unavailable | :check_in_only | :check_out_only}), `selected`, `on_select`, `min_date`, `max_date`

```heex
<.booking_calendar
  id="book-date"
  availability={@availability}
  selected={@selected_date}
  on_select="select-date"
  min_date={Date.utc_today()}
/>
```

```elixir
def mount(_params, _session, socket) do
  # Build availability map for next 90 days
  availability = Bookings.availability_map(
    Date.utc_today(),
    Date.add(Date.utc_today(), 90)
  )
  {:ok, assign(socket, availability: availability, selected_date: nil)}
end

def handle_event("select-date", %{"date" => iso}, socket) do
  date = Date.from_iso8601!(iso)
  slots = Bookings.available_slots(date)
  {:noreply, assign(socket, selected_date: date, available_slots: slots)}
end
```

---

### schedule_view

Google Calendar-style agenda view. Supports day and week modes.

**Attrs**: `id`, `events` (list of %{id, title, start_datetime, end_datetime, color, location}), `view` (:day/:week), `date`, `on_event_click`

```heex
<div class="flex items-center gap-2 mb-4">
  <.segmented_control
    id="schedule-view-mode"
    name="view"
    value={@schedule_view}
    on_change="change-schedule-view"
    segments={[%{value: "day", label: "Day"}, %{value: "week", label: "Week"}]}
  />
  <.button variant="outline" size="icon" phx-click="prev-period">
    <.icon name="chevron-left" size="sm" />
  </.button>
  <.button variant="outline" size="icon" phx-click="next-period">
    <.icon name="chevron-right" size="sm" />
  </.button>
</div>

<.schedule_view
  id="my-schedule"
  events={@schedule_events}
  view={String.to_existing_atom(@schedule_view)}
  date={@schedule_date}
  on_event_click="open-event"
/>
```

---

### daily_agenda

Single-day chronological list view grouped by hour.

**Attrs**: `id`, `date`, `events` (list of %{time, title, duration_minutes, color, location})

```heex
<.daily_agenda
  id="today-agenda"
  date={Date.utc_today()}
  events={@todays_events}
/>
```

---

### schedule_event_card

Rich card for schedule and agenda displays. Use inside `daily_agenda` or any list.

**Attrs**: `title`, `time`, `duration`, `location`, `attendees` (list), `status`, `color`

```heex
<.schedule_event_card
  :for={event <- @events}
  title={event.title}
  time={event.start_time}
  duration="60 min"
  location={event.location}
  status={event.status}
  color={event.color}
/>
```

---

### time_slot_grid

Grid of bookable time slots. Available, booked, and selected states.

**Attrs**: `id`, `slots` (list of strings or maps), `selected`, `on_select`, `cols` (columns, default 4)

```heex
<.time_slot_grid
  id="time-slots"
  slots={@available_slots}
  selected={@selected_slot}
  on_select="select-slot"
  cols={4}
/>
```

```elixir
# Build slots from business hours
def available_slots(date) do
  booked = Bookings.booked_slots(date)
  Enum.reject(~w[09:00 09:30 10:00 10:30 11:00 11:30
                  14:00 14:30 15:00 15:30 16:00 16:30], &(&1 in booked))
end
```

---

### time_slot_list

Vertical list variant of time slot selection. Better for mobile layouts.

**Attrs**: `id`, `slots` (list of %{time, label, available}), `selected`, `on_select`

```heex
<.time_slot_list
  id="slot-list"
  slots={@slots}
  selected={@selected_slot}
  on_select="select-slot"
/>
```

---

### time_slider_picker

Dual-handle range slider for selecting a time window.

**Attrs**: `id`, `from` (minutes since midnight), `to`, `min`, `max`, `step`, `on_change`

```heex
<%!-- 9am to 5pm business hours --%>
<.time_slider_picker
  id="hours-range"
  from={@open_hour * 60}
  to={@close_hour * 60}
  min={0}
  max={1440}
  step={30}
  on_change="set-business-hours"
/>
```

---

### multi_select_calendar

Monthly grid where each day toggles on/off. Returns a list of selected dates.

**Attrs**: `id`, `value` (list of Date.t), `on_change`, `min`, `max`

```heex
<%!-- Blackout dates for a venue --%>
<.multi_select_calendar
  id="blackout-dates"
  value={@blackout_dates}
  on_change="set-blackout-dates"
/>
```

---

## Specialized Displays

### heatmap_calendar

GitHub-style contribution grid with intensity levels. Full WAI-ARIA `role="grid"`.

**Attrs**: `id`, `data` (%{Date.t => integer}), `max_value`, `rows` (7), `cols` (52), `col_labels`, `row_labels`, `show_legend`

```heex
<.heatmap_calendar
  data={@contribution_data}
  rows={7}
  cols={52}
  max_value={10}
  col_labels={@week_labels}
  row_labels={~w(Mon Tue Wed Thu Fri Sat Sun)}
  show_legend={true}
/>
```

```elixir
# Build contribution data from DB
def contribution_data(user_id) do
  user_id
  |> ActivityLog.for_user()
  |> Enum.group_by(& &1.date)
  |> Map.new(fn {date, entries} -> {date, length(entries)} end)
end
```

---

### badge_calendar

Monthly calendar where each day displays a count badge (notifications, events, tasks).

**Attrs**: `id`, `badges` (%{Date.t => integer}), `value`, `on_change`

```heex
<.badge_calendar
  id="task-calendar"
  badges={@task_counts_by_date}
  value={@selected_date}
  on_change="select-date"
/>
```

```elixir
def task_counts_by_date(user_id) do
  Tasks.list_by_user(user_id)
  |> Enum.group_by(& Date.from_naive!(&1.due_date, "Etc/UTC"))
  |> Map.new(fn {date, tasks} -> {date, length(tasks)} end)
end
```

---

### streak_calendar

Habit tracker calendar that highlights consecutive-day streaks with intensity levels.

**Attrs**: `id`, `data` (%{Date.t => boolean}), `streak_color`, `show_stats`

```heex
<.streak_calendar
  id="habit-tracker"
  data={@habit_completions}
  streak_color="green"
  show_stats={true}
/>
```

---

### multi_month_calendar

Side-by-side multiple month view for date range selection across month boundaries.

**Attrs**: `id`, `months` (2–4, default 2), `value`, `on_change`, `mode` (:single/:range)

```heex
<%!-- Side-by-side for hotel booking --%>
<.multi_month_calendar
  id="hotel-booking"
  months={2}
  value={@selected_date}
  on_change="set-checkout"
  mode={:range}
/>
```

---

### countdown_timer

Server-rendered countdown timer updated via LiveView `Process.send_after` loop. Displays DD:HH:MM:SS.

**Attrs**: `id`, `target` (DateTime.t), `on_end` (event name), `format`

```heex
<%!-- Auction countdown --%>
<.countdown_timer
  id="auction-timer"
  target={@auction_ends_at}
  on_end="auction-ended"
/>

<%!-- Sale ending banner --%>
<div class="bg-primary text-primary-foreground py-2 px-4 text-center">
  <span class="font-medium">Flash sale ends in: </span>
  <.countdown_timer id="sale-timer" target={@sale_ends_at} on_end="sale-ended" />
</div>
```

```elixir
def mount(_params, _session, socket) do
  if connected?(socket), do: schedule_tick()
  {:ok, assign(socket, auction_ends_at: ~U[2026-03-06 18:00:00Z])}
end

def handle_info(:tick, socket) do
  schedule_tick()
  {:noreply, socket}
end

def handle_event("auction-ended", _params, socket) do
  {:noreply, assign(socket, auction_active: false)}
end

defp schedule_tick, do: Process.send_after(self(), :tick, 1_000)
```

← [Back to README](../../README.md)
