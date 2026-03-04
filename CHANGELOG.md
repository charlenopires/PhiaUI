# Changelog

All notable changes to PhiaUI are documented here.

## 0.1.3 — 2026-03-03

### Added — 25 new components across 3 sessions (image-analysis driven gap analysis)

#### Enterprise Components — 10 components

- **ActivityFeed** (`activity_feed/1`, `activity_group/1`, `activity_item/1`) — Chronological event log with 6 activity types (`mention`, `file`, `call`, `task`, `reaction`, `system`), optional `:avatar` slot, `data-activity-type` attribute, `role="log"` container, `:footer` slot. 41 tests.

- **HeatmapCalendar** (`heatmap_calendar/1`) — GitHub-style contribution heatmap. Accepts raw `data` map `%{{col, row} => integer}`, `max_value`, configurable `rows`/`cols`, axis labels, and optional legend. Intensity classes `heatmap-0` through `heatmap-4`. `role="grid"` + `role="gridcell"` + `aria-label` per cell. 21 tests.

- **KanbanBoard** (`kanban_board/1`, `kanban_column/1`, `kanban_card/1`) — Multi-column project board. Cards support `priority` (`critical`, `high`, `medium`, `low`) with color-coded left border. Slots: `:avatar`, `:tags`, `:footer`. `data-priority` attribute on each card. 38 tests.

- **ChatMessage** (`chat_container/1`, `chat_message/1`, `chat_bubble/1`, `chat_suggestions/1`, `chat_input/1`) — Full AI/human chat UI. `role="log"` + `aria-live="polite"` on container. Roles: `user` (right, `bg-primary`), `assistant` (left, `bg-muted`), `system` (centered). Avatar slot, thumbs up/down feedback buttons (`phx-value-message-id`), timestamp, suggestion chips, compose form with `:attachments` slot and `max_chars` counter. 49 tests.

- **MentionInput** (`mention_input/1`, `mention_dropdown/1`, `mention_chip/1`) — `@mention` textarea with `PhiaMentionInput` JS hook. `role="combobox"` + `aria-expanded` on textarea. Dropdown uses `role="listbox"` / `role="option"`. Hidden `_ids` CSV input for form submission. Server-side suggestions driven by `pushEvent`. `mention_chip/1` for static server-rendered previews. 35 tests + JS hook.

- **FilterBar** (`filter_bar/1`, `filter_search/1`, `filter_select/1`, `filter_toggle/1`, `filter_reset/1`) — Horizontal filter toolbar for tables. Search input with magnifier icon (`phx-change`), labelled native select (`phx-change`), checkbox toggle (`phx-change`), reset button (`phx-click`). CSS-only, no JS hook. 38 tests.

- **FilterBuilder** (`filter_builder/1`, `filter_rule/1`) — Dynamic query builder. Each rule row: field selector + operator selector + value input + remove button. Operators and value input type adapt automatically to field type (`text`, `select`, `date`, `number`). Entirely server-driven — no JS hook. 26 tests.

- **BulkActionBar** (`bulk_action_bar/1`, `bulk_action/1`) — Contextual action toolbar for table row selection. Hidden when `count == 0` (two function heads). Shows "N label" + clear button + action slot. `role="toolbar"` + `aria-label`. `bulk_action/1` has `default` and `destructive` variants, optional icon. 25 tests.

- **StepTracker** (`step_tracker/1`, `step/1`) — Multi-step wizard progress indicator. Status variants: `complete` (bg-primary + check icon), `active` (bg-primary + ring + `aria-current="step"`), `upcoming` (outlined border, muted text). Horizontal and vertical orientations. Optional step number, description. CSS-only. 26 tests.

- **NavigationMenu** (`navigation_menu/1`, `navigation_menu_list/1`, `navigation_menu_item/1`, `navigation_menu_link/1`, `navigation_menu_trigger/1`, `navigation_menu_content/1`) — Horizontal nav bar. Links use `aria-current="page"` when active. Trigger button has `aria-haspopup="true"` + chevron icon. Content is an absolute-positioned dropdown panel. CSS-only layout. 32 tests.

