defmodule PhiaUi.Components.Editor.AiAssistant do
  @moduledoc """
  AI Assistant Suite — 10 components for integrating AI capabilities into the
  PhiaUI rich text editor.

  These components provide the visual UI layer for AI-powered editing features.
  The actual AI logic is delegated to the `PhiaUi.Editor.AiBridge` behaviour,
  which users implement with their preferred LLM provider.

  ## Components

  ### Chat & Suggestions
  - `ai_sidebar/1`            — chat-like panel with message history + input
  - `ai_inline_suggestion/1`  — ghost text overlay for inline completions
  - `ai_autocomplete/1`       — dropdown suggestion list with keyboard nav

  ### Content Transformation
  - `ai_summary_card/1`       — card displaying AI-generated summary
  - `ai_rewrite_dialog/1`     — style-based rewriting with before/after preview
  - `ai_translate_dialog/1`   — language translation with source/target pickers
  - `ai_command_bar/1`        — sparkle-icon command input for freeform prompts

  ### Analysis & Scoring
  - `ai_tone_adjuster/1`      — range slider for formal ↔ casual tone
  - `ai_grammar_check/1`      — list of grammar suggestions with accept/dismiss
  - `ai_content_score/1`      — clarity/engagement/readability progress bars
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ============================================================================
  # 1. ai_sidebar/1
  # ============================================================================

  attr :id, :string, required: true
  attr :messages, :list, default: []
  attr :loading, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a chat-like AI assistant panel with message history and input.

  Each message in the `:messages` list should be a map with `:role` (`:user` or
  `:assistant`) and `:content` (string) keys.

  ## Example

      <.ai_sidebar id="ai-chat" messages={@ai_messages} loading={@ai_loading} />
  """
  def ai_sidebar(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn([
        "flex h-full flex-col rounded-xl border border-border bg-background shadow-sm",
        @class
      ])}
      {@rest}
    >
      <%!-- Header --%>
      <div class="flex items-center gap-2 border-b border-border px-4 py-3">
        <svg class="h-5 w-5 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M12 3l1.912 5.813L20 10l-4.856 3.396L16.824 19 12 15.6 7.176 19l1.68-5.604L4 10l6.088-1.187z" />
        </svg>
        <span class="text-sm font-semibold text-foreground">AI Assistant</span>
      </div>

      <%!-- Messages area --%>
      <div class="flex-1 space-y-3 overflow-y-auto px-4 py-3" id={"#{@id}-messages"}>
        <div
          :for={msg <- @messages}
          class={cn([
            "rounded-lg px-3 py-2 text-sm",
            msg_class(msg[:role] || msg["role"])
          ])}
        >
          <p class="whitespace-pre-wrap">{msg[:content] || msg["content"]}</p>
        </div>

        <div :if={@loading} class="flex items-center gap-2 px-3 py-2 text-sm text-muted-foreground">
          <span class="inline-flex gap-1">
            <span class="h-1.5 w-1.5 animate-bounce rounded-full bg-muted-foreground" style="animation-delay: 0ms" />
            <span class="h-1.5 w-1.5 animate-bounce rounded-full bg-muted-foreground" style="animation-delay: 150ms" />
            <span class="h-1.5 w-1.5 animate-bounce rounded-full bg-muted-foreground" style="animation-delay: 300ms" />
          </span>
          <span>Thinking...</span>
        </div>
      </div>

      <%!-- Input area --%>
      <div class="border-t border-border p-3">
        <form phx-submit="ai:send" phx-value-sidebar-id={@id} class="flex items-center gap-2">
          <input
            type="text"
            name="message"
            placeholder="Ask AI anything..."
            autocomplete="off"
            class="flex-1 rounded-lg border border-border bg-muted/30 px-3 py-2 text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-1 focus:ring-ring"
          />
          <button
            type="submit"
            class="inline-flex h-9 w-9 items-center justify-center rounded-lg bg-primary text-primary-foreground transition-colors hover:bg-primary/90 focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50"
            disabled={@loading}
          >
            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M22 2L11 13" /><path d="M22 2l-7 20-4-9-9-4z" />
            </svg>
          </button>
        </form>
      </div>
    </div>
    """
  end

  defp msg_class(:user), do: "ml-6 bg-primary/10 text-foreground"
  defp msg_class("user"), do: "ml-6 bg-primary/10 text-foreground"
  defp msg_class(:assistant), do: "mr-6 bg-muted text-foreground"
  defp msg_class("assistant"), do: "mr-6 bg-muted text-foreground"
  defp msg_class(_), do: "bg-muted text-foreground"

  # ============================================================================
  # 2. ai_inline_suggestion/1
  # ============================================================================

  attr :id, :string, required: true
  attr :suggestion, :string, default: ""
  attr :visible, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders an inline ghost-text suggestion overlay.

  The suggestion appears as dimmed text that the user can accept (Tab) or
  dismiss (Escape). Visibility is controlled by the `:visible` attr.

  ## Example

      <.ai_inline_suggestion id="ghost" suggestion="the quick brown fox" visible={@show_suggestion} />
  """
  def ai_inline_suggestion(assigns) do
    ~H"""
    <span
      id={@id}
      class={cn([
        "pointer-events-none select-none text-muted-foreground/50 transition-opacity duration-200",
        @visible && "opacity-100",
        !@visible && "opacity-0",
        @class
      ])}
      aria-hidden="true"
      {@rest}
    >{@suggestion}</span>
    """
  end

  # ============================================================================
  # 3. ai_summary_card/1
  # ============================================================================

  attr :id, :string, required: true
  attr :summary, :string, default: ""
  attr :loading, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a card displaying an AI-generated summary.

  Shows a loading skeleton when `:loading` is true, otherwise displays the
  summary text.

  ## Example

      <.ai_summary_card id="summary" summary={@ai_summary} loading={@summarizing} />
  """
  def ai_summary_card(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn([
        "rounded-xl border border-border bg-background p-4 shadow-sm",
        @class
      ])}
      {@rest}
    >
      <div class="mb-2 flex items-center gap-2">
        <svg class="h-4 w-4 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z" />
          <polyline points="14 2 14 8 20 8" />
          <line x1="16" y1="13" x2="8" y2="13" />
          <line x1="16" y1="17" x2="8" y2="17" />
          <polyline points="10 9 9 9 8 9" />
        </svg>
        <span class="text-sm font-semibold text-foreground">Summary</span>
      </div>

      <div :if={@loading} class="space-y-2">
        <div class="h-3 w-full animate-pulse rounded bg-muted" />
        <div class="h-3 w-4/5 animate-pulse rounded bg-muted" />
        <div class="h-3 w-3/5 animate-pulse rounded bg-muted" />
      </div>

      <p :if={!@loading} class="text-sm leading-relaxed text-muted-foreground">
        {@summary}
      </p>
    </div>
    """
  end

  # ============================================================================
  # 4. ai_rewrite_dialog/1
  # ============================================================================

  attr :id, :string, required: true
  attr :visible, :boolean, default: false
  attr :styles, :list, default: [:professional, :casual, :concise, :detailed, :creative]
  attr :selected_style, :atom, default: nil
  attr :original_text, :string, default: ""
  attr :rewritten_text, :string, default: ""
  attr :loading, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a dialog for AI-powered text rewriting with style selection.

  Displays a row of style buttons, the original text, and the rewritten result.
  The user selects a style which triggers a `phx-click="ai:rewrite"` event.

  ## Example

      <.ai_rewrite_dialog
        id="rewrite"
        visible={@show_rewrite}
        original_text={@selected_text}
        rewritten_text={@rewritten}
        selected_style={@rewrite_style}
        loading={@rewriting}
      />
  """
  def ai_rewrite_dialog(assigns) do
    ~H"""
    <div
      id={@id}
      :if={@visible}
      class={cn([
        "fixed inset-0 z-50 flex items-center justify-center bg-background/80 backdrop-blur-sm",
        @class
      ])}
      {@rest}
    >
      <div class="w-full max-w-2xl rounded-xl border border-border bg-background p-6 shadow-lg">
        <%!-- Header --%>
        <div class="mb-4 flex items-center justify-between">
          <div class="flex items-center gap-2">
            <svg class="h-5 w-5 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7" />
              <path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z" />
            </svg>
            <h3 class="text-base font-semibold text-foreground">Rewrite with AI</h3>
          </div>
          <button
            type="button"
            phx-click="ai:rewrite:close"
            phx-value-id={@id}
            class="inline-flex h-7 w-7 items-center justify-center rounded-md text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
          >
            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
            </svg>
          </button>
        </div>

        <%!-- Style buttons --%>
        <div class="mb-4 flex flex-wrap gap-2">
          <button
            :for={style <- @styles}
            type="button"
            phx-click="ai:rewrite"
            phx-value-style={style}
            phx-value-id={@id}
            class={cn([
              "rounded-full border px-3 py-1.5 text-xs font-medium transition-colors",
              style == @selected_style && "border-primary bg-primary text-primary-foreground",
              style != @selected_style && "border-border bg-background text-foreground hover:bg-muted"
            ])}
          >
            {style_label(style)}
          </button>
        </div>

        <%!-- Before / After --%>
        <div class="grid gap-4 sm:grid-cols-2">
          <div>
            <span class="mb-1 block text-xs font-medium text-muted-foreground">Original</span>
            <div class="rounded-lg border border-border bg-muted/30 p-3 text-sm text-foreground">
              {@original_text}
            </div>
          </div>
          <div>
            <span class="mb-1 block text-xs font-medium text-muted-foreground">Rewritten</span>
            <div class="rounded-lg border border-border bg-muted/30 p-3 text-sm text-foreground">
              <div :if={@loading} class="space-y-2">
                <div class="h-3 w-full animate-pulse rounded bg-muted" />
                <div class="h-3 w-4/5 animate-pulse rounded bg-muted" />
              </div>
              <span :if={!@loading}>{@rewritten_text}</span>
            </div>
          </div>
        </div>

        <%!-- Actions --%>
        <div class="mt-4 flex justify-end gap-2">
          <button
            type="button"
            phx-click="ai:rewrite:close"
            phx-value-id={@id}
            class="rounded-lg border border-border px-4 py-2 text-sm font-medium text-foreground transition-colors hover:bg-muted"
          >
            Cancel
          </button>
          <button
            type="button"
            phx-click="ai:rewrite:accept"
            phx-value-id={@id}
            disabled={@rewritten_text == "" || @loading}
            class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90 disabled:pointer-events-none disabled:opacity-50"
          >
            Accept
          </button>
        </div>
      </div>
    </div>
    """
  end

  defp style_label(:professional), do: "Professional"
  defp style_label(:casual), do: "Casual"
  defp style_label(:concise), do: "Concise"
  defp style_label(:detailed), do: "Detailed"
  defp style_label(:creative), do: "Creative"
  defp style_label(style), do: style |> to_string() |> String.capitalize()

  # ============================================================================
  # 5. ai_translate_dialog/1
  # ============================================================================

  attr :id, :string, required: true
  attr :visible, :boolean, default: false
  attr :languages, :list,
    default: ["English", "Spanish", "French", "German", "Portuguese", "Chinese", "Japanese"]
  attr :source_lang, :string, default: nil
  attr :target_lang, :string, default: nil
  attr :original_text, :string, default: ""
  attr :translated_text, :string, default: ""
  attr :loading, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a translation dialog with source/target language dropdowns and text areas.

  ## Example

      <.ai_translate_dialog
        id="translate"
        visible={@show_translate}
        original_text={@selected_text}
        translated_text={@translated}
        source_lang={@source_lang}
        target_lang={@target_lang}
        loading={@translating}
      />
  """
  def ai_translate_dialog(assigns) do
    ~H"""
    <div
      id={@id}
      :if={@visible}
      class={cn([
        "fixed inset-0 z-50 flex items-center justify-center bg-background/80 backdrop-blur-sm",
        @class
      ])}
      {@rest}
    >
      <div class="w-full max-w-2xl rounded-xl border border-border bg-background p-6 shadow-lg">
        <%!-- Header --%>
        <div class="mb-4 flex items-center justify-between">
          <div class="flex items-center gap-2">
            <svg class="h-5 w-5 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M5 8l6 6" /><path d="M4 14l6-6 2-3" /><path d="M2 5h12" /><path d="M7 2h1" />
              <path d="M22 22l-5-10-5 10" /><path d="M14 18h6" />
            </svg>
            <h3 class="text-base font-semibold text-foreground">Translate with AI</h3>
          </div>
          <button
            type="button"
            phx-click="ai:translate:close"
            phx-value-id={@id}
            class="inline-flex h-7 w-7 items-center justify-center rounded-md text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
          >
            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
            </svg>
          </button>
        </div>

        <%!-- Language selectors --%>
        <div class="mb-4 flex items-center gap-3">
          <div class="flex-1">
            <label for={"#{@id}-source"} class="mb-1 block text-xs font-medium text-muted-foreground">From</label>
            <select
              id={"#{@id}-source"}
              name="source_lang"
              phx-change="ai:translate:source"
              phx-value-id={@id}
              class="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
            >
              <option value="">Detect language</option>
              <option :for={lang <- @languages} value={lang} selected={@source_lang == lang}>{lang}</option>
            </select>
          </div>

          <div class="mt-5">
            <svg class="h-4 w-4 text-muted-foreground" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="9 18 15 12 9 6" />
            </svg>
          </div>

          <div class="flex-1">
            <label for={"#{@id}-target"} class="mb-1 block text-xs font-medium text-muted-foreground">To</label>
            <select
              id={"#{@id}-target"}
              name="target_lang"
              phx-change="ai:translate:target"
              phx-value-id={@id}
              class="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
            >
              <option value="">Select language</option>
              <option :for={lang <- @languages} value={lang} selected={@target_lang == lang}>{lang}</option>
            </select>
          </div>
        </div>

        <%!-- Text areas --%>
        <div class="grid gap-4 sm:grid-cols-2">
          <div>
            <span class="mb-1 block text-xs font-medium text-muted-foreground">Original</span>
            <div class="h-40 overflow-y-auto rounded-lg border border-border bg-muted/30 p-3 text-sm text-foreground">
              {@original_text}
            </div>
          </div>
          <div>
            <span class="mb-1 block text-xs font-medium text-muted-foreground">Translation</span>
            <div class="h-40 overflow-y-auto rounded-lg border border-border bg-muted/30 p-3 text-sm text-foreground">
              <div :if={@loading} class="space-y-2">
                <div class="h-3 w-full animate-pulse rounded bg-muted" />
                <div class="h-3 w-4/5 animate-pulse rounded bg-muted" />
                <div class="h-3 w-3/5 animate-pulse rounded bg-muted" />
              </div>
              <span :if={!@loading}>{@translated_text}</span>
            </div>
          </div>
        </div>

        <%!-- Actions --%>
        <div class="mt-4 flex justify-end gap-2">
          <button
            type="button"
            phx-click="ai:translate:close"
            phx-value-id={@id}
            class="rounded-lg border border-border px-4 py-2 text-sm font-medium text-foreground transition-colors hover:bg-muted"
          >
            Cancel
          </button>
          <button
            type="button"
            phx-click="ai:translate:run"
            phx-value-id={@id}
            disabled={@target_lang == nil || @target_lang == "" || @loading}
            class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90 disabled:pointer-events-none disabled:opacity-50"
          >
            Translate
          </button>
          <button
            type="button"
            phx-click="ai:translate:accept"
            phx-value-id={@id}
            disabled={@translated_text == "" || @loading}
            class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90 disabled:pointer-events-none disabled:opacity-50"
          >
            Accept
          </button>
        </div>
      </div>
    </div>
    """
  end

  # ============================================================================
  # 6. ai_command_bar/1
  # ============================================================================

  attr :id, :string, required: true
  attr :editor_id, :string, required: true
  attr :visible, :boolean, default: false
  attr :query, :string, default: ""
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a command bar input with a sparkle icon for freeform AI prompts.

  Hidden when `:visible` is false. The input fires `phx-submit="ai:command"`
  with the query text.

  ## Example

      <.ai_command_bar id="ai-cmd" editor_id="my-editor" visible={@show_ai_bar} />
  """
  def ai_command_bar(assigns) do
    ~H"""
    <div
      id={@id}
      :if={@visible}
      class={cn([
        "flex items-center gap-2 rounded-lg border border-primary/30 bg-background px-3 py-2 shadow-lg",
        @class
      ])}
      {@rest}
    >
      <svg class="h-4 w-4 shrink-0 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M12 3l1.912 5.813L20 10l-4.856 3.396L16.824 19 12 15.6 7.176 19l1.68-5.604L4 10l6.088-1.187z" />
      </svg>
      <form phx-submit="ai:command" phx-value-editor-id={@editor_id} class="flex-1">
        <input
          type="text"
          name="query"
          value={@query}
          placeholder="Ask AI to edit, generate, or transform..."
          autocomplete="off"
          class="w-full border-0 bg-transparent p-0 text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-0"
        />
      </form>
      <kbd class="hidden shrink-0 rounded border border-border bg-muted px-1.5 py-0.5 text-[10px] text-muted-foreground sm:inline-block">
        Esc
      </kbd>
    </div>
    """
  end

  # ============================================================================
  # 7. ai_autocomplete/1
  # ============================================================================

  attr :id, :string, required: true
  attr :suggestions, :list, default: []
  attr :visible, :boolean, default: false
  attr :selected_index, :integer, default: 0
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a dropdown list of AI autocomplete suggestions.

  Each suggestion is a string. The item at `:selected_index` is visually
  highlighted. Use arrow keys + Enter to navigate/accept.

  ## Example

      <.ai_autocomplete
        id="ai-complete"
        suggestions={@completions}
        visible={@show_completions}
        selected_index={@completion_index}
      />
  """
  def ai_autocomplete(assigns) do
    assigns = assign(assigns, :indexed_suggestions, Enum.with_index(assigns.suggestions))

    ~H"""
    <div
      id={@id}
      :if={@visible && @suggestions != []}
      class={cn([
        "absolute z-50 w-64 rounded-lg border border-border bg-popover py-1 shadow-lg",
        @class
      ])}
      role="listbox"
      {@rest}
    >
      <button
        :for={{suggestion, idx} <- @indexed_suggestions}
        type="button"
        role="option"
        aria-selected={to_string(idx == @selected_index)}
        phx-click="ai:autocomplete:select"
        phx-value-index={idx}
        phx-value-id={@id}
        class={cn([
          "flex w-full items-center px-3 py-1.5 text-left text-sm transition-colors",
          idx == @selected_index && "bg-accent text-accent-foreground",
          idx != @selected_index && "text-foreground hover:bg-muted"
        ])}
      >
        <svg class="mr-2 h-3 w-3 shrink-0 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M12 3l1.912 5.813L20 10l-4.856 3.396L16.824 19 12 15.6 7.176 19l1.68-5.604L4 10l6.088-1.187z" />
        </svg>
        <span class="truncate">{suggestion}</span>
      </button>
    </div>
    """
  end

  # ============================================================================
  # 8. ai_tone_adjuster/1
  # ============================================================================

  attr :id, :string, required: true
  attr :value, :integer, default: 50
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a range slider for adjusting tone from Formal (0) to Casual (100).

  Fires `phx-change="ai:tone"` with the slider value.

  ## Example

      <.ai_tone_adjuster id="tone" value={@tone_value} />
  """
  def ai_tone_adjuster(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn([
        "rounded-lg border border-border bg-background p-4",
        @class
      ])}
      {@rest}
    >
      <div class="mb-2 flex items-center justify-between">
        <span class="text-sm font-medium text-foreground">Tone</span>
        <span class="text-xs text-muted-foreground">{tone_label(@value)}</span>
      </div>
      <div class="flex items-center gap-3">
        <span class="text-xs text-muted-foreground">Formal</span>
        <input
          type="range"
          name="tone"
          min="0"
          max="100"
          value={@value}
          phx-change="ai:tone"
          phx-value-id={@id}
          class="h-2 flex-1 cursor-pointer appearance-none rounded-full bg-muted accent-primary"
        />
        <span class="text-xs text-muted-foreground">Casual</span>
      </div>
    </div>
    """
  end

  defp tone_label(v) when v <= 20, do: "Very Formal"
  defp tone_label(v) when v <= 40, do: "Formal"
  defp tone_label(v) when v <= 60, do: "Neutral"
  defp tone_label(v) when v <= 80, do: "Casual"
  defp tone_label(_), do: "Very Casual"

  # ============================================================================
  # 9. ai_grammar_check/1
  # ============================================================================

  attr :id, :string, required: true
  attr :suggestions, :list, default: []
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a list of grammar/style suggestions with accept/dismiss actions.

  Each item in `:suggestions` should be a map with `:text` (original),
  `:suggestion` (replacement), and `:type` (`:grammar`, `:spelling`, `:style`).

  ## Example

      <.ai_grammar_check
        id="grammar"
        suggestions={[
          %{text: "their", suggestion: "there", type: :grammar},
          %{text: "alot", suggestion: "a lot", type: :spelling}
        ]}
      />
  """
  def ai_grammar_check(assigns) do
    assigns = assign(assigns, :indexed_suggestions, Enum.with_index(assigns.suggestions))

    ~H"""
    <div
      id={@id}
      class={cn([
        "rounded-xl border border-border bg-background shadow-sm",
        @class
      ])}
      {@rest}
    >
      <div class="flex items-center gap-2 border-b border-border px-4 py-3">
        <svg class="h-4 w-4 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M12 20h9" /><path d="M16.5 3.5a2.121 2.121 0 013 3L7 19l-4 1 1-4L16.5 3.5z" />
        </svg>
        <span class="text-sm font-semibold text-foreground">Grammar Check</span>
        <span class="ml-auto text-xs text-muted-foreground">
          {length(@suggestions)} {if length(@suggestions) == 1, do: "issue", else: "issues"}
        </span>
      </div>

      <div :if={@suggestions == []} class="px-4 py-6 text-center text-sm text-muted-foreground">
        No issues found. Your text looks great!
      </div>

      <ul :if={@suggestions != []} class="divide-y divide-border">
        <li :for={{item, idx} <- @indexed_suggestions} class="flex items-start gap-3 px-4 py-3">
          <span class={cn([
            "mt-0.5 inline-flex rounded-full px-1.5 py-0.5 text-[10px] font-medium",
            grammar_badge_class(item[:type] || item["type"])
          ])}>
            {grammar_type_label(item[:type] || item["type"])}
          </span>
          <div class="min-w-0 flex-1">
            <p class="text-sm text-foreground">
              <span class="line-through text-muted-foreground">{item[:text] || item["text"]}</span>
              <svg class="mx-1 inline h-3 w-3 text-muted-foreground" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="9 18 15 12 9 6" />
              </svg>
              <span class="font-medium text-primary">{item[:suggestion] || item["suggestion"]}</span>
            </p>
          </div>
          <div class="flex shrink-0 gap-1">
            <button
              type="button"
              phx-click="ai:grammar:accept"
              phx-value-index={idx}
              phx-value-id={@id}
              class="inline-flex h-6 w-6 items-center justify-center rounded text-green-600 transition-colors hover:bg-green-100 dark:hover:bg-green-900/30"
              aria-label="Accept suggestion"
            >
              <svg class="h-3.5 w-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="20 6 9 17 4 12" />
              </svg>
            </button>
            <button
              type="button"
              phx-click="ai:grammar:dismiss"
              phx-value-index={idx}
              phx-value-id={@id}
              class="inline-flex h-6 w-6 items-center justify-center rounded text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
              aria-label="Dismiss suggestion"
            >
              <svg class="h-3.5 w-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
              </svg>
            </button>
          </div>
        </li>
      </ul>
    </div>
    """
  end

  defp grammar_badge_class(:grammar), do: "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-400"
  defp grammar_badge_class("grammar"), do: grammar_badge_class(:grammar)
  defp grammar_badge_class(:spelling), do: "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400"
  defp grammar_badge_class("spelling"), do: grammar_badge_class(:spelling)
  defp grammar_badge_class(:style), do: "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400"
  defp grammar_badge_class("style"), do: grammar_badge_class(:style)
  defp grammar_badge_class(_), do: "bg-muted text-muted-foreground"

  defp grammar_type_label(:grammar), do: "Grammar"
  defp grammar_type_label("grammar"), do: "Grammar"
  defp grammar_type_label(:spelling), do: "Spelling"
  defp grammar_type_label("spelling"), do: "Spelling"
  defp grammar_type_label(:style), do: "Style"
  defp grammar_type_label("style"), do: "Style"
  defp grammar_type_label(_), do: "Issue"

  # ============================================================================
  # 10. ai_content_score/1
  # ============================================================================

  attr :id, :string, required: true
  attr :scores, :map, default: %{}
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders three labeled progress bars for content quality scores.

  Expects `:scores` to be a map with optional keys `:clarity`, `:engagement`,
  and `:readability`, each 0-100.

  ## Example

      <.ai_content_score
        id="score"
        scores={%{clarity: 85, engagement: 72, readability: 91}}
      />
  """
  def ai_content_score(assigns) do
    assigns =
      assigns
      |> assign(:clarity, Map.get(assigns.scores, :clarity, Map.get(assigns.scores, "clarity", 0)))
      |> assign(:engagement, Map.get(assigns.scores, :engagement, Map.get(assigns.scores, "engagement", 0)))
      |> assign(:readability, Map.get(assigns.scores, :readability, Map.get(assigns.scores, "readability", 0)))

    ~H"""
    <div
      id={@id}
      class={cn([
        "rounded-xl border border-border bg-background p-4 shadow-sm",
        @class
      ])}
      {@rest}
    >
      <div class="mb-3 flex items-center gap-2">
        <svg class="h-4 w-4 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M22 12h-4l-3 9L9 3l-3 9H2" />
        </svg>
        <span class="text-sm font-semibold text-foreground">Content Score</span>
        <span class="ml-auto text-xs text-muted-foreground">
          {overall_score(@clarity, @engagement, @readability)}/100
        </span>
      </div>

      <div class="space-y-3">
        <.score_bar label="Clarity" value={@clarity} />
        <.score_bar label="Engagement" value={@engagement} />
        <.score_bar label="Readability" value={@readability} />
      </div>
    </div>
    """
  end

  attr :label, :string, required: true
  attr :value, :integer, required: true

  defp score_bar(assigns) do
    ~H"""
    <div>
      <div class="mb-1 flex items-center justify-between">
        <span class="text-xs text-muted-foreground">{@label}</span>
        <span class={cn([
          "text-xs font-medium",
          score_text_class(@value)
        ])}>{@value}</span>
      </div>
      <div class="h-1.5 w-full overflow-hidden rounded-full bg-muted">
        <div
          class={cn(["h-full rounded-full transition-all duration-500", score_bar_class(@value)])}
          style={"width: #{min(@value, 100)}%"}
        />
      </div>
    </div>
    """
  end

  defp overall_score(c, e, r) do
    total = c + e + r
    if total == 0, do: 0, else: div(total, 3)
  end

  defp score_bar_class(v) when v >= 80, do: "bg-green-500"
  defp score_bar_class(v) when v >= 60, do: "bg-yellow-500"
  defp score_bar_class(v) when v >= 40, do: "bg-orange-500"
  defp score_bar_class(_), do: "bg-red-500"

  defp score_text_class(v) when v >= 80, do: "text-green-600 dark:text-green-400"
  defp score_text_class(v) when v >= 60, do: "text-yellow-600 dark:text-yellow-400"
  defp score_text_class(v) when v >= 40, do: "text-orange-600 dark:text-orange-400"
  defp score_text_class(_), do: "text-red-600 dark:text-red-400"
end
