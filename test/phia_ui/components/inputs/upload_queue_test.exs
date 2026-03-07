defmodule PhiaUi.Components.UploadQueueTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.UploadQueue

    def render_empty(assigns) do
      ~H"""
      <.upload_queue upload={%{ref: "q1", entries: [], errors: []}} />
      """
    end

    def render_empty_with_msg(assigns) do
      ~H"""
      <.upload_queue
        upload={%{ref: "q1", entries: [], errors: []}}
        show_empty={true}
        empty_label="No files yet"
      />
      """
    end

    def render_with_entries(assigns) do
      ~H"""
      <.upload_queue
        upload={%{ref: "q1", entries: [
          %{client_name: "report.pdf", progress: 50, ref: "e1", errors: []},
          %{client_name: "data.csv", progress: 100, ref: "e2", errors: []}
        ], errors: []}}
        on_cancel="cancel"
      />
      """
    end

    def render_with_upload_error(assigns) do
      ~H"""
      <.upload_queue upload={%{ref: "q1", entries: [], errors: [:too_many_files]}} />
      """
    end

    def render_single_item(assigns) do
      ~H"""
      <.upload_queue_item entry={%{client_name: "invoice.pdf", progress: 75, ref: "e3", errors: []}} on_cancel="cancel" />
      """
    end

    def render_done_item(assigns) do
      ~H"""
      <.upload_queue_item entry={%{client_name: "photo.jpg", progress: 100, ref: "e4", errors: []}} on_cancel="cancel" />
      """
    end

    def render_error_item(assigns) do
      ~H"""
      <.upload_queue_item entry={%{client_name: "huge.zip", progress: 0, ref: "e5", errors: [:too_large]}} on_cancel="cancel" />
      """
    end
  end

  describe "upload_queue/1 rendering" do
    test "renders nothing visible when empty and show_empty is false" do
      html = render_component(&H.render_empty/1, %{})
      refute html =~ "No files"
    end

    test "renders empty message when show_empty is true" do
      html = render_component(&H.render_empty_with_msg/1, %{})
      assert html =~ "No files yet"
    end

    test "renders all entries" do
      html = render_component(&H.render_with_entries/1, %{})
      assert html =~ "report.pdf"
      assert html =~ "data.csv"
    end

    test "renders upload-level error" do
      html = render_component(&H.render_with_upload_error/1, %{})
      assert html =~ "Too many files"
    end
  end

  describe "upload_queue_item/1 rendering" do
    test "renders filename" do
      html = render_component(&H.render_single_item/1, %{})
      assert html =~ "invoice.pdf"
    end

    test "renders progress percentage" do
      html = render_component(&H.render_single_item/1, %{})
      assert html =~ "75%"
    end

    test "renders PDF badge" do
      html = render_component(&H.render_single_item/1, %{})
      assert html =~ "PDF"
    end

    test "renders cancel button when not done" do
      html = render_component(&H.render_single_item/1, %{})
      assert html =~ "Cancel invoice.pdf"
    end

    test "shows Done and checkmark when progress is 100" do
      html = render_component(&H.render_done_item/1, %{})
      assert html =~ "Done"
    end

    test "does not show cancel button when done" do
      html = render_component(&H.render_done_item/1, %{})
      refute html =~ "Cancel photo.jpg"
    end

    test "renders entry error message" do
      html = render_component(&H.render_error_item/1, %{})
      assert html =~ "File too large"
    end

    test "applies destructive bar when entry has errors" do
      html = render_component(&H.render_error_item/1, %{})
      assert html =~ "bg-destructive"
    end
  end
end
