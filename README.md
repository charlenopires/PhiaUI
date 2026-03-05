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

### Buttons — 7 components

Action triggers for all interaction patterns: primary actions, toolbars, floating actions, and toggles.

| Component | Function | Description |
|-----------|----------|-------------|
| Button | `button/1` | 6 variants (default, destructive, outline, secondary, ghost, link) × 4 sizes, icon size, disabled state |
| ButtonGroup | `button_group/1` | Unified button toolbar with horizontal/vertical orientation, shared border radius |
| BackTop | `back_top/1` | Fixed scroll-to-top button — appears after scroll threshold, smooth scroll, fade — `PhiaBackTop` hook |
| CopyButton | `copy_button/1` | Clipboard copy with check-icon feedback and `aria-live` announcement — `PhiaCopyButton` hook |
| FloatButton | `float_button/1` | Fixed circular FAB; speed-dial variant with expandable item buttons |
| Toggle | `toggle/1` | `aria-pressed` stateful button, 2 variants (default, outline), 3 sizes |
| ToggleGroup | `toggle_group/1` | Single or multiple selection group, `:let` context for active state |

→ [Full documentation](docs/components/buttons.md)

### Calendar — 33 components

The most comprehensive calendar and scheduling suite for Phoenix LiveView, covering every date/time interaction pattern from simple pickers to full booking platforms.

| Component | Function | Description |
|-----------|----------|-------------|
| BadgeCalendar | `badge_calendar/1` | Calendar with numeric badge overlay per day (counts, notifications) |
| BigCalendar | `big_calendar/1` | Full-page month view, view switcher (month/week/day), MON-first, event pills |
| BookingCalendar | `booking_calendar/1` | Appointment booking calendar with availability slots per day and confirm flow |
| Calendar | `calendar/1` | Server-rendered monthly grid, single/range mode, keyboard navigation |
| CalendarTimePicker | `calendar_time_picker/1` | Full month calendar + inline time picker combined in one component |
| CalendarWeekView | `calendar_week_view/1` | Week grid with time axis (00:00–23:00), events positioned by pixel offset |
| CountdownTimer | `countdown_timer/1` | Live server-side countdown to target datetime, displays DD:HH:MM:SS |
| DailyAgenda | `daily_agenda/1` | Single-day timeline with hour rows and overlapping event layout |
| DateCard | `date_card/1` | Day card with 4 states: default / today / selected / disabled |
| DateField | `date_field/1`, `form_date_field/1` | Segmented date input (DD / MM / YYYY) with independent slot navigation, FormField |
| DatePicker | `date_picker/1` | Calendar + Popover compose, configurable date format |
| DateRangePicker | `date_range_picker/1` | Dual calendar range selection, range highlight, min/max bounds — `PhiaDateRangePicker` hook |
| DateRangePresets | `date_range_presets/1` | DateRangePicker extended with preset buttons (Today, This Week, Last 30 Days, custom) |
| DateStrip | `date_strip/1` | Horizontal scrollable row of DateCards, auto-scrolls to selected day |
| DateTimePicker | `date_time_picker/1`, `form_date_time_picker/1` | Combined date calendar + time picker in popover, ISO 8601 output, FormField |
| EventCalendar | `event_calendar/1` | Monthly grid with event pills; day click expands event list |
| HeatmapCalendar | `heatmap_calendar/1` | Contribution-style grid, intensity buckets, `role="grid"` WAI-ARIA |
| MonthPicker | `month_picker/1`, `form_month_picker/1` | Grid of 12 months, year navigation arrows, FormField |
| MultiMonthCalendar | `multi_month_calendar/1` | Side-by-side N months (2–4), synchronized navigation |
| MultiSelectCalendar | `multi_select_calendar/1` | Calendar with toggle-per-day multi-day selection |
| RangeCalendar | `range_calendar/1` | SUN-first month grid, range band: start/end blue circles + half-band + full-band |
| ScheduleEventCard | `schedule_event_card/1` | Rich event card: title, time, location, attendees, status badge |
| ScheduleView | `schedule_view/1` | Agenda-style list grouped by date, upcoming events sorted chronologically |
| StreakCalendar | `streak_calendar/1` | Habit tracker / streak heatmap: current streak, longest streak, intensity levels |
| TimePicker | `time_picker/1`, `form_time_picker/1` | Clock-face or scroll-wheel time selector, 12h/24h, minute step, FormField |
| TimeSliderPicker | `time_slider_picker/1` | Slider-based start/end time range picker |
| TimeSlotGrid | `time_slot_grid/1` | Grid of bookable time slots: available / booked / selected states |
| TimeSlotList | `time_slot_list/1` | Vertical list of time slots with availability indicator and book button |
| WeekCalendar | `week_calendar/1` | Compact week navigator: month title + prev/next arrows, 7-day strip, selected-day pill |
| WeekDayPicker | `week_day_picker/1` | Mon–Sun pill toggles for recurrence rules, multi-select |
| WeekPicker | `week_picker/1`, `form_week_picker/1` | ISO week selector (Wxx/YYYY), week highlight in calendar grid, FormField |
| WheelPicker | `wheel_picker/1` | iOS-style scroll-snap wheel picker, configurable columns and items |
| YearPicker | `year_picker/1`, `form_year_picker/1` | Scrollable year grid, min/max bounds, FormField |

