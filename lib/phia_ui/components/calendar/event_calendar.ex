defmodule PhiaUi.Components.EventCalendar do
  @moduledoc """
  Full-month event calendar with colored event badges per day.

  Renders a 7-column month grid — like Google Calendar's month view — where
  each day cell can contain multiple color-coded event badges. Navigation
  between months is handled server-side via `phx-click` — no JavaScript needed.

  ## Anatomy

  | Element           | Purpose                                              |
  |-------------------|------------------------------------------------------|
  | Header            | Month + year label with prev/next navigation buttons |
  | Column headers    | `Sun Mon Tue Wed Thu Fri Sat`                        |
  | Day cells         | Padded grid of 35–42 cells; empty cells for padding  |
  | Event badge       | Colored dot + truncated label per event              |

  ## Events format

  Pass a plain list of maps with `:date`, `:label`, and optional `:color`:

      events = [
        %{date: ~D[2026-03-15], label: "Team standup", color: "blue"},
        %{date: ~D[2026-03-20], label: "Deploy v2", color: "green"},
        %{date: ~D[2026-03-25], label: "Deadline", color: "red"}
      ]

  Supported colors: `"blue"`, `"green"`, `"red"`, `"yellow"`, `"purple"`,
  `"orange"`. Any other value falls back to `bg-primary`.

  ## Navigation

  Set `on_navigate` to a LiveView event name. Both prev and next buttons fire
  that event with `phx-value-month` and `phx-value-year` so your LiveView
  socket can update the assigns:

      def handle_event("navigate_month", %{"month" => m, "year" => y}, socket) do
        {:noreply, assign(socket, month: String.to_integer(m), year: String.to_integer(y))}
      end

  ## Examples

      <%!-- Basic (shows current month) --%>
      <.event_calendar on_navigate="nav" events={@events} />

      <%!-- Specific month --%>
      <.event_calendar year={@year} month={@month} events={@events} on_navigate="nav" />

      <%!-- Clickable days and events --%>
      <.event_calendar
        year={@year}
        month={@month}
        events={@events}
        on_navigate="nav"
        on_day_click="pick_day"
        on_event_click="open_event"
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  @month_names ~w(January February March April May June July August September October November December)

  attr(:year, :integer, default: nil, doc: "Calendar year. Defaults to the current year.")

  attr(:month, :integer,
    default: nil,
    doc: "Calendar month (1–12). Defaults to the current month."
  )

  attr(:events, :list,
    default: [],
    doc:
      "List of event maps. Each map must have `:date` (Date.t()), `:label` (string). Optional `:color` (\"blue\"|\"green\"|\"red\"|\"yellow\"|\"purple\"|\"orange\")."
  )

  attr(:on_navigate, :string,
    default: nil,
    doc:
      "LiveView event name fired by prev/next buttons. Receives `phx-value-month` and `phx-value-year`."
  )

  attr(:on_day_click, :string,
    default: nil,
    doc:
      "LiveView event name fired when a day cell is clicked. Receives `phx-value-date` (ISO 8601)."
  )

  attr(:on_event_click, :string,
    default: nil,
    doc:
      "LiveView event name fired when an event badge is clicked. Receives `phx-value-date` and `phx-value-label`."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root element.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>` element.")

  @doc """
  Renders a full-month event calendar.

  ## Example

      <.event_calendar
        year={2026}
        month={3}
        events={[%{date: ~D[2026-03-15], label: "Sprint review", color: "blue"}]}
        on_navigate="nav"
      />
  """
  def event_calendar(assigns) do
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

    ~H"""
    <div class={cn(["w-full", @class])} {@rest}>
      <%!-- Navigation header --%>
      <div class="mb-4 flex items-center justify-between">
        <h2 class="text-lg font-semibold">{@month_label} {@year}</h2>
        <div class="flex gap-1">
          <button
            type="button"
            phx-click={@on_navigate}
            phx-value-month={@prev.month}
            phx-value-year={@prev.year}
            phx-value-direction="prev"
            aria-label="Previous month"
            class="inline-flex h-8 w-8 items-center justify-center rounded-md hover:bg-muted"
          >
            ‹
          </button>
          <button
            type="button"
            phx-click={@on_navigate}
            phx-value-month={@next.month}
            phx-value-year={@next.year}
            phx-value-direction="next"
            aria-label="Next month"
            class="inline-flex h-8 w-8 items-center justify-center rounded-md hover:bg-muted"
          >
            ›
          </button>
        </div>
      </div>
      <%!-- Calendar grid --%>
      <div role="grid" class="w-full overflow-hidden rounded-lg border border-border">
        <%!-- Day headers row --%>
        <div role="row" class="grid grid-cols-7 border-b border-border bg-muted/50">
          <div
            :for={name <- ~w(Sun Mon Tue Wed Thu Fri Sat)}
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
            aria-current={day && day.date == @today && "date"}
            class={cn([
              "min-h-[80px] border-b border-r border-border p-1.5",
              day == nil && "bg-muted/20",
              day && day.date == @today && "bg-primary/5",
              @on_day_click && day && "cursor-pointer hover:bg-muted/50"
            ])}
            phx-click={day && @on_day_click}
            phx-value-date={day && Date.to_iso8601(day.date)}
          >
            <%= if day do %>
              <%!-- Day number — circle-highlighted when it is today --%>
              <span class={cn([
                "inline-flex h-6 w-6 items-center justify-center rounded-full text-sm",
                if(day.date == @today,
                  do: "bg-primary font-semibold text-primary-foreground",
                  else: "text-foreground"
                )
              ])}>
                {day.day}
              </span>
              <%!-- Event badges --%>
              <div class="mt-0.5 space-y-0.5">
                <div
                  :for={event <- events_for_day(@events, day.date)}
                  class={cn([
                    "flex items-center gap-1 rounded px-1 py-0.5 text-xs",
                    @on_event_click && "cursor-pointer hover:opacity-80"
                  ])}
                  phx-click={@on_event_click}
                  phx-value-date={Date.to_iso8601(day.date)}
                  phx-value-label={event.label}
                >
                  <span class={cn(["h-1.5 w-1.5 shrink-0 rounded-full", dot_color(Map.get(event, :color))])} />
                  <span class="truncate">{event.label}</span>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers — date math
  # ---------------------------------------------------------------------------

  # Builds a flat list of day structs (or nil for padding cells).
  # Grid is always padded to a complete number of weeks (multiples of 7).
  # Starts on Sunday: ISO day_of_week returns 1(Mon)–7(Sun), rem/7 maps Sun→0.
  defp build_days(year, month) do
    days_count = Date.days_in_month(Date.new!(year, month, 1))
    offset = rem(Date.day_of_week(Date.new!(year, month, 1)), 7)

    empty_before = List.duplicate(nil, offset)
    day_cells = Enum.map(1..days_count, &%{day: &1, date: Date.new!(year, month, &1)})

    all = empty_before ++ day_cells

    remainder = rem(length(all), 7)
    empty_after = if remainder == 0, do: [], else: List.duplicate(nil, 7 - remainder)

    all ++ empty_after
  end

  defp prev_month(year, 1), do: %{year: year - 1, month: 12}
  defp prev_month(year, month), do: %{year: year, month: month - 1}

  defp next_month(year, 12), do: %{year: year + 1, month: 1}
  defp next_month(year, month), do: %{year: year, month: month + 1}

  defp events_for_day(events, date) do
    Enum.filter(events, &(Map.get(&1, :date) == date))
  end

  defp dot_color("blue"), do: "bg-blue-500"
  defp dot_color("green"), do: "bg-green-500"
  defp dot_color("red"), do: "bg-red-500"
  defp dot_color("yellow"), do: "bg-yellow-500"
  defp dot_color("purple"), do: "bg-purple-500"
  defp dot_color("orange"), do: "bg-orange-500"
  defp dot_color(_), do: "bg-primary"
end
