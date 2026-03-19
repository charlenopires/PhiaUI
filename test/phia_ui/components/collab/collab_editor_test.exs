defmodule PhiaUi.Components.Collab.CollabEditorTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    use Phoenix.Component

    import PhiaUi.Components.Collab.CollabEditor

    def render_collab_editor(assigns) do
      ~H"""
      <.collab_editor {assigns} />
      """
    end
  end

  @default_user %{id: "u1", name: "Alice", color: "#E53E3E", avatar_url: nil}

  describe "collab_editor/1" do
    test "renders the composite editor" do
      html =
        render_component(&H.render_collab_editor/1, %{
          id: "test-editor",
          doc_id: "doc-123",
          current_user: @default_user
        })

      assert html =~ "data-collab-editor"
      assert html =~ "doc-123"
      assert html =~ "test-editor"
    end

    test "renders status bar by default" do
      html =
        render_component(&H.render_collab_editor/1, %{
          id: "test-editor",
          doc_id: "doc-123",
          current_user: @default_user
        })

      assert html =~ "test-editor-status-bar"
    end

    test "hides status bar when show_status_bar is false" do
      html =
        render_component(&H.render_collab_editor/1, %{
          id: "test-editor",
          doc_id: "doc-123",
          current_user: @default_user,
          show_status_bar: false
        })

      refute html =~ "test-editor-status-bar"
    end

    test "renders editor container with collab data attributes" do
      html =
        render_component(&H.render_collab_editor/1, %{
          id: "test-editor",
          doc_id: "doc-123",
          current_user: @default_user
        })

      assert html =~ ~s(data-collab-enabled="true")
      assert html =~ ~s(data-collab-doc-id="doc-123")
      assert html =~ ~s(data-collab-user-id="u1")
      assert html =~ ~s(data-collab-user-name="Alice")
    end

    test "renders cursor overlay when show_cursors is true" do
      html =
        render_component(&H.render_collab_editor/1, %{
          id: "test-editor",
          doc_id: "doc-123",
          current_user: @default_user,
          show_cursors: true,
          cursors: [%{id: "c1", user_name: "Bob", color: "#3182CE", x: 10, y: 20, idle: false}]
        })

      assert html =~ "test-editor-cursors"
    end

    test "hides cursor overlay when show_cursors is false" do
      html =
        render_component(&H.render_collab_editor/1, %{
          id: "test-editor",
          doc_id: "doc-123",
          current_user: @default_user,
          show_cursors: false
        })

      refute html =~ "test-editor-cursors"
    end

    test "renders thread sidebar when show_threads is true" do
      html =
        render_component(&H.render_collab_editor/1, %{
          id: "test-editor",
          doc_id: "doc-123",
          current_user: @default_user,
          show_threads: true,
          threads: []
        })

      assert html =~ "test-editor-threads"
    end

    test "renders version badge in footer" do
      html =
        render_component(&H.render_collab_editor/1, %{
          id: "test-editor",
          doc_id: "doc-123",
          current_user: @default_user
        })

      assert html =~ "test-editor-version-badge"
    end

    test "shows unresolved thread count" do
      threads = [
        %{id: "t1", resolved: false, comments: []},
        %{id: "t2", resolved: true, comments: []},
        %{id: "t3", resolved: false, comments: []}
      ]

      html =
        render_component(&H.render_collab_editor/1, %{
          id: "test-editor",
          doc_id: "doc-123",
          current_user: @default_user,
          show_threads: true,
          threads: threads
        })

      assert html =~ "2"
    end

    test "passes custom placeholder to editor" do
      html =
        render_component(&H.render_collab_editor/1, %{
          id: "test-editor",
          doc_id: "doc-123",
          current_user: @default_user,
          editor_placeholder: "Custom placeholder..."
        })

      assert html =~ "Custom placeholder..."
    end

    test "applies custom class" do
      html =
        render_component(&H.render_collab_editor/1, %{
          id: "test-editor",
          doc_id: "doc-123",
          current_user: @default_user,
          class: "my-custom-class"
        })

      assert html =~ "my-custom-class"
    end
  end
end
