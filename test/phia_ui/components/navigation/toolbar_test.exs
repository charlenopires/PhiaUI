defmodule PhiaUi.Components.ToolbarTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Toolbar

    def render_toolbar(assigns) do
      ~H"""
      <.toolbar>
        <:item aria_label="Bold">B</:item>
        <:item aria_label="Italic">I</:item>
      </.toolbar>
      """
    end

    def render_with_separator(assigns) do
      ~H"""
      <.toolbar>
        <:item aria_label="Bold">B</:item>
        <:separator />
        <:item aria_label="Link">L</:item>
      </.toolbar>
      """
    end

    def render_floating(assigns) do
      ~H"""
      <.toolbar variant={:floating}>
        <:item aria_label="Bold">B</:item>
      </.toolbar>
      """
    end

    def render_default_variant(assigns) do
      ~H"""
      <.toolbar variant={:default}>
        <:item aria_label="Bold">B</:item>
      </.toolbar>
      """
    end

    def render_size_sm(assigns) do
      ~H"""
      <.toolbar size={:sm}>
        <:item aria_label="Bold">B</:item>
      </.toolbar>
      """
    end

    def render_size_lg(assigns) do
      ~H"""
      <.toolbar size={:lg}>
        <:item aria_label="Bold">B</:item>
      </.toolbar>
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.toolbar class="my-toolbar">
        <:item aria_label="Bold">B</:item>
      </.toolbar>
      """
    end

    def render_pressed_item(assigns) do
      ~H"""
      <.toolbar>
        <:item aria_label="Bold" pressed={true}>B</:item>
        <:item aria_label="Italic" pressed={false}>I</:item>
      </.toolbar>
      """
    end

    def render_with_group(assigns) do
      ~H"""
      <.toolbar>
        <:group>
          <button type="button" aria-label="Bold">B</button>
          <button type="button" aria-label="Italic">I</button>
        </:group>
        <:item aria_label="Link">L</:item>
      </.toolbar>
      """
    end

    def render_item_on_click(assigns) do
      ~H"""
      <.toolbar>
        <:item aria_label="Bold" on_click="toggle_bold">B</:item>
      </.toolbar>
      """
    end
  end

  describe "toolbar/1" do
    test "renders root div" do
      html = render_component(&H.render_toolbar/1, %{})
      assert html =~ "<div"
    end

    test "has flex layout" do
      html = render_component(&H.render_toolbar/1, %{})
      assert html =~ "flex"
    end

    test "renders item slot content" do
      html = render_component(&H.render_toolbar/1, %{})
      assert html =~ "B"
      assert html =~ "I"
    end

    test "item has aria-label" do
      html = render_component(&H.render_toolbar/1, %{})
      assert html =~ ~s(aria-label="Bold")
    end

    test "item renders as button" do
      html = render_component(&H.render_toolbar/1, %{})
      assert html =~ "<button"
    end

    test "separator renders divider element" do
      html = render_component(&H.render_with_separator/1, %{})
      assert html =~ "separator" or html =~ ~s(role="separator") or html =~ "w-px"
    end

    test "variant :floating has shadow class" do
      html = render_component(&H.render_floating/1, %{})
      assert html =~ "shadow"
    end

    test "variant :floating has rounded class" do
      html = render_component(&H.render_floating/1, %{})
      assert html =~ "rounded"
    end

    test "variant :default without shadow-lg" do
      html = render_component(&H.render_default_variant/1, %{})
      refute html =~ "shadow-lg"
    end

    test "size :sm has text-xs" do
      html = render_component(&H.render_size_sm/1, %{})
      assert html =~ "text-xs" or html =~ "h-8"
    end

    test "size :lg has h-10" do
      html = render_component(&H.render_size_lg/1, %{})
      assert html =~ "h-10" or html =~ "text-base"
    end

    test "custom class applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-toolbar"
    end

    test "pressed item has aria-pressed=true" do
      html = render_component(&H.render_pressed_item/1, %{})
      assert html =~ ~s(aria-pressed="true")
    end

    test "non-pressed item has aria-pressed=false" do
      html = render_component(&H.render_pressed_item/1, %{})
      assert html =~ ~s(aria-pressed="false")
    end

    test "item with on_click has phx-click" do
      html = render_component(&H.render_item_on_click/1, %{})
      assert html =~ ~s(phx-click="toggle_bold")
    end

    test "has role=toolbar attribute" do
      html = render_component(&H.render_toolbar/1, %{})
      assert html =~ ~s(role="toolbar")
    end
  end
end
