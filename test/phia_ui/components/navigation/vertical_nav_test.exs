defmodule PhiaUi.Components.VerticalNavTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.VerticalNav

    def render_nav(assigns) do
      ~H"""
      <.vertical_nav>
        <.vertical_nav_item href="/dashboard">Dashboard</.vertical_nav_item>
        <.vertical_nav_item href="/settings" active={true}>Settings</.vertical_nav_item>
      </.vertical_nav>
      """
    end

    def render_item_button(assigns) do
      ~H"""
      <.vertical_nav>
        <.vertical_nav_item on_click="goto_home">Home</.vertical_nav_item>
      </.vertical_nav>
      """
    end

    def render_item_with_icon(assigns) do
      ~H"""
      <.vertical_nav>
        <.vertical_nav_item href="/inbox">
          <:icon><span>I</span></:icon>
          Inbox
        </.vertical_nav_item>
      </.vertical_nav>
      """
    end

    def render_item_with_badge(assigns) do
      ~H"""
      <.vertical_nav>
        <.vertical_nav_item href="/notifications" badge="9+">Notifications</.vertical_nav_item>
      </.vertical_nav>
      """
    end

    def render_item_disabled(assigns) do
      ~H"""
      <.vertical_nav>
        <.vertical_nav_item href="/locked" disabled={true}>Locked</.vertical_nav_item>
      </.vertical_nav>
      """
    end

    def render_group(assigns) do
      ~H"""
      <.vertical_nav>
        <.vertical_nav_group label="Analytics">
          <.vertical_nav_item href="/analytics/revenue">Revenue</.vertical_nav_item>
          <.vertical_nav_item href="/analytics/users">Users</.vertical_nav_item>
        </.vertical_nav_group>
      </.vertical_nav>
      """
    end

    def render_group_open(assigns) do
      ~H"""
      <.vertical_nav>
        <.vertical_nav_group label="Tools" open={true}>
          <.vertical_nav_item href="/tool">Tool</.vertical_nav_item>
        </.vertical_nav_group>
      </.vertical_nav>
      """
    end

    def render_separator(assigns) do
      ~H"""
      <.vertical_nav>
        <.vertical_nav_item href="/a">A</.vertical_nav_item>
        <.vertical_nav_separator />
        <.vertical_nav_item href="/b">B</.vertical_nav_item>
      </.vertical_nav>
      """
    end

    def render_separator_with_label(assigns) do
      ~H"""
      <.vertical_nav>
        <.vertical_nav_separator label="More" />
      </.vertical_nav>
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.vertical_nav class="my-nav">
        <.vertical_nav_item href="/">Home</.vertical_nav_item>
      </.vertical_nav>
      """
    end
  end

  describe "vertical_nav/1" do
    test "renders nav element" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ "<nav"
    end

    test "has flex flex-col" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ "flex-col"
    end

    test "custom class applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-nav"
    end
  end

  describe "vertical_nav_item/1" do
    test "renders label" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ "Dashboard"
    end

    test "renders as anchor when href given" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ "<a"
      assert html =~ ~s(href="/dashboard")
    end

    test "renders as button when no href" do
      html = render_component(&H.render_item_button/1, %{})
      assert html =~ "<button"
    end

    test "active item has bg-accent" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ "bg-accent text-accent-foreground"
    end

    test "active item has aria-current=page" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ ~s(aria-current="page")
    end

    test "disabled adds pointer-events-none" do
      html = render_component(&H.render_item_disabled/1, %{})
      assert html =~ "pointer-events-none"
    end

    test "icon slot renders" do
      html = render_component(&H.render_item_with_icon/1, %{})
      assert html =~ "I"
    end

    test "badge renders" do
      html = render_component(&H.render_item_with_badge/1, %{})
      assert html =~ "9+"
    end
  end

  describe "vertical_nav_group/1" do
    test "renders details element" do
      html = render_component(&H.render_group/1, %{})
      assert html =~ "<details"
    end

    test "renders label in summary" do
      html = render_component(&H.render_group/1, %{})
      assert html =~ "Analytics"
    end

    test "renders child items" do
      html = render_component(&H.render_group/1, %{})
      assert html =~ "Revenue"
      assert html =~ "Users"
    end

    test "open=true sets open attribute" do
      html = render_component(&H.render_group_open/1, %{})
      assert html =~ "open"
    end

    test "chevron has details-open:rotate-90" do
      html = render_component(&H.render_group/1, %{})
      assert html =~ "details-open:rotate-90"
    end
  end

  describe "vertical_nav_separator/1" do
    test "renders hr element" do
      html = render_component(&H.render_separator/1, %{})
      assert html =~ "<hr"
    end

    test "with label renders label text" do
      html = render_component(&H.render_separator_with_label/1, %{})
      assert html =~ "More"
    end
  end
end
