defmodule PhiaUi.Components.DockTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Dock

    def render_dock(assigns) do
      ~H"""
      <.dock position={:inline}>
        <.dock_item label="Home">
          <:icon><span>H</span></:icon>
        </.dock_item>
        <.dock_item label="Search" active={true}>
          <:icon><span>S</span></:icon>
        </.dock_item>
      </.dock>
      """
    end

    def render_glass(assigns) do
      ~H"""
      <.dock variant={:glass} position={:inline}>
        <.dock_item label="Home">
          <:icon><span>H</span></:icon>
        </.dock_item>
      </.dock>
      """
    end

    def render_bordered(assigns) do
      ~H"""
      <.dock variant={:bordered} position={:inline}>
        <.dock_item label="Home">
          <:icon><span>H</span></:icon>
        </.dock_item>
      </.dock>
      """
    end

    def render_vertical(assigns) do
      ~H"""
      <.dock orientation={:vertical} position={:inline}>
        <.dock_item label="Home">
          <:icon><span>H</span></:icon>
        </.dock_item>
      </.dock>
      """
    end

    def render_with_href(assigns) do
      ~H"""
      <.dock position={:inline}>
        <.dock_item label="Home" href="/">
          <:icon><span>H</span></:icon>
        </.dock_item>
      </.dock>
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.dock position={:inline}>
        <.dock_item label="Home" disabled={true}>
          <:icon><span>H</span></:icon>
        </.dock_item>
      </.dock>
      """
    end

    def render_with_badge(assigns) do
      ~H"""
      <.dock position={:inline}>
        <.dock_item label="Inbox">
          <:icon><span>I</span></:icon>
          <:badge><span class="badge-count">3</span></:badge>
        </.dock_item>
      </.dock>
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.dock class="my-dock" position={:inline}>
        <.dock_item label="x">
          <:icon><span>x</span></:icon>
        </.dock_item>
      </.dock>
      """
    end
  end

  describe "dock/1" do
    test "renders div container" do
      html = render_component(&H.render_dock/1, %{})
      assert html =~ "<div"
    end

    test "has rounded-2xl" do
      html = render_component(&H.render_dock/1, %{})
      assert html =~ "rounded-2xl"
    end

    test "glass variant has backdrop-blur" do
      html = render_component(&H.render_glass/1, %{})
      assert html =~ "backdrop-blur"
    end

    test "bordered variant has border-2" do
      html = render_component(&H.render_bordered/1, %{})
      assert html =~ "border-2"
    end

    test "vertical orientation has flex-col" do
      html = render_component(&H.render_vertical/1, %{})
      assert html =~ "flex-col"
    end

    test "custom class applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-dock"
    end
  end

  describe "dock_item/1" do
    test "renders icon slot" do
      html = render_component(&H.render_dock/1, %{})
      assert html =~ "H"
      assert html =~ "S"
    end

    test "active item has bg-accent" do
      html = render_component(&H.render_dock/1, %{})
      assert html =~ "bg-accent"
    end

    test "renders tooltip with label text" do
      html = render_component(&H.render_dock/1, %{})
      assert html =~ "Home"
    end

    test "tooltip has group-hover:opacity-100" do
      html = render_component(&H.render_dock/1, %{})
      assert html =~ "group-hover:opacity-100"
    end

    test "renders as anchor when href given" do
      html = render_component(&H.render_with_href/1, %{})
      assert html =~ "<a"
      assert html =~ ~s(href="/")
    end

    test "renders as button by default" do
      html = render_component(&H.render_dock/1, %{})
      assert html =~ "<button"
    end

    test "disabled adds opacity-50" do
      html = render_component(&H.render_disabled/1, %{})
      assert html =~ "opacity-50"
    end

    test "badge slot renders" do
      html = render_component(&H.render_with_badge/1, %{})
      assert html =~ "badge-count"
    end

    test "wrapper has group class for tooltip hover" do
      html = render_component(&H.render_dock/1, %{})
      assert html =~ ~s(class="group relative")
    end
  end
end
