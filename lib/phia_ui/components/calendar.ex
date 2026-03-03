defmodule PhiaUi.Components.Calendar do
  @moduledoc """
  Server-rendered calendar component for date selection with keyboard navigation.

  The calendar grid is built entirely server-side using Elixir's `Date` module.
  State (current month, selected date / range) lives in the parent LiveView.
  Day clicks and month navigation fire `phx-click` events back to the LiveView.

  Supports two selection modes:

  - `:single` — selects a single `Date.t()` value
  - `:range` — highlights an interval between `:range_start` and `:range_end`

  Keyboard navigation is provided by the `PhiaCalendar` JS hook (Arrow keys,
  Enter, Home, End).

  ## ARIA

  The grid uses `role="grid"`, individual cells use `role="gridcell"`, and
  selected cells carry `aria-selected="true"`. Disabled cells carry
  `aria-disabled="true"`.

  ## Examples

      <%!-- Single-date calendar --%>
      <.calendar
        id="pick-date"
        current_month={@current_month}
        value={@selected_date}
        on_change="date-selected"
      />

      <%!-- Range calendar --%>
      <.calendar
        id="pick-range"
        current_month={@current_month}
        mode="range"
        range_start={@range_start}
        range_end={@range_end}
        on_change="date-selected"
      />

  ## LiveView handlers

      def handle_event("date-selected", %{"date" => iso}, socket) do
        {:noreply, assign(socket, selected_date: Date.from_iso8601!(iso))}
      end

      def handle_event("calendar-prev-month", %{"month" => iso}, socket) do
        {:noreply, assign(socket, current_month: Date.from_iso8601!(iso))}
      end

      def handle_event("calendar-next-month", %{"month" => iso}, socket) do
        {:noreply, assign(socket, current_month: Date.from_iso8601!(iso))}
      end
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:id, :string, default: "calendar", doc: "Unique calendar ID (required for the JS hook)")

  attr(:value, :any, default: nil, doc: "Selected date (Date.t) in :single mode, or nil")

  attr(:current_month, :any,
    default: nil,
    doc: "Currently displayed month (Date.t). Defaults to today or the selected value."
  )

  attr(:mode, :string,
    default: "single",
    values: ~w(single range),
    doc: "Selection mode: 'single' for one date, 'range' for an interval"
  )

  attr(:range_start, :any, default: nil, doc: "Range start date (Date.t) — used in :range mode")
  attr(:range_end, :any, default: nil, doc: "Range end date (Date.t) — used in :range mode")

  attr(:min, :any, default: nil, doc: "Minimum selectable date (Date.t)")
  attr(:max, :any, default: nil, doc: "Maximum selectable date (Date.t)")

  attr(:disabled_dates, :list,
    default: [],
    doc: "Explicit list of Date.t values that cannot be selected"
  )

  attr(:on_change, :string,
    default: "calendar-change",
    doc: "phx-click event name fired when a day is clicked"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element")

  @doc """
  Renders a server-rendered, accessible calendar grid for date selection.
  """
  def calendar(assigns) do
    assigns =
      assign_new(assigns, :current_month, fn ->
        case assigns[:value] do
          %Date{} = d -> Date.beginning_of_month(d)
          _ -> Date.beginning_of_month(Date.utc_today())
        end
      end)

    weeks = build_weeks(assigns.current_month)
    all_dates = List.flatten(weeks)

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
      <%!-- Navigation header --%>
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

      <%!-- Calendar grid --%>
      <div role="grid" class="grid grid-cols-7 gap-1">
        <%!-- Day-of-week headers --%>
        <div
          :for={day <- ~w(Su Mo Tu We Th Fr Sa)}
          role="columnheader"
          aria-label={day_full_name(day)}
          class="text-center text-xs text-muted-foreground w-8 h-8 flex items-center justify-center"
        >
          {day}
        </div>

        <%!-- Date cells --%>
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

    # day_of_week/2 with :sunday returns 1=Sun..7=Sat; convert to 0-based offset
    first_dow = rem(Date.day_of_week(first, :sunday), 7)

    # Leading dates from the previous month
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

    # Trailing dates from the next month
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
      selected && "bg-primary text-primary-foreground rounded-md",
      in_range && !selected && "bg-accent text-accent-foreground",
      outside && "text-muted-foreground opacity-50",
      disabled && "pointer-events-none opacity-25"
    ])
  end

  # ---------------------------------------------------------------------------
  # State predicates
  # ---------------------------------------------------------------------------

  # Single mode
  defp date_selected?(_date, %{mode: "single", value: nil}), do: false
  defp date_selected?(date, %{mode: "single", value: %Date{} = v}), do: date == v

  # Range mode — both endpoints set
  defp date_selected?(date, %{mode: "range", range_start: %Date{} = rs, range_end: %Date{} = re}),
    do: date == rs or date == re

  # Range mode — only start set
  defp date_selected?(date, %{mode: "range", range_start: %Date{} = rs, range_end: nil}),
    do: date == rs

  # Range mode — only end set
  defp date_selected?(date, %{mode: "range", range_start: nil, range_end: %Date{} = re}),
    do: date == re

  # Fallback
  defp date_selected?(_date, _selection), do: false

  defp date_in_range_middle?(_date, %{mode: "single"}), do: false
  defp date_in_range_middle?(_date, %{range_start: nil}), do: false
  defp date_in_range_middle?(_date, %{range_end: nil}), do: false

  defp date_in_range_middle?(date, %{range_start: %Date{} = rs, range_end: %Date{} = re}) do
    Date.compare(date, rs) != :lt and Date.compare(date, re) != :gt
  end

  defp date_in_range_middle?(_date, _selection), do: false

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

  defp day_full_name("Su"), do: "Sunday"
  defp day_full_name("Mo"), do: "Monday"
  defp day_full_name("Tu"), do: "Tuesday"
  defp day_full_name("We"), do: "Wednesday"
  defp day_full_name("Th"), do: "Thursday"
  defp day_full_name("Fr"), do: "Friday"
  defp day_full_name("Sa"), do: "Saturday"
end
