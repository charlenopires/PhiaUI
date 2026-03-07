# Surface

22 surface components — glass, bento grids, animated borders, spotlight effects, and overlay surfaces. Use these to build modern dashboard panels, hero sections, and layered UIs.

**Modules**: `PhiaUi.Components.Surface`, `PhiaUi.Components.Glass`, `PhiaUi.Components.AnimatedSurface`, `PhiaUi.Components.OverlaySurface`, `PhiaUi.Components.Bento`

```elixir
import PhiaUi.Components.Surface
```

---

## Table of Contents

**Base Surfaces**
- [surface](#surface)
- [paper](#paper)
- [inset_surface](#inset_surface)
- [scrollable_surface](#scrollable_surface)
- [tonal_surface](#tonal_surface)

**Glass**
- [glass_card](#glass_card)
- [glass_panel](#glass_panel)
- [acrylic_surface](#acrylic_surface)
- [liquid_glass](#liquid_glass)
- [neon_glow_card](#neon_glow_card)

**Animated Surfaces**
- [border_beam](#border_beam)
- [shine_border](#shine_border)
- [magic_card](#magic_card)
- [card_spotlight](#card_spotlight)
- [moving_border](#moving_border)

**Overlay Surfaces**
- [scrim](#scrim)
- [image_scrim](#image_scrim)
- [gradient_overlay](#gradient_overlay)
- [spotlight_overlay](#spotlight_overlay)
- [bottom_sheet](#bottom_sheet)

**Bento**
- [bento_grid](#bento_grid)
- [bento_item](#bento_item)

---

## surface

Base elevated container. Supports `elevation` levels 0–5 that map to box-shadow scales.

```heex
<.surface elevation={2} class="p-6 rounded-xl">
  <h2>Dashboard panel</h2>
  <p class="text-muted-foreground">Content goes here</p>
</.surface>
```

**Attrs**: `elevation` (0–5, default 1), `class`, `:let`

---

## paper

Flat white/dark surface with a thin border — Material-style.

```heex
<.paper class="p-4 rounded-lg">
  <.form for={@form} phx-submit="save">
    <.phia_input field={@form[:name]} label="Name" />
    <.button>Submit</.button>
  </.form>
</.paper>
```

**Attrs**: `class`

---

## inset_surface

Sunken surface — useful for code blocks or input areas.

```heex
<.inset_surface class="p-4 rounded-lg font-mono text-sm">
  <%= @output %>
</.inset_surface>
```

---

## scrollable_surface

Scrollable container with styled scrollbar and max-height.

```heex
<.scrollable_surface max_height="400px" class="rounded-lg">
  <%= for item <- @long_list do %>
    <div class="p-3 border-b"><%= item.name %></div>
  <% end %>
</.scrollable_surface>
```

**Attrs**: `max_height` (CSS string, default `"300px"`), `class`

---

## tonal_surface

Tinted surface using the `primary` colour at low opacity — great for call-to-action sections.

```heex
<.tonal_surface class="p-8 rounded-xl text-center">
  <.heading level={3}>Upgrade to Pro</.heading>
  <.button variant="default" class="mt-4">Get started</.button>
</.tonal_surface>
```

---

## glass_card

Frosted-glass card with `backdrop-blur` and semi-transparent border.

```heex
<div class="relative bg-gradient-to-br from-indigo-500 to-purple-600 p-8 rounded-xl">
  <.glass_card class="p-6 max-w-sm">
    <.heading level={3} class="text-white">Premium plan</.heading>
    <.paragraph class="text-white/80">Everything you need to ship fast.</.paragraph>
    <.button class="mt-4 bg-white text-primary">Start free trial</.button>
  </.glass_card>
</div>
```

**Attrs**: `blur` (`:sm` | `:md` | `:lg` | `:xl`, default `:md`), `class`

---

## glass_panel

Wider glass surface — use for sidebars, nav panels, or info columns.

```heex
<.glass_panel class="w-72 p-4 space-y-2">
  <%= for item <- @nav_items do %>
    <.nav_link href={item.href}><%= item.label %></.nav_link>
  <% end %>
</.glass_panel>
```

---

## acrylic_surface

Windows Acrylic-style surface with noise texture and backdrop blur.

```heex
<.acrylic_surface class="p-6 rounded-xl">
  <.heading level={4}>Settings</.heading>
</.acrylic_surface>
```

---

## liquid_glass

Highly reflective glass with inner highlight — looks dimensional on coloured backgrounds.

```heex
<div class="bg-gradient-to-br from-rose-400 to-indigo-600 p-12">
  <.liquid_glass class="p-8">
    <.display_text class="text-white">Hello</.display_text>
  </.liquid_glass>
</div>
```

---

## neon_glow_card

Card with a coloured neon glow animation pulsing around the border.

```heex
<.neon_glow_card color="#6366f1" class="p-6">
  <.heading level={3}>Featured</.heading>
  <.paragraph>This card glows.</.paragraph>
</.neon_glow_card>
```

**Attrs**: `color` (CSS color for glow), `class`

---

## border_beam

Animated beam of light that travels around the card border.

```heex
<.card class="relative overflow-hidden p-6">
  <.border_beam />
  <h3>Special offer</h3>
</.card>
```

**Attrs**: `duration` (seconds, default 4), `color` (CSS color), `class`

---

## shine_border

Sweeping shine gradient across the border — subtler than `border_beam`.

```heex
<.shine_border class="p-6 rounded-xl">
  <p>Hover me</p>
</.shine_border>
```

---

## magic_card

Cursor-following gradient spotlight inside the card. Hook: `PhiaMagicCard`.

```heex
<.magic_card id="mc-1" class="p-6 cursor-pointer">
  <.heading level={3}>Hover me</.heading>
  <.paragraph class="text-muted-foreground">The gradient follows your cursor.</.paragraph>
</.magic_card>
```

**Attrs**: `id` (required), `gradient_color` (CSS color), `class`

---

## card_spotlight

Radial spotlight that follows cursor inside the card. More subtle than `magic_card`. Hook: `PhiaCardSpotlight`.

```heex
<.card_spotlight id="cs-1" class="p-8">
  <.heading level={2}>PhiaUI</.heading>
</.card_spotlight>
```

**Attrs**: `id` (required), `class`

---

## moving_border

Card with a continuously rotating gradient border.

```heex
<.moving_border class="p-6" duration={3}>
  <.heading level={4}>Animated border</.heading>
</.moving_border>
```

**Attrs**: `duration` (seconds), `border_radius` (CSS value), `class`

---

## scrim

Full-bleed semi-transparent overlay — use to dim background content behind a modal.

```heex
<.scrim opacity={0.5} class="z-40" phx-click="close_modal" />
```

**Attrs**: `opacity` (float 0–1), `class`

---

## image_scrim

Gradient overlay for hero images — ensures text legibility.

```heex
<div class="relative h-96">
  <img src={@hero_url} class="w-full h-full object-cover" />
  <.image_scrim direction={:bottom} intensity={0.7} />
  <div class="absolute bottom-6 left-6 text-white">
    <h1 class="text-3xl font-bold">Article title</h1>
  </div>
</div>
```

**Attrs**: `direction` (`:bottom` | `:top` | `:left` | `:right`), `intensity` (float 0–1), `class`

---

## gradient_overlay

Coloured gradient overlay for sections — use for decorative purpose or legibility.

```heex
<div class="relative">
  <.gradient_overlay from="primary" to="transparent" direction={:bottom} />
  <div class="relative z-10">Content</div>
</div>
```

---

## spotlight_overlay

Full-page radial spotlight that follows the cursor.

```heex
<.spotlight_overlay color="rgba(99,102,241,0.15)" />
```

---

## bottom_sheet

Mobile-style bottom sheet with slide-up animation. Open/close via `open_bottom_sheet/1` and `close_bottom_sheet/1` JS commands.

```heex
<.button phx-click={open_bottom_sheet("sheet-1")}>Open sheet</.button>

<.bottom_sheet id="sheet-1" title="Options">
  <div class="space-y-2 p-4">
    <.button variant="ghost" class="w-full">Share</.button>
    <.button variant="ghost" class="w-full">Edit</.button>
    <.button variant="destructive" class="w-full">Delete</.button>
  </div>
</.bottom_sheet>
```

**Attrs**: `id` (required), `title`, `class`

---

## bento_grid

CSS grid container for bento-style dashboards. Children are `bento_item` components.

```heex
<.bento_grid cols={3} class="gap-4">
  <.bento_item colspan={2} rowspan={1} class="p-6 bg-card rounded-xl border">
    <.bento_header title="Revenue" badge="MRR" />
    <.line_chart series={@revenue_series} height={120} />
  </.bento_item>
  <.bento_item colspan={1} class="p-6 bg-card rounded-xl border">
    <.bento_header title="Users" />
    <.number_ticker value={@user_count} class="text-4xl font-bold" />
  </.bento_item>
  <.bento_item colspan={3} class="p-6 bg-card rounded-xl border">
    <.bento_header title="Activity" />
    <.bar_chart series={@activity} height={160} />
  </.bento_item>
</.bento_grid>
```

**Attrs (`bento_grid`)**: `cols` (integer, default 3), `class`

**Attrs (`bento_item`)**: `colspan` (integer, default 1), `rowspan` (integer, default 1), `class`

---

## Real-world: SaaS pricing section

```heex
<section class="relative py-24 overflow-hidden">
  <.animated_gradient_bg from="#1e1b4b" via="#312e81" to="#1e1b4b" />

  <div class="relative z-10 max-w-5xl mx-auto px-6">
    <.heading level={2} class="text-center text-white mb-12">Pricing</.heading>

    <div class="grid grid-cols-3 gap-6">
      <.glass_card class="p-8">
        <.bento_badge>Starter</.bento_badge>
        <.display_text class="mt-2 text-white">$9</.display_text>
        <.paragraph class="text-white/70">/month</p>
        <.button class="w-full mt-6 bg-white text-primary">Get started</.button>
      </.glass_card>

      <.magic_card id="pro-card" class="p-8 border-primary">
        <.bento_badge variant="primary">Pro</.bento_badge>
        <.display_text class="mt-2 text-white">$29</.display_text>
        <.paragraph class="text-white/70">/month</.paragraph>
        <.button class="w-full mt-6" variant="default">Get started</.button>
      </.magic_card>

      <.glass_card class="p-8">
        <.bento_badge>Enterprise</.bento_badge>
        <.display_text class="mt-2 text-white">Custom</.display_text>
        <.paragraph class="text-white/70">Talk to sales</.paragraph>
        <.button class="w-full mt-6 bg-white text-primary">Contact us</.button>
      </.glass_card>
    </div>
  </div>
</section>
```
