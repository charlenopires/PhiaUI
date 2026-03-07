defmodule PhiaUi.Components.AnimationTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Animation

    # marquee
    def render_marquee(assigns) do
      ~H"""
      <.marquee><span>item</span></.marquee>
      """
    end

    def render_marquee_vertical(assigns) do
      ~H"""
      <.marquee direction={:vertical} speed={20}><span>item</span></.marquee>
      """
    end

    def render_marquee_reverse(assigns) do
      ~H"""
      <.marquee reverse={true}><span>item</span></.marquee>
      """
    end

    # orbit
    def render_orbit(assigns) do
      ~H"""
      <.orbit radius={80} duration={8}>
        <span>moon</span>
        <:center><span>center</span></:center>
      </.orbit>
      """
    end

    # aurora
    def render_aurora(assigns) do
      ~H"""
      <.aurora />
      """
    end

    def render_aurora_custom(assigns) do
      ~H"""
      <.aurora colors={["#ff0000", "#0000ff"]} speed={4} class="h-32" />
      """
    end

    # meteor_shower
    def render_meteor_shower(assigns) do
      ~H"""
      <.meteor_shower count={5} />
      """
    end

    # dot_pattern
    def render_dot_pattern(assigns) do
      ~H"""
      <.dot_pattern color="red" spacing={16} />
      """
    end

    # grid_pattern
    def render_grid_pattern(assigns) do
      ~H"""
      <.grid_pattern color="blue" size={24} />
      """
    end

    # ripple_bg
    def render_ripple_bg(assigns) do
      ~H"""
      <.ripple_bg count={3} />
      """
    end

    # shimmer_text
    def render_shimmer_text(assigns) do
      ~H"""
      <.shimmer_text>Hello</.shimmer_text>
      """
    end

    def render_shimmer_text_custom(assigns) do
      ~H"""
      <.shimmer_text speed={4}>Shine</.shimmer_text>
      """
    end

    # typewriter
    def render_typewriter(assigns) do
      ~H"""
      <.typewriter text="Hello World" />
      """
    end

    def render_typewriter_no_cursor(assigns) do
      ~H"""
      <.typewriter text="No cursor" cursor={false} />
      """
    end

    def render_typewriter_loop(assigns) do
      ~H"""
      <.typewriter text="Loop" loop={true} speed={50} />
      """
    end

    # word_rotate
    def render_word_rotate(assigns) do
      ~H"""
      <.word_rotate words={["Fast", "Beautiful", "Accessible"]} />
      """
    end

    # text_scramble
    def render_text_scramble(assigns) do
      ~H"""
      <.text_scramble text="Decode me" />
      """
    end

    def render_text_scramble_hover(assigns) do
      ~H"""
      <.text_scramble text="Hover effect" trigger={:hover} />
      """
    end

    # fade_in
    def render_fade_in(assigns) do
      ~H"""
      <.fade_in><p>Content</p></.fade_in>
      """
    end

    def render_fade_in_left(assigns) do
      ~H"""
      <.fade_in direction={:left} delay={200} duration={800}><p>Left</p></.fade_in>
      """
    end

    def render_fade_in_none(assigns) do
      ~H"""
      <.fade_in direction={:none}><p>No translate</p></.fade_in>
      """
    end

    # float
    def render_float(assigns) do
      ~H"""
      <.float><span>floating</span></.float>
      """
    end

    def render_float_lg(assigns) do
      ~H"""
      <.float amplitude={:lg} duration={5}><span>big float</span></.float>
      """
    end

    # spotlight
    def render_spotlight(assigns) do
      ~H"""
      <.spotlight><p>Content</p></.spotlight>
      """
    end

    def render_spotlight_custom(assigns) do
      ~H"""
      <.spotlight color="rgba(120,80,255,0.2)" size={500}><p>x</p></.spotlight>
      """
    end

    # tilt_card
    def render_tilt_card(assigns) do
      ~H"""
      <.tilt_card><p>Tilt me</p></.tilt_card>
      """
    end

    def render_tilt_card_glare(assigns) do
      ~H"""
      <.tilt_card glare={true}><p>Glare</p></.tilt_card>
      """
    end

    # number_ticker
    def render_number_ticker(assigns) do
      ~H"""
      <.number_ticker value={1000} />
      """
    end

    def render_number_ticker_comma(assigns) do
      ~H"""
      <.number_ticker value={1248} format={:comma} prefix="USD" suffix="K" />
      """
    end

    def render_number_ticker_percent(assigns) do
      ~H"""
      <.number_ticker value={98} format={:percent} />
      """
    end

    # animated_border
    def render_animated_border(assigns) do
      ~H"""
      <.animated_border><p>Fancy</p></.animated_border>
      """
    end

    def render_animated_border_custom(assigns) do
      ~H"""
      <.animated_border colors={["#ff0000", "#0000ff"]} speed={2} radius="rounded-2xl"><p>x</p></.animated_border>
      """
    end

    # pulse_ring
    def render_pulse_ring(assigns) do
      ~H"""
      <.pulse_ring><span class="size-3 rounded-full bg-primary" /></.pulse_ring>
      """
    end

    def render_pulse_ring_custom(assigns) do
      ~H"""
      <.pulse_ring color="red" size={32} count={4} duration={3} />
      """
    end

    # typing_indicator
    def render_typing_indicator(assigns) do
      ~H"""
      <.typing_indicator />
      """
    end

    def render_typing_indicator_lg(assigns) do
      ~H"""
      <.typing_indicator size={:lg} color="red" />
      """
    end

    # wave_loader
    def render_wave_loader(assigns) do
      ~H"""
      <.wave_loader />
      """
    end

    def render_wave_loader_custom(assigns) do
      ~H"""
      <.wave_loader size={:sm} bar_count={7} color="blue" />
      """
    end

    # confetti_burst
    def render_confetti_burst(assigns) do
      ~H"""
      <.confetti_burst />
      """
    end

    def render_confetti_click(assigns) do
      ~H"""
      <.confetti_burst trigger={:click} count={120} />
      """
    end

    # particle_bg
    def render_particle_bg(assigns) do
      ~H"""
      <.particle_bg />
      """
    end

    def render_particle_bg_custom(assigns) do
      ~H"""
      <.particle_bg count={80} color="rgba(99,102,241,0.6)" connect={false} />
      """
    end
  end

  # ---------------------------------------------------------------------------
  # A.1 — marquee/1
  # ---------------------------------------------------------------------------

  describe "marquee/1" do
    test "renders with phx-hook PhiaMarquee" do
      html = render_component(&H.render_marquee/1, %{})
      assert html =~ ~s(phx-hook="PhiaMarquee")
    end

    test "renders slot content twice for seamless loop" do
      html = render_component(&H.render_marquee/1, %{})
      count = html |> String.split("<span>item</span>") |> length()
      assert count == 3
    end

    test "has overflow-hidden class" do
      html = render_component(&H.render_marquee/1, %{})
      assert html =~ "overflow-hidden"
    end

    test "vertical direction sets data-direction" do
      html = render_component(&H.render_marquee_vertical/1, %{})
      assert html =~ ~s(data-direction="vertical")
    end

    test "speed is reflected in data-speed" do
      html = render_component(&H.render_marquee_vertical/1, %{})
      assert html =~ ~s(data-speed="20")
    end

    test "reverse is set in data-reverse" do
      html = render_component(&H.render_marquee_reverse/1, %{})
      assert html =~ ~s(data-reverse="true")
    end

    test "has data-marquee-inner element" do
      html = render_component(&H.render_marquee/1, %{})
      assert html =~ "data-marquee-inner"
    end
  end

  # ---------------------------------------------------------------------------
  # A.2 — orbit/1
  # ---------------------------------------------------------------------------

  describe "orbit/1" do
    test "renders orbit element with inline style" do
      html = render_component(&H.render_orbit/1, %{})
      assert html =~ "--orbit-radius: 80px"
    end

    test "renders center slot content" do
      html = render_component(&H.render_orbit/1, %{})
      assert html =~ "center"
    end

    test "renders inner block (orbiting element)" do
      html = render_component(&H.render_orbit/1, %{})
      assert html =~ "moon"
    end

    test "orbit animation duration is set" do
      html = render_component(&H.render_orbit/1, %{})
      assert html =~ "8s"
    end
  end

  # ---------------------------------------------------------------------------
  # B.3 — aurora/1
  # ---------------------------------------------------------------------------

  describe "aurora/1" do
    test "renders a gradient div" do
      html = render_component(&H.render_aurora/1, %{})
      assert html =~ "linear-gradient"
    end

    test "aurora animation is applied" do
      html = render_component(&H.render_aurora/1, %{})
      assert html =~ "aurora"
    end

    test "blur class is present" do
      html = render_component(&H.render_aurora/1, %{})
      assert html =~ "blur-3xl"
    end

    test "custom colors appear in gradient" do
      html = render_component(&H.render_aurora_custom/1, %{})
      assert html =~ "#ff0000"
      assert html =~ "#0000ff"
    end

    test "custom speed is reflected" do
      html = render_component(&H.render_aurora_custom/1, %{})
      assert html =~ "4s"
    end
  end

  # ---------------------------------------------------------------------------
  # B.4 — meteor_shower/1
  # ---------------------------------------------------------------------------

  describe "meteor_shower/1" do
    test "renders count=5 meteor spans" do
      html = render_component(&H.render_meteor_shower/1, %{})
      # Each meteor is a <span> with the meteor animation
      count = html |> String.split("animation: meteor") |> length()
      assert count == 6
    end

    test "has overflow-hidden" do
      html = render_component(&H.render_meteor_shower/1, %{})
      assert html =~ "overflow-hidden"
    end

    test "meteors have rotate-[215deg] class" do
      html = render_component(&H.render_meteor_shower/1, %{})
      assert html =~ "rotate-[215deg]"
    end
  end

  # ---------------------------------------------------------------------------
  # B.5 — dot_pattern/1
  # ---------------------------------------------------------------------------

  describe "dot_pattern/1" do
    test "renders with radial-gradient background" do
      html = render_component(&H.render_dot_pattern/1, %{})
      assert html =~ "radial-gradient"
    end

    test "uses specified color" do
      html = render_component(&H.render_dot_pattern/1, %{})
      assert html =~ "red"
    end

    test "uses specified spacing" do
      html = render_component(&H.render_dot_pattern/1, %{})
      assert html =~ "16px"
    end
  end

  # ---------------------------------------------------------------------------
  # B.6 — grid_pattern/1
  # ---------------------------------------------------------------------------

  describe "grid_pattern/1" do
    test "renders with linear-gradient background" do
      html = render_component(&H.render_grid_pattern/1, %{})
      assert html =~ "linear-gradient"
    end

    test "uses specified color" do
      html = render_component(&H.render_grid_pattern/1, %{})
      assert html =~ "blue"
    end

    test "uses specified size" do
      html = render_component(&H.render_grid_pattern/1, %{})
      assert html =~ "24px"
    end
  end

  # ---------------------------------------------------------------------------
  # B.7 — ripple_bg/1
  # ---------------------------------------------------------------------------

  describe "ripple_bg/1" do
    test "renders count rings" do
      html = render_component(&H.render_ripple_bg/1, %{})
      count = html |> String.split("ripple-wave") |> length()
      assert count == 4
    end

    test "rings are absolutely positioned" do
      html = render_component(&H.render_ripple_bg/1, %{})
      assert html =~ "rounded-full"
    end
  end

  # ---------------------------------------------------------------------------
  # C.8 — shimmer_text/1
  # ---------------------------------------------------------------------------

  describe "shimmer_text/1" do
    test "renders a span element" do
      html = render_component(&H.render_shimmer_text/1, %{})
      assert html =~ "<span"
    end

    test "renders slot content" do
      html = render_component(&H.render_shimmer_text/1, %{})
      assert html =~ "Hello"
    end

    test "has shiny-text animation" do
      html = render_component(&H.render_shimmer_text/1, %{})
      assert html =~ "shiny-text"
    end

    test "has background-clip: text" do
      html = render_component(&H.render_shimmer_text/1, %{})
      assert html =~ "background-clip: text"
    end

    test "custom speed is reflected" do
      html = render_component(&H.render_shimmer_text_custom/1, %{})
      assert html =~ "4s"
      assert html =~ "Shine"
    end
  end

  # ---------------------------------------------------------------------------
  # C.9 — typewriter/1
  # ---------------------------------------------------------------------------

  describe "typewriter/1" do
    test "renders with phx-hook PhiaTypewriter" do
      html = render_component(&H.render_typewriter/1, %{})
      assert html =~ ~s(phx-hook="PhiaTypewriter")
    end

    test "data-text is set" do
      html = render_component(&H.render_typewriter/1, %{})
      assert html =~ ~s(data-text="Hello World")
    end

    test "renders cursor span by default" do
      html = render_component(&H.render_typewriter/1, %{})
      assert html =~ "data-typewriter-cursor"
    end

    test "cursor can be disabled" do
      html = render_component(&H.render_typewriter_no_cursor/1, %{})
      refute html =~ "data-typewriter-cursor"
    end

    test "data-loop is set" do
      html = render_component(&H.render_typewriter_loop/1, %{})
      assert html =~ ~s(data-loop="true")
    end

    test "data-speed is set" do
      html = render_component(&H.render_typewriter_loop/1, %{})
      assert html =~ ~s(data-speed="50")
    end

    test "blink-cursor animation is applied to cursor" do
      html = render_component(&H.render_typewriter/1, %{})
      assert html =~ "blink-cursor"
    end
  end

  # ---------------------------------------------------------------------------
  # C.10 — word_rotate/1
  # ---------------------------------------------------------------------------

  describe "word_rotate/1" do
    test "renders with phx-hook PhiaWordRotate" do
      html = render_component(&H.render_word_rotate/1, %{})
      assert html =~ ~s(phx-hook="PhiaWordRotate")
    end

    test "data-words is JSON encoded" do
      html = render_component(&H.render_word_rotate/1, %{})
      assert html =~ "Fast"
      assert html =~ "Beautiful"
      assert html =~ "Accessible"
    end

    test "data-duration is set" do
      html = render_component(&H.render_word_rotate/1, %{})
      assert html =~ "data-duration"
    end
  end

  # ---------------------------------------------------------------------------
  # C.11 — text_scramble/1
  # ---------------------------------------------------------------------------

  describe "text_scramble/1" do
    test "renders with phx-hook PhiaTextScramble" do
      html = render_component(&H.render_text_scramble/1, %{})
      assert html =~ ~s(phx-hook="PhiaTextScramble")
    end

    test "data-text is set" do
      html = render_component(&H.render_text_scramble/1, %{})
      assert html =~ ~s(data-text="Decode me")
    end

    test "initial text is rendered" do
      html = render_component(&H.render_text_scramble/1, %{})
      assert html =~ "Decode me"
    end

    test "trigger data attribute is set" do
      html = render_component(&H.render_text_scramble_hover/1, %{})
      assert html =~ ~s(data-trigger="hover")
    end

    test "has font-mono class" do
      html = render_component(&H.render_text_scramble/1, %{})
      assert html =~ "font-mono"
    end
  end

  # ---------------------------------------------------------------------------
  # D.12 — fade_in/1
  # ---------------------------------------------------------------------------

  describe "fade_in/1" do
    test "renders with phx-hook PhiaScrollReveal" do
      html = render_component(&H.render_fade_in/1, %{})
      assert html =~ ~s(phx-hook="PhiaScrollReveal")
    end

    test "has opacity-0 class (hidden until revealed)" do
      html = render_component(&H.render_fade_in/1, %{})
      assert html =~ "opacity-0"
    end

    test "default direction is up (translate-y-6)" do
      html = render_component(&H.render_fade_in/1, %{})
      assert html =~ "translate-y-6"
    end

    test "left direction uses translate-x-6" do
      html = render_component(&H.render_fade_in_left/1, %{})
      assert html =~ "translate-x-6"
    end

    test "none direction has no translate class" do
      html = render_component(&H.render_fade_in_none/1, %{})
      refute html =~ "translate-y-6"
      refute html =~ "translate-x-6"
    end

    test "data-direction is set" do
      html = render_component(&H.render_fade_in_left/1, %{})
      assert html =~ ~s(data-direction="left")
    end

    test "data-delay is reflected" do
      html = render_component(&H.render_fade_in_left/1, %{})
      assert html =~ ~s(data-delay="200")
    end

    test "renders slot content" do
      html = render_component(&H.render_fade_in/1, %{})
      assert html =~ "Content"
    end
  end

  # ---------------------------------------------------------------------------
  # D.13 — float/1
  # ---------------------------------------------------------------------------

  describe "float/1" do
    test "renders slot content" do
      html = render_component(&H.render_float/1, %{})
      assert html =~ "floating"
    end

    test "has float animation in inline style" do
      html = render_component(&H.render_float/1, %{})
      assert html =~ "animation: float"
    end

    test "default amplitude uses -10px" do
      html = render_component(&H.render_float/1, %{})
      assert html =~ "--float-y: -10px"
    end

    test ":lg amplitude uses -18px" do
      html = render_component(&H.render_float_lg/1, %{})
      assert html =~ "--float-y: -18px"
    end

    test "custom duration is reflected" do
      html = render_component(&H.render_float_lg/1, %{})
      assert html =~ "5s"
    end
  end

  # ---------------------------------------------------------------------------
  # E.14 — spotlight/1
  # ---------------------------------------------------------------------------

  describe "spotlight/1" do
    test "renders with phx-hook PhiaSpotlight" do
      html = render_component(&H.render_spotlight/1, %{})
      assert html =~ ~s(phx-hook="PhiaSpotlight")
    end

    test "renders spotlight background div" do
      html = render_component(&H.render_spotlight/1, %{})
      assert html =~ "data-spotlight-bg"
    end

    test "has overflow-hidden" do
      html = render_component(&H.render_spotlight/1, %{})
      assert html =~ "overflow-hidden"
    end

    test "data-color is set" do
      html = render_component(&H.render_spotlight_custom/1, %{})
      assert html =~ ~s[data-color="rgba(120,80,255,0.2)"]
    end

    test "data-size is set" do
      html = render_component(&H.render_spotlight_custom/1, %{})
      assert html =~ ~s(data-size="500")
    end

    test "renders slot content" do
      html = render_component(&H.render_spotlight/1, %{})
      assert html =~ "Content"
    end
  end

  # ---------------------------------------------------------------------------
  # E.15 — tilt_card/1
  # ---------------------------------------------------------------------------

  describe "tilt_card/1" do
    test "renders with phx-hook PhiaTiltCard" do
      html = render_component(&H.render_tilt_card/1, %{})
      assert html =~ ~s(phx-hook="PhiaTiltCard")
    end

    test "has data-scale attribute" do
      html = render_component(&H.render_tilt_card/1, %{})
      assert html =~ "data-scale"
    end

    test "data-max-tilt is set" do
      html = render_component(&H.render_tilt_card/1, %{})
      assert html =~ "data-max-tilt"
    end

    test "renders slot content" do
      html = render_component(&H.render_tilt_card/1, %{})
      assert html =~ "Tilt me"
    end

    test "glare=false does not render glare overlay" do
      html = render_component(&H.render_tilt_card/1, %{})
      refute html =~ "data-tilt-glare"
    end

    test "glare=true renders glare overlay" do
      html = render_component(&H.render_tilt_card_glare/1, %{})
      assert html =~ "data-tilt-glare"
    end
  end

  # ---------------------------------------------------------------------------
  # F.16 — number_ticker/1
  # ---------------------------------------------------------------------------

  describe "number_ticker/1" do
    test "renders with phx-hook PhiaNumberTicker" do
      html = render_component(&H.render_number_ticker/1, %{})
      assert html =~ ~s(phx-hook="PhiaNumberTicker")
    end

    test "data-value is set" do
      html = render_component(&H.render_number_ticker/1, %{})
      assert html =~ ~s(data-value="1000")
    end

    test "tabular-nums class is present" do
      html = render_component(&H.render_number_ticker/1, %{})
      assert html =~ "tabular-nums"
    end

    test "prefix and suffix are rendered" do
      html = render_component(&H.render_number_ticker_comma/1, %{})
      assert html =~ "USD"
      assert html =~ "K"
    end

    test "format data attribute is set" do
      html = render_component(&H.render_number_ticker_comma/1, %{})
      assert html =~ ~s(data-format="comma")
    end

    test "percent format data attribute is set" do
      html = render_component(&H.render_number_ticker_percent/1, %{})
      assert html =~ ~s(data-format="percent")
    end
  end

  # ---------------------------------------------------------------------------
  # G.17 — animated_border/1
  # ---------------------------------------------------------------------------

  describe "animated_border/1" do
    test "renders with conic-gradient" do
      html = render_component(&H.render_animated_border/1, %{})
      assert html =~ "conic-gradient"
    end

    test "renders slot content" do
      html = render_component(&H.render_animated_border/1, %{})
      assert html =~ "Fancy"
    end

    test "has border-spin animation" do
      html = render_component(&H.render_animated_border/1, %{})
      assert html =~ "border-spin"
    end

    test "custom colors appear in gradient" do
      html = render_component(&H.render_animated_border_custom/1, %{})
      assert html =~ "#ff0000"
      assert html =~ "#0000ff"
    end

    test "inner div has bg-background" do
      html = render_component(&H.render_animated_border/1, %{})
      assert html =~ "bg-background"
    end
  end

  # ---------------------------------------------------------------------------
  # G.18 — pulse_ring/1
  # ---------------------------------------------------------------------------

  describe "pulse_ring/1" do
    test "renders default 3 rings" do
      html = render_component(&H.render_pulse_ring/1, %{})
      count = html |> String.split("pulse-ring") |> length()
      assert count == 4
    end

    test "renders slot content" do
      html = render_component(&H.render_pulse_ring/1, %{})
      assert html =~ "rounded-full"
    end

    test "custom count=4 renders 4 rings" do
      html = render_component(&H.render_pulse_ring_custom/1, %{})
      count = html |> String.split("pulse-ring") |> length()
      assert count == 5
    end

    test "custom color is in inline style" do
      html = render_component(&H.render_pulse_ring_custom/1, %{})
      assert html =~ "red"
    end
  end

  # ---------------------------------------------------------------------------
  # H.19 — typing_indicator/1
  # ---------------------------------------------------------------------------

  describe "typing_indicator/1" do
    test "renders three dots" do
      html = render_component(&H.render_typing_indicator/1, %{})
      count = html |> String.split("typing-bounce") |> length()
      assert count == 4
    end

    test "has role=status" do
      html = render_component(&H.render_typing_indicator/1, %{})
      assert html =~ ~s(role="status")
    end

    test "aria-label is Typing" do
      html = render_component(&H.render_typing_indicator/1, %{})
      assert html =~ ~s(aria-label="Typing")
    end

    test ":lg size uses w-3 h-3 classes" do
      html = render_component(&H.render_typing_indicator_lg/1, %{})
      assert html =~ "w-3"
      assert html =~ "h-3"
    end

    test "custom color is in inline style" do
      html = render_component(&H.render_typing_indicator_lg/1, %{})
      assert html =~ "background: red"
    end
  end

  # ---------------------------------------------------------------------------
  # H.20 — wave_loader/1
  # ---------------------------------------------------------------------------

  describe "wave_loader/1" do
    test "renders default 5 bars" do
      html = render_component(&H.render_wave_loader/1, %{})
      count = html |> String.split("wave-bar") |> length()
      assert count == 6
    end

    test "has role=status" do
      html = render_component(&H.render_wave_loader/1, %{})
      assert html =~ ~s(role="status")
    end

    test "aria-label is Loading" do
      html = render_component(&H.render_wave_loader/1, %{})
      assert html =~ ~s(aria-label="Loading")
    end

    test "custom bar_count=7 renders 7 bars" do
      html = render_component(&H.render_wave_loader_custom/1, %{})
      count = html |> String.split("wave-bar") |> length()
      assert count == 8
    end

    test ":sm size uses w-0.5 h-3 classes" do
      html = render_component(&H.render_wave_loader_custom/1, %{})
      assert html =~ "w-0.5"
      assert html =~ "h-3"
    end
  end

  # ---------------------------------------------------------------------------
  # I.21 — confetti_burst/1
  # ---------------------------------------------------------------------------

  describe "confetti_burst/1" do
    test "renders with phx-hook PhiaConfetti" do
      html = render_component(&H.render_confetti_burst/1, %{})
      assert html =~ ~s(phx-hook="PhiaConfetti")
    end

    test "renders canvas element" do
      html = render_component(&H.render_confetti_burst/1, %{})
      assert html =~ "data-confetti-canvas"
    end

    test "data-trigger defaults to mount" do
      html = render_component(&H.render_confetti_burst/1, %{})
      assert html =~ ~s(data-trigger="mount")
    end

    test "data-trigger=click is set" do
      html = render_component(&H.render_confetti_click/1, %{})
      assert html =~ ~s(data-trigger="click")
    end

    test "data-count is reflected" do
      html = render_component(&H.render_confetti_click/1, %{})
      assert html =~ ~s(data-count="120")
    end

    test "data-colors is JSON encoded" do
      html = render_component(&H.render_confetti_burst/1, %{})
      assert html =~ "data-colors"
      assert html =~ "#ff0000"
    end
  end

  # ---------------------------------------------------------------------------
  # I.22 — particle_bg/1
  # ---------------------------------------------------------------------------

  describe "particle_bg/1" do
    test "renders with phx-hook PhiaParticleBg" do
      html = render_component(&H.render_particle_bg/1, %{})
      assert html =~ ~s(phx-hook="PhiaParticleBg")
    end

    test "renders canvas element" do
      html = render_component(&H.render_particle_bg/1, %{})
      assert html =~ "data-particle-canvas"
    end

    test "has overflow-hidden" do
      html = render_component(&H.render_particle_bg/1, %{})
      assert html =~ "overflow-hidden"
    end

    test "data-count is set" do
      html = render_component(&H.render_particle_bg/1, %{})
      assert html =~ "data-count"
    end

    test "data-connect defaults to true" do
      html = render_component(&H.render_particle_bg/1, %{})
      assert html =~ ~s(data-connect="true")
    end

    test "data-connect=false is reflected" do
      html = render_component(&H.render_particle_bg_custom/1, %{})
      assert html =~ ~s(data-connect="false")
    end

    test "custom color is set" do
      html = render_component(&H.render_particle_bg_custom/1, %{})
      assert html =~ "rgba(99,102,241,0.6)"
    end
  end
end
