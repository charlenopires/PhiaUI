defmodule PhiaUi.Components.Editor.LanguageTools do
  @moduledoc """
  Language Tools Suite — 4 components for grammar checking, spell check control,
  and custom dictionary management within the PhiaUI rich text editor.

  Provides sidebars and inline popovers for proofing workflows, enabling
  writers to review grammar issues, accept or ignore suggestions, toggle
  browser spell-checking, and maintain a personal word list.

  ## Components

  - `grammar_panel/1`       — sidebar listing grammar issues grouped by severity
  - `grammar_suggestion/1`  — inline popover with replacement suggestion
  - `spell_check_toggle/1`  — compact toggle button for browser spellcheck
  - `dictionary_panel/1`    — custom word dictionary with add/remove management

  ## Example

      <.grammar_panel id="grammar" issues={@grammar_issues} />

      <.grammar_suggestion
        id="suggestion-1"
        visible={@show_suggestion}
        message="Consider using active voice."
        suggestion="The team completed the project."
        severity={:warning}
      />

      <.spell_check_toggle id="spellcheck" enabled={@spellcheck_enabled} />

      <.dictionary_panel id="dictionary" words={@custom_words} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ============================================================================
  # 1. grammar_panel/1
  # ============================================================================

  attr :id, :string, required: true, doc: "Unique identifier for the grammar panel."

  attr :issues, :list,
    default: [],
    doc: """
    List of grammar issue maps. Each map should contain:
    - `:message` (string) — description of the issue
    - `:severity` (atom) — `:error`, `:warning`, or `:info`
    - `:range` (map) — position range for navigation (encoded as JSON on click)
    - `:suggestion` (string | nil) — optional replacement suggestion
    """

  attr :class, :string, default: nil, doc: "Additional CSS classes for the panel."
  attr :rest, :global

  @doc """
  Renders a bordered sidebar panel listing grammar issues with severity icons,
  messages, and optional suggestions.

  When no issues are present, an empty state with a check icon is displayed.
  Each issue row is clickable and emits a `"grammar:navigate"` event with the
  issue's range encoded as JSON in `phx-value-range`.

  ## Example

      <.grammar_panel id="grammar" issues={[
        %{message: "Passive voice detected", severity: :warning, range: %{from: 10, to: 25}, suggestion: "Use active voice"},
        %{message: "Missing comma", severity: :error, range: %{from: 42, to: 43}, suggestion: nil}
      ]} />
  """
  def grammar_panel(assigns) do
    ~H"""
    <div
      id={@id}
      role="region"
      aria-label="Grammar issues"
      class={cn([
        "flex flex-col rounded-lg border border-border bg-background shadow-sm",
        @class
      ])}
      {@rest}
    >
      <%!-- Header --%>
      <div class="flex items-center justify-between border-b border-border px-3 py-2">
        <h3 class="text-sm font-semibold text-foreground">Grammar</h3>
        <span
          :if={@issues != []}
          class={cn([
            "inline-flex h-5 min-w-5 items-center justify-center rounded-full px-1.5 text-[10px] font-medium",
            issue_count_class(@issues)
          ])}
        >
          {length(@issues)}
        </span>
      </div>

      <%!-- Empty state --%>
      <div
        :if={@issues == []}
        class="flex flex-col items-center justify-center gap-2 px-4 py-8 text-center"
      >
        <svg
          class="h-8 w-8 text-emerald-500"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          aria-hidden="true"
        >
          <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
          <polyline points="22 4 12 14.01 9 11.01" />
        </svg>
        <p class="text-sm text-muted-foreground">No issues found</p>
      </div>

      <%!-- Issue list --%>
      <ul :if={@issues != []} class="flex flex-col divide-y divide-border overflow-y-auto" role="list">
        <li :for={{issue, idx} <- Enum.with_index(@issues)}>
          <button
            type="button"
            class={cn([
              "flex w-full items-start gap-2.5 px-3 py-2.5 text-left transition-colors",
              "hover:bg-accent/50 focus-visible:outline-none focus-visible:bg-accent/50 focus-visible:ring-1 focus-visible:ring-inset focus-visible:ring-ring"
            ])}
            phx-click="grammar:navigate"
            phx-value-range={Jason.encode!(issue[:range] || %{})}
            phx-value-index={to_string(idx)}
            aria-label={"Issue #{idx + 1}: #{issue[:message]}"}
          >
            <%!-- Severity icon --%>
            <span class="mt-0.5 shrink-0" aria-hidden="true">
              {severity_icon(issue[:severity])}
            </span>

            <div class="min-w-0 flex-1">
              <p class="text-sm text-foreground">{issue[:message]}</p>
              <p
                :if={issue[:suggestion]}
                class="mt-0.5 text-xs text-muted-foreground"
              >
                Suggestion: <span class="font-medium text-foreground">{issue[:suggestion]}</span>
              </p>
            </div>
          </button>
        </li>
      </ul>
    </div>
    """
  end

  # ============================================================================
  # 2. grammar_suggestion/1
  # ============================================================================

  attr :id, :string, required: true, doc: "Unique identifier for the suggestion popover."
  attr :visible, :boolean, default: false, doc: "Whether the popover is currently shown."
  attr :message, :string, default: "", doc: "Description of the grammar issue."
  attr :suggestion, :string, default: "", doc: "Suggested replacement text."

  attr :severity, :atom,
    default: :warning,
    values: [:error, :warning, :info],
    doc: "Severity level controlling the top accent bar color."

  attr :class, :string, default: nil, doc: "Additional CSS classes for the popover."
  attr :rest, :global

  @doc """
  Renders an inline popover with a grammar replacement suggestion.

  Displays a severity-colored accent bar at the top, the issue message,
  the suggested replacement in a highlighted box, and two action buttons:
  "Ignore" (ghost style) and "Accept" (primary style).

  Emits `"grammar:accept"` or `"grammar:ignore"` events with the popover
  `id` as `phx-value-id`.

  The popover uses the `phia-bubble-menu-open` animation class for entrance.

  ## Example

      <.grammar_suggestion
        id="sug-1"
        visible={true}
        message="Consider rephrasing for clarity."
        suggestion="The results clearly show..."
        severity={:warning}
      />
  """
  def grammar_suggestion(assigns) do
    ~H"""
    <div
      :if={@visible}
      id={@id}
      role="dialog"
      aria-label="Grammar suggestion"
      class={cn([
        "w-72 rounded-lg border border-border bg-popover shadow-lg",
        "animate-[phia-bubble-in_150ms_ease-out]",
        @class
      ])}
      {@rest}
    >
      <%!-- Severity accent bar --%>
      <div class={cn(["h-0.5 rounded-t-lg", severity_bar_class(@severity)])} aria-hidden="true" />

      <div class="p-3">
        <%!-- Message --%>
        <p class="text-sm text-foreground">{@message}</p>

        <%!-- Suggestion highlight --%>
        <div
          :if={@suggestion != ""}
          class={cn([
            "mt-2 rounded-md px-2.5 py-2 text-sm font-medium",
            "bg-emerald-50 text-emerald-900 dark:bg-emerald-950/50 dark:text-emerald-200"
          ])}
        >
          {@suggestion}
        </div>

        <%!-- Action buttons --%>
        <div class="mt-3 flex items-center justify-end gap-2">
          <button
            type="button"
            phx-click="grammar:ignore"
            phx-value-id={@id}
            class={cn([
              "inline-flex h-7 items-center rounded-md px-2.5 text-xs font-medium transition-colors",
              "text-muted-foreground hover:bg-accent hover:text-accent-foreground",
              "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
            ])}
          >
            Ignore
          </button>
          <button
            type="button"
            phx-click="grammar:accept"
            phx-value-id={@id}
            class={cn([
              "inline-flex h-7 items-center rounded-md bg-primary px-2.5 text-xs font-medium text-primary-foreground transition-colors",
              "hover:bg-primary/90",
              "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
            ])}
          >
            Accept
          </button>
        </div>
      </div>
    </div>
    """
  end

  # ============================================================================
  # 3. spell_check_toggle/1
  # ============================================================================

  attr :id, :string, required: true, doc: "Unique identifier for the toggle button."
  attr :enabled, :boolean, default: true, doc: "Whether spell check is currently enabled."
  attr :class, :string, default: nil, doc: "Additional CSS classes for the container."
  attr :rest, :global

  @doc """
  Renders a compact toggle button for enabling or disabling browser spellcheck.

  Displays an "ABC" icon with a check underline when enabled. A small status
  dot indicates the current state (green for enabled, muted for disabled).

  Emits a `"spellcheck:toggle"` event with `phx-value-enabled` set to the
  inverse of the current state.

  ## Example

      <.spell_check_toggle id="spellcheck" enabled={true} />
      <.spell_check_toggle id="spellcheck" enabled={false} />
  """
  def spell_check_toggle(assigns) do
    ~H"""
    <button
      id={@id}
      type="button"
      role="switch"
      aria-checked={to_string(@enabled)}
      aria-label={"Spell check #{if @enabled, do: "enabled", else: "disabled"}"}
      title={"Spell Check: #{if @enabled, do: "On", else: "Off"}"}
      phx-click="spellcheck:toggle"
      phx-value-enabled={to_string(!@enabled)}
      class={cn([
        "inline-flex items-center gap-1.5 rounded-md px-2 py-1 text-xs transition-colors",
        "border border-border bg-background",
        "hover:bg-accent hover:text-accent-foreground",
        "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
        @class
      ])}
      {@rest}
    >
      <%!-- ABC icon with underline check --%>
      <span class="relative inline-flex items-center">
        <svg
          class="h-4 w-4 text-foreground"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          aria-hidden="true"
        >
          <path d="M3 16l4-12h2l4 12" />
          <path d="M5 12h6" />
          <path d="M15 5h4" />
          <path d="M17 3v4" />
        </svg>
        <svg
          :if={@enabled}
          class="absolute -bottom-1 -right-1 h-2.5 w-2.5 text-emerald-500"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="3"
          stroke-linecap="round"
          stroke-linejoin="round"
          aria-hidden="true"
        >
          <polyline points="20 6 9 17 4 12" />
        </svg>
      </span>

      <span class="text-foreground select-none">Spell Check</span>

      <%!-- Status dot --%>
      <span
        class={cn([
          "h-1.5 w-1.5 rounded-full",
          if(@enabled, do: "bg-emerald-500", else: "bg-muted-foreground/40")
        ])}
        aria-hidden="true"
      />
    </button>
    """
  end

  # ============================================================================
  # 4. dictionary_panel/1
  # ============================================================================

  attr :id, :string, required: true, doc: "Unique identifier for the dictionary panel."
  attr :words, :list, default: [], doc: "List of custom dictionary word strings."
  attr :class, :string, default: nil, doc: "Additional CSS classes for the panel."
  attr :rest, :global

  @doc """
  Renders a bordered panel for managing a custom word dictionary.

  Provides an input form to add new words and a scrollable list of existing
  words with individual remove buttons. The word list is capped at `max-h-48`
  for consistent panel height.

  Events emitted:
  - `"dictionary:add"` on form submit (word value in the form field)
  - `"dictionary:remove"` on remove button click (word in `phx-value-word`)

  ## Example

      <.dictionary_panel id="dict" words={["PhiaUI", "LiveView", "GenServer"]} />
  """
  def dictionary_panel(assigns) do
    ~H"""
    <div
      id={@id}
      role="region"
      aria-label="Custom dictionary"
      class={cn([
        "flex flex-col rounded-lg border border-border bg-background shadow-sm",
        @class
      ])}
      {@rest}
    >
      <%!-- Header --%>
      <div class="flex items-center justify-between border-b border-border px-3 py-2">
        <h3 class="text-sm font-semibold text-foreground">Custom Dictionary</h3>
        <span
          :if={@words != []}
          class="text-xs text-muted-foreground tabular-nums"
        >
          {length(@words)} {if length(@words) == 1, do: "word", else: "words"}
        </span>
      </div>

      <%!-- Add word form --%>
      <form
        phx-submit="dictionary:add"
        class="flex items-center gap-1.5 border-b border-border px-3 py-2"
      >
        <input
          type="text"
          name="word"
          placeholder="Add word..."
          autocomplete="off"
          aria-label="New dictionary word"
          class={cn([
            "h-7 flex-1 rounded border border-border bg-background px-2 text-sm text-foreground",
            "placeholder:text-muted-foreground",
            "focus:outline-none focus:ring-1 focus:ring-ring"
          ])}
        />
        <button
          type="submit"
          aria-label="Add word to dictionary"
          class={cn([
            "inline-flex h-7 items-center rounded-md bg-primary px-2.5 text-xs font-medium text-primary-foreground transition-colors",
            "hover:bg-primary/90",
            "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
          ])}
        >
          Add
        </button>
      </form>

      <%!-- Empty state --%>
      <div
        :if={@words == []}
        class="flex items-center justify-center px-4 py-6"
      >
        <p class="text-sm text-muted-foreground">No custom words added</p>
      </div>

      <%!-- Word list --%>
      <ul
        :if={@words != []}
        class="flex max-h-48 flex-col divide-y divide-border overflow-y-auto"
        role="list"
        aria-label="Dictionary words"
      >
        <li
          :for={word <- @words}
          class="flex items-center justify-between px-3 py-1.5 group/word"
        >
          <span class="text-sm font-mono text-foreground truncate">{word}</span>
          <button
            type="button"
            phx-click="dictionary:remove"
            phx-value-word={word}
            aria-label={"Remove #{word} from dictionary"}
            title={"Remove #{word}"}
            class={cn([
              "inline-flex h-5 w-5 shrink-0 items-center justify-center rounded transition-colors",
              "text-muted-foreground opacity-0 group-hover/word:opacity-100",
              "hover:bg-destructive/10 hover:text-destructive",
              "focus-visible:opacity-100 focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
            ])}
          >
            <svg
              class="h-3 w-3"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
              aria-hidden="true"
            >
              <line x1="18" y1="6" x2="6" y2="18" />
              <line x1="6" y1="6" x2="18" y2="18" />
            </svg>
          </button>
        </li>
      </ul>
    </div>
    """
  end

  # ── Helpers ──────────────────────────────────────────────────────────────────

  defp severity_icon(:error) do
    assigns = %{}

    ~H"""
    <svg
      class="h-4 w-4 text-red-500"
      viewBox="0 0 24 24"
      fill="currentColor"
      aria-hidden="true"
    >
      <circle cx="12" cy="12" r="10" opacity="0.15" />
      <circle cx="12" cy="12" r="10" fill="none" stroke="currentColor" stroke-width="2" />
      <line x1="15" y1="9" x2="9" y2="15" stroke="currentColor" stroke-width="2" stroke-linecap="round" />
      <line x1="9" y1="9" x2="15" y2="15" stroke="currentColor" stroke-width="2" stroke-linecap="round" />
    </svg>
    """
  end

  defp severity_icon(:warning) do
    assigns = %{}

    ~H"""
    <svg
      class="h-4 w-4 text-amber-500"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      aria-hidden="true"
    >
      <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z" />
      <line x1="12" y1="9" x2="12" y2="13" />
      <line x1="12" y1="17" x2="12.01" y2="17" />
    </svg>
    """
  end

  defp severity_icon(:info) do
    assigns = %{}

    ~H"""
    <svg
      class="h-4 w-4 text-blue-500"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      aria-hidden="true"
    >
      <circle cx="12" cy="12" r="10" />
      <line x1="12" y1="16" x2="12" y2="12" />
      <line x1="12" y1="8" x2="12.01" y2="8" />
    </svg>
    """
  end

  defp severity_icon(_), do: severity_icon(:info)

  defp severity_bar_class(:error), do: "bg-red-500"
  defp severity_bar_class(:warning), do: "bg-amber-500"
  defp severity_bar_class(:info), do: "bg-blue-500"
  defp severity_bar_class(_), do: "bg-blue-500"

  defp issue_count_class(issues) do
    has_errors = Enum.any?(issues, fn i -> i[:severity] == :error end)
    has_warnings = Enum.any?(issues, fn i -> i[:severity] == :warning end)

    cond do
      has_errors -> "bg-red-100 text-red-700 dark:bg-red-950/50 dark:text-red-300"
      has_warnings -> "bg-amber-100 text-amber-700 dark:bg-amber-950/50 dark:text-amber-300"
      true -> "bg-blue-100 text-blue-700 dark:bg-blue-950/50 dark:text-blue-300"
    end
  end
end
