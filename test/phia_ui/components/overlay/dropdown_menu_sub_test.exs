defmodule PhiaUi.Components.DropdownMenuSubTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.DropdownMenu

    def render_sub(assigns) do
      ~H"""
      <.dropdown_menu id="menu-sub">
        <.dropdown_menu_trigger>Options</.dropdown_menu_trigger>
        <.dropdown_menu_content>
          <.dropdown_menu_item phx-click="action">Action</.dropdown_menu_item>
          <.dropdown_menu_sub>
            <.dropdown_menu_sub_trigger>More</.dropdown_menu_sub_trigger>
            <.dropdown_menu_sub_content>
              <.dropdown_menu_item phx-click="sub_action">Sub Action</.dropdown_menu_item>
            </.dropdown_menu_sub_content>
          </.dropdown_menu_sub>
        </.dropdown_menu_content>
      </.dropdown_menu>
      """
    end

    def render_sub_trigger_disabled(assigns) do
      ~H"""
      <.dropdown_menu_sub>
        <.dropdown_menu_sub_trigger disabled={true}>Disabled Sub</.dropdown_menu_sub_trigger>
        <.dropdown_menu_sub_content>
          <.dropdown_menu_item>Item</.dropdown_menu_item>
        </.dropdown_menu_sub_content>
      </.dropdown_menu_sub>
      """
    end

    def render_sub_content_class(assigns) do
      ~H"""
      <.dropdown_menu_sub>
        <.dropdown_menu_sub_trigger>Trigger</.dropdown_menu_sub_trigger>
        <.dropdown_menu_sub_content class="w-64">
          <.dropdown_menu_item>Item</.dropdown_menu_item>
        </.dropdown_menu_sub_content>
      </.dropdown_menu_sub>
      """
    end
  end

  describe "dropdown_menu_sub/1" do
    test "renders relative wrapper div" do
      html = render_component(&H.render_sub/1, %{})
      assert html =~ "data-dropdown-sub"
    end

    test "renders trigger and content" do
      html = render_component(&H.render_sub/1, %{})
      assert html =~ "More"
      assert html =~ "Sub Action"
    end
  end

  describe "dropdown_menu_sub_trigger/1" do
    test "has data-dropdown-sub-trigger" do
      html = render_component(&H.render_sub/1, %{})
      assert html =~ "data-dropdown-sub-trigger"
    end

    test "has role=menuitem" do
      html = render_component(&H.render_sub/1, %{})
      assert html =~ ~s(role="menuitem")
    end

    test "has aria-haspopup=menu" do
      html = render_component(&H.render_sub/1, %{})
      assert html =~ ~s(aria-haspopup="menu")
    end

    test "renders chevron-right icon" do
      html = render_component(&H.render_sub/1, %{})
      assert html =~ "<polyline"
    end

    test "has justify-between" do
      html = render_component(&H.render_sub/1, %{})
      assert html =~ "justify-between"
    end

    test "disabled adds aria-disabled=true and opacity-50" do
      html = render_component(&H.render_sub_trigger_disabled/1, %{})
      assert html =~ ~s(aria-disabled="true")
      assert html =~ "opacity-50"
    end
  end

  describe "dropdown_menu_sub_content/1" do
    test "has data-dropdown-sub-content" do
      html = render_component(&H.render_sub/1, %{})
      assert html =~ "data-dropdown-sub-content"
    end

    test "has role=menu" do
      html = render_component(&H.render_sub/1, %{})
      # The sub content has role="menu"
      assert html =~ ~s(role="menu")
    end

    test "is hidden by default" do
      html = render_component(&H.render_sub/1, %{})
      assert html =~ "hidden"
    end

    test "is positioned left-full top-0" do
      html = render_component(&H.render_sub/1, %{})
      assert html =~ "left-full"
      assert html =~ "top-0"
    end

    test "custom class applied" do
      html = render_component(&H.render_sub_content_class/1, %{})
      assert html =~ "w-64"
    end
  end
end