#### Form Primitives — 8 components

- **Progress** (`progress/1`) — `role="progressbar"`, `aria-valuenow`, `aria-valuemin`, `aria-valuemax`. Indeterminate mode (no value). CSS-only. 22 tests.
- **Separator** (`separator/1`) — Horizontal / vertical `<hr>` divider. `role="separator"`, `aria-orientation`. `decorative` attr removes from accessibility tree. 16 tests.
- **Toggle** (`toggle/1`) — `aria-pressed` toggle button. Variants: `default`, `outline`. Sizes: `default`, `sm`, `lg`. 19 tests.
- **Switch** (`switch/1`, `form_switch/1`) — CSS-animated toggle switch. `role="switch"`. `form_switch/1` integrates with `Phoenix.HTML.FormField`. 22 tests.
- **ToggleGroup** (`toggle_group/1`, `toggle_group_item/1`) — Single/multiple selection group. `:let` context passes `{group}` to items for spread. 17 tests.
- **RadioGroup** (`radio_group/1`, `radio_group_item/1`, `form_radio_group/1`) — Native radio inputs with label. `:let` context. FormField integration. 23 tests.
- **Tabs** (`tabs/1`, `tabs_list/1`, `tabs_trigger/1`, `tabs_content/1`) — Server-rendered tabbed interface. `:let` context passes `active` to triggers and content panels. `aria-selected` on active trigger. 24 tests.
- **Sheet** (`sheet/1`, `sheet_trigger/1`, `sheet_content/1`, `sheet_header/1`, `sheet_footer/1`, `sheet_close/1`) — Modal panel with 4 directions (`top`, `bottom`, `left`, `right`) and 5 sizes. Reuses `PhiaDialog` hook. 56 tests.
- **HoverCard** (`hover_card/1`, `hover_card_trigger/1`, `hover_card_content/1`) — `role="tooltip"` preview card on hover/focus. CSS-only positioning. 22 tests.
- **ScrollArea** (`scroll_area/1`) — Custom scrollbar overlay. Three orientations: `vertical`, `horizontal`, `both`. CSS-only. 18 tests.

#### Visual Primitives — 5 components

- **Slider** (`slider/1`, `form_slider/1`) — CSS-styled `<input type="range">` using `accent-primary`. WAI-ARIA `role="slider"`. FormField integration. 45 tests.
- **Resizable** (`resizable/1`, `resizable_panel/1`, `resizable_handle/1`) — Drag-to-resize panel pairs. `PhiaResizable` JS hook (drag, touch, keyboard ← →). Horizontal/vertical split. 35 tests.
- **Timeline** (`timeline/1`, `timeline_item/1`) — Vertical activity timeline with CSS connector line. Status variants: `complete`, `active`, `upcoming`. Icon slot. 32 tests.
- **Rating** (`rating/1`, `form_rating/1`) — CSS-only star rating using hidden radio inputs + `checked` boolean attr. `role="radiogroup"`. FormField integration. 40 tests.
- **Kbd** (`kbd/1`) — Semantic `<kbd>` element for keyboard shortcut display. 9 tests.

#### New JS Hooks

- `PhiaResizable` — drag-to-resize panel handles, touch support, keyboard nudge
- `PhiaMentionInput` — `@` detection, `pushEvent(onMention, {query})`, `insertMention(id, name)`

### Bug Fixes

- Fixed 3 pre-existing test failures: version test (0.1.0 → current), package files (assets → lib), `PhiaUi.hello/0` undefined

### Test Coverage

- **2564 tests total** — 0 failures
- All 25 new components: 0 failures
- `mix credo --strict` — 0 issues
- `mix format --check-formatted` ✅

---

### Theme System v2 — CSS-first Architecture (also 0.1.3)

