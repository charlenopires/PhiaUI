# PhiaUI

**Enterprise-ready Phoenix LiveView component library — 31 components, inspired by shadcn/ui.**

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
| WAI-ARIA on all interactive | ✓ | Partial |
| Dark mode, Ctrl+K search, Date Range | ✓ | ✗ |

---

## Component Library — 31 Components

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

### Form Integration — 7 components

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

### Interactive Components — 8 components

Vanilla JS hooks for accessible behaviors: focus trapping, keyboard navigation, smart positioning. → [Full examples & use cases](docs/components/interactive.md)

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

## Quick Start

### 1. Install

Add to `mix.exs`:

```elixir
def deps do
  [
    {:phia_ui, "~> 0.1.0"}
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

### 3. Eject components

```bash
mix phia.add button card badge dialog
```

### 4. Register hooks

```javascript
// assets/js/app.js
import PhiaDialog        from "./phia_hooks/dialog"
import PhiaDropdownMenu  from "./phia_hooks/dropdown_menu"
import PhiaTagsInput     from "./phia_hooks/tags_input"
import PhiaRichTextEditor from "./phia_hooks/rich_text_editor"
import PhiaTooltip       from "./phia_hooks/tooltip"
import PhiaPopover       from "./phia_hooks/popover"
import PhiaToast         from "./phia_hooks/toast"
import PhiaDarkMode      from "./phia_hooks/dark_mode"
import PhiaCommand       from "./phia_hooks/command"
import PhiaDateRangePicker from "./phia_hooks/date_range_picker"
import PhiaChart         from "./phia_hooks/chart"

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: {
    PhiaDialog, PhiaDropdownMenu, PhiaTagsInput, PhiaRichTextEditor,
    PhiaTooltip, PhiaPopover, PhiaToast, PhiaDarkMode,
    PhiaCommand, PhiaDateRangePicker, PhiaChart
  }
})
```

> Hook files are copied to `assets/js/phia_hooks/` by `mix phia.install`.

---

## Usage Examples

### Button

```heex
<.button>Default</.button>
<.button variant="destructive">Delete</.button>
<.button variant="outline" size="sm"><.icon name="download" size="sm" /> Export</.button>
<.button variant="ghost" disabled>Disabled</.button>
```

→ [Button examples](docs/components/primitives.md#button)

### Alert

```heex
<.alert variant="destructive">
  <:icon><.icon name="alert-circle" /></:icon>
  <.alert_title>Payment failed</.alert_title>
  <.alert_description>Your card was declined. Please update your billing details.</.alert_description>
</.alert>
```

→ [Alert examples](docs/components/primitives.md#alert)

### Form

```heex
<.form for={@form} phx-change="validate" phx-submit="save">
  <.phia_input field={@form[:email]} type="email" label="Email" />
  <.phia_input field={@form[:name]} label="Full name" />
  <.phia_select field={@form[:role]} options={["admin", "editor", "viewer"]} label="Role" />
  <.button type="submit">Save</.button>
</.form>
```

→ [Form examples](docs/components/forms.md)

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

### Command Menu (Ctrl+K)

```heex
<.command id="cmd">
  <.command_input id="cmd-input" on_change="search" placeholder="Search…" />
  <.command_list id="cmd-results">
    <.command_empty>No results.</.command_empty>
    <.command_group label="Navigation">
      <.command_item on_click="go" value="/dashboard">Dashboard</.command_item>
    </.command_group>
  </.command_list>
</.command>
```

→ [Command Menu examples](docs/components/interactive.md#command-menu-ctrlk)

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

→ [Dashboard examples](docs/components/dashboard.md)

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
```

---

## Ejectable Architecture

PhiaUI is not a traditional runtime dependency — components are **source code you own**:

```bash
mix phia.add button card dialog toast command
```

This copies Elixir modules and JS hooks directly into your project. After ejection, **you own the code**: read it, modify it, delete parts you don't need. PhiaUI has no opinion on your code after the copy.

```
lib/your_app_web/components/ui/button.ex      ← yours to edit
assets/js/phia_hooks/dialog.js                ← yours to edit
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

---

## Use Cases

- **Financial terminals** — StatCard + MetricGrid + PhiaChart for live P&L, position tracking, risk dashboards
- **BI dashboards** — ChartShell + PhiaChart wrapping ECharts with consistent card chrome and real-time push_event updates
- **SaaS admin panels** — Shell + Sidebar + DataGrid + Dialog + Toast for full CRUD interfaces
- **KPI monitors** — Metric grids with real-time trend indicators and Ctrl+K command palette
- **Booking and scheduling** — DateRangePicker for reservation flows with min/max constraints
- **Internal tools** — Form components with Ecto changeset integration and rich text content editing

---

## Documentation

Detailed examples and use cases:

| Section | Contents |
|---------|----------|
| [Primitives & Feedback](docs/components/primitives.md) | Button, Card, Badge, Icon, Alert, Skeleton, Breadcrumb, Pagination |
| [Form Integration](docs/components/forms.md) | Input, Textarea, Select, Tags Input, Image Upload, Rich Text Editor |
| [Interactive Components](docs/components/interactive.md) | Dialog, Dropdown, Accordion, Tooltip, Popover, Toast, Command, DateRangePicker |
| [Dashboard & Analytics](docs/components/dashboard.md) | Shell, Dark Mode, Table, DataGrid, StatCard, Charts |

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
