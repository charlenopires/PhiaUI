defmodule PhiaUi.Components.Animation do
  @moduledoc """
  Animation primitives for PhiaUI — 22 components covering infinite loops,
  background effects, text effects, entry/scroll animations, interactive hover,
  counter animations, decorative borders, CSS loaders, and canvas effects.

  All JS-driven components respect `prefers-reduced-motion`.

  ## Components (A — Infinite Loop)
  - `marquee/1` — horizontal/vertical infinite scroll ticker
  - `orbit/1` — element orbiting a center at configurable radius

  ## Components (B — Background Effects)
  - `aurora/1` — animated aurora borealis gradient
  - `meteor_shower/1` — falling meteors across a container
  - `dot_pattern/1` — radial dot grid background
  - `grid_pattern/1` — orthogonal grid lines background
  - `ripple_bg/1` — concentric expanding rings

  ## Components (C — Text Effects)
  - `shimmer_text/1` — sliding shine gradient over text
  - `typewriter/1` — char-by-char text reveal
  - `word_rotate/1` — cycling words with fade
  - `text_scramble/1` — glitch-then-reveal text effect

  ## Components (D — Entry Animations)
  - `fade_in/1` — scroll-triggered reveal with direction
  - `float/1` — perpetual levitation loop

  ## Components (E — Interactive Hover)
  - `spotlight/1` — cursor-following radial light
  - `tilt_card/1` — 3D perspective tilt on hover

  ## Components (F — Counter)
  - `number_ticker/1` — count-up animation to target value

  ## Components (G — Decorative)
  - `animated_border/1` — rotating conic-gradient border
  - `pulse_ring/1` — expanding pulsing rings

  ## Components (H — Loaders)
  - `typing_indicator/1` — 3-dot bouncing chat loader
  - `wave_loader/1` — wave bar equalizer loader

  ## Components (I — Canvas Effects)
  - `confetti_burst/1` — canvas confetti particles
  - `particle_bg/1` — canvas floating particle field
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # A.1 — marquee/1
  # ---------------------------------------------------------------------------

  attr :direction, :atom, values: [:horizontal, :vertical], default: :horizontal,
    doc: "Scroll direction."

  attr :speed, :integer, default: 40, doc: "Animation duration in seconds."
  attr :pause_on_hover, :boolean, default: true, doc: "Pause animation on mouse enter."
  attr :reverse, :boolean, default: false, doc: "Reverse scroll direction."
  attr :gap, :string, default: "gap-4", doc: "Tailwind gap class between items."
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Infinite scroll marquee. Renders slot content twice for a seamless loop.
  Requires `PhiaMarquee` JS hook.

  ## Examples

      <.marquee gap="gap-8">
        <img src="/logo1.png" />
        <img src="/logo2.png" />
      </.marquee>

      <.marquee direction={:vertical} speed={20} pause_on_hover={false}>
        <div>Item 1</div>
      </.marquee>
  """
  def marquee(assigns) do
    ~H"""
    <div
      phx-hook="PhiaMarquee"
      data-direction={@direction}
      data-speed={@speed}
      data-pause-on-hover={"#{@pause_on_hover}"}
      data-reverse={"#{@reverse}"}
      class={cn(["relative overflow-hidden", @class])}
      {@rest}
    >
      <div
        data-marquee-inner
        class={cn(["flex", marquee_flex_class(@direction), @gap, "w-max"])}
      >
        <div class={cn(["flex shrink-0", marquee_flex_class(@direction), @gap])}>
          {render_slot(@inner_block)}
        </div>
        <div
          class={cn(["flex shrink-0", marquee_flex_class(@direction), @gap])}
          aria-hidden="true"
        >
          {render_slot(@inner_block)}
        </div>
      </div>
    </div>
    """
  end

  defp marquee_flex_class(:vertical), do: "flex-col"
  defp marquee_flex_class(:horizontal), do: nil

  # ---------------------------------------------------------------------------
  # A.2 — orbit/1
  # ---------------------------------------------------------------------------

  attr :radius, :integer, default: 60, doc: "Orbit radius in pixels."
  attr :duration, :integer, default: 10, doc: "Orbit duration in seconds."
  attr :delay, :integer, default: 0, doc: "Animation delay in milliseconds."
  attr :reverse, :boolean, default: false, doc: "Reverse orbit direction."
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true
  slot :center, doc: "Content placed at the orbit center."

  @doc """
  Element orbiting a center point. Pure CSS `@keyframes orbit`.

  ## Examples

      <.orbit radius={80} duration={8}>
        <span class="size-3 rounded-full bg-primary" />
        <:center>
          <img src="/logo.svg" class="size-10" />
        </:center>
      </.orbit>
  """
  def orbit(assigns) do
    reverse_str = if assigns.reverse, do: " reverse", else: ""
    assigns = assign(assigns, :reverse_str, reverse_str)

    ~H"""
    <div
      class={cn(["relative flex items-center justify-center", @class])}
      {@rest}
    >
      {render_slot(@center)}
      <div
        style={"--orbit-radius: #{@radius}px; animation: orbit #{@duration}s linear #{@delay}ms infinite#{@reverse_str};"}
        class="absolute"
      >
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # B.3 — aurora/1
  # ---------------------------------------------------------------------------

  attr :colors, :list,
    default: ["#00d2ff", "#3a47d5", "#a8edea", "#fed6e3"],
    doc: "Color stops for the aurora gradient."

  attr :speed, :integer, default: 8, doc: "Animation duration in seconds."
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Aurora borealis animated gradient background. Pure CSS.

  ## Examples

      <.aurora colors={["#00d2ff", "#7928ca"]} speed={6} class="h-64 w-full rounded-xl" />
  """
  def aurora(assigns) do
    colors_css = Enum.join(assigns.colors, ", ")
    assigns = assign(assigns, :colors_css, colors_css)

    ~H"""
    <div
      class={cn(["relative overflow-hidden", @class])}
      {@rest}
    >
      <div
        class="absolute inset-0 opacity-80 blur-3xl"
        style={"background: linear-gradient(120deg, #{@colors_css}); background-size: 200% 200%; animation: aurora #{@speed}s ease infinite;"}
      />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # B.4 — meteor_shower/1
  # ---------------------------------------------------------------------------

  attr :count, :integer, default: 20, doc: "Number of meteors."
  attr :color, :string, default: "#94a3b8", doc: "Meteor trail color."
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Randomly-positioned falling meteors. Pure CSS `@keyframes meteor`.

  ## Examples

      <.meteor_shower count={15} class="absolute inset-0" />
  """
  def meteor_shower(assigns) do
    meteors =
      Enum.map(1..max(assigns.count, 1), fn i ->
        %{
          top: rem(i * 37 + 13, 90),
          left: rem(i * 53 + 7, 100),
          delay: rem(i * 17, 9),
          dur: 4 + rem(i * 11, 6)
        }
      end)

    assigns = assign(assigns, :meteors, meteors)

    ~H"""
    <div class={cn(["relative overflow-hidden", @class])} {@rest}>
      <span
        :for={m <- @meteors}
        style={"top: #{m.top}%; left: #{m.left}%; animation: meteor #{m.dur}s linear #{m.delay}s infinite; background: linear-gradient(to bottom right, #{@color}, transparent); transform-origin: top left;"}
        class="absolute h-px w-[100px] rotate-[215deg] opacity-0 rounded-full shadow-[0_0_0_1px_#ffffff10]"
      />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # B.5 — dot_pattern/1
  # ---------------------------------------------------------------------------

  attr :color, :string, default: "currentColor", doc: "Dot color (any CSS value)."
  attr :size, :integer, default: 1, doc: "Dot radius in pixels."
  attr :spacing, :integer, default: 24, doc: "Grid cell size in pixels."
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Radial dot grid background pattern. Pure CSS.

  ## Examples

      <.dot_pattern color="oklch(0.5 0 0 / 20%)" spacing={20} class="absolute inset-0" />
  """
  def dot_pattern(assigns) do
    ~H"""
    <div
      class={cn([@class])}
      style={"background-image: radial-gradient(circle, #{@color} #{@size}px, transparent #{@size}px); background-size: #{@spacing}px #{@spacing}px;"}
      {@rest}
    />
    """
  end

  # ---------------------------------------------------------------------------
  # B.6 — grid_pattern/1
  # ---------------------------------------------------------------------------

  attr :color, :string, default: "currentColor", doc: "Grid line color."
  attr :size, :integer, default: 32, doc: "Grid cell size in pixels."
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Orthogonal grid lines background. Pure CSS.

  ## Examples

      <.grid_pattern color="oklch(0.5 0 0 / 15%)" size={40} class="absolute inset-0" />
  """
  def grid_pattern(assigns) do
    ~H"""
    <div
      class={cn([@class])}
      style={"background-image: linear-gradient(to right, #{@color} 1px, transparent 1px), linear-gradient(to bottom, #{@color} 1px, transparent 1px); background-size: #{@size}px #{@size}px;"}
      {@rest}
    />
    """
  end

  # ---------------------------------------------------------------------------
  # B.7 — ripple_bg/1
  # ---------------------------------------------------------------------------

  attr :color, :string, default: "var(--color-primary)", doc: "Ring color."
  attr :duration, :integer, default: 2, doc: "Ripple cycle duration in seconds."
  attr :count, :integer, default: 3, doc: "Number of concentric rings."
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Concentric expanding rings ripple from center. Pure CSS.

  ## Examples

      <.ripple_bg color="oklch(0.6 0.2 250)" count={4} class="size-40" />
  """
  def ripple_bg(assigns) do
    ~H"""
    <div class={cn(["relative flex items-center justify-center", @class])} {@rest}>
      <span
        :for={i <- 1..max(@count, 1)//1}
        style={"width: #{i * 48}px; height: #{i * 48}px; border: 1px solid #{@color}; animation: ripple-wave #{@duration}s ease-out #{(i - 1) * 0.4}s infinite;"}
        class="absolute rounded-full"
      />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # C.8 — shimmer_text/1
  # ---------------------------------------------------------------------------

  attr :speed, :integer, default: 8, doc: "Shimmer cycle duration in seconds."
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Inline text with a sliding shine gradient over the surface. Pure CSS.

  ## Examples

      <.shimmer_text class="text-2xl font-semibold">✨ Magic UI</.shimmer_text>
  """
  def shimmer_text(assigns) do
    ~H"""
    <span
      class={cn(["inline-block", @class])}
      style={"--shiny-width: 40%; background: linear-gradient(90deg, transparent calc(50% - var(--shiny-width)), oklch(1 0 0 / 0.8) 50%, transparent calc(50% + var(--shiny-width))) no-repeat; background-size: 200% 100%; background-clip: text; -webkit-background-clip: text; color: transparent; animation: shiny-text #{@speed}s ease-in-out infinite;"}
      {@rest}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end

  # ---------------------------------------------------------------------------
  # C.9 — typewriter/1
  # ---------------------------------------------------------------------------

  attr :text, :string, required: true, doc: "The text to type out."
  attr :speed, :integer, default: 80, doc: "Milliseconds per character."
  attr :cursor, :boolean, default: true, doc: "Show blinking cursor."
  attr :loop, :boolean, default: false, doc: "Restart after completion."
  attr :delay, :integer, default: 0, doc: "Initial delay in milliseconds."
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Types text char-by-char with an optional cursor blink.
  Requires `PhiaTypewriter` JS hook.

  ## Examples

      <.typewriter text="Hello, PhiaUI!" speed={60} cursor={true} loop={true} />
  """
  def typewriter(assigns) do
    ~H"""
    <span
      phx-hook="PhiaTypewriter"
      data-text={@text}
      data-speed={@speed}
      data-cursor={"#{@cursor}"}
      data-loop={"#{@loop}"}
      data-delay={@delay}
      class={cn(["inline-flex items-baseline", @class])}
      {@rest}
    >
      <span data-typewriter-text></span>
      <span
        :if={@cursor}
        data-typewriter-cursor
        class="ml-0.5 inline-block h-[1em] w-px bg-current"
        style="animation: blink-cursor 1s step-end infinite;"
      />
    </span>
    """
  end

  # ---------------------------------------------------------------------------
  # C.10 — word_rotate/1
  # ---------------------------------------------------------------------------

  attr :words, :list, required: true, doc: "List of words to cycle through."
  attr :duration, :integer, default: 2500, doc: "Time per word in milliseconds."
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Cycles through a list of words with a fade/slide transition.
  Requires `PhiaWordRotate` JS hook.

  ## Examples

      <.word_rotate words={["Fast", "Beautiful", "Accessible"]} duration={2000} />
  """
  def word_rotate(assigns) do
    ~H"""
    <span
      phx-hook="PhiaWordRotate"
      data-words={Jason.encode!(@words)}
      data-duration={@duration}
      class={cn(["inline-block", @class])}
      {@rest}
    />
    """
  end

  # ---------------------------------------------------------------------------
  # C.11 — text_scramble/1
  # ---------------------------------------------------------------------------

  attr :text, :string, required: true, doc: "Target text to reveal."

  attr :trigger, :atom,
    values: [:mount, :hover, :click],
    default: :mount,
    doc: "What triggers the scramble effect."

  attr :duration, :integer, default: 800, doc: "Scramble duration in milliseconds."
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Scrambles then reveals text with a glitch effect.
  Requires `PhiaTextScramble` JS hook.

  ## Examples

      <.text_scramble text="Decode me" trigger={:hover} />
      <.text_scramble text="Hello World" trigger={:click} duration={1200} />
  """
  def text_scramble(assigns) do
    ~H"""
    <span
      phx-hook="PhiaTextScramble"
      data-text={@text}
      data-trigger={@trigger}
      data-duration={@duration}
      class={cn(["inline-block font-mono", @class])}
      {@rest}
    >
      {@text}
    </span>
    """
  end

  # ---------------------------------------------------------------------------
  # D.12 — fade_in/1
  # ---------------------------------------------------------------------------

  attr :direction, :atom,
    values: [:up, :down, :left, :right, :none],
    default: :up,
    doc: "Entry direction for the slide animation."

  attr :delay, :integer, default: 0, doc: "Transition delay in milliseconds."
  attr :duration, :integer, default: 500, doc: "Transition duration in milliseconds."
  attr :once, :boolean, default: true, doc: "Reveal only once (no re-hide)."
  attr :threshold, :float, default: 0.1, doc: "IntersectionObserver threshold."
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Wraps content with a scroll-triggered reveal animation.
  Requires `PhiaScrollReveal` JS hook.

  ## Examples

      <.fade_in direction={:up} delay={200}>
        <p>Appears from below on scroll.</p>
      </.fade_in>
  """
  def fade_in(assigns) do
    ~H"""
    <div
      phx-hook="PhiaScrollReveal"
      data-direction={@direction}
      data-delay={@delay}
      data-duration={@duration}
      data-once={"#{@once}"}
      data-threshold={@threshold}
      class={cn(["opacity-0", fade_translate_class(@direction), @class])}
      style={"transition: opacity #{@duration}ms ease, transform #{@duration}ms ease; transition-delay: #{@delay}ms;"}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp fade_translate_class(:up), do: "translate-y-6"
  defp fade_translate_class(:down), do: "-translate-y-6"
  defp fade_translate_class(:left), do: "translate-x-6"
  defp fade_translate_class(:right), do: "-translate-x-6"
  defp fade_translate_class(:none), do: nil

  # ---------------------------------------------------------------------------
  # D.13 — float/1
  # ---------------------------------------------------------------------------

  attr :amplitude, :atom,
    values: [:sm, :md, :lg],
    default: :md,
    doc: "Float movement amplitude."

  attr :duration, :integer, default: 3, doc: "Float cycle duration in seconds."
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Perpetual floating/levitation loop. Pure CSS `@keyframes float`.

  ## Examples

      <.float amplitude={:lg} duration={4}>
        <img src="/hero-icon.svg" class="size-16" />
      </.float>
  """
  def float(assigns) do
    ~H"""
    <div
      class={cn(["inline-block", @class])}
      style={"--float-y: #{float_amplitude(@amplitude)}; animation: float #{@duration}s ease-in-out infinite;"}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp float_amplitude(:sm), do: "-6px"
  defp float_amplitude(:md), do: "-10px"
  defp float_amplitude(:lg), do: "-18px"

  # ---------------------------------------------------------------------------
  # E.14 — spotlight/1
  # ---------------------------------------------------------------------------

  attr :color, :string,
    default: "rgba(255,255,255,0.15)",
    doc: "Spotlight color (any CSS color)."

  attr :size, :integer, default: 300, doc: "Spotlight radius in pixels."
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Radial gradient spotlight that follows the cursor inside the container.
  Requires `PhiaSpotlight` JS hook.

  ## Examples

      <.spotlight class="p-8 rounded-xl border" color="rgba(120,80,255,0.2)" size={400}>
        <h2>Hover me!</h2>
      </.spotlight>
  """
  def spotlight(assigns) do
    ~H"""
    <div
      phx-hook="PhiaSpotlight"
      data-color={@color}
      data-size={@size}
      class={cn(["relative overflow-hidden", @class])}
      {@rest}
    >
      <div
        data-spotlight-bg
        class="pointer-events-none absolute inset-0 opacity-0 transition-opacity duration-300"
        style={"background: radial-gradient(#{@size}px circle at 0px 0px, #{@color}, transparent 80%);"}
      />
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # E.15 — tilt_card/1
  # ---------------------------------------------------------------------------

  attr :max_tilt, :integer, default: 15, doc: "Maximum tilt angle in degrees."
  attr :scale, :float, default: 1.05, doc: "Scale factor on hover."
  attr :glare, :boolean, default: false, doc: "Show glare overlay effect."
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  3D perspective tilt card on mouse hover.
  Requires `PhiaTiltCard` JS hook.

  ## Examples

      <.tilt_card max_tilt={20} glare={true} class="rounded-xl border p-6">
        <h3>Hover to tilt</h3>
      </.tilt_card>
  """
  def tilt_card(assigns) do
    ~H"""
    <div
      phx-hook="PhiaTiltCard"
      data-max-tilt={@max_tilt}
      data-scale={@scale}
      data-glare={"#{@glare}"}
      class={cn(["relative", @class])}
      style="transform-style: preserve-3d; transition: transform 0.1s ease;"
      {@rest}
    >
      {render_slot(@inner_block)}
      <div
        :if={@glare}
        data-tilt-glare
        class="pointer-events-none absolute inset-0 rounded-[inherit] opacity-0"
        style="background: linear-gradient(125deg, rgba(255,255,255,0.4) 0%, transparent 60%);"
      />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # F.16 — number_ticker/1
  # ---------------------------------------------------------------------------

  attr :value, :integer, required: true, doc: "Target value to count up to."
  attr :duration, :integer, default: 1500, doc: "Animation duration in milliseconds."

  attr :format, :atom,
    values: [:plain, :comma, :percent],
    default: :plain,
    doc: "Number formatting style."

  attr :prefix, :string, default: "", doc: "Text before the number (e.g. \"$\")."
  attr :suffix, :string, default: "", doc: "Text after the number (e.g. \"K\")."
  attr :decimal_places, :integer, default: 0
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Counts up from 0 to `value` with easeOutCubic easing.
  Requires `PhiaNumberTicker` JS hook.

  ## Examples

      <.number_ticker value={1248} format={:comma} prefix="$" class="text-4xl font-bold" />
      <.number_ticker value={98} format={:percent} suffix="%" duration={2000} />
  """
  def number_ticker(assigns) do
    ~H"""
    <span
      phx-hook="PhiaNumberTicker"
      data-value={@value}
      data-duration={@duration}
      data-format={@format}
      data-prefix={@prefix}
      data-suffix={@suffix}
      data-decimal-places={@decimal_places}
      class={cn(["tabular-nums", @class])}
      {@rest}
    >{@prefix}0{@suffix}</span>
    """
  end

  # ---------------------------------------------------------------------------
  # G.17 — animated_border/1
  # ---------------------------------------------------------------------------

  attr :colors, :list,
    default: ["#ff0080", "#ff8c00", "#40e0d0"],
    doc: "Color stops for the rotating conic gradient."

  attr :speed, :integer, default: 4, doc: "Rotation duration in seconds."
  attr :border_width, :integer, default: 2, doc: "Border width in pixels."
  attr :radius, :string, default: "rounded-lg", doc: "Tailwind border-radius class."
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Rotating conic-gradient animated border wrapper. Pure CSS.

  ## Examples

      <.animated_border colors={["#ff0080", "#7928ca"]} speed={3} class="p-4">
        <p>Fancy border!</p>
      </.animated_border>
  """
  def animated_border(assigns) do
    colors_css = Enum.join(assigns.colors, ", ")
    assigns = assign(assigns, :colors_css, colors_css)

    ~H"""
    <div
      class={cn(["relative p-px overflow-hidden", @radius, @class])}
      {@rest}
    >
      <div
        class={cn(["absolute inset-[-50%]"])}
        style={"background: conic-gradient(from 0deg, #{@colors_css}); animation: border-spin #{@speed}s linear infinite;"}
      />
      <div class={cn(["relative bg-background", @radius, "p-#{@border_width}"])}>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # G.18 — pulse_ring/1
  # ---------------------------------------------------------------------------

  attr :color, :string, default: "var(--color-primary)", doc: "Ring color."
  attr :size, :integer, default: 48, doc: "Base ring size in pixels."
  attr :duration, :integer, default: 2, doc: "Pulse duration in seconds."
  attr :count, :integer, default: 3, doc: "Number of pulsing rings."
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block

  @doc """
  Expanding pulsing rings radiating from a center element. Pure CSS.

  ## Examples

      <.pulse_ring color="oklch(0.6 0.2 250)" size={40}>
        <span class="size-4 rounded-full bg-primary" />
      </.pulse_ring>
  """
  def pulse_ring(assigns) do
    ~H"""
    <div class={cn(["relative inline-flex items-center justify-center", @class])} {@rest}>
      <span
        :for={i <- 0..max(@count - 1, 0)//1}
        class="absolute rounded-full"
        style={"width: #{@size}px; height: #{@size}px; background: #{@color}; opacity: 0; animation: pulse-ring #{@duration}s cubic-bezier(0, 0, 0.2, 1) #{i * @duration / max(@count, 1)}s infinite;"}
      />
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # H.19 — typing_indicator/1
  # ---------------------------------------------------------------------------

  attr :color, :string, default: "var(--color-muted-foreground)", doc: "Dot color."
  attr :size, :atom, values: [:sm, :md, :lg], default: :md
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Three-dot bouncing chat typing indicator. Pure CSS.

  ## Examples

      <.typing_indicator color="var(--color-primary)" size={:lg} />
  """
  def typing_indicator(assigns) do
    ~H"""
    <div
      class={cn(["inline-flex items-center gap-1", @class])}
      role="status"
      aria-label="Typing"
      {@rest}
    >
      <span
        :for={i <- 0..2}
        class={cn(["rounded-full", typing_dot_size(@size)])}
        style={"background: #{@color}; animation: typing-bounce 1.2s ease-in-out #{i * 0.2}s infinite;"}
      />
    </div>
    """
  end

  defp typing_dot_size(:sm), do: "w-1.5 h-1.5"
  defp typing_dot_size(:md), do: "w-2 h-2"
  defp typing_dot_size(:lg), do: "w-3 h-3"

  # ---------------------------------------------------------------------------
  # H.20 — wave_loader/1
  # ---------------------------------------------------------------------------

  attr :color, :string, default: "var(--color-primary)", doc: "Bar color."
  attr :size, :atom, values: [:sm, :md, :lg], default: :md
  attr :bar_count, :integer, default: 5, doc: "Number of bars."
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Wave equalizer bar loader. Pure CSS.

  ## Examples

      <.wave_loader color="oklch(0.6 0.2 250)" size={:lg} bar_count={7} />
  """
  def wave_loader(assigns) do
    ~H"""
    <div
      class={cn(["inline-flex items-end gap-0.5", @class])}
      role="status"
      aria-label="Loading"
      {@rest}
    >
      <span
        :for={i <- 0..max(@bar_count - 1, 0)//1}
        class={cn(["rounded-sm", wave_bar_size(@size)])}
        style={"background: #{@color}; transform: scaleY(0.4); animation: wave-bar 1.2s ease-in-out #{Float.round(i * 1.2 / max(@bar_count, 1), 2)}s infinite;"}
      />
    </div>
    """
  end

  defp wave_bar_size(:sm), do: "w-0.5 h-3"
  defp wave_bar_size(:md), do: "w-1 h-5"
  defp wave_bar_size(:lg), do: "w-1.5 h-8"

  # ---------------------------------------------------------------------------
  # I.21 — confetti_burst/1
  # ---------------------------------------------------------------------------

  attr :trigger, :atom,
    values: [:mount, :click],
    default: :mount,
    doc: "What triggers the confetti burst."

  attr :count, :integer, default: 80, doc: "Number of confetti particles."

  attr :colors, :list,
    default: ["#ff0000", "#00ff00", "#0000ff", "#ffff00", "#ff00ff", "#00ffff"],
    doc: "Particle color palette."

  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Canvas confetti particle burst.
  Requires `PhiaConfetti` JS hook.

  ## Examples

      <.confetti_burst trigger={:click} count={120} class="absolute inset-0">
        <button phx-click="celebrate">🎉 Celebrate!</button>
      </.confetti_burst>
  """
  def confetti_burst(assigns) do
    ~H"""
    <div
      phx-hook="PhiaConfetti"
      data-trigger={@trigger}
      data-count={@count}
      data-colors={Jason.encode!(@colors)}
      class={cn(["relative", @class])}
      {@rest}
    >
      <canvas
        data-confetti-canvas
        class="pointer-events-none absolute inset-0 w-full h-full"
      />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # I.22 — particle_bg/1
  # ---------------------------------------------------------------------------

  attr :count, :integer, default: 50, doc: "Number of floating particles."
  attr :color, :string, default: "rgba(148,163,184,0.8)", doc: "Particle and line color."
  attr :speed, :float, default: 0.5, doc: "Base particle movement speed."

  attr :connect, :boolean,
    default: true,
    doc: "Draw connecting lines between nearby particles."

  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Canvas floating particle field background.
  Requires `PhiaParticleBg` JS hook.

  ## Examples

      <.particle_bg count={80} color="rgba(99,102,241,0.6)" connect={true} class="h-screen w-full" />
  """
  def particle_bg(assigns) do
    ~H"""
    <div
      phx-hook="PhiaParticleBg"
      data-count={@count}
      data-color={@color}
      data-speed={@speed}
      data-connect={"#{@connect}"}
      class={cn(["relative overflow-hidden", @class])}
      {@rest}
    >
      <canvas
        data-particle-canvas
        class="absolute inset-0 w-full h-full"
      />
    </div>
    """
  end
end
