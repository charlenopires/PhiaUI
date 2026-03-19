defmodule PhiaUi.Components.Collab.CursorTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Collab.Cursor

    def render_cursor(assigns) do
      ~H"""
      <.collab_cursor
        id={@id}
        user_name={@user_name}
        color={@color}
        x={assigns[:x] || 0}
        y={assigns[:y] || 0}
        idle={assigns[:idle] || false}
        class={assigns[:class]}
      />
      """
    end

    def render_cursors_overlay(assigns) do
      ~H"""
      <.collab_cursors_overlay
        id={@id}
        cursors={assigns[:cursors] || []}
        class={assigns[:class]}
      />
      """
    end

    def render_selection(assigns) do
      ~H"""
      <.collab_selection
        id={@id}
        color={@color}
        user_name={@user_name}
        top={assigns[:top] || 0}
        left={assigns[:left] || 0}
        width={assigns[:width] || 0}
        height={assigns[:height] || 0}
        class={assigns[:class]}
      />
      """
    end

    def render_cursor_chat(assigns) do
      ~H"""
      <.collab_cursor_chat
        id={@id}
        user_name={@user_name}
        color={@color}
        x={assigns[:x] || 0}
        y={assigns[:y] || 0}
        message={assigns[:message]}
        show_input={assigns[:show_input] || false}
        class={assigns[:class]}
      />
      """
    end
  end

  # ---------------------------------------------------------------------------
  # collab_cursor/1
  # ---------------------------------------------------------------------------

  describe "collab_cursor/1" do
    test "renders SVG cursor arrow" do
      html =
        render_component(&H.render_cursor/1, %{
          id: "cursor-1",
          user_name: "Alice",
          color: "#3B82F6"
        })

      assert html =~ "<svg"
      assert html =~ "<path"
    end

    test "renders user name label" do
      html =
        render_component(&H.render_cursor/1, %{
          id: "cursor-1",
          user_name: "Alice",
          color: "#3B82F6"
        })

      assert html =~ "Alice"
    end

    test "applies user color to SVG fill" do
      html =
        render_component(&H.render_cursor/1, %{
          id: "cursor-1",
          user_name: "Alice",
          color: "#EF4444"
        })

      assert html =~ ~s(fill="#EF4444")
    end

    test "applies user color to name label background" do
      html =
        render_component(&H.render_cursor/1, %{
          id: "cursor-1",
          user_name: "Alice",
          color: "#3B82F6"
        })

      assert html =~ "background-color: #3B82F6"
    end

    test "positions at given x/y coordinates" do
      html =
        render_component(&H.render_cursor/1, %{
          id: "cursor-1",
          user_name: "Alice",
          color: "#3B82F6",
          x: 120,
          y: 340
        })

      assert html =~ "translate(120px, 340px)"
    end

    test "has data-cursor-id attribute" do
      html =
        render_component(&H.render_cursor/1, %{
          id: "cursor-alice",
          user_name: "Alice",
          color: "#3B82F6"
        })

      assert html =~ ~s(data-cursor-id="cursor-alice")
    end

    test "has absolute positioning" do
      html =
        render_component(&H.render_cursor/1, %{
          id: "cursor-1",
          user_name: "Alice",
          color: "#3B82F6"
        })

      assert html =~ "absolute"
    end

    test "fades when idle" do
      html =
        render_component(&H.render_cursor/1, %{
          id: "cursor-1",
          user_name: "Alice",
          color: "#3B82F6",
          idle: true
        })

      assert html =~ "opacity-30"
    end

    test "full opacity when not idle" do
      html =
        render_component(&H.render_cursor/1, %{
          id: "cursor-1",
          user_name: "Alice",
          color: "#3B82F6",
          idle: false
        })

      assert html =~ "opacity-100"
    end

    test "is aria-hidden" do
      html =
        render_component(&H.render_cursor/1, %{
          id: "cursor-1",
          user_name: "Alice",
          color: "#3B82F6"
        })

      assert html =~ ~s(aria-hidden="true")
    end

    test "is pointer-events-none" do
      html =
        render_component(&H.render_cursor/1, %{
          id: "cursor-1",
          user_name: "Alice",
          color: "#3B82F6"
        })

      assert html =~ "pointer-events-none"
    end

    test "applies custom class" do
      html =
        render_component(&H.render_cursor/1, %{
          id: "cursor-1",
          user_name: "Alice",
          color: "#3B82F6",
          class: "my-cursor-class"
        })

      assert html =~ "my-cursor-class"
    end
  end

  # ---------------------------------------------------------------------------
  # collab_cursors_overlay/1
  # ---------------------------------------------------------------------------

  describe "collab_cursors_overlay/1" do
    test "renders container with relative positioning" do
      html = render_component(&H.render_cursors_overlay/1, %{id: "overlay-1"})
      assert html =~ "relative"
    end

    test "has phx-hook attribute" do
      html = render_component(&H.render_cursors_overlay/1, %{id: "overlay-1"})
      assert html =~ ~s(phx-hook="PhiaCollabCursors")
    end

    test "renders multiple cursors" do
      cursors = [
        %{id: "c1", user_name: "Alice", color: "#3B82F6", x: 10, y: 20},
        %{id: "c2", user_name: "Bob", color: "#EF4444", x: 30, y: 40}
      ]

      html =
        render_component(&H.render_cursors_overlay/1, %{
          id: "overlay-multi",
          cursors: cursors
        })

      assert html =~ "Alice"
      assert html =~ "Bob"
    end

    test "renders empty overlay when no cursors" do
      html = render_component(&H.render_cursors_overlay/1, %{id: "overlay-empty", cursors: []})
      assert html =~ ~s(id="overlay-empty")
      refute html =~ "data-cursor-id"
    end

    test "cursor container has pointer-events-none" do
      html = render_component(&H.render_cursors_overlay/1, %{id: "overlay-pe"})
      assert html =~ "pointer-events-none"
    end

    test "applies custom class" do
      html =
        render_component(&H.render_cursors_overlay/1, %{
          id: "overlay-class",
          class: "my-overlay-class"
        })

      assert html =~ "my-overlay-class"
    end
  end

  # ---------------------------------------------------------------------------
  # collab_selection/1
  # ---------------------------------------------------------------------------

  describe "collab_selection/1" do
    test "renders selection rectangle" do
      html =
        render_component(&H.render_selection/1, %{
          id: "sel-1",
          color: "#3B82F6",
          user_name: "Alice",
          top: 80,
          left: 24,
          width: 200,
          height: 20
        })

      assert html =~ ~s(id="sel-1")
      assert html =~ "top: 80px"
      assert html =~ "left: 24px"
      assert html =~ "width: 200px"
      assert html =~ "height: 20px"
    end

    test "applies semi-transparent background color" do
      html =
        render_component(&H.render_selection/1, %{
          id: "sel-color",
          color: "#3B82F6",
          user_name: "Alice"
        })

      assert html =~ "background-color: #3B82F633"
    end

    test "shows user name label" do
      html =
        render_component(&H.render_selection/1, %{
          id: "sel-name",
          color: "#3B82F6",
          user_name: "Alice"
        })

      assert html =~ "Alice"
    end

    test "renders caret line" do
      html =
        render_component(&H.render_selection/1, %{
          id: "sel-caret",
          color: "#3B82F6",
          user_name: "Alice"
        })

      assert html =~ "w-0.5"
    end

    test "is pointer-events-none" do
      html =
        render_component(&H.render_selection/1, %{
          id: "sel-pe",
          color: "#3B82F6",
          user_name: "Alice"
        })

      assert html =~ "pointer-events-none"
    end

    test "is aria-hidden" do
      html =
        render_component(&H.render_selection/1, %{
          id: "sel-aria",
          color: "#3B82F6",
          user_name: "Alice"
        })

      assert html =~ ~s(aria-hidden="true")
    end

    test "applies custom class" do
      html =
        render_component(&H.render_selection/1, %{
          id: "sel-class",
          color: "#3B82F6",
          user_name: "Alice",
          class: "my-selection-class"
        })

      assert html =~ "my-selection-class"
    end
  end

  # ---------------------------------------------------------------------------
  # collab_cursor_chat/1
  # ---------------------------------------------------------------------------

  describe "collab_cursor_chat/1" do
    test "renders cursor with SVG" do
      html =
        render_component(&H.render_cursor_chat/1, %{
          id: "chat-1",
          user_name: "Alice",
          color: "#3B82F6"
        })

      assert html =~ "<svg"
      assert html =~ "Alice"
    end

    test "has phx-hook attribute" do
      html =
        render_component(&H.render_cursor_chat/1, %{
          id: "chat-hook",
          user_name: "Alice",
          color: "#3B82F6"
        })

      assert html =~ ~s(phx-hook="PhiaCollabCursorChat")
    end

    test "shows message bubble when message is set" do
      html =
        render_component(&H.render_cursor_chat/1, %{
          id: "chat-msg",
          user_name: "Alice",
          color: "#3B82F6",
          message: "Hello there!"
        })

      assert html =~ "Hello there!"
      assert html =~ "data-cursor-chat-message"
    end

    test "does not show message bubble when message is nil" do
      html =
        render_component(&H.render_cursor_chat/1, %{
          id: "chat-no-msg",
          user_name: "Alice",
          color: "#3B82F6",
          message: nil
        })

      refute html =~ "data-cursor-chat-message"
    end

    test "shows input when show_input is true" do
      html =
        render_component(&H.render_cursor_chat/1, %{
          id: "chat-input",
          user_name: "Alice",
          color: "#3B82F6",
          show_input: true
        })

      assert html =~ "data-cursor-chat-input"
      assert html =~ "<input"
      assert html =~ ~s(placeholder="Say something...")
    end

    test "does not show input when show_input is false" do
      html =
        render_component(&H.render_cursor_chat/1, %{
          id: "chat-no-input",
          user_name: "Alice",
          color: "#3B82F6",
          show_input: false
        })

      refute html =~ "data-cursor-chat-input"
    end

    test "positions at given coordinates" do
      html =
        render_component(&H.render_cursor_chat/1, %{
          id: "chat-pos",
          user_name: "Alice",
          color: "#3B82F6",
          x: 200,
          y: 150
        })

      assert html =~ "translate(200px, 150px)"
    end

    test "applies user color to message bubble" do
      html =
        render_component(&H.render_cursor_chat/1, %{
          id: "chat-color",
          user_name: "Alice",
          color: "#EF4444",
          message: "Hello!"
        })

      assert html =~ "background-color: #EF4444"
    end

    test "input has pointer-events-auto for interactivity" do
      html =
        render_component(&H.render_cursor_chat/1, %{
          id: "chat-pe",
          user_name: "Alice",
          color: "#3B82F6",
          show_input: true
        })

      assert html =~ "pointer-events-auto"
    end

    test "applies custom class" do
      html =
        render_component(&H.render_cursor_chat/1, %{
          id: "chat-class",
          user_name: "Alice",
          color: "#3B82F6",
          class: "my-chat-class"
        })

      assert html =~ "my-chat-class"
    end
  end
end
