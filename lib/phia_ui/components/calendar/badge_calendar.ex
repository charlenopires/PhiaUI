defmodule PhiaUi.Components.BadgeCalendar do
  @moduledoc """
  Month calendar where each day cell can show a small badge count at the top
  and the day number at the bottom.

  Unlike `EventCalendar` (which uses dot indicators per event), `BadgeCalendar`
  shows a single numeric count badge per day — ideal for showing notification
  counts, task counts, or any scalar metric alongside a calendar date.

  ## Features

  - SUN-first column headers (`S M T W T F S`) — single-letter abbreviations
  - Title formatted as `"November, 2024"`
  - Badge count in primary color at the top of each cell (when count > 0)
  - Day number at the bottom of each cell
  - Selected day: dark filled card (`bg-foreground`) with inverted text colors
  - Adjacent-month padding cells are invisible (`opacity-0`)
  - Optional prev/next navigation buttons
  - Optional `on_select` event for day clicks

  ## Badges format

      badges = %{
        ~D[2024-11-08] => 4,
        ~D[2024-11-15] => 2,
        ~D[2024-11-22] => 9
      }

  ## Examples

      <%!-- Basic --%>
      <.badge_calendar year={2024} month={11} />

      <%!-- With badges --%>
      <.badge_calendar year={2024} month={11} badges={@badges} />

      <%!-- With selection and navigation --%>
      <.badge_calendar
        year={2024}
        month={11}
        badges={@badges}
        selected_date={@selected}
        on_select="pick_date"
        on_prev="prev_month"
        on_next="next_month"
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  @day_names ~w(S M T W T F S)

  attr :year, :integer, required: true, doc: "Calendar year (e.g. 2024)"
  attr :month, :integer, required: true, doc: "Calendar month, 1–12"

  attr :badges, :map,
    default: %{},
    doc: "Map of %{Date.t() => integer} — numeric badge count per day"

  attr :selected_date, :any,
    default: nil,
    doc: "Currently selected date (Date.t()). That cell gets the dark filled style."

  attr :on_select, :string,
    default: nil,
    doc:
      "LiveView event fired when a current-month day is clicked. Receives `phx-value-date` (ISO 8601)."

  attr :on_prev, :string,
    default: nil,
    doc: "LiveView event fired by the prev (‹) button."

  attr :on_next, :string,
    default: nil,
    doc: "LiveView event fired by the next (›) button."

  attr :class, :string, default: nil, doc: "Additional CSS classes for the root element."

  attr :rest, :global, doc: "HTML attributes forwarded to the root `<div>` element."

  @doc """
  Renders a month calendar with per-day badge counts.

  ## Example

      <.badge_calendar
        year={2024}
        month={11}
        badges={%{~D[2024-11-08] => 4}}
        selected_date={~D[2024-11-08]}
        on_select="pick_date"
      />
  """
  def badge_calendar(assigns) do
    assigns =
      assigns
      |> assign(:title, format_title(assigns.year, assigns.month))
      |> assign(:days, build_days(assigns.year, assigns.month))
      |> assign(:day_names, @day_names)

    ~H"""
    <div class={cn(["bg-background rounded-2xl border border-border shadow-sm p-4", @class])} {@rest}>
      <%!-- Header --%>
      <div class="flex items-center justify-between mb-4">
        <button
          :if={@on_prev}
          phx-click={@on_prev}
          class="flex h-8 w-8 items-center justify-center rounded-full hover:bg-muted/50"
        >
          ‹
        </button>
        <span :if={!@on_prev} class="w-8" />
        <span class="text-base font-semibold">{@title}</span>
        <button
          :if={@on_next}
          phx-click={@on_next}
          class="flex h-8 w-8 items-center justify-center rounded-full hover:bg-muted/50"
        >
          ›
        </button>
        <span :if={!@on_next} class="w-8" />
      </div>

      <%!-- Day name headers (single letter) --%>
      <div class="grid grid-cols-7 mb-2">
        <div
          :for={name <- @day_names}
          class="flex h-6 items-center justify-center text-xs text-muted-foreground font-medium"
        >
          {name}
        </div>
      </div>

      <%!-- Day grid --%>
      <div class="grid grid-cols-7 gap-1">
        <div
          :for={cell <- @days}
          class={cell_class(cell.date, @selected_date, cell.current_month)}
          phx-click={if @on_select && cell.current_month, do: @on_select}
          phx-value-date={
            if @on_select && cell.current_month, do: Date.to_iso8601(cell.date)
          }
        >
          <%!-- Badge number (top) --%>
          <span
            :if={cell.current_month && Map.get(@badges, cell.date, 0) > 0}
            class={badge_class(cell.date, @selected_date)}
          >
            {Map.get(@badges, cell.date)}
          </span>
          <span
            :if={!(cell.current_month && Map.get(@badges, cell.date, 0) > 0)}
            class="h-4"
          />
          <%!-- Day number (bottom) --%>
          <span :if={cell.current_month} class={day_num_class(cell.date, @selected_date)}>
            {cell.date.day}
          </span>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Builds the flat list of day cells for the calendar grid.
  # Each cell is %{date: Date.t(), current_month: boolean}.
  # The grid is SUN-first: ISO day_of_week/1 returns 1(Mon)–7(Sun).
  # rem(day_of_week, 7) maps Sun → 0, Mon → 1, …, Sat → 6.
  defp build_days(year, month) do
    first = Date.new!(year, month, 1)
    last = Date.end_of_month(first)
    offset = rem(Date.day_of_week(first, :default), 7)

    # Padding cells from the previous month
    prev_cells =
      if offset > 0 do
        prev_last = Date.add(first, -1)

        Enum.map((offset - 1)..0//-1, fn i ->
          %{date: Date.add(prev_last, -i), current_month: false}
        end)
      else
        []
      end

    # Current month cells
    current_cells =
      Enum.map(Date.range(first, last), fn d ->
        %{date: d, current_month: true}
      end)

    all = prev_cells ++ current_cells

    # Trailing padding cells from the next month
    remainder = rem(length(all), 7)

    next_cells =
      if remainder == 0 do
        []
      else
        next_first = Date.add(last, 1)

        Enum.map(0..(6 - remainder), fn i ->
          %{date: Date.add(next_first, i), current_month: false}
        end)
      end

    all ++ next_cells
  end

  defp format_title(year, month) do
    date = Date.new!(year, month, 1)
    Calendar.strftime(date, "%B, %Y")
  end

  defp cell_class(date, selected_date, current_month) do
    cond do
      date == selected_date ->
        "flex flex-col items-center justify-between h-14 w-full rounded-xl bg-foreground text-background px-1 py-1.5 cursor-pointer"

      not current_month ->
        "flex flex-col items-center justify-between h-14 w-full rounded-xl px-1 py-1.5 opacity-0"

      true ->
        "flex flex-col items-center justify-between h-14 w-full rounded-xl border border-border bg-background px-1 py-1.5 cursor-pointer hover:bg-muted/50"
    end
  end

  defp badge_class(date, selected_date) do
    if date == selected_date do
      "text-xs font-bold text-background/90 self-start"
    else
      "text-xs font-bold text-primary self-start"
    end
  end

  defp day_num_class(date, selected_date) do
    if date == selected_date do
      "text-sm font-semibold text-background"
    else
      "text-sm text-foreground"
    end
  end
end