Complete architectural refactoring of the theme system inspired by DaisyUI's data-attribute pattern,
eliminating runtime `<style>` injection in favour of a static pre-generated CSS file.

#### New: `mix phia.theme install`

Generates `assets/css/phia-themes.css` with all 8 built-in themes, each under its own
`[data-phia-theme="name"]` CSS attribute selector. Automatically injects `@import "./phia-themes.css"`
into `assets/css/app.css` (idempotent). Options:

- `--output PATH` — custom output path (default: `assets/css/phia-themes.css`)
- `--themes a,b,c` — generate only a subset of presets

#### Improved: `mix phia.theme list`

Added PRIMARY (light) column showing the OKLCH primary color value for each preset.

#### Improved: `mix phia.theme export`

New `--format css` option: exports a theme as `[data-phia-theme="name"]` CSS selectors instead of JSON.

#### New: `ThemeCSS.generate/2` with opts

Extended `generate/2` with keyword options:
- `selector:` — override `:root` (default)
- `dark_selector:` — override `.dark` (default)
- `include_theme_block:` — include/exclude `@theme {}` block (default: `true`)

Backward-compatible: `generate(theme)` still works identically.

#### New: `ThemeCSS.generate_for_selector/1`

Generates CSS using `[data-phia-theme="name"]` and `.dark [data-phia-theme="name"]` selectors.
No `@theme` block — designed for the multi-theme file.

#### New: `ThemeCSS.generate_all/1`

Generates a complete CSS file with all themes as attribute selectors. Accepts a list of atoms
(`:zinc`, `:blue`), `%Theme{}` structs, or `nil` (defaults to all presets).

#### Refactored: `ThemeProvider` component

**Breaking change (minor):** `<.theme_provider theme={:blue}>` no longer injects a `<style>` tag.
Instead, it sets `data-phia-theme="blue"` on the wrapper div. CSS custom properties cascade
automatically from `phia-themes.css`.

**Migration:** Run `mix phia.theme install` to generate the CSS file, then import it in `app.css`.
Existing templates using `<.theme_provider theme={:blue}>` work without modification.

#### New: `PhiaTheme` JS Hook

New hook in `priv/templates/js/hooks/theme.js` for runtime color preset switching.

- Supports `<button phx-hook="PhiaTheme" data-theme="blue">` (click event)
- Supports `<select phx-hook="PhiaTheme">` (change event)
- Persists preference in `localStorage['phia-color-theme']`
- Sets `data-phia-theme` attribute on `<html>` element
- Dispatches `phia:color-theme-changed` CustomEvent

#### Updated: `PhiaDarkMode` JS Hook

- Now writes `phia-mode` (new canonical key) and `phia-theme` (retained for backward compatibility)
- `phia:theme-changed` event detail now includes `mode` field alongside existing `theme` field
- Anti-FOUC snippet updated to restore both dark mode and color preset on page load

#### New components

- **TabsNav** (`tabs_nav/1`, `tabs_nav_item/1`) — Navigation tabs with 3 visual variants:
  `underline` (default, bottom border), `pills` (filled background), `segment` (segmented control).
  Fully accessible with `aria-current`, keyboard support. No JS hooks.

#### localStorage keys (updated)

| Key | Written by | Value |
|-----|-----------|-------|
| `phia-mode` | `PhiaDarkMode` | `"dark"` \| `"light"` (new canonical key) |
| `phia-theme` | `PhiaDarkMode` | same as `phia-mode` (legacy, retained for compat) |
| `phia-color-theme` | `PhiaTheme` | preset name (e.g., `"blue"`, `"zinc"`) |

#### Test coverage (theme)

- 113 new tests for theme system (ThemeCSS, ThemeProvider, mix phia.theme)

---

## 0.1.2 — 2026-03-03

### Theme System v2 — CSS-first Architecture

Complete architectural refactoring of the theme system inspired by DaisyUI's data-attribute pattern,
eliminating runtime `<style>` injection in favour of a static pre-generated CSS file.

