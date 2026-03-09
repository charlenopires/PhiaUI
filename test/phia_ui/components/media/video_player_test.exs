defmodule PhiaUi.Components.VideoPlayerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.VideoPlayer

    def render_default(assigns) do
      ~H"""
      <.video_player id="vp1" src="/videos/demo.mp4" />
      """
    end

    def render_with_poster(assigns) do
      ~H"""
      <.video_player id="vp2" src="/videos/demo.mp4" poster="/images/poster.jpg" />
      """
    end

    def render_aspect_video(assigns) do
      ~H"""
      <.video_player id="vp3" src="/videos/demo.mp4" aspect_ratio={:video} />
      """
    end

    def render_aspect_square(assigns) do
      ~H"""
      <.video_player id="vp4" src="/videos/demo.mp4" aspect_ratio={:square} />
      """
    end

    def render_aspect_portrait(assigns) do
      ~H"""
      <.video_player id="vp5" src="/videos/demo.mp4" aspect_ratio={:portrait} />
      """
    end

    def render_aspect_auto(assigns) do
      ~H"""
      <.video_player id="vp6" src="/videos/demo.mp4" aspect_ratio={:auto} />
      """
    end

    def render_no_controls(assigns) do
      ~H"""
      <.video_player id="vp7" src="/videos/demo.mp4" controls={false} />
      """
    end

    def render_with_controls(assigns) do
      ~H"""
      <.video_player id="vp8" src="/videos/demo.mp4" controls={true} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.video_player id="vp9" src="/videos/demo.mp4" class="my-video-class" />
      """
    end

    def render_muted(assigns) do
      ~H"""
      <.video_player id="vp10" src="/videos/demo.mp4" muted={true} />
      """
    end

    def render_autoplay(assigns) do
      ~H"""
      <.video_player id="vp11" src="/videos/demo.mp4" autoplay={true} />
      """
    end

    def render_loop(assigns) do
      ~H"""
      <.video_player id="vp12" src="/videos/demo.mp4" loop={true} />
      """
    end
  end

  describe "video_player/1" do
    test "renders video element" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<video"
      assert html =~ "data-video"
    end

    test "renders source with src attr" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(src="/videos/demo.mp4")
      assert html =~ ~s(type="video/mp4")
    end

    test "renders poster when provided" do
      html = render_component(&H.render_with_poster/1, %{})
      assert html =~ ~s(poster="/images/poster.jpg")
    end

    test "default aspect_ratio renders aspect-video" do
      html = render_component(&H.render_aspect_video/1, %{})
      assert html =~ "aspect-video"
    end

    test "square aspect_ratio renders aspect-square" do
      html = render_component(&H.render_aspect_square/1, %{})
      assert html =~ "aspect-square"
    end

    test "portrait aspect renders aspect-[9/16]" do
      html = render_component(&H.render_aspect_portrait/1, %{})
      assert html =~ "aspect-[9/16]"
    end

    test "auto aspect no aspect class" do
      html = render_component(&H.render_aspect_auto/1, %{})
      refute html =~ "aspect-video"
      refute html =~ "aspect-square"
      refute html =~ "aspect-[9/16]"
    end

    test "controls renders play overlay" do
      html = render_component(&H.render_with_controls/1, %{})
      assert html =~ "data-play-overlay"
      assert html =~ ~s(aria-label="Play video")
    end

    test "controls renders progress bar" do
      html = render_component(&H.render_with_controls/1, %{})
      assert html =~ "data-progress-bar"
      assert html =~ "data-progress-fill"
    end

    test "no controls when false" do
      html = render_component(&H.render_no_controls/1, %{})
      refute html =~ "data-play-overlay"
      refute html =~ "data-play-btn"
      refute html =~ "data-progress-bar"
      refute html =~ "data-fullscreen-btn"
    end

    test "renders phx-hook PhiaVideoPlayer" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(phx-hook="PhiaVideoPlayer")
    end

    test "custom class merging" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-video-class"
      assert html =~ "rounded-lg"
    end
  end
end
