defmodule PhiaUi.Components.GanttChart do
  @moduledoc """
  Week-view calendar (Google Calendar style) with hourly time slots.

  Renders a 7-column grid (Mon–Sun) with time rows and absolutely-positioned
  event blocks. Events are placed by start/end time using CSS `top`/`height`
  percentages computed server-side.

  Zero JavaScript — pure HTML + inline style positioning.

  ## Examples

      <.gantt_chart week_start={@week_start}>
        <:event
          day={~D[2026-03-09]}
          start_time="10:00"
          end_time="11:30"
          label="Team Meeting"
          color="bg-blue-500"
        />
        <:event
          day={~D[2026-03-11]}
          start_time="14:00"
          end_time="15:00"
          label="Design Review"
          color="bg-purple-500"
        />
      </.gantt_chart>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  @day_names ~w(Mon Tue Wed Thu Fri Sat Sun)

  # ---------------------------------------------------------------------------
  # Attributes
  # ---------------------------------------------------------------------------

  attr(:week_start, :any,
    required: true,
    doc: "The `Date` for Monday of the displayed week."
  )

  attr(:start_hour, :integer,
    default: 8,
    doc: "First visible hour (0–23). Default: `8` (8am)."
  )

  attr(:end_hour, :integer,
    default: 20,
    doc: "Last visible hour, exclusive (0–23). Default: `20` (8pm)."
  )

  attr(:id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided).")
  attr(:title, :string, default: nil, doc: "Chart title rendered above the visualization.")
  attr(:description, :string, default: nil, doc: "Chart description for context (rendered below title).")
  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root element.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>` element.")

  slot(:event,
    doc: "An event block to render on the calendar."
  ) do
    attr(:day, :any, required: true, doc: "`Date` of the event.")
    attr(:start_time, :string, required: true, doc: "Start time as `\"HH:MM\"`.")
    attr(:end_time, :string, required: true, doc: "End time as `\"HH:MM\"`.")
    attr(:label, :string, doc: "Event title text.")

    attr(:color, :string,
      doc: "Tailwind bg class (e.g. `\"bg-blue-500\"`). Default: `bg-blue-500`."
    )
  end

  # ---------------------------------------------------------------------------
  # Component
  # ---------------------------------------------------------------------------

  def gantt_chart(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"

    total_hours = assigns.end_hour - assigns.start_hour
    total_minutes = total_hours * 60

    assigns =
      assigns
      |> assign(:days, build_days(assigns.week_start))
      |> assign(:hours, assigns.start_hour..(assigns.end_hour - 1))
      |> assign(:total_hours, total_hours)
      |> assign(:total_minutes, total_minutes)
      |> assign(:chart_id, chart_id)
      |> assign(:grid_height_px, total_hours * 64)

    ~H"""
    <div class={cn(["w-full overflow-x-auto", @class])} {@rest}>
      <div :if={@title} class="mb-2">
        <h3 class="text-sm font-medium text-foreground">{@title}</h3>
        <p :if={@description} class="text-xs text-muted-foreground">{@description}</p>
      </div>
      <div class="flex min-w-[640px]">
        <%!-- Time labels column --%>
        <div class="w-14 shrink-0 pt-10 select-none">
          <div :for={hour <- @hours} class="h-16 flex items-start justify-end pr-2">
            <span class="text-xs text-muted-foreground leading-none">{format_hour(hour)}</span>
          </div>
        </div>

        <%!-- Day columns --%>
        <div class="flex flex-1 gap-px bg-border rounded-lg overflow-hidden">
          <div :for={day <- @days} class="flex-1 flex flex-col bg-card">
            <%!-- Day header --%>
            <div class="h-10 flex flex-col items-center justify-center border-b border-border">
              <span class="text-xs font-medium text-muted-foreground">{day.name}</span>
              <span class={cn(["text-xs font-semibold", day.is_today && "text-primary"])}>
                {day.date.day}
              </span>
            </div>

            <%!-- Time grid --%>
            <div
              class="relative"
              style={"height: #{@grid_height_px}px;"}
            >
              <%!-- Hour boundary lines --%>
              <div :for={_hour <- @hours} class="h-16 border-b border-border border-dashed" />

              <%!-- Current time indicator (today only) --%>
              <div
                :if={day.is_today}
                class="absolute left-0 right-0 border-t-2 border-primary z-10 pointer-events-none"
                style={"top: #{current_time_pct(@start_hour, @total_minutes)}%;"}
              />

              <%!-- Events for this day --%>
              <div
                :for={event <- events_for_day(@event, day.date)}
                class={
                  cn([
                    "absolute left-1 right-1 rounded-md px-1.5 py-1 overflow-hidden z-20",
                    "text-white text-xs cursor-default",
                    Map.get(event, :color, "bg-blue-500")
                  ])
                }
                style={event_style(event, @start_hour, @total_minutes)}
              >
                <span class="font-medium truncate block leading-tight">
                  {Map.get(event, :label, "")}
                </span>
                <span class="opacity-80 leading-tight">
                  {Map.get(event, :start_time, "")} – {Map.get(event, :end_time, "")}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp build_days(week_start) do
    today = Date.utc_today()

    Enum.map(0..6, fn offset ->
      date = Date.add(week_start, offset)
      %{date: date, name: Enum.at(@day_names, offset), is_today: date == today}
    end)
  end

  defp events_for_day(events, date) do
    Enum.filter(events, fn e -> Map.get(e, :day) == date end)
  end

  defp event_style(event, start_hour, total_minutes) do
    start_time = Map.get(event, :start_time, "#{start_hour}:00")
    end_time = Map.get(event, :end_time, "#{start_hour + 1}:00")
    top = time_offset_pct(start_time, start_hour, total_minutes)
    height = duration_pct(start_time, end_time, total_minutes)
    "top: #{top}%; height: #{height}%;"
  end

  defp time_offset_pct(time_str, start_hour, total_minutes) do
    minutes = time_to_minutes(time_str) - start_hour * 60
    Float.round(max(minutes, 0) / total_minutes * 100.0, 2)
  end

  defp duration_pct(start_str, end_str, total_minutes) do
    duration = time_to_minutes(end_str) - time_to_minutes(start_str)
    Float.round(max(duration, 0) / total_minutes * 100.0, 2)
  end

  defp time_to_minutes(time_str) do
    [h, m] = String.split(time_str, ":")
    String.to_integer(h) * 60 + String.to_integer(m)
  end

  defp current_time_pct(start_hour, total_minutes) do
    now = Time.utc_now()
    minutes = now.hour * 60 + now.minute - start_hour * 60
    (minutes / total_minutes * 100.0) |> max(0.0) |> min(100.0) |> Float.round(2)
  end

  defp format_hour(hour) when hour < 12, do: "#{hour}am"
  defp format_hour(12), do: "12pm"
  defp format_hour(hour), do: "#{hour - 12}pm"
end
