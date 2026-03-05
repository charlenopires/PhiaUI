defmodule PhiaUi.Components.BookingCalendar do
  @moduledoc """
  Airbnb-style booking calendar with per-cell availability states.

  Unlike RangeCalendar (pure range selection), BookingCalendar adds availability
  states per cell: :available, :unavailable, :check_in_only, :check_out_only.

  Supports optional price display per cell and range selection with visual band.

  ## Example

      <.booking_calendar
        year={2026}
        month={3}
        availability={%{~D[2026-03-15] => :unavailable, ~D[2026-03-20] => :check_in_only}}
        prices={%{~D[2026-03-10] => "$120"}}
        range_start={@from}
        range_end={@to}
        on_select="pick_date"
        on_prev="prev_month"
        on_next="next_month"
      />
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  @mon_names ~w(Mon Tue Wed Thu Fri Sat Sun)
  @sun_names ~w(Sun Mon Tue Wed Thu Fri Sat)

  attr :year, :integer, required: true
  attr :month, :integer, required: true
  attr :availability, :map, default: %{}
  attr :prices, :map, default: %{}
  attr :range_start, :any, default: nil
  attr :range_end, :any, default: nil
  attr :on_select, :string, default: nil
  attr :on_prev, :string, default: nil
  attr :on_next, :string, default: nil
  attr :first_day, :atom, default: :mon, values: [:mon, :sun]
  attr :class, :string, default: nil
  attr :rest, :global

  def booking_calendar(assigns) do
    days = build_days(assigns.year, assigns.month, assigns.first_day, assigns.range_start, assigns.range_end, assigns.availability, assigns.prices)
    title = format_title(assigns.year, assigns.month)
    day_names = if assigns.first_day == :mon, do: @mon_names, else: @sun_names

    assigns =
      assigns
      |> assign(:days, days)
      |> assign(:title, title)
      |> assign(:day_names, day_names)

    ~H"""
    <div
      class={cn(["bg-background rounded-2xl border border-border shadow-sm p-4 select-none", @class])}
      {@rest}
    >
      <%!-- Header --%>
      <div class="flex items-center justify-between mb-4 px-1">
        <button
          :if={@on_prev}
          phx-click={@on_prev}
          class="flex h-9 w-9 items-center justify-center rounded-full border border-border hover:bg-muted transition-colors text-foreground text-lg"
          aria-label="Previous month"
        >
          &#8249;
        </button>
        <span :if={!@on_prev} class="w-9" />

        <span class="text-base font-semibold text-foreground">{@title}</span>

        <button
          :if={@on_next}
          phx-click={@on_next}
          class="flex h-9 w-9 items-center justify-center rounded-full border border-border hover:bg-muted transition-colors text-foreground text-lg"
          aria-label="Next month"
        >
          &#8250;
        </button>
        <span :if={!@on_next} class="w-9" />
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

      <%!-- Day grid --%>
      <div class="grid grid-cols-7">
        <div :for={cell <- @days} class={cell_wrapper_class(cell.range_state)}>
          <div :if={cell.range_state in [:range_start, :range_end]} class={band_div_class(cell.range_state)} />
          <div class={cell_inner_class(cell)}>
            <span
              class={cn([number_class(cell), !cell.current_month && "opacity-40"])}
              phx-click={if @on_select && cell.current_month && cell.avail != :unavailable, do: @on_select}
              phx-value-date={if @on_select && cell.current_month && cell.avail != :unavailable, do: Date.to_iso8601(cell.date)}
            >
              {cell.date.day}
            </span>
            <span :if={cell.price && cell.current_month} class="text-[9px] text-muted-foreground leading-none mt-0.5">
              {cell.price}
            </span>
          </div>
        </div>
      </div>

      <%!-- Legend --%>
      <div class="flex items-center gap-4 mt-4 px-1 text-xs text-muted-foreground">
        <span class="flex items-center gap-1">
          <span class="inline-block w-4 h-4 rounded bg-muted opacity-60 border border-border" />
          Unavailable
        </span>
        <span class="flex items-center gap-1">
          <span class="inline-block w-4 h-4 rounded bg-background border border-border" />
          Available
        </span>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Grid builder
  # ---------------------------------------------------------------------------

  defp build_days(year, month, first_day, range_start, range_end, availability, prices) do
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
      avail = Map.get(availability, cell.date, :available)
      price = Map.get(prices, cell.date)
      range_state = day_range_state(cell.date, range_start, range_end)

      cell
      |> Map.put(:avail, avail)
      |> Map.put(:price, price)
      |> Map.put(:range_state, range_state)
    end)
  end

  defp day_offset(first, :mon) do
    # Mon-first: Mon=0, Tue=1, ..., Sun=6
    # Date.day_of_week returns 1=Mon..7=Sun
    Date.day_of_week(first) - 1
  end

  defp day_offset(first, :sun) do
    # Sun-first: Sun=0, Mon=1, ..., Sat=6
    rem(Date.day_of_week(first), 7)
  end

  # ---------------------------------------------------------------------------
  # Range state
  # ---------------------------------------------------------------------------

  defp day_range_state(date, range_start, range_end) do
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
  # CSS helpers
  # ---------------------------------------------------------------------------

  defp cell_wrapper_class(:range_middle),
    do: "relative flex flex-col items-center justify-center h-12 bg-primary/20"
  defp cell_wrapper_class(_), do: "relative flex flex-col items-center justify-center h-12"

  defp band_div_class(:range_start), do: "absolute inset-y-0 left-1/2 right-0 bg-primary/20"
  defp band_div_class(:range_end), do: "absolute inset-y-0 left-0 right-1/2 bg-primary/20"
  defp band_div_class(_), do: nil

  defp cell_inner_class(%{avail: :unavailable}),
    do: "relative z-10 flex flex-col items-center"
  defp cell_inner_class(_), do: "relative z-10 flex flex-col items-center"

  defp number_class(%{avail: :unavailable}) do
    "flex h-8 w-8 items-center justify-center rounded-full text-sm line-through opacity-40 cursor-not-allowed"
  end

  defp number_class(%{avail: :check_in_only, range_state: rs}) when rs == :default do
    "flex h-8 w-8 items-center justify-center rounded-full text-sm text-foreground border border-dashed border-primary cursor-pointer hover:bg-primary/5"
  end

  defp number_class(%{avail: :check_out_only, range_state: rs}) when rs == :default do
    "flex h-8 w-8 items-center justify-center rounded-full text-sm text-foreground border border-dashed border-muted-foreground cursor-pointer hover:bg-muted"
  end

  defp number_class(%{range_state: :range_start}) do
    "flex h-8 w-8 items-center justify-center rounded-full bg-primary text-primary-foreground text-sm font-semibold cursor-pointer"
  end

  defp number_class(%{range_state: :range_end}) do
    "flex h-8 w-8 items-center justify-center rounded-full bg-primary text-primary-foreground text-sm font-semibold cursor-pointer"
  end

  defp number_class(%{range_state: :single}) do
    "flex h-8 w-8 items-center justify-center rounded-full bg-primary text-primary-foreground text-sm font-semibold cursor-pointer"
  end

  defp number_class(%{range_state: :range_middle}) do
    "flex h-8 w-8 items-center justify-center text-sm font-medium text-foreground cursor-pointer"
  end

  defp number_class(_) do
    "flex h-8 w-8 items-center justify-center rounded-full text-sm text-foreground hover:bg-muted cursor-pointer"
  end

  # ---------------------------------------------------------------------------
  # Title formatter
  # ---------------------------------------------------------------------------

  defp format_title(year, month) do
    date = Date.new!(year, month, 1)
    Calendar.strftime(date, "%B '%y")
  end
end
