# Animation

CSS and canvas animation primitives for landing pages, dashboards, and interactive UIs. All 22 components live in `PhiaUi.Components.Animation` and belong to the `:animation` tier. Every component respects `prefers-reduced-motion` via the `.phia-chart-animate` guard and requires no npm dependencies — vanilla JS hooks only.

```elixir
import PhiaUi.Components.Animation
```

---

## marquee/1

**Module**: `PhiaUi.Components.Animation`
**Tier**: animation
**Hook**: `PhiaMarquee`

Infinite horizontal scrolling ticker. Loops child content seamlessly. Useful for logo clouds, news tickers, and announcement banners.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `speed` | `:integer` | `30` | Scroll speed in seconds for one full loop |
| `direction` | `:string` | `"left"` | Scroll direction: `"left"` or `"right"` |
| `gap` | `:string` | `"1rem"` | Gap between items |
| `pause_on_hover` | `:boolean` | `true` | Pause animation on mouse hover |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.marquee speed={20}>
  <span class="px-8">Elixir</span>
  <span class="px-8">Phoenix</span>
  <span class="px-8">LiveView</span>
</.marquee>
```

### Use Cases

- Logo cloud / partner strip
- News ticker or announcement banner
- Infinite tag cloud

---

## orbit/1

**Module**: `PhiaUi.Components.Animation`
**Tier**: animation

Elements orbiting a fixed center point with CSS animation. Supports multiple items at configurable radii and speeds.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `radius` | `:integer` | `80` | Orbit radius in pixels |
| `duration` | `:integer` | `8` | Seconds for one full orbit |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.orbit radius={100} duration={6}>
  <:center><.icon name="zap" size={:lg} /></:center>
  <:item><img src="/logo1.png" class="size-8 rounded-full" /></:item>
  <:item><img src="/logo2.png" class="size-8 rounded-full" /></:item>
</.orbit>
```

### Use Cases

- Hero section "ecosystem" animation
- Technology showcase

---

## aurora/1

**Module**: `PhiaUi.Components.Animation`
**Tier**: animation

Animated northern-lights gradient backdrop. Soft blobs of color that shift and blend using CSS keyframe animations.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `colors` | `:list` | `["#3b82f6", "#8b5cf6", "#06b6d4"]` | List of aurora blob colors |
| `class` | `:string` | `nil` | Wrapper CSS classes |

### Usage

```heex
<.aurora>
  <div class="relative z-10 text-center">
    <h1 class="text-5xl font-bold">Hero Title</h1>
  </div>
</.aurora>
```

---

## meteor_shower/1

**Module**: `PhiaUi.Components.Animation`
**Tier**: animation

CSS animated diagonal meteor streaks. Generates configurable number of `<span>` meteors at random horizontal positions with staggered delays.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `count` | `:integer` | `20` | Number of meteor streaks |
| `class` | `:string` | `nil` | Wrapper CSS classes |

### Usage

```heex
<.meteor_shower count={30} class="absolute inset-0" />
```

---

## dot_pattern/1

**Module**: `PhiaUi.Components.Animation`
**Tier**: animation

SVG repeating dot grid background pattern. Zero JS, pure SVG `<pattern>` element.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `dot_size` | `:integer` | `2` | Dot radius in pixels |
| `spacing` | `:integer` | `20` | Grid cell size in pixels |
| `color` | `:string` | `"currentColor"` | Dot fill color |
| `class` | `:string` | `nil` | Wrapper CSS classes |

### Usage

```heex
<.dot_pattern spacing={24} color="#e5e7eb" class="absolute inset-0 opacity-50" />
```

---

## grid_pattern/1

**Module**: `PhiaUi.Components.Animation`
**Tier**: animation

SVG repeating grid line background pattern. Similar to `dot_pattern` but renders grid lines instead of dots.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `cell_size` | `:integer` | `40` | Grid cell size in pixels |
| `stroke` | `:string` | `"currentColor"` | Line stroke color |
| `class` | `:string` | `nil` | Wrapper CSS classes |

### Usage

```heex
<.grid_pattern cell_size={32} stroke="#f3f4f6" class="absolute inset-0" />
```

