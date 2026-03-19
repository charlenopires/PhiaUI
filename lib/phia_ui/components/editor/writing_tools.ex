defmodule PhiaUi.Components.Editor.WritingTools do
  @moduledoc """
  Editor Writing Tools Suite — 8 components for writing productivity, readability
  analysis, focus mode, voice input, text-to-speech, statistics, and grammar checking.

  ## Components

  - `readability_score/1`        — circular/bar gauge showing readability score
  - `writing_goals/1`            — progress bar with word count target
  - `focus_mode/1`               — wrapper that dims surrounding content
  - `voice_typing_indicator/1`   — mic icon with recording state and pulse animation
  - `text_to_speech/1`           — play/pause/stop controls for TTS
  - `writing_statistics/1`       — grid of 4 stat boxes (words, chars, sentences, reading time)
  - `document_metrics/1`         — mini bar chart of daily writing counts
  - `grammar_highlight/1`        — inline span with colored underline by issue type
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ============================================================================
  # 7. readability_score/1
  # ============================================================================

  attr :score, :any, default: nil
  attr :grade, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a circular gauge showing the readability score (0-100).

  Color-coded: red < 30 (difficult), amber 30-59 (moderate), green >= 60 (easy).
  An optional `:grade` label (e.g., "Grade 8") is displayed below the score.

  ## Example

      <.readability_score score={65} grade="Grade 8" />
  """
  def readability_score(assigns) do
    score_val = if is_number(assigns.score), do: assigns.score, else: nil
    clamped = if score_val, do: max(0, min(100, score_val)), else: nil

    # SVG circle: radius=36, circumference=226.19
    circumference = 226.19
    offset = if clamped, do: circumference * (1 - clamped / 100), else: circumference

    assigns =
      assigns
      |> assign(:score_val, score_val)
      |> assign(:clamped, clamped)
      |> assign(:circumference, circumference)
      |> assign(:offset, offset)

    ~H"""
    <div
      class={cn(["flex flex-col items-center gap-1", @class])}
      role="meter"
      aria-valuemin={if @score_val, do: "0"}
      aria-valuemax={if @score_val, do: "100"}
      aria-valuenow={if @score_val, do: to_string(@clamped)}
      aria-label="Readability score"
      {@rest}
    >
      <div class="relative h-20 w-20">
        <svg class="h-20 w-20 -rotate-90" viewBox="0 0 80 80">
          <%!-- Background circle --%>
          <circle
            cx="40" cy="40" r="36"
            fill="none"
            stroke="currentColor"
            stroke-width="6"
            class="text-muted"
          />
          <%!-- Progress arc --%>
          <circle
            :if={@score_val}
            cx="40" cy="40" r="36"
            fill="none"
            stroke="currentColor"
            stroke-width="6"
            stroke-linecap="round"
            stroke-dasharray={to_string(@circumference)}
            stroke-dashoffset={to_string(@offset)}
            class={cn(["transition-all duration-700", score_color(@clamped)])}
          />
        </svg>
        <%!-- Center text --%>
        <div class="absolute inset-0 flex flex-col items-center justify-center">
          <span :if={@score_val} class={cn(["text-lg font-bold tabular-nums", score_text_color(@clamped)])}>
            {@clamped}
          </span>
          <span :if={!@score_val} class="text-xs text-muted-foreground">N/A</span>
        </div>
      </div>
      <span :if={@grade} class="text-xs text-muted-foreground">{@grade}</span>
      <span :if={!@grade && @score_val} class="text-xs text-muted-foreground">{score_label(@clamped)}</span>
    </div>
    """
  end

  defp score_color(s) when s < 30, do: "text-destructive"
  defp score_color(s) when s < 60, do: "text-amber-500"
  defp score_color(_), do: "text-emerald-500"

  defp score_text_color(s) when s < 30, do: "text-destructive"
  defp score_text_color(s) when s < 60, do: "text-amber-600"
  defp score_text_color(_), do: "text-emerald-600"

  defp score_label(s) when s < 30, do: "Difficult"
  defp score_label(s) when s < 60, do: "Moderate"
  defp score_label(_), do: "Easy"

  # ============================================================================
  # 8. writing_goals/1
  # ============================================================================

  attr :id, :string, required: true
  attr :target, :integer, default: 1000
  attr :current, :integer, default: 0
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a progress bar with a word count target.

  Shows "{current}/{target} words" and fills the bar proportionally.
  Turns green when the target is met or exceeded.

  ## Example

      <.writing_goals id="goals" target={2000} current={1250} />
  """
  def writing_goals(assigns) do
    target = max(1, assigns.target)
    pct = min(100, round(assigns.current / target * 100))
    reached = assigns.current >= assigns.target

    assigns =
      assigns
      |> assign(:pct, pct)
      |> assign(:reached, reached)

    ~H"""
    <div
      id={@id}
      class={cn(["rounded-lg border border-border bg-card p-3", @class])}
      {@rest}
    >
      <div class="flex items-center justify-between mb-1.5">
        <span class="text-xs font-medium text-muted-foreground">Writing Goal</span>
        <span class={cn([
          "text-xs font-semibold tabular-nums",
          @reached && "text-emerald-600",
          !@reached && "text-foreground"
        ])}>
          {@current}/{@target} words
        </span>
      </div>
      <div class="h-2 w-full overflow-hidden rounded-full bg-muted">
        <div
          role="progressbar"
          aria-valuenow={to_string(@current)}
          aria-valuemin="0"
          aria-valuemax={to_string(@target)}
          class={cn([
            "h-full rounded-full transition-all duration-500",
            @reached && "bg-emerald-500",
            !@reached && "bg-primary"
          ])}
          style={"width: #{@pct}%"}
        />
      </div>
      <p :if={@reached} class="mt-1 text-xs text-emerald-600">Goal reached!</p>
    </div>
    """
  end

  # ============================================================================
  # 9. focus_mode/1
  # ============================================================================

  attr :id, :string, required: true
  attr :active, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Renders a wrapper div that dims surrounding content when focus mode is active.

  When `active` is true, applies an opacity dimming class to create a focused
  writing experience. The inner content remains fully visible.

  ## Example

      <.focus_mode id="focus" active={@focus_active}>
        <div contenteditable>Writing content here...</div>
      </.focus_mode>
  """
  def focus_mode(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn([
        "relative transition-all duration-300",
        @active && "phia-focus-mode",
        @class
      ])}
      data-focus-active={to_string(@active)}
      {@rest}
    >
      <div :if={@active} class="pointer-events-none fixed inset-0 z-40 bg-background/80 backdrop-blur-sm" />
      <div class={cn(["relative", @active && "z-50"])}>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  # ============================================================================
  # 10. voice_typing_indicator/1
  # ============================================================================

  attr :id, :string, required: true
  attr :recording, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a microphone icon that indicates voice typing state.

  When `recording` is true, the icon turns red and gains a pulse animation.

  ## Example

      <.voice_typing_indicator id="voice" recording={@is_recording} />
  """
  def voice_typing_indicator(assigns) do
    ~H"""
    <div
      id={@id}
      role="status"
      aria-label={if @recording, do: "Recording", else: "Not recording"}
      class={cn(["inline-flex items-center gap-1.5", @class])}
      {@rest}
    >
      <div class={cn([
        "relative inline-flex h-8 w-8 items-center justify-center rounded-full transition-colors",
        @recording && "bg-destructive/10",
        !@recording && "bg-muted"
      ])}>
        <%!-- Pulse ring when recording --%>
        <div
          :if={@recording}
          class="absolute inset-0 rounded-full bg-destructive/20 animate-[phia-pulse-ring_1.5s_ease-out_infinite]"
        />
        <%!-- Mic icon --%>
        <svg
          class={cn([
            "relative h-4 w-4 transition-colors",
            @recording && "text-destructive",
            !@recording && "text-muted-foreground"
          ])}
          viewBox="0 0 16 16"
          fill="none"
        >
          <rect x="5.5" y="1.5" width="5" height="8" rx="2.5" stroke="currentColor" stroke-width="1.3" />
          <path d="M3.5 7.5a4.5 4.5 0 009 0" stroke="currentColor" stroke-width="1.3" stroke-linecap="round" />
          <path d="M8 12.5v2" stroke="currentColor" stroke-width="1.3" stroke-linecap="round" />
          <path d="M6 14.5h4" stroke="currentColor" stroke-width="1.3" stroke-linecap="round" />
        </svg>
      </div>
      <span :if={@recording} class="text-xs font-medium text-destructive">Recording...</span>
    </div>
    """
  end

  # ============================================================================
  # 11. text_to_speech/1
  # ============================================================================

  attr :id, :string, required: true
  attr :playing, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders play/pause and stop buttons for text-to-speech playback.

  ## Example

      <.text_to_speech id="tts" playing={@tts_playing} />
  """
  def text_to_speech(assigns) do
    ~H"""
    <div
      id={@id}
      role="group"
      aria-label="Text to speech controls"
      class={cn(["inline-flex items-center gap-1", @class])}
      {@rest}
    >
      <%!-- Play / Pause --%>
      <button
        type="button"
        phx-click="tts:toggle"
        aria-label={if @playing, do: "Pause", else: "Play"}
        class={cn([
          "inline-flex h-8 w-8 items-center justify-center rounded-full transition-colors",
          "hover:bg-accent hover:text-accent-foreground",
          "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
          @playing && "bg-primary text-primary-foreground hover:bg-primary/90"
        ])}
      >
        <%!-- Play icon --%>
        <svg :if={!@playing} class="h-4 w-4" viewBox="0 0 16 16" fill="currentColor">
          <path d="M4.5 2.5v11l9-5.5-9-5.5z" />
        </svg>
        <%!-- Pause icon --%>
        <svg :if={@playing} class="h-4 w-4" viewBox="0 0 16 16" fill="currentColor">
          <rect x="3.5" y="2.5" width="3" height="11" rx="0.5" />
          <rect x="9.5" y="2.5" width="3" height="11" rx="0.5" />
        </svg>
      </button>

      <%!-- Stop --%>
      <button
        type="button"
        phx-click="tts:stop"
        aria-label="Stop"
        class="inline-flex h-8 w-8 items-center justify-center rounded-full text-muted-foreground transition-colors hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
      >
        <svg class="h-4 w-4" viewBox="0 0 16 16" fill="currentColor">
          <rect x="3" y="3" width="10" height="10" rx="1" />
        </svg>
      </button>
    </div>
    """
  end

  # ============================================================================
  # 12. writing_statistics/1
  # ============================================================================

  attr :words, :integer, default: 0
  attr :characters, :integer, default: 0
  attr :sentences, :integer, default: 0
  attr :reading_time, :integer, default: 0
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a grid of 4 statistic boxes showing word count, character count,
  sentence count, and estimated reading time.

  ## Example

      <.writing_statistics words={1250} characters={6800} sentences={52} reading_time={5} />
  """
  def writing_statistics(assigns) do
    stats = [
      %{label: "Words", value: assigns.words, icon: "W"},
      %{label: "Characters", value: assigns.characters, icon: "C"},
      %{label: "Sentences", value: assigns.sentences, icon: "S"},
      %{label: "Reading time", value: assigns.reading_time, suffix: "min", icon: "T"}
    ]

    assigns = assign(assigns, :stats, stats)

    ~H"""
    <div
      class={cn(["grid grid-cols-2 gap-2", @class])}
      role="group"
      aria-label="Writing statistics"
      {@rest}
    >
      <div
        :for={stat <- @stats}
        class="rounded-lg border border-border bg-card p-2.5"
      >
        <div class="flex items-center gap-1.5 mb-1">
          <span class="inline-flex h-5 w-5 items-center justify-center rounded bg-muted text-[10px] font-bold text-muted-foreground">
            {stat.icon}
          </span>
          <span class="text-[10px] font-medium text-muted-foreground uppercase tracking-wider">
            {stat.label}
          </span>
        </div>
        <span class="text-lg font-semibold text-foreground tabular-nums">
          {format_stat(stat.value)}{if Map.get(stat, :suffix), do: " #{stat.suffix}", else: ""}
        </span>
      </div>
    </div>
    """
  end

  defp format_stat(n) when n >= 1_000_000, do: "#{Float.round(n / 1_000_000, 1)}M"
  defp format_stat(n) when n >= 1_000, do: "#{Float.round(n / 1_000, 1)}k"
  defp format_stat(n), do: to_string(n)

  # ============================================================================
  # 13. document_metrics/1
  # ============================================================================

  attr :id, :string, required: true
  attr :daily_counts, :list, default: []
  attr :target, :integer, default: 0
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a mini bar chart showing daily writing word counts.

  Each item in `daily_counts` is a map with `:date` (string) and `:count` (integer).
  An optional `:target` draws a horizontal reference line.

  ## Example

      <.document_metrics
        id="metrics"
        target={500}
        daily_counts={[
          %{date: "Mon", count: 420},
          %{date: "Tue", count: 680},
          %{date: "Wed", count: 310}
        ]}
      />
  """
  def document_metrics(assigns) do
    max_count =
      case assigns.daily_counts do
        [] -> 1
        counts -> max(1, Enum.max_by(counts, &Map.get(&1, :count, 0)) |> Map.get(:count, 1))
      end

    max_val = max(max_count, assigns.target)

    bars =
      Enum.map(assigns.daily_counts, fn day ->
        count = Map.get(day, :count, 0)
        pct = round(count / max_val * 100)
        met = assigns.target > 0 and count >= assigns.target

        %{
          date: Map.get(day, :date, ""),
          count: count,
          pct: pct,
          met: met
        }
      end)

    target_pct = if assigns.target > 0, do: round(assigns.target / max_val * 100), else: 0

    assigns =
      assigns
      |> assign(:bars, bars)
      |> assign(:target_pct, target_pct)

    ~H"""
    <div
      id={@id}
      class={cn(["rounded-lg border border-border bg-card p-3", @class])}
      {@rest}
    >
      <div class="flex items-center justify-between mb-2">
        <span class="text-xs font-medium text-muted-foreground">Daily Words</span>
        <span :if={@target > 0} class="text-[10px] text-muted-foreground">
          Target: {format_stat(@target)}
        </span>
      </div>

      <div :if={@bars == []} class="py-4 text-center text-xs text-muted-foreground">
        No data yet
      </div>

      <div :if={@bars != []} class="relative" style="height: 80px">
        <%!-- Target line --%>
        <div
          :if={@target > 0}
          class="absolute left-0 right-0 border-t border-dashed border-amber-500/50"
          style={"bottom: #{@target_pct}%"}
        />

        <%!-- Bars --%>
        <div class="flex h-full items-end gap-1">
          <div
            :for={bar <- @bars}
            class="flex flex-1 flex-col items-center gap-0.5"
          >
            <div
              class={cn([
                "w-full min-h-[2px] rounded-t transition-all duration-300",
                bar.met && "bg-emerald-500",
                !bar.met && "bg-primary/70"
              ])}
              style={"height: #{bar.pct}%"}
              title={"#{bar.date}: #{bar.count} words"}
            />
            <span class="text-[9px] text-muted-foreground truncate w-full text-center">
              {bar.date}
            </span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # ============================================================================
  # 14. grammar_highlight/1
  # ============================================================================

  attr :type, :atom, default: :grammar, values: [:grammar, :spelling, :style, :clarity]
  attr :suggestion, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Renders a `<span>` with a colored wavy underline indicating a grammar,
  spelling, style, or clarity issue.

  Colors:
  - `:grammar`  — blue underline
  - `:spelling` — red underline
  - `:style`    — purple underline
  - `:clarity`  — amber underline

  An optional `:suggestion` is shown as a `title` tooltip.

  ## Example

      <.grammar_highlight type={:spelling} suggestion="their">
        there
      </.grammar_highlight>
  """
  def grammar_highlight(assigns) do
    ~H"""
    <span
      class={cn([
        "relative cursor-help",
        highlight_underline(@type),
        @class
      ])}
      title={@suggestion}
      data-grammar-type={@type}
      data-suggestion={@suggestion}
      {@rest}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end

  defp highlight_underline(:grammar),
    do: "decoration-wavy decoration-blue-500 underline underline-offset-2 decoration-[1.5px]"

  defp highlight_underline(:spelling),
    do: "decoration-wavy decoration-destructive underline underline-offset-2 decoration-[1.5px]"

  defp highlight_underline(:style),
    do: "decoration-wavy decoration-purple-500 underline underline-offset-2 decoration-[1.5px]"

  defp highlight_underline(:clarity),
    do: "decoration-wavy decoration-amber-500 underline underline-offset-2 decoration-[1.5px]"
end
