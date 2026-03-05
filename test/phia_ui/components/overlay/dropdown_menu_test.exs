defmodule PhiaUi.Components.DropdownMenuTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helpers
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.DropdownMenu

    def render_dropdown_menu(assigns) do
      ~H"""
      <.dropdown_menu>
        <.dropdown_menu_trigger>Open</.dropdown_menu_trigger>
        <.dropdown_menu_content>
          <.dropdown_menu_item>Item 1</.dropdown_menu_item>
        </.dropdown_menu_content>
      </.dropdown_menu>
      """
    end

    def render_trigger(assigns) do
      ~H"""
      <.dropdown_menu>
        <.dropdown_menu_trigger>Trigger</.dropdown_menu_trigger>
        <.dropdown_menu_content></.dropdown_menu_content>
      </.dropdown_menu>
      """
    end

    def render_content(assigns) do
      ~H"""
      <.dropdown_menu>
        <.dropdown_menu_trigger>T</.dropdown_menu_trigger>
        <.dropdown_menu_content>
          <.dropdown_menu_item>Item</.dropdown_menu_item>
        </.dropdown_menu_content>
      </.dropdown_menu>
      """
    end

    attr(:disabled, :boolean, default: false)
    attr(:class, :string, default: nil)

    def render_item(assigns) do
      ~H"""
      <.dropdown_menu>
        <.dropdown_menu_trigger>T</.dropdown_menu_trigger>
        <.dropdown_menu_content>
          <.dropdown_menu_item disabled={@disabled} class={@class}>Click me</.dropdown_menu_item>
        </.dropdown_menu_content>
      </.dropdown_menu>
      """
    end

    def render_label(assigns) do
      ~H"""
      <.dropdown_menu>
        <.dropdown_menu_trigger>T</.dropdown_menu_trigger>
        <.dropdown_menu_content>
          <.dropdown_menu_label>Section</.dropdown_menu_label>
        </.dropdown_menu_content>
      </.dropdown_menu>
      """
    end

    def render_separator(assigns) do
      ~H"""
      <.dropdown_menu>
        <.dropdown_menu_trigger>T</.dropdown_menu_trigger>
        <.dropdown_menu_content>
          <.dropdown_menu_item>A</.dropdown_menu_item>
          <.dropdown_menu_separator />
          <.dropdown_menu_item>B</.dropdown_menu_item>
        </.dropdown_menu_content>
      </.dropdown_menu>
      """
    end

    def render_group(assigns) do
      ~H"""
      <.dropdown_menu>
        <.dropdown_menu_trigger>T</.dropdown_menu_trigger>
        <.dropdown_menu_content>
          <.dropdown_menu_group>
            <.dropdown_menu_item>A</.dropdown_menu_item>
            <.dropdown_menu_item>B</.dropdown_menu_item>
          </.dropdown_menu_group>
        </.dropdown_menu_content>
      </.dropdown_menu>
      """
    end

    def render_checkbox_item_checked(assigns) do
      ~H"""
      <.dropdown_menu>
        <.dropdown_menu_trigger>T</.dropdown_menu_trigger>
        <.dropdown_menu_content>
          <.dropdown_menu_checkbox_item checked={true} phx-click="toggle">
            Status bar
          </.dropdown_menu_checkbox_item>
        </.dropdown_menu_content>
      </.dropdown_menu>
      """
    end

    def render_checkbox_item_unchecked(assigns) do
      ~H"""
      <.dropdown_menu>
        <.dropdown_menu_trigger>T</.dropdown_menu_trigger>
        <.dropdown_menu_content>
          <.dropdown_menu_checkbox_item checked={false} phx-click="toggle">
            Status bar
          </.dropdown_menu_checkbox_item>
        </.dropdown_menu_content>
      </.dropdown_menu>
      """
    end

    def render_checkbox_item_disabled(assigns) do
      ~H"""
      <.dropdown_menu>
        <.dropdown_menu_trigger>T</.dropdown_menu_trigger>
        <.dropdown_menu_content>
          <.dropdown_menu_checkbox_item checked={false} disabled={true}>
            Disabled option
          </.dropdown_menu_checkbox_item>
        </.dropdown_menu_content>
      </.dropdown_menu>
      """
    end

    def render_radio_group(assigns) do
      ~H"""
      <.dropdown_menu>
        <.dropdown_menu_trigger>T</.dropdown_menu_trigger>
        <.dropdown_menu_content>
          <.dropdown_menu_radio_group>
            <.dropdown_menu_radio_item checked={true} phx-click="select" phx-value-value="light">
              Light
            </.dropdown_menu_radio_item>
            <.dropdown_menu_radio_item checked={false} phx-click="select" phx-value-value="dark">
              Dark
            </.dropdown_menu_radio_item>
          </.dropdown_menu_radio_group>
        </.dropdown_menu_content>
      </.dropdown_menu>
      """
    end

    def render_shortcut(assigns) do
      ~H"""
      <.dropdown_menu>
        <.dropdown_menu_trigger>T</.dropdown_menu_trigger>
        <.dropdown_menu_content>
          <.dropdown_menu_item>
            Profile
            <.dropdown_menu_shortcut>⌘P</.dropdown_menu_shortcut>
          </.dropdown_menu_item>
        </.dropdown_menu_content>
      </.dropdown_menu>
      """
    end

    def render_destructive_item(assigns) do
      ~H"""
      <.dropdown_menu>
        <.dropdown_menu_trigger>T</.dropdown_menu_trigger>
        <.dropdown_menu_content>
          <.dropdown_menu_item variant="destructive">Delete</.dropdown_menu_item>
        </.dropdown_menu_content>
      </.dropdown_menu>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # Criterion 1: 7 sub-componentes renderizam sem erro
  # ---------------------------------------------------------------------------

  describe "dropdown_menu/1" do
    test "renders container element" do
      html = render_component(&H.render_dropdown_menu/1, %{})
      assert html =~ "<div"
    end

    test "has relative positioning class" do
      html = render_component(&H.render_dropdown_menu/1, %{})
      assert html =~ "relative"
    end
  end

  describe "dropdown_menu_trigger/1" do
    test "renders a button element" do
      html = render_component(&H.render_trigger/1, %{})
      assert html =~ "<button"
    end

    test "renders trigger text content" do
      html = render_component(&H.render_trigger/1, %{})
      assert html =~ "Trigger"
    end

    # Criterion 2: aria-haspopup e aria-expanded
    test "has aria-haspopup=menu" do
      html = render_component(&H.render_trigger/1, %{})
      assert html =~ ~s(aria-haspopup="menu")
    end

    test "has aria-expanded=false as initial state" do
      html = render_component(&H.render_trigger/1, %{})
      assert html =~ ~s(aria-expanded="false")
    end
  end

  describe "dropdown_menu_content/1" do
    test "renders a div with role=menu" do
      html = render_component(&H.render_content/1, %{})
      assert html =~ ~s(role="menu")
    end

    # Criterion 3: position absolute
    test "has absolute positioning" do
      html = render_component(&H.render_content/1, %{})
      assert html =~ "absolute"
    end

    test "is hidden by default" do
      html = render_component(&H.render_content/1, %{})
      assert html =~ "hidden"
    end
  end

  describe "dropdown_menu_item/1" do
    # Criterion 4: role=menuitem
    test "has role=menuitem" do
      html = render_component(&H.render_item/1, %{})
      assert html =~ ~s(role="menuitem")
    end

    test "has tabindex=-1" do
      html = render_component(&H.render_item/1, %{})
      assert html =~ ~s(tabindex="-1")
    end

    test "renders item content" do
      html = render_component(&H.render_item/1, %{})
      assert html =~ "Click me"
    end

    test "disabled item has aria-disabled=true" do
      html = render_component(&H.render_item/1, %{disabled: true})
      assert html =~ ~s(aria-disabled="true")
    end

    test "disabled item has opacity class" do
      html = render_component(&H.render_item/1, %{disabled: true})
      assert html =~ "opacity-50"
    end

    test "non-disabled item has no aria-disabled" do
      html = render_component(&H.render_item/1, %{disabled: false})
      refute html =~ "aria-disabled"
    end

    test "accepts custom class" do
      html = render_component(&H.render_item/1, %{class: "text-red-500"})
      assert html =~ "text-red-500"
    end
  end

  describe "dropdown_menu_label/1" do
    test "renders label content" do
      html = render_component(&H.render_label/1, %{})
      assert html =~ "Section"
    end

    test "has label styling" do
      html = render_component(&H.render_label/1, %{})
      assert html =~ "font-semibold"
    end
  end

  describe "dropdown_menu_separator/1" do
    test "renders a separator element" do
      html = render_component(&H.render_separator/1, %{})
      assert html =~ "<hr"
    end
  end

  describe "dropdown_menu_group/1" do
    test "renders group wrapper with children" do
      html = render_component(&H.render_group/1, %{})
      assert html =~ "<div"
      assert html =~ "A"
      assert html =~ "B"
    end
  end

  # ---------------------------------------------------------------------------
  # Full composition smoke test
  # ---------------------------------------------------------------------------

  describe "full dropdown composition" do
    test "all sub-components render together without error" do
      html = render_component(&H.render_dropdown_menu/1, %{})
      assert html =~ "<button"
      assert html =~ ~s(role="menu")
      assert html =~ "Item 1"
    end
  end

  # ---------------------------------------------------------------------------
  # dropdown_menu_item/1 — destructive variant
  # ---------------------------------------------------------------------------

  describe "dropdown_menu_item/1 — destructive variant" do
    test "destructive variant adds text-destructive class" do
      html = render_component(&H.render_destructive_item/1, %{})
      assert html =~ "text-destructive"
    end

    test "default variant does not have text-destructive class" do
      html = render_component(&H.render_item/1, %{})
      refute html =~ "text-destructive"
    end
  end

  # ---------------------------------------------------------------------------
  # dropdown_menu_checkbox_item/1
  # ---------------------------------------------------------------------------

  describe "dropdown_menu_checkbox_item/1" do
    test "has role=menuitemcheckbox" do
      html = render_component(&H.render_checkbox_item_checked/1, %{})
      assert html =~ ~s(role="menuitemcheckbox")
    end

    test "has tabindex=-1" do
      html = render_component(&H.render_checkbox_item_checked/1, %{})
      assert html =~ ~s(tabindex="-1")
    end

    test "checked=true sets aria-checked='true'" do
      html = render_component(&H.render_checkbox_item_checked/1, %{})
      assert html =~ ~s(aria-checked="true")
    end

    test "checked=false sets aria-checked='false'" do
      html = render_component(&H.render_checkbox_item_unchecked/1, %{})
      assert html =~ ~s(aria-checked="false")
    end

    test "renders a checkmark SVG when checked" do
      html = render_component(&H.render_checkbox_item_checked/1, %{})
      assert html =~ "<svg"
    end

    test "renders item content" do
      html = render_component(&H.render_checkbox_item_checked/1, %{})
      assert html =~ "Status bar"
    end

    test "disabled item has opacity-50 class" do
      html = render_component(&H.render_checkbox_item_disabled/1, %{})
      assert html =~ "opacity-50"
    end

    test "disabled item has aria-disabled=true" do
      html = render_component(&H.render_checkbox_item_disabled/1, %{})
      assert html =~ ~s(aria-disabled="true")
    end
  end

  # ---------------------------------------------------------------------------
  # dropdown_menu_radio_group/1
  # ---------------------------------------------------------------------------

  describe "dropdown_menu_radio_group/1" do
    test "has role=group" do
      html = render_component(&H.render_radio_group/1, %{})
      assert html =~ ~s(role="group")
    end

    test "renders child radio items" do
      html = render_component(&H.render_radio_group/1, %{})
      assert html =~ "Light"
      assert html =~ "Dark"
    end
  end

  # ---------------------------------------------------------------------------
  # dropdown_menu_radio_item/1
  # ---------------------------------------------------------------------------

  describe "dropdown_menu_radio_item/1" do
    test "has role=menuitemradio" do
      html = render_component(&H.render_radio_group/1, %{})
      assert html =~ ~s(role="menuitemradio")
    end

    test "checked=true sets aria-checked='true'" do
      html = render_component(&H.render_radio_group/1, %{})
      assert html =~ ~s(aria-checked="true")
    end

    test "checked=false sets aria-checked='false'" do
      html = render_component(&H.render_radio_group/1, %{})
      assert html =~ ~s(aria-checked="false")
    end

    test "renders a bullet SVG when checked" do
      html = render_component(&H.render_radio_group/1, %{})
      assert html =~ "<svg"
    end

    test "has tabindex=-1" do
      html = render_component(&H.render_radio_group/1, %{})
      assert html =~ ~s(tabindex="-1")
    end
  end

  # ---------------------------------------------------------------------------
  # dropdown_menu_shortcut/1
  # ---------------------------------------------------------------------------

  describe "dropdown_menu_shortcut/1" do
    test "renders inside a span element" do
      html = render_component(&H.render_shortcut/1, %{})
      assert html =~ "<span"
    end

    test "renders shortcut text content" do
      html = render_component(&H.render_shortcut/1, %{})
      assert html =~ "⌘P"
    end

    test "has ml-auto for right alignment" do
      html = render_component(&H.render_shortcut/1, %{})
      assert html =~ "ml-auto"
    end

    test "has text-xs for small size" do
      html = render_component(&H.render_shortcut/1, %{})
      assert html =~ "text-xs"
    end
  end
end
