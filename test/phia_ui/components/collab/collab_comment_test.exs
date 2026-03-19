defmodule PhiaUi.Components.Collab.CollabCommentTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helpers — all render functions live inside module H
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Collab.CollabComment

    # collab_comment
    def render_collab_comment(assigns) do
      comment = assigns[:comment] || default_comment()

      assigns =
        assigns
        |> Map.put_new(:id, "comment-1")
        |> Map.put(:comment, comment)
        |> Map.put_new(:current_user_id, nil)
        |> Map.put_new(:editable, false)
        |> Map.put_new(:on_edit, "collab:comment:edit")
        |> Map.put_new(:on_delete, "collab:comment:delete")
        |> Map.put_new(:on_react, "collab:comment:react")
        |> Map.put_new(:class, nil)

      ~H"""
      <.collab_comment
        id={@id}
        comment={@comment}
        current_user_id={@current_user_id}
        editable={@editable}
        on_edit={@on_edit}
        on_delete={@on_delete}
        on_react={@on_react}
        class={@class}
      />
      """
    end

    # collab_comment_body
    def render_collab_comment_body(assigns) do
      assigns =
        assigns
        |> Map.put_new(:body, "Hello world")
        |> Map.put_new(:class, nil)

      ~H"""
      <.collab_comment_body body={@body} class={@class} />
      """
    end

    # collab_comment_reactions
    def render_collab_comment_reactions(assigns) do
      assigns =
        assigns
        |> Map.put_new(:id, "reactions-1")
        |> Map.put_new(:reactions, [])
        |> Map.put_new(:on_react, "collab:comment:react")
        |> Map.put_new(:class, nil)

      ~H"""
      <.collab_comment_reactions
        id={@id}
        reactions={@reactions}
        on_react={@on_react}
        class={@class}
      />
      """
    end

    # collab_comment_actions
    def render_collab_comment_actions(assigns) do
      assigns =
        assigns
        |> Map.put_new(:id, "actions-1")
        |> Map.put_new(:comment_id, "c1")
        |> Map.put_new(:can_edit, false)
        |> Map.put_new(:can_delete, false)
        |> Map.put_new(:on_edit, "collab:comment:edit")
        |> Map.put_new(:on_delete, "collab:comment:delete")
        |> Map.put_new(:class, nil)

      ~H"""
      <.collab_comment_actions
        id={@id}
        comment_id={@comment_id}
        can_edit={@can_edit}
        can_delete={@can_delete}
        on_edit={@on_edit}
        on_delete={@on_delete}
        class={@class}
      />
      """
    end

    # collab_comment_pin
    def render_collab_comment_pin(assigns) do
      assigns =
        assigns
        |> Map.put_new(:id, "pin-1")
        |> Map.put_new(:color, "#6366F1")
        |> Map.put_new(:count, nil)
        |> Map.put_new(:active, false)
        |> Map.put_new(:class, nil)

      ~H"""
      <.collab_comment_pin
        id={@id}
        color={@color}
        count={@count}
        active={@active}
        class={@class}
      />
      """
    end

    # collab_comment_indicator
    def render_collab_comment_indicator(assigns) do
      assigns =
        assigns
        |> Map.put_new(:id, "indicator-1")
        |> Map.put_new(:count, 0)
        |> Map.put_new(:active, false)
        |> Map.put_new(:on_click, "collab:comment:show")
        |> Map.put_new(:class, nil)

      ~H"""
      <.collab_comment_indicator
        id={@id}
        count={@count}
        active={@active}
        on_click={@on_click}
        class={@class}
      />
      """
    end

    defp default_comment do
      %{
        id: "c1",
        user_id: "user-1",
        user_name: "Alice Smith",
        user_color: nil,
        user_avatar_url: nil,
        body: "This is a test comment",
        created_at: DateTime.utc_now(),
        edited_at: nil,
        reactions: [],
        thread_id: "t1"
      }
    end
  end

  # ===========================================================================
  # collab_comment/1
  # ===========================================================================

  describe "collab_comment/1" do
    test "renders comment with user name" do
      html = render_component(&H.render_collab_comment/1, %{})
      assert html =~ "Alice Smith"
    end

    test "renders comment body" do
      html = render_component(&H.render_collab_comment/1, %{})
      assert html =~ "This is a test comment"
    end

    test "renders user initials when no avatar" do
      html = render_component(&H.render_collab_comment/1, %{})
      assert html =~ "AS"
    end

    test "renders avatar image when avatar_url provided" do
      comment = %{
        id: "c1",
        user_id: "user-1",
        user_name: "Alice",
        user_color: nil,
        user_avatar_url: "https://example.com/avatar.jpg",
        body: "Hello",
        created_at: DateTime.utc_now(),
        edited_at: nil,
        reactions: [],
        thread_id: "t1"
      }

      html = render_component(&H.render_collab_comment/1, %{comment: comment})
      assert html =~ "https://example.com/avatar.jpg"
    end

    test "shows (edited) marker when edited_at differs from created_at" do
      now = DateTime.utc_now()
      later = DateTime.add(now, 60, :second)

      comment = %{
        id: "c1",
        user_id: "user-1",
        user_name: "Alice",
        user_color: nil,
        user_avatar_url: nil,
        body: "Edited comment",
        created_at: now,
        edited_at: later,
        reactions: [],
        thread_id: "t1"
      }

      html = render_component(&H.render_collab_comment/1, %{comment: comment})
      assert html =~ "(edited)"
    end

    test "applies custom class" do
      html = render_component(&H.render_collab_comment/1, %{class: "my-comment"})
      assert html =~ "my-comment"
    end

    test "sets data-comment-id attribute" do
      html = render_component(&H.render_collab_comment/1, %{})
      assert html =~ ~s(data-comment-id="c1")
    end
  end

  # ===========================================================================
  # collab_comment_body/1
  # ===========================================================================

  describe "collab_comment_body/1" do
    test "renders plain text" do
      html = render_component(&H.render_collab_comment_body/1, %{body: "Hello world"})
      assert html =~ "Hello world"
    end

    test "renders mentions with styled spans" do
      html =
        render_component(&H.render_collab_comment_body/1, %{
          body: "Hey @[Alice](user-1), check this out"
        })

      assert html =~ "@Alice"
      assert html =~ "text-primary"
    end

    test "renders multiple mentions" do
      html =
        render_component(&H.render_collab_comment_body/1, %{
          body: "@[Alice](u1) and @[Bob](u2)"
        })

      assert html =~ "@Alice"
      assert html =~ "@Bob"
    end

    test "applies custom class" do
      html =
        render_component(&H.render_collab_comment_body/1, %{
          body: "Hello",
          class: "my-body"
        })

      assert html =~ "my-body"
    end
  end

  # ===========================================================================
  # collab_comment_reactions/1
  # ===========================================================================

  describe "collab_comment_reactions/1" do
    test "renders reaction pills" do
      reactions = [
        %{emoji: "thumbs_up", count: 3, reacted: false},
        %{emoji: "heart", count: 1, reacted: true}
      ]

      html = render_component(&H.render_collab_comment_reactions/1, %{reactions: reactions})
      assert html =~ "thumbs_up"
      assert html =~ "heart"
      assert html =~ "3"
      assert html =~ "1"
    end

    test "highlights active reactions" do
      reactions = [%{emoji: "thumbs_up", count: 1, reacted: true}]
      html = render_component(&H.render_collab_comment_reactions/1, %{reactions: reactions})
      assert html =~ "bg-primary/10"
    end

    test "renders add reaction button" do
      html = render_component(&H.render_collab_comment_reactions/1, %{reactions: []})
      assert html =~ "Add reaction"
    end

    test "renders role=group" do
      html = render_component(&H.render_collab_comment_reactions/1, %{})
      assert html =~ ~s(role="group")
    end
  end

  # ===========================================================================
  # collab_comment_actions/1
  # ===========================================================================

  describe "collab_comment_actions/1" do
    test "renders nothing when no permissions" do
      html =
        render_component(&H.render_collab_comment_actions/1, %{
          can_edit: false,
          can_delete: false
        })

      refute html =~ "Edit"
      refute html =~ "Delete"
    end

    test "renders edit button when can_edit" do
      html = render_component(&H.render_collab_comment_actions/1, %{can_edit: true})
      assert html =~ "Edit"
    end

    test "renders delete button when can_delete" do
      html = render_component(&H.render_collab_comment_actions/1, %{can_delete: true})
      assert html =~ "Delete"
    end

    test "renders both edit and delete" do
      html =
        render_component(&H.render_collab_comment_actions/1, %{
          can_edit: true,
          can_delete: true
        })

      assert html =~ "Edit"
      assert html =~ "Delete"
    end

    test "renders role=menu on dropdown" do
      html =
        render_component(&H.render_collab_comment_actions/1, %{
          can_edit: true,
          can_delete: true
        })

      assert html =~ ~s(role="menu")
    end
  end

  # ===========================================================================
  # collab_comment_pin/1
  # ===========================================================================

  describe "collab_comment_pin/1" do
    test "renders pin with default color" do
      html = render_component(&H.render_collab_comment_pin/1, %{})
      assert html =~ "#6366F1"
    end

    test "renders pin with custom color" do
      html = render_component(&H.render_collab_comment_pin/1, %{color: "#FF0000"})
      assert html =~ "#FF0000"
    end

    test "shows count badge when count > 0" do
      html = render_component(&H.render_collab_comment_pin/1, %{count: 5})
      assert html =~ "5"
    end

    test "hides count badge when count is nil" do
      html = render_component(&H.render_collab_comment_pin/1, %{count: nil})
      refute html =~ ~s(size-4 rounded-full bg-foreground)
    end

    test "applies active scale" do
      html = render_component(&H.render_collab_comment_pin/1, %{active: true})
      assert html =~ "scale-125"
    end

    test "renders data-comment-pin attribute" do
      html = render_component(&H.render_collab_comment_pin/1, %{})
      assert html =~ "data-comment-pin"
    end
  end

  # ===========================================================================
  # collab_comment_indicator/1
  # ===========================================================================

  describe "collab_comment_indicator/1" do
    test "renders as button" do
      html = render_component(&H.render_collab_comment_indicator/1, %{})
      assert html =~ "<button"
    end

    test "shows comment count" do
      html = render_component(&H.render_collab_comment_indicator/1, %{count: 3})
      assert html =~ "3"
    end

    test "hides count when zero" do
      html = render_component(&H.render_collab_comment_indicator/1, %{count: 0})
      # The count span should not render for 0
      assert html =~ "0 comments"
    end

    test "applies active styling" do
      html = render_component(&H.render_collab_comment_indicator/1, %{active: true})
      assert html =~ "bg-primary"
    end

    test "applies inactive styling" do
      html = render_component(&H.render_collab_comment_indicator/1, %{active: false})
      assert html =~ "bg-muted"
    end

    test "renders data-comment-indicator attribute" do
      html = render_component(&H.render_collab_comment_indicator/1, %{})
      assert html =~ "data-comment-indicator"
    end

    test "renders aria-label" do
      html = render_component(&H.render_collab_comment_indicator/1, %{count: 5})
      assert html =~ "5 comments"
    end
  end
end
