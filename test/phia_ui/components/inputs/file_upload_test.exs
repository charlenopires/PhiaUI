defmodule PhiaUi.Components.FileUploadTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.FileUpload

    def render_file_upload(assigns) do
      ~H"""
      <.file_upload label="Upload Documents">
        <:empty>
          <p>Drag &amp; drop files here or browse</p>
        </:empty>
      </.file_upload>
      """
    end

    def render_with_accept(assigns) do
      ~H"""
      <.file_upload accept=".pdf,.docx" label="Upload Files">
        <:empty>Drop files</:empty>
      </.file_upload>
      """
    end

    def render_without_accept(assigns) do
      ~H"""
      <.file_upload label="Upload Files">
        <:empty>Drop files</:empty>
      </.file_upload>
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.file_upload class="custom-class" label="Upload Files">
        <:empty>Drop files</:empty>
      </.file_upload>
      """
    end

    def render_with_upload_ref(assigns) do
      ~H"""
      <.file_upload upload={%{ref: "upload-ref-1", entries: []}} label="Upload Files">
        <:empty>Drop files</:empty>
      </.file_upload>
      """
    end

    def render_with_entries(assigns) do
      ~H"""
      <.file_upload upload={%{ref: "upload-ref-1", entries: [%{client_name: "doc.pdf", progress: 75, ref: "e-1", errors: []}]}}>
        <:empty>Drop files</:empty>
        <:file :let={entry}>
          <span class="entry-name">{entry.client_name}</span>
        </:file>
      </.file_upload>
      """
    end

    def render_without_upload(assigns) do
      ~H"""
      <.file_upload label="Upload Files">
        <:empty>Drop files</:empty>
        <:file :let={_entry}>
          <span class="should-not-appear">file</span>
        </:file>
      </.file_upload>
      """
    end

    def render_entry(assigns) do
      ~H"""
      <.file_upload_entry
        entry={%{client_name: "report.pdf", progress: 60, ref: "ref-42", errors: []}}
        on_cancel="cancel_upload"
      />
      """
    end

    def render_entry_with_progress(assigns) do
      ~H"""
      <.file_upload_entry
        entry={%{client_name: "data.csv", progress: 33, ref: "ref-33", errors: []}}
        on_cancel="cancel_upload"
      />
      """
    end

    def render_entry_with_errors(assigns) do
      ~H"""
      <.file_upload_entry
        entry={%{client_name: "huge.pdf", progress: 0, ref: "ref-err", errors: ["File too large"]}}
        on_cancel="cancel_upload"
      />
      """
    end

    def render_entry_with_class(assigns) do
      ~H"""
      <.file_upload_entry
        entry={%{client_name: "test.pdf", progress: 50, ref: "ref-1", errors: []}}
        on_cancel="cancel_upload"
        class="custom-entry-class"
      />
      """
    end
  end

  # ---------------------------------------------------------------------------
  # file_upload/1
  # ---------------------------------------------------------------------------

  describe "file_upload/1" do
    test "renders wrapper div" do
      html = render_component(&H.render_file_upload/1, %{})
      assert html =~ "file-upload-wrapper"
    end

    test "renders label text" do
      html = render_component(&H.render_file_upload/1, %{})
      assert html =~ "Upload Documents"
    end

    test "renders drop zone div" do
      html = render_component(&H.render_file_upload/1, %{})
      assert html =~ "drop-zone"
    end

    test "drop zone has border-dashed class" do
      html = render_component(&H.render_file_upload/1, %{})
      assert html =~ "border-dashed"
    end

    test "drop zone has border-2 class" do
      html = render_component(&H.render_file_upload/1, %{})
      assert html =~ "border-2"
    end

    test "renders empty slot content" do
      html = render_component(&H.render_file_upload/1, %{})
      assert html =~ "Drag"
      assert html =~ "drop files here or browse"
    end

    test "renders label element" do
      html = render_component(&H.render_file_upload/1, %{})
      assert html =~ "<label"
    end

    test "renders file input (type=file)" do
      html = render_component(&H.render_file_upload/1, %{})
      assert html =~ ~s(type="file")
    end

    test "file input has sr-only class" do
      html = render_component(&H.render_file_upload/1, %{})
      assert html =~ "sr-only"
    end

    test "renders accept attr when provided" do
      html = render_component(&H.render_with_accept/1, %{})
      assert html =~ ~s(accept=".pdf,.docx")
    end

    test "renders without accept attr when not provided" do
      html = render_component(&H.render_without_accept/1, %{})
      refute html =~ ~s(accept=)
    end

    test "custom class applied" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "custom-class"
    end

    test "file list hidden when no upload entries" do
      html = render_component(&H.render_without_upload/1, %{})
      refute html =~ "should-not-appear"
    end

    test "renders phx-drop-target when upload has ref" do
      html = render_component(&H.render_with_upload_ref/1, %{})
      assert html =~ ~s(phx-drop-target="upload-ref-1")
    end
  end

  # ---------------------------------------------------------------------------
  # file_upload_entry/1
  # ---------------------------------------------------------------------------

  describe "file_upload_entry/1" do
    test "renders entry filename" do
      html = render_component(&H.render_entry/1, %{})
      assert html =~ "report.pdf"
    end

    test "renders progress bar" do
      html = render_component(&H.render_entry/1, %{})
      assert html =~ "bg-primary"
    end

    test "progress bar width reflects entry progress" do
      html = render_component(&H.render_entry_with_progress/1, %{})
      assert html =~ "width: 33%"
    end

    test "renders cancel button" do
      html = render_component(&H.render_entry/1, %{})
      assert html =~ "<button"
    end

    test "cancel button has aria-label=Cancel upload" do
      html = render_component(&H.render_entry/1, %{})
      assert html =~ ~s(aria-label="Cancel upload")
    end

    test "cancel button has phx-click with on_cancel event" do
      html = render_component(&H.render_entry/1, %{})
      assert html =~ ~s(phx-click="cancel_upload")
    end

    test "cancel button has phx-value-ref with entry ref" do
      html = render_component(&H.render_entry/1, %{})
      assert html =~ ~s(phx-value-ref="ref-42")
    end

    test "renders error messages" do
      html = render_component(&H.render_entry_with_errors/1, %{})
      assert html =~ "File too large"
      assert html =~ "text-destructive"
    end
  end
end
