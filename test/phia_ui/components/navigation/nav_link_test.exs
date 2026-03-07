defmodule PhiaUi.Components.NavLinkTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.NavLink

    def render_link(assigns) do
      ~H"""
      <.nav_link href="/dashboard">Dashboard</.nav_link>
      """
    end

    def render_active(assigns) do
      ~H"""
      <.nav_link href="/dashboard" active={true}>Dashboard</.nav_link>
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.nav_link href="/dashboard" disabled={true}>Dashboard</.nav_link>
      """
    end

    def render_light(assigns) do
      ~H"""
      <.nav_link variant={:light} active={true}>Light</.nav_link>
      """
    end

    def render_filled(assigns) do
      ~H"""
      <.nav_link variant={:filled} active={true}>Filled</.nav_link>
      """
    end

    def render_with_icon(assigns) do
      ~H"""
      <.nav_link href="/">
        <:icon><span>*</span></:icon>
        Home
      </.nav_link>
      """
    end

    def render_with_description(assigns) do
      ~H"""
      <.nav_link href="/analytics">
        Analytics
        <:description>View your stats</:description>
      </.nav_link>
      """
    end

    def render_with_right_section(assigns) do
      ~H"""
      <.nav_link href="/inbox">
        Inbox
        <:right_section><span class="badge">5</span></:right_section>
      </.nav_link>
      """
    end

    def render_with_children(assigns) do
      ~H"""
      <.nav_link active={true}>
        Settings
        <:children>
          <.nav_link href="/settings/profile">Profile</.nav_link>
          <.nav_link href="/settings/security">Security</.nav_link>
        </:children>
      </.nav_link>
      """
    end

    def render_button(assigns) do
      ~H"""
      <.nav_link>Button Link</.nav_link>
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.nav_link href="/" class="my-link">Home</.nav_link>
      """
    end
  end

  describe "nav_link/1" do
    test "renders anchor when href given" do
      html = render_component(&H.render_link/1, %{})
      assert html =~ "<a"
      assert html =~ ~s(href="/dashboard")
    end

    test "renders button when no href" do
      html = render_component(&H.render_button/1, %{})
      assert html =~ "<button"
    end

    test "renders label" do
      html = render_component(&H.render_link/1, %{})
      assert html =~ "Dashboard"
    end

    test "active adds bg-accent" do
      html = render_component(&H.render_active/1, %{})
      assert html =~ "bg-accent"
    end

    test "active has aria-current=page" do
      html = render_component(&H.render_active/1, %{})
      assert html =~ ~s(aria-current="page")
    end

    test "disabled adds pointer-events-none opacity-50" do
      html = render_component(&H.render_disabled/1, %{})
      assert html =~ "pointer-events-none"
      assert html =~ "opacity-50"
    end

    test "light variant active uses bg-primary/10" do
      html = render_component(&H.render_light/1, %{})
      assert html =~ "bg-primary/10"
    end

    test "filled variant active uses bg-primary" do
      html = render_component(&H.render_filled/1, %{})
      assert html =~ "bg-primary"
    end

    test "icon slot renders" do
      html = render_component(&H.render_with_icon/1, %{})
      assert html =~ "*"
    end

    test "description slot renders" do
      html = render_component(&H.render_with_description/1, %{})
      assert html =~ "View your stats"
      assert html =~ "text-xs"
    end

    test "right_section slot renders" do
      html = render_component(&H.render_with_right_section/1, %{})
      assert html =~ "badge"
    end

    test "children slot renders details/summary" do
      html = render_component(&H.render_with_children/1, %{})
      assert html =~ "<details"
      assert html =~ "<summary"
      assert html =~ "Profile"
      assert html =~ "Security"
    end

    test "children details is open when active" do
      html = render_component(&H.render_with_children/1, %{})
      assert html =~ "open"
    end

    test "chevron has details-open:rotate-90" do
      html = render_component(&H.render_with_children/1, %{})
      assert html =~ "details-open:rotate-90"
    end

    test "custom class applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-link"
    end
  end
end
