defmodule PhiaUi.Components.WeekCalendar do
  @moduledoc """
  WeekCalendar — compact week navigator with prev/next header and day strip.

  Renders a header row with a month/year title and optional prev/next arrow
  buttons, plus a 7-column day strip showing the 3-letter weekday abbreviation
  above the day number. The selected day is highlighted with a filled primary
  pill card.

  ## Example

      <.week_calendar
        week_start={~D[2025-07-14]}
        selected_date={@selected}
        on_prev="prev_week"
        on_next="next_week"
        on_select="select_date"
      />

  ## Visual layout

      < July '25 >
    Fri  Sat  Sun [Mon] Tue  Wed  Thu
     14   15   16  [17]  18   19   20
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :week_start, :any, required: true,
    doc: "Date.t() — first day of the visible 7-day strip"

  attr :selected_date, :any, default: nil,
    doc: "Date.t() or nil — the currently highlighted day"

  attr :on_select, :string, default: nil,
    doc: "phx-click event name for day selection; receives phx-value-date (ISO 8601)"

  attr :on_prev, :string, default: nil,
    doc: "phx-click event name for the previous-week arrow button"

  attr :on_next, :string, default: nil,
    doc: "phx-click event name for the next-week arrow button"

  attr :title_format, :string, default: "%B '%y",
    doc: "strftime format string for the header title (default: \"July '25\")"

  attr :class, :string, default: nil,
    doc: "Additional CSS classes merged onto the wrapper element"

  attr :rest, :global,
    doc: "HTML attributes forwarded to the wrapper div"

  @doc """
  Renders a compact week navigator component.

  The header displays a centred title (formatted via `:title_format`) flanked
  by optional prev/next navigation buttons. Below the header, 7 day columns
  each show the abbreviated weekday name and the calendar day number. The
  `:selected_date` column is rendered with `bg-primary text-primary-foreground`
  and a rounded pill style.

  ## Examples

      <%!-- Read-only week view --%>
      <.week_calendar week_start={~D[2025-07-14]} selected_date={~D[2025-07-17]} />

      <%!-- Full navigation and selection --%>
      <.week_calendar
        week_start={@week_start}
        selected_date={@selected}
        on_prev="prev_week"
        on_next="next_week"
        on_select="select_date"
      />
  """
  def week_calendar(assigns) do
    assigns =
      assigns
      |> assign(:dates, week_dates(assigns.week_start))
      |> assign(:title, Calendar.strftime(assigns.week_start, assigns.title_format))

    ~H"""
    <div
      class={cn(["bg-background rounded-2xl border border-border shadow-sm p-4", @class])}
      {@rest}
    >
      <%!-- Header: prev arrow | title | next arrow --%>
      <div class="flex items-center justify-between mb-4">
        <button
          :if={@on_prev}
          phx-click={@on_prev}
          class="flex h-8 w-8 items-center justify-center rounded-full hover:bg-muted/50 text-foreground"
          aria-label="Previous week"
        >
          &lt;
        </button>
        <span :if={!@on_prev} class="w-8" />

        <span class="text-sm font-semibold text-foreground">{@title}</span>

        <button
          :if={@on_next}
          phx-click={@on_next}
          class="flex h-8 w-8 items-center justify-center rounded-full hover:bg-muted/50 text-foreground"
          aria-label="Next week"
        >
          &gt;
        </button>
        <span :if={!@on_next} class="w-8" />
      </div>

      <%!-- Day strip: 7 columns of (weekday abbr + day number) --%>
      <div class="flex justify-between gap-1">
        <div
          :for={date <- @dates}
          class={cn([
            "flex flex-col items-center cursor-pointer select-none",
            day_class(date, @selected_date)
          ])}
          phx-click={@on_select}
          phx-value-date={if @on_select, do: Date.to_iso8601(date)}
        >
          <span class="text-xs font-medium">{day_abbr(date)}</span>
          <span class="text-sm font-bold mt-0.5">{date.day}</span>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp week_dates(start) do
    Enum.map(0..6, fn offset -> Date.add(start, offset) end)
  end

  defp day_abbr(date), do: Calendar.strftime(date, "%a")

  defp day_class(date, selected_date) when date == selected_date do
    "bg-primary text-primary-foreground rounded-xl px-3 py-2"
  end

  defp day_class(_date, _selected_date) do
    "text-foreground hover:bg-muted/50 rounded-xl px-3 py-2"
  end
end
