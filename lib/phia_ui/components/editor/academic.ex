defmodule PhiaUi.Components.Editor.Academic do
  @moduledoc """
  Editor Academic Suite — 6 components for academic and scholarly writing tools.

  Provides citation style selection, structure validation, abbreviation management,
  readability scoring, page numbering, and margin notes for building full-featured
  academic editors.

  ## Components

  - `citation_style_selector/1`  — dropdown to choose citation format (APA, MLA, Chicago, etc.)
  - `structure_validator/1`      — panel displaying document structure rule violations
  - `abbreviation_manager/1`     — table of abbreviation definitions with delete actions
  - `reading_level_indicator/1`  — progress bar showing readability score with color coding
  - `page_numbering/1`           — "Page N of M" display with numeric/roman/letter formats
  - `margin_note/1`              — absolutely positioned aside for side annotations
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ============================================================================
  # 9. citation_style_selector/1
  # ============================================================================

  attr :id, :string, required: true
  attr :value, :atom, default: :apa, values: [:apa, :abnt, :mla, :chicago, :harvard, :ieee]
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a `<select>` dropdown for choosing a citation style.

  ## Example

      <.citation_style_selector id="cite-style" value={:apa} />
  """
  def citation_style_selector(assigns) do
    styles = [
      {:apa, "APA (7th ed.)"},
      {:abnt, "ABNT"},
      {:mla, "MLA (9th ed.)"},
      {:chicago, "Chicago (17th ed.)"},
      {:harvard, "Harvard"},
      {:ieee, "IEEE"}
    ]

    assigns = assign(assigns, :styles, styles)

    ~H"""
    <div class={cn(["relative", @class])} {@rest}>
      <label for={@id} class="block text-xs font-medium text-muted-foreground mb-0.5">
        Citation Style
      </label>
      <select
        id={@id}
        name="citation_style"
        aria-label="Citation style"
        class="h-8 w-full rounded border border-border bg-background px-2 text-sm text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
      >
        <option
          :for={{val, label} <- @styles}
          value={val}
          selected={@value == val}
        >
          {label}
        </option>
      </select>
    </div>
    """
  end

  # ============================================================================
  # 10. structure_validator/1
  # ============================================================================

  attr :id, :string, required: true
  attr :rules, :list, default: []
  attr :violations, :list, default: []
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a panel showing document structure rule violations.

  Each violation is a map with `:rule`, `:message`, and `:severity` keys.
  Severity values: `:error`, `:warning`, `:info`.

  ## Example

      <.structure_validator
        id="validator"
        violations={[
          %{rule: "abstract", message: "Missing abstract section", severity: :error},
          %{rule: "heading", message: "Consider adding sub-headings", severity: :warning}
        ]}
      />
  """
  def structure_validator(assigns) do
    ~H"""
    <div
      id={@id}
      role="status"
      aria-label="Structure validation"
      class={cn(["rounded-lg border border-border bg-card p-3", @class])}
      {@rest}
    >
      <div class="flex items-center justify-between mb-2">
        <h3 class="text-sm font-semibold text-foreground">Structure Validation</h3>
        <span :if={@violations == []} class="text-xs text-emerald-600">All checks passed</span>
        <span :if={@violations != []} class="text-xs text-muted-foreground">
          {length(@violations)} {if length(@violations) == 1, do: "issue", else: "issues"}
        </span>
      </div>

      <div :if={@violations == []} class="flex items-center gap-2 py-2 text-emerald-600">
        <svg class="h-4 w-4" viewBox="0 0 16 16" fill="none">
          <path d="M4 8l3 3 5-6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
        <span class="text-sm">Document structure looks good</span>
      </div>

      <ul :if={@violations != []} class="space-y-1.5">
        <li
          :for={v <- @violations}
          class="flex items-start gap-2 text-sm"
        >
          <span class={cn([
            "mt-0.5 h-4 w-4 shrink-0 rounded-full flex items-center justify-center text-[10px] font-bold",
            violation_color(Map.get(v, :severity, :info))
          ])}>
            {violation_icon(Map.get(v, :severity, :info))}
          </span>
          <div class="min-w-0">
            <span class="font-medium text-foreground">{Map.get(v, :rule, "")}</span>
            <span class="text-muted-foreground ml-1">{Map.get(v, :message, "")}</span>
          </div>
        </li>
      </ul>
    </div>
    """
  end

  defp violation_color(:error), do: "bg-destructive/10 text-destructive"
  defp violation_color(:warning), do: "bg-amber-500/10 text-amber-600"
  defp violation_color(_), do: "bg-blue-500/10 text-blue-600"

  defp violation_icon(:error), do: "!"
  defp violation_icon(:warning), do: "!"
  defp violation_icon(_), do: "i"

  # ============================================================================
  # 11. abbreviation_manager/1
  # ============================================================================

  attr :id, :string, required: true
  attr :abbreviations, :list, default: []
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a table of abbreviation definitions with delete actions.

  Each abbreviation is a map with `:short` and `:full` keys.

  ## Example

      <.abbreviation_manager
        id="abbr-mgr"
        abbreviations={[
          %{short: "HTML", full: "HyperText Markup Language"},
          %{short: "CSS", full: "Cascading Style Sheets"}
        ]}
      />
  """
  def abbreviation_manager(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn(["rounded-lg border border-border bg-card p-3", @class])}
      {@rest}
    >
      <h3 class="text-sm font-semibold text-foreground mb-2">Abbreviations</h3>

      <div :if={@abbreviations == []} class="py-3 text-center text-sm text-muted-foreground">
        No abbreviations defined yet.
      </div>

      <table :if={@abbreviations != []} class="w-full text-sm">
        <thead>
          <tr class="border-b border-border text-left">
            <th class="pb-1.5 pr-3 text-xs font-medium text-muted-foreground">Abbr.</th>
            <th class="pb-1.5 pr-3 text-xs font-medium text-muted-foreground">Full Form</th>
            <th class="pb-1.5 w-10 text-xs font-medium text-muted-foreground sr-only">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr
            :for={abbr <- @abbreviations}
            class="border-b border-border/50 last:border-0"
          >
            <td class="py-1.5 pr-3 font-mono text-xs text-foreground">{Map.get(abbr, :short, "")}</td>
            <td class="py-1.5 pr-3 text-muted-foreground">{Map.get(abbr, :full, "")}</td>
            <td class="py-1.5 w-10 text-right">
              <button
                type="button"
                phx-click="abbreviation:delete"
                phx-value-short={Map.get(abbr, :short, "")}
                aria-label={"Delete #{Map.get(abbr, :short, "")}"}
                class="inline-flex h-6 w-6 items-center justify-center rounded text-muted-foreground hover:bg-destructive/10 hover:text-destructive transition-colors"
              >
                <svg class="h-3.5 w-3.5" viewBox="0 0 16 16" fill="none">
                  <path d="M4 4l8 8M12 4l-8 8" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" />
                </svg>
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  # ============================================================================
  # 12. reading_level_indicator/1
  # ============================================================================

  attr :score, :any, default: nil
  attr :label, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a 0-100 progress bar showing readability score with color coding.

  - Red (score < 30): Difficult to read
  - Amber (score 30-59): Moderate readability
  - Green (score >= 60): Easy to read

  When no score is provided, shows "Not calculated" placeholder.

  ## Example

      <.reading_level_indicator score={72} label="Grade 8" />
  """
  def reading_level_indicator(assigns) do
    score_val = if is_number(assigns.score), do: assigns.score, else: nil
    clamped = if score_val, do: max(0, min(100, score_val)), else: nil

    assigns =
      assigns
      |> assign(:score_val, score_val)
      |> assign(:clamped, clamped)

    ~H"""
    <div
      class={cn(["rounded-lg border border-border bg-card p-3", @class])}
      role="meter"
      aria-valuemin={if @score_val, do: "0"}
      aria-valuemax={if @score_val, do: "100"}
      aria-valuenow={if @score_val, do: to_string(@clamped)}
      aria-label="Reading level"
      {@rest}
    >
      <div class="flex items-center justify-between mb-1.5">
        <span class="text-xs font-medium text-muted-foreground">Readability</span>
        <span :if={@score_val} class={cn(["text-xs font-semibold", reading_level_text_color(@clamped)])}>
          {@clamped}/100
        </span>
        <span :if={!@score_val} class="text-xs text-muted-foreground">Not calculated</span>
      </div>

      <div :if={@score_val} class="h-2 w-full overflow-hidden rounded-full bg-muted">
        <div
          class={cn(["h-full rounded-full transition-all duration-500", reading_level_bar_color(@clamped)])}
          style={"width: #{@clamped}%"}
        />
      </div>

      <div :if={!@score_val} class="h-2 w-full rounded-full bg-muted" />

      <p :if={@label} class="mt-1 text-xs text-muted-foreground">{@label}</p>
    </div>
    """
  end

  defp reading_level_text_color(score) when score < 30, do: "text-destructive"
  defp reading_level_text_color(score) when score < 60, do: "text-amber-600"
  defp reading_level_text_color(_), do: "text-emerald-600"

  defp reading_level_bar_color(score) when score < 30, do: "bg-destructive"
  defp reading_level_bar_color(score) when score < 60, do: "bg-amber-500"
  defp reading_level_bar_color(_), do: "bg-emerald-500"

  # ============================================================================
  # 13. page_numbering/1
  # ============================================================================

  attr :current, :integer, default: 1
  attr :total, :integer, default: 1
  attr :format, :atom, default: :numeric, values: [:numeric, :roman, :letter]
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a "Page N of M" text display with configurable number format.

  Formats:
  - `:numeric` — "Page 1 of 10"
  - `:roman`   — "Page I of X"
  - `:letter`  — "Page A of J"

  ## Example

      <.page_numbering current={3} total={15} format={:roman} />
  """
  def page_numbering(assigns) do
    assigns =
      assigns
      |> assign(:formatted_current, format_page_number(assigns.current, assigns.format))
      |> assign(:formatted_total, format_page_number(assigns.total, assigns.format))

    ~H"""
    <span
      class={cn(["text-xs text-muted-foreground tabular-nums", @class])}
      aria-label={"Page #{@current} of #{@total}"}
      {@rest}
    >
      Page {@formatted_current} of {@formatted_total}
    </span>
    """
  end

  defp format_page_number(n, :roman), do: to_roman(n)
  defp format_page_number(n, :letter) when n >= 1 and n <= 26, do: <<(n - 1 + ?A)>>
  defp format_page_number(n, :letter), do: to_string(n)
  defp format_page_number(n, _), do: to_string(n)

  defp to_roman(n) when n <= 0, do: "0"

  defp to_roman(n) do
    romans = [
      {1000, "M"}, {900, "CM"}, {500, "D"}, {400, "CD"},
      {100, "C"}, {90, "XC"}, {50, "L"}, {40, "XL"},
      {10, "X"}, {9, "IX"}, {5, "V"}, {4, "IV"}, {1, "I"}
    ]

    do_roman(n, romans, "")
  end

  defp do_roman(0, _romans, acc), do: acc
  defp do_roman(_n, [], acc), do: acc

  defp do_roman(n, [{val, sym} | rest], acc) when n >= val do
    do_roman(n - val, [{val, sym} | rest], acc <> sym)
  end

  defp do_roman(n, [_ | rest], acc), do: do_roman(n, rest, acc)

  # ============================================================================
  # 14. margin_note/1
  # ============================================================================

  attr :id, :string, required: true
  attr :side, :atom, default: :right, values: [:left, :right]
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Renders an absolutely positioned `<aside>` for side annotations.

  Must be placed inside a `position: relative` parent container. The note
  appears on the specified side of the content area.

  ## Example

      <div class="relative">
        <p>Main content here...</p>
        <.margin_note id="note-1" side={:right}>
          This is a side annotation.
        </.margin_note>
      </div>
  """
  def margin_note(assigns) do
    ~H"""
    <aside
      id={@id}
      role="note"
      class={cn([
        "absolute top-0 w-48 text-xs text-muted-foreground leading-relaxed",
        "border-border",
        @side == :right && "left-full ml-6 border-l pl-3",
        @side == :left && "right-full mr-6 border-r pr-3",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </aside>
    """
  end
end
