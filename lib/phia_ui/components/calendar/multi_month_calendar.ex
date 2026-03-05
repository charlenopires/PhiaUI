defmodule PhiaUi.Components.MultiMonthCalendar do
  @moduledoc """
  Airbnb-style multi-month calendar showing 2 or 3 months side by side.

  Unlike DateRangePicker (two calendars in a popover), MultiMonthCalendar is
  always visible. The range band extends across months — range_start can be in
  month N while range_end is in month N+1.

  ## Example

      <.multi_month_calendar
        year={2026}
        month={3}
        months_count={2}
        range_start={@from}
        range_end={@to}
        on_select="pick_date"
        on_prev="prev"
        on_next="next"
      />
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  @sun_names ~w(Sun Mon Tue Wed Thu Fri Sat)
  @mon_names ~w(Mon Tue Wed Thu Fri Sat Sun)

  attr :year, :integer, required: true
  attr :month, :integer, required: true
  attr :months_count, :integer, default: 2, values: [2, 3]
  attr :range_start, :any, default: nil
  attr :range_end, :any, default: nil
  attr :on_select, :string, default: nil
  attr :on_prev, :string, default: nil
  attr :on_next, :string, default: nil
  attr :first_day, :atom, default: :sun, values: [:sun, :mon]
  attr :class, :string, default: nil
  attr :rest, :global

  def multi_month_calendar(assigns) do
    month_grids = build_month_grids(assigns.year, assigns.month, assigns.months_count, assigns.first_day, assigns.range_start, assigns.range_end)
    day_names = if assigns.first_day == :sun, do: @sun_names, else: @mon_names

    assigns =
      assigns
      |> assign(:month_grids, month_grids)
      |> assign(:day_names, day_names)

    ~H"""
    <div
      class={cn(["bg-background rounded-2xl border border-border shadow-sm p-4 select-none", @class])}
      {@rest}
    >
      <%!-- Outer navigation bar --%>
      <div class="flex items-center justify-between mb-4 px-1">
        <button
          :if={@on_prev}
          phx-click={@on_prev}
          class="flex h-9 w-9 items-center justify-center rounded-full bg-primary text-primary-foreground text-lg font-bold hover:bg-primary/90 transition-colors"
          aria-label="Previous period"
        >
          &#8249;
        </button>
        <span :if={!@on_prev} class="w-9" />

        <span class="text-base font-semibold text-foreground">
          {List.first(@month_grids).title} – {List.last(@month_grids).title}
        </span>

        <button
          :if={@on_next}
          phx-click={@on_next}
          class="flex h-9 w-9 items-center justify-center rounded-full bg-primary text-primary-foreground text-lg font-bold hover:bg-primary/90 transition-colors"
          aria-label="Next period"
        >
          &#8250;
        </button>
        <span :if={!@on_next} class="w-9" />
      </div>

      <%!-- Month grids --%>
      <div class="flex flex-wrap gap-6 justify-center">
        <div :for={grid <- @month_grids} class="min-w-[280px]">
          <%!-- Month title --%>
          <div class="text-center text-sm font-semibold text-foreground mb-3">
            {grid.title}
          </div>

          <%!-- Day headers --%>
          <div class="grid grid-cols-7 mb-1">
            <div
              :for={name <- @day_names}
              class="flex h-8 items-center justify-center text-xs font-medium text-muted-foreground"
            >
              {name}
            </div>
          </div>

          <%!-- Day cells --%>
          <div class="grid grid-cols-7">
            <div :for={cell <- grid.days} class={cell_wrapper_class(cell.state)}>
              <div :if={cell.state in [:range_start, :range_end]} class={band_div_class(cell.state)} />
              <span
                class={cn([number_class(cell.state), !cell.current_month && "opacity-40"])}
                phx-click={if @on_select && cell.current_month, do: @on_select}
                phx-value-date={if @on_select && cell.current_month, do: Date.to_iso8601(cell.date)}
              >
                {cell.date.day}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Month grid builders
  # ---------------------------------------------------------------------------

  defp build_month_grids(year, month, months_count, first_day, range_start, range_end) do
    0..(months_count - 1)
    |> Enum.map(fn offset ->
      {y, m} = add_months(year, month, offset)
      days = build_days(y, m, first_day, range_start, range_end)
      title = format_title(y, m)
      %{year: y, month: m, title: title, days: days}
    end)
  end

  defp add_months(year, month, 0), do: {year, month}
  defp add_months(year, month, offset) do
    total = (year * 12 + month - 1) + offset
    new_year = div(total, 12)
    new_month = rem(total, 12) + 1
    {new_year, new_month}
  end

  defp build_days(year, month, first_day, range_start, range_end) do
    first = Date.new!(year, month, 1)
    last = Date.end_of_month(first)

    offset = day_offset(first, first_day)

    prev_cells =
      if offset > 0 do
        prev_last = Date.add(first, -1)
        prev_first = Date.add(prev_last, -(offset - 1))
        Date.range(prev_first, prev_last) |> Enum.map(&%{date: &1, current_month: false})
      else
        []
      end

    current_cells = Date.range(first, last) |> Enum.map(&%{date: &1, current_month: true})
    all = prev_cells ++ current_cells
    remainder = rem(length(all), 7)

    next_cells =
      if remainder > 0 do
        next_first = Date.add(last, 1)
        next_last = Date.add(next_first, 7 - remainder - 1)
        Date.range(next_first, next_last) |> Enum.map(&%{date: &1, current_month: false})
      else
        []
      end

    (all ++ next_cells)
    |> Enum.map(fn cell ->
      Map.put(cell, :state, day_state(cell.date, range_start, range_end))
    end)
  end

  defp day_offset(first, :sun) do
    # Sun-first: Sun=0, Mon=1, ..., Sat=6
    rem(Date.day_of_week(first), 7)
  end

  defp day_offset(first, :mon) do
    # Mon-first: Mon=0, ..., Sun=6
    Date.day_of_week(first) - 1
  end

  # ---------------------------------------------------------------------------
  # State / range helpers (same as range_calendar)
  # ---------------------------------------------------------------------------

  defp day_state(date, range_start, range_end) do
    cond do
      date == range_start and date == range_end -> :single
      date == range_start -> :range_start
      date == range_end -> :range_end
      in_range?(date, range_start, range_end) -> :range_middle
      true -> :default
    end
  end

  defp in_range?(_date, nil, _end), do: false
  defp in_range?(_date, _start, nil), do: false
  defp in_range?(date, range_start, range_end) do
    Date.compare(date, range_start) == :gt and Date.compare(date, range_end) == :lt
  end

  # ---------------------------------------------------------------------------
  # CSS class helpers
  # ---------------------------------------------------------------------------

  defp cell_wrapper_class(:range_middle),
    do: "relative flex items-center justify-center h-9 bg-primary/20"
  defp cell_wrapper_class(_), do: "relative flex items-center justify-center h-9"

  defp band_div_class(:range_start), do: "absolute inset-y-0 left-1/2 right-0 bg-primary/20"
  defp band_div_class(:range_end), do: "absolute inset-y-0 left-0 right-1/2 bg-primary/20"
  defp band_div_class(_), do: nil

  defp number_class(:range_start),
    do: "relative z-10 flex h-8 w-8 items-center justify-center rounded-full bg-primary text-primary-foreground text-sm font-semibold cursor-pointer"
  defp number_class(:range_end),
    do: "relative z-10 flex h-8 w-8 items-center justify-center rounded-full bg-primary text-primary-foreground text-sm font-semibold cursor-pointer"
  defp number_class(:single),
    do: "relative z-10 flex h-8 w-8 items-center justify-center rounded-full bg-primary text-primary-foreground text-sm font-semibold cursor-pointer"
  defp number_class(:range_middle),
    do: "relative z-10 flex h-8 w-8 items-center justify-center text-sm font-medium text-foreground cursor-pointer"
  defp number_class(:default),
    do: "relative z-10 flex h-8 w-8 items-center justify-center text-sm text-foreground hover:bg-muted rounded-full cursor-pointer"

  # ---------------------------------------------------------------------------
  # Title formatter
  # ---------------------------------------------------------------------------

  defp format_title(year, month) do
    date = Date.new!(year, month, 1)
    Calendar.strftime(date, "%B '%y")
  end
end