#### New: `mix phia.theme install`

Generates `assets/css/phia-themes.css` with all 8 built-in themes, each under its own
`[data-phia-theme="name"]` CSS attribute selector. Automatically injects `@import "./phia-themes.css"`
into `assets/css/app.css` (idempotent). Options:

- `--output PATH` — custom output path (default: `assets/css/phia-themes.css`)
- `--themes a,b,c` — generate only a subset of presets

#### Improved: `mix phia.theme list`

Added PRIMARY (light) column showing the OKLCH primary color value for each preset.

#### Improved: `mix phia.theme export`

New `--format css` option: exports a theme as `[data-phia-theme="name"]` CSS selectors instead of JSON.

#### New: `ThemeCSS.generate/2` with opts

Extended `generate/2` with keyword options:
- `selector:` — override `:root` (default)
- `dark_selector:` — override `.dark` (default)
- `include_theme_block:` — include/exclude `@theme {}` block (default: `true`)

Backward-compatible: `generate(theme)` still works identically.

#### New: `ThemeCSS.generate_for_selector/1`

Generates CSS using `[data-phia-theme="name"]` and `.dark [data-phia-theme="name"]` selectors.
No `@theme` block — designed for the multi-theme file.

#### New: `ThemeCSS.generate_all/1`

Generates a complete CSS file with all themes as attribute selectors. Accepts a list of atoms
(`:zinc`, `:blue`), `%Theme{}` structs, or `nil` (defaults to all presets).

#### Refactored: `ThemeProvider` component

**Breaking change (minor):** `<.theme_provider theme={:blue}>` no longer injects a `<style>` tag.
Instead, it sets `data-phia-theme="blue"` on the wrapper div. CSS custom properties cascade
automatically from `phia-themes.css`.

**Migration:** Run `mix phia.theme install` to generate the CSS file, then import it in `app.css`.
Existing templates using `<.theme_provider theme={:blue}>` work without modification.

#### New: `PhiaTheme` JS Hook

New hook in `priv/templates/js/hooks/theme.js` for runtime color preset switching.

- Supports `<button phx-hook="PhiaTheme" data-theme="blue">` (click event)
- Supports `<select phx-hook="PhiaTheme">` (change event)
- Persists preference in `localStorage['phia-color-theme']`
- Sets `data-phia-theme` attribute on `<html>` element
- Dispatches `phia:color-theme-changed` CustomEvent

#### Updated: `PhiaDarkMode` JS Hook

- Now writes `phia-mode` (new canonical key) and `phia-theme` (retained for backward compatibility)
- `phia:theme-changed` event detail now includes `mode` field alongside existing `theme` field
- Anti-FOUC snippet updated to restore both dark mode and color preset on page load

#### New components

- **TabsNav** (`tabs_nav/1`, `tabs_nav_item/1`) — Navigation tabs with 3 visual variants:
  `underline` (default, bottom border), `pills` (filled background), `segment` (segmented control).
  Fully accessible with `aria-current`, keyboard support. No JS hooks.

#### localStorage keys (updated)

| Key | Written by | Value |
|-----|-----------|-------|
| `phia-mode` | `PhiaDarkMode` | `"dark"` \| `"light"` (new canonical key) |
| `phia-theme` | `PhiaDarkMode` | same as `phia-mode` (legacy, retained for compat) |
| `phia-color-theme` | `PhiaTheme` | preset name (e.g., `"blue"`, `"zinc"`) |

#### Test coverage

- 113 new tests for theme system (ThemeCSS, ThemeProvider, mix phia.theme)
- All tests pass: `mix test`
- `mix format --check-formatted` ✅
- `mix credo --strict` — no new issues

## 0.1.2 — 2026-03-03

### Added — 15 new components (5 agents × 3 parallel cycles)

#### Utilities & Layout — 5 components

