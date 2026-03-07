defmodule PhiaUi.Components.ChipNavTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ChipNav

    def render_nav(assigns) do
      ~H"""
      <.chip_nav>
        <.chip_nav_item>All</.chip_nav_item>
        <.chip_nav_item active={true}>Active</.chip_nav_item>
      </.chip_nav>
      """
    end

    def render_not_scrollable(assigns) do
      ~H"""
      <.chip_nav scrollable={false}>
        <.chip_nav_item>Item</.chip_nav_item>
      </.chip_nav>
      """
    end

    def render_outline(assigns) do
      ~H"""
      <.chip_nav>
        <.chip_nav_item variant={:outline}>Outline</.chip_nav_item>
      </.chip_nav>
      """
    end

    def render_ghost(assigns) do
      ~H"""
      <.chip_nav>
        <.chip_nav_item variant={:ghost}>Ghost</.chip_nav_item>
      </.chip_nav>
      """
    end

    def render_with_href(assigns) do
      ~H"""
      <.chip_nav>
        <.chip_nav_item href="/tag/elixir">Elixir</.chip_nav_item>
      </.chip_nav>
      """
    end

    def render_with_on_click(assigns) do
      ~H"""
      <.chip_nav>
        <.chip_nav_item on_click="filter">Filter</.chip_nav_item>
      </.chip_nav>
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.chip_nav>
        <.chip_nav_item disabled={true}>Disabled</.chip_nav_item>
      </.chip_nav>
      """
    end

    def render_with_icon(assigns) do
      ~H"""
      <.chip_nav>
        <.chip_nav_item>
          <:icon><span>*</span></:icon>
          Tagged
        </.chip_nav_item>
      </.chip_nav>
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.chip_nav class="my-chips">
        <.chip_nav_item>Item</.chip_nav_item>
      </.chip_nav>
      """
    end
  end

  describe "chip_nav/1" do
    test "renders div container" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ "<div"
    end

    test "scrollable=true adds overflow-x-auto" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ "overflow-x-auto"
    end

    test "scrollable=false omits overflow-x-auto" do
      html = render_component(&H.render_not_scrollable/1, %{})
      refute html =~ "overflow-x-auto"
    end

    test "custom class applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-chips"
    end
  end

  describe "chip_nav_item/1" do
    test "renders item content" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ "All"
      assert html =~ "Active"
    end

    test "active item has bg-primary" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ "bg-primary"
    end

    test "active item has aria-current=page" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ ~s(aria-current="page")
    end

    test "outline variant has border class" do
      html = render_component(&H.render_outline/1, %{})
      assert html =~ "border"
    end

    test "ghost variant has bg-transparent" do
      html = render_component(&H.render_ghost/1, %{})
      assert html =~ "bg-transparent"
    end

    test "renders as anchor when href given" do
      html = render_component(&H.render_with_href/1, %{})
      assert html =~ "<a"
      assert html =~ ~s(href="/tag/elixir")
    end

    test "renders as button by default" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ "<button"
    end

    test "on_click sets phx-click" do
      html = render_component(&H.render_with_on_click/1, %{})
      assert html =~ ~s(phx-click="filter")
    end

    test "disabled adds opacity-50" do
      html = render_component(&H.render_disabled/1, %{})
      assert html =~ "opacity-50"
    end

    test "icon slot renders" do
      html = render_component(&H.render_with_icon/1, %{})
      assert html =~ "*"
    end

    test "items are whitespace-nowrap" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ "whitespace-nowrap"
    end

    test "items are rounded-full" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ "rounded-full"
    end
  end
end
