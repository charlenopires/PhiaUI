defmodule PhiaUi.Components.CommandPaletteTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.CommandPalette

    def render_palette(assigns) do
      ~H"""
      <.command_palette id="cmd" placeholder="Search commands...">
        <.command_palette_group heading="Navigation">
          <.command_palette_item id="item-home" on_select="navigate" value="home">
            Home
          </.command_palette_item>
        </.command_palette_group>
        <.command_palette_empty />
      </.command_palette>
      """
    end

    def render_item_disabled(assigns) do
      ~H"""
      <.command_palette id="cmd" placeholder="Search...">
        <.command_palette_item id="item-locked" disabled={true}>
          Locked Action
        </.command_palette_item>
      </.command_palette>
      """
    end

    def render_item_no_select(assigns) do
      ~H"""
      <.command_palette id="cmd" placeholder="Search...">
        <.command_palette_item id="item-basic">
          Basic Item
        </.command_palette_item>
      </.command_palette>
      """
    end
  end

  defp render_palette, do: render_component(&H.render_palette/1, %{})
  defp render_item_disabled, do: render_component(&H.render_item_disabled/1, %{})
  defp render_item_no_select, do: render_component(&H.render_item_no_select/1, %{})

  describe "command_palette/1" do
    test "has role=dialog" do
      assert render_palette() =~ ~s(role="dialog")
    end

    test "has aria-modal=true" do
      assert render_palette() =~ ~s(aria-modal="true")
    end

    test "starts with hidden class" do
      assert render_palette() =~ "hidden"
    end

    test "has phx-hook=PhiaCommand" do
      assert render_palette() =~ ~s(phx-hook="PhiaCommand")
    end

    test "has data-command-backdrop" do
      assert render_palette() =~ "data-command-backdrop"
    end

    test "has data-command-input" do
      assert render_palette() =~ "data-command-input"
    end

    test "has data-command-list" do
      assert render_palette() =~ "data-command-list"
    end

    test "renders placeholder on input" do
      assert render_palette() =~ ~s(placeholder="Search commands...")
    end

    test "input has role=combobox" do
      assert render_palette() =~ ~s(role="combobox")
    end

    test "has fixed inset-0 positioning" do
      assert render_palette() =~ "fixed"
      assert render_palette() =~ "inset-0"
    end
  end

  describe "command_palette_group/1" do
    test "renders group heading" do
      assert render_palette() =~ "Navigation"
    end

    test "heading has text-muted-foreground" do
      assert render_palette() =~ "text-muted-foreground"
    end
  end

  describe "command_palette_item/1" do
    test "has data-command-item attribute" do
      assert render_palette() =~ "data-command-item"
    end

    test "has role=option" do
      assert render_palette() =~ ~s(role="option")
    end

    test "has aria-selected=false initially" do
      assert render_palette() =~ ~s(aria-selected="false")
    end

    test "renders item text" do
      assert render_palette() =~ "Home"
    end

    test "has phx-click when on_select is set" do
      assert render_palette() =~ ~s(phx-click="navigate")
    end

    test "disabled item has pointer-events-none" do
      assert render_item_disabled() =~ "pointer-events-none"
    end

    test "disabled item has opacity-50" do
      assert render_item_disabled() =~ "opacity-50"
    end

    test "no phx-click when on_select is nil" do
      refute render_item_no_select() =~ "phx-click="
    end
  end

  describe "command_palette_empty/1" do
    test "renders default empty message" do
      assert render_palette() =~ "No results found"
    end

    test "has text-muted-foreground class" do
      assert render_palette() =~ "text-muted-foreground"
    end
  end
end
