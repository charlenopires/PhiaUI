defmodule PhiaUi.Components.ActionSheetTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ActionSheet

    def render_sheet(assigns) do
      ~H"""
      <.action_sheet id="sheet-1">
        <.action_sheet_trigger action_sheet_id="sheet-1">
          <button type="button">Open</button>
        </.action_sheet_trigger>
        <.action_sheet_content id="sheet-1-content" title="Actions" description="Choose an action">
          <.action_sheet_item on_click="edit">Edit</.action_sheet_item>
          <.action_sheet_item on_click="delete" variant={:destructive}>Delete</.action_sheet_item>
          <.action_sheet_cancel />
        </.action_sheet_content>
      </.action_sheet>
      """
    end

    def render_item_href(assigns) do
      ~H"""
      <.action_sheet id="sheet-2">
        <.action_sheet_content id="sheet-2-content">
          <.action_sheet_item href="/view">View</.action_sheet_item>
        </.action_sheet_content>
      </.action_sheet>
      """
    end

    def render_item_with_icon(assigns) do
      ~H"""
      <.action_sheet id="sheet-3">
        <.action_sheet_content id="sheet-3-content">
          <.action_sheet_item on_click="share">
            <:icon><span>S</span></:icon>
            Share
          </.action_sheet_item>
        </.action_sheet_content>
      </.action_sheet>
      """
    end

    def render_item_disabled(assigns) do
      ~H"""
      <.action_sheet id="sheet-4">
        <.action_sheet_content id="sheet-4-content">
          <.action_sheet_item on_click="locked" disabled={true}>Locked</.action_sheet_item>
        </.action_sheet_content>
      </.action_sheet>
      """
    end

    def render_cancel_custom(assigns) do
      ~H"""
      <.action_sheet id="sheet-5">
        <.action_sheet_content id="sheet-5-content">
          <.action_sheet_cancel>Dismiss</.action_sheet_cancel>
        </.action_sheet_content>
      </.action_sheet>
      """
    end
  end

  describe "action_sheet/1" do
    test "renders div with id and hook" do
      html = render_component(&H.render_sheet/1, %{})
      assert html =~ ~s(id="sheet-1")
      assert html =~ ~s(phx-hook="PhiaActionSheet")
    end
  end

  describe "action_sheet_trigger/1" do
    test "renders trigger wrapper" do
      html = render_component(&H.render_sheet/1, %{})
      assert html =~ "data-action-sheet-trigger"
    end

    test "trigger has action_sheet_id" do
      html = render_component(&H.render_sheet/1, %{})
      assert html =~ ~s(data-action-sheet-trigger="sheet-1")
    end

    test "renders trigger content" do
      html = render_component(&H.render_sheet/1, %{})
      assert html =~ "Open"
    end
  end

  describe "action_sheet_content/1" do
    test "renders backdrop element" do
      html = render_component(&H.render_sheet/1, %{})
      assert html =~ "data-action-sheet-backdrop"
    end

    test "renders panel element" do
      html = render_component(&H.render_sheet/1, %{})
      assert html =~ "data-action-sheet-panel"
    end

    test "panel has rounded-t-2xl" do
      html = render_component(&H.render_sheet/1, %{})
      assert html =~ "rounded-t-2xl"
    end

    test "panel starts with translate-y-full" do
      html = render_component(&H.render_sheet/1, %{})
      assert html =~ "translate-y-full"
    end

    test "renders title" do
      html = render_component(&H.render_sheet/1, %{})
      assert html =~ "Actions"
    end

    test "renders description" do
      html = render_component(&H.render_sheet/1, %{})
      assert html =~ "Choose an action"
    end

    test "backdrop starts hidden" do
      html = render_component(&H.render_sheet/1, %{})
      assert html =~ "hidden"
    end
  end

  describe "action_sheet_item/1" do
    test "renders item labels" do
      html = render_component(&H.render_sheet/1, %{})
      assert html =~ "Edit"
      assert html =~ "Delete"
    end

    test "destructive variant has text-destructive" do
      html = render_component(&H.render_sheet/1, %{})
      assert html =~ "text-destructive"
    end

    test "renders as anchor when href given" do
      html = render_component(&H.render_item_href/1, %{})
      assert html =~ "<a"
      assert html =~ ~s(href="/view")
    end

    test "renders as button by default" do
      html = render_component(&H.render_sheet/1, %{})
      assert html =~ "<button"
    end

    test "icon slot renders" do
      html = render_component(&H.render_item_with_icon/1, %{})
      assert html =~ "S"
    end

    test "disabled adds pointer-events-none" do
      html = render_component(&H.render_item_disabled/1, %{})
      assert html =~ "pointer-events-none"
    end
  end

  describe "action_sheet_cancel/1" do
    test "renders cancel button" do
      html = render_component(&H.render_sheet/1, %{})
      assert html =~ "Cancel"
    end

    test "has data-action-sheet-close" do
      html = render_component(&H.render_sheet/1, %{})
      assert html =~ "data-action-sheet-close"
    end

    test "custom label renders" do
      html = render_component(&H.render_cancel_custom/1, %{})
      assert html =~ "Dismiss"
    end
  end
end
