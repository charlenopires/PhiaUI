defmodule PhiaUi.Components.UploadProgressTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.UploadProgress

    def render_pending(assigns) do
      ~H"""
      <.upload_progress filename="document.pdf" status={:pending} />
      """
    end

    def render_uploading(assigns) do
      ~H"""
      <.upload_progress filename="video.mp4" status={:uploading} progress={65} />
      """
    end

    def render_done(assigns) do
      ~H"""
      <.upload_progress filename="photo.jpg" status={:done} progress={100} />
      """
    end

    def render_error(assigns) do
      ~H"""
      <.upload_progress filename="file.pdf" status={:error} error_message="Network error" on_retry="retry" on_cancel="cancel" />
      """
    end

    def render_canceled(assigns) do
      ~H"""
      <.upload_progress filename="report.csv" status={:canceled} />
      """
    end

    def render_with_cancel(assigns) do
      ~H"""
      <.upload_progress filename="data.csv" status={:uploading} progress={30} on_cancel="cancel_upload" />
      """
    end
  end

  describe "upload_progress/1 rendering" do
    test "renders filename" do
      html = render_component(&H.render_pending/1, %{})
      assert html =~ "document.pdf"
    end

    test "pending shows Queued label" do
      html = render_component(&H.render_pending/1, %{})
      assert html =~ "Queued"
    end

    test "uploading shows progress percent" do
      html = render_component(&H.render_uploading/1, %{})
      assert html =~ "65%"
    end

    test "done shows Upload complete" do
      html = render_component(&H.render_done/1, %{})
      assert html =~ "Upload complete"
    end

    test "done applies green bar" do
      html = render_component(&H.render_done/1, %{})
      assert html =~ "bg-green"
    end

    test "error shows error message" do
      html = render_component(&H.render_error/1, %{})
      assert html =~ "Network error"
    end

    test "error shows retry button when on_retry set" do
      html = render_component(&H.render_error/1, %{})
      assert html =~ "Retry"
    end

    test "canceled shows line-through class" do
      html = render_component(&H.render_canceled/1, %{})
      assert html =~ "line-through"
    end

    test "canceled shows Canceled label" do
      html = render_component(&H.render_canceled/1, %{})
      assert html =~ "Canceled"
    end

    test "cancel button shown when on_cancel set and uploading" do
      html = render_component(&H.render_with_cancel/1, %{})
      assert html =~ "Cancel upload"
    end

    test "cancel button not shown when uploading without on_cancel" do
      html = render_component(&H.render_uploading/1, %{})
      refute html =~ "Cancel upload"
    end
  end
end
