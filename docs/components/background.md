# Background

15 decorative background components — CSS-only patterns and canvas/SVG animations for hero sections, landing pages, and feature highlights. All are `aria-hidden`, respect `prefers-reduced-motion`, and sit behind content via `absolute inset-0` positioning.

**Module**: `PhiaUi.Components.Background`

```elixir
import PhiaUi.Components.Background
```

---

## Table of Contents

- [gradient_mesh](#gradient_mesh)
- [noise_bg](#noise_bg)
- [animated_gradient_bg](#animated_gradient_bg)
- [retro_grid](#retro_grid)
- [wave_bg](#wave_bg)
- [hex_pattern](#hex_pattern)
- [stripe_pattern](#stripe_pattern)
- [checker_pattern](#checker_pattern)
- [dot_grid](#dot_grid)
- [bokeh_bg](#bokeh_bg)
- [conic_gradient_bg](#conic_gradient_bg)
- [flicker_grid](#flicker_grid)
- [beam_bg](#beam_bg)
- [warp_grid](#warp_grid)
- [flowing_lines](#flowing_lines)

---

## gradient_mesh

Canvas-based animated colour blob mesh. Reads `data-colors` JSON and smoothly drifts blobs via `requestAnimationFrame`. Hook: `PhiaMeshBg`.

```heex
<div class="relative h-96 overflow-hidden rounded-xl">
  <.gradient_mesh id="hero-mesh" colors={["#f43f5e", "#6366f1", "#0ea5e9"]} />
  <div class="relative z-10 p-8">
    <h1>Your content here</h1>
  </div>
</div>
```

**Attrs**: `id` (required), `colors` (list of hex strings), `blob_count` (integer, default 6), `class`

---

## noise_bg

Inline SVG `<feTurbulence>` noise filter overlaid on the parent element. Adds organic texture to flat colour backgrounds.

```heex
<div class="relative bg-primary h-64 rounded-lg">
  <.noise_bg opacity={0.15} />
  <div class="relative z-10 p-6 text-primary-foreground">Textured section</div>
</div>
```

**Attrs**: `opacity` (float 0–1, default 0.1), `class`

---

## animated_gradient_bg

Full-bleed aurora-style animated gradient. Reuses the `--animate-aurora` keyframe already in the theme.

```heex
<div class="relative min-h-screen overflow-hidden">
  <.animated_gradient_bg from="#667eea" via="#764ba2" to="#f64f59" />
  <div class="relative z-10 flex items-center justify-center min-h-screen">
    <h1 class="text-white text-5xl font-bold">Hero Title</h1>
  </div>
</div>
```

**Attrs**: `from`, `via`, `to` (CSS color strings), `class`

---

## retro_grid

CSS perspective-transformed grid — classic synthwave look. Pure CSS, zero JS.

```heex
<div class="relative h-80 overflow-hidden bg-zinc-950 rounded-xl">
  <.retro_grid color="rgba(99,102,241,0.3)" cell_size={40} />
  <div class="relative z-10 p-8 text-white">Retro vibes</div>
</div>
```

**Attrs**: `color` (CSS color string), `cell_size` (integer px, default 32), `class`

---

## wave_bg

Animating SVG wave paths that scroll horizontally. Use for footer or section dividers.

```heex
<div class="relative h-48 overflow-hidden">
  <.wave_bg color="rgba(99,102,241,0.2)" speed={:normal} />
</div>
```

**Attrs**: `color` (CSS color), `speed` (`:slow` | `:normal` | `:fast`, default `:normal`), `class`

---

## hex_pattern

SVG hexagonal tessellation. Great for dark hero backgrounds.

```heex
<div class="relative h-64 bg-slate-900 overflow-hidden rounded-xl">
  <.hex_pattern color="rgba(255,255,255,0.05)" size={24} />
  <div class="relative z-10 p-8 text-white">Content</div>
</div>
```

**Attrs**: `color` (CSS color), `size` (integer, hex radius in px, default 20), `class`

---

## stripe_pattern

Repeating linear-gradient stripes.

```heex
<%!-- Diagonal --%>
<.stripe_pattern color="rgba(0,0,0,0.06)" direction={:diagonal} stripe_width={4} gap={12} />

<%!-- Horizontal --%>
<.stripe_pattern color="rgba(0,0,0,0.04)" direction={:horizontal} />
```

**Attrs**: `color`, `direction` (`:diagonal` | `:horizontal` | `:vertical`), `stripe_width` (px), `gap` (px), `class`

---

## checker_pattern

CSS `repeating-conic-gradient` checkerboard.

```heex
<div class="relative h-48 overflow-hidden rounded-lg">
  <.checker_pattern color="rgba(0,0,0,0.05)" size={20} />
</div>
```

**Attrs**: `color`, `size` (integer, square size in px, default 16), `class`

---

## dot_grid

Simple radial-gradient dot grid. Lighter and more minimal than `dot_pattern`.

```heex
<.dot_grid dot_size={2} spacing={20} color="rgba(100,100,100,0.3)" />
```

**Attrs**: `dot_size` (integer px), `spacing` (integer px), `color`, `class`

---

## bokeh_bg

Server-rendered blurred blob orbs that drift with CSS animation. Purely server-side — no JS required.

```heex
<div class="relative h-screen overflow-hidden">
  <.bokeh_bg
    colors={["#f59e0b", "#6366f1", "#ec4899", "#10b981"]}
    count={8}
    class="opacity-40"
  />
  <div class="relative z-10">Hero content</div>
</div>
```

**Attrs**: `colors` (list of CSS colors), `count` (integer, number of blobs), `class`

---

## conic_gradient_bg

Spinning conic gradient. Uses `@property --phia-conic-angle` for smooth CSS animation.

```heex
<div class="relative h-64 overflow-hidden rounded-xl">
  <.conic_gradient_bg from_color="#f43f5e" to_color="#6366f1" />
</div>
```

**Attrs**: `from_color`, `to_color` (CSS colors), `speed` (`:slow` | `:normal` | `:fast`), `class`

---

## flicker_grid

Canvas-based animated dot grid where dots randomly flicker their opacity each frame. Hook: `PhiaFlickerGrid`.

```heex
<div class="relative h-96 bg-zinc-950 overflow-hidden rounded-xl">
  <.flicker_grid id="fgrid" color="rgba(99,102,241,0.6)" dot_size={2} gap={16} />
  <div class="relative z-10 p-8 text-white">Dark panel content</div>
</div>
```

**Attrs**: `id` (required), `color`, `dot_size` (integer px), `gap` (integer px), `class`

---

## beam_bg

A single glowing beam that sweeps across the element via CSS animation.

```heex
<div class="relative h-1 overflow-hidden bg-border">
  <.beam_bg color="rgba(99,102,241,0.8)" />
</div>

<%!-- Or as a full hero highlight --%>
<div class="relative h-48 bg-zinc-950 overflow-hidden">
  <.beam_bg color="rgba(99,102,241,0.3)" />
</div>
```

**Attrs**: `color` (CSS color), `class`

---

## warp_grid

Perspective-transformed dot grid — a darker, subtler take on `retro_grid`.

```heex
<div class="relative h-80 bg-black overflow-hidden rounded-xl">
  <.warp_grid color="rgba(255,255,255,0.08)" />
  <div class="relative z-10 p-8 text-white">Content</div>
</div>
```

**Attrs**: `color`, `class`

---

## flowing_lines

SVG paths animated with `stroke-dashoffset` — each line draws itself continuously.

```heex
<div class="relative h-64 overflow-hidden">
  <.flowing_lines
    color="rgba(99,102,241,0.3)"
    count={5}
    stroke_width={1.5}
  />
</div>
```

**Attrs**: `color`, `count` (integer, number of paths, default 4), `stroke_width` (float), `class`

---

## Combining backgrounds

Stack multiple backgrounds for rich effects:

```heex
<div class="relative min-h-screen overflow-hidden bg-zinc-950">
  <%!-- Layer 1: base dot grid --%>
  <.dot_grid dot_size={1} spacing={24} color="rgba(255,255,255,0.05)" />
  <%!-- Layer 2: colour bokeh on top --%>
  <.bokeh_bg colors={["#6366f1", "#f43f5e"]} count={4} class="opacity-30" />
  <%!-- Content --%>
  <div class="relative z-10">
    <h1 class="text-white">Landing page</h1>
  </div>
</div>
```
