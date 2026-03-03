defmodule PhiaUi.Components.ContextMenuTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helpers
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ContextMenu

    def render_basic(assigns) do
      ~H"""
      <.context_menu id="ctx-menu">
        <.context_menu_trigger context_menu_id="ctx-menu">
          Right-click here
        </.context_menu_trigger>
        <.context_menu_content id="ctx-menu-content">
          <.context_menu_item>Open</.context_menu_item>
          <.context_menu_separator />
          <.context_menu_checkbox_item checked={true}>Checked Item</.context_menu_checkbox_item>
          <.context_menu_label>Actions</.context_menu_label>
        </.context_menu_content>
      </.context_menu>
      """
    end

    def render_unchecked(assigns) do
      ~H"""
      <.context_menu id="ctx2">
        <.context_menu_trigger context_menu_id="ctx2">Area</.context_menu_trigger>
        <.context_menu_content id="ctx2-content">
          <.context_menu_checkbox_item checked={false}>Unchecked</.context_menu_checkbox_item>
        </.context_menu_content>
      </.context_menu>
      """
    end

    def render_label(assigns) do
      ~H"""
      <.context_menu id="ctx3">
        <.context_menu_trigger context_menu_id="ctx3">Area</.context_menu_trigger>
        <.context_menu_content id="ctx3-content">
          <.context_menu_label>My Section</.context_menu_label>
          <.context_menu_item>Action</.context_menu_item>
        </.context_menu_content>
      </.context_menu>
      """
    end

    attr(:class, :string, default: nil)

    def render_custom_class(assigns) do
      ~H"""
      <.context_menu id="ctx4" class={@class}>
        <.context_menu_trigger context_menu_id="ctx4">Area</.context_menu_trigger>
        <.context_menu_content id="ctx4-content">
          <.context_menu_item>Item</.context_menu_item>
        </.context_menu_content>
      </.context_menu>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # context_menu/1
  # ---------------------------------------------------------------------------

  describe "context_menu/1" do
    test "renders container div" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<div"
    end

    test "has relative positioning class" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "relative"
    end

    test "renders with given id" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(id="ctx-menu")
    end

    test "accepts custom class" do
      html = render_component(&H.render_custom_class/1, %{class: "my-custom"})
      assert html =~ "my-custom"
    end
  end

  # ---------------------------------------------------------------------------
  # context_menu_trigger/1
  # ---------------------------------------------------------------------------

  describe "context_menu_trigger/1" do
    test "has aria-haspopup=menu" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(aria-haspopup="menu")
    end

    test "uses PhiaContextMenu hook" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "PhiaContextMenu"
    end

    test "has data-content-id pointing to content" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(data-content-id="ctx-menu-content")
    end

    test "has data-context-trigger attribute" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "data-context-trigger"
    end

    test "renders trigger content" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "Right-click here"
    end
  end

  # ---------------------------------------------------------------------------
  # context_menu_content/1
  # ---------------------------------------------------------------------------

  describe "context_menu_content/1" do
    test "has role=menu" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(role="menu")
    end

    test "has aria-orientation=vertical" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(aria-orientation="vertical")
    end

    test "is initially hidden via display:none" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "display:none"
    end

    test "uses position:fixed" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "position:fixed"
    end

    test "has correct id" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(id="ctx-menu-content")
    end

    test "has tabindex=-1 for programmatic focus" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(tabindex="-1")
    end

    test "has z-50 for stacking" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "z-50"
    end
  end

  # ---------------------------------------------------------------------------
  # context_menu_item/1
  # ---------------------------------------------------------------------------

  describe "context_menu_item/1" do
    test "has role=menuitem" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(role="menuitem")
    end

    test "has tabindex=-1" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(tabindex="-1")
    end

    test "renders item content" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "Open"
    end

    test "has focus classes for keyboard navigation" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "focus:bg-accent"
    end
  end

  # ---------------------------------------------------------------------------
  # context_menu_separator/1
  # ---------------------------------------------------------------------------

  describe "context_menu_separator/1" do
    test "has role=separator" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(role="separator")
    end

    test "renders as hr element" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<hr"
    end

    test "has muted background" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "bg-muted"
    end
  end

  # ---------------------------------------------------------------------------
  # context_menu_checkbox_item/1
  # ---------------------------------------------------------------------------

  describe "context_menu_checkbox_item/1" do
    test "has role=menuitemcheckbox" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(role="menuitemcheckbox")
    end

    test "checked item has aria-checked=true" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(aria-checked="true")
    end

    test "checked item shows check mark" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "&#10003;"
    end

    test "unchecked item has aria-checked=false" do
      html = render_component(&H.render_unchecked/1, %{})
      assert html =~ ~s(aria-checked="false")
    end

    test "unchecked item does not show check mark" do
      html = render_component(&H.render_unchecked/1, %{})
      refute html =~ "&#10003;"
    end

    test "renders item content" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "Checked Item"
    end

    test "has tabindex=-1" do
      html = render_component(&H.render_basic/1, %{})
      # multiple tabindex=-1 are expected (items + content)
      assert html =~ ~s(tabindex="-1")
    end
  end

  # ---------------------------------------------------------------------------
  # context_menu_label/1
  # ---------------------------------------------------------------------------

  describe "context_menu_label/1" do
    test "renders label content" do
      html = render_component(&H.render_label/1, %{})
      assert html =~ "My Section"
    end

    test "has font-semibold styling" do
      html = render_component(&H.render_label/1, %{})
      assert html =~ "font-semibold"
    end

    test "has correct padding classes" do
      html = render_component(&H.render_label/1, %{})
      assert html =~ "px-2"
      assert html =~ "py-1.5"
    end
  end

  # ---------------------------------------------------------------------------
  # Full composition smoke test
  # ---------------------------------------------------------------------------

  describe "full context menu composition" do
    test "all sub-components render together without error" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(role="menu")
      assert html =~ ~s(role="menuitem")
      assert html =~ ~s(role="menuitemcheckbox")
      assert html =~ ~s(role="separator")
      assert html =~ "Open"
      assert html =~ "Checked Item"
      assert html =~ "Actions"
    end
  end
end
