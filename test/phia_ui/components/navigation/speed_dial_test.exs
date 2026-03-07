defmodule PhiaUi.Components.SpeedDialTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.SpeedDial

    def render_dial(assigns) do
      ~H"""
      <.speed_dial id="fab-1">
        <.speed_dial_item label="New File" on_click="new_file">
          <:icon><span>+</span></:icon>
        </.speed_dial_item>
        <.speed_dial_item label="Upload" on_click="upload">
          <:icon><span>U</span></:icon>
        </.speed_dial_item>
      </.speed_dial>
      """
    end

    def render_bottom_left(assigns) do
      ~H"""
      <.speed_dial id="fab-bl" position={:bottom_left}>
        <.speed_dial_item label="Action" on_click="act">
          <:icon><span>A</span></:icon>
        </.speed_dial_item>
      </.speed_dial>
      """
    end

    def render_top_right(assigns) do
      ~H"""
      <.speed_dial id="fab-tr" position={:top_right}>
        <.speed_dial_item label="Action" on_click="act">
          <:icon><span>A</span></:icon>
        </.speed_dial_item>
      </.speed_dial>
      """
    end

    def render_direction_down(assigns) do
      ~H"""
      <.speed_dial id="fab-d" direction={:down}>
        <.speed_dial_item label="A" on_click="a">
          <:icon><span>A</span></:icon>
        </.speed_dial_item>
      </.speed_dial>
      """
    end

    def render_with_href(assigns) do
      ~H"""
      <.speed_dial id="fab-h">
        <.speed_dial_item label="Profile" href="/profile">
          <:icon><span>P</span></:icon>
        </.speed_dial_item>
      </.speed_dial>
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.speed_dial id="fab-dis">
        <.speed_dial_item label="Locked" on_click="locked" disabled={true}>
          <:icon><span>L</span></:icon>
        </.speed_dial_item>
      </.speed_dial>
      """
    end

    def render_custom_trigger(assigns) do
      ~H"""
      <.speed_dial id="fab-ct">
        <.speed_dial_item label="A" on_click="a">
          <:icon><span>A</span></:icon>
        </.speed_dial_item>
        <:trigger>
          <button type="button" class="custom-fab">Open</button>
        </:trigger>
      </.speed_dial>
      """
    end
  end

  describe "speed_dial/1" do
    test "renders div with id and hook" do
      html = render_component(&H.render_dial/1, %{})
      assert html =~ ~s(id="fab-1")
      assert html =~ ~s(phx-hook="PhiaSpeedDial")
    end

    test "default position bottom_right" do
      html = render_component(&H.render_dial/1, %{})
      assert html =~ "right-6"
      assert html =~ "bottom-6"
    end

    test "position bottom_left applies left-6" do
      html = render_component(&H.render_bottom_left/1, %{})
      assert html =~ "left-6"
    end

    test "position top_right applies top-6" do
      html = render_component(&H.render_top_right/1, %{})
      assert html =~ "top-6"
    end

    test "direction down applies flex-col" do
      html = render_component(&H.render_direction_down/1, %{})
      assert html =~ "flex-col"
    end

    test "default FAB button rendered when no trigger slot" do
      html = render_component(&H.render_dial/1, %{})
      assert html =~ "data-speed-dial-fab"
    end

    test "custom trigger slot renders" do
      html = render_component(&H.render_custom_trigger/1, %{})
      assert html =~ "custom-fab"
    end
  end

  describe "speed_dial_item/1" do
    test "renders item labels" do
      html = render_component(&H.render_dial/1, %{})
      assert html =~ "New File"
      assert html =~ "Upload"
    end

    test "items start with opacity-0" do
      html = render_component(&H.render_dial/1, %{})
      assert html =~ "opacity-0"
    end

    test "renders as button by default" do
      html = render_component(&H.render_dial/1, %{})
      assert html =~ "<button"
    end

    test "renders as anchor when href given" do
      html = render_component(&H.render_with_href/1, %{})
      assert html =~ "<a"
      assert html =~ ~s(href="/profile")
    end

    test "disabled button has disabled attr" do
      html = render_component(&H.render_disabled/1, %{})
      assert html =~ "disabled"
    end

    test "icon slot renders" do
      html = render_component(&H.render_dial/1, %{})
      assert html =~ "+"
      assert html =~ "U"
    end

    test "has data-speed-dial-item" do
      html = render_component(&H.render_dial/1, %{})
      assert html =~ "data-speed-dial-item"
    end
  end
end
