# PhiaUI

**Enterprise-ready Phoenix LiveView component library inspired by shadcn/ui.**

Ejectable components with zero heavy JS dependencies, full WAI-ARIA accessibility, and built-in analytics widgets for financial terminals, BI dashboards, and KPI monitors.

[![Hex.pm](https://img.shields.io/hexpm/v/phia_ui.svg)](https://hex.pm/packages/phia_ui)
[![Elixir](https://img.shields.io/badge/elixir-%3E%3D1.17-purple)](https://elixir-lang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## Why PhiaUI?

| Feature | PhiaUI | salad_ui |
|---------|--------|----------|
| Ejectable architecture | Yes | Partial |
| Enterprise analytics widgets | Yes | No |
| Zero npm deps for interactivity | Yes | No |
| Native ClassMerger (no tw_merge) | Yes | No |
| TailwindCSS v4 theme system | Yes | No |
| WAI-ARIA on all interactive | Yes | Partial |

---

## Implemented Components

### Primitives (Stateless, no JS)

| Component | Function | Sub-components |
|-----------|----------|----------------|
| Button | `button/1` | — |
| Card | `card/1` | `card_header`, `card_title`, `card_description`, `card_content`, `card_footer` |
| Badge | `badge/1` | — |
| Table | `table/1` | `table_header`, `table_body`, `table_footer`, `table_row`, `table_head`, `table_cell`, `table_caption` |
| Icon | `icon/1` | — |

### Form Integration

| Component | Function | Description |
|-----------|----------|-------------|
| Input | `phia_input/1` | Label + input + description + errors, integrated with `Phoenix.HTML.FormField` |
| Textarea | `phia_textarea/1` | Multi-line textarea with form integration |
| Select | `phia_select/1` | Native select with FormField integration |
| Form | `form_field/1`, `form_label/1`, `form_message/1` | Composable form primitives |
| Tags Input | `tags_input/1` | Multi-tag input with deduplication |
| Image Upload | `image_upload/1` | Drop zone + preview, uses native Phoenix LiveView uploads |
| Rich Text Editor | `rich_text_editor/1` | WYSIWYG editor, toolbar with 14 commands, zero npm deps |

### Interactive (JS Hooks)

| Component | Function | Hook |
|-----------|----------|------|
| Dialog | `dialog/1` | `PhiaDialog` |
| Dropdown Menu | `dropdown_menu/1` | `PhiaDropdownMenu` |
| Accordion | `accordion/1` | `Phoenix.LiveView.JS` only |

### Dashboard Shell

| Component | Function | Description |
|-----------|----------|-------------|
| Shell | `shell/1` | CSS Grid desktop layout (sidebar 240px + 1fr) |
| Sidebar | `sidebar/1` | Fixed sidebar with brand, nav, footer slots |
| Sidebar Item | `sidebar_item/1` | Navigation item with active state |
| Topbar | `topbar/1` | Full-width header bar |
| Mobile Sidebar Toggle | `mobile_sidebar_toggle/1` | Hamburger trigger (hidden on md+) |

### Dashboard Widgets

| Component | Function | Description |
|-----------|----------|-------------|
| Stat Card | `stat_card/1` | KPI card with trend indicator (up/down/neutral) |
| Metric Grid | `metric_grid/1` | Responsive grid layout (1–4 cols) |
| Chart Shell | `chart_shell/1` | Titled card wrapper for any chart library |

---

## Installation

Add to `mix.exs`:

```elixir
def deps do
  [
    {:phia_ui, "~> 0.1.0"}
  ]
end
```

Run the installer:

```bash
mix phia.install
```

This copies the TailwindCSS v4 theme and the ClassMerger into your project.

### TailwindCSS v4 Theme

In your `assets/css/app.css`:

```css
@import "tailwindcss";
@import "../../../deps/phia_ui/priv/static/theme.css";
```

Or after ejection:

```css
@import "tailwindcss";
@import "./phia_theme.css";
```

The theme provides semantic design tokens:

```css
@theme {
  --color-primary: oklch(0.21 0.006 285.885);
  --color-primary-foreground: oklch(0.985 0 0);
  --color-destructive: oklch(0.577 0.245 27.325);
  --radius-sm: 0.25rem;
  --radius-md: 0.375rem;
  --radius-lg: 0.5rem;
  /* ... */
}
```

---

## Mix Tasks

```bash
# Install core dependencies and setup
mix phia.install

# List all available components
mix phia.list

# Eject specific components into your codebase
mix phia.add button card badge

# Generate the Lucide SVG sprite
mix phia.icons
```

---

## Usage Examples

### Button

```heex
<.button>Click me</.button>
<.button variant="destructive">Delete</.button>
<.button variant="outline" size="sm">Small outline</.button>
<.button variant="ghost" disabled>Disabled</.button>
```

Variants: `default`, `destructive`, `outline`, `secondary`, `ghost`, `link`
Sizes: `default`, `sm`, `lg`, `icon`

### Card Composition

```heex
<.card>
  <.card_header>
    <.card_title>Revenue</.card_title>
    <.card_description>Last 30 days</.card_description>
  </.card_header>
  <.card_content>
    <p class="text-3xl font-bold">$48,290</p>
  </.card_content>
  <.card_footer>
    <.badge variant="secondary">+12.5%</.badge>
  </.card_footer>
</.card>
```

### Badge

```heex
<.badge>Default</.badge>
<.badge variant="destructive">Error</.badge>
<.badge variant="outline">Pending</.badge>
```

### Icon

```heex
<.icon name="check" />
<.icon name="alert-triangle" size="lg" class="text-destructive" />
```

Requires the Lucide sprite at `/priv/static/icons/lucide-sprite.svg`. Generate with `mix phia.icons`.

### Table with LiveView Streams

```heex
<.table>
  <.table_header>
    <.table_row>
      <.table_head>Name</.table_head>
      <.table_head>Status</.table_head>
      <.table_head class="text-right">Amount</.table_head>
    </.table_row>
  </.table_header>
  <.table_body>
    <.table_row :for={{dom_id, row} <- @streams.rows} id={dom_id}>
      <.table_cell><%= row.name %></.table_cell>
      <.table_cell><.badge><%= row.status %></.badge></.table_cell>
      <.table_cell class="text-right"><%= row.amount %></.table_cell>
    </.table_row>
  </.table_body>
</.table>
```

### Form with Changeset

```heex
<.form for={@form} phx-change="validate" phx-submit="save">
  <.phia_input field={@form[:name]} label="Full Name" />
  <.phia_input field={@form[:email]} type="email" label="Email" description="We won't spam you." />
  <.phia_textarea field={@form[:bio]} label="Bio" rows={4} />
  <.phia_select field={@form[:role]} options={["admin", "editor", "viewer"]} label="Role" />
  <.button type="submit">Save</.button>
</.form>
```

### Tags Input

```heex
<.tags_input
  field={@form[:tags]}
  label="Tags"
  placeholder="Add a tag..."
  separator=","
/>
```

Tags are stored as a comma-separated string in the hidden input. Requires the `PhiaTagsInput` JS hook.

### Image Upload

```heex
<.live_file_input upload={@uploads.avatar} class="sr-only" />
<.image_upload upload={@uploads.avatar} label="Profile photo" />
```

In your LiveView:

```elixir
def mount(_params, _session, socket) do
  {:ok, allow_upload(socket, :avatar, accept: ~w(.jpg .jpeg .png), max_entries: 1)}
end
```

### Rich Text Editor

```heex
<.rich_text_editor
  field={@form[:content]}
  label="Content"
  placeholder="Start writing..."
  min_height="200px"
/>
```

Requires the `PhiaRichTextEditor` JS hook. Toolbar includes: bold, italic, underline, strikethrough, H1–H3, paragraph, bullet list, ordered list, blockquote, inline code, code block, link.

### Dialog

```heex
<.dialog id="confirm-dialog">
  <.dialog_trigger>
    <.button variant="outline">Open dialog</.button>
  </.dialog_trigger>
  <.dialog_content>
    <.dialog_header>
      <.dialog_title>Confirm action</.dialog_title>
      <.dialog_description>This cannot be undone.</.dialog_description>
    </.dialog_header>
    <.dialog_footer>
      <.dialog_close><.button variant="outline">Cancel</.button></.dialog_close>
      <.button phx-click="confirm">Confirm</.button>
    </.dialog_footer>
  </.dialog_content>
</.dialog>
```

Requires the `PhiaDialog` JS hook. Features: focus trap, Escape key, scroll locking, auto-focus.

### Dropdown Menu

```heex
<.dropdown_menu id="actions-menu">
  <.dropdown_menu_trigger>
    <.button variant="ghost" size="icon"><.icon name="more-horizontal" /></.button>
  </.dropdown_menu_trigger>
  <.dropdown_menu_content>
    <.dropdown_menu_label>Actions</.dropdown_menu_label>
    <.dropdown_menu_separator />
    <.dropdown_menu_item phx-click="edit">Edit</.dropdown_menu_item>
    <.dropdown_menu_item phx-click="delete" class="text-destructive">Delete</.dropdown_menu_item>
  </.dropdown_menu_content>
</.dropdown_menu>
```

Requires the `PhiaDropdownMenu` JS hook. Features: smart auto-flip positioning, click-outside detection, keyboard navigation.

### Accordion

```heex
<.accordion type="single">
  <.accordion_item accordion_id="item-1">
    <.accordion_trigger accordion_id="item-1">What is PhiaUI?</.accordion_trigger>
    <.accordion_content accordion_id="item-1">
      A Phoenix LiveView component library for enterprise dashboards.
    </.accordion_content>
  </.accordion_item>
  <.accordion_item accordion_id="item-2">
    <.accordion_trigger accordion_id="item-2">Is it ejectable?</.accordion_trigger>
    <.accordion_content accordion_id="item-2">
      Yes. Use <code>mix phia.add</code> to copy components into your project.
    </.accordion_content>
  </.accordion_item>
</.accordion>
```

Uses `Phoenix.LiveView.JS` only — no external hook required.

### Dashboard Shell

```heex
<.shell>
  <:topbar>
    <.topbar>
      <:brand>MyApp</:brand>
      <.mobile_sidebar_toggle />
    </.topbar>
  </:topbar>
  <:sidebar>
    <.sidebar>
      <:brand><span class="font-bold">MyApp</span></:brand>
      <:nav_items>
        <.sidebar_item href="/dashboard" active={@current_path == "/dashboard"}>
          <.icon name="layout-dashboard" /> Dashboard
        </.sidebar_item>
        <.sidebar_item href="/reports">
          <.icon name="bar-chart" /> Reports
        </.sidebar_item>
      </:nav_items>
    </.sidebar>
  </:sidebar>
  <main class="p-6">
    <%= @inner_content %>
  </main>
</.shell>
```

Desktop: CSS Grid `grid-cols-[240px_1fr] h-screen`. Mobile: Flexbox drawer toggled via `Phoenix.LiveView.JS` (no Alpine.js).

### Stat Card + Metric Grid

```heex
<.metric_grid cols={4}>
  <.stat_card
    title="Revenue"
    value="$48,290"
    trend="up"
    trend_value="+12.5%"
    description="vs last month"
  >
    <:icon><.icon name="dollar-sign" size="lg" /></:icon>
  </.stat_card>
  <.stat_card
    title="Active Users"
    value="2,840"
    trend="up"
    trend_value="+8.2%"
    description="daily active"
  />
  <.stat_card
    title="Churn Rate"
    value="3.1%"
    trend="down"
    trend_value="-0.4%"
    description="this month"
  />
  <.stat_card
    title="Avg Session"
    value="4m 32s"
    trend="neutral"
    trend_value="0%"
    description="no change"
  />
</.metric_grid>
```

### Chart Shell

```heex
<.chart_shell title="Monthly Revenue" description="Jan–Dec 2024" period="2024">
  <:actions>
    <.button variant="outline" size="sm">Export</.button>
  </:actions>
  <%!-- Drop in any chart library: VegaLite, Chart.js, D3, etc. --%>
  <canvas id="revenue-chart" phx-hook="RevenueChart" />
</.chart_shell>
```

---

## ClassMerger

The `cn/1` function merges Tailwind classes with conflict resolution (last wins per group):

```elixir
import PhiaUi.ClassMerger, only: [cn: 1]

cn(["px-4 py-2", @class])
# => "px-4 py-2 mt-4" (if @class = "mt-4")

cn(["px-4", "px-8"])
# => "px-8"  (conflict resolved: last wins)

cn(["text-red-500", @error && "text-destructive", @class])
# => falsy values are filtered out
```

Backed by an ETS-cached GenServer (`PhiaUi.ClassMerger.Cache`) for zero-overhead repeated calls.

---

## JS Hooks Setup

Register the four hooks in `assets/js/app.js`:

```javascript
import PhiaDialog from "./phia_hooks/dialog.js"
import PhiaDropdownMenu from "./phia_hooks/dropdown_menu.js"
import PhiaTagsInput from "./phia_hooks/tags_input.js"
import PhiaRichTextEditor from "./phia_hooks/rich_text_editor.js"

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: { PhiaDialog, PhiaDropdownMenu, PhiaTagsInput, PhiaRichTextEditor }
})
```

Hook files are copied to your project by `mix phia.install` or `mix phia.add <component>`.

| Hook | Component | Lines | Features |
|------|-----------|-------|----------|
| `PhiaDialog` | Dialog | 152 | Focus trap, Escape, scroll lock, auto-focus |
| `PhiaDropdownMenu` | Dropdown Menu | 174 | Smart positioning, click-outside, arrow key nav |
| `PhiaTagsInput` | Tags Input | 202 | Add/remove tags, deduplication, CSV sync |
| `PhiaRichTextEditor` | Rich Text Editor | 300+ | 14 toolbar commands, active state detection |

---

## Ejectable Architecture

PhiaUI is not a traditional runtime dependency. Components are source code you own:

```bash
# Eject button and card into your project
mix phia.add button card
```

This copies:
- `lib/your_app/components/button.ex`
- `lib/your_app/components/card.ex`
- `assets/js/phia_hooks/` (any required hooks)

After ejection, modify components freely — PhiaUI has no opinion on your code after the copy.

This contrasts with Tailwind UI or shadcn/ui's copy-paste model by automating the copy via Mix tasks and keeping component metadata in a registry.

---

## Use Cases

- **Financial terminals** — StatCard + MetricGrid for live P&L, position tracking, risk dashboards
- **BI dashboards** — ChartShell wrapping VegaLite/Chart.js/D3 with consistent chrome
- **KPI monitors** — Metric grids with real-time trend indicators
- **Admin panels** — Shell + Sidebar + Table + Dialog for CRUD interfaces
- **Internal tools** — Form components with Ecto changeset integration for data entry workflows

---

## Documentation

Generate docs locally:

```bash
mix docs
```

Full documentation will be published to [HexDocs](https://hexdocs.pm/phia_ui) on release.

---

## Contributing

We value **Clarity**, **Simplicity**, and **Testability**.

- All features require a specification with acceptance criteria before implementation
- TDD: write failing tests first (red → green)
- No Alpine.js, no npm deps for interactivity
- `cn/1` implemented natively — no tw_merge or similar
- All code passes `mix credo --strict` without warnings

