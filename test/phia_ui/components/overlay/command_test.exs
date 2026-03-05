defmodule PhiaUi.Components.CommandTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Command

    def render_full(assigns) do
      ~H"""
      <.command id="cmd1">
        <.command_input id="cmd1-input" on_change="search" />
        <.command_list id="cmd1-list">
          <.command_group label="Pages">
            <.command_item on_click="nav" value="home">Home</.command_item>
            <.command_item on_click="nav" value="settings">
              Settings
              <.command_shortcut>⌘,</.command_shortcut>
            </.command_item>
          </.command_group>
          <.command_separator />
          <.command_group label="Actions">
            <.command_item on_click="action" value="logout">Logout</.command_item>
          </.command_group>
        </.command_list>
      </.command>
      """
    end

    def render_empty(assigns) do
      ~H"""
      <.command id="cmd2">
        <.command_input id="cmd2-input" on_change="search" />
        <.command_list id="cmd2-list">
          <.command_empty>No results found.</.command_empty>
        </.command_list>
      </.command>
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.command id="cmd3" class="custom-command">
        <.command_input id="cmd3-input" on_change="search" class="custom-input" />
        <.command_list id="cmd3-list" class="custom-list">
          <.command_item on_click="go" value="x" class="custom-item">Item</.command_item>
        </.command_list>
      </.command>
      """
    end

    def render_command_dialog(assigns) do
      ~H"""
      <.command_dialog id="cmd-dlg">
        <.command_input id="cmd-dlg-input" on_change="search" />
        <.command_list id="cmd-dlg-list">
          <.command_item on_click="nav" value="home">Home</.command_item>
        </.command_list>
      </.command_dialog>
      """
    end

    def render_command_dialog_with_title(assigns) do
      ~H"""
      <.command_dialog id="cmd-dlg-2" title="Global Search">
        <.command_input id="cmd-dlg-2-input" on_change="search" />
        <.command_list id="cmd-dlg-2-list">
          <.command_empty>No results.</.command_empty>
        </.command_list>
      </.command_dialog>
      """
    end
  end

  defp render_full, do: render_component(&H.render_full/1, %{})
  defp render_empty, do: render_component(&H.render_empty/1, %{})
  defp render_with_class, do: render_component(&H.render_with_class/1, %{})

  # ---------------------------------------------------------------------------
  # command/1
  # ---------------------------------------------------------------------------

  describe "command/1" do
    test "has phx-hook='PhiaCommand'" do
      assert render_full() =~ ~s(phx-hook="PhiaCommand")
    end

    test "has id attribute" do
      assert render_full() =~ ~s(id="cmd1")
    end

    test "has role='dialog'" do
      assert render_full() =~ ~s(role="dialog")
    end

    test "has aria-modal='true'" do
      assert render_full() =~ ~s(aria-modal="true")
    end

    test "hidden by default" do
      html = render_full()
      assert html =~ "hidden" or html =~ "display:none" or html =~ "opacity-0"
    end

    test "accepts :class via cn/1" do
      assert render_with_class() =~ "custom-command"
    end
  end

  # ---------------------------------------------------------------------------
  # command_input/1
  # ---------------------------------------------------------------------------

  describe "command_input/1" do
    test "renders input element" do
      assert render_full() =~ "<input"
    end

    test "has role='combobox'" do
      assert render_full() =~ ~s(role="combobox")
    end

    test "has aria-expanded='false' by default" do
      assert render_full() =~ ~s(aria-expanded="false")
    end

    test "has phx-change with on_change event" do
      assert render_full() =~ ~s(phx-change="search")
    end

    test "has data-command-input marker" do
      assert render_full() =~ "data-command-input"
    end

    test "accepts :class via cn/1" do
      assert render_with_class() =~ "custom-input"
    end
  end

  # ---------------------------------------------------------------------------
  # command_list/1
  # ---------------------------------------------------------------------------

  describe "command_list/1" do
    test "renders list container" do
      assert render_full() =~ ~s(id="cmd1-list")
    end

    test "has data-command-list marker" do
      assert render_full() =~ "data-command-list"
    end

    test "accepts :class via cn/1" do
      assert render_with_class() =~ "custom-list"
    end
  end

  # ---------------------------------------------------------------------------
  # command_empty/1
  # ---------------------------------------------------------------------------

  describe "command_empty/1" do
    test "renders empty state text" do
      assert render_empty() =~ "No results found."
    end
  end

  # ---------------------------------------------------------------------------
  # command_group/1
  # ---------------------------------------------------------------------------

  describe "command_group/1" do
    test "renders group label" do
      assert render_full() =~ "Pages"
    end

    test "renders second group label" do
      assert render_full() =~ "Actions"
    end
  end

  # ---------------------------------------------------------------------------
  # command_item/1
  # ---------------------------------------------------------------------------

  describe "command_item/1" do
    test "renders item content" do
      assert render_full() =~ "Home"
    end

    test "has phx-click with on_click event" do
      assert render_full() =~ ~s(phx-click="nav")
    end

    test "has phx-value-value with item value" do
      assert render_full() =~ ~s(phx-value-value="home")
    end

    test "has data-command-item marker" do
      assert render_full() =~ "data-command-item"
    end

    test "accepts :class via cn/1" do
      assert render_with_class() =~ "custom-item"
    end
  end

  # ---------------------------------------------------------------------------
  # command_separator/1
  # ---------------------------------------------------------------------------

  describe "command_separator/1" do
    test "renders separator element" do
      assert render_full() =~ "data-command-separator"
    end
  end

  # ---------------------------------------------------------------------------
  # command_shortcut/1
  # ---------------------------------------------------------------------------

  describe "command_shortcut/1" do
    test "renders shortcut text" do
      assert render_full() =~ "⌘,"
    end
  end

  # ---------------------------------------------------------------------------
  # command_dialog/1
  # ---------------------------------------------------------------------------

  describe "command_dialog/1" do
    test "command_dialog/1 is exported" do
      assert function_exported?(PhiaUi.Components.Command, :command_dialog, 1)
    end

    test "has phx-hook='PhiaCommand'" do
      html = render_component(&H.render_command_dialog/1, %{})
      assert html =~ ~s(phx-hook="PhiaCommand")
    end

    test "has id attribute" do
      html = render_component(&H.render_command_dialog/1, %{})
      assert html =~ ~s(id="cmd-dlg")
    end

    test "has role='dialog'" do
      html = render_component(&H.render_command_dialog/1, %{})
      assert html =~ ~s(role="dialog")
    end

    test "has aria-modal='true'" do
      html = render_component(&H.render_command_dialog/1, %{})
      assert html =~ ~s(aria-modal="true")
    end

    test "is hidden by default" do
      html = render_component(&H.render_command_dialog/1, %{})
      assert html =~ "hidden"
    end

    test "has backdrop-blur overlay" do
      html = render_component(&H.render_command_dialog/1, %{})
      assert html =~ "backdrop-blur"
    end

    test "default title is 'Command Palette'" do
      html = render_component(&H.render_command_dialog/1, %{})
      assert html =~ "Command Palette"
    end

    test "accepts custom :title as aria-label" do
      html = render_component(&H.render_command_dialog_with_title/1, %{})
      assert html =~ "Global Search"
    end

    test "renders inner content (command sub-components)" do
      html = render_component(&H.render_command_dialog/1, %{})
      assert html =~ "Home"
    end
  end
end
