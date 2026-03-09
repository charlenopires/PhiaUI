defmodule PhiaUi.Components.CommentTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Comment

    def render_comment(assigns) do
      ~H"""
      <.comment
        author={assigns[:author] || "Jane"}
        avatar_src={assigns[:avatar_src]}
        avatar_fallback={assigns[:avatar_fallback]}
        date={assigns[:date]}
        depth={assigns[:depth] || 0}
        max_depth={assigns[:max_depth] || 4}
        class={assigns[:class]}
      >
        {assigns[:body] || "Comment body"}
        <:actions :if={assigns[:show_actions]}>
          <button>Reply</button>
        </:actions>
        <:replies :if={assigns[:show_replies]}>
          <.comment author="Nested" depth={1}>Nested reply</.comment>
        </:replies>
        <:header_extra :if={assigns[:header_extra]}>
          <span class="badge">Edited</span>
        </:header_extra>
      </.comment>
      """
    end

    def render_comment_list(assigns) do
      ~H"""
      <.comment_list class={assigns[:class]}>
        <.comment author="Alice">First comment</.comment>
        <.comment author="Bob">Second comment</.comment>
      </.comment_list>
      """
    end
  end

  defp render_comment(attrs \\ %{}), do: render_component(&H.render_comment/1, attrs)
  defp render_comment_list(attrs \\ %{}), do: render_component(&H.render_comment_list/1, attrs)

  describe "comment/1" do
    test "renders author name" do
      assert render_comment(%{author: "Alice"}) =~ "Alice"
    end

    test "renders body content" do
      assert render_comment(%{body: "Great post!"}) =~ "Great post!"
    end

    test "renders date when provided" do
      assert render_comment(%{date: "2 hours ago"}) =~ "2 hours ago"
    end

    test "renders avatar image when avatar_src provided" do
      html = render_comment(%{avatar_src: "/img/jane.jpg"})
      assert html =~ "/img/jane.jpg"
      assert html =~ "<img"
    end

    test "renders fallback initials when no avatar_src" do
      html = render_comment(%{avatar_fallback: "JD"})
      assert html =~ "JD"
    end

    test "renders first letter of author when no avatar" do
      html = render_comment(%{author: "Alice"})
      assert html =~ "A"
    end

    test "renders actions slot" do
      html = render_comment(%{show_actions: true})
      assert html =~ "Reply"
    end

    test "renders replies slot" do
      html = render_comment(%{show_replies: true})
      assert html =~ "Nested reply"
    end

    test "renders header_extra slot" do
      html = render_comment(%{header_extra: true})
      assert html =~ "Edited"
    end

    test "depth 0 has no indent" do
      html = render_comment(%{depth: 0})
      refute html =~ "pl-8"
    end

    test "depth 1 adds border-l" do
      html = render_comment(%{depth: 1})
      assert html =~ "border-l-2"
    end

    test "custom class is applied" do
      assert render_comment(%{class: "my-comment"}) =~ "my-comment"
    end
  end

  describe "comment_list/1" do
    test "renders container with space-y-6" do
      assert render_comment_list() =~ "space-y-6"
    end

    test "renders child comments" do
      html = render_comment_list()
      assert html =~ "Alice"
      assert html =~ "Bob"
    end

    test "custom class is applied" do
      assert render_comment_list(%{class: "my-list"}) =~ "my-list"
    end
  end
end
