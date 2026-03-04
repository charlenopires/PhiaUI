defmodule PhiaUi.Components.ChatMessage do
  @moduledoc """
  Chat interface components for PhiaUI.

  Provides a complete AI/human chat UI: a scrollable log container, individual
  message rows with role-based alignment, content bubbles with optional avatar
  and feedback buttons, clickable suggestion chips, and a submit form.

  CSS-only layout. Streams-compatible for real-time message delivery.

  ## Sub-components

  - `chat_container/1` — root scroll area (`role="log"`, `aria-live="polite"`)
  - `chat_message/1` — a message row, aligned by `:role`
  - `chat_bubble/1` — the styled content balloon with optional avatar and feedback
  - `chat_suggestions/1` — row of clickable suggestion buttons
  - `chat_input/1` — bottom compose form with `phx-submit`

  ## Roles

  | Role        | Alignment    | Background              |
  |------------|-------------|-------------------------|
  | `user`      | Right        | `bg-primary`            |
  | `assistant` | Left         | `bg-muted`              |
  | `system`    | Center       | transparent, `text-xs`  |

  ## Examples

      <.chat_container id="ai-chat">
        <.chat_message role="assistant" id={dom_id}>
          <.chat_bubble role="assistant" timestamp="2:30 PM">
            <:avatar>
              <.avatar size="sm"><.avatar_fallback name="AI" /></.avatar>
            </:avatar>
            Welcome! How can I help you today?
          </.chat_bubble>
          <.chat_suggestions
            suggestions={["Key features?", "Show an example"]}
            on_select="select_suggestion"
          />
        </.chat_message>

        <.chat_message role="user" id={dom_id}>
          <.chat_bubble role="user" timestamp="2:31 PM">
            Key features?
          </.chat_bubble>
        </.chat_message>
      </.chat_container>

      <.chat_input id="chat-compose" on_submit="send_message" placeholder="Ask anything..." />

  ## Streams

      <.chat_message
        :for={{dom_id, msg} <- @streams.messages}
        id={dom_id}
        role={msg.role}
      >
        <.chat_bubble role={msg.role} timestamp={msg.sent_at}>
          {msg.body}
        </.chat_bubble>
      </.chat_message>

  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # chat_container/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, default: nil, doc: "DOM id — recommended for LiveView streams")
  attr(:class, :string, default: nil, doc: "Additional CSS classes for the scroll container")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root div")

  slot(:inner_block, required: true, doc: "chat_message children")

  @doc """
  Renders the chat log container.

  Sets `role="log"` and `aria-live="polite"` so assistive technologies announce
  new messages as they arrive via LiveView streams without interrupting the user.
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
    doc: "Message role: user | assistant | system"
  )

  attr(:id, :string, default: nil, doc: "DOM id — required for LiveView streams")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the message wrapper")

  slot(:inner_block, required: true, doc: "chat_bubble and/or chat_suggestions children")

  @doc """
  Renders a message row.

  Alignment is determined by `:role`:
  - `user` → right-aligned (`justify-end`)
  - `assistant` → left-aligned (`justify-start`)
  - `system` → centered (`justify-center`)
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
    doc: "Bubble role controls background colour and text colour"
  )

  attr(:timestamp, :string, default: nil, doc: "Optional time label (e.g. \"2:34 PM\")")

  attr(:on_feedback, :string,
    default: nil,
    doc: "phx-click event for thumbs up/down feedback (assistant only)"
  )

  attr(:message_id, :string,
    default: nil,
    doc: "ID passed as phx-value-message-id to feedback buttons"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the bubble")
  attr(:rest, :global, doc: "HTML attributes forwarded to the bubble wrapper")

  slot(:avatar, doc: "Optional Avatar component displayed beside an assistant bubble")
  slot(:inner_block, required: true, doc: "Bubble text content")

  @doc """
  Renders the styled chat content balloon.

  For `role="user"` the bubble uses `bg-primary`. For `role="assistant"` it uses
  `bg-muted`. For `role="system"` it renders as small muted inline text.

  Supply an `:avatar` slot (typically `avatar/1`) beside assistant messages.
  Set `on_feedback` to render thumbs up/down buttons for AI feedback collection.
  """
  def chat_bubble(assigns) do
    ~H"""
    <div class={cn(["flex items-end gap-2", bubble_wrapper_class(@role), @class])} {@rest}>
      <%!-- Avatar (assistant left side) --%>
      <span :if={@avatar != [] and @role == "assistant"} class="shrink-0 self-end">
        {render_slot(@avatar)}
      </span>

      <div class={cn(["flex flex-col gap-1", bubble_column_align(@role)])}>
        <%!-- Bubble content --%>
        <div class={cn(["rounded-2xl px-4 py-2.5 text-sm", bubble_bg(@role)])}>
          {render_slot(@inner_block)}
        </div>

        <%!-- Footer: timestamp + feedback --%>
        <div
          :if={@timestamp || (@on_feedback && @role == "assistant")}
          class={cn(["flex items-center gap-2", bubble_footer_align(@role)])}
        >
          <span :if={@timestamp} class="text-xs text-muted-foreground">
            {@timestamp}
          </span>

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

      <%!-- Avatar (user right side) --%>
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
    doc: "List of suggestion strings shown as clickable buttons"
  )

  attr(:on_select, :string,
    required: true,
    doc: "phx-click event emitted when a suggestion is selected"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the suggestions row")
  attr(:rest, :global, doc: "HTML attributes forwarded to the wrapper div")

  @doc """
  Renders a row of clickable suggestion chips.

  Each chip fires `on_select` with `phx-value-suggestion` set to the suggestion text.
  Typically rendered below an assistant bubble to guide the conversation.
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
  attr(:on_submit, :string, required: true, doc: "phx-submit event name")
  attr(:placeholder, :string, default: "Type a message...", doc: "Textarea placeholder")
  attr(:max_chars, :integer, default: nil, doc: "Optional character limit displayed as a counter")
  attr(:class, :string, default: nil, doc: "Additional CSS classes for the form wrapper")
  attr(:rest, :global, include: ~w(phx-change), doc: "HTML attributes forwarded to the form")

  slot(:attachments, doc: "Optional attachment chips rendered above the textarea")

  @doc """
  Renders the chat compose form.

  The form fires `on_submit` via `phx-submit`. A `max_chars` counter is shown
  when provided. Supply attachment chips via the `:attachments` slot.
  """
  def chat_input(assigns) do
    ~H"""
    <form
      id={@id}
      phx-submit={@on_submit}
      class={cn(["flex flex-col gap-2 rounded-xl border border-input bg-background p-3", @class])}
      {@rest}
    >
      <%!-- Attachment chips --%>
      <div :if={@attachments != []} class="flex flex-wrap gap-1">
        {render_slot(@attachments)}
      </div>

      <%!-- Textarea --%>
      <textarea
        name="message"
        rows="2"
        placeholder={@placeholder}
        class={cn([
          "w-full resize-none bg-transparent text-sm text-foreground",
          "placeholder:text-muted-foreground focus:outline-none"
        ])}
      />

      <%!-- Footer: char counter + submit --%>
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
  # Private helpers — pattern matching only
  # ---------------------------------------------------------------------------

  defp message_alignment("user"), do: "items-end"
  defp message_alignment("assistant"), do: "items-start"
  defp message_alignment("system"), do: "items-center"

  defp bubble_wrapper_class("user"), do: "justify-end"
  defp bubble_wrapper_class("assistant"), do: "justify-start"
  defp bubble_wrapper_class("system"), do: "justify-center"

  defp bubble_column_align("user"), do: "items-end"
  defp bubble_column_align("assistant"), do: "items-start"
  defp bubble_column_align("system"), do: "items-center"

  defp bubble_footer_align("user"), do: "justify-end"
  defp bubble_footer_align("assistant"), do: "justify-start"
  defp bubble_footer_align("system"), do: "justify-center"

  defp bubble_bg("user"), do: "bg-primary text-primary-foreground"
  defp bubble_bg("assistant"), do: "bg-muted text-foreground"
  defp bubble_bg("system"), do: "text-xs text-muted-foreground italic"
end
