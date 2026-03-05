defmodule PhiaUi.Components.MenubarTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Menubar

    def render_menubar(assigns) do
      ~H"""
      <.menubar id="main-menubar">
        <.menubar_menu>
          <.menubar_trigger>File</.menubar_trigger>
          <.menubar_content>
            <.menubar_item on_click="new_file">New File</.menubar_item>
            <.menubar_separator />
            <.menubar_item on_click="save" shortcut="⌘S">Save</.menubar_item>
          </.menubar_content>
        </.menubar_menu>
        <.menubar_menu>
          <.menubar_trigger>Edit</.menubar_trigger>
          <.menubar_content>
            <.menubar_item disabled>Undo</.menubar_item>
          </.menubar_content>
        </.menubar_menu>
      </.menubar>
      """
    end

    def render_menubar_with_class(assigns) do
      ~H"""
      <.menubar id="mb-custom" class="my-custom-class">
        <.menubar_menu>
          <.menubar_trigger>File</.menubar_trigger>
          <.menubar_content>
            <.menubar_item>Item</.menubar_item>
          </.menubar_content>
        </.menubar_menu>
      </.menubar>
      """
    end

    def render_menubar_menu_with_class(assigns) do
      ~H"""
      <.menubar id="mb-menu-class">
        <.menubar_menu class="menu-custom-class">
          <.menubar_trigger>File</.menubar_trigger>
          <.menubar_content>
            <.menubar_item>Item</.menubar_item>
          </.menubar_content>
        </.menubar_menu>
      </.menubar>
      """
    end

    def render_menubar_trigger_disabled(assigns) do
      ~H"""
      <.menubar id="mb-trigger-disabled">
        <.menubar_menu>
          <.menubar_trigger disabled>Disabled Trigger</.menubar_trigger>
          <.menubar_content>
            <.menubar_item>Item</.menubar_item>
          </.menubar_content>
        </.menubar_menu>
      </.menubar>
      """
    end

    def render_menubar_item_disabled(assigns) do
      ~H"""
      <.menubar id="mb-item-disabled">
        <.menubar_menu>
          <.menubar_trigger>File</.menubar_trigger>
          <.menubar_content>
            <.menubar_item disabled>Disabled Item</.menubar_item>
          </.menubar_content>
        </.menubar_menu>
      </.menubar>
      """
    end

    def render_menubar_item_with_shortcut(assigns) do
      ~H"""
      <.menubar id="mb-shortcut">
        <.menubar_menu>
          <.menubar_trigger>File</.menubar_trigger>
          <.menubar_content>
            <.menubar_item on_click="save" shortcut="⌘S">Save</.menubar_item>
          </.menubar_content>
        </.menubar_menu>
      </.menubar>
      """
    end

    def render_menubar_separator(assigns) do
      ~H"""
      <.menubar id="mb-sep">
        <.menubar_menu>
          <.menubar_trigger>File</.menubar_trigger>
          <.menubar_content>
            <.menubar_item>New</.menubar_item>
            <.menubar_separator />
            <.menubar_item>Open</.menubar_item>
          </.menubar_content>
        </.menubar_menu>
      </.menubar>
      """
    end

    def render_menubar_separator_with_class(assigns) do
      ~H"""
      <.menubar id="mb-sep-class">
        <.menubar_menu>
          <.menubar_trigger>File</.menubar_trigger>
          <.menubar_content>
            <.menubar_separator class="sep-custom-class" />
          </.menubar_content>
        </.menubar_menu>
      </.menubar>
      """
    end
  end

  defp render_menubar, do: render_component(&H.render_menubar/1, %{})
  defp render_menubar_with_class, do: render_component(&H.render_menubar_with_class/1, %{})

  defp render_menubar_menu_with_class,
    do: render_component(&H.render_menubar_menu_with_class/1, %{})

  defp render_menubar_trigger_disabled,
    do: render_component(&H.render_menubar_trigger_disabled/1, %{})

  defp render_menubar_item_disabled,
    do: render_component(&H.render_menubar_item_disabled/1, %{})

  defp render_menubar_item_with_shortcut,
    do: render_component(&H.render_menubar_item_with_shortcut/1, %{})

  defp render_menubar_separator, do: render_component(&H.render_menubar_separator/1, %{})

  defp render_menubar_separator_with_class,
    do: render_component(&H.render_menubar_separator_with_class/1, %{})

  # ---------------------------------------------------------------------------
  # menubar/1
  # ---------------------------------------------------------------------------

  describe "menubar/1" do
    test "renders with role=menubar" do
      assert render_menubar() =~ ~s(role="menubar")
    end

    test "renders inner_block content" do
      html = render_menubar()
      assert html =~ "File"
      assert html =~ "Edit"
    end

    test "has flex layout class" do
      assert render_menubar() =~ "flex"
    end

    test "renders custom class" do
      assert render_menubar_with_class() =~ "my-custom-class"
    end
  end

  # ---------------------------------------------------------------------------
  # menubar_menu/1
  # ---------------------------------------------------------------------------

  describe "menubar_menu/1" do
    test "renders relative container" do
      assert render_menubar() =~ "relative"
    end

    test "has data-menubar-menu attribute" do
      assert render_menubar() =~ "data-menubar-menu"
    end

    test "renders inner_block content" do
      assert render_menubar() =~ "File"
    end

    test "renders custom class" do
      assert render_menubar_menu_with_class() =~ "menu-custom-class"
    end
  end

  # ---------------------------------------------------------------------------
  # menubar_trigger/1
  # ---------------------------------------------------------------------------

  describe "menubar_trigger/1" do
    test "renders a button element" do
      assert render_menubar() =~ "<button"
    end

    test "has role=menubutton" do
      assert render_menubar() =~ ~s(role="menubutton")
    end

    test "has aria-haspopup=menu" do
      assert render_menubar() =~ ~s(aria-haspopup="menu")
    end

    test "has aria-expanded=false by default" do
      assert render_menubar() =~ ~s(aria-expanded="false")
    end

    test "has hover:bg-accent class" do
      assert render_menubar() =~ "hover:bg-accent"
    end

    test "renders disabled attribute when disabled=true" do
      assert render_menubar_trigger_disabled() =~ "disabled"
    end

    test "renders trigger label content" do
      html = render_menubar()
      assert html =~ "File"
      assert html =~ "Edit"
    end
  end

  # ---------------------------------------------------------------------------
  # menubar_content/1
  # ---------------------------------------------------------------------------

  describe "menubar_content/1" do
    test "renders with role=menu" do
      assert render_menubar() =~ ~s(role="menu")
    end

    test "has hidden class initially" do
      assert render_menubar() =~ "hidden"
    end

    test "has absolute positioning class" do
      assert render_menubar() =~ "absolute"
    end

    test "has data-menubar-content attribute" do
      assert render_menubar() =~ "data-menubar-content"
    end
  end

  # ---------------------------------------------------------------------------
  # menubar_item/1
  # ---------------------------------------------------------------------------

  describe "menubar_item/1" do
    test "renders a button element" do
      assert render_menubar() =~ "<button"
    end

    test "has role=menuitem" do
      assert render_menubar() =~ ~s(role="menuitem")
    end

    test "sets phx-click attribute with the given event" do
      assert render_menubar() =~ ~s(phx-click="new_file")
    end

    test "renders item content" do
      html = render_menubar()
      assert html =~ "New File"
      assert html =~ "Undo"
    end

    test "renders disabled attribute when disabled=true" do
      html = render_menubar_item_disabled()
      assert html =~ "disabled"
    end

    test "renders opacity-50 when disabled" do
      assert render_menubar_item_disabled() =~ "opacity-50"
    end

    test "renders shortcut text when shortcut is provided" do
      assert render_menubar_item_with_shortcut() =~ "⌘S"
    end

    test "shortcut span has ml-auto class" do
      assert render_menubar_item_with_shortcut() =~ "ml-auto"
    end

    test "has hover:bg-accent class" do
      assert render_menubar() =~ "hover:bg-accent"
    end
  end

  # ---------------------------------------------------------------------------
  # menubar_separator/1
  # ---------------------------------------------------------------------------

  describe "menubar_separator/1" do
    test "renders a div element" do
      html = render_menubar_separator()
      assert html =~ "<div"
    end

    test "has role=separator" do
      assert render_menubar_separator() =~ ~s(role="separator")
    end

    test "has bg-border class" do
      assert render_menubar_separator() =~ "bg-border"
    end
  end
end
