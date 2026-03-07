defmodule PhiaUi.Components.AvatarUploadTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.AvatarUpload

    def render_no_photo(assigns) do
      ~H"""
      <.avatar_upload upload={%{ref: "avatar-ref", entries: [], errors: []}} />
      """
    end

    def render_with_photo(assigns) do
      ~H"""
      <.avatar_upload
        upload={%{ref: "avatar-ref", entries: [], errors: []}}
        current_url="https://example.com/avatar.jpg"
      />
      """
    end

    def render_circle(assigns) do
      ~H"""
      <.avatar_upload upload={%{ref: "av", entries: [], errors: []}} shape="circle" />
      """
    end

    def render_square(assigns) do
      ~H"""
      <.avatar_upload upload={%{ref: "av", entries: [], errors: []}} shape="square" />
      """
    end

    def render_sm(assigns) do
      ~H"""
      <.avatar_upload upload={%{ref: "av", entries: [], errors: []}} size="sm" />
      """
    end

    def render_lg(assigns) do
      ~H"""
      <.avatar_upload upload={%{ref: "av", entries: [], errors: []}} size="lg" />
      """
    end

    def render_with_error(assigns) do
      ~H"""
      <.avatar_upload upload={%{ref: "av", entries: [], errors: [:too_large]}} />
      """
    end
  end

  describe "avatar_upload/1 rendering" do
    test "renders a label as drop zone" do
      html = render_component(&H.render_no_photo/1, %{})
      assert html =~ "<label"
    end

    test "renders camera icon" do
      html = render_component(&H.render_no_photo/1, %{})
      assert html =~ "Upload"
    end

    test "renders current photo when provided" do
      html = render_component(&H.render_with_photo/1, %{})
      assert html =~ "https://example.com/avatar.jpg"
      assert html =~ "<img"
    end

    test "does not render img when no current_url" do
      html = render_component(&H.render_no_photo/1, %{})
      refute html =~ ~s(alt="Current photo")
    end

    test "circle shape applies rounded-full" do
      html = render_component(&H.render_circle/1, %{})
      assert html =~ "rounded-full"
    end

    test "square shape applies rounded-lg" do
      html = render_component(&H.render_square/1, %{})
      assert html =~ "rounded-lg"
    end

    test "sm size applies w-16 h-16" do
      html = render_component(&H.render_sm/1, %{})
      assert html =~ "w-16"
      assert html =~ "h-16"
    end

    test "lg size applies w-32 h-32" do
      html = render_component(&H.render_lg/1, %{})
      assert html =~ "w-32"
      assert html =~ "h-32"
    end

    test "renders error message for too_large" do
      html = render_component(&H.render_with_error/1, %{})
      assert html =~ "File too large"
    end
  end
end
