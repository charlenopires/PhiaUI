defmodule PhiaUi.Components.QrCodeTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.QrCode

    def render_qr_code(assigns) do
      ~H"""
      <.qr_code value="https://phiaui.dev" />
      """
    end

    def render_with_size(assigns) do
      ~H"""
      <.qr_code value="hello" size={300} />
      """
    end

    def render_with_color(assigns) do
      ~H"""
      <.qr_code value="test" color="#ff0000" />
      """
    end

    def render_with_background(assigns) do
      ~H"""
      <.qr_code value="test" background="#f0f0f0" />
      """
    end

    def render_with_aria_label(assigns) do
      ~H"""
      <.qr_code value="https://phiaui.dev" aria_label="Scan QR code to visit PhiaUI" />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.qr_code value="test" class="my-qr-class" />
      """
    end

    def render_with_error_correction(assigns) do
      ~H"""
      <.qr_code value="test" error_correction_level={:high} />
      """
    end

    def render_with_caption(assigns) do
      ~H"""
      <.qr_code value="https://phiaui.dev" caption="Scan me!" />
      """
    end

    def render_default_aria_label(assigns) do
      ~H"""
      <.qr_code value="https://example.com" />
      """
    end
  end

  describe "qr_code/1" do
    test "renders SVG element" do
      html = render_component(&H.render_qr_code/1, %{})
      assert html =~ "<svg"
    end

    test "SVG has xmlns attribute" do
      html = render_component(&H.render_qr_code/1, %{})
      assert html =~ ~s(xmlns="http://www.w3.org/2000/svg")
    end

    test "renders rect elements (QR modules)" do
      html = render_component(&H.render_qr_code/1, %{})
      assert html =~ "<rect"
    end

    test "default size includes 200 in SVG dimensions" do
      html = render_component(&H.render_qr_code/1, %{})
      # eqrcode renders width as "200.0" float — check prefix
      assert html =~ ~s(width="200)
    end

    test "custom size includes 300 in SVG dimensions" do
      html = render_component(&H.render_with_size/1, %{})
      assert html =~ ~s(width="300)
    end

    test "custom color applied to rects" do
      html = render_component(&H.render_with_color/1, %{})
      assert html =~ "#ff0000"
    end

    test "custom background applied" do
      html = render_component(&H.render_with_background/1, %{})
      assert html =~ "#f0f0f0"
    end

    test "wrapper has role=img attribute" do
      html = render_component(&H.render_qr_code/1, %{})
      assert html =~ ~s(role="img")
    end

    test "default aria-label contains the value" do
      html = render_component(&H.render_default_aria_label/1, %{})
      assert html =~ "https://example.com"
    end

    test "custom aria-label applied" do
      html = render_component(&H.render_with_aria_label/1, %{})
      assert html =~ "Scan QR code to visit PhiaUI"
    end

    test "custom class applied to wrapper" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-qr-class"
    end

    test "with caption renders figcaption" do
      html = render_component(&H.render_with_caption/1, %{})
      assert html =~ "Scan me!"
    end

    test "SVG is inline (no img src)" do
      html = render_component(&H.render_qr_code/1, %{})
      refute html =~ "<img"
    end

    test "no XML declaration in output" do
      html = render_component(&H.render_qr_code/1, %{})
      refute html =~ "<?xml"
    end

    test "high error correction still generates valid SVG" do
      html = render_component(&H.render_with_error_correction/1, %{})
      assert html =~ "<svg"
      assert html =~ "<rect"
    end

    test "renders figure element as wrapper" do
      html = render_component(&H.render_qr_code/1, %{})
      assert html =~ "<figure"
    end
  end
end
