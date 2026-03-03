defmodule PhiaUi.Components.DateRangePicker do
  @moduledoc """
  Date range picker with dual-calendar server-side rendering.

  The calendar grid is built server-side using Elixir's `Date` module.
  State (current view month, selected from/to) lives in your LiveView.
  Day clicks and month navigation fire `phx-click` events to the LiveView.

  ## Example

      <.date_range_picker
        id="booking-range"
        view_month={@view_month}
        from={@date_from}
        to={@date_to}
        on_change="select-date"
        on_month_change="change-month"
        min_date={Date.utc_today()}
      />

  ## LiveView handlers

      def handle_event("select-date", %{"date" => date_str}, socket) do
        date = Date.from_iso8601!(date_str)
        socket = cond do
          is_nil(socket.assigns.date_from) ->
            assign(socket, date_from: date, date_to: nil)
          is_nil(socket.assigns.date_to) and Date.compare(date, socket.assigns.date_from) != :lt ->
            assign(socket, date_to: date)
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

  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  attr(:id, :string, required: true, doc: "Unique ID")
  attr(:view_month, :any, required: true, doc: "Date for the first displayed month")
  attr(:from, :any, default: nil, doc: "Selected range start (Date or nil)")
  attr(:to, :any, default: nil, doc: "Selected range end (Date or nil)")

  attr(:on_change, :string,
    default: "date-range-changed",
    doc: "phx-click event for day selection"
  )

  attr(:on_month_change, :string,
    default: "date-range-month",
    doc: "phx-click event for month nav"
  )

  attr(:min_date, :any, default: nil, doc: "Minimum selectable date (Date or nil)")
  attr(:max_date, :any, default: nil, doc: "Maximum selectable date (Date or nil)")
  attr(:locale, :string, default: "en", doc: "Locale for month/day labels")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)

  @doc "Renders a dual-calendar date range picker."
  def date_range_picker(assigns) do
    assigns =
      assigns
      |> assign(:month1, assigns.view_month)
      |> assign(:month2, shift_month(assigns.view_month, 1))

    ~H"""
    <div id={@id} class={cn(["inline-flex flex-col gap-2", @class])} {@rest}>
      <%!-- Trigger button --%>
      <button
        type="button"
        class="inline-flex h-10 items-center justify-start gap-2 rounded-md border border-border bg-background px-3 py-2 text-sm text-left hover:bg-accent hover:text-accent-foreground"
      >
        <.icon name="calendar" size={:sm} />
        <span>
          <%= format_range(@from, @to) %>
        </span>
      </button>

      <%!-- Calendar panel — always shown in this implementation; hide/show via LiveView state --%>
      <div class="rounded-md border border-border bg-background p-4 shadow-md">
        <%!-- Month navigation --%>
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

        <%!-- Dual calendar grid --%>
        <div class="flex gap-8">
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

  attr(:month, :any, required: true)
  attr(:from, :any, default: nil)
  attr(:to, :any, default: nil)
  attr(:min_date, :any, default: nil)
  attr(:max_date, :any, default: nil)
  attr(:on_change, :string, required: true)

  defp calendar_month(assigns) do
    assigns = assign(assigns, :weeks, calendar_weeks(assigns.month))

    ~H"""
    <div class="calendar-month">
      <div class="mb-2 text-center text-sm font-medium">
        <%= month_label(@month) %>
      </div>
      <table class="w-full border-collapse">
        <thead>
          <tr>
            <%= for day_name <- ~w[Su Mo Tu We Th Fr Sa] do %>
              <th class="h-8 w-8 text-center text-xs text-muted-foreground font-normal">
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
                  <% disabled = day_disabled?(day, @min_date, @max_date) %>
                  <% is_from = @from && Date.compare(day, @from) == :eq %>
                  <% is_to = @to && Date.compare(day, @to) == :eq %>
                  <% in_range = in_range?(day, @from, @to) %>
                  <td class={cn([
                    "relative h-8 w-8 p-0 text-center text-sm",
                    if(in_range && !is_from && !is_to, do: "bg-accent", else: nil)
                  ])}>
                    <button
                      type="button"
                      phx-click={if !disabled, do: @on_change}
                      phx-value-date={Date.to_iso8601(day)}
                      disabled={disabled}
                      class={cn([
                        "inline-flex h-8 w-8 items-center justify-center rounded-full text-sm transition-colors",
                        "focus:outline-none focus:ring-1 focus:ring-ring",
                        if(disabled, do: "opacity-50 pointer-events-none", else: "hover:bg-accent hover:text-accent-foreground"),
                        if(is_from || is_to, do: "bg-primary text-primary-foreground hover:bg-primary/90", else: nil),
                        if(is_from && @to, do: "rounded-r-none", else: nil),
                        if(is_to && @from, do: "rounded-l-none", else: nil)
                      ])}
                    >
                      <%= day.day %>
                    </button>
                  </td>
                <% else %>
                  <td class="h-8 w-8" />
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

  defp calendar_weeks(first_of_month) do
    last = Date.end_of_month(first_of_month)
    # day_of_week: 1=Mon..7=Sun → convert to 0=Sun..6=Sat offset
    dow = rem(Date.day_of_week(first_of_month), 7)
    leading = List.duplicate(nil, dow)
    days = Date.range(first_of_month, last) |> Enum.to_list()
    all = leading ++ days
    chunked = Enum.chunk_every(all, 7)

    Enum.map(chunked, fn week ->
      week ++ List.duplicate(nil, 7 - length(week))
    end)
  end

  defp in_range?(_day, nil, _to), do: false
  defp in_range?(_day, _from, nil), do: false

  defp in_range?(day, from, to) do
    Date.compare(day, from) != :lt and Date.compare(day, to) != :gt
  end

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

  defp format_range(nil, _to), do: "Select date range"
  defp format_range(from, nil), do: "#{format_date(from)} –"
  defp format_range(from, to), do: "#{format_date(from)} – #{format_date(to)}"

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
