defmodule PhiaUi.Components.FloatButtonTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.FloatButton

    def render_simple(assigns) do
      ~H"""
      <.float_button icon="plus" on_click="new_item" aria_label="Create new item" />
      """
    end

    def render_bottom_left(assigns) do
      ~H"""
      <.float_button icon="plus" on_click="new_item" position={:bottom_left} />
      """
    end

    def render_top_right(assigns) do
      ~H"""
      <.float_button icon="plus" on_click="new_item" position={:top_right} />
      """
    end

    def render_top_left(assigns) do
      ~H"""
      <.float_button icon="plus" on_click="new_item" position={:top_left} />
      """
    end

    def render_default_position(assigns) do
      ~H"""
      <.float_button icon="plus" on_click="new_item" />
      """
    end

    def render_speed_dial(assigns) do
      ~H"""
      <.float_button position={:bottom_right}>
        <:main icon="menu" aria_label="Actions" />
        <:item icon="edit" on_click="edit" label="Edit" />
        <:item icon="share" on_click="share" label="Share" />
      </.float_button>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # Simple button
  # ---------------------------------------------------------------------------

  describe "float_button/1 simple" do
    test "renders button element" do
      html = render_component(&H.render_simple/1, %{})
      assert html =~ "<button"
    end

    test "button has type=button" do
      html = render_component(&H.render_simple/1, %{})
      assert html =~ ~s(type="button")
    end

    test "button has phx-click attr" do
      html = render_component(&H.render_simple/1, %{})
      assert html =~ ~s(phx-click="new_item")
    end

    test "button has aria-label" do
      html = render_component(&H.render_simple/1, %{})
      assert html =~ ~s(aria-label="Create new item")
    end

    test "button has h-14 class" do
      html = render_component(&H.render_simple/1, %{})
      assert html =~ "h-14"
    end

    test "button has w-14 class" do
      html = render_component(&H.render_simple/1, %{})
      assert html =~ "w-14"
    end

    test "button has rounded-full class" do
      html = render_component(&H.render_simple/1, %{})
      assert html =~ "rounded-full"
    end

    test "button has bg-primary class" do
      html = render_component(&H.render_simple/1, %{})
      assert html =~ "bg-primary"
    end

    test "renders fixed positioning class" do
      html = render_component(&H.render_simple/1, %{})
      assert html =~ "fixed"
    end

    test "bottom_right position has bottom-6 and right-6 classes" do
      html = render_component(&H.render_simple/1, %{})
      assert html =~ "bottom-6"
      assert html =~ "right-6"
    end
  end

  # ---------------------------------------------------------------------------
  # Position variants
  # ---------------------------------------------------------------------------

  describe "float_button/1 position variants" do
    test "bottom_left has left-6 class" do
      html = render_component(&H.render_bottom_left/1, %{})
      assert html =~ "left-6"
    end

    test "top_right has top-6 class" do
      html = render_component(&H.render_top_right/1, %{})
      assert html =~ "top-6"
    end

    test "top_left has top-6 and left-6 classes" do
      html = render_component(&H.render_top_left/1, %{})
      assert html =~ "top-6"
      assert html =~ "left-6"
    end

    test "default position is bottom_right" do
      html = render_component(&H.render_default_position/1, %{})
      assert html =~ "bottom-6"
      assert html =~ "right-6"
    end
  end

  # ---------------------------------------------------------------------------
  # Speed dial
  # ---------------------------------------------------------------------------

  describe "float_button/1 speed dial" do
    test "renders wrapping div when items given" do
      html = render_component(&H.render_speed_dial/1, %{})
      assert html =~ "<div"
    end

    test "renders main button" do
      html = render_component(&H.render_speed_dial/1, %{})
      assert html =~ ~s(aria-label="Actions")
    end

    test "renders item buttons" do
      html = render_component(&H.render_speed_dial/1, %{})
      assert html =~ ~s(phx-click="edit")
      assert html =~ ~s(phx-click="share")
    end

    test "item label text rendered" do
      html = render_component(&H.render_speed_dial/1, %{})
      assert html =~ "Edit"
      assert html =~ "Share"
    end
  end
end
