defmodule PhiaUi.Components.Collab.ComposerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helpers — all render functions live inside module H
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Collab.Composer

    # collab_composer
    def render_collab_composer(assigns) do
      assigns =
        assigns
        |> Map.put_new(:id, "composer-1")
        |> Map.put_new(:thread_id, nil)
        |> Map.put_new(:placeholder, "Write a comment...")
        |> Map.put_new(:on_submit, "collab:comment:create")
        |> Map.put_new(:mention_suggestions, [])
        |> Map.put_new(:show_mention_dropdown, false)
        |> Map.put_new(:class, nil)

      ~H"""
      <.collab_composer
        id={@id}
        thread_id={@thread_id}
        placeholder={@placeholder}
        on_submit={@on_submit}
        mention_suggestions={@mention_suggestions}
        show_mention_dropdown={@show_mention_dropdown}
        class={@class}
      />
      """
    end

    # collab_mention_suggest
    def render_collab_mention_suggest(assigns) do
      assigns =
        assigns
        |> Map.put_new(:id, "mention-1")
        |> Map.put_new(:suggestions, [])
        |> Map.put_new(:visible, false)
        |> Map.put_new(:on_select, "collab:mention:select")
        |> Map.put_new(:class, nil)

      ~H"""
      <.collab_mention_suggest
        id={@id}
        suggestions={@suggestions}
        visible={@visible}
        on_select={@on_select}
        class={@class}
      />
      """
    end

    # collab_floating_composer
    def render_collab_floating_composer(assigns) do
      assigns =
        assigns
        |> Map.put_new(:id, "float-composer-1")
        |> Map.put_new(:x, 100)
        |> Map.put_new(:y, 200)
        |> Map.put_new(:thread_id, nil)
        |> Map.put_new(:on_submit, "collab:comment:create")
        |> Map.put_new(:mention_suggestions, [])
        |> Map.put_new(:show_mention_dropdown, false)
        |> Map.put_new(:class, nil)

      ~H"""
      <.collab_floating_composer
        id={@id}
        x={@x}
        y={@y}
        thread_id={@thread_id}
        on_submit={@on_submit}
        mention_suggestions={@mention_suggestions}
        show_mention_dropdown={@show_mention_dropdown}
        class={@class}
      />
      """
    end
  end

  # ===========================================================================
  # collab_composer/1
  # ===========================================================================

  describe "collab_composer/1" do
    test "renders textarea with placeholder" do
      html = render_component(&H.render_collab_composer/1, %{})
      assert html =~ "Write a comment..."
    end

    test "renders custom placeholder" do
      html = render_component(&H.render_collab_composer/1, %{placeholder: "Add a reply..."})
      assert html =~ "Add a reply..."
    end

    test "renders phx-hook" do
      html = render_component(&H.render_collab_composer/1, %{})
      assert html =~ "PhiaCollabComposer"
    end

    test "renders data-composer-input on textarea" do
      html = render_component(&H.render_collab_composer/1, %{})
      assert html =~ "data-composer-input"
    end

    test "renders send button" do
      html = render_component(&H.render_collab_composer/1, %{})
      assert html =~ "Send comment"
    end

    test "renders formatting hints" do
      html = render_component(&H.render_collab_composer/1, %{})
      assert html =~ "Enter to send"
      assert html =~ "Shift+Enter for new line"
      assert html =~ "@ to mention"
    end

    test "stores on_submit in data attribute" do
      html =
        render_component(&H.render_collab_composer/1, %{
          on_submit: "custom:submit"
        })

      assert html =~ ~s(data-on-submit="custom:submit")
    end

    test "stores thread_id in data attribute" do
      html = render_component(&H.render_collab_composer/1, %{thread_id: "t42"})
      assert html =~ ~s(data-thread-id="t42")
    end

    test "applies custom class" do
      html = render_component(&H.render_collab_composer/1, %{class: "my-composer"})
      assert html =~ "my-composer"
    end
  end

  # ===========================================================================
  # collab_mention_suggest/1
  # ===========================================================================

  describe "collab_mention_suggest/1" do
    test "hidden by default" do
      html = render_component(&H.render_collab_mention_suggest/1, %{})
      assert html =~ "hidden"
    end

    test "visible with suggestions" do
      suggestions = [
        %{id: "u1", name: "Alice", avatar_url: nil},
        %{id: "u2", name: "Bob", avatar_url: nil}
      ]

      html =
        render_component(&H.render_collab_mention_suggest/1, %{
          suggestions: suggestions,
          visible: true
        })

      assert html =~ "Alice"
      assert html =~ "Bob"
      refute html =~ "hidden"
    end

    test "renders user avatars when provided" do
      suggestions = [
        %{id: "u1", name: "Alice", avatar_url: "https://example.com/alice.jpg"}
      ]

      html =
        render_component(&H.render_collab_mention_suggest/1, %{
          suggestions: suggestions,
          visible: true
        })

      assert html =~ "https://example.com/alice.jpg"
    end

    test "renders initials when no avatar" do
      suggestions = [
        %{id: "u1", name: "Jane Doe", avatar_url: nil}
      ]

      html =
        render_component(&H.render_collab_mention_suggest/1, %{
          suggestions: suggestions,
          visible: true
        })

      assert html =~ "JD"
    end

    test "renders role=listbox" do
      html = render_component(&H.render_collab_mention_suggest/1, %{})
      assert html =~ ~s(role="listbox")
    end

    test "renders no users found when visible with empty suggestions" do
      html =
        render_component(&H.render_collab_mention_suggest/1, %{
          suggestions: [],
          visible: true
        })

      assert html =~ "No users found"
    end

    test "renders data-mention-option on each suggestion" do
      suggestions = [%{id: "u1", name: "Alice", avatar_url: nil}]

      html =
        render_component(&H.render_collab_mention_suggest/1, %{
          suggestions: suggestions,
          visible: true
        })

      assert html =~ "data-mention-option"
    end
  end

  # ===========================================================================
  # collab_floating_composer/1
  # ===========================================================================

  describe "collab_floating_composer/1" do
    test "renders with position style" do
      html = render_component(&H.render_collab_floating_composer/1, %{x: 150, y: 250})
      assert html =~ "left: 150px"
      assert html =~ "top: 250px"
    end

    test "renders New comment header" do
      html = render_component(&H.render_collab_floating_composer/1, %{})
      assert html =~ "New comment"
    end

    test "renders nested composer" do
      html = render_component(&H.render_collab_floating_composer/1, %{})
      assert html =~ "data-composer-input"
      assert html =~ "PhiaCollabComposer"
    end

    test "applies custom class" do
      html =
        render_component(&H.render_collab_floating_composer/1, %{class: "my-float-composer"})

      assert html =~ "my-float-composer"
    end

    test "renders absolute positioning" do
      html = render_component(&H.render_collab_floating_composer/1, %{})
      assert html =~ "absolute"
    end
  end
end
