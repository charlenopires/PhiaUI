# PhiaUI

**Enterprise-ready Phoenix LiveView component library — 75 components, inspired by shadcn/ui.**

Ejectable components with zero heavy JS dependencies, full WAI-ARIA accessibility, TailwindCSS v4 semantic tokens, and built-in analytics widgets, enterprise data components, and AI-ready chat UI for financial terminals, BI dashboards, and KPI monitors.

[![Hex.pm](https://img.shields.io/hexpm/v/phia_ui.svg)](https://hex.pm/packages/phia_ui)
[![Elixir](https://img.shields.io/badge/elixir-%3E%3D1.17-purple)](https://elixir-lang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## Why PhiaUI?

| Feature | PhiaUI | salad_ui |
|---------|--------|----------|
| Ejectable architecture | ✓ | Partial |
| Enterprise analytics widgets | ✓ | ✗ |
| AI / chat components | ✓ | ✗ |
| Kanban, filter builder, activity feed | ✓ | ✗ |
| Zero npm deps for interactivity | ✓ | ✗ |
| Native ClassMerger (no tw_merge) | ✓ | ✗ |
| TailwindCSS v4 theme system | ✓ | ✗ |
| CSS-first theme system (8 presets, runtime switching) | ✓ | ✗ |
| WAI-ARIA on all interactive | ✓ | Partial |
| Dark mode, Ctrl+K, Date Pickers, Carousels | ✓ | ✗ |

---

## Component Library — 75 Components

### Primitives & Feedback — 9 components

Stateless HEEx components. No JavaScript. → [Full examples & use cases](docs/components/primitives.md)

| Component | Function | Description |
|-----------|----------|-------------|
| Button | `button/1` | 6 variants × 4 sizes, disabled state |
| Card | `card/1` | Composable header / content / footer slots |
| Badge | `badge/1` | 4 variants for status labels |
| Icon | `icon/1` | Lucide SVG sprite, 4 sizes (`xs`, `sm`, `md`, `lg`) |
| Alert | `alert/1` | 2 variants with title and description sub-components |
| Skeleton | `skeleton/1` | `animate-pulse` placeholders for loading states |
| Breadcrumb | `breadcrumb/1` | 7 sub-components, `aria-current="page"` |
| Pagination | `pagination/1` | Server-side pagination with `phx-click` |
| Kbd | `kbd/1` | Semantic `<kbd>` keyboard shortcut display |

### Form Integration — 12 components

Integrated with `Phoenix.HTML.Form` and Ecto changesets. → [Full examples & use cases](docs/components/forms.md)

| Component | Function | Description |
|-----------|----------|-------------|
| Input | `phia_input/1` | Label + input + description + errors |
| Textarea | `phia_textarea/1` | Multi-line with form integration |
| Select | `phia_select/1` | Native select with FormField |
| Form | `form_field/1`, `form_label/1`, `form_message/1` | Composable form primitives |
| Checkbox | `checkbox/1`, `form_checkbox/1` | Native checkbox, indeterminate state, FormField |
| Radio Group | `radio_group/1`, `form_radio_group/1` | Native radio inputs, `:let` context |
| Switch | `switch/1`, `form_switch/1` | Toggle switch, CSS animation, FormField |
| Slider | `slider/1`, `form_slider/1` | CSS `input[type=range]`, WAI-ARIA, FormField |
| Rating | `rating/1`, `form_rating/1` | CSS-only star rating, radiogroup ARIA |
| Tags Input | `tags_input/1` | Multi-tag, deduplication, CSV sync — `PhiaTagsInput` |
| Image Upload | `image_upload/1` | Drop zone + preview, native Phoenix uploads |
| Rich Text Editor | `rich_text_editor/1` | WYSIWYG, 14 toolbar commands, zero npm — `PhiaRichTextEditor` |
| Calendar | `calendar/1` | Server-rendered monthly grid, single/range mode, keyboard nav |

### Interactive Components — 17 components

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
| Sheet | `sheet/1` | `PhiaDialog` | 4 sides, 5 sizes, modal panel |
| Hover Card | `hover_card/1` | — | `role="tooltip"`, hover preview card |

### Utilities & Composed — 16 components

CSS-only utilities, display patterns, and data viz primitives. → [Full examples & use cases](docs/components/utilities.md)

| Component | Function | Description |
|-----------|----------|-------------|
| Aspect Ratio | `aspect_ratio/1` | CSS padding-top trick, any ratio (16:9, 4:3, 1:1…) |
| Direction | `direction/1` | LTR/RTL wrapper for multilingual content |
| Empty State | `empty/1` | Centered placeholder with icon/title/description/action slots |
| Field | `field/1` | Standalone form field layout without FormField |
| Button Group | `button_group/1` | Unified button toolbar, H/V orientation |
| Avatar | `avatar/1` | Circular profile image with initials fallback, `avatar_group/1` |
| Tabs Nav | `tabs_nav/1` | Navigation tabs: underline, pills, segment variants |
| Theme Provider | `theme_provider/1` | Scoped CSS theme wrapper using `data-phia-theme` attribute |
| Scroll Area | `scroll_area/1` | Custom scrollbar overlay, H/V/both orientations |
| Progress | `progress/1` | `role="progressbar"`, `aria-valuenow`, indeterminate mode |
| Separator | `separator/1` | Horizontal / vertical divider, `role="separator"` |
| Toggle | `toggle/1` | `aria-pressed`, 2 variants, 3 sizes |
| Toggle Group | `toggle_group/1` | Single / multiple selection, `:let` context |
| Tabs | `tabs/1` | `tabs/list/trigger/content`, server-rendered, `:let` context |
| Timeline | `timeline/1` | Vertical activity timeline, CSS-only connector |
| Resizable | `resizable/1` | Drag-to-resize panels — `PhiaResizable` |

### Dashboard & Analytics — 9 components

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
| Heatmap Calendar | `heatmap_calendar/1` | Contribution grid, intensity buckets, WAI-ARIA grid |

### Enterprise Components — 10 components

Advanced data management and collaboration UI. → [Full examples & use cases](docs/components/enterprise.md)

| Component | Function | Description |
|-----------|----------|-------------|
| Activity Feed | `activity_feed/1` | Chronological event log with 6 activity types and avatar slot |
| Kanban Board | `kanban_board/1` | Drag-ready column + card layout with priority indicators |
| Chat Message | `chat_message/1` | Full AI/human chat UI: container, bubbles, suggestions, input |
| Mention Input | `mention_input/1` | `@mention` textarea with server-side autocomplete — `PhiaMentionInput` |
| Filter Bar | `filter_bar/1` | Horizontal filter toolbar: search, select, toggle, reset |
| Filter Builder | `filter_builder/1` | Dynamic query builder with field/operator/value rules |
| Bulk Action Bar | `bulk_action_bar/1` | Contextual toolbar for table row selection |
| Step Tracker | `step_tracker/1` | Multi-step wizard progress (horizontal/vertical) |
| Navigation Menu | `navigation_menu/1` | Horizontal nav with links and dropdown content panels |

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
    {:phia_ui, "~> 0.1.3"}
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
import PhiaResizable       from "./phia_hooks/resizable"
import PhiaMentionInput    from "./phia_hooks/mention_input"

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: {
    PhiaDialog, PhiaDropdownMenu, PhiaTagsInput, PhiaRichTextEditor,
    PhiaTooltip, PhiaPopover, PhiaToast, PhiaDarkMode,
    PhiaCommand, PhiaDateRangePicker, PhiaChart,
    PhiaCalendar, PhiaCarousel, PhiaContextMenu, PhiaDrawer,
    PhiaTheme, PhiaResizable, PhiaMentionInput
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
<.button variant="outline" size="sm"><.icon name="download" size={:sm} /> Export</.button>

<%!-- Button Group toolbar --%>
<.button_group>
  <.button variant="outline" size="icon"><.icon name="bold" size={:sm} /></.button>
  <.button variant="outline" size="icon"><.icon name="italic" size={:sm} /></.button>
  <.button variant="outline" size="icon"><.icon name="underline" size={:sm} /></.button>
</.button_group>
```

→ [Button examples](docs/components/primitives.md#button) | [Button Group examples](docs/components/utilities.md#button-group)

### Form with Validation

```heex
<.form for={@form} phx-change="validate" phx-submit="save">
  <.phia_input field={@form[:email]} type="email" label="Email" phx-debounce="blur" />
  <.phia_input field={@form[:name]} label="Name" />
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

→ [Form examples](docs/components/forms.md)

### Tabs

```heex
<.tabs active="overview">
  <:tab_list>
    <.tabs_trigger tab="overview">Overview</.tabs_trigger>
    <.tabs_trigger tab="analytics">Analytics</.tabs_trigger>
    <.tabs_trigger tab="settings">Settings</.tabs_trigger>
  </:tab_list>
  <.tabs_content tab="overview">
    <p>Overview content here</p>
  </.tabs_content>
  <.tabs_content tab="analytics">
    <p>Analytics content here</p>
  </.tabs_content>
</.tabs>
```

### Step Tracker / Wizard

```heex
<.step_tracker>
  <.step status="complete" label="Account" step={1} />
  <.step status="active"   label="Profile"  step={2} description="Fill in your details" />
  <.step status="upcoming" label="Confirm"  step={3} />
</.step_tracker>
```

→ [Step Tracker examples](docs/components/enterprise.md#step-tracker)

### Navigation Menu

```heex
<.navigation_menu>
  <.navigation_menu_list>
    <.navigation_menu_item>
      <.navigation_menu_link href="/" active={@path == "/"}>Home</.navigation_menu_link>
    </.navigation_menu_item>
    <.navigation_menu_item>
      <.navigation_menu_trigger label="Products" />
      <.navigation_menu_content>
        <ul class="grid grid-cols-2 gap-2 p-4">
          <li><a href="/products/web">Web</a></li>
          <li><a href="/products/mobile">Mobile</a></li>
        </ul>
      </.navigation_menu_content>
    </.navigation_menu_item>
  </.navigation_menu_list>
</.navigation_menu>
```

→ [Navigation Menu examples](docs/components/enterprise.md#navigation-menu)

### Filter Bar + Filter Builder

```heex
<%!-- Simple filter bar for a table --%>
<.filter_bar>
  <.filter_search placeholder="Search users…" on_search="search_users" />
  <.filter_select label="Status" name="status"
    options={[{"All", ""}, {"Active", "active"}, {"Inactive", "inactive"}]}
    value={@filter_status} on_change="filter_status" />
  <.filter_toggle label="Archived" name="archived"
    checked={@show_archived} on_change="toggle_archived" />
  <.filter_reset on_click="reset_filters" />
</.filter_bar>

<%!-- Advanced query builder --%>
<.filter_builder
  fields={[
    %{name: "status", label: "Status", type: "select",
      options: [{"Active", "active"}, {"Inactive", "inactive"}]},
    %{name: "name",       label: "Name",       type: "text"},
    %{name: "created_at", label: "Created At", type: "date"}
  ]}
  rules={@filter_rules}
  on_add="add_filter_rule"
  on_remove="remove_filter_rule"
  on_change="update_filter_rule"
/>
```

→ [Filter Bar examples](docs/components/enterprise.md#filter-bar) | [Filter Builder examples](docs/components/enterprise.md#filter-builder)

### Bulk Action Bar

```heex
<.bulk_action_bar count={@selected_count} label="items selected" on_clear="clear_selection">
  <.bulk_action label="Delete"  on_click="bulk_delete"  variant="destructive" icon="trash" />
  <.bulk_action label="Archive" on_click="bulk_archive" icon="archive" />
  <.bulk_action label="Export"  on_click="bulk_export"  icon="download" />
</.bulk_action_bar>
```

→ [Bulk Action Bar examples](docs/components/enterprise.md#bulk-action-bar)

### Activity Feed

```heex
<.activity_feed>
  <.activity_group label="Today">
    <.activity_item
      type="mention"
      name="Alice Martin"
      description="mentioned you in Project Alpha"
      timestamp="2m ago"
    >
      <:avatar><.avatar><.avatar_fallback name="Alice Martin" /></.avatar></:avatar>
    </.activity_item>
    <.activity_item
      type="task"
      name="Bob Chen"
      description="completed task: Deploy to staging"
      timestamp="15m ago"
    />
  </.activity_group>
  <:footer>
    <.button variant="ghost" size="sm" phx-click="load_more">Load more</.button>
  </:footer>
</.activity_feed>
```

→ [Activity Feed examples](docs/components/enterprise.md#activity-feed)

### Kanban Board

```heex
<.kanban_board>
  <.kanban_column label="To Do" count={3}>
    <.kanban_card id="card-1" title="Design review" priority="high">
      <:tags><.badge variant="secondary">Design</.badge></:tags>
    </.kanban_card>
  </.kanban_column>
  <.kanban_column label="In Progress" count={1}>
    <.kanban_card id="card-2" title="API integration" priority="critical">
      <:avatar><.avatar size="sm"><.avatar_fallback name="Dev Team" /></.avatar></:avatar>
    </.kanban_card>
  </.kanban_column>
  <.kanban_column label="Done" count={5} />
</.kanban_board>
```

→ [Kanban Board examples](docs/components/enterprise.md#kanban-board)

### Chat (AI/Human UI)

```heex
<.chat_container id="ai-chat">
  <.chat_message role="assistant" id="msg-0">
    <.chat_bubble role="assistant" timestamp="2:30 PM">
      <:avatar><.avatar size="sm"><.avatar_fallback name="AI" /></.avatar></:avatar>
      Welcome! How can I help you today?
    </.chat_bubble>
    <.chat_suggestions
      suggestions={["What are key features?", "Show me an example"]}
      on_select="select_suggestion"
    />
  </.chat_message>
  <.chat_message role="user" id="msg-1">
    <.chat_bubble role="user" timestamp="2:31 PM">
      What are key features?
    </.chat_bubble>
  </.chat_message>
</.chat_container>

<.chat_input id="chat-compose" on_submit="send_message" placeholder="Ask anything…" />
```

→ [Chat examples](docs/components/enterprise.md#chat-message)

### Mention Input

```heex
<.mention_input
  id="comment-field"
  name="comment"
  suggestions={@mention_suggestions}
  open={@mention_open}
  search={@mention_search}
  mentioned_ids={@mentioned_ids}
  on_mention="mention_search"
  on_select="mention_select"
  placeholder="Leave a comment… type @ to mention"
/>
```

```elixir
def handle_event("mention_search", %{"query" => q}, socket) do
  suggestions = filter_users(q)
  {:noreply, assign(socket, mention_suggestions: suggestions, mention_open: true)}
end
```

→ [Mention Input examples](docs/components/enterprise.md#mention-input)

### Alert Dialog (confirmation)

```heex
<.alert_dialog id="delete-confirm" open={@show_confirm}>
  <.alert_dialog_header>
    <.alert_dialog_title>Delete item?</.alert_dialog_title>
    <.alert_dialog_description>This action cannot be undone.</.alert_dialog_description>
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
    <.filter_builder fields={@fields} rules={@rules}
      on_add="add_rule" on_remove="remove_rule" on_change="update_rule" />
  </div>
  <.drawer_footer>
    <.button phx-click="apply-filters">Apply</.button>
  </.drawer_footer>
</.drawer_content>
```

→ [Drawer examples](docs/components/interactive.md#drawer)

### Progress & Slider

```heex
<%!-- Progress bar --%>
<.progress value={75} max={100} aria-label="Upload progress" />

<%!-- Range slider (form-integrated) --%>
<.form_slider field={@form[:volume]} label="Volume" min={0} max={100} step={1} />
```

### Timeline

```heex
<.timeline>
  <.timeline_item status="complete">
    <:icon><.icon name="check-circle" size={:sm} /></:icon>
    <:content>
      <p class="font-medium">Order placed</p>
      <p class="text-sm text-muted-foreground">March 1 at 10:00 AM</p>
    </:content>
  </.timeline_item>
  <.timeline_item status="active">
    <:icon><.icon name="package" size={:sm} /></:icon>
    <:content>
      <p class="font-medium">In transit</p>
      <p class="text-sm text-muted-foreground">Estimated: March 5</p>
    </:content>
  </.timeline_item>
  <.timeline_item status="upcoming">
    <:icon><.icon name="home" size={:sm} /></:icon>
    <:content>
      <p class="font-medium text-muted-foreground">Delivered</p>
    </:content>
  </.timeline_item>
</.timeline>
```

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
  <.stat_card title="MRR"   value="$48,290" trend="up"      trend_value="+12.5%" />
  <.stat_card title="Users" value="2,840"   trend="up"      trend_value="+8.2%" />
  <.stat_card title="Churn" value="3.1%"    trend="down"    trend_value="-0.4%" />
  <.stat_card title="NPS"   value="67"      trend="neutral" trend_value="0" />
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

### Heatmap Calendar

```heex
<.heatmap_calendar
  data={@contribution_data}
  rows={7}
  cols={52}
  max_value={10}
  col_labels={@week_labels}
  row_labels={~w(Mon Tue Wed Thu Fri Sat Sun)}
  show_legend={true}
/>
```

→ [Heatmap Calendar examples](docs/components/enterprise.md#heatmap-calendar)

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

→ [Full theme guide](docs/guides/theme-system.md)

---

## Use Cases

- **Financial terminals** — StatCard + MetricGrid + PhiaChart for live P&L, position tracking, risk dashboards
- **BI dashboards** — ChartShell + PhiaChart wrapping ECharts with consistent card chrome and real-time push_event updates
- **SaaS admin panels** — Shell + Sidebar + DataGrid + Dialog + Toast for full CRUD interfaces
- **KPI monitors** — Metric grids with real-time trend indicators and Ctrl+K command palette
- **Project management** — KanbanBoard + ActivityFeed + BulkActionBar + StepTracker for work tracking
- **Data exploration** — FilterBar + FilterBuilder + DataGrid for ad-hoc query interfaces
- **Team collaboration** — MentionInput + ChatMessage for AI-augmented comment threads
- **Booking and scheduling** — DatePicker + DateRangePicker + HeatmapCalendar for reservation flows
- **Internal tools** — Form components with Ecto changeset integration and rich text content editing
- **Mobile-first apps** — Drawer (bottom sheet) + Carousel for mobile UX patterns
- **Multilingual apps** — Direction wrapper for RTL content (Arabic, Hebrew)

---

## Documentation

Detailed examples and use cases:

| Section | Contents |
|---------|----------|
| [Primitives & Feedback](docs/components/primitives.md) | Button, Card, Badge, Icon, Alert, Skeleton, Breadcrumb, Pagination, Kbd |
| [Form Integration](docs/components/forms.md) | Input, Textarea, Select, Checkbox, Switch, Slider, Rating, Calendar, Tags Input, Image Upload, Rich Text Editor |
| [Interactive Components](docs/components/interactive.md) | Dialog, Dropdown, Accordion, Tooltip, Popover, Toast, Command, DateRangePicker, Collapsible, AlertDialog, Carousel, ContextMenu, Drawer, Combobox, DatePicker, Sheet, HoverCard |
| [Utilities & Composed](docs/components/utilities.md) | Aspect Ratio, Direction, Empty State, Field, Button Group, Avatar, Tabs Nav, Theme Provider, Scroll Area, Progress, Separator, Toggle, Tabs, Timeline, Resizable |
| [Dashboard & Analytics](docs/components/dashboard.md) | Shell, Dark Mode, Table, DataGrid, StatCard, Charts, HeatmapCalendar |
| [Enterprise Components](docs/components/enterprise.md) | ActivityFeed, KanbanBoard, ChatMessage, MentionInput, FilterBar, FilterBuilder, BulkActionBar, StepTracker, NavigationMenu |
| [Theme System](docs/guides/theme-system.md) | CSS-first themes, color presets, runtime switching, ThemeProvider, PhiaTheme hook |
| [Tutorial: Build a Dashboard](docs/guides/tutorial-dashboard.md) | Step-by-step guide: shell, KPIs, charts, tables, command palette, enterprise widgets |

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