→ [Full documentation](docs/components/calendar.md)

---

### Cards — 5 components

Structured surface components for metrics, selection, and e-commerce receipts.

| Component | Function | Description |
|-----------|----------|-------------|
| Card | `card/1` | Composable card with header, content, and footer slots |
| MetricGrid | `metric_grid/1` | Responsive grid wrapper for multiple StatCards, configurable column count |
| ReceiptCard | `receipt_card/1` | Transaction/purchase receipt: line items, totals, merchant info, QR slot |
| SelectableCard | `selectable_card/1` | Card with checkbox/radio selection state, border highlight when selected |
| StatCard | `stat_card/1` | KPI card with value, trend indicator (up/down/neutral), and trend value |

→ [Full documentation](docs/components/cards.md)

---

### Data — 13 components

Enterprise data management: tables, grids, charts, Gantt, Kanban, and advanced filters.

| Component | Function | Description |
|-----------|----------|-------------|
| BulkActionBar | `bulk_action_bar/1` | Contextual toolbar activated by table row selection; action slots |
| ChartShell | `chart_shell/1` | Consistent card chrome wrapper for any chart library |
| Chart | `phia_chart/1` | ECharts integration hook — area, bar, line, pie, scatter — `PhiaChart` hook |
| DataGrid | `data_grid/1` | Sortable columns with `phx-click` sort events, `next_dir/1` helper |
| FilterBar | `filter_bar/1` | Horizontal filter toolbar with search, select, toggle, and reset slots |
| FilterBuilder | `filter_builder/1` | Dynamic query builder: field / operator / value rule rows, add/remove |
| GanttChart | `gantt_chart/1` | Horizontal SVG project timeline: row labels, date-range bars, today indicator |
| GaugeChart | `gauge_chart/1` | SVG semicircle gauge, value needle, min/max labels, configurable color zones |
| KanbanBoard | `kanban_board/1` | Drag-ready column + card layout with priority indicators and avatar slots |
| SparklineCard | `sparkline_card/1` | Inline SVG sparkline polyline + metric value + trend badge |
| Table | `table/1` | 8 sub-components, `phx-update="stream"` compatible, sortable headers |
| Tree | `tree/1`, `tree_item/1` | Hierarchical tree view via native `<details>/<summary>` (zero JS), `role="tree"` |
| UptimeBar | `uptime_bar/1` | Segmented uptime visualization (green/red/yellow segments), percentage badge |

→ [Full documentation](docs/components/data.md)

---

### Display — 11 components

Visual identity, status indicators, avatars, chat bubbles, and theme control.

| Component | Function | Description |
|-----------|----------|-------------|
| ActivityFeed | `activity_feed/1` | Chronological event log with 6 activity types, group labels, and avatar slot |
| Avatar | `avatar/1` | Circular profile image with initials fallback, 5 sizes |
| AvatarGroup | `avatar_group/1` | Stacked overlapping avatars, `+N` overflow badge, configurable max |
| Badge | `badge/1` | 4 variants (default, secondary, outline, destructive) for status labels |
| ChatMessage | `chat_message/1` | Full AI/human chat UI: container, bubbles, suggestions, chat input |
| DarkModeToggle | `dark_mode_toggle/1` | localStorage + `prefers-color-scheme` dark mode toggle — `PhiaDarkMode` hook |
| Direction | `direction/1` | LTR/RTL wrapper for multilingual (Arabic, Hebrew) content |
| Icon | `icon/1` | Lucide SVG sprite, 4 sizes (`xs`, `sm`, `md`, `lg`) |
| Kbd | `kbd/1` | Semantic `<kbd>` keyboard shortcut display |
| ThemeProvider | `theme_provider/1` | Scoped CSS theme wrapper via `data-phia-theme` attribute |
| Timeline | `timeline/1` | Vertical activity timeline with status states, CSS-only connector |

→ [Full documentation](docs/components/display.md)

---

### Feedback — 11 components

Loading states, alerts, notifications, and progress indicators.

