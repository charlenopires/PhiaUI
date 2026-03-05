defmodule PhiaUi.Components.Calendar do
  @moduledoc """
  Server-rendered calendar component for date selection with keyboard navigation.

  The calendar grid is built entirely server-side using Elixir's `Date` module.
  State (current month, selected date or range) lives in the parent LiveView.
  Day clicks and month navigation fire `phx-click` events back to the LiveView.

  Supports two selection modes:

  - `:single` — selects a single `Date.t()` value
  - `:range`  — highlights an interval between `:range_start` and `:range_end`

  Keyboard navigation (Arrow keys, Enter, Home, End) is provided by the
  `PhiaCalendar` JS hook registered on the root element.

  ## When to use

  Use `calendar/1` as the foundational date-picking primitive. Higher-level
  components compose it:

  - `date_picker/1` — wraps `calendar/1` in a popover with a trigger button
  - `date_range_picker/1` — renders two `calendar/1` instances side-by-side
    for range selection

  Use `calendar/1` directly when you want a permanently visible calendar
  (e.g. a booking widget, an event scheduler, a date navigator).

  ## ARIA

  The grid uses `role="grid"`. Day-of-week headers use `role="columnheader"`.
  Individual day cells use `role="gridcell"` with `aria-selected` and
  `aria-disabled` reflecting state. Disabled buttons have the `disabled` HTML
  attribute to prevent interaction and remove them from the tab order.

  ## Single-date example

      defmodule MyAppWeb.BookingLive do
        use Phoenix.LiveView

        def mount(_params, _session, socket) do
          today = Date.utc_today()
          {:ok, assign(socket,
            current_month: Date.beginning_of_month(today),
            selected_date: nil
          )}
        end

        def handle_event("date-selected", %{"date" => iso}, socket) do
          date = Date.from_iso8601!(iso)
          {:noreply, assign(socket, selected_date: date)}
        end

        def handle_event("calendar-prev-month", %{"month" => iso}, socket) do
          {:noreply, assign(socket, current_month: Date.from_iso8601!(iso))}
        end

        def handle_event("calendar-next-month", %{"month" => iso}, socket) do
          {:noreply, assign(socket, current_month: Date.from_iso8601!(iso))}
        end
      end

      <%!-- Template --%>
      <.calendar
        id="booking-calendar"
        current_month={@current_month}
        value={@selected_date}
        on_change="date-selected"
        min={Date.utc_today()}
      />
      <p :if={@selected_date}>
        Selected: {Calendar.strftime(@selected_date, "%B %d, %Y")}
      </p>

  ## Range selection example

      <.calendar
        id="vacation-range"
        current_month={@current_month}
        mode="range"
        range_start={@check_in}
        range_end={@check_out}
        on_change="date-selected"
        min={Date.utc_today()}
      />

  ## Disabling specific dates

  Pass `disabled_dates` to block holiday or unavailable dates:

      <.calendar
        id="appointment-picker"
        value={@appointment_date}
        disabled_dates={@fully_booked_dates}
        min={Date.utc_today()}
        max={Date.add(Date.utc_today(), 90)}
        on_change="date-selected"
      />

  ## Hook setup

      # app.js
      import PhiaCalendar from "./hooks/calendar"
      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaCalendar }
      })
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:id, :string,
    default: "calendar",
    doc: """
    Unique calendar ID. Used as the hook anchor and as a prefix for
    the embedded calendar in `date_picker/1`. Must be unique per page.
    """
  )

  attr(:value, :any,
    default: nil,
    doc: "Selected date (`Date.t()`) in `:single` mode, or `nil` for no selection"
  )

  attr(:current_month, :any,
    default: nil,
    doc: """
    Currently displayed month (`Date.t()`). When `nil`, defaults to the month
    containing `value`, or the current month if `value` is also nil.
    The LiveView must update this assign in response to prev/next month events.
    """
  )

  attr(:mode, :string,
    default: "single",
    values: ~w(single range),
    doc: """
    Selection mode:
    - `"single"` — highlights one selected date
    - `"range"`  — highlights the interval between `range_start` and `range_end`
    """
  )

  attr(:range_start, :any,
    default: nil,
    doc: "Range selection start date (`Date.t()`) — only used in `mode=\"range\"`"
  )

  attr(:range_end, :any,
    default: nil,
    doc: "Range selection end date (`Date.t()`) — only used in `mode=\"range\"`"
  )

  attr(:min, :any,
    default: nil,
    doc: "Minimum selectable date (`Date.t()`). Dates before this are disabled."
  )

  attr(:max, :any,
    default: nil,
    doc: "Maximum selectable date (`Date.t()`). Dates after this are disabled."
  )

  attr(:disabled_dates, :list,
    default: [],
    doc: """
    Explicit list of `Date.t()` values that cannot be selected regardless of
    `min`/`max`. Use for holidays, fully-booked slots, or blackout dates.
    """
  )

  attr(:on_change, :string,
    default: "calendar-change",
    doc: """
    `phx-click` event name fired when a day button is clicked.
    The LiveView receives `%{"date" => "YYYY-MM-DD"}`.
    """
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged onto the root element via `cn/1`"
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the root div element")

  @doc """
  Renders a server-rendered, accessible calendar grid for date selection.

  All calendar geometry (weeks, leading/trailing days, cell states) is computed
  server-side in `build_weeks/1` and `compute_cell_states/4` before the
  template renders. This keeps the HEEx template declarative and free of logic.

  The `PhiaCalendar` hook handles keyboard navigation: Arrow keys move focus
  between day cells, Enter selects the focused cell, Home/End jump to the
  first/last day of the displayed month.
  """
  def calendar(assigns) do
    # Default current_month: the month of the selected value, or today.
    assigns =
      assign_new(assigns, :current_month, fn ->
        case assigns[:value] do
          %Date{} = d -> Date.beginning_of_month(d)
          _ -> Date.beginning_of_month(Date.utc_today())
        end
      end)

    weeks = build_weeks(assigns.current_month)
    all_dates = List.flatten(weeks)

    # Group selection and constraint data into maps so helper functions have
    # a single, clean argument to pattern-match on.
    selection = %{
      value: assigns.value,
      mode: assigns.mode,
      range_start: assigns.range_start,
      range_end: assigns.range_end
    }

    constraint = %{
      min: assigns.min,
      max: assigns.max,
      disabled_dates: assigns.disabled_dates
    }

    # Pre-compute all cell states once so the template just looks up the map.
    # Without pre-computation, each cell would call three predicates per render.
    cell_states = compute_cell_states(all_dates, assigns.current_month, selection, constraint)

    assigns =
      assigns
      |> assign(:weeks, weeks)
      |> assign(:prev_month, shift_month(assigns.current_month, -1))
      |> assign(:next_month, shift_month(assigns.current_month, 1))
      |> assign(:cell_states, cell_states)

    ~H"""
    <div
      id={@id}
      phx-hook="PhiaCalendar"
      class={cn(["p-3 w-fit select-none", @class])}
      {@rest}
    >
      <%!-- Month navigation header --%>
      <div class="flex items-center justify-between mb-4">
        <button
          type="button"
          class="inline-flex items-center justify-center rounded-md p-1 text-sm hover:bg-accent focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
          phx-click="calendar-prev-month"
          phx-value-month={Date.to_iso8601(@prev_month)}
          aria-label="Previous month"
        >
          &#8249;
        </button>

        <span class="text-sm font-medium">
          {month_label(@current_month)}
        </span>

        <button
          type="button"
          class="inline-flex items-center justify-center rounded-md p-1 text-sm hover:bg-accent focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
          phx-click="calendar-next-month"
          phx-value-month={Date.to_iso8601(@next_month)}
          aria-label="Next month"
        >
          &#8250;
        </button>
      </div>

      <%!-- Calendar grid (7 columns = one per day of the week) --%>
      <div role="grid" class="grid grid-cols-7 gap-1">
        <%!-- Day-of-week column headers — aria-label provides full name for screen readers --%>
        <div
          :for={day <- ~w(Su Mo Tu We Th Fr Sa)}
          role="columnheader"
          aria-label={day_full_name(day)}
          class="text-center text-xs text-muted-foreground w-8 h-8 flex items-center justify-center"
        >
          {day}
        </div>

        <%!-- Date cells — pre-computed cell_states avoids repeated predicate calls --%>
        <div
          :for={date <- List.flatten(@weeks)}
          role="gridcell"
          class={cell_classes(date, @cell_states)}
          aria-selected={if @cell_states[date].selected, do: "true", else: "false"}
          aria-disabled={if @cell_states[date].disabled, do: "true", else: "false"}
        >
          <button
            type="button"
            class="w-full h-full flex items-center justify-center text-sm rounded-md focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
            phx-click={@on_change}
            phx-value-date={Date.to_iso8601(date)}
            tabindex={if @cell_states[date].selected, do: "0", else: "-1"}
            disabled={@cell_states[date].disabled}
          >
            {date.day}
          </button>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Calendar grid builder
  # ---------------------------------------------------------------------------

  @doc false
  @spec build_weeks(Date.t()) :: [[Date.t()]]
  def build_weeks(%Date{} = month) do
    first = Date.beginning_of_month(month)
    last = Date.end_of_month(month)

    # day_of_week/2 with :sunday returns 1=Sun..7=Sat.
    # `rem(..., 7)` converts to 0=Sun..6=Sat for 0-based grid offset.
    first_dow = rem(Date.day_of_week(first, :sunday), 7)

    # Pad the start of the first week with trailing days from the previous month.
    prefix =
      if first_dow > 0 do
        prev_last = Date.add(first, -1)
        prev_first = Date.add(prev_last, -(first_dow - 1))
        prev_first |> Date.range(prev_last) |> Enum.to_list()
      else
        []
      end

    dates = first |> Date.range(last) |> Enum.to_list()
    all_cells = prefix ++ dates

    # Pad the end of the last week with leading days from the next month.
    remainder = rem(length(all_cells), 7)

    suffix =
      if remainder == 0 do
        []
      else
        next_first = Date.add(last, 1)
        next_last = Date.add(next_first, 6 - remainder)
        next_first |> Date.range(next_last) |> Enum.to_list()
      end

    all_cells
    |> Kernel.++(suffix)
    |> Enum.chunk_every(7)
  end

  # ---------------------------------------------------------------------------
  # Cell state pre-computation
  # ---------------------------------------------------------------------------

  # Compute all cell states in one pass and return a date => state map.
  # This avoids calling three predicate functions per cell in the template loop.
  defp compute_cell_states(dates, current_month, selection, constraint) do
    Map.new(dates, fn date ->
      state = %{
        outside: date.month != current_month.month,
        selected: date_selected?(date, selection),
        in_range: date_in_range_middle?(date, selection),
        disabled: date_disabled?(date, constraint)
      }

      {date, state}
    end)
  end

  # ---------------------------------------------------------------------------
  # CSS class helpers
  # ---------------------------------------------------------------------------

  defp cell_classes(date, cell_states) do
    %{outside: outside, selected: selected, in_range: in_range, disabled: disabled} =
      cell_states[date]

    cn([
      "w-8 h-8 relative",
      # Selected date(s) use the primary colour.
      selected && "bg-primary text-primary-foreground rounded-md",
      # Range interior (non-endpoint days) use a softer accent.
      in_range && !selected && "bg-accent text-accent-foreground",
      # Days from adjacent months are dimmed to indicate they are not in scope.
      outside && "text-muted-foreground opacity-50",
      # Disabled dates are non-interactive.
      disabled && "pointer-events-none opacity-25"
    ])
  end

  # ---------------------------------------------------------------------------
  # State predicates
  # ---------------------------------------------------------------------------

  # Single mode — no selection
  defp date_selected?(_date, %{mode: "single", value: nil}), do: false
  # Single mode — exact match
  defp date_selected?(date, %{mode: "single", value: %Date{} = v}), do: date == v

  # Range mode — both endpoints: select start or end
  defp date_selected?(date, %{mode: "range", range_start: %Date{} = rs, range_end: %Date{} = re}),
    do: date == rs or date == re

  # Range mode — only start selected (user has clicked once, not yet twice)
  defp date_selected?(date, %{mode: "range", range_start: %Date{} = rs, range_end: nil}),
    do: date == rs

  # Range mode — only end (edge case, should not normally occur)
  defp date_selected?(date, %{mode: "range", range_start: nil, range_end: %Date{} = re}),
    do: date == re

  # Fallback
  defp date_selected?(_date, _selection), do: false

  # In-range middle: only meaningful in range mode with both endpoints set.
  defp date_in_range_middle?(_date, %{mode: "single"}), do: false
  defp date_in_range_middle?(_date, %{range_start: nil}), do: false
  defp date_in_range_middle?(_date, %{range_end: nil}), do: false

  defp date_in_range_middle?(date, %{range_start: %Date{} = rs, range_end: %Date{} = re}) do
    # Both endpoints are inclusive — the endpoints themselves are rendered as
    # "selected" (darker), while interior days get the lighter "in_range" style.
    Date.compare(date, rs) != :lt and Date.compare(date, re) != :gt
  end

  defp date_in_range_middle?(_date, _selection), do: false

  # No constraints — never disabled.
  defp date_disabled?(_date, %{min: nil, max: nil, disabled_dates: []}), do: false

  defp date_disabled?(date, %{min: min, max: max, disabled_dates: disabled_dates}) do
    below_min?(date, min) or above_max?(date, max) or Enum.member?(disabled_dates, date)
  end

  defp below_min?(_date, nil), do: false
  defp below_min?(date, min), do: Date.compare(date, min) == :lt

  defp above_max?(_date, nil), do: false
  defp above_max?(date, max), do: Date.compare(date, max) == :gt

  # ---------------------------------------------------------------------------
  # Month navigation
  # ---------------------------------------------------------------------------

  # Shift a date by `months` months, clamping the day to the 1st of the target month.
  # Using arithmetic on year*12+month avoids Calendar boundary edge cases.
  defp shift_month(%Date{} = date, months) do
    total = date.year * 12 + date.month - 1 + months
    new_year = div(total, 12)
    new_month = rem(total, 12) + 1
    Date.new!(new_year, new_month, 1)
  end

  # ---------------------------------------------------------------------------
  # Label helpers
  # ---------------------------------------------------------------------------

  defp month_label(%Date{} = date) do
    "#{month_name(date.month)} #{date.year}"
  end

  defp month_name(1), do: "January"
  defp month_name(2), do: "February"
  defp month_name(3), do: "March"
  defp month_name(4), do: "April"
  defp month_name(5), do: "May"
  defp month_name(6), do: "June"
  defp month_name(7), do: "July"
  defp month_name(8), do: "August"
  defp month_name(9), do: "September"
  defp month_name(10), do: "October"
  defp month_name(11), do: "November"
  defp month_name(12), do: "December"

  # Full day names for aria-label on column headers — screen readers read the full name.
  defp day_full_name("Su"), do: "Sunday"
  defp day_full_name("Mo"), do: "Monday"
  defp day_full_name("Tu"), do: "Tuesday"
  defp day_full_name("We"), do: "Wednesday"
  defp day_full_name("Th"), do: "Thursday"
  defp day_full_name("Fr"), do: "Friday"
  defp day_full_name("Sa"), do: "Saturday"
end
