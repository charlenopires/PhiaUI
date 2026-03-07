defmodule PhiaUi.Components.DotNavigationTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.DotNavigation

    def render_nav(assigns) do
      ~H"""
      <.dot_navigation>
        <.dot_navigation_item label="Page 1" />
        <.dot_navigation_item label="Page 2" active={true} />
      </.dot_navigation>
      """
    end

    def render_pill_variant(assigns) do
      ~H"""
      <.dot_navigation variant={:pill}>
        <.dot_navigation_item variant={:pill} label="p1" />
      </.dot_navigation>
      """
    end

    def render_dash_variant(assigns) do
      ~H"""
      <.dot_navigation variant={:dash}>
        <.dot_navigation_item variant={:dash} label="p1" />
      </.dot_navigation>
      """
    end

    def render_align_start(assigns) do
      ~H"""
      <.dot_navigation align={:start}>
        <.dot_navigation_item label="x" />
      </.dot_navigation>
      """
    end

    def render_align_end(assigns) do
      ~H"""
      <.dot_navigation align={:end}>
        <.dot_navigation_item label="x" />
      </.dot_navigation>
      """
    end

    def render_gap_lg(assigns) do
      ~H"""
      <.dot_navigation gap={:lg}>
        <.dot_navigation_item label="x" />
      </.dot_navigation>
      """
    end

    def render_with_href(assigns) do
      ~H"""
      <.dot_navigation>
        <.dot_navigation_item label="Home" href="/home" />
      </.dot_navigation>
      """
    end

    def render_with_on_click(assigns) do
      ~H"""
      <.dot_navigation>
        <.dot_navigation_item label="Slide 1" on_click="goto_slide" />
      </.dot_navigation>
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.dot_navigation class="my-dots">
        <.dot_navigation_item label="x" />
      </.dot_navigation>
      """
    end
  end

  describe "dot_navigation/1" do
    test "renders nav element" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ "<nav"
    end

    test "default variant uses justify-center" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ "justify-center"
    end

    test "align :start uses justify-start" do
      html = render_component(&H.render_align_start/1, %{})
      assert html =~ "justify-start"
    end

    test "align :end uses justify-end" do
      html = render_component(&H.render_align_end/1, %{})
      assert html =~ "justify-end"
    end

    test "gap :lg applies gap-3" do
      html = render_component(&H.render_gap_lg/1, %{})
      assert html =~ "gap-3"
    end

    test "custom class forwarded" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-dots"
    end
  end

  describe "dot_navigation_item/1" do
    test "active item has bg-primary" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ "bg-primary"
    end

    test "inactive item has bg-muted" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ "bg-muted"
    end

    test "active item has aria-current=page" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ ~s(aria-current="page")
    end

    test "renders as anchor when href given" do
      html = render_component(&H.render_with_href/1, %{})
      assert html =~ ~s(href="/home")
      assert html =~ "<a"
    end

    test "renders as button by default" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ "<button"
    end

    test "button has phx-click when on_click provided" do
      html = render_component(&H.render_with_on_click/1, %{})
      assert html =~ ~s(phx-click="goto_slide")
    end

    test "circle variant has size-2 rounded-full" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ "size-2"
      assert html =~ "rounded-full"
    end

    test "pill variant has w-4" do
      html = render_component(&H.render_pill_variant/1, %{})
      assert html =~ "w-4"
    end

    test "dash variant has h-0.5" do
      html = render_component(&H.render_dash_variant/1, %{})
      assert html =~ "h-0.5"
    end

    test "aria-label set from label attr" do
      html = render_component(&H.render_nav/1, %{})
      assert html =~ ~s(aria-label="Page 1")
    end
  end
end
