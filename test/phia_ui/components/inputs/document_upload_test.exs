defmodule PhiaUi.Components.DocumentUploadTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.DocumentUpload

    def render_basic(assigns) do
      ~H"""
      <.document_upload upload={%{ref: "doc-ref", entries: [], errors: []}} />
      """
    end

    def render_with_hints(assigns) do
      ~H"""
      <.document_upload
        upload={%{ref: "doc-ref", entries: [], errors: []}}
        accepted_types=".pdf, .docx"
        max_size_label="20 MB"
        label="Upload documents"
      />
      """
    end

    def render_with_entries(assigns) do
      ~H"""
      <.document_upload upload={%{ref: "doc-ref", entries: [%{client_name: "report.pdf", progress: 60, ref: "e1", errors: []}], errors: []}} on_cancel="cancel" />
      """
    end

    def render_with_error(assigns) do
      ~H"""
      <.document_upload upload={%{ref: "doc-ref", entries: [], errors: [:too_large]}} />
      """
    end

    def render_entry(assigns) do
      ~H"""
      <.document_upload_entry entry={%{client_name: "invoice.pdf", progress: 80, ref: "e2", errors: []}} on_cancel="cancel" />
      """
    end

    def render_entry_error(assigns) do
      ~H"""
      <.document_upload_entry entry={%{client_name: "big.zip", progress: 0, ref: "e3", errors: [:too_large]}} on_cancel="cancel" />
      """
    end
  end

  describe "document_upload/1 rendering" do
    test "renders drop zone with label" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<label"
    end

    test "renders default heading" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "Upload documents"
    end

    test "renders accepted types hint" do
      html = render_component(&H.render_with_hints/1, %{})
      assert html =~ ".pdf, .docx"
    end

    test "renders max size hint" do
      html = render_component(&H.render_with_hints/1, %{})
      assert html =~ "20 MB"
    end

    test "renders entries" do
      html = render_component(&H.render_with_entries/1, %{})
      assert html =~ "report.pdf"
      assert html =~ "60%"
    end

    test "renders upload-level error" do
      html = render_component(&H.render_with_error/1, %{})
      assert html =~ "File too large"
    end

    test "renders phx-drop-target" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "phx-drop-target"
    end
  end

  describe "document_upload_entry/1 rendering" do
    test "renders filename" do
      html = render_component(&H.render_entry/1, %{})
      assert html =~ "invoice.pdf"
    end

    test "renders PDF badge" do
      html = render_component(&H.render_entry/1, %{})
      assert html =~ "PDF"
    end

    test "renders progress bar" do
      html = render_component(&H.render_entry/1, %{})
      assert html =~ "80%"
    end

    test "renders entry-level error" do
      html = render_component(&H.render_entry_error/1, %{})
      assert html =~ "File too large"
    end

    test "renders remove button" do
      html = render_component(&H.render_entry/1, %{})
      assert html =~ "Remove invoice.pdf"
    end
  end
end
