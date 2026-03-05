defmodule PhiaUi.Components.CountdownTimer do
  @moduledoc """
  Display-only countdown timer widget rendered in two variants.

  Both variants are **zero-JS** — the parent LiveView drives the timer by
  updating assigns (e.g. via `Process.send_after/3` + `handle_info/2`).

  ## Variants

  | Variant      | Description                                                     |
  |--------------|-----------------------------------------------------------------|
  | `:circular`  | SVG arc progress ring with centered time + duration label       |
  | `:flat`      | Rectangular card with large time pill, progress bar, and optional action buttons |

  ## Examples

      <%!-- Circular (default) --%>
      <.countdown_timer
        minutes={@minutes}
        seconds={@seconds}
        total_seconds={3600}
        label="60 min"
      />

      <%!-- Flat with action buttons --%>
      <.countdown_timer
        minutes={@minutes}
        seconds={@seconds}
        total_seconds={3600}
        variant={:flat}
        label="60 min"
        on_pause="pause_timer"
        on_stop="stop_timer"
      />

  ## LiveView integration

      def mount(_params, _session, socket) do
        total = 3600
        {:ok, assign(socket, minutes: 60, seconds: 0, total_seconds: total)}
      end

      def handle_info(:tick, %{assigns: %{minutes: 0, seconds: 0}} = socket) do
        {:noreply, socket}
      end

      def handle_info(:tick, socket) do
        remaining = socket.assigns.minutes * 60 + socket.assigns.seconds - 1
        Process.send_after(self(), :tick, 1_000)
        {:noreply, assign(socket,
          minutes: div(remaining, 60),
          seconds: rem(remaining, 60)
        )}
      end
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # SVG arc geometry: circle at cx=60 cy=60 r=50 inside a 120x120 viewBox.
  # circumference = 2 * pi * 50 ≈ 314.16
  @circumference 314.16

  attr(:minutes, :integer, required: true, doc: "Current remaining minutes.")
  attr(:seconds, :integer, required: true, doc: "Current remaining seconds (0–59).")

  attr(:total_seconds, :integer,
    required: true,
    doc: "Total timer duration in seconds. Used to compute progress percentage."
  )

  attr(:variant, :atom,
    default: :circular,
    values: [:circular, :flat],
    doc: "Display variant. `:circular` renders an SVG arc ring; `:flat` renders a card with a progress bar."
  )

  attr(:label, :string,
    default: nil,
    doc: "Optional duration label displayed below the time, e.g. `\"60 min\"`."
  )

  attr(:on_pause, :string,
    default: nil,
    doc: "phx-click event name for the pause button (flat variant only)."
  )

  attr(:on_stop, :string,
    default: nil,
    doc: "phx-click event name for the stop button (flat variant only)."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root element.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>`.")

  @doc """
  Renders a countdown timer widget.

  ## Example

      <.countdown_timer minutes={31} seconds={47} total_seconds={3600} variant={:flat} label="60 min" />
  """
  def countdown_timer(assigns) do
    assigns =
      assigns
      |> assign(:formatted_time, format_time(assigns.minutes, assigns.seconds))
      |> assign(:arc_dash, arc_dash(assigns.minutes, assigns.seconds, assigns.total_seconds))
      |> assign(
        :progress_width,
        trunc((1 - progress_pct(assigns.minutes, assigns.seconds, assigns.total_seconds)) * 100)
      )

    ~H"""
    <div
      class={cn(["bg-background rounded-2xl border border-border shadow-sm p-6", @class])}
      {@rest}
    >
      <%!-- CIRCULAR VARIANT --%>
      <div :if={@variant == :circular} class="flex flex-col items-center">
        <div class="relative w-32 h-32">
          <svg viewBox="0 0 120 120" class="w-full h-full -rotate-90" aria-hidden="true">
            <%!-- Track ring --%>
            <circle
              cx="60"
              cy="60"
              r="50"
              fill="none"
              class="stroke-muted"
              stroke-width="10"
            />
            <%!-- Progress arc --%>
            <circle
              cx="60"
              cy="60"
              r="50"
              fill="none"
              class="stroke-primary"
              stroke-width="10"
              stroke-linecap="round"
              stroke-dasharray={@arc_dash}
              stroke-dashoffset="0"
            />
          </svg>
          <div class="absolute inset-0 flex flex-col items-center justify-center">
            <span class="text-xl font-bold text-foreground">{@formatted_time}</span>
            <span :if={@label} class="text-xs text-muted-foreground mt-0.5">{@label}</span>
          </div>
        </div>
      </div>

      <%!-- FLAT VARIANT --%>
      <div :if={@variant == :flat} class="flex flex-col items-center gap-3">
        <%!-- Time display pill --%>
        <div class="rounded-xl bg-muted px-6 py-3">
          <span class="text-3xl font-bold tabular-nums text-foreground tracking-wider">
            {@formatted_time}
          </span>
        </div>
        <span :if={@label} class="text-sm text-muted-foreground">{@label}</span>
        <%!-- Progress bar --%>
        <div class="w-full h-3 rounded-full bg-muted overflow-hidden">
          <div
            class="h-full rounded-full bg-primary transition-all"
            style={"width: #{@progress_width}%;"}
          />
        </div>
        <%!-- Optional action buttons --%>
        <div :if={@on_pause || @on_stop} class="flex items-center gap-3 mt-1">
          <button
            :if={@on_pause}
            phx-click={@on_pause}
            class="flex h-10 w-10 items-center justify-center rounded-full bg-muted hover:bg-muted/70 text-muted-foreground"
            aria-label="Pause"
          >
            ⏸
          </button>
          <button
            :if={@on_stop}
            phx-click={@on_stop}
            class="flex h-10 w-10 items-center justify-center rounded-full bg-muted hover:bg-muted/70 text-muted-foreground"
            aria-label="Stop"
          >
            ✕
          </button>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Returns elapsed fraction (0.0 = just started, 1.0 = finished).
  defp progress_pct(_minutes, _seconds, 0), do: 0.0

  defp progress_pct(minutes, seconds, total_seconds) do
    elapsed = total_seconds - (minutes * 60 + seconds)
    elapsed / total_seconds
  end

  # Returns stroke-dasharray value for the SVG arc.
  # `filled` = remaining portion of the circumference to stroke.
  defp arc_dash(minutes, seconds, total_seconds) do
    pct = progress_pct(minutes, seconds, total_seconds)
    remaining_pct = 1.0 - pct
    filled = Float.round(remaining_pct * @circumference, 2)
    "#{filled} #{@circumference}"
  end

  # Formats minutes and seconds as "M:SS" (seconds always zero-padded to 2 digits).
  defp format_time(m, s) when s < 10, do: "#{m}:0#{s}"
  defp format_time(m, s), do: "#{m}:#{s}"
end
