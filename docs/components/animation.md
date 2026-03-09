# Animation

22 animation primitives — marquee, typewriter, particle systems, text effects, number tickers, and motion wrappers for landing pages, dashboards, and interactive UIs.

**Module**: `PhiaUi.Components.Animation`

```elixir
import PhiaUi.Components.Animation
```

All components:
- Respect `prefers-reduced-motion` — animations disable automatically for users who prefer reduced motion
- Use vanilla JS hooks — no npm packages
- Are server-rendered — content is in the DOM before JavaScript runs

> **Background patterns** (gradient mesh, dot grids, bokeh, SVG waves, etc.) live in their own module — see [Background](background.md).

---

## Table of Contents

**Marquee & Orbit**
- [marquee](#marquee)
- [orbit](#orbit)

**Background Effects**
- [aurora](#aurora)
- [meteor_shower](#meteor_shower)
- [dot_pattern](#dot_pattern)
- [grid_pattern](#grid_pattern)
- [ripple_bg](#ripple_bg)
- [particle_bg](#particle_bg)

**Text Effects**
- [shimmer_text](#shimmer_text)
- [typewriter](#typewriter)
- [word_rotate](#word_rotate)
- [text_scramble](#text_scramble)
- [gradient_text](#gradient_text) — see [Typography](typography.md)

**Motion Wrappers**
- [fade_in](#fade_in)
- [float](#float)
- [tilt_card](#tilt_card)
- [spotlight](#spotlight)
- [animated_border](#animated_border)
- [pulse_ring](#pulse_ring)

**UI Animations**
- [number_ticker](#number_ticker)
- [typing_indicator](#typing_indicator)
- [wave_loader](#wave_loader)
- [confetti_burst](#confetti_burst)

---

## marquee

Infinite horizontal scrolling ticker. Loops child content seamlessly. Hook: `PhiaMarquee`.

```heex
<%!-- Logo cloud --%>
<.marquee speed={40} gap={32} class="py-4">
  <%= for logo <- @logos do %>
    <img src={logo.url} alt={logo.name} class="h-8 grayscale hover:grayscale-0 transition-all" />
  <% end %>
</.marquee>

<%!-- Testimonial ticker --%>
<.marquee speed={30} pause_on_hover={true}>
  <%= for quote <- @quotes do %>
    <.testimonial_card {quote} class="w-72 mx-4 shrink-0" />
  <% end %>
</.marquee>

<%!-- Reverse direction --%>
<.marquee reverse={true} speed={25}>
  <%= for tag <- @tags do %>
    <.badge class="mx-2"><%= tag %></.badge>
  <% end %>
</.marquee>
```

**Attrs**: `speed` (px/s, default 30), `gap` (px), `reverse` (boolean), `pause_on_hover` (boolean), `class`

---

## orbit

Elements orbit around a central point. Hook: `PhiaOrbit`.

```heex
<.orbit id="skills-orbit" radius={120} speed={20}>
  <:center>
    <.avatar size="xl"><.avatar_image src={@profile.avatar} /></.avatar>
  </:center>
  <:items>
    <img src="/icons/elixir.svg" class="h-8 w-8" />
    <img src="/icons/phoenix.svg" class="h-8 w-8" />
    <img src="/icons/tailwind.svg" class="h-8 w-8" />
    <img src="/icons/postgresql.svg" class="h-8 w-8" />
  </:items>
</.orbit>
```

**Attrs**: `id` (required), `radius` (px), `speed` (seconds for full orbit), `class`

---

## aurora

Animated aurora borealis gradient — soft, shifting colours. Reuses the `--animate-aurora` theme token.

```heex
<div class="relative h-64 overflow-hidden rounded-xl bg-zinc-900">
  <.aurora colors={["#3b82f6", "#8b5cf6", "#ec4899"]} />
  <div class="relative z-10 p-8 text-white">Hero content</div>
</div>
```

**Attrs**: `colors` (list of CSS colors), `class`

---

## meteor_shower

Animated shooting meteors across a dark background. Hook: `PhiaMeteor`.

```heex
<div class="relative h-96 bg-black overflow-hidden rounded-xl">
  <.meteor_shower count={30} color="rgba(255,255,255,0.8)" />
  <div class="relative z-10">Content</div>
</div>
```

**Attrs**: `count` (integer, default 20), `color`, `class`

---

## dot_pattern

Repeating SVG dot pattern background with optional radial fade mask.

```heex
<div class="relative bg-white dark:bg-zinc-950">
  <.dot_pattern class="opacity-50" />
  <div class="relative z-10 p-12">Page content</div>
</div>
```

---

## grid_pattern

SVG grid line pattern with optional fade mask.

```heex
<div class="relative">
  <.grid_pattern stroke_color="rgba(0,0,0,0.08)" />
  <div class="relative z-10">Content</div>
</div>
```

---

## ripple_bg

Expanding concentric circle ripples from a centre point.

```heex
<div class="relative h-64 flex items-center justify-center bg-primary/5 rounded-xl overflow-hidden">
  <.ripple_bg color="rgba(99,102,241,0.15)" count={4} duration={3} />
  <.icon name="wifi" size="lg" class="relative z-10 text-primary" />
</div>
```

---

## particle_bg

Canvas particle system with connecting lines. Hook: `PhiaParticleBg`.

```heex
<div class="relative h-screen bg-zinc-950">
  <.particle_bg
    id="hero-particles"
    count={80}
    color="rgba(99,102,241,0.5)"
    connect={true}
  />
  <div class="relative z-10 flex items-center justify-center h-full">
    <h1 class="text-white text-5xl font-bold">PhiaUI</h1>
  </div>
</div>
```

**Attrs**: `id` (required), `count` (integer), `color`, `connect` (boolean), `speed` (float)

---

## shimmer_text

Text with a sweeping shimmer highlight.

```heex
<.shimmer_text class="text-4xl font-bold">
  PhiaUI
</.shimmer_text>
```

---

## typewriter

Types text character by character, with optional blinking cursor. Hook: `PhiaTypewriter`.

```heex
<.typewriter
  id="hero-type"
  phrases={["Build faster.", "Ship confidently.", "Own your UI."]}
  speed={80}
  pause={2000}
/>
```

**Attrs**: `id` (required), `phrases` (list of strings), `speed` (ms per char), `pause` (ms between phrases), `loop` (boolean)

---

## word_rotate

Rotates through a list of words with a fade transition. Hook: `PhiaWordRotate`.

```heex
<h1 class="text-4xl font-bold flex gap-3 items-center">
  Build
  <.word_rotate
    id="rotating-word"
    words={["faster", "smarter", "better", "with confidence"]}
    class="text-primary"
  />
</.h1>
```

---

## text_scramble

Scrambles and resolves text character by character (Matrix-style). Hook: `PhiaTextScramble`.

```heex
<.text_scramble id="scramble-1" text="PhiaUI" class="text-5xl font-mono font-bold" />
```

---

## fade_in

Fades and slides content into view on scroll. Hook: `PhiaScrollReveal`.

```heex
<.fade_in id="feature-1" direction={:up} delay={0}>
  <.feature_card title="Fast" description="584 components, zero bloat." />
</.fade_in>
<.fade_in id="feature-2" direction={:up} delay={100}>
  <.feature_card title="Accessible" description="Full WAI-ARIA on all interactive components." />
</.fade_in>
```

**Attrs**: `id` (required), `direction` (`:up` | `:down` | `:left` | `:right`), `delay` (ms), `duration` (ms)

---

## float

Gently floats content up and down continuously.

```heex
<.float amplitude={8} duration={3}>
  <img src="/hero-graphic.svg" class="w-64" />
</.float>
```

**Attrs**: `amplitude` (px, default 6), `duration` (seconds, default 4), `class`

---

## tilt_card

Card that tilts in 3D on mouse movement. Hook: `PhiaTiltCard`.

```heex
<.tilt_card id="product-card" max_tilt={15} class="rounded-xl overflow-hidden">
  <.image_card src="/product.jpg" title="Product Name" />
</.tilt_card>
```

---

## spotlight

Radial spotlight that follows cursor inside the container. Hook: `PhiaSpotlight`.

```heex
<.spotlight id="hero-spotlight" color="rgba(99,102,241,0.15)">
  <div class="p-12">
    <.heading level={1}>Build something great</.heading>
  </div>
</.spotlight>
```

---

## animated_border

Animates a gradient around the element border.

```heex
<.animated_border class="rounded-xl p-0.5">
  <div class="bg-card rounded-xl p-6">
    <h3>Special offer</h3>
  </div>
</.animated_border>
```

---

## pulse_ring

Pulsing ring around an element — draws attention.

```heex
<div class="relative">
  <.pulse_ring color="rgba(99,102,241,0.4)" />
  <.button variant="default">New feature</.button>
</div>
```

---

## number_ticker

Counts up to a target value with easing. Hook: `PhiaNumberTicker`.

```heex
<.number_ticker id="mrr" value={24500} prefix="$" duration={1500} />
<.number_ticker id="users" value={18723} suffix=" users" duration={2000} />
```

**Attrs**: `id` (required), `value` (number), `prefix`, `suffix`, `duration` (ms), `start` (initial value)

---

## typing_indicator

Three animated dots — for chat "is typing" states.

```heex
<%= if @contact_is_typing do %>
  <div class="flex items-center gap-2">
    <.avatar size="xs"><.avatar_fallback name={@contact.name} /></.avatar>
    <.typing_indicator />
  </div>
<% end %>
```

---

## wave_loader

Five vertical bars that animate like a sound wave.

```heex
<.wave_loader class="text-primary" />
<.wave_loader size="lg" class="text-muted-foreground" />
```

---

## confetti_burst

Canvas confetti explosion. Hook: `PhiaConfetti`.

```heex
<.confetti_burst id="success-confetti" />

<%!-- Trigger from LiveView --%>
<%!-- push_event(socket, "confetti", %{id: "success-confetti"}) --%>
```

---

## Real-world: Hero section with animation stack

```heex
<section class="relative min-h-screen overflow-hidden bg-zinc-950">
  <%!-- Background layers --%>
  <.particle_bg id="hero-bg" count={60} color="rgba(99,102,241,0.3)" connect={true} />

  <%!-- Foreground content --%>
  <div class="relative z-10 flex flex-col items-center justify-center min-h-screen px-4 text-center">
    <.fade_in id="hero-badge" direction={:down} delay={0}>
      <.badge variant="outline" class="text-white border-white/20 mb-6">
        v0.1.14 — 584 components
      </.badge>
    </.fade_in>

    <.fade_in id="hero-title" direction={:up} delay={100}>
      <h1 class="text-6xl font-bold text-white mb-4">
        Build Phoenix UIs
        <br />
        <.shimmer_text class="text-indigo-400">in minutes</.shimmer_text>
      </h1>
    </.fade_in>

    <.fade_in id="hero-cta" direction={:up} delay={300}>
      <div class="flex gap-4 mt-8">
        <.glow_button color="#6366f1" phx-click="get_started">Get started</.glow_button>
        <.button variant="outline" class="text-white border-white/20">View docs</.button>
      </div>
    </.fade_in>
  </div>
</section>
```
