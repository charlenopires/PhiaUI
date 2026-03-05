# PhiaUI

**Enterprise-ready Phoenix LiveView component library — 119 components, inspired by shadcn/ui.**

Ejectable components with zero heavy JS dependencies, full WAI-ARIA accessibility, TailwindCSS v4 semantic tokens, and built-in analytics widgets, enterprise data components, full Calendar & Scheduling Suite, and AI-ready chat UI for financial terminals, BI dashboards, booking platforms, and KPI monitors.

[![Hex.pm](https://img.shields.io/hexpm/v/phia_ui.svg)](https://hex.pm/packages/phia_ui)
[![Elixir](https://img.shields.io/badge/elixir-%3E%3D1.17-purple)](https://elixir-lang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## Why PhiaUI?

| Feature | **PhiaUI** | [DaisyUI](https://github.com/saadeghi/daisyui) | [Salad UI](https://github.com/bluzky/salad_ui) | [ShadCN/ui](https://github.com/shadcn-ui/ui) | [Doggo](https://github.com/woylie/doggo) | [Mishka Chelekom](https://github.com/mishka-group/mishka_chelekom) | [Primer Live](https://github.com/ArthurClemens/primer_live) |
|---------|:----------:|:-------:|:--------:|:---------:|:-----:|:---------------:|:-----------:|
| **Platform** | Phoenix LiveView | CSS / Any | Phoenix LiveView | React | Phoenix LiveView | Phoenix LiveView | Phoenix LiveView |
| **Components** | **119** | 40+ | ~30 | 50+ | 40+ | ~90 | ~40 |
| Copy-paste ownership | ✓ | ✗ | ✓ | ✓ | ✓ | ✓ | ✗ |
| LiveView-native (`phx-*`, streams) | ✓ | ✗ | ✓ | ✗ | ✓ | ✓ | ✓ |
| Zero npm runtime deps | ✓ | ✓ | Partial | ✗ | ✓ | ✓ | Partial |
| Full WAI-ARIA on all interactive | ✓ | Partial | Partial | ✓ | ✓ | Partial | Partial |
| Tailwind CSS v4 | ✓ | ✓ | Partial | Partial | ✗ | ✓ | ✗ |
| Dark mode | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| CSS-first theming & color presets | ✓ (8) | ✓ (20+) | ✗ | Partial | ✗ | Partial | ✗ |
| Ecto / FormField integration | ✓ | ✗ | ✓ | ✗ | ✓ | ✓ | ✓ |
| Enterprise dashboard shell | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| KPI / analytics widgets | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| AI / chat components | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Kanban + filter builder | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Ctrl+K command palette | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |

> **DaisyUI** — CSS-only Tailwind plugin, framework-agnostic, ideal for rapid prototyping.
> **Salad UI** — shadcn/ui patterns for Phoenix LiveView, copy-paste via `mix salad.install`.
> **ShadCN/ui** — React/Next.js, Radix UI primitives, the inspiration behind PhiaUI's copy-paste model.
> **Doggo** — headless, unstyled, strict WAI-ARIA; bring your own CSS.
> **Mishka Chelekom** — feature-rich Phoenix LiveView kit, CLI-generated components, Tailwind v4.
> **Primer Live** — GitHub Primer design system for Phoenix LiveView, library dependency model.

---

## Component Library — 119 Components

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

### Gap Analysis Components — 15 components

Newly added components identified by gap analysis vs shadcn/ui, Mantine, Ant Design, Chakra UI v3, and MUI. → [Full examples & use cases](docs/components/gap.md)

#### Input Primitives

| Component | Function | Description |
|-----------|----------|-------------|
| InputOTP | `input_otp/1`, `input_otp_group/1`, `input_otp_slot/1`, `input_otp_separator/1` | N-slot OTP/PIN input with auto-advance focus, paste distribution, `inputmode="numeric"` |
| Spinner | `spinner/1` | CSS SVG animated loading indicator, 5 sizes, `role="status"` + `aria-live` |
| NumberInput | `number_input/1`, `form_number_input/1` | Native `<input type="number">` with ± stepper buttons, prefix/suffix slots, FormField integration |
| PasswordInput | `password_input/1`, `form_password_input/1` | Password field with show/hide toggle via `JS.toggle_attribute`, `autocomplete="current-password"` |
| CopyButton | `copy_button/1` | Clipboard copy button — `PhiaCopyButton` hook, check icon feedback, `aria-live` announcement |

#### Selection & Interaction

| Component | Function | Hook | Description |
|-----------|----------|------|-------------|
| SegmentedControl | `segmented_control/1` | — | Radio-based segment selector, CSS active state, 3 sizes |
| Chip | `chip/1`, `chip_group/1` | — | Interactive pill: toggle (`aria-pressed`), dismissible (×), 3 variants, 3 sizes |
| Editable | `editable/1` | `PhiaEditable` | Click-to-edit inline field — preview/edit toggle, Enter confirm, Escape cancel, click-outside cancel |
| Menubar | `menubar/1`, `menubar_trigger/1`, `menubar_content/1`, `menubar_item/1`, `menubar_separator/1` | — | Desktop app-style menu bar, `role="menubar"` + `role="menu"` + keyboard navigation |

#### Upload & File

| Component | Function | Description |
|-----------|----------|-------------|
| FileUpload | `file_upload/1`, `file_upload_entry/1` | Drag-and-drop zone, `phx-drop-target`, progress bar per entry, error display, cancel button |

#### Utility & Navigation

| Component | Function | Hook | Description |
|-----------|----------|------|-------------|
| ColorPicker | `color_picker/1` | `PhiaColorPicker` | Native `<input type="color">` + swatches + hex display, hook syncs all three |
| FloatButton | `float_button/1` | — | Fixed circular action button; speed-dial variant with expandable item buttons |
| MultiSelect | `multi_select/1`, `form_multi_select/1` | — | `<select multiple>` with selected-chip row, `find_label/2`, FormField integration |
| Tree | `tree/1`, `tree_item/1` | — | Hierarchical tree view using native `<details>/<summary>` (zero JS), `role="tree"` + `aria-expanded` |
| BackTop | `back_top/1` | `PhiaBackTop` | Fixed scroll-to-top button — appears after threshold px, smooth scroll, fade transition |

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
    {:phia_ui, "~> 0.1.5"}
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
import PhiaCopyButton   from "./phia_hooks/copy_button"
import PhiaEditable     from "./phia_hooks/editable"
import PhiaColorPicker  from "./phia_hooks/color_picker"
import PhiaBackTop      from "./phia_hooks/back_top"
import PhiaAudioPlayer  from "./phia_hooks/audio_player"
import PhiaSonner       from "./phia_hooks/sonner"

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: {
    PhiaDialog, PhiaDropdownMenu, PhiaTagsInput, PhiaRichTextEditor,
    PhiaTooltip, PhiaPopover, PhiaToast, PhiaDarkMode,
    PhiaCommand, PhiaDateRangePicker, PhiaChart,
    PhiaCalendar, PhiaCarousel, PhiaContextMenu, PhiaDrawer,
    PhiaTheme, PhiaResizable, PhiaMentionInput,
    PhiaCopyButton, PhiaEditable, PhiaColorPicker, PhiaBackTop,
    PhiaAudioPlayer, PhiaSonner
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

### InputOTP

```heex
<%!-- Simple: --%>
<.input_otp id="verify-code" name="code" length={6} value={@otp_code} />

<%!-- Composable with separator: --%>
<.input_otp_group id="token-group">
  <.input_otp_slot index={0} name="token[0]" value={String.at(@token, 0) || ""} />
  <.input_otp_slot index={1} name="token[1]" value={String.at(@token, 1) || ""} />
  <.input_otp_slot index={2} name="token[2]" value={String.at(@token, 2) || ""} />
  <.input_otp_separator />
  <.input_otp_slot index={3} name="token[3]" value={String.at(@token, 3) || ""} />
  <.input_otp_slot index={4} name="token[4]" value={String.at(@token, 4) || ""} />
  <.input_otp_slot index={5} name="token[5]" value={String.at(@token, 5) || ""} />
</.input_otp_group>
```

### Spinner

```heex
<.spinner />
<.spinner size={:lg} class="text-primary" />
<.spinner label="Loading data..." size={:sm} />
```

### NumberInput & PasswordInput

```heex
<.form_number_input field={@form[:quantity]} label="Quantity" min={1} max={999} step={1} />
<.form_number_input field={@form[:price]} label="Price" prefix="$" suffix="USD" />

<.form_password_input field={@form[:password]} label="Password" />
<.form_password_input field={@form[:confirm]} label="Confirm Password" autocomplete="new-password" />
```

### CopyButton

```heex
<div class="flex items-center gap-2">
  <code class="text-sm bg-muted px-2 py-1 rounded font-mono">{@api_key}</code>
  <.copy_button value={@api_key} label="Copy API key" />
</div>
```

### SegmentedControl

```heex
<.segmented_control
  id="view-mode"
  name="view"
  value={@view}
  on_change="change_view"
  segments={[
    %{value: "list",   label: "List"},
    %{value: "grid",   label: "Grid"},
    %{value: "kanban", label: "Kanban"}
  ]}
/>
```

### Chip & ChipGroup

```heex
<.chip_group>
  <.chip :for={tech <- @selected_stack}
    value={tech}
    dismissible={true}
    on_dismiss="remove_tech"
    variant={:outline}>
    {tech}
  </.chip>
</.chip_group>

<%!-- Toggle chip --%>
<.chip selected={@dark_mode} on_click="toggle_dark" value="dark">
  Dark Mode
</.chip>
```

### Editable (inline edit)

```heex
<.editable id="project-title" value={@project.name} on_submit="update_name">
  <:preview>
    <h1 class="text-2xl font-bold">{@project.name}</h1>
  </:preview>
  <:input>
    <.phia_input id="project-title-input" name="name" value={@project.name} />
  </:input>
</.editable>
```

### FileUpload

```heex
<.file_upload upload={@uploads.attachments} label="Attach Files" accept=".pdf,.docx,.xlsx">
  <:empty>
    <.icon name="upload-cloud" class="h-8 w-8 text-muted-foreground mx-auto mb-2" />
    <p class="text-sm text-muted-foreground">
      Drag & drop files here or <span class="text-primary underline">browse</span>
    </p>
  </:empty>
  <:file :let={entry}>
    <.file_upload_entry entry={entry} on_cancel="cancel_upload" />
  </:file>
</.file_upload>
```

### Menubar

```heex
<.menubar id="app-menubar">
  <.menubar_menu>
    <.menubar_trigger>File</.menubar_trigger>
    <.menubar_content>
      <.menubar_item on_click="new_file">New File</.menubar_item>
      <.menubar_item on_click="open_file">Open…</.menubar_item>
      <.menubar_separator />
      <.menubar_item on_click="save" shortcut="⌘S">Save</.menubar_item>
    </.menubar_content>
  </.menubar_menu>
  <.menubar_menu>
    <.menubar_trigger>Edit</.menubar_trigger>
    <.menubar_content>
      <.menubar_item on_click="undo" shortcut="⌘Z">Undo</.menubar_item>
      <.menubar_item on_click="redo" shortcut="⌘⇧Z">Redo</.menubar_item>
    </.menubar_content>
  </.menubar_menu>
</.menubar>
```

### MultiSelect

```heex
<.form_multi_select
  field={@form[:tags]}
  label="Tags"
  options={[{"Elixir", "elixir"}, {"Phoenix", "phoenix"}, {"LiveView", "liveview"}, {"Ecto", "ecto"}]}
/>
```

### Tree

```heex
<.tree id="file-explorer">
  <.tree_item label="lib" expandable={true} expanded={true}>
    <.tree_item label="phia_ui" expandable={true}>
      <.tree_item label="components" expandable={true}>
        <.tree_item label="button.ex" on_click="open_file" value="button.ex" />
        <.tree_item label="card.ex" on_click="open_file" value="card.ex" />
      </.tree_item>
    </.tree_item>
  </.tree_item>
  <.tree_item label="mix.exs" on_click="open_file" value="mix.exs" />
</.tree>
```

### ColorPicker

```heex
<.color_picker
  id="brand-color"
  value={@brand_color}
  on_change="update_brand_color"
  swatches={["#1e40af", "#7c3aed", "#dc2626", "#16a34a", "#ea580c"]}
/>
```

### FloatButton

```heex
<%!-- Simple --%>
<.float_button icon="plus" on_click="new_item" aria_label="Create new item" />

<%!-- Speed dial --%>
<.float_button position={:bottom_right}>
  <:main icon="menu" aria_label="Actions" />
  <:item icon="edit" on_click="edit" label="Edit" />
  <:item icon="share" on_click="share" label="Share" />
  <:item icon="trash" on_click="delete" label="Delete" />
</.float_button>
```

### BackTop

```heex
<%!-- Mount once per page that needs it --%>
<.back_top threshold={300} smooth={true} aria_label="Back to top" />
```

→ [Gap analysis component examples](docs/components/gap.md)

### Calendar & Scheduling Suite — 27 components

The most comprehensive calendar and scheduling system for Phoenix LiveView. → [Full examples & use cases](docs/components/calendar.md)

#### Standard Pickers

| Component | Function | Description |
|-----------|----------|-------------|
| TimePicker | `time_picker/1`, `form_time_picker/1` | Clock-face or scroll-wheel time selector, 12h/24h, minute step, FormField |
| DateTimePicker | `date_time_picker/1`, `form_date_time_picker/1` | Combined date calendar + time picker in popover, ISO 8601 output, FormField |
| MonthPicker | `month_picker/1`, `form_month_picker/1` | Grid of 12 months, year navigation, FormField |
| YearPicker | `year_picker/1`, `form_year_picker/1` | Scrollable year grid, min/max bounds, FormField |
| WeekPicker | `week_picker/1`, `form_week_picker/1` | ISO week selector (Wxx/YYYY), week highlight in calendar grid |
| DateField | `date_field/1`, `form_date_field/1` | Segmented date input (DD / MM / YYYY) with independent slot navigation |
| WeekDayPicker | `week_day_picker/1` | Mon–Sun pill toggles for recurrence rules, multi-select |
| CalendarTimePicker | `calendar_time_picker/1` | Full month calendar + inline time picker in one component |
| DateRangePresets | `date_range_presets/1` | DateRangePicker with preset buttons (Today, This Week, Last 30 Days, etc.) |
| WheelPicker | `wheel_picker/1` | iOS-style scroll-wheel picker, configurable columns and items |

#### Calendar Views

| Component | Function | Description |
|-----------|----------|-------------|
| BigCalendar | `big_calendar/1` | Full-page month view, view switcher (month/week/day), MON-first, event pills |
| CalendarWeekView | `calendar_week_view/1` | Week grid with time axis (00:00–23:00), events positioned by px offset |
| WeekCalendar | `week_calendar/1` | Compact week navigator: month title + prev/next arrows, 7-day strip, selected-day pill |
| RangeCalendar | `range_calendar/1` | SUN-first month grid, range band: start/end circles + half-band + middle full-band |
| MultiSelectCalendar | `multi_select_calendar/1` | Calendar with multi-day selection (toggle individual days) |
| BadgeCalendar | `badge_calendar/1` | Calendar with numeric badge overlay per day (counts, notifications) |

#### Scheduling & Time

| Component | Function | Description |
|-----------|----------|-------------|
| TimeSlotGrid | `time_slot_grid/1` | Grid of bookable time slots: available / booked / selected states |
| TimeSlotList | `time_slot_list/1` | Vertical list of time slots with availability indicator and book button |
| DailyAgenda | `daily_agenda/1` | Single-day timeline with hour rows and overlapping event layout |
| ScheduleEventCard | `schedule_event_card/1` | Rich event card: title, time, location, attendees, status badge |
| CountdownTimer | `countdown_timer/1` | Live countdown to a target datetime, displays DD:HH:MM:SS |
| TimeSliderPicker | `time_slider_picker/1` | Slider-based time range picker for start/end time selection |

#### Booking & Specialized

| Component | Function | Description |
|-----------|----------|-------------|
| BookingCalendar | `booking_calendar/1` | Appointment booking calendar: availability slots per day, confirm flow |
| StreakCalendar | `streak_calendar/1` | Habit tracker / streak heatmap: current streak, longest streak, intensity |
| ScheduleView | `schedule_view/1` | Agenda-style list grouped by date (upcoming events sorted chronologically) |
| MultiMonthCalendar | `multi_month_calendar/1` | Side-by-side N months (2–4), synchronized navigation |
| DateCard | `date_card/1` | Day card with 4 states: default / today / selected / disabled |
| DateStrip | `date_strip/1` | Horizontal scrollable row of DateCards, highlights selected day |

### Advanced Dashboard Widgets — 8 components

High-fidelity data visualization and status widgets. → [Full examples & use cases](docs/components/widgets.md)

| Component | Function | Description |
|-----------|----------|-------------|
| CircularProgress | `circular_progress/1` | Radial SVG progress ring, customizable size/stroke/color, `role="progressbar"` |
| UptimeBar | `uptime_bar/1` | Segmented uptime visualization (green/red/yellow segments), percentage badge |
| ReceiptCard | `receipt_card/1` | Transaction/purchase receipt layout: line items, totals, merchant info, QR slot |
| SparklineCard | `sparkline_card/1` | Inline SVG sparkline polyline + metric value + trend badge |
| GaugeChart | `gauge_chart/1` | SVG semicircle gauge, value needle, min/max labels, color zones |
| GanttChart | `gantt_chart/1` | Horizontal timeline/project planning: row labels, date-range bars, today indicator |
| EventCalendar | `event_calendar/1` | Monthly grid with event pills, day click expands event list |
| Snackbar | `snackbar/1` | Temporary notification banner (bottom of screen), auto-dismiss, action slot |

### Media, Communication & Navigation — 5 components

| Component | Function | Description |
|-----------|----------|-------------|
| AudioPlayer | `audio_player/1` | Media player: play/pause, scrubber, volume, duration display — `PhiaAudioPlayer` hook |
| Sonner | `sonner/1` | Rich toast notifications: icon variants, action button, promise integration — `PhiaSonner` hook |
| QrCode | `qr_code/1` | SVG QR code generator via `eqrcode`, size attr, configurable error correction |
| BottomNavigation | `bottom_navigation/1`, `bottom_navigation_item/1` | Mobile bottom tab bar, `aria-current` on active tab, icon + label layout |
| Toolbar | `toolbar/1`, `toolbar_button/1`, `toolbar_separator/1` | Horizontal `role="toolbar"`, icon buttons, separators |

### Display & Interaction Additions — 3 components

| Component | Function | Description |
|-----------|----------|-------------|
| AvatarGroup | `avatar_group/1` | Standalone stacked avatars with overlap, `+N` overflow badge, sizes |
| SelectableCard | `selectable_card/1` | Card with checkbox/radio selection state, border highlight when selected |
| InputAddon | `input_addon/1` | Prefix/suffix addon wrapper for inputs (icons, labels, currency symbols) |

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
- **Booking and scheduling** — BookingCalendar + TimeSlotGrid + DateRangePicker + CalendarWeekView for complete reservation flows
- **Habit and streak tracking** — StreakCalendar + BadgeCalendar + HeatmapCalendar for gamified productivity apps
- **Project planning** — GanttChart + KanbanBoard + ActivityFeed + StepTracker for full project management UI
- **Audio & media apps** — AudioPlayer with full controls, progress scrubber, volume, and dark mode support
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
| [Gap Analysis Components](docs/components/gap.md) | InputOTP, Spinner, NumberInput, PasswordInput, CopyButton, SegmentedControl, Chip, Editable, FileUpload, Menubar, ColorPicker, FloatButton, MultiSelect, Tree, BackTop |
| [Calendar & Scheduling Suite](docs/components/calendar.md) | TimePicker, DateTimePicker, MonthPicker, YearPicker, WeekPicker, DateField, BigCalendar, CalendarWeekView, WeekCalendar, RangeCalendar, TimeSlotGrid, BookingCalendar, StreakCalendar, and more |
| [Advanced Widgets](docs/components/widgets.md) | CircularProgress, UptimeBar, ReceiptCard, SparklineCard, GaugeChart, GanttChart, EventCalendar, Snackbar |
| [Media & Navigation](docs/components/media.md) | AudioPlayer, Sonner, QrCode, BottomNavigation, Toolbar |
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
