defmodule PhiaUi.Components.SidebarTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Sidebar

    attr(:id, :string, default: "sidebar-drawer")
    attr(:class, :string, default: nil)
    attr(:collapsed, :boolean, default: false)

    def render_sidebar(assigns) do
      ~H"""
      <.sidebar id={@id} class={@class} collapsed={@collapsed}>
        <:brand><span>Brand</span></:brand>
        <:nav_items><p>Nav</p></:nav_items>
        <:footer_items><p>Footer</p></:footer_items>
      </.sidebar>
      """
    end

    def render_sidebar_inner(assigns) do
      ~H"""
      <.sidebar>
        <p>Legacy Nav</p>
      </.sidebar>
      """
    end

    def render_sidebar_dark(assigns) do
      ~H"""
      <.sidebar variant={:dark}>
        <:nav_items><p>Nav</p></:nav_items>
      </.sidebar>
      """
    end

    def render_sidebar_item(assigns) do
      ~H"""
      <.sidebar_item href="/dashboard">Dashboard</.sidebar_item>
      """
    end

    def render_sidebar_item_active(assigns) do
      ~H"""
      <.sidebar_item href="/dashboard" active={true}>Dashboard</.sidebar_item>
      """
    end

    def render_sidebar_item_badge(assigns) do
      ~H"""
      <.sidebar_item href="/inbox" badge={5}>Inbox</.sidebar_item>
      """
    end

    def render_sidebar_section(assigns) do
      ~H"""
      <.sidebar_section label="Main">
        <p>item</p>
      </.sidebar_section>
      """
    end

    def render_sidebar_section_no_label(assigns) do
      ~H"""
      <.sidebar_section>
        <p>item</p>
      </.sidebar_section>
      """
    end
  end

  describe "sidebar/1" do
    test "renders aside element" do
      html = render_component(&H.render_sidebar/1, %{})
      assert html =~ "<aside"
    end

    test "renders :brand slot content" do
      html = render_component(&H.render_sidebar/1, %{})
      assert html =~ "Brand"
    end

    test "renders :nav_items slot content" do
      html = render_component(&H.render_sidebar/1, %{})
      assert html =~ "Nav"
    end

    test "renders :footer_items slot content" do
      html = render_component(&H.render_sidebar/1, %{})
      assert html =~ "Footer"
    end

    test "has w-60 width" do
      html = render_component(&H.render_sidebar/1, %{})
      assert html =~ "w-60"
    end

    test "has border-r" do
      html = render_component(&H.render_sidebar/1, %{})
      assert html =~ "border-r"
    end

    test "uses provided id" do
      html = render_component(&H.render_sidebar/1, %{id: "my-sidebar"})
      assert html =~ ~s(id="my-sidebar")
    end

    test "defaults id to sidebar-drawer" do
      html = render_component(&H.render_sidebar/1, %{})
      assert html =~ ~s(id="sidebar-drawer")
    end

    test "accepts custom class" do
      html = render_component(&H.render_sidebar/1, %{class: "shadow-lg"})
      assert html =~ "shadow-lg"
    end

    test "collapsed=true adds -translate-x-full" do
      html = render_component(&H.render_sidebar/1, %{collapsed: true})
      assert html =~ "-translate-x-full"
    end

    test "collapsed=false does not add -translate-x-full" do
      html = render_component(&H.render_sidebar/1, %{collapsed: false})
      refute html =~ "-translate-x-full"
    end

    test "variant :dark adds dark class" do
      html = render_component(&H.render_sidebar_dark/1, %{})
      assert html =~ "dark"
    end

    test "inner_block fallback renders when nav_items empty" do
      html = render_component(&H.render_sidebar_inner/1, %{})
      assert html =~ "Legacy Nav"
    end
  end

  describe "sidebar_item/1" do
    test "renders anchor element" do
      html = render_component(&H.render_sidebar_item/1, %{})
      assert html =~ "<a"
    end

    test "has href attribute" do
      html = render_component(&H.render_sidebar_item/1, %{})
      assert html =~ ~s(href="/dashboard")
    end

    test "renders label text" do
      html = render_component(&H.render_sidebar_item/1, %{})
      assert html =~ "Dashboard"
    end

    test "active=true adds bg-accent class" do
      html = render_component(&H.render_sidebar_item_active/1, %{})
      assert html =~ "bg-accent"
    end

    test "badge renders when provided" do
      html = render_component(&H.render_sidebar_item_badge/1, %{})
      assert html =~ "5"
    end

    test "badge has bg-primary class" do
      html = render_component(&H.render_sidebar_item_badge/1, %{})
      assert html =~ "bg-primary"
    end
  end

  describe "sidebar_section/1" do
    test "renders wrapping div" do
      html = render_component(&H.render_sidebar_section/1, %{})
      assert html =~ "<div"
    end

    test "renders label text" do
      html = render_component(&H.render_sidebar_section/1, %{})
      assert html =~ "Main"
    end

    test "renders inner_block content" do
      html = render_component(&H.render_sidebar_section/1, %{})
      assert html =~ "item"
    end

    test "no label element when label is nil" do
      html = render_component(&H.render_sidebar_section_no_label/1, %{})
      refute html =~ "uppercase tracking-wider"
    end
  end
end
