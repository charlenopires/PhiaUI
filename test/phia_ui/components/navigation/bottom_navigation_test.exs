defmodule PhiaUi.Components.BottomNavigationTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.BottomNavigation

    def render_bottom_nav(assigns) do
      ~H"""
      <.bottom_navigation
        items={[
          %{label: "Home", icon: "home", href: "/"},
          %{label: "Search", icon: "search", href: "/search"},
          %{label: "Profile", icon: "user", href: "/profile"}
        ]}
      />
      """
    end

    def render_with_active(assigns) do
      ~H"""
      <.bottom_navigation
        active="search"
        items={[
          %{label: "Home", icon: "home", href: "/", value: "home"},
          %{label: "Search", icon: "search", href: "/search", value: "search"},
          %{label: "Profile", icon: "user", href: "/profile", value: "profile"}
        ]}
      />
      """
    end

    def render_with_badge(assigns) do
      ~H"""
      <.bottom_navigation
        items={[
          %{label: "Messages", icon: "message", href: "/messages", badge_count: 5},
          %{label: "Home", icon: "home", href: "/"}
        ]}
      />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.bottom_navigation
        class="my-bottom-nav"
        items={[%{label: "Home", icon: "home", href: "/"}]}
      />
      """
    end

    def render_with_phx_click(assigns) do
      ~H"""
      <.bottom_navigation
        on_click="nav_item_clicked"
        items={[
          %{label: "Home", icon: "home", value: "home"},
          %{label: "Search", icon: "search", value: "search"}
        ]}
      />
      """
    end

    def render_slot_items(assigns) do
      ~H"""
      <.bottom_navigation>
        <:item label="Home" icon="home" href="/" />
        <:item label="Search" icon="search" href="/search" />
      </.bottom_navigation>
      """
    end
  end

  describe "bottom_navigation/1" do
    test "renders nav element" do
      html = render_component(&H.render_bottom_nav/1, %{})
      assert html =~ "<nav"
    end

    test "renders fixed bottom positioning class" do
      html = render_component(&H.render_bottom_nav/1, %{})
      assert html =~ "fixed"
      assert html =~ "bottom-0"
    end

    test "renders all item labels" do
      html = render_component(&H.render_bottom_nav/1, %{})
      assert html =~ "Home"
      assert html =~ "Search"
      assert html =~ "Profile"
    end

    test "renders items as links when href present" do
      html = render_component(&H.render_bottom_nav/1, %{})
      assert html =~ ~s(href="/")
    end

    test "active item has active styling" do
      html = render_component(&H.render_with_active/1, %{})
      assert html =~ "text-primary"
    end

    test "renders badge count when badge_count present" do
      html = render_component(&H.render_with_badge/1, %{})
      assert html =~ "5"
    end

    test "badge renders as span" do
      html = render_component(&H.render_with_badge/1, %{})
      assert html =~ "<span"
    end

    test "custom class applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-bottom-nav"
    end

    test "with on_click renders phx-click" do
      html = render_component(&H.render_with_phx_click/1, %{})
      assert html =~ ~s(phx-click="nav_item_clicked")
    end

    test "has w-full class" do
      html = render_component(&H.render_bottom_nav/1, %{})
      assert html =~ "w-full"
    end

    test "has flex class for layout" do
      html = render_component(&H.render_bottom_nav/1, %{})
      assert html =~ "flex"
    end

    test "renders slot items" do
      html = render_component(&H.render_slot_items/1, %{})
      assert html =~ "Home"
      assert html =~ "Search"
    end
  end
end
