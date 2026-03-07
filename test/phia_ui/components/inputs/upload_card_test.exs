defmodule PhiaUi.Components.UploadCardTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.UploadCard

    def render_basic(assigns) do
      ~H"""
      <.upload_card filename="report.pdf" />
      """
    end

    def render_with_size(assigns) do
      ~H"""
      <.upload_card filename="data.csv" size_bytes={512_000} />
      """
    end

    def render_with_all(assigns) do
      ~H"""
      <.upload_card
        filename="invoice.pdf"
        size_bytes={248_320}
        uploaded_at="Mar 6, 2026"
        status={:done}
        href="/files/invoice.pdf"
        on_remove="remove_file"
      />
      """
    end

    def render_error_status(assigns) do
      ~H"""
      <.upload_card filename="broken.jpg" status={:error} />
      """
    end

    def render_with_thumbnail(assigns) do
      ~H"""
      <.upload_card filename="logo.png" thumbnail_url="https://example.com/logo.png" />
      """
    end

    def render_small_bytes(assigns) do
      ~H"""
      <.upload_card filename="tiny.txt" size_bytes={512} />
      """
    end

    def render_large_bytes(assigns) do
      ~H"""
      <.upload_card filename="big.mp4" size_bytes={1_073_741_824} />
      """
    end
  end

  describe "upload_card/1 rendering" do
    test "renders filename" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "report.pdf"
    end

    test "renders PDF file badge" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "PDF"
    end

    test "renders uploaded status badge by default" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "Uploaded"
    end

    test "renders error status badge" do
      html = render_component(&H.render_error_status/1, %{})
      assert html =~ "Failed"
    end

    test "formats bytes as KB" do
      html = render_component(&H.render_with_size/1, %{})
      assert html =~ "KB"
    end

    test "formats small bytes as B" do
      html = render_component(&H.render_small_bytes/1, %{})
      assert html =~ " B"
    end

    test "formats large bytes as GB" do
      html = render_component(&H.render_large_bytes/1, %{})
      assert html =~ "GB"
    end

    test "renders upload timestamp" do
      html = render_component(&H.render_with_all/1, %{})
      assert html =~ "Mar 6, 2026"
    end

    test "renders download link when href given" do
      html = render_component(&H.render_with_all/1, %{})
      assert html =~ "/files/invoice.pdf"
      assert html =~ "download"
    end

    test "renders remove button when on_remove given" do
      html = render_component(&H.render_with_all/1, %{})
      assert html =~ "Remove invoice.pdf"
    end

    test "does not render remove button when on_remove is nil" do
      html = render_component(&H.render_basic/1, %{})
      refute html =~ "Remove report.pdf"
    end

    test "renders thumbnail image when thumbnail_url given" do
      html = render_component(&H.render_with_thumbnail/1, %{})
      assert html =~ "https://example.com/logo.png"
      assert html =~ "<img"
    end

    test "does not render img when no thumbnail" do
      html = render_component(&H.render_basic/1, %{})
      refute html =~ "<img"
    end
  end
end
