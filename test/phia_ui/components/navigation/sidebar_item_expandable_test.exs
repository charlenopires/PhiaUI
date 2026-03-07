defmodule PhiaUi.Components.SidebarItemExpandableTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Sidebar

    def render_expandable(assigns) do
      ~H"""
      <.sidebar_item_expandable label="Settings">
        <.sidebar_item href="/settings/profile">Profile</.sidebar_item>
        <.sidebar_item href="/settings/security">Security</.sidebar_item>
      </.sidebar_item_expandable>
      """
    end

    def render_active(assigns) do
      ~H"""
      <.sidebar_item_expandable label="Settings" active={true}>
        <.sidebar_item href="/settings/profile">Profile</.sidebar_item>
      </.sidebar_item_expandable>
      """
    end

    def render_with_icon(assigns) do
      ~H"""
      <.sidebar_item_expandable label="Tools">
        <:icon><span>T</span></:icon>
        <.sidebar_item href="/tools">Tools</.sidebar_item>
      </.sidebar_item_expandable>
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.sidebar_item_expandable label="Section" class="my-expandable">
        <.sidebar_item href="/">Item</.sidebar_item>
      </.sidebar_item_expandable>
      """
    end
  end

  describe "sidebar_item_expandable/1" do
    test "renders details element" do
      html = render_component(&H.render_expandable/1, %{})
      assert html =~ "<details"
    end

    test "renders summary with label" do
      html = render_component(&H.render_expandable/1, %{})
      assert html =~ "<summary"
      assert html =~ "Settings"
    end

    test "renders child items" do
      html = render_component(&H.render_expandable/1, %{})
      assert html =~ "Profile"
      assert html =~ "Security"
    end

    test "active=true sets open attribute" do
      html = render_component(&H.render_active/1, %{})
      assert html =~ "open"
    end

    test "active=false does not set open" do
      html = render_component(&H.render_expandable/1, %{})
      refute html =~ ~s(open="open")
    end

    test "chevron has details-open:rotate-90" do
      html = render_component(&H.render_expandable/1, %{})
      assert html =~ "details-open:rotate-90"
    end

    test "icon slot renders" do
      html = render_component(&H.render_with_icon/1, %{})
      assert html =~ "T"
    end

    test "custom class applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-expandable"
    end

    test "summary has list-none to hide marker" do
      html = render_component(&H.render_expandable/1, %{})
      assert html =~ "list-none"
    end
  end
end
