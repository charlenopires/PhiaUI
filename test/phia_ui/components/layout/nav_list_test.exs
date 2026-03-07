defmodule PhiaUi.Components.Layout.NavListTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Layout.NavList

    def render_nav_list(assigns) do
      ~H"""
      <.nav_list aria_label={assigns[:aria_label] || "Navigation"} class={assigns[:class]}>
        <.nav_list_item href="/home" active={assigns[:active] || false}>
          Home
        </.nav_list_item>
        <.nav_list_item href="/settings" disabled={assigns[:disabled] || false}>
          Settings
        </.nav_list_item>
      </.nav_list>
      """
    end

    def render_nav_list_with_group(assigns) do
      ~H"""
      <.nav_list>
        <.nav_list_group title="Main">
          <.nav_list_item href="/dashboard">Dashboard</.nav_list_item>
        </.nav_list_group>
        <.nav_list_divider />
        <.nav_list_group title="Admin">
          <.nav_list_item href="/admin">Admin</.nav_list_item>
        </.nav_list_group>
      </.nav_list>
      """
    end

    def render_nav_list_button(assigns) do
      ~H"""
      <.nav_list>
        <.nav_list_item>Button item</.nav_list_item>
      </.nav_list>
      """
    end
  end

  defp render_nav_list(attrs \\ %{}) do
    render_component(&H.render_nav_list/1, attrs)
  end

  describe "nav_list/1 default" do
    test "renders a nav element" do
      assert render_nav_list() =~ "<nav"
    end

    test "renders aria-label" do
      assert render_nav_list() =~ ~s(aria-label="Navigation")
    end

    test "renders a ul" do
      assert render_nav_list() =~ "<ul"
    end

    test "renders items" do
      assert render_nav_list() =~ "Home"
      assert render_nav_list() =~ "Settings"
    end
  end

  describe "nav_list/1 custom aria_label" do
    test "custom aria-label" do
      assert render_nav_list(%{aria_label: "Sidebar nav"}) =~ ~s(aria-label="Sidebar nav")
    end
  end

  describe "nav_list_item/1 active" do
    test "active adds bg-accent class" do
      assert render_nav_list(%{active: true}) =~ "bg-accent"
    end

    test "active adds aria-current=page" do
      assert render_nav_list(%{active: true}) =~ ~s(aria-current="page")
    end

    test "not active has no bg-accent on first item by default" do
      refute render_nav_list(%{active: false}) =~ "aria-current"
    end
  end

  describe "nav_list_item/1 disabled" do
    test "disabled adds opacity-50" do
      assert render_nav_list(%{disabled: true}) =~ "opacity-50"
    end

    test "disabled adds pointer-events-none" do
      assert render_nav_list(%{disabled: true}) =~ "pointer-events-none"
    end
  end

  describe "nav_list_item/1 without href (button)" do
    test "renders a button element when no href" do
      html = render_component(&H.render_nav_list_button/1, %{})
      assert html =~ "<button"
      assert html =~ "Button item"
    end
  end

  describe "nav_list_group/1" do
    test "renders group title" do
      html = render_component(&H.render_nav_list_with_group/1, %{})
      assert html =~ "Main"
      assert html =~ "Admin"
    end

    test "title has uppercase tracking-wider" do
      html = render_component(&H.render_nav_list_with_group/1, %{})
      assert html =~ "uppercase"
      assert html =~ "tracking-wider"
    end
  end

  describe "nav_list_divider/1" do
    test "renders a thin separator" do
      html = render_component(&H.render_nav_list_with_group/1, %{})
      assert html =~ "bg-border"
    end

    test "is aria-hidden" do
      html = render_component(&H.render_nav_list_with_group/1, %{})
      assert html =~ ~s(aria-hidden="true")
    end
  end

  describe "nav_list/1 class forwarding" do
    test "forwards custom class" do
      assert render_nav_list(%{class: "w-64"}) =~ "w-64"
    end
  end
end
