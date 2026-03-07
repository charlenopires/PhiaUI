defmodule PhiaUi.Components.NavRailTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.NavRail
    import PhiaUi.Components.Icon, only: [icon: 1]

    def render_collapsed(assigns) do
      ~H"""
      <.nav_rail id="test-rail" expanded={false} position={:left} variant={:default}>
        <.nav_rail_item label="Home" active={true}>
          <:icon><.icon name="home" /></:icon>
        </.nav_rail_item>
        <.nav_rail_item label="Settings" active={false}>
          <:icon><.icon name="settings" /></:icon>
        </.nav_rail_item>
      </.nav_rail>
      """
    end

    def render_expanded(assigns) do
      ~H"""
      <.nav_rail id="test-rail" expanded={true} position={:inline} variant={:default}>
        <.nav_rail_item label="Dashboard" active={false}>
          <:icon><.icon name="layout-dashboard" /></:icon>
        </.nav_rail_item>
      </.nav_rail>
      """
    end

    def render_with_href(assigns) do
      ~H"""
      <.nav_rail id="test-rail" expanded={false} position={:left} variant={:default}>
        <.nav_rail_item label="Home" href="/home" active={true}>
          <:icon><.icon name="home" /></:icon>
        </.nav_rail_item>
      </.nav_rail>
      """
    end

    def render_with_badge(assigns) do
      ~H"""
      <.nav_rail id="test-rail" expanded={false} position={:left} variant={:default}>
        <.nav_rail_item label="Notifications" badge={5} active={false}>
          <:icon><.icon name="bell" /></:icon>
        </.nav_rail_item>
      </.nav_rail>
      """
    end
  end

  defp render_collapsed, do: render_component(&H.render_collapsed/1, %{})
  defp render_expanded, do: render_component(&H.render_expanded/1, %{})
  defp render_with_href, do: render_component(&H.render_with_href/1, %{})
  defp render_with_badge, do: render_component(&H.render_with_badge/1, %{})

  describe "nav_rail/1" do
    test "renders <nav> element" do
      assert render_collapsed() =~ "<nav"
    end

    test "collapsed has w-14 class" do
      assert render_collapsed() =~ "w-14"
    end

    test "expanded has w-36 class" do
      assert render_expanded() =~ "w-36"
    end

    test "left position has fixed left-0 class" do
      assert render_collapsed() =~ "fixed"
      assert render_collapsed() =~ "left-0"
    end

    test "inline position has relative class" do
      assert render_expanded() =~ "relative"
    end
  end

  describe "nav_rail_item/1" do
    test "active item has bg-primary/10" do
      assert render_collapsed() =~ "bg-primary"
    end

    test "renders button when no href" do
      assert render_collapsed() =~ "<button"
    end

    test "renders <a> when href is set" do
      assert render_with_href() =~ ~s(href="/home")
    end

    test "active item has aria-current=page when href" do
      assert render_with_href() =~ ~s(aria-current="page")
    end

    test "label is used as aria-label" do
      assert render_collapsed() =~ ~s(aria-label="Home")
    end
  end

  describe "nav_rail_item/1 — badge" do
    test "renders badge when badge attr set" do
      assert render_with_badge() =~ "5"
    end

    test "badge has rounded-full styling" do
      assert render_with_badge() =~ "rounded-full"
    end
  end
end
