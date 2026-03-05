defmodule PhiaUi.Components.RangeCalendar do
  @moduledoc """
  A full-month calendar grid with range selection visualised as a continuous
  band.

  Range visualisation:
  - **range_start**: blue filled circle on the number + right-half band
    background connecting to the middle days.
  - **range_middle**: full-width band background.
  - **range_end**: blue filled circle on the number + left-half band
    background connecting from the middle days.
  - **single** (start == end): blue filled circle only — no band.

  State (current month, range boundaries) lives entirely in the parent
  LiveView. Day clicks and month navigation fire `phx-click` events.

  ## Example

      <.range_calendar
        year={@year}
        month={@month}
        range_start={@from}
        range_end={@to}
        on_select="pick_date"
        on_prev="prev_month"
        on_next="next_month"
      />

  ## LiveView event handlers

      def handle_event("pick_date", %{"date" => iso}, socket) do
        date = Date.from_iso8601!(iso)
        # two-click range protocol
        socket =
          cond do
            is_nil(socket.assigns.from) ->
              assign(socket, from: date, to: nil)
            is_nil(socket.assigns.to) and Date.compare(date, socket.assigns.from) != :lt ->
              assign(socket, to: date)
            true ->
              assign(socket, from: date, to: nil)
          end
        {:noreply, socket}
      end

      def handle_event("prev_month", _params, socket) do
        {:noreply, assign(socket, month: prev_month(socket.assigns.month, socket.assigns.year))}
      end

  ## Zero JavaScript

  This component is entirely server-rendered. No JS hook is required.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  @day_names ~w(Sun Mon Tue Wed Thu Fri Sat)

  attr :year, :integer, required: true, doc: "4-digit year of the displayed month"
  attr :month, :integer, required: true, doc: "Month number (1–12)"

  attr :range_start, :any,
    default: nil,
    doc: "Range selection start `Date.t()` (or `nil` for no selection)"

  attr :range_end, :any,
    default: nil,
    doc: "Range selection end `Date.t()` (or `nil` for open range)"

  attr :on_select, :string,
    default: nil,
    doc: """
    `phx-click` event name fired when a current-month day is clicked.
    The LiveView receives `%{"date" => "YYYY-MM-DD"}`.
    """

  attr :on_prev, :string,
    default: nil,
    doc: "`phx-click` event name for the previous-month navigation button"

  attr :on_next, :string,
    default: nil,
    doc: "`phx-click` event name for the next-month navigation button"

  attr :class, :string, default: nil, doc: "Additional CSS classes merged onto the root element"
  attr :rest, :global, doc: "HTML attributes forwarded to the root `<div>`"

  @doc """
  Renders a single-month calendar grid with range-selection band visualisation.

  All geometry (leading/trailing days, per-cell range state) is computed
  server-side before the template renders. The HEEx template is purely
  declarative — no inline logic.
  """
  def range_calendar(assigns) do
    days = build_days(assigns.year, assigns.month, assigns.range_start, assigns.range_end)
    title = format_title(assigns.year, assigns.month)

    assigns =
      assigns
      |> assign(:days, days)
      |> assign(:title, title)
      |> assign(:day_names, @day_names)

    ~H"""
    <div
      class={cn(["bg-background rounded-2xl border border-border shadow-sm p-4 select-none", @class])}
      {@rest}
    >
      <%!-- Header: prev button · title · next button --%>
      <div class="flex items-center justify-between mb-4 px-1">
        <button
          :if={@on_prev}
          phx-click={@on_prev}
          class="flex h-9 w-9 items-center justify-center rounded-full bg-primary text-primary-foreground text-lg font-bold hover:bg-primary/90 transition-colors"
          aria-label="Previous month"
        >
          &#8249;
        </button>
        <span :if={!@on_prev} class="w-9" />

        <span class="text-base font-semibold text-foreground">{@title}</span>

        <button
          :if={@on_next}
          phx-click={@on_next}
          class="flex h-9 w-9 items-center justify-center rounded-full bg-primary text-primary-foreground text-lg font-bold hover:bg-primary/90 transition-colors"
          aria-label="Next month"
        >
          &#8250;
        </button>
        <span :if={!@on_next} class="w-9" />
      </div>

      <%!-- Day-of-week column headers (Sun-first) --%>
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
        <div :for={cell <- @days} class={cell_wrapper_class(cell.state)}>
          <%!-- Half-band layer for range_start / range_end cells --%>
          <div :if={cell.state in [:range_start, :range_end]} class={band_div_class(cell.state)} />
          <%!-- Day number --%>
          <span
            class={cn([number_class(cell.state), !cell.current_month && "opacity-40"])}
            phx-click={if @on_select && cell.current_month, do: @on_select}
            phx-value-date={
              if @on_select && cell.current_month, do: Date.to_iso8601(cell.date)
            }
          >
            {cell.date.day}
          </span>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Grid builder
  # ---------------------------------------------------------------------------

  # Builds a flat list of day cell maps covering the full displayed grid
  # (leading adjacent-month days + current month days + trailing adjacent-month
  # days). Each cell is a map with keys:
  #   - :date          — the `Date.t()` value
  #   - :current_month — `true` for days in the requested month
  #   - :state         — one of :default | :single | :range_start | :range_middle | :range_end
  @spec build_days(integer(), integer(), Date.t() | nil, Date.t() | nil) :: [map()]
  defp build_days(year, month, range_start, range_end) do
    first = Date.new!(year, month, 1)
    last = Date.end_of_month(first)

    # SUN-first offset: Date.day_of_week/1 returns 1=Mon..7=Sun.
    # rem(dow, 7) maps Mon→1, Tue→2, ..., Sat→6, Sun→0.
    offset = rem(Date.day_of_week(first), 7)

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

  # ---------------------------------------------------------------------------
  # State classifier
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
  # CSS class helpers (all use pattern matching, no case/cond)
  # ---------------------------------------------------------------------------

  # Outer cell wrapper — carries the full-width middle band background.
  defp cell_wrapper_class(:range_middle),
    do: "relative flex items-center justify-center h-9 bg-primary/20"

  defp cell_wrapper_class(_state),
    do: "relative flex items-center justify-center h-9"

  # Half-band `<div>` rendered inside range_start and range_end cells.
  # range_start: band extends from centre rightward (right half)
  defp band_div_class(:range_start), do: "absolute inset-y-0 left-1/2 right-0 bg-primary/20"
  # range_end: band extends from left to centre (left half)
  defp band_div_class(:range_end), do: "absolute inset-y-0 left-0 right-1/2 bg-primary/20"
  defp band_div_class(_state), do: nil

  # Number `<span>` class — determines the circle style (or lack thereof).
  defp number_class(:range_start),
    do:
      "relative z-10 flex h-8 w-8 items-center justify-center rounded-full bg-primary text-primary-foreground text-sm font-semibold cursor-pointer"

  defp number_class(:range_end),
    do:
      "relative z-10 flex h-8 w-8 items-center justify-center rounded-full bg-primary text-primary-foreground text-sm font-semibold cursor-pointer"

  defp number_class(:single),
    do:
      "relative z-10 flex h-8 w-8 items-center justify-center rounded-full bg-primary text-primary-foreground text-sm font-semibold cursor-pointer"

  defp number_class(:range_middle),
    do:
      "relative z-10 flex h-8 w-8 items-center justify-center text-sm font-medium text-foreground cursor-pointer"

  defp number_class(:default),
    do:
      "relative z-10 flex h-8 w-8 items-center justify-center text-sm text-foreground hover:bg-muted rounded-full cursor-pointer"

  # ---------------------------------------------------------------------------
  # Title formatter
  # ---------------------------------------------------------------------------

  # Produces "July '25" style title using Calendar.strftime.
  defp format_title(year, month) do
    date = Date.new!(year, month, 1)
    Calendar.strftime(date, "%B '%y")
  end
end