| Component | Function | Description |
|-----------|----------|-------------|
| Alert | `alert/1` | 2 variants (default, destructive) with title and description sub-components |
| AlertDialog | `alert_dialog/1` | `role="alertdialog"`, destructive variant, shared `PhiaDialog` hook |
| CircularProgress | `circular_progress/1` | Radial SVG progress ring, customizable size/stroke/color, `role="progressbar"` |
| EmptyState | `empty_state/1` | Centered placeholder with icon, title, description, and action slots |
| Progress | `progress/1` | Horizontal `role="progressbar"`, `aria-valuenow`, indeterminate mode |
| Skeleton | `skeleton/1` | `animate-pulse` block placeholders for loading states |
| Snackbar | `snackbar/1` | Temporary bottom-of-screen notification banner, auto-dismiss, action slot |
| Sonner | `sonner/1` | Rich toast stack: icon variants, action button, promise integration — `PhiaSonner` hook |
| Spinner | `spinner/1` | CSS SVG animated loading indicator, 5 sizes, `role="status"` + `aria-live` |
| StepTracker | `step_tracker/1` | Multi-step wizard progress indicator, horizontal and vertical orientation |
| Toast | `toast/1` | `push_event`-driven auto-dismiss toast, stacking, 5 variants — `PhiaToast` hook |

→ [Full documentation](docs/components/feedback.md)

---

### Forms — 4 components

Form layout primitives that integrate with `Phoenix.HTML.Form` and Ecto changesets.

| Component | Function | Description |
|-----------|----------|-------------|
| Field | `field/1` | Standalone form field layout without Phoenix.HTML.FormField |
| Form | `form/1` | `phx-change` / `phx-submit` form wrapper |
| FormField | `form_field/1`, `form_label/1`, `form_message/1` | Composable label + input + error message primitives |
| Label | `label/1` | Accessible `<label>` with `for` attribute, required indicator |

→ [Full documentation](docs/components/forms.md)

---

### Inputs — 24 components

Every input primitive with full Ecto / `Phoenix.HTML.FormField` integration.

| Component | Function | Description |
|-----------|----------|-------------|
| Checkbox | `checkbox/1`, `form_checkbox/1` | Native checkbox, indeterminate state, FormField |
| Chip | `chip/1`, `chip_group/1` | Interactive pill: toggle (`aria-pressed`), dismissible (×), 3 variants |
| ColorPicker | `color_picker/1` | Native `<input type="color">` + swatches + hex display — `PhiaColorPicker` hook |
| Combobox | `combobox/1` | Server-side search filter dropdown, FormField integration |
| Editable | `editable/1` | Click-to-edit inline field: preview/edit toggle, Enter/Escape/click-outside — `PhiaEditable` hook |
| FileUpload | `file_upload/1`, `file_upload_entry/1` | Drag-and-drop zone, `phx-drop-target`, per-entry progress bar, cancel |
| ImageUpload | `image_upload/1` | Drop zone + preview grid, native Phoenix `live_file_input` uploads |
| Input | `input/1` | Base `<input>` element, multiple types, class customization |
| InputAddon | `input_addon/1` | Prefix/suffix addon wrapper for inputs (icons, labels, currency symbols) |
| InputOTP | `input_otp/1` | N-slot OTP/PIN input with auto-advance focus, paste distribution, `inputmode="numeric"` |
| MentionInput | `mention_input/1` | `@mention` textarea with server-side autocomplete — `PhiaMentionInput` hook |
| MultiSelect | `multi_select/1`, `form_multi_select/1` | `<select multiple>` with selected-chip row, FormField integration |
| NumberInput | `number_input/1`, `form_number_input/1` | `<input type="number">` with ± stepper buttons, prefix/suffix slots, FormField |
| PasswordInput | `password_input/1`, `form_password_input/1` | Password field with show/hide toggle via `JS.toggle_attribute`, FormField |
| PhiaInput | `phia_input/1` | Unified label + input + description + error message wrapper, all input types |
| RadioGroup | `radio_group/1`, `form_radio_group/1` | Native radio inputs, `:let` context, FormField |
| Rating | `rating/1`, `form_rating/1` | CSS-only star rating, `role="radiogroup"`, FormField |
| RichTextEditor | `rich_text_editor/1` | WYSIWYG editor, 14 toolbar commands, zero npm — `PhiaRichTextEditor` hook |
| SegmentedControl | `segmented_control/1` | Radio-based segment selector, CSS active-sliding state, 3 sizes |
| Select | `select/1` | Native `<select>` with FormField integration |
| Slider | `slider/1`, `form_slider/1` | CSS `input[type=range]`, WAI-ARIA `aria-valuemin/max/now`, FormField |
| Switch | `switch/1`, `form_switch/1` | Toggle switch with CSS animation, `role="switch"`, FormField |
| TagsInput | `tags_input/1` | Multi-tag input, deduplication, CSV hidden sync — `PhiaTagsInput` hook |
| Textarea | `textarea/1` | Multi-line textarea with FormField integration |

