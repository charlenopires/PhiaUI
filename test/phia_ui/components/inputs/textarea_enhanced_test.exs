defmodule PhiaUi.Components.TextareaEnhancedTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.TextareaEnhanced

    def render_autoresize_textarea(assigns) do
      ~H"""
      <.autoresize_textarea
        id="ar-1"
        name="content"
        value="Hello"
        min_rows={2}
        max_rows={10}
        phx-change="update"
      />
      """
    end

    def render_chat_textarea(assigns) do
      ~H"""
      <.chat_textarea
        id="chat-1"
        name="message"
        on_submit="send_msg"
      >
        <:actions>
          <button type="button">Send</button>
        </:actions>
      </.chat_textarea>
      """
    end

    def render_code_textarea(assigns) do
      ~H"""
      <.code_textarea
        id="code-1"
        name="snippet"
        value={"def hello do\n  :world\nend"}
        tab_size={2}
        show_line_numbers={true}
        rows={10}
      />
      """
    end

    def render_textarea_with_actions(assigns) do
      ~H"""
      <.textarea_with_actions name="post" value="Draft">
        <:actions>
          <button type="submit">Post</button>
        </:actions>
      </.textarea_with_actions>
      """
    end

    def render_split_textarea(assigns) do
      ~H"""
      <.split_textarea name="md" value="# Hello">
        <:preview><div class="prose">Preview</div></:preview>
      </.split_textarea>
      """
    end

    def render_ghost_textarea(assigns) do
      ~H"""
      <.ghost_textarea id="ghost-1" name="note" value="Note here" />
      """
    end

    def render_expandable_textarea(assigns) do
      ~H"""
      <.expandable_textarea
        id="exp-1"
        name="desc"
        value="Short"
        collapsed_rows={2}
        expanded_rows={8}
      />
      """
    end
  end

  describe "autoresize_textarea/1" do
    test "renders textarea with phx-hook" do
      html = render_component(&H.render_autoresize_textarea/1, %{})
      assert html =~ ~s(phx-hook="PhiaAutoresize")
    end

    test "has data-min-rows attribute" do
      html = render_component(&H.render_autoresize_textarea/1, %{})
      assert html =~ ~s(data-min-rows="2")
    end

    test "has data-max-rows attribute" do
      html = render_component(&H.render_autoresize_textarea/1, %{})
      assert html =~ ~s(data-max-rows="10")
    end

    test "renders value" do
      html = render_component(&H.render_autoresize_textarea/1, %{})
      assert html =~ "Hello"
    end

    test "has resize-none class" do
      html = render_component(&H.render_autoresize_textarea/1, %{})
      assert html =~ "resize-none"
    end
  end

  describe "chat_textarea/1" do
    test "renders with phx-hook" do
      html = render_component(&H.render_chat_textarea/1, %{})
      assert html =~ ~s(phx-hook="PhiaChatTextarea")
    end

    test "has data-on-submit" do
      html = render_component(&H.render_chat_textarea/1, %{})
      assert html =~ ~s(data-on-submit="send_msg")
    end

    test "renders actions slot" do
      html = render_component(&H.render_chat_textarea/1, %{})
      assert html =~ "Send"
    end

    test "has rounded border container" do
      html = render_component(&H.render_chat_textarea/1, %{})
      assert html =~ "rounded-md"
      assert html =~ "border"
    end
  end

  describe "code_textarea/1" do
    test "renders with phx-hook" do
      html = render_component(&H.render_code_textarea/1, %{})
      assert html =~ ~s(phx-hook="PhiaCodeTextarea")
    end

    test "has data-tab-size" do
      html = render_component(&H.render_code_textarea/1, %{})
      assert html =~ ~s(data-tab-size="2")
    end

    test "renders line numbers ol" do
      html = render_component(&H.render_code_textarea/1, %{})
      assert html =~ "<ol"
    end

    test "has font-mono class" do
      html = render_component(&H.render_code_textarea/1, %{})
      assert html =~ "font-mono"
    end

    test "renders line number items" do
      html = render_component(&H.render_code_textarea/1, %{})
      assert html =~ "1\n"
      assert html =~ "2\n"
    end
  end

  describe "textarea_with_actions/1" do
    test "renders textarea" do
      html = render_component(&H.render_textarea_with_actions/1, %{})
      assert html =~ "<textarea"
      assert html =~ "Draft"
    end

    test "renders action bar with border-t" do
      html = render_component(&H.render_textarea_with_actions/1, %{})
      assert html =~ "border-t"
    end

    test "renders actions slot" do
      html = render_component(&H.render_textarea_with_actions/1, %{})
      assert html =~ "Post"
    end
  end

  describe "split_textarea/1" do
    test "renders two-column layout" do
      html = render_component(&H.render_split_textarea/1, %{})
      assert html =~ "grid-cols-2"
    end

    test "renders Write label" do
      html = render_component(&H.render_split_textarea/1, %{})
      assert html =~ "Write"
    end

    test "renders Preview label" do
      html = render_component(&H.render_split_textarea/1, %{})
      assert html =~ "Preview"
    end

    test "renders preview content" do
      html = render_component(&H.render_split_textarea/1, %{})
      assert html =~ "Preview"
    end

    test "renders textarea value" do
      html = render_component(&H.render_split_textarea/1, %{})
      assert html =~ "# Hello"
    end
  end

  describe "ghost_textarea/1" do
    test "has transparent background" do
      html = render_component(&H.render_ghost_textarea/1, %{})
      assert html =~ "bg-transparent"
    end

    test "has no border" do
      html = render_component(&H.render_ghost_textarea/1, %{})
      assert html =~ "border-0"
    end

    test "has no shadow" do
      html = render_component(&H.render_ghost_textarea/1, %{})
      assert html =~ "shadow-none"
    end

    test "renders value" do
      html = render_component(&H.render_ghost_textarea/1, %{})
      assert html =~ "Note here"
    end
  end

  describe "expandable_textarea/1" do
    test "renders textarea" do
      html = render_component(&H.render_expandable_textarea/1, %{})
      assert html =~ "<textarea"
    end

    test "renders expand button" do
      html = render_component(&H.render_expandable_textarea/1, %{})
      assert html =~ "Expand"
    end

    test "renders collapse label" do
      html = render_component(&H.render_expandable_textarea/1, %{})
      assert html =~ "Collapse"
    end

    test "starts with collapsed_rows" do
      html = render_component(&H.render_expandable_textarea/1, %{})
      assert html =~ ~s(rows="2")
    end
  end
end
