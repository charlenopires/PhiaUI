# PhiaUI

**Enterprise-ready Phoenix LiveView component library — 48 components, inspired by shadcn/ui.**

Ejectable components with zero heavy JS dependencies, full WAI-ARIA accessibility, TailwindCSS v4 semantic tokens, and built-in analytics widgets for financial terminals, BI dashboards, and KPI monitors.

[![Hex.pm](https://img.shields.io/hexpm/v/phia_ui.svg)](https://hex.pm/packages/phia_ui)
[![Elixir](https://img.shields.io/badge/elixir-%3E%3D1.17-purple)](https://elixir-lang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## Why PhiaUI?

| Feature | PhiaUI | salad_ui |
|---------|--------|----------|
| Ejectable architecture | ✓ | Partial |
| Enterprise analytics widgets | ✓ | ✗ |
| Zero npm deps for interactivity | ✓ | ✗ |
| Native ClassMerger (no tw_merge) | ✓ | ✗ |
| TailwindCSS v4 theme system | ✓ | ✗ |
| CSS-first theme system (8 presets, runtime switching) | ✓ | ✗ |
| WAI-ARIA on all interactive | ✓ | Partial |
| Dark mode, Ctrl+K, Date Pickers, Carousels | ✓ | ✗ |

---

## Component Library — 48 Components

### Primitives & Feedback — 8 components

Stateless HEEx components. No JavaScript. → [Full examples & use cases](docs/components/primitives.md)

| Component | Function | Description |
|-----------|----------|-------------|
| Button | `button/1` | 6 variants × 4 sizes, disabled state |
| Card | `card/1` | Composable header / content / footer slots |
| Badge | `badge/1` | 4 variants for status labels |
| Icon | `icon/1` | Lucide SVG sprite, 4 sizes |
| Alert | `alert/1` | 4 variants with optional icon slot |
| Skeleton | `skeleton/1` | `animate-pulse` placeholders for loading states |
| Breadcrumb | `breadcrumb/1` | 7 sub-components, `aria-current="page"` |
| Pagination | `pagination/1` | Server-side pagination with `phx-click` |

### Form Integration — 9 components

Integrated with `Phoenix.HTML.Form` and Ecto changesets. → [Full examples & use cases](docs/components/forms.md)

| Component | Function | Description |
|-----------|----------|-------------|
| Input | `phia_input/1` | Label + input + description + errors |
| Textarea | `phia_textarea/1` | Multi-line with form integration |
| Select | `phia_select/1` | Native select with FormField |
| Form | `form_field/1`, `form_label/1`, `form_message/1` | Composable form primitives |
| Tags Input | `tags_input/1` | Multi-tag, deduplication, CSV sync — `PhiaTagsInput` |
| Image Upload | `image_upload/1` | Drop zone + preview, native Phoenix uploads |
| Rich Text Editor | `rich_text_editor/1` | WYSIWYG, 14 toolbar commands, zero npm — `PhiaRichTextEditor` |
| Checkbox | `checkbox/1` | Native checkbox, indeterminate state, FormField integration |
| Calendar | `calendar/1` | Server-rendered monthly grid, single/range mode, keyboard nav |

### Interactive Components — 15 components

Vanilla JS hooks for accessible behaviors. → [Full examples & use cases](docs/components/interactive.md)

| Component | Function | Hook | Key features |
|-----------|----------|------|--------------|
| Dialog | `dialog/1` | `PhiaDialog` | Focus trap, Escape, scroll lock |
| Dropdown Menu | `dropdown_menu/1` | `PhiaDropdownMenu` | Smart flip, click-outside, arrow keys |
| Accordion | `accordion/1` | (LiveView.JS) | Single / multiple mode |
| Tooltip | `tooltip/1` | `PhiaTooltip` | Hover + focus, 4 positions, smart flip |
| Popover | `popover/1` | `PhiaPopover` | Click-open, focus trap, click-outside |
| Toast | `toast/1` | `PhiaToast` | `push_event` driven, auto-dismiss, stacking |
| Command Menu | `command/1` | `PhiaCommand` | Ctrl+K global, Arrow keys, server-side filter |
| Date Range Picker | `date_range_picker/1` | `PhiaDateRangePicker` | Dual calendar, range highlight, min/max |
| Collapsible | `collapsible/1` | (LiveView.JS) | Zero hooks, server-controlled open state |
| Alert Dialog | `alert_dialog/1` | `PhiaDialog` | `role="alertdialog"`, destructive variant |
| Carousel | `carousel/1` | `PhiaCarousel` | Touch swipe, keyboard, loop, indicators |
| Context Menu | `context_menu/1` | `PhiaContextMenu` | Right-click, smart positioning, WAI-ARIA |
| Drawer | `drawer/1` | `PhiaDrawer` | 4 directions, focus trap, backdrop click |
| Combobox | `combobox/1` | — | Server-side search filter, FormField |
| Date Picker | `date_picker/1` | — | Calendar + Popover compose, format attr |

### Utilities & Composed — 8 components

CSS-only utilities and composed display patterns. → [Full examples & use cases](docs/components/utilities.md)

| Component | Function | Description |
|-----------|----------|-------------|
| Aspect Ratio | `aspect_ratio/1` | CSS padding-top trick, any ratio (16:9, 4:3, 1:1…) |
| Direction | `direction/1` | LTR/RTL wrapper for multilingual content |
| Empty State | `empty/1` | Centered placeholder with icon/title/description/action slots |
| Field | `field/1` | Standalone form field layout without FormField |
| Button Group | `button_group/1` | Unified button toolbar, H/V orientation |
| Avatar | `avatar/1` | Circular profile image with initials fallback, avatar_group |
| Tabs Nav | `tabs_nav/1`, `tabs_nav_item/1` | Navigation tabs with 3 variants: underline, pills, segment |
| Theme Provider | `theme_provider/1` | Scoped CSS theme wrapper using `data-phia-theme` attribute |

### Dashboard & Analytics — 8 components

Enterprise layout shell, data tables, KPI widgets, and chart integration. → [Full examples & use cases](docs/components/dashboard.md)

| Component | Function | Description |
|-----------|----------|-------------|
| Shell | `shell/1` | CSS Grid desktop layout (sidebar 240px + 1fr) |
| Sidebar | `sidebar/1` + `sidebar_item/1` | Fixed sidebar, brand/nav/footer slots |
| Topbar | `topbar/1` | Full-width header, actions slot |
| Dark Mode Toggle | `dark_mode_toggle/1` | `PhiaDarkMode`: localStorage + `prefers-color-scheme` |
| Table | `table/1` | 8 sub-components, `phx-update="stream"` compatible |
| DataGrid | `data_grid/1` | Sortable columns, `phx-click` sort events |
| Stat Card + Metric Grid | `stat_card/1`, `metric_grid/1` | KPI cards with trend indicators, responsive grid |
| Chart Shell + PhiaChart | `chart_shell/1`, `phia_chart/1` | Any chart library wrapper + ECharts hook |

---

## Live Sample — PhiaUI Dashboard

See PhiaUI in action with a full enterprise dashboard built entirely from library components:

**[github.com/charlenopires/PhiaUI-samples](https://github.com/charlenopires/PhiaUI-samples)**

Or follow the step-by-step **[Dashboard Tutorial](docs/guides/tutorial-dashboard.md)** to build one from scratch.

---

## Quick Start

### 1. Install

Add to `mix.exs`:

```elixir
def deps do
  [
    {:phia_ui, "~> 0.1.2"}
  ]
end
```

Run:

```bash
mix deps.get
mix phia.install
```

### 2. Add the theme

In `assets/css/app.css`:

```css
@import "tailwindcss";
@import "../../../deps/phia_ui/priv/static/theme.css";
```

For runtime color theme switching (optional), generate the multi-theme CSS:

```bash
mix phia.theme install
```

This creates `assets/css/phia-themes.css` and auto-imports it in `app.css`. Then set `data-phia-theme="blue"` on any ancestor element to activate that theme.

### 3. Eject components

```bash
mix phia.add button card badge dialog
```

### 4. Register hooks

```javascript
// assets/js/app.js
import PhiaDialog          from "./phia_hooks/dialog"
import PhiaDropdownMenu    from "./phia_hooks/dropdown_menu"
import PhiaTagsInput       from "./phia_hooks/tags_input"
import PhiaRichTextEditor  from "./phia_hooks/rich_text_editor"
import PhiaTooltip         from "./phia_hooks/tooltip"
import PhiaPopover         from "./phia_hooks/popover"
import PhiaToast           from "./phia_hooks/toast"
import PhiaDarkMode        from "./phia_hooks/dark_mode"
import PhiaCommand         from "./phia_hooks/command"
import PhiaDateRangePicker from "./phia_hooks/date_range_picker"
import PhiaChart           from "./phia_hooks/chart"
import PhiaCalendar        from "./phia_hooks/calendar"
import PhiaCarousel        from "./phia_hooks/carousel"
import PhiaContextMenu     from "./phia_hooks/context_menu"
import PhiaDrawer          from "./phia_hooks/drawer"
import PhiaTheme           from "./phia_hooks/theme"

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: {
    PhiaDialog, PhiaDropdownMenu, PhiaTagsInput, PhiaRichTextEditor,
    PhiaTooltip, PhiaPopover, PhiaToast, PhiaDarkMode,
    PhiaCommand, PhiaDateRangePicker, PhiaChart,
    PhiaCalendar, PhiaCarousel, PhiaContextMenu, PhiaDrawer,
    PhiaTheme
  }
})
```

> Hook files are copied to `assets/js/phia_hooks/` by `mix phia.install`.

---

## Usage Examples

### Button & Button Group

```heex
<.button>Default</.button>
<.button variant="destructive">Delete</.button>
<.button variant="outline" size="sm"><.icon name="download" size="sm" /> Export</.button>

<%!-- Button Group toolbar --%>
<.button_group>
  <.button variant="outline" size="icon"><.icon name="bold" size="sm" /></.button>
  <.button variant="outline" size="icon"><.icon name="italic" size="sm" /></.button>
  <.button variant="outline" size="icon"><.icon name="underline" size="sm" /></.button>
</.button_group>
```

→ [Button examples](docs/components/primitives.md#button) | [Button Group examples](docs/components/utilities.md#button-group)

### Form with Checkbox

```heex
<.form for={@form} phx-change="validate" phx-submit="save">
  <.phia_input field={@form[:email]} type="email" label="Email" />
  <.field>
    <div class="flex items-center gap-2">
      <.checkbox id="terms" name="terms" checked={@terms_checked} phx-click="toggle-terms" />
      <.field_label for="terms">I agree to the Terms of Service</.field_label>
    </div>
    <.field_message error={@terms_error} />
  </.field>
  <.button type="submit">Register</.button>
</.form>
```

→ [Form examples](docs/components/forms.md) | [Checkbox examples](docs/components/forms.md#checkbox)

### Alert Dialog (confirmation)

```heex
<.alert_dialog id="delete-confirm" open={@show_confirm}>
  <.alert_dialog_header>
    <.alert_dialog_title>Delete item?</.alert_dialog_title>
    <.alert_dialog_description>
      This action cannot be undone.
    </.alert_dialog_description>
  </.alert_dialog_header>
  <.alert_dialog_footer>
    <.alert_dialog_cancel phx-click="cancel">Cancel</.alert_dialog_cancel>
    <.alert_dialog_action variant="destructive" phx-click="confirm-delete">
      Delete
    </.alert_dialog_action>
  </.alert_dialog_footer>
</.alert_dialog>
```

→ [Alert Dialog examples](docs/components/interactive.md#alert-dialog)

### Drawer (side panel / bottom sheet)

```heex
<.drawer_content id="filters-panel" open={@filters_open} direction="right">
  <.drawer_header>
    <h2 class="text-lg font-semibold">Filters</h2>
  </.drawer_header>
  <.drawer_close />
  <div class="px-6 pb-6">
    <!-- filter controls -->
  </div>
  <.drawer_footer>
    <.button phx-click="apply-filters">Apply</.button>
  </.drawer_footer>
</.drawer_content>
```

→ [Drawer examples](docs/components/interactive.md#drawer)

### Avatar with group

```heex
<.avatar_group>
  <.avatar :for={user <- @team_members}>
    <.avatar_image src={user.avatar_url} alt={user.name} />
    <.avatar_fallback name={user.name} />
  </.avatar>
</.avatar_group>
```

→ [Avatar examples](docs/components/utilities.md#avatar)

### Carousel

```heex
<.carousel id="hero" loop={true} class="w-full">
  <.carousel_content>
    <.carousel_item :for={slide <- @slides}>
      <img src={slide.image} alt={slide.title} class="w-full h-64 object-cover rounded-lg" />
    </.carousel_item>
  </.carousel_content>
  <.carousel_previous />
  <.carousel_next />
</.carousel>
```

→ [Carousel examples](docs/components/interactive.md#carousel)

### Empty State

```heex
<.empty>
  <:icon><.icon name="inbox" size="lg" class="text-muted-foreground" /></:icon>
  <:title>No invoices found</:title>
  <:description>Create your first invoice to get started.</:description>
  <:action><.button phx-click="new-invoice">Create Invoice</.button></:action>
</.empty>
```

→ [Empty State examples](docs/components/utilities.md#empty-state)

### Toast notification

```heex
<%!-- Mount once in root.html.heex --%>
<.toast id="toast-viewport" />
```

```elixir
# Trigger from any LiveView
{:noreply, push_event(socket, "phia-toast", %{
  title: "Saved", description: "Changes saved.", variant: "success"
})}
```

→ [Toast examples](docs/components/interactive.md#toast)

### Dashboard with charts

```heex
<.metric_grid cols={4}>
  <.stat_card title="MRR" value="$48,290" trend="up" trend_value="+12.5%" />
  <.stat_card title="Users" value="2,840" trend="up" trend_value="+8.2%" />
  <.stat_card title="Churn" value="3.1%" trend="down" trend_value="-0.4%" />
  <.stat_card title="NPS" value="67" trend="neutral" trend_value="0" />
</.metric_grid>

<.phia_chart
  id="revenue-chart"
  type={:area}
  title="Monthly Revenue"
  series={[%{name: "MRR", data: @mrr_data}]}
  labels={@month_labels}
  height="320px"
/>
```

→ [Dashboard examples](docs/components/dashboard.md) | [Full tutorial](docs/guides/tutorial-dashboard.md)

---

## Mix Tasks

```bash
# Install core dependencies and setup
mix phia.install

# List all available components
mix phia.list

# Eject specific components into your codebase
mix phia.add button card badge dialog

# Generate the Lucide SVG sprite
mix phia.icons

# Theme management
mix phia.theme list                    # list all 8 color presets
mix phia.theme install                 # generate assets/css/phia-themes.css
mix phia.theme apply zinc              # write theme vars to your theme.css
mix phia.theme export blue             # print JSON (or --format css for CSS)
mix phia.theme import ./my-brand.json  # apply custom theme
```

---

## Ejectable Architecture

PhiaUI is not a traditional runtime dependency — components are **source code you own**:

```bash
mix phia.add button card dialog toast command carousel drawer
```

This copies Elixir modules and JS hooks directly into your project. After ejection, **you own the code**: read it, modify it, delete parts you don't need.

```
lib/your_app_web/components/ui/button.ex      ← yours to edit
assets/js/phia_hooks/dialog.js                ← yours to edit
assets/js/phia_hooks/carousel.js              ← yours to edit
```

---

## ClassMerger

The `cn/1` function merges Tailwind classes with conflict resolution (last wins per group):

```elixir
import PhiaUi.ClassMerger, only: [cn: 1]

cn(["px-4 py-2", @class])           # => "px-4 py-2 mt-4" (if @class = "mt-4")
cn(["px-4", "px-8"])                # => "px-8"  (conflict resolved)
cn(["text-red-500", @error && "text-destructive", nil])  # nil filtered out
```

Backed by an ETS-cached GenServer (`ClassMerger.Cache`) — zero overhead on repeated calls.

---

## TailwindCSS v4 Theme

The theme provides semantic OKLCH design tokens. Always use tokens, never hardcoded colors:

```css
/* ✓ Use semantic tokens */
bg-primary text-muted-foreground border-border bg-accent

/* ✗ Never hardcode */
bg-gray-900 text-[#333]
```

Dark mode support via `@custom-variant dark (&:where(.dark, .dark *))` — toggle the `.dark` class on `<html>` with `PhiaDarkMode`.

### Color presets & runtime theme switching

PhiaUI ships 8 OKLCH color presets: `zinc`, `slate`, `blue`, `rose`, `orange`, `green`, `violet`, `neutral`.

Generate the multi-theme CSS file:

```bash
mix phia.theme install
# → writes assets/css/phia-themes.css with all 8 [data-phia-theme] selectors
# → injects @import into app.css automatically
```

Activate a preset at the HTML level:

```html
<html class="dark" data-phia-theme="blue">
```

Scoped per section via ThemeProvider:

```heex
<.theme_provider theme={:blue}>
  <.button>Blue button</.button>
</.theme_provider>
```

Runtime switching via the PhiaTheme hook:

```heex
<select phx-hook="PhiaTheme" id="color-picker">
  <option value="zinc">Zinc</option>
  <option value="blue">Blue</option>
  <option value="rose">Rose</option>
</select>
```

**Anti-FOUC** — add to `<head>` before any stylesheet:

```html
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
```

---

## Use Cases

- **Financial terminals** — StatCard + MetricGrid + PhiaChart for live P&L, position tracking, risk dashboards
- **BI dashboards** — ChartShell + PhiaChart wrapping ECharts with consistent card chrome and real-time push_event updates
- **SaaS admin panels** — Shell + Sidebar + DataGrid + Dialog + Toast for full CRUD interfaces
- **KPI monitors** — Metric grids with real-time trend indicators and Ctrl+K command palette
- **Booking and scheduling** — DatePicker + DateRangePicker for reservation flows with min/max constraints
- **Internal tools** — Form components with Ecto changeset integration and rich text content editing
- **Mobile-first apps** — Drawer (bottom sheet) + Carousel for mobile UX patterns
- **Multilingual apps** — Direction wrapper for RTL content (Arabic, Hebrew)

---

## Documentation

Detailed examples and use cases:

| Section | Contents |
|---------|----------|
| [Primitives & Feedback](docs/components/primitives.md) | Button, Card, Badge, Icon, Alert, Skeleton, Breadcrumb, Pagination |
| [Form Integration](docs/components/forms.md) | Input, Textarea, Select, Checkbox, Calendar, Tags Input, Image Upload, Rich Text Editor |
| [Interactive Components](docs/components/interactive.md) | Dialog, Dropdown, Accordion, Tooltip, Popover, Toast, Command, DateRangePicker, Collapsible, AlertDialog, Carousel, ContextMenu, Drawer, Combobox, DatePicker |
| [Utilities & Composed](docs/components/utilities.md) | Aspect Ratio, Direction, Empty State, Field, Button Group, Avatar, Tabs Nav, Theme Provider |
| [Theme System](docs/guides/theme-system.md) | CSS-first themes, color presets, runtime switching, ThemeProvider, PhiaTheme hook |
| [Dashboard & Analytics](docs/components/dashboard.md) | Shell, Dark Mode, Table, DataGrid, StatCard, Charts |
| [Tutorial: Build a Dashboard](docs/guides/tutorial-dashboard.md) | Step-by-step guide: shell, KPIs, charts, tables, command palette |

Generate API docs locally:

```bash
mix docs
```

---

## Contributing

We value **Clarity**, **Simplicity**, and **Testability**.

- All features require a specification with acceptance criteria before implementation
- TDD: write failing tests first (red → green)
- No Alpine.js, no npm deps for interactivity — vanilla JS hooks only
- `cn/1` implemented natively — no tw_merge or similar
- All interactive components require WAI-ARIA roles, states, and keyboard support
- All code passes `mix credo --strict` without warnings
