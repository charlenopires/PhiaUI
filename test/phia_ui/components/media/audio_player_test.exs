defmodule PhiaUi.Components.AudioPlayerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.AudioPlayer

    def render_audio_player(assigns) do
      ~H"""
      <.audio_player id="ap1" src="/audio/test.mp3" />
      """
    end

    def render_with_duration(assigns) do
      ~H"""
      <.audio_player id="ap2" src="/audio/test.mp3" duration={120} />
      """
    end

    def render_compact(assigns) do
      ~H"""
      <.audio_player id="ap3" src="/audio/test.mp3" variant={:compact} />
      """
    end

    def render_default_variant(assigns) do
      ~H"""
      <.audio_player id="ap4" src="/audio/test.mp3" variant={:default} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.audio_player id="ap5" src="/audio/test.mp3" class="my-audio-class" />
      """
    end

    def render_with_label(assigns) do
      ~H"""
      <.audio_player id="ap6" src="/audio/test.mp3" label="Voice note" />
      """
    end

    def render_autoplay(assigns) do
      ~H"""
      <.audio_player id="ap7" src="/audio/test.mp3" autoplay={true} />
      """
    end
  end

  describe "audio_player/1" do
    test "renders root element with phx-hook" do
      html = render_component(&H.render_audio_player/1, %{})
      assert html =~ ~s(phx-hook="PhiaAudioPlayer")
    end

    test "renders with id attribute" do
      html = render_component(&H.render_audio_player/1, %{})
      assert html =~ ~s(id="ap1")
    end

    test "passes src as data-src" do
      html = render_component(&H.render_audio_player/1, %{})
      assert html =~ ~s(data-src="/audio/test.mp3")
    end

    test "renders play/pause button" do
      html = render_component(&H.render_audio_player/1, %{})
      assert html =~ "<button"
    end

    test "play button has aria-label" do
      html = render_component(&H.render_audio_player/1, %{})
      assert html =~ ~s(aria-label="Play")
    end

    test "renders progress bar element" do
      html = render_component(&H.render_audio_player/1, %{})
      assert html =~ ~s(data-progress)
    end

    test "renders timestamp element" do
      html = render_component(&H.render_audio_player/1, %{})
      assert html =~ ~s(data-timestamp)
    end

    test "with duration passes data-duration" do
      html = render_component(&H.render_with_duration/1, %{})
      assert html =~ ~s(data-duration="120")
    end

    test "default variant without duration shows 0:00" do
      html = render_component(&H.render_audio_player/1, %{})
      assert html =~ "0:00"
    end

    test "with duration=120 shows 2:00" do
      html = render_component(&H.render_with_duration/1, %{})
      assert html =~ "2:00"
    end

    test "variant :compact has compact class" do
      html = render_component(&H.render_compact/1, %{})
      assert html =~ "compact"
    end

    test "variant :default renders without compact class" do
      html = render_component(&H.render_default_variant/1, %{})
      refute html =~ "compact"
    end

    test "custom class applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-audio-class"
    end

    test "with label renders label text" do
      html = render_component(&H.render_with_label/1, %{})
      assert html =~ "Voice note"
    end

    test "autoplay=true passes data-autoplay=true" do
      html = render_component(&H.render_autoplay/1, %{})
      assert html =~ ~s(data-autoplay="true")
    end

    test "autoplay=false (default) passes data-autoplay=false" do
      html = render_component(&H.render_audio_player/1, %{})
      assert html =~ ~s(data-autoplay="false")
    end

    test "renders audio element with src" do
      html = render_component(&H.render_audio_player/1, %{})
      assert html =~ "<audio"
    end

    test "renders waveform/progress track element" do
      html = render_component(&H.render_audio_player/1, %{})
      assert html =~ ~s(data-track)
    end
  end
end
