defmodule PhiaUi.Components.BigCalendar do
  @moduledoc """
  Full-page monthly calendar with colored event pills and a view switcher.

  Renders a Google Calendar-style month view:
  - MON-first 7-column grid
  - Days from adjacent months shown (muted)
  - Today's cell highlighted with a primary-color ring
  - Events as full-width colored pills: `"HH:MM (label)"`
  - View switcher: Month / Week / Day / List (Week/Day/List stub — Month implemented)

  ## Event format

      events = [
        %{date: ~D[2024-09-08], time: "9:00", label: "2 hours", color: "green"},
        %{date: ~D[2024-09-11], time: "13:00", label: "info here", color: "orange"},
        %{date: ~D[2024-09-11], time: "13:00", label: "info here", color: "orange"},
      ]

  ## Example

      <.big_calendar
        year={@year}
        month={@month}
        view={@view}
        events={@events}
        on_navigate="cal-nav"
        on_view_change="cal-view"
        on_day_click="cal-day"
        on_event_click="cal-event"
      />

  ## LiveView event handlers

  - `on_navigate` receives `%{"direction" => "prev"|"next", "month" => m, "year" => y}`
  - `on_view_change` receives `%{"view" => "month"|"week"|"day"|"list"}`
  - `on_day_click` receives `%{"date" => "YYYY-MM-DD"}`
  - `on_event_click` receives `%{"date" => "YYYY-MM-DD", "time" => "HH:MM", "label" => "..."}`
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  @month_names ~w(January February March April May June July August September October November December)
  @view_labels ~w(Month Week Day List)

  attr(:year, :integer, default: nil, doc: "Calendar year. Defaults to the current year.")

  attr(:month, :integer,
    default: nil,
    doc: "Calendar month (1–12). Defaults to the current month."
  )

  attr(:view, :string,
    default: "month",
    values: ~w(month week day list),
    doc: "Active view. One of: month | week | day | list."
  )

  attr(:events, :list,
    default: [],
    doc:
      "List of event maps. Each map must have `:date` (Date.t()), `:time` (string). Optional `:label` (string) and `:color` (\"green\"|\"orange\"|\"blue\"|\"red\"|\"purple\"|\"gray\")."
  )

  attr(:on_navigate, :string,
    default: nil,
    doc:
      "LiveView event name fired by prev/next buttons. Receives direction, month and year values."
  )

  attr(:on_view_change, :string,
    default: nil,
    doc: "LiveView event name fired when a view button is clicked. Receives the view value."
  )

  attr(:on_day_click, :string,
    default: nil,
    doc:
      "LiveView event name fired when a day cell is clicked. Receives `phx-value-date` (ISO 8601)."
  )

  attr(:on_event_click, :string,
    default: nil,
    doc:
      "LiveView event name fired when an event pill is clicked. Receives date, time and label values."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root element.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>` element.")

  @doc """
  Renders a full-page monthly calendar with colored event pills.

  ## Example

      <.big_calendar
        year={2024}
        month={9}
        events={[%{date: ~D[2024-09-08], time: "9:00", label: "2 hours", color: "green"}]}
        on_navigate="cal-nav"
        on_view_change="cal-view"
        on_day_click="cal-day"
        on_event_click="cal-event"
      />
  """
  def big_calendar(assigns) do
    today = Date.utc_today()
    year = assigns.year || today.year
    month = assigns.month || today.month

    assigns =
      assigns
      |> assign(:year, year)
      |> assign(:month, month)
      |> assign(:today, today)
      |> assign(:days, build_days(year, month))
      |> assign(:month_label, Enum.at(@month_names, month - 1))
      |> assign(:prev, prev_month(year, month))
      |> assign(:next, next_month(year, month))
      |> assign(:view_labels, @view_labels)

    ~H"""
    <div class={cn(["w-full select-none", @class])} {@rest}>
      <%!-- Header: month title + view switcher --%>
      <div class="mb-4 flex items-center justify-between">
        <div class="flex items-center gap-2">
          <button
            :if={@on_navigate}
            type="button"
            phx-click={@on_navigate}
            phx-value-direction="prev"
            phx-value-month={@prev.month}
            phx-value-year={@prev.year}
            aria-label="Previous month"
            class="inline-flex h-8 w-8 items-center justify-center rounded-md text-lg hover:bg-muted"
          >
            ‹
          </button>
          <h2 class="text-xl font-semibold">{@month_label} {@year}</h2>
          <button
            :if={@on_navigate}
            type="button"
            phx-click={@on_navigate}
            phx-value-direction="next"
            phx-value-month={@next.month}
            phx-value-year={@next.year}
            aria-label="Next month"
            class="inline-flex h-8 w-8 items-center justify-center rounded-md text-lg hover:bg-muted"
          >
            ›
          </button>
        </div>

        <%!-- View switcher --%>
        <div class="flex overflow-hidden rounded-lg border border-border bg-muted/30">
          <button
            :for={label <- @view_labels}
            type="button"
            phx-click={@on_view_change}
            phx-value-view={String.downcase(label)}
            class={cn([
              "px-3 py-1.5 text-sm font-medium transition-colors hover:bg-accent",
              String.downcase(label) == @view && "bg-background shadow-sm"
            ])}
          >
            {label}
          </button>
        </div>
      </div>

      <%!-- Month view --%>
      <div
        :if={@view == "month"}
        role="grid"
        class="w-full overflow-hidden rounded-lg border border-border"
      >
        <%!-- MON-first column headers --%>
        <div role="row" class="grid grid-cols-7 border-b border-border bg-muted/30">
          <div
            :for={name <- ~w(MON TUE WED THU FRI SAT SUN)}
            role="columnheader"
            class="py-2 text-center text-xs font-medium uppercase tracking-wide text-muted-foreground"
          >
            {name}
          </div>
        </div>

        <%!-- Day cells --%>
        <div class="grid grid-cols-7">
          <div
            :for={day <- @days}
            role="gridcell"
            aria-current={if day.date == @today, do: "date", else: "false"}
            class={cn([
              "min-h-[110px] border-b border-r border-border p-2",
              !day.current_month && "bg-muted/20",
              day.date == @today && "bg-primary/5 ring-2 ring-inset ring-primary",
              @on_day_click && day.current_month && "cursor-pointer hover:bg-muted/30"
            ])}
            phx-click={if @on_day_click && day.current_month, do: @on_day_click}
            phx-value-date={Date.to_iso8601(day.date)}
          >
            <%!-- Day number --%>
            <span class={cn([
              "mb-1 block text-sm",
              day.current_month && "font-medium",
              !day.current_month && "text-muted-foreground"
            ])}>
              {day.date.day}
            </span>

            <%!-- Event pills --%>
            <div class="space-y-0.5">
              <button
                :for={event <- events_for_day(@events, day.date)}
                type="button"
                phx-click={@on_event_click}
                phx-value-date={Date.to_iso8601(day.date)}
                phx-value-time={Map.get(event, :time, "")}
                phx-value-label={Map.get(event, :label, "")}
                class={cn([
                  "w-full truncate rounded px-1.5 py-0.5 text-left text-xs font-medium",
                  if(day.current_month,
                    do: pill_class(Map.get(event, :color)),
                    else: "bg-muted text-muted-foreground"
                  ),
                  @on_event_click && "cursor-pointer hover:opacity-80"
                ])}
              >
                {pill_label(event)}
              </button>
            </div>
          </div>
        </div>
      </div>

      <%!-- Stub for week / day / list views --%>
      <div
        :if={@view != "month"}
        class="flex min-h-[400px] items-center justify-center rounded-lg border border-border text-muted-foreground"
      >
        {String.capitalize(@view)} view
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Date math
  # ---------------------------------------------------------------------------

  # Builds a flat list of day maps covering full weeks (multiples of 7).
  # MON-first: Monday=1 → offset=0, Sunday=7 → offset=6.
  # Adjacent-month days are included (not nil) with current_month: false.
  defp build_days(year, month) do
    first = Date.new!(year, month, 1)
    last = Date.end_of_month(first)

    # Mon-first offset: Monday(1) → 0, ..., Sunday(7) → 6
    offset = Date.day_of_week(first) - 1

    prev_days =
      if offset > 0 do
        prev_last = Date.add(first, -1)
        prev_first = Date.add(prev_last, -(offset - 1))

        Date.range(prev_first, prev_last)
        |> Enum.map(&%{date: &1, current_month: false})
      else
        []
      end

    current_days =
      Date.range(first, last)
      |> Enum.map(&%{date: &1, current_month: true})

    all = prev_days ++ current_days
    remainder = rem(length(all), 7)

    next_days =
      if remainder > 0 do
        next_first = Date.add(last, 1)
        next_last = Date.add(next_first, 7 - remainder - 1)

        Date.range(next_first, next_last)
        |> Enum.map(&%{date: &1, current_month: false})
      else
        []
      end

    all ++ next_days
  end

  defp prev_month(year, 1), do: %{year: year - 1, month: 12}
  defp prev_month(year, month), do: %{year: year, month: month - 1}

  defp next_month(year, 12), do: %{year: year + 1, month: 1}
  defp next_month(year, month), do: %{year: year, month: month + 1}

  defp events_for_day(events, date) do
    Enum.filter(events, &(Map.get(&1, :date) == date))
  end

  defp pill_label(event) do
    time = Map.get(event, :time, "")
    label = Map.get(event, :label)
    if label && label != "", do: "#{time} (#{label})", else: time
  end

  defp pill_class("green"), do: "bg-green-500 text-white"
  defp pill_class("orange"), do: "bg-orange-500 text-white"
  defp pill_class("blue"), do: "bg-blue-500 text-white"
  defp pill_class("red"), do: "bg-red-500 text-white"
  defp pill_class("purple"), do: "bg-purple-500 text-white"
  defp pill_class("gray"), do: "bg-gray-300 text-gray-700"
  defp pill_class(_), do: "bg-primary text-primary-foreground"
end
