defmodule PhiaUi.Components.BackgroundTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Background

    def render_gradient_mesh(assigns) do
      ~H"<.gradient_mesh id=\"mesh-1\" colors={[\"#f43f5e\", \"#6366f1\"]} />"
    end

    def render_noise_bg(assigns) do
      ~H"<.noise_bg opacity={0.2} />"
    end

    def render_animated_gradient_bg(assigns) do
      ~H"<.animated_gradient_bg from=\"#667eea\" via=\"#764ba2\" to=\"#f64f59\" />"
    end

    def render_retro_grid(assigns) do
      ~H"<.retro_grid color=\"rgba(0,0,0,0.1)\" cell_size={32} />"
    end

    def render_wave_bg(assigns) do
      ~H"<.wave_bg color=\"rgba(99,102,241,0.2)\" />"
    end

    def render_hex_pattern(assigns) do
      ~H"<.hex_pattern color=\"rgba(0,0,0,0.1)\" size={20} />"
    end

    def render_stripe_pattern(assigns) do
      ~H"<.stripe_pattern color=\"rgba(0,0,0,0.1)\" direction={:diagonal} />"
    end

    def render_checker_pattern(assigns) do
      ~H"<.checker_pattern color=\"rgba(0,0,0,0.05)\" size={20} />"
    end

    def render_dot_grid(assigns) do
      ~H"<.dot_grid dot_size={2} spacing={20} />"
    end

    def render_bokeh_bg(assigns) do
      ~H"<.bokeh_bg colors={[\"#f59e0b\"]} count={2} />"
    end

    def render_conic_gradient_bg(assigns) do
      ~H"<.conic_gradient_bg from_color=\"#f43f5e\" to_color=\"#6366f1\" />"
    end

    def render_flicker_grid(assigns) do
      ~H"<.flicker_grid id=\"flicker-1\" color=\"rgba(99,102,241,0.5)\" />"
    end

    def render_beam_bg(assigns) do
      ~H"<.beam_bg color=\"rgba(99,102,241,0.4)\" />"
    end

    def render_warp_grid(assigns) do
      ~H"<.warp_grid color=\"rgba(0,0,0,0.1)\" />"
    end

    def render_flowing_lines(assigns) do
      ~H"<.flowing_lines color=\"rgba(99,102,241,0.4)\" count={3} />"
    end
  end

  describe "gradient_mesh/1" do
    test "renders with phx-hook" do
      html = render_component(&H.render_gradient_mesh/1, %{})
      assert html =~ ~s(phx-hook="PhiaMeshBg")
    end

    test "has data-colors attribute" do
      html = render_component(&H.render_gradient_mesh/1, %{})
      assert html =~ "data-colors"
    end

    test "is aria-hidden" do
      html = render_component(&H.render_gradient_mesh/1, %{})
      assert html =~ ~s(aria-hidden="true")
    end
  end

  describe "noise_bg/1" do
    test "renders SVG with feTurbulence" do
      html = render_component(&H.render_noise_bg/1, %{})
      assert html =~ "feTurbulence"
    end

    test "renders unique filter id" do
      html = render_component(&H.render_noise_bg/1, %{})
      assert html =~ "phia-noise-"
    end
  end

  describe "animated_gradient_bg/1" do
    test "renders with aurora animation" do
      html = render_component(&H.render_animated_gradient_bg/1, %{})
      assert html =~ "aurora"
    end

    test "contains from color" do
      html = render_component(&H.render_animated_gradient_bg/1, %{})
      assert html =~ "#667eea"
    end
  end

  describe "retro_grid/1" do
    test "renders with perspective transform" do
      html = render_component(&H.render_retro_grid/1, %{})
      assert html =~ "perspective"
      assert html =~ "rotateX"
    end
  end

  describe "wave_bg/1" do
    test "renders SVG paths" do
      html = render_component(&H.render_wave_bg/1, %{})
      assert html =~ "<path"
    end

    test "uses phia-wave-scroll animation" do
      html = render_component(&H.render_wave_bg/1, %{})
      assert html =~ "phia-wave-scroll"
    end
  end

  describe "hex_pattern/1" do
    test "renders SVG pattern" do
      html = render_component(&H.render_hex_pattern/1, %{})
      assert html =~ "<pattern"
      assert html =~ "<polygon"
    end

    test "renders unique pattern id" do
      html = render_component(&H.render_hex_pattern/1, %{})
      assert html =~ "phia-hex-"
    end
  end

  describe "stripe_pattern/1" do
    test "renders diagonal gradient" do
      html = render_component(&H.render_stripe_pattern/1, %{})
      assert html =~ "45deg"
    end
  end

  describe "checker_pattern/1" do
    test "renders conic-gradient" do
      html = render_component(&H.render_checker_pattern/1, %{})
      assert html =~ "repeating-conic-gradient"
    end
  end

  describe "dot_grid/1" do
    test "renders radial-gradient" do
      html = render_component(&H.render_dot_grid/1, %{})
      assert html =~ "radial-gradient"
    end
  end

  describe "bokeh_bg/1" do
    test "renders blobs" do
      html = render_component(&H.render_bokeh_bg/1, %{})
      assert html =~ "phia-bokeh-drift"
      assert html =~ "blur"
    end

    test "renders aria-hidden" do
      html = render_component(&H.render_bokeh_bg/1, %{})
      assert html =~ ~s(aria-hidden="true")
    end
  end

  describe "conic_gradient_bg/1" do
    test "uses conic-gradient" do
      html = render_component(&H.render_conic_gradient_bg/1, %{})
      assert html =~ "conic-gradient"
    end

    test "uses phia-conic-spin animation" do
      html = render_component(&H.render_conic_gradient_bg/1, %{})
      assert html =~ "phia-conic-spin"
    end
  end

  describe "flicker_grid/1" do
    test "renders canvas with phx-hook" do
      html = render_component(&H.render_flicker_grid/1, %{})
      assert html =~ "<canvas"
      assert html =~ ~s(phx-hook="PhiaFlickerGrid")
    end

    test "has data-color attribute" do
      html = render_component(&H.render_flicker_grid/1, %{})
      assert html =~ "data-color"
    end
  end

  describe "beam_bg/1" do
    test "uses phia-beam-sweep animation" do
      html = render_component(&H.render_beam_bg/1, %{})
      assert html =~ "phia-beam-sweep"
    end
  end

  describe "warp_grid/1" do
    test "renders perspective transform" do
      html = render_component(&H.render_warp_grid/1, %{})
      assert html =~ "perspective"
      assert html =~ "rotateX"
    end

    test "uses radial-gradient dot grid" do
      html = render_component(&H.render_warp_grid/1, %{})
      assert html =~ "radial-gradient"
    end
  end

  describe "flowing_lines/1" do
    test "renders SVG paths" do
      html = render_component(&H.render_flowing_lines/1, %{})
      assert html =~ "<path"
    end

    test "uses phia-line-draw animation" do
      html = render_component(&H.render_flowing_lines/1, %{})
      assert html =~ "phia-line-draw"
    end
  end
end
