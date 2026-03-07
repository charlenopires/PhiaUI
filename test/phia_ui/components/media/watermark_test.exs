defmodule PhiaUi.Components.WatermarkTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Watermark

    def render_basic(assigns) do
      ~H"""
      <.watermark content="CONFIDENTIAL">
        <div class="inner-content">Document</div>
      </.watermark>
      """
    end

    def render_custom_opacity(assigns) do
      ~H"""
      <.watermark content="Draft" opacity="0.05">
        <p>Text</p>
      </.watermark>
      """
    end

    def render_custom_rotate(assigns) do
      ~H"""
      <.watermark content="Private" rotate={-45}>
        <p>Content</p>
      </.watermark>
      """
    end

    def render_custom_font(assigns) do
      ~H"""
      <.watermark content="Internal" font_size="24px">
        <p>Content</p>
      </.watermark>
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.watermark content="Test" class="my-watermark">
        <p>Inner</p>
      </.watermark>
      """
    end
  end

  describe "watermark/1" do
    test "renders a root div with relative and overflow-hidden" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "relative"
      assert html =~ "overflow-hidden"
    end

    test "renders inner_block content" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "inner-content"
      assert html =~ "Document"
    end

    test "renders SVG element" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<svg"
    end

    test "renders pattern element" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<pattern"
    end

    test "content text appears in SVG" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "CONFIDENTIAL"
    end

    test "opacity attr is rendered" do
      html = render_component(&H.render_custom_opacity/1, %{})
      assert html =~ "opacity: 0.05"
    end

    test "rotate attr is applied in transform" do
      html = render_component(&H.render_custom_rotate/1, %{})
      assert html =~ "rotate(-45"
    end

    test "font_size attr is applied to text" do
      html = render_component(&H.render_custom_font/1, %{})
      assert html =~ "24px"
    end

    test "unique pattern id is generated" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "id=\"wm-"
    end

    test "aria-hidden is set on SVG" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(aria-hidden="true")
    end

    test "pointer-events-none on SVG overlay" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "pointer-events-none"
    end

    test "custom class applied to root" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-watermark"
    end
  end
end