---

## ripple_bg/1

**Module**: `PhiaUi.Components.Animation`
**Tier**: animation

Concentric ripple rings expanding from center. Multiple rings animate with staggered delays via `phia-ripple` keyframes.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `rings` | `:integer` | `4` | Number of concentric ripple rings |
| `color` | `:string` | `"primary"` | Ring color (CSS color or theme variable) |
| `duration` | `:integer` | `3` | Seconds for one ripple expansion |
| `class` | `:string` | `nil` | Wrapper CSS classes |

### Usage

```heex
<.ripple_bg rings={5} color="hsl(var(--primary))" class="size-48">
  <.icon name="bell" size={:lg} />
</.ripple_bg>
```

---

## shimmer_text/1

**Module**: `PhiaUi.Components.Animation`
**Tier**: animation

Gradient shimmer sweep across text. Uses a moving linear-gradient over `background-clip: text`.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.shimmer_text class="text-4xl font-bold">
  Building the future
</.shimmer_text>
```

---

## typewriter/1

**Module**: `PhiaUi.Components.Animation`
**Tier**: animation
**Hook**: `PhiaTypewriter`

Character-by-character text typing animation with configurable speed and optional loop.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Required for hook |
| `text` | `:string` | required | Text to type |
| `speed` | `:integer` | `60` | Milliseconds per character |
| `loop` | `:boolean` | `false` | Loop after completion |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.typewriter id="hero-typer" text="Hello, Phoenix LiveView." speed={50} loop={true} />
```

---

## word_rotate/1

**Module**: `PhiaUi.Components.Animation`
**Tier**: animation
**Hook**: `PhiaWordRotate`

Cycles through a list of words with fade-in/fade-out transition.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Required for hook |
| `words` | `:list` | required | List of words to cycle through |
| `interval` | `:integer` | `2000` | Milliseconds between word changes |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.word_rotate id="hero-words" words={["Fast", "Reliable", "Beautiful"]} interval={1500} />
```

---

## text_scramble/1

**Module**: `PhiaUi.Components.Animation`
**Tier**: animation
**Hook**: `PhiaTextScramble`

Characters scramble randomly then resolve to the final target text.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Required for hook |
| `text` | `:string` | required | Final resolved text |
| `duration` | `:integer` | `1000` | Total animation duration in ms |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.text_scramble id="scramble-1" text="PhiaUI Components" duration={1200} />
```

---

## fade_in/1

**Module**: `PhiaUi.Components.Animation`
**Tier**: animation

Opacity + translate-Y entrance animation with configurable delay. Pure CSS, respects `prefers-reduced-motion`.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `delay` | `:integer` | `0` | Animation delay in milliseconds |
| `duration` | `:integer` | `500` | Animation duration in milliseconds |
| `direction` | `:string` | `"up"` | Entry direction: `"up"`, `"down"`, `"left"`, `"right"` |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.fade_in delay={200}>
  <.card>Content</.card>
</.fade_in>
```

---

## float/1

**Module**: `PhiaUi.Components.Animation`
**Tier**: animation

Gentle CSS floating/bobbing animation wrapper. Uses `phia-float` keyframes.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `amplitude` | `:integer` | `10` | Float amplitude in pixels |
| `duration` | `:integer` | `3` | Seconds per float cycle |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.float amplitude={12} duration={4}>
  <.icon name="arrow-up" size={:lg} />
</.float>
```

---

## spotlight/1

**Module**: `PhiaUi.Components.Animation`
**Tier**: animation
**Hook**: `PhiaSpotlight`

Mouse-following radial gradient spotlight overlay. The gradient tracks cursor position within the wrapper element.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Required for hook |
| `size` | `:integer` | `600` | Spotlight diameter in pixels |
| `color` | `:string` | `"hsl(var(--primary) / 0.15)"` | Spotlight gradient color |
| `class` | `:string` | `nil` | Wrapper CSS classes |

### Usage

```heex
<.spotlight id="hero-spotlight" size={500} class="relative min-h-screen">
  <div class="relative z-10">Hero content</div>
</.spotlight>
```