→ [Full documentation](docs/components/inputs.md)

---

### Layout — 7 components

Structural composition components for panels, scroll areas, and collapsible regions.

| Component | Function | Description |
|-----------|----------|-------------|
| Accordion | `accordion/1` | Single or multiple expand mode via `Phoenix.LiveView.JS`, zero hooks |
| AspectRatio | `aspect_ratio/1` | CSS padding-top ratio trick, any ratio (16:9, 4:3, 1:1, etc.) |
| Collapsible | `collapsible/1` | Single-panel expand/collapse, server-controlled open state via `Phoenix.LiveView.JS` |
| Resizable | `resizable/1` | Drag-to-resize split panels — `PhiaResizable` hook |
| ScrollArea | `scroll_area/1` | Custom scrollbar overlay, horizontal / vertical / both orientations |
| Separator | `separator/1` | Horizontal or vertical divider, `role="separator"` |
| Shell | `shell/1` | CSS Grid desktop layout: fixed sidebar 240px + fluid main 1fr |

→ [Full documentation](docs/components/layout.md)

---

### Media — 3 components

Audio playback, image carousels, and QR code generation.

| Component | Function | Description |
|-----------|----------|-------------|
| AudioPlayer | `audio_player/1` | Full media player: play/pause, scrubber, volume, duration display — `PhiaAudioPlayer` hook |
| Carousel | `carousel/1` | Touch-swipe, keyboard navigation, loop, dot indicators — `PhiaCarousel` hook |
| QrCode | `qr_code/1` | Inline SVG QR code via `eqrcode`, configurable size and error correction level |

→ [Full documentation](docs/components/media.md)

---

### Navigation — 11 components

Application chrome: sidebar, topbar, breadcrumbs, tabs, pagination, and mobile navigation.

| Component | Function | Description |
|-----------|----------|-------------|
| BottomNavigation | `bottom_navigation/1`, `bottom_navigation_item/1` | Mobile bottom tab bar, `aria-current` on active tab, icon + label layout |
| Breadcrumb | `breadcrumb/1` | 7 sub-components, `aria-label="Breadcrumb"`, `aria-current="page"` on last item |
| Menubar | `menubar/1` | Desktop app-style menu bar, `role="menubar"` + keyboard navigation |
| MobileSidebarToggle | `mobile_sidebar_toggle/1` | Hamburger button that opens sidebar drawer on small viewports |
| NavigationMenu | `navigation_menu/1` | Horizontal nav with links and mega-menu dropdown content panels |
| Pagination | `pagination/1` | Server-side pagination with `phx-click` page events |
| Sidebar | `sidebar/1`, `sidebar_item/1` | Fixed sidebar, brand / nav / footer slots, active item highlight |
| Tabs | `tabs/1` | tab / list / trigger / content composition, server-rendered, `:let` context |
| TabsNav | `tabs_nav/1` | Navigation tabs: underline, solid, and pill variants |
| Toolbar | `toolbar/1`, `toolbar_button/1`, `toolbar_separator/1` | `role="toolbar"`, icon buttons, keyboard-navigable separator |
| Topbar | `topbar/1` | Full-width application header with left/center/right action slots |

→ [Full documentation](docs/components/navigation.md)

---

### Overlay — 9 components

Modal dialogs, drawers, popovers, tooltips, and context menus — all with focus management.

| Component | Function | Description |
|-----------|----------|-------------|
| Command | `command/1` | Ctrl+K global command palette, arrow-key navigation, server-side filter — `PhiaCommand` hook |
| ContextMenu | `context_menu/1` | Right-click context menu, smart positioning, `role="menu"` WAI-ARIA — `PhiaContextMenu` hook |
| Dialog | `dialog/1` | Modal dialog with focus trap, Escape to close, scroll lock — `PhiaDialog` hook |
| Drawer | `drawer/1` | 4-direction side panel / bottom sheet, focus trap, backdrop click — `PhiaDrawer` hook |
| DropdownMenu | `dropdown_menu/1` | Trigger + menu: smart flip, click-outside, arrow-key navigation — `PhiaDropdownMenu` hook |
| HoverCard | `hover_card/1` | `role="tooltip"` hover preview card, delay show/hide |
| Popover | `popover/1` | Click-open floating panel, focus trap, click-outside to close — `PhiaPopover` hook |
| Sheet | `sheet/1` | 4 sides (top/right/bottom/left), 5 sizes, modal side panel — `PhiaDialog` hook |
| Tooltip | `tooltip/1` | Hover + focus tooltip, 4 positions, smart flip — `PhiaTooltip` hook |

