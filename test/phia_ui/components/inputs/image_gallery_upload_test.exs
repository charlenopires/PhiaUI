defmodule PhiaUi.Components.ImageGalleryUploadTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ImageGalleryUpload

    def render_empty(assigns) do
      ~H"""
      <.image_gallery_upload upload={%{ref: "g1", entries: [], max_entries: 6, errors: []}} />
      """
    end

    def render_with_label(assigns) do
      ~H"""
      <.image_gallery_upload
        upload={%{ref: "g1", entries: [], max_entries: 4, errors: []}}
        label="Product images"
        description="Upload up to 4 photos"
      />
      """
    end

    def render_cols_3(assigns) do
      ~H"""
      <.image_gallery_upload upload={%{ref: "g1", entries: [], max_entries: 6, errors: []}} cols={3} />
      """
    end

    def render_cols_5(assigns) do
      ~H"""
      <.image_gallery_upload upload={%{ref: "g1", entries: [], max_entries: 6, errors: []}} cols={5} />
      """
    end

    def render_aspect_video(assigns) do
      ~H"""
      <.image_gallery_upload upload={%{ref: "g1", entries: [], max_entries: 4, errors: []}} aspect="video" />
      """
    end

    def render_with_upload_error(assigns) do
      ~H"""
      <.image_gallery_upload upload={%{ref: "g1", entries: [], max_entries: 2, errors: [:too_many_files]}} />
      """
    end

    def render_at_limit(assigns) do
      ~H"""
      <.image_gallery_upload upload={%{ref: "g1", entries: [%{ref: "e1", progress: 100, client_name: "a.jpg", errors: []}, %{ref: "e2", progress: 100, client_name: "b.jpg", errors: []}], max_entries: 2, errors: []}} />
      """
    end
  end

  describe "image_gallery_upload/1 rendering" do
    test "renders add photo cell when empty" do
      html = render_component(&H.render_empty/1, %{})
      assert html =~ "Add photo"
    end

    test "renders label and description" do
      html = render_component(&H.render_with_label/1, %{})
      assert html =~ "Product images"
      assert html =~ "Upload up to 4 photos"
    end

    test "cols 3 applies grid-cols-3" do
      html = render_component(&H.render_cols_3/1, %{})
      assert html =~ "grid-cols-3"
    end

    test "cols 5 applies grid-cols-5" do
      html = render_component(&H.render_cols_5/1, %{})
      assert html =~ "grid-cols-5"
    end

    test "default grid is grid-cols-4" do
      html = render_component(&H.render_empty/1, %{})
      assert html =~ "grid-cols-4"
    end

    test "aspect video applies aspect-video class" do
      html = render_component(&H.render_aspect_video/1, %{})
      assert html =~ "aspect-video"
    end

    test "renders upload-level error" do
      html = render_component(&H.render_with_upload_error/1, %{})
      assert html =~ "Limit reached"
    end

    test "does not render add cell when at max entries" do
      html = render_component(&H.render_at_limit/1, %{})
      refute html =~ "Add photo"
    end
  end
end