---

## tilt_card/1

**Module**: `PhiaUi.Components.Animation`
**Tier**: animation
**Hook**: `PhiaTiltCard`

3D perspective tilt effect on mouse-move. The card tilts toward the cursor position within bounds.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Required for hook |
| `max_tilt` | `:integer` | `15` | Maximum tilt angle in degrees |
| `scale` | `:any` | `1.05` | Scale factor on hover |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.tilt_card id="feature-card" max_tilt={10}>
  <.card class="p-6">
    <h3>Feature Title</h3>
  </.card>
</.tilt_card>
```

---

## number_ticker/1

**Module**: `PhiaUi.Components.Animation`
**Tier**: animation
**Hook**: `PhiaNumberTicker`

Animated number count-up from 0 to a target value on mount.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Required for hook |
| `value` | `:integer` | required | Target number to count up to |
| `duration` | `:integer` | `1500` | Animation duration in ms |
| `prefix` | `:string` | `nil` | Text before number (e.g., `"$"`) |
| `suffix` | `:string` | `nil` | Text after number (e.g., `"+"`) |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.number_ticker id="user-count" value={12500} duration={2000} suffix="+" class="text-5xl font-bold" />
```

---

## animated_border/1

**Module**: `PhiaUi.Components.Animation`
**Tier**: animation

Rotating conic-gradient border animation. Wraps content with a visible animated border.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `duration` | `:integer` | `4` | Seconds per rotation cycle |
| `colors` | `:list` | `["#3b82f6", "#8b5cf6", "#ec4899"]` | Gradient color stops |
| `border_width` | `:integer` | `2` | Border thickness in pixels |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.animated_border duration={3} class="rounded-xl">
  <.button>Premium Feature</.button>
</.animated_border>
```

---

## pulse_ring/1

**Module**: `PhiaUi.Components.Animation`
**Tier**: animation

Expanding pulse ring animation, useful as a notification beacon or "live" indicator.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `color` | `:string` | `"primary"` | Ring color variant |
| `size` | `:integer` | `12` | Inner dot size in pixels |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.pulse_ring color="emerald" class="absolute top-0 right-0" />
```

---

## typing_indicator/1

**Module**: `PhiaUi.Components.Animation`
**Tier**: animation

Three-dot animated chat typing indicator. Uses staggered `phia-bounce` keyframes.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.typing_indicator class="px-4 py-2" />
```

---

## wave_loader/1

**Module**: `PhiaUi.Components.Animation`
**Tier**: animation

Animated vertical wave bar loading indicator. Five bars animate with staggered heights.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `bars` | `:integer` | `5` | Number of wave bars |
| `color` | `:string` | `"primary"` | Bar color class |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.wave_loader bars={6} class="h-8" />
```

---

## confetti_burst/1

**Module**: `PhiaUi.Components.Animation`
**Tier**: animation
**Hook**: `PhiaConfetti`

Canvas confetti explosion on mount. Fires a burst of colored particles from the center of the element.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Required for hook |
| `count` | `:integer` | `150` | Number of confetti particles |
| `duration` | `:integer` | `3000` | Animation duration in ms |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.confetti_burst id="celebration" count={200} />
```

### LiveView Example

```elixir
def handle_event("payment_success", _params, socket) do
  {:noreply, assign(socket, show_confetti: true)}
end
```

```heex
<%= if @show_confetti do %>
  <.confetti_burst id="payment-confetti" />
<% end %>
```

---

## particle_bg/1

**Module**: `PhiaUi.Components.Animation`
**Tier**: animation
**Hook**: `PhiaParticleBg`

Canvas floating particles background. Particles drift with random velocities and connect with lines when close.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Required for hook |
| `count` | `:integer` | `80` | Number of particles |
| `color` | `:string` | `"#3b82f6"` | Particle and line color |
| `speed` | `:any` | `0.5` | Particle movement speed |
| `class` | `:string` | `nil` | Wrapper CSS classes |

### Usage

```heex
<.particle_bg id="hero-particles" count={60} color="hsl(var(--primary))" class="absolute inset-0" />
```