→ [Full documentation](docs/components/overlay.md)

---

## Live Sample

See PhiaUI in action with a full enterprise dashboard, booking platform, and CMS built entirely from library components:

**[github.com/charlenopires/PhiaUI-samples](https://github.com/charlenopires/PhiaUI-samples)**

---

## Quick Start

### Step 1 — Install

Add PhiaUI to `mix.exs`:

```elixir
def deps do
  [
    {:phia_ui, "~> 0.1.5"}
  ]
end
```

Fetch dependencies and run the installer:

```bash
mix deps.get
mix phia.install
```

The installer copies all 24 JS hook files to `assets/js/phia_hooks/` and injects the base theme import into `app.css`.

### Step 2 — Configure CSS

In `assets/css/app.css`:

```css
@import "tailwindcss";
@import "../../../deps/phia_ui/priv/static/theme.css";
```

For runtime color theme switching (optional), generate the multi-theme CSS:

```bash
mix phia.theme install
```

This writes `assets/css/phia-themes.css` with all 8 `[data-phia-theme]` selectors and auto-imports it in `app.css`. Activate a preset by setting `data-phia-theme="blue"` on any ancestor element or on `<html>`.

### Step 3 — Eject components

Copy specific component source files into your project:

```bash
mix phia.add button card dialog
```

Components are ejected to `lib/your_app_web/components/ui/`. After ejection you own the code — read it, customize it, delete what you do not need.

```
lib/your_app_web/components/ui/button.ex      ← yours to edit
assets/js/phia_hooks/dialog.js                ← yours to edit
```

### Step 4 — Import in your LiveView

```elixir
defmodule MyAppWeb.PageLive do
  use MyAppWeb, :live_view

  import MyAppWeb.Components.UI.Button
  import MyAppWeb.Components.UI.Card
  import MyAppWeb.Components.UI.Dialog

  def render(assigns) do
    ~H"""
    <.button variant="default">Hello PhiaUI</.button>
    """
  end
end
```

Or import globally in `my_app_web.ex`:

```elixir
defp html_helpers do
  quote do
    import MyAppWeb.Components.UI.Button
    import MyAppWeb.Components.UI.Card
    # add more as you eject them
  end
end
```

### Step 5 — Register JS hooks

Add all 24 hooks to `assets/js/app.js`:

```javascript
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
import PhiaCopyButton      from "./phia_hooks/copy_button"
import PhiaEditable        from "./phia_hooks/editable"
import PhiaColorPicker     from "./phia_hooks/color_picker"
import PhiaBackTop         from "./phia_hooks/back_top"
import PhiaAudioPlayer     from "./phia_hooks/audio_player"
import PhiaSonner          from "./phia_hooks/sonner"

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: {
    PhiaDialog, PhiaDropdownMenu, PhiaTagsInput, PhiaRichTextEditor,
    PhiaTooltip, PhiaPopover, PhiaToast, PhiaDarkMode,
    PhiaCommand, PhiaDateRangePicker, PhiaChart, PhiaCalendar,
    PhiaCarousel, PhiaContextMenu, PhiaDrawer, PhiaTheme,
    PhiaResizable, PhiaMentionInput, PhiaCopyButton, PhiaEditable,
    PhiaColorPicker, PhiaBackTop, PhiaAudioPlayer, PhiaSonner
  }
})
```

> Only import hooks for components you actually use. All hook files are vanilla JS — zero npm runtime dependencies.

---

## Usage Patterns

### Buttons & Actions

```heex
<%!-- Variants --%>
<.button>Default</.button>
<.button variant="destructive">Delete</.button>
<.button variant="outline" size="sm">
  <.icon name="download" size={:sm} /> Export
</.button>
<.button variant="ghost" size="icon"><.icon name="more-horizontal" size={:sm} /></.button>

<%!-- Button Group toolbar --%>
<.button_group>
  <.button variant="outline" size="icon"><.icon name="bold" size={:sm} /></.button>
  <.button variant="outline" size="icon"><.icon name="italic" size={:sm} /></.button>
  <.button variant="outline" size="icon"><.icon name="underline" size={:sm} /></.button>
</.button_group>

<%!-- Floating action button with speed dial --%>
<.float_button position={:bottom_right}>
  <:main icon="plus" aria_label="Actions" />
  <:item icon="edit"  on_click="edit"   label="Edit" />
  <:item icon="share" on_click="share"  label="Share" />
  <:item icon="trash" on_click="delete" label="Delete" />
</.float_button>
```

### Layout Shell

```heex
<.shell>
  <:sidebar>
    <.sidebar>
      <:brand>
        <span class="font-bold text-lg">MyApp</span>
      </:brand>
      <:nav>
        <.sidebar_item href="/dashboard" active={@path == "/dashboard"} icon="layout-dashboard">
          Dashboard
        </.sidebar_item>
        <.sidebar_item href="/users" active={@path =~ "/users"} icon="users">
          Users
        </.sidebar_item>
        <.sidebar_item href="/settings" active={@path =~ "/settings"} icon="settings">
          Settings
        </.sidebar_item>
      </:nav>
    </.sidebar>
  </:sidebar>
  <:topbar>
    <.topbar>
      <:left><h1 class="text-lg font-semibold">{@page_title}</h1></:left>
      <:right>
        <.dark_mode_toggle />
        <.avatar><.avatar_fallback name={@current_user.name} /></.avatar>
      </:right>
    </.topbar>
  </:topbar>
  <:main>
    {@inner_content}
  </:main>
</.shell>
```

### Forms & Inputs

```heex
<.form for={@form} phx-change="validate" phx-submit="save">
  <.phia_input field={@form[:email]} type="email" label="Email address" phx-debounce="blur" />
  <.phia_input field={@form[:name]} label="Full name" />
  <.form_number_input field={@form[:age]} label="Age" min={18} max={120} step={1} />
  <.form_password_input field={@form[:password]} label="Password" />

  <.field>
    <div class="flex items-center gap-2">
      <.checkbox id="terms" name="terms" checked={@terms_checked} phx-click="toggle-terms" />
      <.label for="terms">I agree to the Terms of Service</.label>
    </div>
  </.field>

  <.button type="submit" class="w-full">Create account</.button>
</.form>

<%!-- Tags input --%>
<.tags_input id="skill-tags" name="skills" value={@skills} placeholder="Add skill…" />

<%!-- Inline editable field --%>
<.editable id="project-name" value={@project.name} on_submit="rename_project">
  <:preview><h1 class="text-2xl font-bold">{@project.name}</h1></:preview>
  <:input><.phia_input id="project-name-input" name="name" value={@project.name} /></:input>
</.editable>
```

### Overlay Components

```heex
<%!-- Dialog --%>
<.dialog id="confirm-dialog" open={@show_dialog}>
  <.dialog_header>
    <.dialog_title>Confirm action</.dialog_title>
    <.dialog_description>This cannot be undone.</.dialog_description>
  </.dialog_header>
  <.dialog_footer>
    <.button variant="outline" phx-click="cancel">Cancel</.button>
    <.button variant="destructive" phx-click="confirm">Confirm</.button>
  </.dialog_footer>
</.dialog>

<%!-- Drawer --%>
<.drawer id="filters-drawer" open={@filters_open} direction="right">
  <.drawer_header><h2 class="font-semibold">Filters</h2></.drawer_header>
  <.drawer_close />
  <div class="px-6 pb-6">
    <.filter_builder fields={@fields} rules={@rules}
      on_add="add_rule" on_remove="remove_rule" on_change="update_rule" />
  </div>
  <.drawer_footer>
    <.button phx-click="apply_filters">Apply filters</.button>
  </.drawer_footer>
</.drawer>

<%!-- Tooltip --%>
<.tooltip content="Copy to clipboard">
  <.copy_button value={@api_key} />
</.tooltip>

<%!-- Command palette (Ctrl+K) --%>
<.command id="command-palette" open={@command_open} on_search="search_commands">
  <.command_input placeholder="Search commands…" />
  <.command_list>
    <.command_item :for={cmd <- @commands} value={cmd.id} on_select="run_command">
      <.icon name={cmd.icon} size={:sm} /> {cmd.label}
    </.command_item>
  </.command_list>
</.command>
```

### Data & Analytics

```heex
<%!-- KPI metric grid --%>
<.metric_grid cols={4}>
  <.stat_card title="MRR"   value="$48,290" trend="up"      trend_value="+12.5%" />
  <.stat_card title="Users" value="2,840"   trend="up"      trend_value="+8.2%" />
  <.stat_card title="Churn" value="3.1%"    trend="down"    trend_value="-0.4%" />
  <.stat_card title="NPS"   value="67"      trend="neutral" trend_value="0" />
</.metric_grid>

<%!-- ECharts integration --%>
<.phia_chart
  id="revenue-chart"
  type={:area}
  title="Monthly Revenue"
  series={[%{name: "MRR", data: @mrr_data}]}
  labels={@month_labels}
  height="320px"
/>

<%!-- Streamable data table --%>
<.table id="users-table" rows={@streams.users}>
  <:col :let={user} label="Name">{user.name}</:col>
  <:col :let={user} label="Email">{user.email}</:col>
  <:col :let={user} label="Role"><.badge>{user.role}</.badge></:col>
  <:action :let={user}>
    <.button variant="ghost" size="sm" phx-click="edit" phx-value-id={user.id}>Edit</.button>
  </:action>
</.table>

<%!-- Sparkline widget --%>
<.sparkline_card
  title="Weekly signups"
  value="284"
  trend="up"
  trend_value="+18%"
  data={@weekly_signups}
/>

<%!-- Gauge --%>
<.gauge_chart value={72} min={0} max={100} label="CPU Usage" unit="%" />
```

### Calendar Suite

```heex
<%!-- Simple date picker --%>
<.date_picker field={@form[:start_date]} label="Start date" />

<%!-- Booking calendar with time slots --%>
<.booking_calendar
  id="appointment-calendar"
  available_dates={@available_dates}
  selected_date={@selected_date}
  on_date_select="select_date"
/>

<.time_slot_grid
  id="time-slots"
  slots={@time_slots}
  selected={@selected_slot}
  on_select="select_slot"
/>

<%!-- Full-page calendar --%>
<.big_calendar
  id="main-calendar"
  events={@events}
  view={@calendar_view}
  current_date={@current_date}
  on_view_change="change_view"
  on_date_click="open_day"
  on_event_click="open_event"
/>

<%!-- Week view with positioned events --%>
<.calendar_week_view
  id="week-view"
  week_start={@week_start}
  events={@week_events}
  on_slot_click="new_event"
/>

<%!-- Streak/habit tracker --%>
<.streak_calendar
  data={@habit_data}
  current_streak={@current_streak}
  longest_streak={@longest_streak}
/>
```

### Notifications

```heex
<%!-- Toast — mount once in root.html.heex --%>
<.toast id="toast-viewport" />
```

```elixir
# Trigger from any LiveView event handler
{:noreply,
 socket
 |> push_event("phia-toast", %{
   title: "File saved",
   description: "document.pdf saved successfully.",
   variant: "success"
 })}
```

```heex
<%!-- Sonner (rich toast stack) — mount once in root.html.heex --%>
<.sonner id="sonner-viewport" position="bottom-right" />
```

```elixir
# Push a Sonner toast
{:noreply, push_event(socket, "phia-sonner", %{
  message: "Changes published",
  type: "success",
  action: %{label: "Undo", event: "undo_publish"}
})}
```

```heex
<%!-- Snackbar — inline temporary notification --%>
<.snackbar id="save-snackbar" open={@snackbar_open} auto_dismiss={3000}>
  Draft saved automatically
  <:action phx-click="dismiss_snackbar">Dismiss</:action>
</.snackbar>
```

### Feedback

```heex
<%!-- Spinner --%>
<.spinner size={:md} label="Loading data…" />

<%!-- Skeleton placeholders --%>
<div class="space-y-3">
  <.skeleton class="h-4 w-3/4" />
  <.skeleton class="h-4 w-1/2" />
  <.skeleton class="h-32 w-full" />
</div>

<%!-- Progress bar --%>
<.progress value={@upload_progress} max={100} aria-label="Upload progress" />

<%!-- Circular progress --%>
<.circular_progress value={68} size={80} stroke_width={8} label="68%" />

<%!-- Empty state --%>
<.empty_state>
  <:icon><.icon name="inbox" class="h-12 w-12 text-muted-foreground" /></:icon>
  <:title>No results found</:title>
  <:description>Try adjusting your filters or search terms.</:description>
  <:action>
    <.button phx-click="reset_filters">Clear filters</.button>
  </:action>
</.empty_state>

<%!-- Step tracker --%>
<.step_tracker>
  <.step status="complete" label="Account"  step={1} />
  <.step status="active"   label="Profile"  step={2} description="Fill in your details" />
  <.step status="upcoming" label="Confirm"  step={3} />
</.step_tracker>
```

---

## Tutorials

Three end-to-end step-by-step guides that take you from a blank Phoenix LiveView project to a production-ready application.

### 1. Analytics Dashboard

**[docs/guides/tutorial-dashboard.md](docs/guides/tutorial-dashboard.md)**

Build a full enterprise analytics dashboard with a Shell layout (sidebar + topbar), KPI metric cards (StatCard, MetricGrid), live ECharts area and bar charts (PhiaChart), a streamable sortable data table (DataGrid), a Ctrl+K command palette, dark mode toggle, and real-time push_event updates. Covers `phx-update="stream"`, server-side sorting, and hook registration.

### 2. Booking Platform

**[docs/guides/tutorial-booking.md](docs/guides/tutorial-booking.md)**

Build a complete appointment booking flow: BookingCalendar for date selection, TimeSlotGrid for slot availability, StepTracker wizard (date → slot → details → confirm), form validation with Ecto changesets, PhiaInput with live error feedback, AlertDialog for cancellation confirmation, and Sonner toast notifications on booking success or failure.

### 3. Content Management System

**[docs/guides/tutorial-cms.md](docs/guides/tutorial-cms.md)**

Build a CMS with a RichTextEditor for content authoring, DataGrid with sortable columns and BulkActionBar for bulk publish/archive/delete, KanbanBoard for editorial pipeline management, ActivityFeed for audit log, FilterBuilder for advanced content search, Tree for taxonomy/category management, and Drawer side panel for record editing.

---

## Documentation

| File | Description |
|------|-------------|
| [docs/components/buttons.md](docs/components/buttons.md) | Button, ButtonGroup, BackTop, CopyButton, FloatButton, Toggle, ToggleGroup |
| [docs/components/calendar.md](docs/components/calendar.md) | All 33 calendar and scheduling components |
| [docs/components/cards.md](docs/components/cards.md) | Card, MetricGrid, ReceiptCard, SelectableCard, StatCard |
| [docs/components/data.md](docs/components/data.md) | BulkActionBar, Chart, ChartShell, DataGrid, FilterBar, FilterBuilder, GanttChart, GaugeChart, KanbanBoard, SparklineCard, Table, Tree, UptimeBar |
| [docs/components/display.md](docs/components/display.md) | ActivityFeed, Avatar, AvatarGroup, Badge, ChatMessage, DarkModeToggle, Direction, Icon, Kbd, ThemeProvider, Timeline |
| [docs/components/feedback.md](docs/components/feedback.md) | Alert, AlertDialog, CircularProgress, EmptyState, Progress, Skeleton, Snackbar, Sonner, Spinner, StepTracker, Toast |
| [docs/components/forms.md](docs/components/forms.md) | Field, Form, FormField, Label |
| [docs/components/inputs.md](docs/components/inputs.md) | All 24 input components |
| [docs/components/layout.md](docs/components/layout.md) | Accordion, AspectRatio, Collapsible, Resizable, ScrollArea, Separator, Shell |
| [docs/components/media.md](docs/components/media.md) | AudioPlayer, Carousel, QrCode |
| [docs/components/navigation.md](docs/components/navigation.md) | BottomNavigation, Breadcrumb, Menubar, MobileSidebarToggle, NavigationMenu, Pagination, Sidebar, Tabs, TabsNav, Toolbar, Topbar |
| [docs/components/overlay.md](docs/components/overlay.md) | Command, ContextMenu, Dialog, Drawer, DropdownMenu, HoverCard, Popover, Sheet, Tooltip |
| [docs/guides/theme-system.md](docs/guides/theme-system.md) | CSS-first theming, 8 OKLCH color presets, dark mode, runtime switching, ThemeProvider, anti-FOUC |
| [docs/guides/tutorial-dashboard.md](docs/guides/tutorial-dashboard.md) | Step-by-step analytics dashboard tutorial |
| [docs/guides/tutorial-booking.md](docs/guides/tutorial-booking.md) | Step-by-step booking platform tutorial |
| [docs/guides/tutorial-cms.md](docs/guides/tutorial-cms.md) | Step-by-step CMS tutorial |

Generate ExDoc API reference locally:

```bash
mix docs
```

---

## Theming

PhiaUI ships 8 OKLCH color presets: `zinc`, `slate`, `blue`, `rose`, `orange`, `green`, `violet`, `neutral`.

Generate the multi-theme CSS:

```bash
mix phia.theme install
# Writes assets/css/phia-themes.css with all 8 [data-phia-theme] selectors
# Auto-imports it in app.css
```

Activate a preset at the HTML level:

```html
<html class="dark" data-phia-theme="blue">
```

Scope a theme to a specific section:

```heex
<.theme_provider theme={:rose}>
  <.button>Rose button</.button>
</.theme_provider>
```

Enable runtime theme switching with the `PhiaTheme` hook:

```heex
<select phx-hook="PhiaTheme" id="theme-select">
  <option value="zinc">Zinc</option>
  <option value="blue">Blue</option>
  <option value="rose">Rose</option>
  <option value="green">Green</option>
</select>
```

Dark mode is toggled by adding/removing the `.dark` class on `<html>` via the `PhiaDarkMode` hook. To prevent flash of unstyled content, add this script to `<head>` before any stylesheet:

```html
<script>
  (function() {
    var mode = localStorage.getItem('phia-mode');
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

## License

MIT — see [LICENSE](LICENSE).
