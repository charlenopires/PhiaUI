# Changelog

All notable changes to PhiaUI are documented here.

## 0.0.1 — 2026-03-03

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