- **AspectRatio** (`aspect_ratio/1`) — CSS padding-top trick maintains any aspect ratio (16:9, 4:3, 1:1, 21:9, 9:16) for images, videos, and arbitrary HTML. Zero JS. Attr `:ratio` accepts any float.
- **Direction** (`direction/1`) — Minimal LTR/RTL wrapper. Sets `dir` attribute on a `<div>` for multilingual applications. Useful for Arabic, Hebrew, and RTL content.
- **EmptyState** (`empty/1`) — Centered empty state with 4 optional named slots: `:icon`, `:title`, `:description`, `:action`. Works inside `<td colspan>` in tables.
- **Field** (`field/1`, `field_label/1`, `field_description/1`, `field_message/1`) — Standalone form field layout components that do NOT require `Phoenix.HTML.FormField`. Accept `:error` string directly. Ideal wrapper for Checkbox, Radio, Switch.
- **ButtonGroup** (`button_group/1`) — Groups multiple Button components into a unified toolbar bar. Orientation `:horizontal` (default) or `:vertical`. Uses CSS `[&>*]` selectors to remove duplicate borders and manage border-radius on first/last children.

#### Form Integration — 2 components

- **Checkbox** (`checkbox/1`, `form_checkbox/1`) — Native HTML `<input type="checkbox">` styled with Tailwind. Supports `:checked`, `:indeterminate` (data-state + `aria-checked="mixed"`), `:disabled`. `form_checkbox/1` integrates with `Phoenix.HTML.FormField` and displays Ecto errors. No custom JS hook.
- **Calendar** (`calendar/1`) — Server-rendered monthly grid with 7-column layout. Attrs: `:value` (`Date.t`), `:mode` (`"single"` | `"range"`), `:min`, `:max`, `:disabled_dates`. Navigation via `phx-click`. Range highlight with `bg-accent`. PhiaCalendar JS hook for keyboard navigation only (Arrow keys, Home, End, Enter). WAI-ARIA: `role="grid"`, `role="gridcell"`, `aria-selected`.

#### Interactive Components — 5 components

- **Collapsible** (`collapsible/1`, `collapsible_trigger/1`, `collapsible_content/1`) — Expand/collapse section using only `Phoenix.LiveView.JS`. Zero external hooks. State controlled by `:open` boolean. `aria-expanded`, `aria-controls` wired between trigger and content.
- **AlertDialog** (`alert_dialog/1`, `alert_dialog_header/1`, `alert_dialog_title/1`, `alert_dialog_description/1`, `alert_dialog_footer/1`, `alert_dialog_action/1`, `alert_dialog_cancel/1`) — Critical action confirmation modal. Uses `role="alertdialog"` and reuses `PhiaDialog` hook for focus trap. Destructive action variant applies `bg-destructive`.
- **Carousel** (`carousel/1`, `carousel_content/1`, `carousel_item/1`, `carousel_previous/1`, `carousel_next/1`) — CSS transform-based slide carousel with touch swipe, keyboard (`ArrowLeft`/`ArrowRight`), and loop mode. PhiaCarousel JS hook. WAI-ARIA: `role="region"`, `aria-roledescription="slide"`.
- **ContextMenu** (`context_menu/1`, `context_menu_trigger/1`, `context_menu_content/1`, `context_menu_item/1`, `context_menu_separator/1`, `context_menu_checkbox_item/1`, `context_menu_label/1`) — Right-click contextmenu event menu. PhiaContextMenu JS hook: smart viewport-aware positioning, click-outside close, `ArrowUp/Down/Enter/Escape` keyboard navigation. WAI-ARIA: `role="menu"`, `role="menuitem"`.
- **Drawer** (`drawer/1`, `drawer_trigger/1`, `drawer_content/1`, `drawer_header/1`, `drawer_footer/1`, `drawer_close/1`) — Slide-in modal panel from any edge. Directions: `"bottom"` (default, mobile sheet), `"top"`, `"left"`, `"right"`. PhiaDrawer JS hook: CSS transform animation, complete focus trap, Escape to close, backdrop click to close. WAI-ARIA: `role="dialog"`, `aria-modal="true"`.

