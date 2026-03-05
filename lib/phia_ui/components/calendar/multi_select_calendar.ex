defmodule PhiaUi.Components.MultiSelectCalendar do
  @moduledoc """
  A full-month calendar grid where multiple individual (non-contiguous) dates
  can be toggled on/off.

  Selected dates are rendered as individual filled rounded rectangles using
  `bg-primary/20 text-primary font-semibold`. This is distinct from
  `RangeCalendar`, which selects a contiguous band of dates.

  The grid is SUN-first (Sun Mon Tue Wed Thu Fri Sat). Adjacent-month days are
  rendered faded (`opacity-40`) to fill the first and last rows.

  Month and year navigation is provided through navigation buttons (`on_prev`,
  `on_next`) and/or `<select>` dropdowns (`on_month_change`, `on_year_change`).
  State (current month/year, selected dates) lives entirely in the parent
  LiveView.

  ## Example

      <.multi_select_calendar
        year={@year}
        month={@month}
        selected_dates={@selected_dates}
        on_select="toggle_date"
        on_prev="prev_month"
        on_next="next_month"
        on_month_change="month_changed"
        on_year_change="year_changed"
      />

  ## LiveView event handlers

      def handle_event("toggle_date", %{"date" => iso}, socket) do
        date = Date.from_iso8601!(iso)
        selected =
          if date in socket.assigns.selected_dates do
            List.delete(socket.assigns.selected_dates, date)
          else
            [date | socket.assigns.selected_dates]
          end
        {:noreply, assign(socket, selected_dates: selected)}
      end

      def handle_event("prev_month", _params, socket) do
        {y, m} = prev_ym(socket.assigns.year, socket.assigns.month)
        {:noreply, assign(socket, year: y, month: m)}
      end

      def handle_event("next_month", _params, socket) do
        {y, m} = next_ym(socket.assigns.year, socket.assigns.month)
        {:noreply, assign(socket, year: y, month: m)}
      end

      def handle_event("month_changed", %{"month" => m}, socket) do
        {:noreply, assign(socket, month: String.to_integer(m))}
      end

      def handle_event("year_changed", %{"year" => y}, socket) do
        {:noreply, assign(socket, year: String.to_integer(y))}
      end

  ## Zero JavaScript

  This component is entirely server-rendered. No JS hook is required.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  @day_names ~w(Sun Mon Tue Wed Thu Fri Sat)

  @month_names ~w(January February March April May June July August September October November December)

  attr :year, :integer, required: true, doc: "4-digit year of the displayed month"
  attr :month, :integer, required: true, doc: "Month number (1–12)"

  attr :selected_dates, :list,
    default: [],
    doc: "List of `Date.t()` values that are currently selected"

  attr :on_select, :string,
    default: nil,
    doc: """
    `phx-click` event name fired when any current-month day is clicked.
    The LiveView receives `%{"date" => "YYYY-MM-DD"}`. Clicking a selected date
    again is intended to deselect it — the toggle logic lives in the parent.
    """

  attr :on_prev, :string,
    default: nil,
    doc: "`phx-click` event name for the previous-month navigation button"

  attr :on_next, :string,
    default: nil,
    doc: "`phx-click` event name for the next-month navigation button"

  attr :on_month_change, :string,
    default: nil,
    doc: "`phx-change` event name for the month `<select>` dropdown"

  attr :on_year_change, :string,
    default: nil,
    doc: "`phx-change` event name for the year `<select>` dropdown"

  attr :min_year, :integer,
    default: 2000,
    doc: "Earliest year shown in the year `<select>` dropdown"

  attr :max_year, :integer,
    default: 2040,
    doc: "Latest year shown in the year `<select>` dropdown"

  attr :class, :string, default: nil, doc: "Additional CSS classes merged onto the root element"
  attr :rest, :global, doc: "HTML attributes forwarded to the root `<div>`"

  @doc """
  Renders a single-month calendar grid supporting multiple individual date
  selections.

  All geometry (leading/trailing days, per-cell selection state) is computed
  server-side before the template renders.
  """
  def multi_select_calendar(assigns) do
    days = build_days(assigns.year, assigns.month)

    assigns =
      assigns
      |> assign(:days, days)
      |> assign(:day_names, @day_names)
      |> assign(:month_names, @month_names)
      |> assign(:month_name, month_name(assigns.month))

    ~H"""
    <div
      class={cn(["bg-background rounded-2xl border border-border shadow-sm p-4 select-none", @class])}
      {@rest}
    >
      <%!-- Header: prev button · month+year title/selects · next button --%>
      <div class="flex items-center justify-between mb-4">
        <button
          :if={@on_prev}
          phx-click={@on_prev}
          class="flex h-8 w-8 items-center justify-center rounded-full hover:bg-muted/50 text-foreground text-lg font-bold transition-colors"
          aria-label="Previous month"
        >
          &#8249;
        </button>
        <span :if={!@on_prev} class="w-8" />

        <div class="flex items-center gap-2">
          <%!-- Month — either a <select> (when on_month_change provided) or plain text --%>
          <select
            :if={@on_month_change}
            phx-change={@on_month_change}
            name="month"
            class="text-sm font-semibold bg-transparent border-none cursor-pointer focus:outline-none"
          >
            <option :for={m <- 1..12} value={m} selected={m == @month}>
              {Enum.at(@month_names, m - 1)}
            </option>
          </select>
          <span :if={!@on_month_change} class="text-sm font-semibold text-foreground">
            {@month_name}
          </span>

          <%!-- Year — either a <select> (when on_year_change provided) or plain text --%>
          <select
            :if={@on_year_change}
            phx-change={@on_year_change}
            name="year"
            class="text-sm font-semibold bg-transparent border-none cursor-pointer focus:outline-none"
          >
            <option :for={y <- @min_year..@max_year} value={y} selected={y == @year}>
              {y}
            </option>
          </select>
          <span :if={!@on_year_change} class="text-sm font-semibold text-foreground">
            {@year}
          </span>
        </div>

        <button
          :if={@on_next}
          phx-click={@on_next}
          class="flex h-8 w-8 items-center justify-center rounded-full hover:bg-muted/50 text-foreground text-lg font-bold transition-colors"
          aria-label="Next month"
        >
          &#8250;
        </button>
        <span :if={!@on_next} class="w-8" />
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
        <div
          :for={cell <- @days}
          class="flex items-center justify-center"
        >
          <span
            class={day_class(cell.date, @selected_dates, cell.current_month)}
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

  # Builds a flat list of day cell maps covering the full displayed grid.
  # Cells include leading adjacent-month days (from the previous month) and
  # trailing adjacent-month days (from the next month) to always produce
  # complete rows of 7.
  #
  # SUN-first offset:
  #   Date.day_of_week/1 returns 1=Mon..7=Sun.
  #   rem(dow, 7) maps: Mon→1, Tue→2, Wed→3, Thu→4, Fri→5, Sat→6, Sun→0.
  @spec build_days(integer(), integer()) :: [%{date: Date.t(), current_month: boolean()}]
  defp build_days(year, month) do
    first = Date.new!(year, month, 1)
    last = Date.end_of_month(first)
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

    all ++ next_cells
  end

  # ---------------------------------------------------------------------------
  # CSS class helpers
  # ---------------------------------------------------------------------------

  # Returns the full class string for a single day cell `<span>`.
  # Uses `cond` because three conditions are mutually exclusive and the
  # "not current_month" case must be checked regardless of selection state.
  defp day_class(date, selected_dates, current_month) do
    selected = date in selected_dates
    base = "flex h-9 w-full items-center justify-center text-sm rounded-md"

    cond do
      not current_month ->
        cn([base, "text-muted-foreground opacity-40", selected && "bg-primary/10"])

      selected ->
        cn([base, "bg-primary/20 text-primary font-semibold cursor-pointer"])

      true ->
        cn([base, "text-foreground cursor-pointer hover:bg-muted/50"])
    end
  end

  # ---------------------------------------------------------------------------
  # Title helpers
  # ---------------------------------------------------------------------------

  defp month_name(m), do: Enum.at(@month_names, m - 1)
end
