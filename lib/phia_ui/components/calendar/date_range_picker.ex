defmodule PhiaUi.Components.DateRangePicker do
  @moduledoc """
  Date range picker with dual-calendar server-side rendering.

  Renders two side-by-side monthly calendar grids for selecting a start and
  end date. The calendar grid is built server-side using Elixir's `Date`
  module. All state (current view month, selected from/to) lives in the
  parent LiveView. Day clicks and month navigation fire `phx-click` events.

  ## When to use

  Use `date_range_picker/1` whenever users need to select a date interval:

  - Hotel booking (check-in / check-out)
  - Report date range (start period / end period)
  - Project timeline (kickoff / deadline)
  - Vacation request (from / to)
  - Analytics dashboard date filter

  For single-date selection, use `date_picker/1` instead.

  ## State management

  The LiveView manages a two-click selection protocol:

  1. First click sets `from`, clears `to`
  2. Second click (on a date ≥ `from`) sets `to`
  3. Any subsequent click resets: sets new `from`, clears `to`

  ## Complete example — booking range

      defmodule MyAppWeb.BookingLive do
        use Phoenix.LiveView

        def mount(_params, _session, socket) do
          {:ok, assign(socket,
            view_month: Date.beginning_of_month(Date.utc_today()),
            date_from: nil,
            date_to: nil
          )}
        end

        def handle_event("select-date", %{"date" => date_str}, socket) do
          date = Date.from_iso8601!(date_str)
          socket =
            cond do
              # No start date yet — set it
              is_nil(socket.assigns.date_from) ->
                assign(socket, date_from: date, date_to: nil)
              # Start set, no end, and the clicked date is >= start — set end
              is_nil(socket.assigns.date_to) and Date.compare(date, socket.assigns.date_from) != :lt ->
                assign(socket, date_to: date)
              # Otherwise reset: start a new range
              true ->
                assign(socket, date_from: date, date_to: nil)
            end
          {:noreply, socket}
        end

        def handle_event("change-month", %{"dir" => "next"}, socket) do
          {:noreply, assign(socket, view_month: Date.shift(socket.assigns.view_month, month: 1))}
        end

        def handle_event("change-month", %{"dir" => "prev"}, socket) do
          {:noreply, assign(socket, view_month: Date.shift(socket.assigns.view_month, month: -1))}
        end
      end

      <%!-- Template --%>
      <.date_range_picker
        id="booking-range"
        view_month={@view_month}
        from={@date_from}
        to={@date_to}
        on_change="select-date"
        on_month_change="change-month"
        min_date={Date.utc_today()}
      />

      <p :if={@date_from && @date_to}>
        Booking: {Calendar.strftime(@date_from, "%B %d")} –
                 {Calendar.strftime(@date_to, "%B %d, %Y")}
        ({Date.diff(@date_to, @date_from)} nights)
      </p>

  ## Range highlight

  When both `from` and `to` are set, days between the endpoints receive a
  `bg-accent` background. The endpoint buttons themselves receive
  `bg-primary text-primary-foreground` and rounded corners that connect
  visually to the range stripe (`rounded-r-none` on `from`, `rounded-l-none`
  on `to`).
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  attr(:id, :string, required: true, doc: "Unique DOM id for the root element")

  attr(:view_month, :any,
    required: true,
    doc: """
    `Date.t()` representing the first of the two displayed months.
    The second month is derived automatically as `view_month + 1`.
    Update this assign in response to `on_month_change` events.
    """
  )

  attr(:from, :any,
    default: nil,
    doc: "Selected range start date (`Date.t()`) or `nil` before the user's first click"
  )

  attr(:to, :any,
    default: nil,
    doc: "Selected range end date (`Date.t()`) or `nil` before the user's second click"
  )

  attr(:on_change, :string,
    default: "date-range-changed",
    doc: """
    `phx-click` event name fired when a day cell is clicked.
    The LiveView receives `%{"date" => "YYYY-MM-DD"}`.
    """
  )

  attr(:on_month_change, :string,
    default: "date-range-month",
    doc: """
    `phx-click` event name for month navigation buttons.
    The LiveView receives `%{"dir" => "next" | "prev"}`.
    """
  )

  attr(:min_date, :any,
    default: nil,
    doc: "Minimum selectable date (`Date.t()`). Days before this are rendered disabled."
  )

  attr(:max_date, :any,
    default: nil,
    doc: "Maximum selectable date (`Date.t()`). Days after this are rendered disabled."
  )

  attr(:locale, :string,
    default: "en",
    doc: "Locale for month/day labels (currently informational — labels are hardcoded in English)"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root wrapper")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root div")

  @doc """
  Renders a dual-calendar date range picker.

  Displays two side-by-side monthly grids. The left grid shows `view_month`;
  the right grid shows the month immediately following. Both grids share the
  same `from`/`to` selection state and highlight the range consistently.

  Month navigation applies to both calendars simultaneously — advancing or
  retreating one month at a time.
  """
  def date_range_picker(assigns) do
    # Compute the two displayed months up-front so the template is declarative.
    assigns =
      assigns
      |> assign(:month1, assigns.view_month)
      |> assign(:month2, shift_month(assigns.view_month, 1))

    ~H"""
    <div id={@id} class={cn(["inline-flex flex-col gap-2", @class])} {@rest}>
      <%!-- Trigger button — shows the selected range or a placeholder --%>
      <button
        type="button"
        class="inline-flex h-10 items-center justify-start gap-2 rounded-md border border-border bg-background px-3 py-2 text-sm text-left hover:bg-accent hover:text-accent-foreground"
      >
        <.icon name="calendar" size={:sm} />
        <span>
          <%= format_range(@from, @to) %>
        </span>
      </button>

      <%!-- Calendar panel — always visible in this implementation.
           To show/hide based on LiveView state, wrap in :if={@open} and add a toggle handler. --%>
      <div class="rounded-md border border-border bg-background p-4 shadow-md">
        <%!-- Month navigation — prev/next buttons with the two month titles between them --%>
        <div class="flex items-center justify-between mb-4">
          <button
            type="button"
            phx-click={@on_month_change}
            phx-value-dir="prev"
            class="inline-flex h-7 w-7 items-center justify-center rounded-md hover:bg-accent"
            aria-label="Previous month"
          >
            <.icon name="chevron-left" size={:sm} />
          </button>
          <div class="flex flex-1 justify-around px-2">
            <span class="text-sm font-medium"><%= month_label(@month1) %></span>
            <span class="text-sm font-medium"><%= month_label(@month2) %></span>
          </div>
          <button
            type="button"
            phx-click={@on_month_change}
            phx-value-dir="next"
            class="inline-flex h-7 w-7 items-center justify-center rounded-md hover:bg-accent"
            aria-label="Next month"
          >
            <.icon name="chevron-right" size={:sm} />
          </button>
        </div>

        <%!-- Dual calendar grid — two months side by side, stacked on mobile --%>
        <div class="flex flex-col gap-4 sm:flex-row sm:gap-8">
          <.calendar_month
            month={@month1}
            from={@from}
            to={@to}
            min_date={@min_date}
            max_date={@max_date}
            on_change={@on_change}
          />
          <.calendar_month
            month={@month2}
            from={@from}
            to={@to}
            min_date={@min_date}
            max_date={@max_date}
            on_change={@on_change}
          />
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private: calendar_month sub-component
  # ---------------------------------------------------------------------------

  # Private component — not part of the public API.
  # Renders a single month grid inside the dual-calendar panel.
  # Each month shares the same from/to state so range highlights span months.

  attr(:month, :any, required: true)
  attr(:from, :any, default: nil)
  attr(:to, :any, default: nil)
  attr(:min_date, :any, default: nil)
  attr(:max_date, :any, default: nil)
  attr(:on_change, :string, required: true)

  defp calendar_month(assigns) do
    # Build the week grid for this month at render time.
    assigns = assign(assigns, :weeks, calendar_weeks(assigns.month))

    ~H"""
    <div class="calendar-month">
      <table class="w-full border-collapse">
        <thead>
          <tr>
            <%= for day_name <- ~w[Su Mo Tu We Th Fr Sa] do %>
              <th class="h-9 w-9 text-center text-xs text-muted-foreground font-normal">
                <%= day_name %>
              </th>
            <% end %>
          </tr>
        </thead>
        <tbody>
          <%= for week <- @weeks do %>
            <tr>
              <%= for day <- week do %>
                <%= if day do %>
                  <%!-- Compute per-cell state inline (private component, no pre-computation) --%>
                  <% disabled = day_disabled?(day, @min_date, @max_date) %>
                  <% is_from = @from && Date.compare(day, @from) == :eq %>
                  <% is_to = @to && Date.compare(day, @to) == :eq %>
                  <% in_range = in_range?(day, @from, @to) %>
                  <%!-- Range interior cells get a full-width accent background --%>
                  <td class={cn([
                    "relative h-9 w-9 p-0 text-center text-sm",
                    if(in_range && !is_from && !is_to, do: "bg-accent", else: nil)
                  ])}>
                    <button
                      type="button"
                      phx-click={if !disabled, do: @on_change}
                      phx-value-date={Date.to_iso8601(day)}
                      disabled={disabled}
                      class={cn([
                        "inline-flex h-9 w-9 items-center justify-center rounded-full text-sm transition-colors",
                        "focus:outline-none focus:ring-1 focus:ring-ring",
                        if(disabled,
                          do: "opacity-50 pointer-events-none",
                          else: "hover:bg-accent hover:text-accent-foreground"
                        ),
                        # Endpoint buttons use primary colour
                        if(is_from || is_to,
                          do: "bg-primary text-primary-foreground hover:bg-primary/90",
                          else: nil
                        ),
                        # Connect the "from" endpoint visually to the range stripe
                        if(is_from && @to, do: "rounded-r-none", else: nil),
                        # Connect the "to" endpoint visually to the range stripe
                        if(is_to && @from, do: "rounded-l-none", else: nil)
                      ])}
                    >
                      <%= day.day %>
                    </button>
                  </td>
                <% else %>
                  <%!-- Nil day = leading/trailing padding cell from adjacent month --%>
                  <td class="h-9 w-9" />
                <% end %>
              <% end %>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Shift a date by N months using integer arithmetic on year*12+month.
  # This avoids Calendar boundary edge cases (e.g. month 13 = January next year).
  defp shift_month(date, months) do
    Date.new!(date.year, date.month, 1)
    |> Date.add(0)
    |> then(fn d ->
      total_months = d.year * 12 + d.month - 1 + months
      new_year = div(total_months, 12)
      new_month = rem(total_months, 12) + 1
      Date.new!(new_year, new_month, 1)
    end)
  end

  # Build a list of 6×7 = 42 cells (or fewer complete weeks) for a month.
  # Cells before the 1st of the month and after the last day are `nil`.
  defp calendar_weeks(first_of_month) do
    last = Date.end_of_month(first_of_month)
    # day_of_week returns 1=Mon..7=Sun; rem(..., 7) converts to 0=Sun..6=Sat
    dow = rem(Date.day_of_week(first_of_month), 7)
    leading = List.duplicate(nil, dow)
    days = Date.range(first_of_month, last) |> Enum.to_list()
    all = leading ++ days
    chunked = Enum.chunk_every(all, 7)

    # Pad the last partial week to 7 cells so the table columns stay aligned.
    Enum.map(chunked, fn week ->
      week ++ List.duplicate(nil, 7 - length(week))
    end)
  end

  # A day is in the range if it falls between from and to (inclusive on both ends).
  defp in_range?(_day, nil, _to), do: false
  defp in_range?(_day, _from, nil), do: false

  defp in_range?(day, from, to) do
    Date.compare(day, from) != :lt and Date.compare(day, to) != :gt
  end

  # Disabled when the day falls outside the [min_date, max_date] window.
  defp day_disabled?(_day, nil, nil), do: false
  defp day_disabled?(day, min, nil), do: Date.compare(day, min) == :lt
  defp day_disabled?(day, nil, max), do: Date.compare(day, max) == :gt

  defp day_disabled?(day, min, max) do
    Date.compare(day, min) == :lt or Date.compare(day, max) == :gt
  end

  defp month_label(date) do
    month_name =
      case date.month do
        1 -> "January"
        2 -> "February"
        3 -> "March"
        4 -> "April"
        5 -> "May"
        6 -> "June"
        7 -> "July"
        8 -> "August"
        9 -> "September"
        10 -> "October"
        11 -> "November"
        12 -> "December"
      end

    "#{month_name} #{date.year}"
  end

  # Trigger button display text — shows placeholder or the formatted range.
  defp format_range(nil, _to), do: "Select date range"
  defp format_range(from, nil), do: "#{format_date(from)} –"
  defp format_range(from, to), do: "#{format_date(from)} – #{format_date(to)}"

  # Short date format for the trigger label (e.g. "Mar 15, 2026").
  defp format_date(date) do
    month_abbr =
      case date.month do
        1 -> "Jan"
        2 -> "Feb"
        3 -> "Mar"
        4 -> "Apr"
        5 -> "May"
        6 -> "Jun"
        7 -> "Jul"
        8 -> "Aug"
        9 -> "Sep"
        10 -> "Oct"
        11 -> "Nov"
        12 -> "Dec"
      end

    "#{month_abbr} #{date.day}, #{date.year}"
  end
end