#### Composed Components — 3 components

- **Avatar** (`avatar/1`, `avatar_image/1`, `avatar_fallback/1`, `avatar_group/1`) — Circular profile image with automatic fallback to initials on image load error (inline `onerror` JS, no external hook). 4 sizes (`sm`, `default`, `lg`, `xl`). `avatar_group/1` stacks avatars with negative spacing.
- **Combobox** (`combobox/1`, `form_combobox/1`) — Search-filtered select dropdown. Server-rendered options list filtered in real-time by search query. Check icon (✓) on selected item. `form_combobox/1` integrates with `Phoenix.HTML.FormField` via hidden input. ARIA: `aria-haspopup="listbox"`, `role="option"`.
- **DatePicker** (`date_picker/1`, `form_date_picker/1`) — Composing `calendar/1` inside a popover dropdown. Calendar SVG icon trigger, formatted date display via `Calendar.strftime/2`. `:format` attr customises display (default `"%d/%m/%Y"`). `form_date_picker/1` emits ISO 8601 via hidden input. Integrates with `Phoenix.HTML.FormField`.

### New JS Hooks

- `PhiaCalendar` — keyboard navigation for calendar grids
- `PhiaCarousel` — CSS transform slides, touch swipe, keyboard navigation
- `PhiaContextMenu` — right-click positioning, smart flip, keyboard menu navigation
- `PhiaDrawer` — slide animation, focus trap, Escape/backdrop handlers

### Documentation

- Added `docs/components/utilities.md` — Aspect Ratio, Direction, Empty State, Field, Button Group, Avatar
- Added `docs/guides/tutorial-dashboard.md` — Step-by-step tutorial: build a complete dashboard with PhiaUI

### Test Coverage

- 1574 tests total (+358 new tests from 15 components)
- All 15 new components: 0 failures
- `mix credo --strict` — 0 issues on all new components

## 0.1.1 — 2026-03-03

### Added

#### Infrastructure

- **ClassMerger** (`cn/1`) — native Tailwind class merger with ETS-backed GenServer cache; no external tw_merge dependency
- **ComponentRegistry** — central registry with 59 entries; `ComponentRegistry.all/0` is the source of truth for `mix phia.add` and `mix phia.list`
- **TemplateLinter** — compile-time EEx template validation
- **TailwindCSS v4 Theme** — `priv/static/theme.css` with `@theme` semantic tokens: OKLCH colour palette, radius scale, shadow scale, and `@custom-variant dark (&:where(.dark, .dark *))` for automatic dark mode
- **Mix tasks**: `phia.install` (copies JS hooks + CSS), `phia.add <component>` (ejects component files), `phia.list` (catalogue), `phia.icons` (copies Lucide sprite)

#### Primitive Components

- **Button** — 6 variants (`default`, `destructive`, `outline`, `secondary`, `ghost`, `link`), 4 sizes (`default`, `sm`, `lg`, `icon`)
- **Card** — composable anatomy: `card/1`, `card_header/1`, `card_title/1`, `card_description/1`, `card_content/1`, `card_footer/1`
- **Badge** — 4 variants (`default`, `secondary`, `destructive`, `outline`)
- **Table** — streams-compatible; 8 sub-components: `table/1`, `table_header/1`, `table_body/1`, `table_footer/1`, `table_row/1`, `table_head/1`, `table_cell/1`, `table_caption/1`
- **Icon** — Lucide SVG sprite integration; 4 sizes (`xs`, `sm`, `md`, `lg`)
- **Alert** — 2 variants (`default`, `destructive`); accessible `role="alert"`
- **Skeleton** — loading placeholder with animated pulse

#### Form Integration

