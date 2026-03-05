defmodule PhiaUi.Components.StreakCalendar do
  @moduledoc """
  Duolingo/Fitbit-style habit streak calendar.

  Shows daily completion states (:completed, :missed, :rest) for a given month.
  Displays streak count in header. Unlike HeatmapCalendar (GitHub intensity 0-4),
  StreakCalendar focuses on binary habit completion with emotional/motivational UX.

  ## Example

      <.streak_calendar
        year={2026}
        month={3}
        entries={%{~D[2026-03-01] => :completed, ~D[2026-03-02] => :missed}}
        streak_count={5}
        on_select="pick_day"
        on_prev="prev_month"
        on_next="next_month"
      />
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  @day_names ~w(Mon Tue Wed Thu Fri Sat Sun)

  attr :year, :integer, required: true
  attr :month, :integer, required: true
  attr :entries, :map, default: %{}
  attr :streak_count, :integer, default: 0
  attr :on_select, :string, default: nil
  attr :on_prev, :string, default: nil
  attr :on_next, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  def streak_calendar(assigns) do
    days = build_days(assigns.year, assigns.month, assigns.entries)
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
      <%!-- Streak header --%>
      <div class="flex items-center justify-between mb-3 px-1">
        <button
          :if={@on_prev}
          phx-click={@on_prev}
          class="flex h-8 w-8 items-center justify-center rounded-full border border-border hover:bg-muted transition-colors text-foreground"
          aria-label="Previous month"
        >
          &#8249;
        </button>
        <span :if={!@on_prev} class="w-8" />

        <div class="flex flex-col items-center">
          <span class="text-base font-semibold text-foreground">{@title}</span>
          <span :if={@streak_count > 0} class="text-xs text-orange-500 font-medium mt-0.5">
            🔥 {@streak_count} day streak
          </span>
          <span :if={@streak_count == 0} class="text-xs text-muted-foreground mt-0.5">
            Start your streak!
          </span>
        </div>

        <button
          :if={@on_next}
          phx-click={@on_next}
          class="flex h-8 w-8 items-center justify-center rounded-full border border-border hover:bg-muted transition-colors text-foreground"
          aria-label="Next month"
        >
          &#8250;
        </button>
        <span :if={!@on_next} class="w-8" />
      </div>

      <%!-- Day headers (MON-first) --%>
      <div class="grid grid-cols-7 mb-1">
        <div
          :for={name <- @day_names}
          class="flex h-7 items-center justify-center text-xs font-medium text-muted-foreground"
        >
          {name}
        </div>
      </div>

      <%!-- Day grid --%>
      <div class="grid grid-cols-7 gap-y-1">
        <div
          :for={cell <- @days}
          class="flex items-center justify-center h-9"
        >
          <span
            class={cn([entry_class(cell.entry), !cell.current_month && "opacity-30"])}
            phx-click={if @on_select && cell.current_month, do: @on_select}
            phx-value-date={if @on_select && cell.current_month, do: Date.to_iso8601(cell.date)}
          >
            {cell.date.day}
          </span>
        </div>
      </div>

      <%!-- Legend --%>
      <div class="flex items-center gap-4 mt-3 px-1 text-xs text-muted-foreground">
        <span class="flex items-center gap-1">
          <span class="inline-block w-4 h-4 rounded-full bg-green-500" />
          Done
        </span>
        <span class="flex items-center gap-1">
          <span class="inline-block w-4 h-4 rounded-full bg-red-200" />
          Missed
        </span>
        <span class="flex items-center gap-1">
          <span class="inline-block w-4 h-4 rounded-full bg-muted" />
          Rest
        </span>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Grid builder (MON-first)
  # ---------------------------------------------------------------------------

  defp build_days(year, month, entries) do
    first = Date.new!(year, month, 1)
    last = Date.end_of_month(first)

    # MON-first offset: Date.day_of_week returns 1=Mon..7=Sun → offset = dow - 1
    offset = Date.day_of_week(first) - 1

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
      Map.put(cell, :entry, Map.get(entries, cell.date, :none))
    end)
  end

  # ---------------------------------------------------------------------------
  # CSS class helpers (pattern matching only)
  # ---------------------------------------------------------------------------

  defp entry_class(:completed) do
    "flex h-8 w-8 items-center justify-center rounded-full bg-green-500 text-white text-sm font-semibold cursor-pointer"
  end

  defp entry_class(:missed) do
    "flex h-8 w-8 items-center justify-center rounded-full bg-red-200 text-red-700 text-sm font-semibold cursor-pointer"
  end

  defp entry_class(:rest) do
    "flex h-8 w-8 items-center justify-center rounded-full bg-muted text-muted-foreground text-sm cursor-pointer"
  end

  defp entry_class(:none) do
    "flex h-8 w-8 items-center justify-center text-sm text-foreground hover:bg-muted rounded-full cursor-pointer"
  end

  # ---------------------------------------------------------------------------
  # Title formatter
  # ---------------------------------------------------------------------------

  defp format_title(year, month) do
    date = Date.new!(year, month, 1)
    Calendar.strftime(date, "%B '%y")
  end
end
