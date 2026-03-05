defmodule PhiaUi.Components.ChipTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Chip

    def render_chip(assigns) do
      ~H"""
      <.chip>React</.chip>
      """
    end

    def render_chip_with_on_click(assigns) do
      ~H"""
      <.chip on_click="toggle" value="vue">Vue</.chip>
      """
    end

    def render_chip_selected(assigns) do
      ~H"""
      <.chip on_click="toggle" value="vue" selected={true}>Vue</.chip>
      """
    end

    def render_chip_not_selected(assigns) do
      ~H"""
      <.chip on_click="toggle" value="vue" selected={false}>Vue</.chip>
      """
    end

    def render_chip_variant_default(assigns) do
      ~H"""
      <.chip variant={:default}>Default</.chip>
      """
    end

    def render_chip_variant_outline(assigns) do
      ~H"""
      <.chip variant={:outline}>Outline</.chip>
      """
    end

    def render_chip_variant_filled(assigns) do
      ~H"""
      <.chip variant={:filled}>Filled</.chip>
      """
    end

    def render_chip_size_sm(assigns) do
      ~H"""
      <.chip size={:sm}>Small</.chip>
      """
    end

    def render_chip_size_lg(assigns) do
      ~H"""
      <.chip size={:lg}>Large</.chip>
      """
    end

    def render_chip_selected_ring(assigns) do
      ~H"""
      <.chip selected={true}>Selected</.chip>
      """
    end

    def render_chip_dismissible(assigns) do
      ~H"""
      <.chip dismissible={true} on_dismiss="remove_tag" value="elixir">Elixir</.chip>
      """
    end

    def render_chip_custom_class(assigns) do
      ~H"""
      <.chip class="my-custom-class">Custom</.chip>
      """
    end

    def render_chip_group(assigns) do
      ~H"""
      <.chip_group>
        <.chip>A</.chip>
        <.chip>B</.chip>
      </.chip_group>
      """
    end

    def render_chip_group_custom_class(assigns) do
      ~H"""
      <.chip_group class="custom-group-class">
        <.chip>Tag</.chip>
      </.chip_group>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # chip/1
  # ---------------------------------------------------------------------------

  describe "chip/1" do
    test "renders chip content (inner_block)" do
      html = render_component(&H.render_chip/1, %{})
      assert html =~ "React"
    end

    test "default renders as span element" do
      html = render_component(&H.render_chip/1, %{})
      assert html =~ "<span"
      refute html =~ "<button"
    end

    test "with on_click renders as button element" do
      html = render_component(&H.render_chip_with_on_click/1, %{})
      assert html =~ "<button"
      refute html =~ "<span"
    end

    test "button has aria-pressed=false when not selected" do
      html = render_component(&H.render_chip_not_selected/1, %{})
      assert html =~ ~s(aria-pressed="false")
    end

    test "button has aria-pressed=true when selected" do
      html = render_component(&H.render_chip_selected/1, %{})
      assert html =~ ~s(aria-pressed="true")
    end

    test "variant :default has bg-secondary class" do
      html = render_component(&H.render_chip_variant_default/1, %{})
      assert html =~ "bg-secondary"
    end

    test "variant :outline has border and border-border class" do
      html = render_component(&H.render_chip_variant_outline/1, %{})
      assert html =~ "border"
      assert html =~ "border-border"
    end

    test "variant :filled has bg-primary class" do
      html = render_component(&H.render_chip_variant_filled/1, %{})
      assert html =~ "bg-primary"
    end

    test "size :sm has text-xs class" do
      html = render_component(&H.render_chip_size_sm/1, %{})
      assert html =~ "text-xs"
    end

    test "size :lg has text-base class" do
      html = render_component(&H.render_chip_size_lg/1, %{})
      assert html =~ "text-base"
    end

    test "selected=true adds ring-2 class" do
      html = render_component(&H.render_chip_selected_ring/1, %{})
      assert html =~ "ring-2"
    end

    test "dismissible=true renders dismiss button" do
      html = render_component(&H.render_chip_dismissible/1, %{})
      assert html =~ "<button"
    end

    test "dismiss button has aria-label=Remove" do
      html = render_component(&H.render_chip_dismissible/1, %{})
      assert html =~ ~s(aria-label="Remove")
    end

    test "custom class applied" do
      html = render_component(&H.render_chip_custom_class/1, %{})
      assert html =~ "my-custom-class"
    end
  end

  # ---------------------------------------------------------------------------
  # chip_group/1
  # ---------------------------------------------------------------------------

  describe "chip_group/1" do
    test "renders wrapping div" do
      html = render_component(&H.render_chip_group/1, %{})
      assert html =~ "<div"
    end

    test "renders inner_block content" do
      html = render_component(&H.render_chip_group/1, %{})
      assert html =~ "A"
      assert html =~ "B"
    end

    test "has flex class" do
      html = render_component(&H.render_chip_group/1, %{})
      assert html =~ "flex"
    end

    test "has flex-wrap class" do
      html = render_component(&H.render_chip_group/1, %{})
      assert html =~ "flex-wrap"
    end

    test "has gap-2 class" do
      html = render_component(&H.render_chip_group/1, %{})
      assert html =~ "gap-2"
    end

    test "applies custom class" do
      html = render_component(&H.render_chip_group_custom_class/1, %{})
      assert html =~ "custom-group-class"
    end
  end
end
