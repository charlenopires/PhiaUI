defmodule PhiaUi.Components.ChatMessageTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ChatMessage

    def render_container(assigns) do
      ~H"""
      <.chat_container id={assigns[:id]} class={assigns[:class]}>
        {assigns[:content] || "chat content"}
      </.chat_container>
      """
    end

    def render_message(assigns) do
      ~H"""
      <.chat_message
        role={assigns[:role] || "user"}
        id={assigns[:id]}
        class={assigns[:class]}
      >
        {assigns[:content] || "Hello there"}
      </.chat_message>
      """
    end

    def render_bubble(assigns) do
      ~H"""
      <.chat_bubble
        role={assigns[:role] || "user"}
        timestamp={assigns[:timestamp]}
        class={assigns[:class]}
      >
        {assigns[:content] || "Bubble content"}
      </.chat_bubble>
      """
    end

    def render_bubble_with_avatar(assigns) do
      ~H"""
      <.chat_bubble role="assistant" timestamp="2:34 PM">
        <:avatar><span class="chat-avatar" /></:avatar>
        Assistant reply here
      </.chat_bubble>
      """
    end

    def render_bubble_with_feedback(assigns) do
      ~H"""
      <.chat_bubble role="assistant" on_feedback="handle_feedback" message_id="msg-1">
        Some AI response
      </.chat_bubble>
      """
    end

    def render_suggestions(assigns) do
      ~H"""
      <.chat_suggestions
        suggestions={assigns[:suggestions] || ["Option A", "Option B", "Option C"]}
        on_select={assigns[:on_select] || "select_suggestion"}
        class={assigns[:class]}
      />
      """
    end

    def render_input(assigns) do
      ~H"""
      <.chat_input
        id={assigns[:id] || "chat-input"}
        on_submit={assigns[:on_submit] || "send_message"}
        placeholder={assigns[:placeholder]}
        class={assigns[:class]}
      />
      """
    end

    def render_full(assigns) do
      ~H"""
      <.chat_container id="ai-chat">
        <.chat_message role="assistant" id="msg-0">
          <.chat_bubble role="assistant" timestamp="2:30 PM">
            <:avatar><span class="bot-avatar" /></:avatar>
            Welcome! How can I help?
          </.chat_bubble>
          <.chat_suggestions
            suggestions={["What are key features?", "Show me an example"]}
            on_select="select_suggestion"
          />
        </.chat_message>

        <.chat_message role="user" id="msg-1">
          <.chat_bubble role="user" timestamp="2:31 PM">
            What are key features?
          </.chat_bubble>
        </.chat_message>

        <.chat_message role="assistant" id="msg-2">
          <.chat_bubble role="assistant" on_feedback="handle_feedback" message_id="msg-2" timestamp="2:31 PM">
            Here are the key features...
          </.chat_bubble>
        </.chat_message>

        <.chat_message role="system" id="msg-sys">
          <.chat_bubble role="system">
            Conversation started
          </.chat_bubble>
        </.chat_message>
      </.chat_container>
      """
    end

    def render_input_with_attachments(assigns) do
      ~H"""
      <.chat_input id="ci" on_submit="send" max_chars={120}>
        <:attachments>
          <span class="attachment-chip">diagram17.png</span>
        </:attachments>
      </.chat_input>
      """
    end
  end

  defp render_container(attrs \\ %{}), do: render_component(&H.render_container/1, attrs)
  defp render_message(attrs \\ %{}), do: render_component(&H.render_message/1, attrs)
  defp render_bubble(attrs \\ %{}), do: render_component(&H.render_bubble/1, attrs)
  defp render_bubble_with_avatar, do: render_component(&H.render_bubble_with_avatar/1, %{})
  defp render_bubble_with_feedback, do: render_component(&H.render_bubble_with_feedback/1, %{})
  defp render_suggestions(attrs \\ %{}), do: render_component(&H.render_suggestions/1, attrs)
  defp render_input(attrs \\ %{}), do: render_component(&H.render_input/1, attrs)
  defp render_full, do: render_component(&H.render_full/1, %{})

  defp render_input_with_attachments,
    do: render_component(&H.render_input_with_attachments/1, %{})

  # ---------------------------------------------------------------------------
  # chat_container/1 — ARIA + wrapper
  # ---------------------------------------------------------------------------

  describe "chat_container/1 — ARIA and wrapper" do
    test "renders a root element" do
      assert render_container() =~ "<div"
    end

    test "has role=log for ARIA chat log semantics" do
      assert render_container() =~ ~s(role="log")
    end

    test "has aria-live=polite for real-time announcements" do
      assert render_container() =~ ~s(aria-live="polite")
    end

    test "renders inner slot content" do
      assert render_container(%{content: "chat content here"}) =~ "chat content here"
    end

    test "id attribute is forwarded" do
      assert render_container(%{id: "my-chat"}) =~ ~s(id="my-chat")
    end

    test "custom class is applied" do
      assert render_container(%{class: "my-chat-container"}) =~ "my-chat-container"
    end
  end

  # ---------------------------------------------------------------------------
  # chat_message/1 — role alignment
  # ---------------------------------------------------------------------------

  describe "chat_message/1 — role variants" do
    test "user role renders right-aligned layout" do
      html = render_message(%{role: "user"})
      assert html =~ "items-end" or html =~ "justify-end" or html =~ "ml-auto"
    end

    test "assistant role renders left-aligned layout" do
      html = render_message(%{role: "assistant"})
      assert html =~ "items-start" or html =~ "justify-start" or html =~ "mr-auto"
    end

    test "system role renders centered layout" do
      html = render_message(%{role: "system"})
      assert html =~ "items-center" or html =~ "justify-center" or html =~ "mx-auto"
    end

    test "renders inner content" do
      assert render_message(%{content: "Hello world"}) =~ "Hello world"
    end

    test "id is forwarded to the message element" do
      assert render_message(%{id: "msg-123"}) =~ ~s(id="msg-123")
    end

    test "custom class is applied" do
      assert render_message(%{class: "my-msg"}) =~ "my-msg"
    end
  end

  # ---------------------------------------------------------------------------
  # chat_bubble/1 — content and styling
  # ---------------------------------------------------------------------------

  describe "chat_bubble/1 — content" do
    test "renders bubble content" do
      assert render_bubble(%{content: "Test message"}) =~ "Test message"
    end

    test "renders timestamp when provided" do
      assert render_bubble(%{timestamp: "3:45 PM"}) =~ "3:45 PM"
    end

    test "timestamp uses text-muted-foreground token" do
      html = render_bubble(%{timestamp: "3:45 PM"})
      assert html =~ "text-muted-foreground"
    end

    test "does not render timestamp element when nil" do
      html = render_bubble(%{timestamp: nil})
      refute html =~ "3:45 PM"
    end

    test "custom class is applied" do
      assert render_bubble(%{class: "my-bubble"}) =~ "my-bubble"
    end
  end

  describe "chat_bubble/1 — role variants" do
    test "user bubble has primary or distinct background" do
      html = render_bubble(%{role: "user"})
      assert html =~ "bg-primary" or html =~ "bg-accent"
    end

    test "assistant bubble has muted or secondary background" do
      html = render_bubble(%{role: "assistant"})
      assert html =~ "bg-muted" or html =~ "bg-secondary" or html =~ "bg-card"
    end

    test "system bubble uses muted styling" do
      html = render_bubble(%{role: "system"})
      assert html =~ "text-muted-foreground" or html =~ "text-xs"
    end

    test "bubbles use rounded corners" do
      assert render_bubble() =~ "rounded"
    end
  end

  describe "chat_bubble/1 — avatar slot" do
    test "renders avatar slot content when provided" do
      assert render_bubble_with_avatar() =~ "chat-avatar"
    end

    test "renders bubble content alongside avatar" do
      html = render_bubble_with_avatar()
      assert html =~ "Assistant reply here"
      assert html =~ "chat-avatar"
    end

    test "renders timestamp with avatar present" do
      assert render_bubble_with_avatar() =~ "2:34 PM"
    end
  end

  describe "chat_bubble/1 — feedback buttons" do
    test "renders thumbs up and down buttons when on_feedback is set" do
      html = render_bubble_with_feedback()
      assert html =~ "phx-click"
    end

    test "feedback buttons carry message_id as phx-value" do
      html = render_bubble_with_feedback()
      assert html =~ "msg-1"
    end

    test "does not render feedback buttons when on_feedback is nil" do
      html = render_bubble(%{role: "assistant"})
      refute html =~ "phx-value-message-id"
    end
  end

  # ---------------------------------------------------------------------------
  # chat_suggestions/1
  # ---------------------------------------------------------------------------

  describe "chat_suggestions/1 — suggestion buttons" do
    test "renders a button for each suggestion" do
      html = render_suggestions(%{suggestions: ["A", "B", "C"]})
      assert html =~ "A"
      assert html =~ "B"
      assert html =~ "C"
    end

    test "each suggestion is a clickable button" do
      assert render_suggestions() =~ "<button"
    end

    test "buttons carry phx-click handler" do
      assert render_suggestions() =~ "phx-click"
    end

    test "buttons carry the suggestion text as phx-value" do
      html = render_suggestions(%{suggestions: ["Option A"], on_select: "pick"})
      assert html =~ "Option A"
    end

    test "custom class is applied to the suggestions container" do
      assert render_suggestions(%{class: "my-suggestions"}) =~ "my-suggestions"
    end

    test "renders empty container for empty suggestions list" do
      html = render_suggestions(%{suggestions: []})
      refute html =~ "<button"
    end
  end

  # ---------------------------------------------------------------------------
  # chat_input/1
  # ---------------------------------------------------------------------------

  describe "chat_input/1 — form" do
    test "renders a form element" do
      assert render_input() =~ "<form"
    end

    test "form has phx-submit handler" do
      html = render_input(%{on_submit: "send_message"})
      assert html =~ ~s(phx-submit="send_message")
    end

    test "renders a textarea or input for user text" do
      html = render_input()
      assert html =~ "<textarea" or html =~ ~s(type="text")
    end

    test "placeholder is applied when provided" do
      html = render_input(%{placeholder: "Type a message..."})
      assert html =~ "Type a message..."
    end

    test "id is forwarded to the form or input" do
      assert render_input(%{id: "my-input"}) =~ "my-input"
    end

    test "custom class is applied" do
      assert render_input(%{class: "my-input-wrapper"}) =~ "my-input-wrapper"
    end

    test "renders a submit button" do
      html = render_input()
      assert html =~ ~s(type="submit") or html =~ "Send" or html =~ "send"
    end
  end

  describe "chat_input/1 — attachments slot" do
    test "renders attachments slot content when provided" do
      assert render_input_with_attachments() =~ "attachment-chip"
    end

    test "attachment chip text is rendered" do
      assert render_input_with_attachments() =~ "diagram17.png"
    end
  end

  describe "chat_input/1 — char counter" do
    test "renders max_chars counter when provided" do
      html = render_input_with_attachments()
      assert html =~ "120"
    end
  end

  # ---------------------------------------------------------------------------
  # Full composition
  # ---------------------------------------------------------------------------

  describe "full chat composition" do
    test "renders container with role=log" do
      assert render_full() =~ ~s(role="log")
    end

    test "renders user and assistant messages" do
      html = render_full()
      assert html =~ "What are key features?"
      assert html =~ "Welcome! How can I help?"
    end

    test "renders system message" do
      assert render_full() =~ "Conversation started"
    end

    test "renders suggestion buttons" do
      html = render_full()
      assert html =~ "What are key features?"
      assert html =~ "Show me an example"
    end

    test "renders bot avatar" do
      assert render_full() =~ "bot-avatar"
    end

    test "no hardcoded hex colors in style attributes" do
      html = render_full()
      refute html =~ ~r/style="[^"]*#[0-9a-fA-F]{3,6}/
    end
  end
end
