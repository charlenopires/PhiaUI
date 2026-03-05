defmodule PhiaUi.Components.TimeSliderPicker do
  @moduledoc """
  TimeSliderPicker — horizontal time ruler/scrubber display.

  Renders the selected time as large bold text above a horizontal tick-mark
  ruler. The ruler contains evenly spaced tick marks; the tick at the selected
  time is rendered taller and in the primary colour to act as an indicator.
  Optional hour labels appear beneath full-hour tick marks.

  This component is **display-only** — zero JavaScript. The parent LiveView is
  responsible for handling time changes. When `on_select` is provided, each tick
  receives a `phx-click` event and a `phx-value-time="HH:MM"` attribute so the
  LiveView can pattern-match on the chosen slot.

  ## Examples

      <%!-- Basic 24-hour ruler with selected time 12:30 --%>
      <.time_slider_picker hour={12} minute={30} />

      <%!-- Business-hours ruler (08:00–18:00), hourly steps --%>
      <.time_slider_picker
        hour={@hour}
        minute={@minute}
        start_hour={8}
        end_hour={18}
        step_minutes={60}
        on_select="pick_time"
      />

      <%!-- Custom container class --%>
      <.time_slider_picker hour={9} minute={30} class="w-full max-w-lg" />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :hour, :integer, required: true, doc: "Selected hour (0–23)"
  attr :minute, :integer, required: true, doc: "Selected minute (0–59)"

  attr :start_hour, :integer,
    default: 0,
    doc: "Ruler start hour (inclusive). Defaults to 0."

  attr :end_hour, :integer,
    default: 24,
    doc: "Ruler end hour (exclusive). Defaults to 24."

  attr :step_minutes, :integer,
    default: 30,
    doc: "Interval between tick marks in minutes. Defaults to 30."

  attr :on_select, :string,
    default: nil,
    doc: """
    LiveView event name. When set, each tick receives `phx-click={on_select}`
    and `phx-value-time=\"HH:MM\"`. The parent handles the event to update
    the selected time.
    """

  attr :class, :string, default: nil, doc: "Additional CSS classes merged via cn/1"

  attr :rest, :global, doc: "HTML attributes forwarded to the container div"

  @doc """
  Renders a horizontal time ruler with a bold time display and tick marks.

  ## Examples

      <.time_slider_picker hour={12} minute={30} />

      <.time_slider_picker
        hour={@hour}
        minute={@minute}
        start_hour={8}
        end_hour={18}
        step_minutes={60}
        on_select="pick_time"
      />
  """
  def time_slider_picker(assigns) do
    assigns = assign(assigns, :ticks, build_ticks(assigns.start_hour, assigns.end_hour, assigns.step_minutes))

    ~H"""
    <div class={cn(["flex flex-col gap-3", @class])} {@rest}>
      <%!-- Time display --%>
      <div class="text-center">
        <span class="text-3xl font-bold tabular-nums text-foreground">
          {display_time(@hour, @minute)}
        </span>
      </div>

      <%!-- Ruler --%>
      <div class="relative flex items-end gap-0 overflow-x-auto pb-2">
        <div
          :for={tick <- @ticks}
          class={cn([
            "flex flex-col items-center flex-shrink-0",
            @on_select && "cursor-pointer hover:opacity-80"
          ])}
          style="width: 20px;"
          phx-click={if @on_select, do: @on_select}
          phx-value-time={if @on_select, do: tick.value}
        >
          <%!-- Tick mark: tall + primary for selected, short + border otherwise --%>
          <div class={cn([
            "w-0.5 rounded-full",
            is_selected(tick, @hour, @minute) && "h-6 bg-primary",
            !is_selected(tick, @hour, @minute) && "h-3 bg-border"
          ])} />
          <%!-- Hour label only on full-hour ticks --%>
          <span :if={tick.minute == 0} class="text-[9px] text-muted-foreground mt-1">
            {tick.hour}
          </span>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  @doc false
  defp build_ticks(start_hour, end_hour, step_minutes) do
    total_slots = div((end_hour - start_hour) * 60, step_minutes)

    Enum.map(0..total_slots, fn i ->
      total_minutes = start_hour * 60 + i * step_minutes
      h = div(total_minutes, 60)
      m = rem(total_minutes, 60)
      %{hour: h, minute: m, value: format_time(h, m)}
    end)
  end

  defp format_time(h, m) when h < 10 and m < 10, do: "0#{h}:0#{m}"
  defp format_time(h, m) when h < 10, do: "0#{h}:#{m}"
  defp format_time(h, m) when m < 10, do: "#{h}:0#{m}"
  defp format_time(h, m), do: "#{h}:#{m}"

  defp is_selected(tick, hour, minute), do: tick.hour == hour and tick.minute == minute

  defp display_time(h, m) do
    suffix = if h < 12, do: "AM", else: "PM"

    h12 =
      cond do
        h == 0 -> 12
        h > 12 -> h - 12
        true -> h
      end

    m_str = if m < 10, do: "0#{m}", else: "#{m}"
    "#{h12}:#{m_str} #{suffix}"
  end
end
