defmodule PhiaUi.Components.ChatMessage do
  @moduledoc """
  Chat interface components for PhiaUI.

  Provides a complete AI/human chat UI: a scrollable message log, individual
  message rows aligned by role, styled content bubbles with optional avatars
  and feedback buttons, clickable suggestion chips, and a compose form.

  CSS-only layout — no JS hook required. Fully compatible with LiveView
  streams for real-time message delivery, including streaming AI token output.

  ## When to use

  - AI assistant chat (GPT-style, Anthropic Claude, etc.)
  - Customer support live chat embedded in an app
  - Team messaging feed within a product

  ## Anatomy

  | Component           | Element | Purpose                                        |
  |---------------------|---------|------------------------------------------------|
  | `chat_container/1`  | `div`   | Scrollable log (`role="log"`, live region)     |
  | `chat_message/1`    | `div`   | A message row, aligned by `:role`              |
  | `chat_bubble/1`     | `div`   | Styled content balloon with optional avatar    |
  | `chat_suggestions/1`| `div`   | Row of suggestion chips below an AI message    |
  | `chat_input/1`      | `form`  | Bottom compose form with `phx-submit`          |

  ## Role alignment

  | Role        | Alignment | Background            |
  |-------------|-----------|------------------------|
  | `user`      | Right      | `bg-primary`          |
  | `assistant` | Left       | `bg-muted`            |
  | `system`    | Center     | transparent, italic   |

  ## Minimal chat example

      <.chat_container id="ai-chat" class="h-96 p-4">
        <.chat_message role="assistant">
          <.chat_bubble role="assistant" timestamp="2:30 PM">
            Welcome! How can I help you today?
          </.chat_bubble>
          <.chat_suggestions
            suggestions={["Show me an example", "What can you do?"]}
            on_select="select_suggestion"
          />
        </.chat_message>

        <.chat_message role="user">
          <.chat_bubble role="user" timestamp="2:31 PM">
            Show me an example
          </.chat_bubble>
        </.chat_message>
      </.chat_container>

      <.chat_input id="chat-compose" on_submit="send_message" placeholder="Ask anything..." />

  ## Full AI assistant with LiveView streams

  Using streams means only new messages are DOM-patched; the full message list
  is never re-rendered, which is critical for long conversations.

      # LiveView mount/3 — initialise the stream
      def mount(_params, _session, socket) do
        {:ok, stream(socket, :messages, initial_messages())}
      end

      # Push a new AI message (e.g. from a Task or GenServer)
      def handle_info({:ai_message, msg}, socket) do
        {:noreply, stream_insert(socket, :messages, msg)}
      end

      # Template
      <.chat_container id="ai-chat" class="flex-1 overflow-y-auto p-4">
        <.chat_message
          :for={{dom_id, msg} <- @streams.messages}
          id={dom_id}
          role={msg.role}
        >
          <.chat_bubble
            role={msg.role}
            timestamp={Calendar.strftime(msg.inserted_at, "%I:%M %p")}
            on_feedback={if msg.role == "assistant", do: "rate_message"}
            message_id={msg.id}
          >
            <:avatar :if={msg.role == "assistant"}>
              <.avatar size="sm">
                <.avatar_fallback name="AI" />
              </.avatar>
            </:avatar>
            {msg.content}
          </.chat_bubble>
        </.chat_message>
      </.chat_container>

      <.chat_input
        id="chat-compose"
        on_submit="send_message"
        placeholder="Type a message..."
        max_chars={2000}
      />

  ## Streaming AI token output

  For token-by-token streaming responses, `stream_insert/4` with `at: -1`
  updates the last message in-place via LiveView's morphdom patching:

      def handle_info({:token, token}, socket) do
        # Append the token to the last AI message in your stream
        {:noreply, stream_insert(socket, :messages, updated_message, at: -1)}
      end
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # chat_container/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    default: nil,
    doc: """
    DOM id for the container. Recommended when using LiveView streams so the
    engine can locate and patch individual messages efficiently.
    """
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes for the scroll container (e.g. `h-96 overflow-y-auto`)"
  )

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the root div"
  )

  slot(:inner_block, required: true, doc: "`chat_message/1` children")

  @doc """
  Renders the chat log scroll container.

  Sets `role="log"` and `aria-live="polite"` so screen readers announce new
  messages as they arrive via LiveView streams without interrupting the user's
  current focus or reading flow.

  Apply a fixed height and `overflow-y-auto` via `:class` to make the log
  scrollable within a fixed layout region:

      <.chat_container id="chat" class="h-[600px] overflow-y-auto p-4">
        ...
      </.chat_container>
  """
  def chat_container(assigns) do
    ~H"""
    <div
      id={@id}
      role="log"
      aria-live="polite"
      aria-label="Chat messages"
      class={cn(["flex flex-col gap-4 overflow-y-auto", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # chat_message/1
  # ---------------------------------------------------------------------------

  attr(:role, :string,
    required: true,
    values: ~w(user assistant system),
    doc: """
    Message role — controls horizontal alignment:
    - `user`      → right-aligned (`items-end`)
    - `assistant` → left-aligned (`items-start`)
    - `system`    → centered (`items-center`)
    """
  )

  attr(:id, :string,
    default: nil,
    doc: "DOM id — required when using LiveView streams (pass `dom_id` from stream tuple)"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the message wrapper")

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the message wrapper div"
  )

  slot(:inner_block,
    required: true,
    doc: "`chat_bubble/1` and/or `chat_suggestions/1` children"
  )

  @doc """
  Renders a message row with role-based alignment.

  Alignment is determined by `:role`:
  - `user` → `items-end` (right side, mirroring human side of a conversation)
  - `assistant` → `items-start` (left side, mirroring AI/agent side)
  - `system` → `items-center` (centered, for notices like "Session started")
  """
  def chat_message(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn(["flex w-full flex-col gap-2", message_alignment(@role), @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # chat_bubble/1
  # ---------------------------------------------------------------------------

  attr(:role, :string,
    required: true,
    values: ~w(user assistant system),
    doc: "Bubble role — controls background colour and text colour"
  )

  attr(:timestamp, :string,
    default: nil,
    doc: ~s(Optional time label rendered beneath the bubble, e.g. "2:34 PM".)
  )

  attr(:on_feedback, :string,
    default: nil,
    doc: """
    `phx-click` event name for thumbs up/down feedback buttons.
    Only rendered for `role="assistant"` bubbles.
    Pair with `:message_id` to identify which message received feedback.
    """
  )

  attr(:message_id, :string,
    default: nil,
    doc: """
    ID passed as `phx-value-message-id` to feedback buttons.
    The LiveView receives `%{"message_id" => id, "feedback" => "up" | "down"}`.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the bubble wrapper")

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the bubble wrapper div"
  )

  slot(:avatar,
    doc: """
    Optional `avatar/1` component displayed beside the bubble.
    For `role="assistant"` the avatar appears on the left;
    for `role="user"` it appears on the right (matching message alignment).
    """
  )

  slot(:inner_block,
    required: true,
    doc: """
    Bubble text content. May include inline HTML or Markdown-rendered content.
    For streaming AI output, update this via `stream_insert/4`.
    """
  )

  @doc """
  Renders the styled chat content balloon.

  - `role="user"` — `bg-primary text-primary-foreground` (right-aligned)
  - `role="assistant"` — `bg-muted text-foreground` (left-aligned)
  - `role="system"` — transparent, italic, centered small text

  Supply an `:avatar` slot to show a user or AI avatar beside the bubble.
  Set `on_feedback` + `message_id` to enable thumbs up/down rating buttons
  for assistant responses (common in AI assistant UIs for RLHF collection).

  ## Example — assistant bubble with avatar and feedback

      <.chat_bubble
        role="assistant"
        timestamp="2:34 PM"
        on_feedback="rate_message"
        message_id={msg.id}
      >
        <:avatar>
          <.avatar size="sm"><.avatar_fallback name="AI" /></.avatar>
        </:avatar>
        The capital of France is Paris.
      </.chat_bubble>
  """
  def chat_bubble(assigns) do
    ~H"""
    <div class={cn(["flex items-end gap-2", bubble_wrapper_class(@role), @class])} {@rest}>
      <%!-- Avatar on the left side for assistant messages --%>
      <span :if={@avatar != [] and @role == "assistant"} class="shrink-0 self-end">
        {render_slot(@avatar)}
      </span>

      <div class={cn(["flex flex-col gap-1", bubble_column_align(@role)])}>
        <%!-- The actual speech bubble --%>
        <div class={cn(["rounded-2xl px-4 py-2.5 text-sm", bubble_bg(@role)])}>
          {render_slot(@inner_block)}
        </div>

        <%!-- Footer: timestamp + optional thumbs up/down feedback (assistant only) --%>
        <div
          :if={@timestamp || (@on_feedback && @role == "assistant")}
          class={cn(["flex items-center gap-2", bubble_footer_align(@role)])}
        >
          <span :if={@timestamp} class="text-xs text-muted-foreground">
            {@timestamp}
          </span>

          <%!-- Feedback buttons — only shown for assistant messages --%>
          <div
            :if={@on_feedback && @role == "assistant"}
            class="flex items-center gap-1"
          >
            <button
              type="button"
              phx-click={@on_feedback}
              phx-value-message-id={@message_id}
              phx-value-feedback="up"
              aria-label="Thumbs up"
              class="rounded p-0.5 text-muted-foreground hover:text-foreground transition-colors"
            >
              <.icon name="thumbs-up" size={:xs} />
            </button>
            <button
              type="button"
              phx-click={@on_feedback}
              phx-value-message-id={@message_id}
              phx-value-feedback="down"
              aria-label="Thumbs down"
              class="rounded p-0.5 text-muted-foreground hover:text-foreground transition-colors"
            >
              <.icon name="thumbs-down" size={:xs} />
            </button>
          </div>
        </div>
      </div>

      <%!-- Avatar on the right side for user messages --%>
      <span :if={@avatar != [] and @role == "user"} class="shrink-0 self-end">
        {render_slot(@avatar)}
      </span>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # chat_suggestions/1
  # ---------------------------------------------------------------------------

  attr(:suggestions, :list,
    required: true,
    doc: """
    List of suggestion strings shown as clickable pill buttons below an
    assistant bubble. Typically 2–4 concise prompts that guide the user.
    """
  )

  attr(:on_select, :string,
    required: true,
    doc: """
    `phx-click` event emitted when a suggestion is selected.
    The LiveView receives `%{"suggestion" => text}`.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the suggestions row")

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the wrapper div"
  )

  @doc """
  Renders a row of clickable conversation suggestion chips.

  Each chip fires `on_select` with `phx-value-suggestion` set to the chip text.
  Render these below an assistant bubble to help users discover common queries.

  ## Example

      <.chat_suggestions
        suggestions={["Tell me more", "Show an example", "How does billing work?"]}
        on_select="select_suggestion"
      />

      # LiveView handler
      def handle_event("select_suggestion", %{"suggestion" => text}, socket) do
        # Treat the suggestion as if the user typed and sent it
        {:noreply, send_user_message(socket, text)}
      end
  """
  def chat_suggestions(assigns) do
    ~H"""
    <div class={cn(["flex flex-wrap gap-2", @class])} {@rest}>
      <button
        :for={suggestion <- @suggestions}
        type="button"
        phx-click={@on_select}
        phx-value-suggestion={suggestion}
        class={cn([
          "rounded-full border border-border bg-background px-3 py-1.5",
          "text-sm text-foreground hover:bg-muted transition-colors",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
        ])}
      >
        {suggestion}
      </button>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # chat_input/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "DOM id for the form element")

  attr(:on_submit, :string,
    required: true,
    doc: """
    `phx-submit` event name. The LiveView receives `%{"message" => text}`.
    After handling, reset the textarea with `Phoenix.LiveView.push_event/3`
    or by clearing the assign that controls the input value.
    """
  )

  attr(:placeholder, :string,
    default: "Type a message...",
    doc: "Textarea placeholder text"
  )

  attr(:max_chars, :integer,
    default: nil,
    doc: """
    Optional character limit displayed as a static counter below the textarea.
    Note: actual enforcement must be done server-side in the LiveView handler.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the form wrapper")

  attr(:rest, :global,
    include: ~w(phx-change),
    doc: "HTML attributes forwarded to the form element"
  )

  slot(:attachments,
    doc: """
    Optional attachment chips rendered above the textarea.
    Use `badge/1` or custom chips to show files the user has attached.
    """
  )

  @doc """
  Renders the chat compose form.

  The form fires `on_submit` via `phx-submit`. A `max_chars` counter is
  displayed when provided. Attachment chips (e.g. file uploads) can be rendered
  above the textarea via the `:attachments` slot.

  ## Example

      <.chat_input
        id="chat-compose"
        on_submit="send_message"
        placeholder="Ask me anything..."
        max_chars={4000}
        phx-change="typing"
      >
        <:attachments>
          <.badge :for={file <- @pending_attachments} variant="outline">
            <.icon name="paperclip" size={:xs} />
            {file.name}
          </.badge>
        </:attachments>
      </.chat_input>
  """
  def chat_input(assigns) do
    ~H"""
    <form
      id={@id}
      phx-submit={@on_submit}
      class={cn(["flex flex-col gap-2 rounded-xl border border-input bg-background p-3", @class])}
      {@rest}
    >
      <%!-- Attachment chips above the textarea --%>
      <div :if={@attachments != []} class="flex flex-wrap gap-1">
        {render_slot(@attachments)}
      </div>

      <%!-- Auto-growing textarea; rows="2" gives a comfortable default height --%>
      <textarea
        name="message"
        rows="2"
        placeholder={@placeholder}
        class={cn([
          "w-full resize-none bg-transparent text-sm text-foreground",
          "placeholder:text-muted-foreground focus:outline-none"
        ])}
      />

      <%!-- Footer: optional char counter on the left + submit button on the right --%>
      <div class="flex items-center justify-between">
        <span :if={@max_chars} class="text-xs text-muted-foreground">
          {@max_chars}
        </span>
        <button
          type="submit"
          class={cn([
            "ml-auto rounded-lg bg-primary px-4 py-1.5 text-sm font-medium",
            "text-primary-foreground hover:bg-primary/90 transition-colors",
            "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
          ])}
        >
          Send
        </button>
      </div>
    </form>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers — pure pattern-matched functions
  # ---------------------------------------------------------------------------

  # Message row alignment inside the flex column container.
  defp message_alignment("user"), do: "items-end"
  defp message_alignment("assistant"), do: "items-start"
  defp message_alignment("system"), do: "items-center"

  # Bubble wrapper flex direction (affects avatar + bubble ordering).
  defp bubble_wrapper_class("user"), do: "justify-end"
  defp bubble_wrapper_class("assistant"), do: "justify-start"
  defp bubble_wrapper_class("system"), do: "justify-center"

  # Align the inner column (bubble + footer) to match its side.
  defp bubble_column_align("user"), do: "items-end"
  defp bubble_column_align("assistant"), do: "items-start"
  defp bubble_column_align("system"), do: "items-center"

  # Footer row alignment (timestamp + feedback) mirrors the bubble.
  defp bubble_footer_align("user"), do: "justify-end"
  defp bubble_footer_align("assistant"), do: "justify-start"
  defp bubble_footer_align("system"), do: "justify-center"

  # Background and text colour for each role.
  # System messages are intentionally minimal to not compete with chat content.
  defp bubble_bg("user"), do: "bg-primary text-primary-foreground"
  defp bubble_bg("assistant"), do: "bg-muted text-foreground"
  defp bubble_bg("system"), do: "text-xs text-muted-foreground italic"
end