- **Input** (`phia_input/1`) — label + input + description + error messages; `Phoenix.HTML.FormField` integration; `phx-debounce` support
- **Textarea** (`phia_textarea/1`) — multi-line form-integrated input with the same label/error anatomy
- **Select** (`phia_select/1`) — native `<select>` with `Phoenix.HTML.FormField` and error display
- **Form** — `form_field/1`, `form_label/1`, `form_message/1`; thin wrappers over `Phoenix.HTML.Form`
- **TagsInput** — PhiaTagsInput JS hook; CSV hidden input for form submission; keyboard-driven tag management
- **ImageUpload** — native Phoenix LiveView uploads API; drag-and-drop zone; preview thumbnails; no custom hook
- **RichTextEditor** — PhiaRichTextEditor JS hook; `contenteditable` + `document.execCommand` + Selection API; 14 toolbar commands; zero npm dependencies

#### Interactive Components

- **Dialog** — PhiaDialog JS hook; focus trap via `_focusable()` query; Escape key dismissal; scroll lock; auto-focus on open; WAI-ARIA `role="dialog"` with `aria-modal`
- **DropdownMenu** — PhiaDropdownMenu JS hook; smart viewport-aware positioning (flip top/bottom, left/right); click-outside dismissal; full arrow-key navigation; WAI-ARIA `role="menu"`
- **Accordion** — powered by `Phoenix.LiveView.JS` only (no external hook); single and multiple open modes; WAI-ARIA `role="region"` + `aria-expanded`
- **Tooltip** — PhiaTooltip JS hook; `getBoundingClientRect()` positioning with smart flip; WAI-ARIA `role="tooltip"`
- **Popover** — PhiaPopover JS hook; focus trap; smart flip positioning; click-outside close; WAI-ARIA `aria-expanded` / `aria-haspopup`
- **Command** (Ctrl+K global search) — PhiaCommand JS hook; fuzzy-search filtering; keyboard navigation (`↑↓ Enter Escape`); WAI-ARIA `role="combobox"` + `role="listbox"`
- **DateRangePicker** — PhieDateRangePicker JS hook; dual-month calendar; range highlight; keyboard navigation; `phx-change` integration

#### Navigation & Feedback

- **Breadcrumb** — accessible `<nav aria-label="Breadcrumb">` landmark; separator slot; truncation support
- **Pagination** — WAI-ARIA compliant `<nav>`; previous/next/page controls; `phx-click` integration
- **Toast** — PhiaToast JS hook; `push_event(socket, "show-toast", …)` → `handleEvent` in hook; 4 variants (`default`, `success`, `error`, `warning`); auto-dismiss with progress bar
- **DarkMode Toggle** — PhiaDarkMode JS hook; toggles `.dark` class on `<html>`; persists choice in `localStorage`; respects `prefers-color-scheme` on first load

#### Dashboard Shell

- **Shell** — CSS Grid `grid-cols-[240px_1fr] h-screen overflow-hidden` on desktop; Flexbox drawer layout on mobile; toggled via `Phoenix.LiveView.JS`
- **Sidebar** — brand slot, nav slot, footer slot; active link highlighting
- **Topbar** — full-width header slot; mobile hamburger trigger
- **MobileSidebarToggle** — `md:hidden` button that opens/closes the mobile sidebar drawer via `JS.toggle()`

#### Dashboard Widgets

- **StatCard** — trend indicator (`up` / `down` / `neutral`); icon slot; footer slot; coloured trend badge
- **MetricGrid** — responsive 1–4 column grid; wraps any `StatCard` children
- **ChartShell** — titled card wrapper for any chart library (ECharts, Chart.js, VegaLite)
- **Chart** — PhiaChart JS hook; `build_config/2` generates ECharts JSON from `:type` + `:labels`; `Jason.encode!/1` for `data-config`/`data-series` attributes; `push_event(socket, "update-chart-#{id}", …)` for live updates; dark mode via `phia:theme-changed` CustomEvent; falls back to Chart.js if ECharts is absent

#### DataGrid

- **DataGrid** — server-side sortable columns; streams-compatible; sort direction cycling (`asc → desc → none`); `phx-click` sort headers; WAI-ARIA `aria-sort`
