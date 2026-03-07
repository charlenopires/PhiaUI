# PhiaUI

**Enterprise-ready Phoenix LiveView component library — 343 components, inspired by shadcn/ui.**

Ejectable components with zero heavy JS dependencies, full WAI-ARIA accessibility, TailwindCSS v4 semantic tokens, and built-in analytics widgets, enterprise data components, full Calendar & Scheduling Suite, comprehensive Card Suite, and AI-ready chat UI for financial terminals, BI dashboards, booking platforms, and KPI monitors.

[![Hex.pm](https://img.shields.io/hexpm/v/phia_ui.svg)](https://hex.pm/packages/phia_ui)
[![Elixir](https://img.shields.io/badge/elixir-%3E%3D1.17-purple)](https://elixir-lang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## Why PhiaUI?

| Feature | **PhiaUI** | [DaisyUI](https://github.com/saadeghi/daisyui) | [Salad UI](https://github.com/bluzky/salad_ui) | [ShadCN/ui](https://github.com/shadcn-ui/ui) | [Doggo](https://github.com/woylie/doggo) | [Mishka Chelekom](https://github.com/mishka-group/mishka_chelekom) | [Primer Live](https://github.com/ArthurClemens/primer_live) |
|---------|:----------:|:-------:|:--------:|:---------:|:-----:|:---------------:|:-----------:|
| **Platform** | Phoenix LiveView | CSS / Any | Phoenix LiveView | React | Phoenix LiveView | Phoenix LiveView | Phoenix LiveView |
| **Components** | **343** | 40+ | ~30 | 50+ | 40+ | ~90 | ~40 |
| Copy-paste ownership | ✓ | ✗ | ✓ | ✓ | ✓ | ✓ | ✗ |
| LiveView-native (`phx-*`, streams) | ✓ | ✗ | ✓ | ✗ | ✓ | ✓ | ✓ |
| Zero npm runtime deps | ✓ | ✓ | Partial | ✗ | ✓ | ✓ | Partial |
| Full WAI-ARIA on all interactive | ✓ | Partial | Partial | ✓ | ✓ | Partial | Partial |
| Tailwind CSS v4 | ✓ | ✓ | Partial | Partial | ✗ | ✓ | ✗ |
| Dark mode | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| CSS-first theming & color presets | ✓ (8 OKLCH) | ✓ (20+) | ✗ | Partial | ✗ | Partial | ✗ |
| Ecto / FormField integration | ✓ | ✗ | ✓ | ✗ | ✓ | ✓ | ✓ |
| Enterprise dashboard shell | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| KPI / analytics widgets | ✓ (41 data) | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Native SVG chart suite | ✓ (16 charts) | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Full Calendar & Scheduling Suite | ✓ (33 components) | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Drag-and-drop (DnD) primitives | ✓ (14 components) | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Rich text / markdown editor | ✓ (19 components) | ✗ | ✗ | ✗ | ✗ | Partial | ✗ |
| Animation primitives | ✓ (22 components) | Partial | ✗ | ✗ | ✗ | ✗ | ✗ |
| Upload components | ✓ (8 upload) | ✗ | ✗ | ✗ | ✗ | Partial | ✗ |
| Special form inputs | ✓ (11 types) | ✗ | ✗ | ✗ | ✗ | Partial | ✗ |
| Typography system | ✓ (18 components) | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| AI / chat components | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Kanban + filter builder | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Ctrl+K command palette | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Menu Suite (Mega/Dock/SpeedDial) | ✓ (36 nav) | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |

> **DaisyUI** — CSS-only Tailwind plugin, framework-agnostic, ideal for rapid prototyping.
> **Salad UI** — shadcn/ui patterns for Phoenix LiveView, copy-paste via `mix salad.install`.
> **ShadCN/ui** — React/Next.js, Radix UI primitives, the inspiration behind PhiaUI's copy-paste model.
> **Doggo** — headless, unstyled, strict WAI-ARIA; bring your own CSS.
> **Mishka Chelekom** — feature-rich Phoenix LiveView kit, CLI-generated components, Tailwind v4.
> **Primer Live** — GitHub Primer design system for Phoenix LiveView, library dependency model.

---

## Component Library — 343 Components

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

---

### Animation — 22 components

CSS + canvas animation primitives for landing pages, dashboards, and interactive UIs. All components respect `prefers-reduced-motion` and require no npm dependencies.

| Component | Function | Description |
|-----------|----------|-------------|
| AnimatedBorder | `animated_border/1` | Rotating gradient border animation via CSS conic-gradient |
| Aurora | `aurora/1` | Animated northern-lights gradient backdrop |
| ConfettiBurst | `confetti_burst/1` | Canvas confetti explosion on mount — `PhiaConfetti` hook |
| DotPattern | `dot_pattern/1` | SVG repeating dot grid background pattern |
| FadeIn | `fade_in/1` | Opacity + translate entrance animation with configurable delay |
| Float | `float/1` | Gentle CSS floating/bobbing animation wrapper |
| GridPattern | `grid_pattern/1` | SVG repeating grid line background pattern |
| Marquee | `marquee/1` | Infinite horizontal scroll ticker — `PhiaMarquee` hook |
| MeteorShower | `meteor_shower/1` | CSS animated diagonal meteor streaks |
| NumberTicker | `number_ticker/1` | Animated number count-up from 0 to target — `PhiaNumberTicker` hook |
| Orbit | `orbit/1` | Elements orbiting a center point with CSS animation |
| ParticleBg | `particle_bg/1` | Canvas floating particles background — `PhiaParticleBg` hook |
| PulseRing | `pulse_ring/1` | Expanding pulse ring animation (notification beacon) |
| RippleBg | `ripple_bg/1` | Concentric ripple rings expanding from center |
| ShimmerText | `shimmer_text/1` | Gradient shimmer sweep across text |
| Spotlight | `spotlight/1` | Mouse-following spotlight overlay — `PhiaSpotlight` hook |
| TextScramble | `text_scramble/1` | Characters scramble then resolve to final text — `PhiaTextScramble` hook |
| TiltCard | `tilt_card/1` | 3D perspective tilt on mouse-move — `PhiaTiltCard` hook |
| Typewriter | `typewriter/1` | Character-by-character text typing animation — `PhiaTypewriter` hook |
| TypingIndicator | `typing_indicator/1` | Three-dot chat typing indicator animation |
| WaveLoader | `wave_loader/1` | Animated vertical wave bar loading indicator |
| WordRotate | `word_rotate/1` | Cycles through a list of words with fade transition — `PhiaWordRotate` hook |

→ [Full documentation](docs/components/animation.md)

---

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

### Cards — 20 components

Structured surface components covering the full spectrum of card patterns: metrics, content, marketing, e-commerce, dashboard, and utility cards. All zero-JS, pure Elixir/Tailwind, composing existing PhiaUI primitives.

#### Core card primitives

| Component | Function | Description |
|-----------|----------|-------------|
| Card | `card/1` | Composable card with header, content, and footer slots |
| MetricGrid | `metric_grid/1` | Responsive grid wrapper for multiple StatCards, configurable column count |
| ReceiptCard | `receipt_card/1` | Transaction/purchase receipt: line items, totals, merchant info, QR slot |
| SelectableCard | `selectable_card/1` | Card with checkbox/radio selection state, border highlight when selected |
| StatCard | `stat_card/1` | KPI card with value, trend indicator (up/down/neutral), and trend value |

#### Content cards (new in 0.1.6)

| Component | Function | Description |
|-----------|----------|-------------|
| ArticleCard | `article_card/1` | Blog/news card: cover image, category badge, date, excerpt, author avatar; optional `href` links title |
| CtaCard | `cta_card/1` | Call-to-action / empty-state card: illustration, headline, description, primary + secondary actions; 4 variants |
| FeatureCard | `feature_card/1` | Icon + title + description landing-page block; 3 variants (default/bordered/ghost), 2 icon positions (top/left) |
| ImageCard | `image_card/1` | Hero cover image card; 4 aspect ratios (video/square/wide/tall), optional gradient overlay, badge slot |
| ProfileCard | `profile_card/1` | User profile card: large avatar, name, role, bio, tags, actions; presence status dot; vertical/horizontal layout |
| TestimonialCard | `testimonial_card/1` | Quote + star rating (1–5) + author avatar + name + company; 3 variants (default/bordered/minimal) |

#### Dashboard & operational cards (new in 0.1.6)

| Component | Function | Description |
|-----------|----------|-------------|
| EventCard | `event_card/1` | Large date badge + title + time + location + stacked attendee avatars; 6 category colors |
| FileCard | `file_card/1` | File icon (by extension type) + filename + size + uploaded_at; default/compact variant; download href |
| NotificationCard | `notification_card/1` | Type icon + title + message + timestamp; 4 severity types (info/success/warning/error); dismissible |
| ProgressCard | `progress_card/1` | Title + progress bar; 4 variants (default/success/warning/destructive), 3 sizes; label override; icon slot |
| TeamCard | `team_card/1` | Member directory card: avatar + name + role + department + email; 3 variants (default/compact/horizontal) |

#### Utility & specialty cards (new in 0.1.6)

| Component | Function | Description |
|-----------|----------|-------------|
| ColorSwatchCard | `color_swatch_card/1` | Color block + name + hex value; 3 sizes; optional CopyButton (PhiaCopyButton hook); rgb/hsl display |
| LinkPreviewCard | `link_preview_card/1` | URL unfurl: favicon + site name + title + description + og-image; 3 variants (default/compact/minimal) |
| PricingCard | `pricing_card/1` | SaaS plan card: price, period, feature list (available/unavailable), CTA; highlighted variant with ring |
| ProductCard | `product_card/1` | E-commerce: product image, price, original price (crossed out), star rating, badge, sold-out state, add-to-cart |

→ [Full documentation](docs/components/cards.md)

---

### Data — 41 components

Enterprise data management: tables, grids, native SVG charts, Gantt, Kanban, advanced filters, and analytics widgets.

#### Core data components

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

#### Chart Suite (new in 0.1.7) — 16 native SVG charts

| Component | Function | Description |
|-----------|----------|-------------|
| AreaChart | `area_chart/1` | Filled area chart with optional stacking, gradient fill, CSS animation |
| BarChart | `bar_chart/1` | Vertical bar chart, grouped/stacked variants, axis labels, CSS animation |
| BubbleChart | `bubble_chart/1` | XY scatter chart with variable bubble radius for third dimension |
| BulletChart | `bullet_chart/1` | Horizontal bullet gauge with target marker and range bands |
| DonutChart | `donut_chart/1` | SVG pie with center hole, arc labels, and optional center slot |
| HeatmapChart | `heatmap_chart/1` | Calendar-style heatmap grid with intensity color scale |
| HistogramChart | `histogram_chart/1` | Frequency histogram with configurable bin count |
| LineChart | `line_chart/1` | Multi-series polyline chart with dot markers and animation |
| PieChart | `pie_chart/1` | SVG pie slices with arc labels and hover state |
| RadarChart | `radar_chart/1` | Spider/radar chart with filled polygon and axis grid |
| RadialBarChart | `radial_bar_chart/1` | Circular bar segments, useful for part-to-whole comparisons |
| ScatterChart | `scatter_chart/1` | XY scatter plot with configurable dot radius and axis ticks |
| SlopeChart | `slope_chart/1` | Before/after comparison chart with labeled slope lines |
| TimelineChart | `timeline_chart/1` | Horizontal event timeline with time axis |
| TreemapChart | `treemap_chart/1` | Squarified treemap for hierarchical proportional data |
| WaterfallChart | `waterfall_chart/1` | Cumulative running-total bar chart (bridge chart) |

#### Analytics widgets (new in 0.1.7)

| Component | Function | Description |
|-----------|----------|-------------|
| BadgeDelta | `badge_delta/1` | Trend badge with colored arrow: increase/decrease/unchanged |
| BarList | `bar_list/1` | Ranked list with inline horizontal bars and values |
| CategoryBar | `category_bar/1` | Segmented horizontal bar showing proportional category breakdown |
| ComparisonTable | `comparison_table/1` | Feature comparison matrix table (SaaS pricing style) |
| FunnelChart | `funnel_chart/1` | Conversion funnel with step labels, counts, and drop-off rates |
| Leaderboard | `leaderboard/1` | Ranked list with avatar, name, score, rank badge, and delta |
| MeterGroup | `meter_group/1` | Multiple labeled progress meters stacked or in a row |
| NpsWidget | `nps_widget/1` | Net Promoter Score input (0–10 scale) with legend labels |

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

### Feedback — 13 components

Loading states, alerts, notifications, progress indicators, and confirmation patterns.

| Component | Function | Description |
|-----------|----------|-------------|
| Alert | `alert/1` | 2 variants (default, destructive) with title and description sub-components |
| AlertDialog | `alert_dialog/1` | `role="alertdialog"`, destructive variant, shared `PhiaDialog` hook |
| CircularProgress | `circular_progress/1` | Radial SVG progress ring, customizable size/stroke/color, `role="progressbar"` |
| EmptyState | `empty_state/1` | Centered placeholder with icon, title, description, and action slots |
| Popconfirm | `popconfirm/1` | Inline confirmation popover before destructive actions (new in 0.1.7) |
| Progress | `progress/1` | Horizontal `role="progressbar"`, `aria-valuenow`, indeterminate mode |
| ResultState | `result_state/1` | Full-page outcome display: success/error/warning/info with icon and actions (new in 0.1.7) |
| Skeleton | `skeleton/1` | `animate-pulse` block placeholders for loading states |
| Snackbar | `snackbar/1` | Temporary bottom-of-screen notification banner, auto-dismiss, action slot |
| Sonner | `sonner/1` | Rich toast stack: icon variants, action button, promise integration — `PhiaSonner` hook |
| Spinner | `spinner/1` | CSS SVG animated loading indicator, 5 sizes, `role="status"` + `aria-live` |
| StepTracker | `step_tracker/1` | Multi-step wizard progress indicator, horizontal and vertical orientation |
| Toast | `toast/1` | `push_event`-driven auto-dismiss toast, stacking, 5 variants — `PhiaToast` hook |

→ [Full documentation](docs/components/feedback.md)

---

### Forms — 19 components

Form layout primitives and advanced layout patterns that integrate with `Phoenix.HTML.Form` and Ecto changesets.

#### Core form primitives

| Component | Function | Description |
|-----------|----------|-------------|
| Field | `field/1` | Standalone form field layout without Phoenix.HTML.FormField |
| Form | `form/1` | `phx-change` / `phx-submit` form wrapper |
| FormField | `form_field/1`, `form_label/1`, `form_message/1` | Composable label + input + error message primitives |
| Label | `label/1` | Accessible `<label>` with `for` attribute, required indicator |

#### Form layout components (new in 0.1.7)

| Component | Function | Description |
|-----------|----------|-------------|
| FormSection | `form_section/1` | Titled form section with optional description and divider |
| FormFieldset | `form_fieldset/1` | Grouped fieldset with legend, used for related inputs |
| FormGrid | `form_grid/1` | Responsive multi-column form grid |
| FormRow | `form_row/1` | Single horizontal row for side-by-side inputs |
| FormActions | `form_actions/1` | Standardized submit/cancel button row with alignment options |
| FormSummary | `form_summary/1` | Error summary block listing all validation errors |

#### Form selection components (new in 0.1.7)

| Component | Function | Description |
|-----------|----------|-------------|
| CheckboxGroup | `checkbox_group/1`, `checkbox_group_item/1`, `form_checkbox_group/1` | Grouped checkbox list with FormField integration |
| RadioCard | `radio_card/1`, `radio_card_group/1`, `form_radio_card_group/1` | Card-style radio option group with peer-checked ring highlight |
| Cascader | `cascader/1`, `form_cascader/1` | Multi-level cascading select — `PhiaCascader` hook |
| ButtonTransferList | `button_transfer_list/1` | Two-column available/selected transfer list with move buttons |

→ [Full documentation](docs/components/forms.md)

---

### Inputs — 43 components

Every input primitive with full Ecto / `Phoenix.HTML.FormField` integration, plus upload components and special input types.

#### Core inputs

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

#### Input wave (new in 0.1.7)

| Component | Function | Description |
|-----------|----------|-------------|
| AutocompleteInput | `autocomplete_input/1` | Text input with dropdown suggestion list, keyboard navigation |
| ClearableInput | `clearable_input/1` | Input with × clear button, controlled value |
| CopyInput | `copy_input/1` | Read-only input with integrated copy button |
| InlineSearch | `inline_search/1` | Compact search bar for in-page filtering |
| InputGroup | `input_group/1` | Composite input with prepend/append sections sharing a border |
| PhoneInput | `phone_input/1` | Phone number input with country dial-code selector |
| SearchInput | `search_input/1` | Search input with magnifier icon and optional clear button |
| TextareaCounter | `textarea_counter/1` | Textarea with remaining/max character counter |
| UnitInput | `unit_input/1` | Numeric input with unit selector dropdown (px/em/%, kg/lb, etc.) |
| UrlInput | `url_input/1` | URL input with protocol prefix badge |

#### Upload components (new in 0.1.7)

| Component | Function | Description |
|-----------|----------|-------------|
| AvatarUpload | `avatar_upload/1` | Avatar crop-upload: circular preview, click-to-replace, live_file_input |
| DocumentUpload | `document_upload/1` | Document upload zone with file type restriction and entry list |
| FullscreenDrop | `fullscreen_drop/1` | Full-viewport drag-and-drop overlay — `PhiaFullscreenDrop` hook |
| ImageGalleryUpload | `image_gallery_upload/1` | Multi-image grid upload with inline preview and remove |
| UploadButton | `upload_button/1` | Minimal button-triggered file upload |
| UploadCard | `upload_card/1` | File card preview with progress ring and cancel button |
| UploadProgress | `upload_progress/1` | Upload progress bar with filename, size, and cancel |
| UploadQueue | `upload_queue/1` | Ordered list of pending uploads with bulk cancel |

#### Special inputs (new in 0.1.7 — FormField integrated)

| Component | Function | Description |
|-----------|----------|-------------|
| ColorSwatchPicker | `color_swatch_picker/1`, `form_color_swatch_picker/1` | Click-to-select color swatch grid, FormField |
| CountrySelect | `country_select/1`, `form_country_select/1` | Country dropdown with flag emojis, FormField |
| CurrencyInput | `currency_input/1`, `form_currency_input/1` | Formatted monetary input with currency symbol prefix, FormField |
| FloatInput | `float_input/1`, `form_float_input/1` | Floating label text input, FormField |
| FloatTextarea | `float_textarea/1`, `form_float_textarea/1` | Floating label textarea, FormField |
| FormFeedback | `form_feedback/1` | Contextual feedback message with icon for valid/invalid state |
| FormStepper | `form_stepper/1`, `form_stepper_item/1` | Step-based wizard form with numbered item slots |
| InputStatus | `input_status/1` | Input status indicator (loading/valid/invalid icon suffix) |
| MaskedInput | `masked_input/1`, `form_masked_input/1` | Formatted mask input (phone, SSN, date, custom) — `PhiaMaskedInput` hook |
| RangeSlider | `range_slider/1`, `form_range_slider/1` | Dual-thumb range slider — `PhiaRangeSlider` hook |
| SignaturePad | `signature_pad/1` | Canvas signature drawing pad, outputs base64 PNG — `PhiaSignaturePad` hook |

→ [Full documentation](docs/components/inputs.md)

---

### Layout — 27 components

Structural composition components for panels, scroll areas, collapsible regions, and a full layout primitive suite.

#### Interactive layout

| Component | Function | Description |
|-----------|----------|-------------|
| Accordion | `accordion/1` | Single or multiple expand mode via `Phoenix.LiveView.JS`, zero hooks |
| AspectRatio | `aspect_ratio/1` | CSS padding-top ratio trick, any ratio (16:9, 4:3, 1:1, etc.) |
| Collapsible | `collapsible/1` | Single-panel expand/collapse, server-controlled open state via `Phoenix.LiveView.JS` |
| Resizable | `resizable/1` | Drag-to-resize split panels — `PhiaResizable` hook |
| ScrollArea | `scroll_area/1` | Custom scrollbar overlay, horizontal / vertical / both orientations |
| Separator | `separator/1` | Horizontal or vertical divider, `role="separator"` |
| Shell | `shell/1` | CSS Grid desktop layout: fixed sidebar 240px + fluid main 1fr |

#### Layout primitives (new in 0.1.5)

| Component | Function | Description |
|-----------|----------|-------------|
| Box | `box/1` | Generic block container, any HTML tag via `:as` attr |
| Center | `center/1` | Flex centering wrapper, horizontal-only or both axes |
| Container | `container/1` | Responsive max-width wrapper with configurable size and padding |
| DescriptionList | `description_list/1` | `<dl>` with responsive term/detail layout |
| Divider | `divider/1` | Horizontal or vertical divider with optional label text |
| FixedBar | `fixed_bar/1` | Fixed-position top/bottom bar for persistent UI chrome |
| Flex | `flex/1` | Flex container with gap, direction, align, justify props |
| Grid | `grid/1` | CSS Grid container with configurable cols, rows, and gap |
| MasonryGrid | `masonry_grid/1` | CSS column-count masonry layout |
| MediaObject | `media_object/1` | Horizontal image/icon + text layout (email-client safe) |
| NavList | `nav_list/1` | Styled vertical navigation list with item and group slots |
| PageHeader | `page_header/1` | Page title + breadcrumb + action slot, consistent heading region |
| PageLayout | `page_layout/1` | Two-column or three-column content/sidebar page layout |
| SimpleGrid | `simple_grid/1` | Responsive equal-column grid, auto-fill/auto-fit |
| Spacer | `spacer/1` | Flex spacer / fixed-size gap element |
| SplitLayout | `split_layout/1` | Two-pane resizable split panel with configurable ratio |
| Stack | `stack/1` | Vertical flex stack with uniform gap |
| Sticky | `sticky/1` | `position: sticky` wrapper with configurable `top`/`bottom` |
| Wrap | `wrap/1` | Flex-wrap container for tag clouds, button groups, pill rows |

→ [Full documentation](docs/components/layout.md)

---

### Interaction — 14 components

Drag-and-drop primitives for sortable lists, Kanban workflows, and tree reordering. All use vanilla JS hooks with no npm dependencies.

| Component | Function | Description |
|-----------|----------|-------------|
| DragHandle | `drag_handle/1` | Grip icon handle for initiating drag operations |
| DropIndicator | `drop_indicator/1` | Visual line/zone indicator for valid drop targets |
| SortableList | `sortable_list/1`, `sortable_item/1` | Vertical drag-to-reorder list — `PhiaSortable` hook |
| SortableGrid | `sortable_grid/1`, `sortable_grid_item/1` | Grid drag-to-reorder layout — `PhiaSortableGrid` hook |
| KanbanBoard (DnD) | `kanban_board/1`, `kanban_column/1`, `kanban_card/1` | Full DnD Kanban with cross-column card dragging — `PhiaKanban` hook |
| DropZone | `drop_zone/1` | Generic file/item drop target with visual feedback — `PhiaDropZone` hook |
| DragTransferList | `drag_transfer_list/1` | Two-column drag-between-lists transfer — `PhiaDragTransferList` hook |
| MultiDragList | `multi_drag_list/1` | Multi-select drag list (shift-click + drag group) — `PhiaMultiDrag` hook |
| DraggableTree | `draggable_tree/1`, `draggable_tree_node/1` | Hierarchical tree with drag-to-reorder nodes — `PhiaDraggableTree` hook |

→ [Full documentation](docs/components/interaction.md)

---

### Media — 5 components

Audio playback, image carousels, QR code generation, image comparison, and watermarking.

| Component | Function | Description |
|-----------|----------|-------------|
| AudioPlayer | `audio_player/1` | Full media player: play/pause, scrubber, volume, duration display — `PhiaAudioPlayer` hook |
| Carousel | `carousel/1` | Touch-swipe, keyboard navigation, loop, dot indicators — `PhiaCarousel` hook |
| ImageComparison | `image_comparison/1` | Before/after image slider — `PhiaImageComparison` hook |
| QrCode | `qr_code/1` | Inline SVG QR code via `eqrcode`, configurable size and error correction level |
| Watermark | `watermark/1` | SVG tiled watermark overlay with configurable text, opacity, and angle |

→ [Full documentation](docs/components/media.md)

---

### Navigation — 23 components

Application chrome: sidebar, topbar, breadcrumbs, tabs, pagination, mobile navigation, and Menu Suite.

#### Core navigation

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

#### Menu Suite (new in 0.1.7)

| Component | Function | Description |
|-----------|----------|-------------|
| ActionSheet | `action_sheet/1` | Mobile-style bottom action sheet with icon items and cancel |
| AppShell | `app_shell/1` | Full-page app shell combining sidebar, topbar, and main region |
| ChipNav | `chip_nav/1` | Horizontal pill/chip navigation bar, active chip highlight |
| Dock | `dock/1` | macOS-style centered icon dock with tooltip labels |
| DotNavigation | `dot_navigation/1` | Minimal dot indicator navigation for carousels and slides |
| FloatingNav | `floating_nav/1` | Floating pill navigation bar, glass morphism style |
| MegaMenu | `mega_menu/1` | Full-width dropdown navigation panel with multi-column layout |
| NavLink | `nav_link/1` | Styled navigation anchor with active state and icon slot |
| SpeedDial | `speed_dial/1` | FAB-style expandable action menu with labeled icon items |
| VerticalNav | `vertical_nav/1` | Vertical navigation list with section groups and collapse |
| WizardNav | `wizard_nav/1` | Step-based wizard navigation header with progress indication |

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

### Editor — 19 components

Rich text editor toolkit: toolbar primitives, bubble and floating menus, markdown editor, and a full TipTap-inspired advanced editor. All components use vanilla JS hooks, no npm runtime required.

| Component | Function | Description |
|-----------|----------|-------------|
| AdvancedEditor | `advanced_editor/1` | Full-featured ProseMirror-inspired rich text editor — `PhiaAdvancedEditor` hook |
| BubbleMenu | `bubble_menu/1` | Floating selection toolbar that appears on text selection — `PhiaBubbleMenu` hook |
| EditorCharacterCount | `editor_character_count/1` | Live character and word count display |
| EditorCodeBlock | `editor_code_block/1` | Syntax-highlighted code block with language label |
| EditorColorPicker | `editor_color_picker/1` | Color picker for text/highlight formatting — `PhiaEditorColorPicker` hook |
| EditorFindReplace | `editor_find_replace/1` | Find-and-replace panel for inline text editing — `PhiaEditorFindReplace` hook |
| EditorLinkDialog | `editor_link_dialog/1` | Link insert/edit dialog with href and target inputs |
| EditorToolbar | `editor_toolbar/1` | Full-width formatting toolbar with grouped commands |
| EditorToolbarDropdown | `editor_toolbar_dropdown/1` | Dropdown menu for toolbar (heading level, font size) — `PhiaEditorDropdown` hook |
| EditorWordCount | `editor_word_count/1` | Word count display with reading time estimate |
| FloatingMenu | `floating_menu/1` | Contextual menu floating near the cursor position — `PhiaFloatingMenu` hook |
| InlineEdit | `inline_edit/1` | Click-to-edit inline text field, Enter to confirm |
| InlineEditGroup | `inline_edit_group/1` | Group of related inline-editable fields |
| MarkdownEditor | `markdown_editor/1` | Split-pane markdown editor + live HTML preview — `PhiaMarkdownEditor` hook |
| RichTextViewer | `rich_text_viewer/1` | Read-only HTML content renderer with prose typography |
| SlashCommandMenu | `slash_command_menu/1` | `/command` trigger menu for inserting blocks — `PhiaSlashCommand` hook |
| ToolbarButton | `toolbar_button/1` | Individual toolbar action button with active and disabled states |
| ToolbarGroup | `toolbar_group/1` | Visually grouped set of toolbar buttons with shared border |
| ToolbarSeparator | `toolbar_separator/1` | Vertical divider between toolbar groups |

→ [Full documentation](docs/components/editor.md)

---

### Typography — 18 components

Semantic typographic primitives covering headings, body text, code, quotes, links, and prose formatting.

| Component | Function | Description |
|-----------|----------|-------------|
| Abbr | `abbr/1` | `<abbr>` with dotted underline and title tooltip |
| Blockquote | `blockquote/1` | Left-bordered blockquote with optional citation |
| Caption | `caption/1` | Small caption text for figures, tables, and media |
| CodeBlock | `code_block/1` | Preformatted code block with language label and copy button |
| DisplayText | `display_text/1` | Extra-large hero display text, configurable size (xl–4xl) |
| GradientText | `gradient_text/1` | Text with CSS gradient fill, 6 preset directions |
| Heading | `heading/1` | Semantic `<h1>`–`<h6>` with consistent typographic scale |
| InlineCode | `inline_code/1` | `<code>` with monospace font and subtle background |
| Lead | `lead/1` | Introductory paragraph with larger line-height |
| Mark | `mark/1` | `<mark>` highlighted text span |
| OrderedList | `ordered_list/1` | Styled `<ol>` with decimal/roman/alpha variants |
| Overline | `overline/1` | Small uppercase spaced label above a heading |
| Paragraph | `paragraph/1` | Body paragraph with configurable size and lead spacing |
| Prose | `prose/1` | Prose container for long-form HTML content (article, blog, docs) |
| ProseList | `prose_list/1` | Styled unordered `<ul>` with custom bullets |
| Text | `text/1` | Inline `<span>` with semantic size, weight, and color variants |
| TextLink | `text_link/1` | Styled `<a>` with underline-on-hover and external icon |
| TruncatedText | `truncated_text/1` | Single or multi-line text truncation with configurable clamp |

→ [Full documentation](docs/components/typography.md)

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
    {:phia_ui, "~> 0.1.7"}
  ]
end
```

Fetch dependencies and run the installer:

```bash
mix deps.get
mix phia.install
```

The installer copies all JS hook files to `assets/js/phia_hooks/` and injects the base theme import into `app.css`.

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
| [docs/components/animation.md](docs/components/animation.md) | All 22 animation components — marquee, aurora, typewriter, particle_bg, etc. |
| [docs/components/buttons.md](docs/components/buttons.md) | Button, ButtonGroup, BackTop, CopyButton, FloatButton, Toggle, ToggleGroup |
| [docs/components/calendar.md](docs/components/calendar.md) | All 33 calendar and scheduling components |
| [docs/components/cards.md](docs/components/cards.md) | Card, StatCard, MetricGrid plus all 15 Card Suite components |
| [docs/components/data.md](docs/components/data.md) | 13 core data + 16 Chart Suite + 8 analytics widgets (41 total) |
| [docs/components/display.md](docs/components/display.md) | ActivityFeed, Avatar, AvatarGroup, Badge, ChatMessage, DarkModeToggle, Direction, Icon, Kbd, ThemeProvider, Timeline |
| [docs/components/editor.md](docs/components/editor.md) | All 19 editor components — EditorToolbar, BubbleMenu, MarkdownEditor, AdvancedEditor, etc. |
| [docs/components/feedback.md](docs/components/feedback.md) | Alert, AlertDialog, CircularProgress, EmptyState, Popconfirm, Progress, ResultState, Skeleton, Snackbar, Sonner, Spinner, StepTracker, Toast |
| [docs/components/forms.md](docs/components/forms.md) | Field, Form, FormField, Label + FormLayout (6) + FormSelects (9) |
| [docs/components/inputs.md](docs/components/inputs.md) | All 43 input components including uploads and special inputs |
| [docs/components/interaction.md](docs/components/interaction.md) | All 14 DnD components — SortableList, SortableGrid, KanbanBoard DnD, DraggableTree |
| [docs/components/layout.md](docs/components/layout.md) | 7 interactive layout + 20 Layout Suite primitives (27 total) |
| [docs/components/media.md](docs/components/media.md) | AudioPlayer, Carousel, ImageComparison, QrCode, Watermark |
| [docs/components/navigation.md](docs/components/navigation.md) | 11 core navigation + 12 Menu Suite components (23 total) |
| [docs/components/overlay.md](docs/components/overlay.md) | Command, ContextMenu, Dialog, Drawer, DropdownMenu, HoverCard, Popover, Sheet, Tooltip |
| [docs/components/typography.md](docs/components/typography.md) | All 18 typography components — Heading, Prose, CodeBlock, GradientText, etc. |
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
