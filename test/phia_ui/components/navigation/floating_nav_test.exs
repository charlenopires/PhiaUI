defmodule PhiaUi.Components.FloatingNavTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.FloatingNav

    def render_nav(assigns) do
      ~H"""
      <.floating_nav>
        <.floating_nav_item label="Home" />
        <.floating_nav_item label="Search" active={true} />
      </.floating_nav>
      """
    end

    def render_sticky(assigns) do
      ~H"""
      <.floating_nav position={:sticky}>
        <.floating_nav_item label="x" />
      </.floating_nav>
      """
    end

    def render_top(assigns) do
      ~H"""
      <.floating_nav placement={:top}>
        <.floating_nav_item label="x" />
      </.floating_nav>
      """
    end

    def render_bottom_left(assigns) do
      ~H"""
      <.floating_nav placement={:bottom_left}>
        <.floating_nav_item label="x" />
      </.floating_nav>
      """
    end

    def render_with_href(assigns) do
      ~H"""
      <.floating_nav>
        <.floating_nav_item label="Home" href="/" />
      </.floating_nav>
      """
    end

    def render_with_icon(assigns) do
      ~H"""
      <.floating_nav>
        <.floating_nav_item label="Home">
          <:icon><span>H</span></:icon>
        </.floating_nav_item>
      </.floating_nav>
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.floating_nav class="my-float">
        <.floating_nav_item label="x" />
      </.floating_nav>
      """
    end
  end

  describe "floating_nav/1" do
    test "renders nav element" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ "<nav"
    end

    test "default position is fixed bottom center" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ "fixed"
      assert html =~ "bottom-6"
    end

    test "sticky position applies sticky class" do
      html = render_component(&H.render_sticky/1, %{})
      assert html =~ "sticky"
    end

    test "top placement applies top-6" do
      html = render_component(&H.render_top/1, %{})
      assert html =~ "top-6"
    end

    test "bottom_left placement applies left-6" do
      html = render_component(&H.render_bottom_left/1, %{})
      assert html =~ "left-6"
    end

    test "has rounded-full pill shape" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ "rounded-full"
    end

    test "has backdrop-blur" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ "backdrop-blur"
    end

    test "custom class applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-float"
    end
  end

  describe "floating_nav_item/1" do
    test "renders item labels" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ "Home"
      assert html =~ "Search"
    end

    test "active item has text-primary" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ "text-primary"
    end

    test "renders as anchor when href given" do
      html = render_component(&H.render_with_href/1, %{})
      assert html =~ "<a"
      assert html =~ ~s(href="/")
    end

    test "renders as button by default" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ "<button"
    end

    test "icon slot renders" do
      html = render_component(&H.render_with_icon/1, %{})
      assert html =~ "H"
    end

    test "aria-label set from label" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ ~s(aria-label="Home")
    end

    test "active item has aria-current=page" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ ~s(aria-current="page")
    end
  end
end
