defmodule PhiaUi.Components.DailyAgenda do
  @moduledoc """
  DailyAgenda — daily schedule view with a large day header, compact week strip,
  and an event list with dotted separators.

  The component displays:
  - A large day-name header with month/day/year on the right
  - An optional indicator dot (destructive colour) when the day has events
  - A horizontal week strip showing 7 days centred on the selected date
    (3 days before + selected + 3 days after), with click-to-select support
  - A vertical event list where entries are separated by dashed borders

  CSS-only for layout; zero JS required. The week strip supports LiveView
  event routing via `on_date_select`.

  ## Examples

      <%!-- Minimal — just the header and week strip --%>
      <.daily_agenda date={@selected_date} />

      <%!-- With events --%>
      <.daily_agenda date={@selected_date} has_events on_date_select="pick_date">
        <:event icon="✳">Daria's 20th Birthday</:event>
        <:event icon="☀️" time="09:00">Wake up</:event>
        <:event time="10:00">Design Crit</:event>
        <:event time="13:00">Haircut with Vincent</:event>
      </.daily_agenda>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :date, :any, required: true, doc: "Date.t() — the selected/current date"

  attr :has_events, :boolean,
    default: false,
    doc: "When true, renders a destructive indicator dot next to the day name"

  attr :on_date_select, :string,
    default: nil,
    doc: "phx-click event name fired when a week strip day is clicked"

  attr :class, :string, default: nil, doc: "Additional CSS classes merged via cn/1"

  attr :rest, :global, doc: "HTML attributes forwarded to the root div"

  slot :event, doc: "An event entry in the agenda list" do
    attr :icon, :string, doc: "Emoji or text icon (optional)"
    attr :time, :string, doc: "Time label such as \"09:00\" (optional)"
  end

  @doc """
  Renders a daily agenda card.

  ## Examples

      <.daily_agenda date={~D[2024-12-09]} has_events on_date_select="pick_date">
        <:event icon="☀️" time="09:00">Wake up</:event>
        <:event time="10:00">Design Crit</:event>
      </.daily_agenda>
  """
  def daily_agenda(assigns) do
    assigns = assign(assigns, :week_dates, week_dates(assigns.date))

    ~H"""
    <div class={cn(["p-4 rounded-xl bg-card text-card-foreground", @class])} {@rest}>
      <%!-- ── Header ─────────────────────────────────────────────────────────── --%>
      <div class="flex items-start justify-between mb-6">
        <div class="flex items-center gap-1">
          <span class="text-4xl font-black text-foreground">{day_name(@date)}</span>
          <span
            :if={@has_events}
            class="w-2.5 h-2.5 rounded-full bg-destructive mt-1 flex-shrink-0"
          />
        </div>
        <div class="text-right">
          <div class="text-sm text-muted-foreground">{Calendar.strftime(@date, "%B %-d")}</div>
          <div class="text-sm text-muted-foreground">{@date.year}</div>
        </div>
      </div>

      <%!-- ── Week strip ──────────────────────────────────────────────────────── --%>
      <div class="flex justify-between mb-6">
        <div
          :for={d <- @week_dates}
          class={cn([
            "flex flex-col items-center gap-0.5 px-2 py-1.5 rounded-xl cursor-pointer",
            d == @date && "border border-border bg-background shadow-sm",
            d != @date && "hover:bg-muted/50"
          ])}
          phx-click={if @on_date_select, do: @on_date_select}
          phx-value-date={if @on_date_select, do: Date.to_iso8601(d)}
        >
          <span class={cn(["text-base font-semibold", d == @date && "text-primary", d != @date && "text-muted-foreground"])}>
            {d.day}
          </span>
          <span class="text-[10px] font-medium text-muted-foreground">{day_abbr(d)}</span>
        </div>
      </div>

      <%!-- ── Event list ──────────────────────────────────────────────────────── --%>
      <div class="flex flex-col">
        <div :for={{event, idx} <- Enum.with_index(@event)} class="group">
          <%!-- Dotted separator before every event except the first --%>
          <div :if={idx > 0} class="border-t border-dashed border-border my-2" />
          <div class="flex items-center gap-3 py-1">
            <%!-- Icon or fallback square --%>
            <span :if={Map.get(event, :icon)} class="text-base flex-shrink-0">
              {Map.get(event, :icon)}
            </span>
            <div
              :if={!Map.get(event, :icon)}
              class="w-5 h-5 rounded-sm border border-border flex-shrink-0"
            />
            <%!-- Event title --%>
            <span class="flex-1 text-sm font-medium text-foreground">{render_slot(event)}</span>
            <%!-- Time label --%>
            <span :if={Map.get(event, :time)} class="text-sm text-muted-foreground ml-auto">
              {Map.get(event, :time)}
            </span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Returns the 7 dates centred on `date` (3 before, selected, 3 after).
  defp week_dates(date) do
    Enum.map(-3..3, fn offset -> Date.add(date, offset) end)
  end

  # Short day name for the large header, e.g. "Mon", "Fri".
  defp day_name(date), do: Calendar.strftime(date, "%a")

  # Uppercased 3-letter abbreviation for the week strip, e.g. "MON", "FRI".
  defp day_abbr(date), do: date |> Calendar.strftime("%a") |> String.upcase()
end
