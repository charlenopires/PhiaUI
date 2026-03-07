defmodule PhiaUi.Components.FeedbackWidget do
  @moduledoc """
  Micro-feedback collection components for gathering quick user feedback
  without interrupting the user's workflow.

  Inspired by Notion's page reactions, GitHub's "Was this helpful?" pattern,
  Intercom's CSAT survey, and Linear's NPS widget.

  Pure HEEx — no JavaScript hooks required. All state managed server-side
  via LiveView assigns and phx-click events.

  ## Sub-components

  | Component              | Purpose                                                      |
  |------------------------|--------------------------------------------------------------|
  | `feedback_thumb/1`     | Single thumbs-up "Was this helpful?" button                  |
  | `feedback_reaction/1`  | Emoji/icon reaction bar (👍 ❤️ 😂 😮 😢 😡)                  |
  | `feedback_nps/1`       | Net Promoter Score 0–10 scale widget                         |
  | `feedback_survey_card/1`| "Was this helpful?" card with Yes/No and optional comment    |

  ## Thumbs up (docs helpful)

      <.feedback_thumb
        helpful={@page_helpful}
        count={@helpful_count}
        phx-click="toggle_helpful"
      />

  ## Emoji reactions

      <.feedback_reaction
        reactions={@reactions}
        current_reaction={@my_reaction}
        phx-value-reaction="..."
        phx-click="react"
      />

  ## NPS score

      <.feedback_nps
        selected={@nps_score}
        phx-click="submit_nps"
        phx-value-score="..."
      />

  ## Survey card

      <.feedback_survey_card
        :if={!@feedback_submitted}
        title="Was this article helpful?"
        phx-click-yes="feedback_yes"
        phx-click-no="feedback_no"
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # feedback_thumb/1
  # ---------------------------------------------------------------------------

  attr(:helpful, :boolean,
    default: false,
    doc: "Whether the current user has marked as helpful."
  )

  attr(:count, :integer,
    default: nil,
    doc: "Optional count of people who found it helpful."
  )

  attr(:label, :string,
    default: "Helpful",
    doc: "Button label text."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attrs forwarded to the `<button>`.")

  @doc """
  Renders a single "thumbs up / helpful" feedback button.

  Commonly used at the bottom of documentation pages, support articles,
  and knowledge base entries. State is toggled server-side via `phx-click`.

  ## Example

      <.feedback_thumb helpful={@helpful} count={@count} phx-click="toggle_helpful" />
  """
  def feedback_thumb(assigns) do
    ~H"""
    <button
      type="button"
      aria-pressed={to_string(@helpful)}
      aria-label={if @helpful, do: "Remove helpful vote", else: "Mark as helpful"}
      class={cn([
        "inline-flex items-center gap-2 rounded-full px-3 py-1.5 text-sm font-medium",
        "border transition-colors duration-150",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-1",
        @helpful && "bg-primary/10 border-primary/30 text-primary",
        !@helpful && "bg-transparent border-border text-muted-foreground hover:bg-accent hover:text-accent-foreground",
        @class
      ])}
      {@rest}
    >
      <.icon
        name={if @helpful, do: "thumbs-up", else: "thumbs-up"}
        class={cn(["h-4 w-4", @helpful && "fill-primary"])}
        aria-hidden="true"
      />
      <span>{@label}</span>
      <span :if={@count} class="tabular-nums">{@count}</span>
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # feedback_reaction/1
  # ---------------------------------------------------------------------------

  attr(:reactions, :list,
    default: [],
    doc: """
    List of reaction maps. Each map:
    - `:emoji` (string) — the emoji character or label
    - `:count` (integer) — current count
    - `:value` (string) — value sent as phx-value-reaction

    Example: `[%{emoji: "👍", count: 12, value: "like"}]`
    """
  )

  attr(:current_reaction, :string,
    default: nil,
    doc: "The `:value` of the reaction the current user has selected (if any)."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attrs forwarded to the wrapper `<div>`. Add `phx-click` here.")

  @doc """
  Renders an emoji reaction bar.

  Each reaction button shows the emoji + count. The active reaction (matching
  `:current_reaction`) is highlighted. Wire `phx-click` and `phx-value-reaction`
  at the wrapper level for event delegation.

  ## Example

      <.feedback_reaction
        reactions={[
          %{emoji: "👍", count: 14, value: "like"},
          %{emoji: "❤️", count: 7, value: "love"},
          %{emoji: "😂", count: 3, value: "laugh"},
          %{emoji: "😮", count: 2, value: "wow"}
        ]}
        current_reaction={@my_reaction}
        phx-click="react"
      />
  """
  def feedback_reaction(assigns) do
    ~H"""
    <div class={cn(["inline-flex flex-wrap gap-1.5", @class])} {@rest}>
      <button
        :for={reaction <- @reactions}
        type="button"
        phx-value-reaction={reaction.value}
        aria-pressed={to_string(@current_reaction == reaction.value)}
        aria-label={"React with #{reaction.emoji}: #{reaction.count} reactions"}
        class={cn([
          "inline-flex items-center gap-1 rounded-full px-2.5 py-1 text-sm",
          "border transition-all duration-100",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
          "hover:scale-105 active:scale-95",
          @current_reaction == reaction.value &&
            "bg-primary/10 border-primary/30 font-medium",
          @current_reaction != reaction.value &&
            "bg-muted/50 border-border hover:bg-accent"
        ])}
      >
        <span aria-hidden="true">{reaction.emoji}</span>
        <span class="tabular-nums text-xs text-muted-foreground">{reaction.count}</span>
      </button>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # feedback_nps/1
  # ---------------------------------------------------------------------------

  attr(:selected, :any,
    default: nil,
    doc: "Currently selected score (0–10), or `nil` if not yet answered."
  )

  attr(:question, :string,
    default: "How likely are you to recommend us to a friend?",
    doc: "The NPS question displayed above the scale."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attrs forwarded to the wrapper. Add `phx-click` here.")

  @doc """
  Renders a Net Promoter Score (NPS) 0–10 rating widget.

  Wire `phx-click` and `phx-value-score` at the wrapper level or on each button.
  Scores 0–6 are Detractors (red), 7–8 Passives (amber), 9–10 Promoters (green).

  ## Example

      <.feedback_nps
        question="How likely are you to recommend PhiaUI?"
        selected={@nps_score}
        phx-click="submit_nps"
      />

      # LiveView handler
      def handle_event("submit_nps", %{"score" => score}, socket) do
        {:noreply, assign(socket, nps_score: String.to_integer(score))}
      end
  """
  def feedback_nps(assigns) do
    ~H"""
    <div class={cn(["w-full space-y-4", @class])} {@rest}>
      <p class="text-sm font-medium text-foreground text-center">{@question}</p>
      <div class="flex justify-between gap-1" role="radiogroup" aria-label="NPS score">
        <button
          :for={score <- 0..10}
          type="button"
          role="radio"
          aria-checked={to_string(@selected == score)}
          phx-value-score={score}
          aria-label={"Score #{score}"}
          class={cn([
            "flex-1 rounded-md py-2 text-sm font-medium transition-all duration-100",
            "border focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
            "hover:scale-105 active:scale-95",
            @selected == score && nps_selected_class(score),
            @selected != score && "bg-muted/50 border-border text-muted-foreground hover:bg-accent hover:text-accent-foreground"
          ])}
        >
          {score}
        </button>
      </div>
      <div class="flex justify-between text-xs text-muted-foreground">
        <span>Not likely</span>
        <span>Extremely likely</span>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # feedback_survey_card/1
  # ---------------------------------------------------------------------------

  attr(:title, :string,
    default: "Was this helpful?",
    doc: "Survey question displayed as the card title."
  )

  attr(:description, :string,
    default: nil,
    doc: "Optional sub-text below the title."
  )

  attr(:yes_label, :string, default: "Yes", doc: "Label for the positive response.")
  attr(:no_label, :string, default: "No", doc: "Label for the negative response.")

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attrs forwarded to the card `<div>`.")

  slot(:after_answer,
    doc: "Content to render after the user answers (e.g. thank-you message). Wire using `:if`."
  )

  @doc """
  Renders a compact "Was this helpful?" survey card.

  Provides Yes/No buttons with `phx-click-yes` and `phx-click-no` support.
  Combine with a LiveView assign to swap the card content after answering.

  ## Example

      <.feedback_survey_card
        :if={!@feedback_submitted}
        title="Was this article helpful?"
        phx-click-yes="feedback_yes"
        phx-click-no="feedback_no"
      />
      <div :if={@feedback_submitted} class="text-sm text-muted-foreground text-center py-4">
        Thank you for your feedback!
      </div>
  """
  def feedback_survey_card(assigns) do
    yes_event = Map.get(assigns.rest, :"phx-click-yes") || Map.get(assigns.rest, :phx_click_yes)
    no_event = Map.get(assigns.rest, :"phx-click-no") || Map.get(assigns.rest, :phx_click_no)

    rest =
      assigns.rest
      |> Map.drop([:"phx-click-yes", :"phx-click-no", :phx_click_yes, :phx_click_no])

    assigns = assign(assigns, yes_event: yes_event, no_event: no_event, clean_rest: rest)

    ~H"""
    <div
      class={cn([
        "inline-flex flex-col items-center gap-3 rounded-lg border border-border bg-card p-4 text-center shadow-sm",
        @class
      ])}
      {@clean_rest}
    >
      <div>
        <p class="text-sm font-medium text-foreground">{@title}</p>
        <p :if={@description} class="mt-0.5 text-xs text-muted-foreground">{@description}</p>
      </div>
      <div class="flex items-center gap-2">
        <button
          type="button"
          phx-click={@yes_event}
          aria-label={@yes_label}
          class={cn([
            "inline-flex items-center gap-1.5 rounded-md border border-border px-3 py-1.5",
            "text-sm font-medium text-foreground hover:bg-success/10 hover:border-success/30 hover:text-success",
            "transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
          ])}
        >
          <.icon name="thumbs-up" class="h-4 w-4" />
          {@yes_label}
        </button>
        <button
          type="button"
          phx-click={@no_event}
          aria-label={@no_label}
          class={cn([
            "inline-flex items-center gap-1.5 rounded-md border border-border px-3 py-1.5",
            "text-sm font-medium text-foreground hover:bg-destructive/10 hover:border-destructive/30 hover:text-destructive",
            "transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
          ])}
        >
          <.icon name="thumbs-down" class="h-4 w-4" />
          {@no_label}
        </button>
      </div>
      <div :if={@after_answer != []}>{render_slot(@after_answer)}</div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # NPS color: 0-6 = detractor (red), 7-8 = passive (amber), 9-10 = promoter (green)
  defp nps_selected_class(score) when score <= 6,
    do: "bg-destructive/10 border-destructive/40 text-destructive font-semibold"

  defp nps_selected_class(score) when score <= 8,
    do: "bg-warning/10 border-warning/40 text-warning font-semibold"

  defp nps_selected_class(_score),
    do: "bg-success/10 border-success/40 text-success font-semibold"
end
