# Theme System Guide

PhiaUI uses a **CSS-first theme system** inspired by DaisyUI. Themes are pre-generated as static
CSS with `[data-phia-theme]` attribute selectors. Activating a theme requires only setting an HTML
attribute — no JavaScript CSS injection, no runtime recalculation.

## Table of Contents

- [Quick Setup](#quick-setup)
- [How it Works](#how-it-works)
- [Built-in Color Presets](#built-in-color-presets)
- [Activating a Theme](#activating-a-theme)
- [Scoped Themes (ThemeProvider)](#scoped-themes-themeprovider)
- [Runtime Theme Switching (PhiaTheme)](#runtime-theme-switching-phiatheme)
- [Anti-FOUC Script](#anti-fouc-script)
- [Customising Themes](#customising-themes)
- [Custom Color Presets](#custom-color-presets)
- [Mix Tasks Reference](#mix-tasks-reference)
- [localStorage Reference](#localstorage-reference)

---

## Quick Setup

```bash
# 1. Generate the multi-theme CSS file
mix phia.theme install
# → creates assets/css/phia-themes.css
# → injects @import into assets/css/app.css automatically

# 2. Add the unified anti-FOUC script to <head> (see below)

# 3. Activate a preset
# <html data-phia-theme="blue" class="dark">
```

---

## How it Works

### The two CSS files

PhiaUI uses two CSS files:

| File | Purpose |
|------|---------|
| `priv/static/theme.css` | Base `@theme` tokens, radius, typography, `@custom-variant dark` |
| `assets/css/phia-themes.css` | All 8 color presets as `[data-phia-theme]` selectors |

In your `app.css`:

```css
@import "tailwindcss";
@import "../../../deps/phia_ui/priv/static/theme.css";
@import "./phia-themes.css";   ← added by mix phia.theme install
```

### CSS cascade

Tailwind v4 generates `bg-primary` as `background-color: var(--color-primary)`.
CSS custom properties inherit through the DOM. A `[data-phia-theme="blue"]` on any
ancestor makes every `bg-primary` inside use the blue primary color — automatically.

```css
/* phia-themes.css (generated) */
[data-phia-theme="zinc"] {
  --color-primary: oklch(0.141 0 0);
  --color-primary-foreground: oklch(0.985 0 0);
  /* ... all color tokens ... */
}

.dark [data-phia-theme="zinc"] {
  --color-primary: oklch(0.985 0 0);
  --color-primary-foreground: oklch(0.141 0 0);
}

[data-phia-theme="blue"] {
  --color-primary: oklch(0.546 0.245 262.881);
  /* ... */
}
```

### Dark + color theme composition

```html
<!-- dark mode + blue preset — works correctly -->
<html class="dark" data-phia-theme="blue">
```

The `.dark [data-phia-theme="blue"]` selector has specificity 0,2,0 and correctly
overrides the light-mode values. ✅

---

## Built-in Color Presets

| Preset | Key | Personality |
|--------|-----|-------------|
| Zinc | `zinc` | Neutral dark — shadcn/ui default |
| Slate | `slate` | Cool blue-grey |
| Blue | `blue` | Enterprise blue |
| Rose | `rose` | Modern rose/pink |
| Orange | `orange` | Energetic orange |
| Green | `green` | Success green |
| Violet | `violet` | Premium violet |
| Neutral | `neutral` | Pure grey |

Preview all presets:

```bash
mix phia.theme list
```

---

## Activating a Theme

### App-wide

Set `data-phia-theme` on the `<html>` element in your `root.html.heex`:

```heex
<html lang="en" data-phia-theme="blue" class={if @dark_mode, do: "dark", else: ""}>
```

Or hard-code it statically:

```html
<html lang="en" data-phia-theme="violet">
```

### In a Phoenix LiveView layout

```elixir
defmodule MyAppWeb.Layouts do
  use Phoenix.Component

  def app(assigns) do
    ~H"""
    <html lang="en" data-phia-theme={@theme} class={@mode_class}>
      <head>...</head>
      <body>
        <%= @inner_content %>
      </body>
    </html>
    """
  end
end
```

---

## Scoped Themes (ThemeProvider)

`<.theme_provider>` sets `data-phia-theme` on a wrapper div, scoping the theme to
only the enclosed content. Ideal for multi-tenant apps, preview panels, or themed sections.

```heex
<%!-- Default app uses zinc, but this card uses rose --%>
<.theme_provider theme={:rose}>
  <.card>
    <.card_header>
      <.card_title class="text-primary">Rose Card</.card_title>
    </.card_header>
    <.card_content>
      <.button>Rose Button</.button>
    </.card_content>
  </.card>
</.theme_provider>
```

### With a struct (custom or tenant theme)

```elixir
# In your LiveView
def mount(_params, %{"org_id" => org_id}, socket) do
  theme = MyApp.Orgs.get_theme(org_id)  # returns %PhiaUi.Theme{}
  {:ok, assign(socket, :org_theme, theme)}
end
```

```heex
<.theme_provider theme={@org_theme}>
  <%= @inner_content %>
</.theme_provider>
```

### nil theme — no-op

```heex
<%!-- No data-phia-theme attribute rendered --%>
<.theme_provider theme={nil}>
  <.button>Uses default theme</.button>
</.theme_provider>
```

### Required: phia-themes.css

`<.theme_provider>` requires `phia-themes.css` to be imported. Without it, the attribute
is set but no CSS custom properties are applied.

```bash
mix phia.theme install
```

---

## Runtime Theme Switching (PhiaTheme)

The `PhiaTheme` hook enables users to switch color presets without a page reload.

### Setup

```javascript
// assets/js/app.js
import PhiaTheme from "./phia_hooks/theme"

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { PhiaTheme, PhiaDarkMode, /* other hooks */ }
})
```

### With a select element

```heex
<select phx-hook="PhiaTheme" id="theme-select">
  <option value="zinc">Zinc</option>
  <option value="slate">Slate</option>
  <option value="blue">Blue</option>
  <option value="rose">Rose</option>
  <option value="orange">Orange</option>
  <option value="green">Green</option>
  <option value="violet">Violet</option>
  <option value="neutral">Neutral</option>
</select>
```

### With buttons

```heex
<div class="flex gap-2">
  <.button phx-hook="PhiaTheme" id="t-zinc" data-theme="zinc" variant="outline" size="sm">
    Zinc
  </.button>
  <.button phx-hook="PhiaTheme" id="t-blue" data-theme="blue" variant="outline" size="sm">
    Blue
  </.button>
  <.button phx-hook="PhiaTheme" id="t-rose" data-theme="rose" variant="outline" size="sm">
    Rose
  </.button>
</div>
```

### What it does

1. Sets `document.documentElement.setAttribute('data-phia-theme', theme)`
2. Writes to `localStorage['phia-color-theme']`
3. Dispatches `phia:color-theme-changed` CustomEvent for other hooks (e.g. `PhiaChart` dark mode)

The preference persists across page reloads via localStorage and is restored by the anti-FOUC script.

---

## Anti-FOUC Script

Without this script, users may briefly see the default theme on page load before the hook runs.
Add it to the `<head>` of `root.html.heex` **before any stylesheets**:

```heex
<head>
  <!-- Anti-FOUC: restore dark mode + color preset before first paint -->
  <script>
    (function() {
      var mode = localStorage.getItem('phia-mode') || localStorage.getItem('phia-theme');
      if (mode === 'dark' || (!mode && matchMedia('(prefers-color-scheme: dark)').matches)) {
        document.documentElement.classList.add('dark');
      }
      var ct = localStorage.getItem('phia-color-theme');
      if (ct) document.documentElement.setAttribute('data-phia-theme', ct);
    })();
  </script>
  <!-- stylesheets below -->
  <link rel="stylesheet" href={~p"/assets/app.css"} />
</head>
```

---

## Customising Themes

### Apply a preset to your theme.css

```bash
# Overwrites your assets/css/theme.css with the blue preset's variables
mix phia.theme apply blue
```

### Export a preset for editing

```bash
# JSON format (default)
mix phia.theme export blue > my-brand-base.json

# CSS with attribute selectors
mix phia.theme export blue --format css > my-brand-base.css
```

### Import a custom theme

Create a JSON file (based on the export format):

```json
{
  "name": "my-brand",
  "label": "My Brand",
  "radius": "0.375rem",
  "colors": {
    "light": {
      "background": "oklch(1 0 0)",
      "foreground": "oklch(0.09 0 0)",
      "primary": "oklch(0.55 0.20 230)",
      "primary_foreground": "oklch(1 0 0)",
      "secondary": "oklch(0.94 0 0)",
      "secondary_foreground": "oklch(0.09 0 0)",
      "muted": "oklch(0.95 0 0)",
      "muted_foreground": "oklch(0.45 0 0)",
      "accent": "oklch(0.93 0.02 230)",
      "accent_foreground": "oklch(0.09 0 0)",
      "destructive": "oklch(0.55 0.22 27)",
      "border": "oklch(0.89 0 0)",
      "input": "oklch(0.89 0 0)",
      "ring": "oklch(0.55 0.20 230)",
      "card": "oklch(1 0 0)",
      "card_foreground": "oklch(0.09 0 0)",
      "popover": "oklch(1 0 0)",
      "popover_foreground": "oklch(0.09 0 0)",
      "sidebar_background": "oklch(0.97 0 0)",
      "sidebar_foreground": "oklch(0.36 0 0)"
    },
    "dark": {
      "background": "oklch(0.12 0 0)",
      "foreground": "oklch(0.97 0 0)",
      "primary": "oklch(0.75 0.18 230)",
      "primary_foreground": "oklch(0.09 0 0)"
    }
  },
  "typography": {
    "font_sans": "\"Inter\", system-ui, sans-serif"
  }
}
```

Import and apply:

```bash
mix phia.theme import ./my-brand.json
```

### Generate CSS from Elixir

```elixir
# Generate CSS for a specific theme with custom selector
theme = PhiaUi.Theme.get!(:blue)
css = PhiaUi.ThemeCSS.generate(theme, selector: "#my-app")
File.write!("assets/css/my-section.css", css)

# Generate all themes as attribute selectors
css = PhiaUi.ThemeCSS.generate_all()
File.write!("assets/css/phia-themes.css", css)

# Generate just one theme as attribute selector
css = PhiaUi.ThemeCSS.generate_for_selector(theme)
# => "[data-phia-theme=\"blue\"] { ... } .dark [data-phia-theme=\"blue\"] { ... }"
```

---

## Custom Color Presets

To create a reusable preset module:

```elixir
defmodule MyApp.Themes.Brand do
  @moduledoc "My Brand color preset for PhiaUI"

  def theme do
    %PhiaUi.Theme{
      name: "brand",
      label: "My Brand",
      radius: "0.375rem",
      colors: %{
        light: %{
          background: "oklch(1 0 0)",
          foreground: "oklch(0.09 0 0)",
          primary: "oklch(0.55 0.20 230)",
          primary_foreground: "oklch(1 0 0)",
          # ... add remaining tokens
        },
        dark: %{
          background: "oklch(0.12 0 0)",
          foreground: "oklch(0.97 0 0)",
          primary: "oklch(0.75 0.18 230)",
          primary_foreground: "oklch(0.09 0 0)",
          # ... add remaining tokens
        }
      },
      typography: %{
        font_sans: ~s("Inter", system-ui, sans-serif)
      }
    }
  end
end
```

Then generate its CSS:

```elixir
theme = MyApp.Themes.Brand.theme()
css = PhiaUi.ThemeCSS.generate_for_selector(theme)
```

---

## Mix Tasks Reference

```bash
# List all built-in presets with primary color values
mix phia.theme list

# Generate phia-themes.css and inject @import into app.css
mix phia.theme install

# Generate only specific themes
mix phia.theme install --themes zinc,blue,rose

# Custom output path
mix phia.theme install --output priv/static/phia-themes.css

# Apply a preset to assets/css/theme.css
mix phia.theme apply zinc

# Export preset as JSON
mix phia.theme export blue > blue.json

# Export preset as CSS (with attribute selectors)
mix phia.theme export blue --format css

# Import a custom theme from JSON
mix phia.theme import ./my-brand.json
```

---

## localStorage Reference

| Key | Written by | Value | Purpose |
|-----|-----------|-------|---------|
| `phia-mode` | `PhiaDarkMode` hook | `"dark"` or `"light"` | Dark mode preference (canonical) |
| `phia-theme` | `PhiaDarkMode` hook | same as `phia-mode` | Legacy key (backward compat) |
| `phia-color-theme` | `PhiaTheme` hook | preset name, e.g. `"blue"` | Color preset preference |

---

← [Back to README](../../README.md) | [Dashboard Tutorial](tutorial-dashboard.md)
