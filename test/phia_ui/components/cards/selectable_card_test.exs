defmodule PhiaUi.Components.SelectableCardTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.SelectableCard

    def render_basic(assigns) do
      ~H"""
      <.selectable_card>
        <:title>Alert Type</:title>
      </.selectable_card>
      """
    end

    def render_selected(assigns) do
      ~H"""
      <.selectable_card selected={true}>
        <:title>Plan A</:title>
      </.selectable_card>
      """
    end

    def render_not_selected(assigns) do
      ~H"""
      <.selectable_card selected={false}>
        <:title>Plan B</:title>
      </.selectable_card>
      """
    end

    def render_with_on_click(assigns) do
      ~H"""
      <.selectable_card on_click="choose" value="premium">
        <:title>Premium</:title>
      </.selectable_card>
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.selectable_card disabled={true}>
        <:title>Locked</:title>
      </.selectable_card>
      """
    end

    def render_with_icon(assigns) do
      ~H"""
      <.selectable_card>
        <:icon>★</:icon>
        <:title>Star</:title>
      </.selectable_card>
      """
    end

    def render_with_description(assigns) do
      ~H"""
      <.selectable_card>
        <:title>T</:title>
        <:description>Desc</:description>
      </.selectable_card>
      """
    end

    def render_compact(assigns) do
      ~H"""
      <.selectable_card variant={:compact}>
        <:title>Compact</:title>
      </.selectable_card>
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.selectable_card class="my-class">
        <:title>Custom</:title>
      </.selectable_card>
      """
    end

    def render_group(assigns) do
      ~H"""
      <.selectable_card_group>
        <.selectable_card>
          <:title>A</:title>
        </.selectable_card>
      </.selectable_card_group>
      """
    end
  end

  describe "selectable_card/1" do
    test "renders button element" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<button"
    end

    test "has role=radio" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(role="radio")
    end

    test "selected=true adds ring-2" do
      html = render_component(&H.render_selected/1, %{})
      assert html =~ "ring-2"
    end

    test "selected=true adds border-primary" do
      html = render_component(&H.render_selected/1, %{})
      assert html =~ "border-primary"
    end

    test "selected=false does not have ring-primary" do
      html = render_component(&H.render_not_selected/1, %{})
      refute html =~ "ring-primary"
    end

    test "selected=true has aria-checked=true" do
      html = render_component(&H.render_selected/1, %{})
      assert html =~ ~s(aria-checked="true")
    end

    test "selected=false has aria-checked=false" do
      html = render_component(&H.render_not_selected/1, %{})
      assert html =~ ~s(aria-checked="false")
    end

    test "disabled=true renders disabled attribute" do
      html = render_component(&H.render_disabled/1, %{})
      assert html =~ "disabled"
    end

    test "disabled=true has opacity-50" do
      html = render_component(&H.render_disabled/1, %{})
      assert html =~ "opacity-50"
    end

    test "with on_click has phx-click attribute" do
      html = render_component(&H.render_with_on_click/1, %{})
      assert html =~ ~s(phx-click="choose")
    end

    test "with value has phx-value-value" do
      html = render_component(&H.render_with_on_click/1, %{})
      assert html =~ ~s(phx-value-value="premium")
    end

    test "icon slot renders icon content" do
      html = render_component(&H.render_with_icon/1, %{})
      assert html =~ "★"
    end

    test "description slot renders description" do
      html = render_component(&H.render_with_description/1, %{})
      assert html =~ "Desc"
    end

    test "variant :compact has p-3" do
      html = render_component(&H.render_compact/1, %{})
      assert html =~ "p-3"
    end

    test "variant :compact does not use default p-4 exclusively" do
      html = render_component(&H.render_compact/1, %{})
      assert html =~ "p-3"
    end

    test "custom class applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-class"
    end
  end

  describe "selectable_card_group/1" do
    test "has role=radiogroup" do
      html = render_component(&H.render_group/1, %{})
      assert html =~ ~s(role="radiogroup")
    end

    test "has grid class" do
      html = render_component(&H.render_group/1, %{})
      assert html =~ "grid"
    end

    test "renders inner selectable cards" do
      html = render_component(&H.render_group/1, %{})
      assert html =~ "A"
    end
  end
end
