# Changelog

All notable changes to PhiaUI are documented here.

## 0.1.6 — 2026-03-06

### Added — 15 new card components (Card Suite)

Full-spectrum card library covering content, marketing, dashboard, e-commerce, and utility patterns. Every component is zero-JS, pure Elixir/HEEx + TailwindCSS v4, composing existing PhiaUI primitives (Card, Badge, Avatar, Icon, Progress, Button, CopyButton). Registry grew from 139 to 154 entries — all implemented.

#### Content Cards (7 components)

- **ImageCard** (`image_card/1`) — Hero cover-image card. Full-bleed `<img>` with 4 aspect ratio options (`:video` → `aspect-video`, `:square` → `aspect-square`, `:wide` → `aspect-[2/1]`, `:tall` → `aspect-[3/4]`). Optional dark gradient overlay via CSS `after:` pseudo-element (`after:bg-gradient-to-t after:from-black/60`). Badge slot for overlaid labels (top-left, `absolute z-10`). Inner block renders as `card_content`. **12 tests**.

- **ProfileCard** (`profile_card/1`) — User profile card with two layout variants. `:vertical` (default): centered avatar + name + role + bio + tags + actions. `:horizontal`: flex-row with avatar left and content right. Avatar uses `PhiaUi.Components.Avatar` with size `:lg`. Presence status dot overlaid on avatar: `:online` → `bg-emerald-500`, `:offline` → `bg-gray-400`, `:busy` → `bg-red-500`, `:away` → `bg-amber-500`. Slots: `:bio`, `:tags`, `:actions`. **16 tests**.

- **FeatureCard** (`feature_card/1`) — Landing-page feature block: icon + title + description. Three card style variants: `:default` (border + shadow), `:bordered` (border-2, no shadow), `:ghost` (no border, no shadow — renders plain `<div>`). Two icon positions: `:top` (flex-col, icon above title) and `:left` (flex-row, icon beside text block). Slots: `:icon`, `:inner_block`. **14 tests**.

- **ArticleCard** (`article_card/1`) — Blog/news article card. Optional cover image (`aspect-video`), category badge, meta row (`date · read_time`), title (with optional `href` link), excerpt (`line-clamp-3`), and author row (avatar + name). All fields are optional except `:title`. **19 tests**.

- **TestimonialCard** (`testimonial_card/1`) — Customer testimonial card. Star rating 1–5 (Unicode `★`/`☆`), rendered only when `:rating` is set. Large decorative quotation mark (`text-6xl text-muted-foreground/20`). Italic quote body. Author row with optional avatar, name, role, and company. Three variants: `:default` (card + shadow), `:bordered` (card + border-2), `:minimal` (plain div, no card). **17 tests**.

- **PricingCard** (`pricing_card/1`) — SaaS pricing plan card. Attrs: `plan`, `price`, `period` (`/month`), `description`, `features` (list of strings; prefix `—` marks unavailable items). Feature list rendered with check icons (`text-emerald-500`) for available and `—` for unavailable items. `highlighted=true` applies `ring-2 ring-primary bg-primary/5`. Optional `badge` label (rendered above plan name). Full-width CTA button with `cta_href`. `disabled` state. Slots: `:header_extra`, `:footer`. **17 tests**.

- **ProductCard** (`product_card/1`) — E-commerce product card. Product image (`aspect-square`), optional `badge` overlay (top-left, configurable variant). Price with optional `original_price` (line-through). Star rating from float (0.0–5.0, rounded and rendered as `★`/`☆` text). Review count. `sold_out=true` disables CTA and shows "Sold Out" badge. Default CTA "Add to cart" with `on_add_to_cart` event, overridable via `:actions` slot. Optional `href` link on image/title. **15 tests**.

#### Dashboard & Operational Cards (5 components)

- **ProgressCard** (`progress_card/1`) — Goal / task progress card. Uses existing `<.progress>` component internally. Four color variants: `:default` (primary bar), `:success` (`[&>div]:bg-emerald-500`), `:warning` (`[&>div]:bg-amber-500`), `:destructive` (`[&>div]:bg-destructive`). Three progress bar sizes: `:sm` (h-1), `:md` (h-2), `:lg` (h-3). `show_value=false` hides the percentage label. `label` attr overrides the default `"N%"` display. Slots: `:icon` (in header), `:footer`. **18 tests**.

- **NotificationCard** (`notification_card/1`) — Notification / alert card. Left accent border (`border-l-4`) colored by type: `:info` (blue), `:success` (emerald), `:warning` (amber), `:error` (red). Type icon from Lucide sprite beside content. `read=true` applies `opacity-60`. `dismissible=true` shows an × button in the top-right corner with `phx-click={@on_dismiss}`. Timestamp row in `text-xs text-muted-foreground`. Slots: `:icon` (override default type icon), `:actions`. **20 tests**.

- **FileCard** (`file_card/1`) — File attachment card. Extension-based icon color coding via `file_type/1` pattern-matching: PDF → `bg-red-100 text-red-600`; DOC/DOCX → `bg-blue-100 text-blue-600`; XLS/XLSX → `bg-emerald-100 text-emerald-600`; PPT/PPTX → `bg-orange-100 text-orange-600`; images → `bg-violet-100 text-violet-600`; archives → `bg-yellow-100 text-yellow-600`; media → `bg-pink-100 text-pink-600`. Uppercase extension badge. Two variants: `:default` (stacked, larger icon) and `:compact` (single-row). `href` renders filename as `<a download>`. Slot: `:actions`. **22 tests**.

- **EventCard** (`event_card/1`) — Calendar event card with prominent date badge. Left-panel: colored by `category_color` (`:primary`, `:blue`, `:emerald`, `:amber`, `:rose`, `:violet`), shows 3-letter month abbrev + day number (3xl bold). Right panel: title, time row, location row (`map-pin` or `video-camera` icon based on `virtual`), stacked attendee avatars with `+N` overflow. `max_attendees` controls visible count. Slot: `:actions`. **20 tests**.

- **TeamCard** (`team_card/1`) — Team member directory card. Three layout variants: `:default` (centered avatar top, content below), `:compact` (smaller avatar, denser spacing), `:horizontal` (flex-row, avatar left, content right). Avatar from `PhiaUi.Components.Avatar`. Optional department badge, email link (`mailto:`). Slots: `:badges`, `:actions`. **15 tests**.

#### Utility & Specialty Cards (3 components)

- **LinkPreviewCard** (`link_preview_card/1`) — URL link-unfurl embed card (Slack/Twitter style). Domain extracted server-side via `URI.parse/1`. Three variants: `:default` (full card with optional og-image, favicon, site name, title, description, domain), `:compact` (single row: favicon + title + domain, no image), `:minimal` (plain title + domain, no border). External link icon (`external-link`) shown in `:default` and `:compact`. **16 tests**.

- **ColorSwatchCard** (`color_swatch_card/1`) — Color palette swatch card. Color block at top with `style="background-color: #{hex}"`. Three sizes: `:sm` (h-16), `:md` (h-24), `:lg` (h-32). Color name (`text-sm font-medium`) below block. Hex value in monospace (`text-xs text-muted-foreground`). `copyable=true` renders `<.copy_button>` using existing `PhiaCopyButton` hook. Optional `rgb` and `hsl` secondary rows. Slot: `:tags`. **14 tests**.

- **CtaCard** (`cta_card/1`) — Call-to-action / empty-state / onboarding card. Four variants: `:default` (border + shadow), `:bordered` (border-2), `:filled` (`bg-muted`), `:minimal` (plain `<div>`, no card chrome). Two alignment modes: `:center` (`text-center items-center`) and `:start` (`text-start items-start`). Slots: `:illustration` (icon, SVG, or image above title), `:actions` (primary + secondary buttons), `:footer` (fine print). **16 tests**.

### Test Coverage

- **344 new tests** across 15 new components — **0 failures**
- **4604+ total tests** — **0 new failures** (2 pre-existing failures in unrelated tests)
- Component registry: **154 entries** (139 → 154, all implemented)
- `mix credo --strict` — 0 issues

---

## 0.1.5 — 2026-03-05

### Added — 44 new components (Calendar Suite + Advanced Widgets + Media)

Largest release to date. Multi-session image-analysis, gap analysis vs Full Calendar, Eleken design system, Ant Design, and Mantine. Registry grew from 75 to 119 entries — all implemented.

#### Calendar & Scheduling Suite — Wave 8: Standard Date/Time Pickers (6 components)

- **TimePicker** (`time_picker/1`, `form_time_picker/1`) — Clock-face or scroll-wheel time selector. 12h/24h mode, configurable minute step (1/5/15/30), AM/PM toggle. `role="group"` with labelled hour/minute/period spinbuttons. FormField integration. **24 tests**.

- **DateTimePicker** (`date_time_picker/1`, `form_date_time_picker/1`) — Combined calendar + time picker rendered in a popover. Outputs ISO 8601 (`"2026-03-05T14:30:00"`). TimePicker embedded below calendar grid. FormField integration. **22 tests**.

- **MonthPicker** (`month_picker/1`, `form_month_picker/1`) — Grid of 12 abbreviated month names, year navigation arrows. `aria-selected` on selected month. FormField outputs `"YYYY-MM"`. **18 tests**.

- **YearPicker** (`year_picker/1`, `form_year_picker/1`) — Scrollable year grid ±10 years from current, `min`/`max` bounds. `aria-selected`. FormField outputs `"YYYY"`. **16 tests**.

- **WeekPicker** (`week_picker/1`, `form_week_picker/1`) — ISO 8601 week selector. Calendar grid highlights entire selected week on hover/selection. FormField outputs `"YYYY-Www"`. **20 tests**.

- **DateField** (`date_field/1`, `form_date_field/1`) — Segmented DD / MM / YYYY input. Each segment is an independent `<input type="number">` with `inputmode="numeric"`. Arrow keys increment/decrement, Tab advances to next segment. `aria-label="Day"`, `aria-label="Month"`, `aria-label="Year"`. FormField integration. **26 tests**.

#### Calendar & Scheduling Suite — Wave 8 additional: WeekDayPicker

- **WeekDayPicker** (`week_day_picker/1`) — Mon–Sun pill toggles for recurrence rule UIs. Multi-select with `aria-pressed`. Abbreviated labels (`Mo`, `Tu`, `We`…). Hidden `name[]` inputs for form submission. **14 tests**.

#### Calendar & Scheduling Suite — Wave 9: Calendar Compositions (2 components)

- **CalendarTimePicker** (`calendar_time_picker/1`) — Full-month calendar grid + inline time picker rendered as a single coherent widget. Outputs combined `Date` + `Time` via separate hidden inputs. `calendar_time_picker_nav/1` sub-component handles month navigation. **20 tests**.

- **DateRangePresets** (`date_range_presets/1`) — `DateRangePicker` augmented with a preset sidebar: Today, Yesterday, This Week, Last 7 Days, Last 30 Days, This Month, Last Month, This Year, Custom. Preset buttons call `on_change` with start/end dates. Fully composable via `:presets` slot for custom entries. **22 tests**.

#### Calendar & Scheduling Suite — Wave 10: Full-Page Calendar (1 component)

- **BigCalendar** (`big_calendar/1`) — Full-page month view inspired by Google Calendar. View switcher (month / week / day) via `:view` attr + `on_view_change` event. MON-first grid. Events rendered as colored pills truncated at 3-per-day with `+N more`. `big_calendar_event/1` sub-component. Today highlighted. `phx-click` on days and events. **28 tests**.

#### Calendar & Scheduling Suite — Wave 11: Week Grid (1 component)

- **CalendarWeekView** (`calendar_week_view/1`) — Week grid with 24-hour time axis on the left. Each event is absolutely positioned by `top: #{start_px}px; height: #{duration_px}px` computed from start time and duration. Overlapping events share column width. `calendar_week_event/1` sub-component with color, title, time label. **25 tests**.

#### Calendar & Scheduling Suite — Wave 12: Day Cards (2 components)

- **DateCard** (`date_card/1`) — Individual day card with 4 visual states: `default`, `today` (ring), `selected` (filled background), `disabled` (muted, pointer-events-none). Attrs: `date`, `state`, `on_click`. **16 tests**.

- **DateStrip** (`date_strip/1`) — Horizontal scrollable row of `DateCard` components. Accepts `dates` list + `selected` date. Auto-scrolls to keep selected card visible (inline JS). `aria-label="Date strip"`. **14 tests**.

#### Calendar & Scheduling Suite — Wave 13: Compact Week Navigator (1 component)

- **WeekCalendar** (`week_calendar/1`) — Compact week navigator widget. Header: current month/year title + prev/next arrows. 7-day strip below: each day shows abbreviated weekday label + date number. Selected day renders as a filled pill. `on_day_click` event. **18 tests**.

#### Calendar & Scheduling Suite — Wave 14: Range Calendar (1 component)

- **RangeCalendar** (`range_calendar/1`) — SUN-first single-month grid with rich range band visualization. Start/end dates render as filled blue circles with half-band; intermediate days render as full-band. Circular blue navigation buttons. `on_range_change` event with `{start, end}` map. **20 tests**.

#### Calendar & Scheduling Suite — Wave 15: Scheduling Components (9 components)

- **TimeSlotGrid** (`time_slot_grid/1`) — Grid of bookable time slots. Each slot is a button with 3 states: `available`, `booked`, `selected`. Configurable columns and slot duration. `on_select` event pushes `%{slot: time_string}`. **20 tests**.

- **WheelPicker** (`wheel_picker/1`) — iOS-style scroll-wheel picker. Configurable number of columns, each with a list of items and a selected index. Pure CSS `overflow: hidden` + `scroll-snap-type: y mandatory` scroll wheel. Inline JS to sync scroll position → `pushEvent` on snap. **22 tests**.

- **MultiSelectCalendar** (`multi_select_calendar/1`) — Calendar with multi-day toggle. Each day button toggles in/out of a selected set. Selected days rendered with `bg-primary`. Hidden `name[]` inputs submit all selected dates. `on_change` event pushes updated selected list. **18 tests**.

- **BadgeCalendar** (`badge_calendar/1`) — Monthly calendar with numeric badge overlays. Accepts `data` map `%{~D[2026-03-05] => integer}`. Badge renders as `absolute top-1 right-1 text-xs`. `aria-label="N events on date"`. **16 tests**.

- **DailyAgenda** (`daily_agenda/1`) — Single-day 24-hour timeline. Hour rows divided into 15-min gridlines. Events rendered as absolutely-positioned cards with CSS `top` + `height` computed from time values. Overlap detection: side-by-side columns. **24 tests**.

- **ScheduleEventCard** (`schedule_event_card/1`) — Rich event detail card. Slots: title, time range, location, attendees (avatar stack), status badge, action buttons. Color accent bar on left border matches event category color. **18 tests**.

- **CountdownTimer** (`countdown_timer/1`) — Live countdown to a target `DateTime`. Displays DD : HH : MM : SS flip tiles. Counts down to zero (shows "00:00:00:00"). Configurable label and expired state. Pure server-rendered — no JS hook; update via `push_event` or LiveView timer. **16 tests**.

- **TimeSlotList** (`time_slot_list/1`) — Vertical list of time slots with availability indicator. Each slot shows time, duration, availability label, and a "Book" button. Available/booked/pending states with colored dot. `on_book` event. **16 tests**.

- **TimeSliderPicker** (`time_slider_picker/1`) — Dual-handle slider for selecting a start + end time within a day. Renders two `<input type="range">` with CSS overlap. Outputs start/end as `"HH:MM"` strings. `on_change` event. **20 tests**.

#### Calendar & Scheduling Suite — Wave 16: Booking & Schedule Views (4 components)

- **BookingCalendar** (`booking_calendar/1`) — Full appointment booking flow. Month calendar shows available/booked/closed days. Clicking an available day reveals time slot list. Confirm button triggers `on_book` event with `%{date: date, slot: time}`. **26 tests**.

- **StreakCalendar** (`streak_calendar/1`) — Habit tracker / contribution heatmap. Accepts `entries` list of `%{date, completed}`. Shows current streak, longest streak, completion percentage. Intensity coloring per week. Legend below grid. **22 tests**.

- **ScheduleView** (`schedule_view/1`) — Agenda-style event list grouped by date. Events sorted chronologically. Date group headers highlight today. `schedule_view_event/1` sub-component: time, title, location, attendee avatars, color dot. **20 tests**.

- **MultiMonthCalendar** (`multi_month_calendar/1`) — Side-by-side display of 2–4 months (`:count` attr). Navigation arrows advance all months together. Range selection spans across months. Used for extended booking windows. **24 tests**.

#### Advanced Dashboard Widgets — Wave 6 (4 components)

- **CircularProgress** (`circular_progress/1`) — Radial SVG progress ring. Attrs: `value` (0–100), `size` (px), `stroke_width`, `color` (semantic token). `role="progressbar"` + `aria-valuenow` + `aria-valuemax`. Inner label slot for value/text. **22 tests**.

- **EventCalendar** (`event_calendar/1`) — Monthly calendar grid with event pills per day. Accepts `events` list `%{date, title, color, id}`. Max 3 pills per day + `+N more` overflow. Day click triggers `on_day_click` with date + event list. **24 tests**.

- **UptimeBar** (`uptime_bar/1`) — Segmented uptime visualization. Accepts `segments` list `%{status: :up | :down | :degraded, label}`. Green/red/yellow colored segments. Uptime percentage badge. Tooltip per segment on hover. `rounding/2` helper applies `rounded-full` for single-segment edge case. **20 tests**.

- **ReceiptCard** (`receipt_card/1`) — Transaction/purchase receipt layout. Line items table with description + amount. Subtotal, tax, total rows. Merchant header with logo slot. QR code slot at bottom. Print-friendly CSS. **20 tests**.

#### Advanced Dashboard Widgets — Wave 7 (4 components)

- **SparklineCard** (`sparkline_card/1`) — Inline SVG sparkline polyline + metric value card. Accepts `data` list of numbers. Normalizes to SVG viewBox. Trend badge (▲/▼ + %). Color inherited from `text-*` class. **20 tests**.

- **GaugeChart** (`gauge_chart/1`) — SVG semicircle gauge. Needle rotates from -90° (min) to +90° (max) based on `value`. Color zones (green/yellow/red arcs). Min/max labels at edges. Center displays value + unit. **22 tests**.

- **GanttChart** (`gantt_chart/1`) — Horizontal timeline/project planning. Accepts `tasks` list `%{label, start_date, end_date, color, progress}`. Date axis auto-scales to task range. Today indicator vertical line. Progress bar within each task bar. **26 tests**.

- **Snackbar** (`snackbar/1`) — Temporary notification banner appearing at the bottom center of the screen. Variants: `default`, `success`, `error`, `warning`. `open` boolean attr toggles visibility with CSS transition. Auto-dismiss via `phx-click` or timer. Action slot for link/button. **18 tests**.

#### Display & Interaction Additions — Wave 5 (3 components)

- **AvatarGroup** (`avatar_group/1`) — Standalone stacked avatars registry entry. Negative-margin overlap. `+N` overflow badge when `max` exceeded. 3 sizes (`:sm`, `:default`, `:lg`). Accepts `avatars` list `%{src, name, fallback}`. **16 tests**.

- **SelectableCard** (`selectable_card/1`) — Card with selection state. Renders a hidden `<input type="checkbox">` or `<input type="radio">` underneath. Selected state: `ring-2 ring-primary`. Checkmark icon appears in top-right corner when selected. `on_select` event. **18 tests**.

- **InputAddon** (`input_addon/1`) — Prefix and suffix addon wrapper for `phia_input/1`. Merges borders and removes duplicate rounded corners at the join. Addon can be text, icon, or button. Zero JS. **16 tests**.

#### Tabs Enhancement — Wave 5 (update, not new entry)

- **Tabs variants** — Added `:variant` attr to `tabs/1`: `:underline` (default, bottom border), `:solid` (filled background), `:pill` (rounded). No registry count change.

#### Media, Communication & Navigation (5 components)

- **AudioPlayer** (`audio_player/1`) + `PhiaAudioPlayer` hook — HTML5 `<audio>` element controlled by a custom UI. Play/pause toggle, scrubber (time slider), current/total time display, volume slider, mute button. Hook uses native `audio` events (`timeupdate`, `loadedmetadata`, `ended`). `destroyed()` removes all listeners. **22 tests**.

- **Sonner** (`sonner/1`) + `PhiaSonner` hook — Rich toast notification system (Sonner-inspired). Icon variants (`success` ✓, `error` ✗, `warning` ⚠, `info` ℹ, `loading` spinner). Action button slot. Promise toast mode (pending → success/error). Stacking with configurable `position` (6 positions). `push_event(socket, "phia-sonner", %{...})` API. **24 tests**.

- **QrCode** (`qr_code/1`) — SVG QR code generator using `eqrcode ~> 0.2`. `EQRCode.svg/2` wrapped in a `<div>`. Attrs: `value` (string), `size` (integer, default 200), `error_correction_level` (`:l`, `:m`, `:q`, `:h`). `title` attr for `<title>` inside SVG for accessibility. **16 tests**.

- **BottomNavigation** (`bottom_navigation/1`, `bottom_navigation_item/1`) — Mobile bottom tab bar. Fixed at bottom, full width, 3–5 items. Each item: icon + label + optional badge. `aria-current="page"` on active item. `phx-click` on each item. **16 tests**.

- **Toolbar** (`toolbar/1`, `toolbar_button/1`, `toolbar_separator/1`) — Horizontal `role="toolbar"` bar. `toolbar_button/1`: icon button with tooltip, `aria-label`, disabled state, active/pressed state. `toolbar_separator/1`: `role="separator"`, `aria-orientation="vertical"`. Arrow key navigation via `aria-keyshortcuts`. **18 tests**.

### New JS Hooks

- `priv/templates/js/hooks/audio_player.js` — `PhiaAudioPlayer`
- `priv/templates/js/hooks/sonner.js` — `PhiaSonner`

### Test Coverage

- **1098 new tests** across 44 new components — **0 failures**
- **4043 total tests** — **0 failures**
- Component registry: **119 entries** (75 → 119, all implemented — zero planned-only entries)
- `mix credo --strict` — 0 issues

---

## 0.1.4 — 2026-03-04

### Added — 15 gap-analysis components (vs shadcn/ui, Mantine, Ant Design, Chakra UI, MUI)

Gap analysis identified 15 high-demand components present in major UI libraries but missing from PhiaUI.
All components follow TDD (tests first), use semantic Tailwind v4 tokens, WAI-ARIA, and zero npm dependencies.

#### Wave 1 — High Priority: Input Primitives

- **InputOTP** (`input_otp/1`, `input_otp_group/1`, `input_otp_slot/1`, `input_otp_separator/1`) — Multi-slot OTP/PIN field. Each slot is `<input type="text" maxlength="1" inputmode="numeric">`. Auto-advances focus on input; Backspace returns to previous slot. `autocomplete="one-time-code"` on slot 0. `aria-label="Digit N"`. Inline JS (no hook) for focus traversal. Supports separator between slot groups. **25 tests**.

- **Spinner** (`spinner/1`) — Animated SVG loading indicator. 5 sizes (`:xs` h-3, `:sm` h-4, `:default` h-6, `:lg` h-8, `:xl` h-12). Uses `animate-spin` and `currentColor` — inherits text color. `role="status"` + `aria-label` + `aria-live="polite"` + `<span class="sr-only">`. **15 tests**.

- **NumberInput** (`number_input/1`, `form_number_input/1`) — Stepper input with `[−] [value] [+]` layout. Native `<input type="number">` with `min`, `max`, `step`. Optional `prefix` and `suffix` slots. `aria-valuemin/max/now`. FormField integration for Ecto changesets. **28 tests**.

- **PasswordInput** (`password_input/1`, `form_password_input/1`) — Password field with toggle button. Uses `Phoenix.LiveView.JS.toggle_attribute({"type", "password", "text"})` — zero JS hook needed. `autocomplete="current-password"` by default. Eye SVG icon inline. `aria-label="Show password"`. Disables toggle button when `disabled`. FormField integration. **20 tests**.

- **CopyButton** (`copy_button/1`) + `PhiaCopyButton` hook — Copy-to-clipboard button. `navigator.clipboard.writeText` with `execCommand` fallback. Copy icon → check icon feedback for `timeout` ms. `aria-live="polite"` on hidden span for screen reader announcement. **18 tests**.

#### Wave 2 — Medium Priority: Selection & Interaction

- **SegmentedControl** (`segmented_control/1`) — Horizontal selector using hidden radio inputs + styled labels. Active state applied server-side (`bg-background shadow-sm`). 3 sizes (`:sm`, `:default`, `:lg`). `phx-click` on labels for `on_change` event. `role="group"` on container. **29 tests**.

- **Chip** (`chip/1`, `chip_group/1`) — Interactive pill component. When `on_click` present, renders as `<button>` with `aria-pressed={to_string(@selected)}`. When `dismissible`, shows × button with `aria-label="Remove"`. 3 variants (`:default`, `:outline`, `:filled`), 3 sizes. `chip_group/1` wraps in flex-wrap container. **20 tests**.

- **Editable** (`editable/1`) + `PhiaEditable` hook — Inline edit field with preview/edit state. Renders preview `div` (role=button, tabindex=0) and hidden input wrapper. Hook: click/Enter/Space → startEdit (focus+select), Enter → submit (pushEvent), Escape/click-outside → cancel. **25 tests**.

- **FileUpload** (`file_upload/1`, `file_upload_entry/1`) — Generic file drop zone. Accepts `Phoenix.LiveView.UploadConfig` or plain map. `phx-drop-target={upload.ref}` for drag-and-drop. `:empty` slot for drop zone content. `:file` slot with `:let={entry}` for file list. `file_upload_entry/1`: filename, progress bar (`width: #{progress}%`), error messages, cancel button with `phx-value-ref`. **22 tests**.

- **Menubar** (`menubar/1`, `menubar_menu/1`, `menubar_trigger/1`, `menubar_content/1`, `menubar_item/1`, `menubar_separator/1`) — Desktop app-style horizontal menu bar. `role="menubar"` on container, `role="menubutton"` + `aria-haspopup="menu"` on triggers, `role="menu"` on content panels (hidden by default, JS toggles). `menubar_item/1` supports `shortcut` attr for keyboard shortcut display, `disabled` state. **31 tests**.

#### Wave 3 — Lower Priority: Utility & Navigation

- **ColorPicker** (`color_picker/1`) + `PhiaColorPicker` hook — Color selector built on native `<input type="color">`. Swatch buttons update the input; hook syncs value display span and pushes `on_change` event. `data-color-input`, `data-color-value`, `data-swatch-value` data attributes for hook targeting. **20 tests**.

- **FloatButton** (`float_button/1`) — Fixed circular action button (FAB). Position variants: `:bottom_right`, `:bottom_left`, `:top_right`, `:top_left`. Two function heads: simple button (with `on_click`) or speed-dial (with `:main` + `:item` slots showing expandable action items). `h-14 w-14 rounded-full bg-primary`. **18 tests**.

- **MultiSelect** (`multi_select/1`, `form_multi_select/1`) — Multiple-value select with `<select multiple>`. Selected values shown as chip row above the select. Chips have `phx-value-deselect` for individual removal. `name="field[]"` for multi-value form submission. `aria-label` on select for accessibility. FormField integration. **25 tests**.

- **Tree** (`tree/1`, `tree_item/1`) — Hierarchical tree view using native `<details>/<summary>` (zero JavaScript). `role="tree"` on root `<ul>`. Expandable items: `<details open={@expanded}>` + `<summary>` with chevron SVG + `<ul role="group" class="ml-4">` for nesting. Leaf items: `phx-click` + `phx-value-value`. `aria-expanded` on each `<li>`. **25 tests**.

- **BackTop** (`back_top/1`) + `PhiaBackTop` hook — Scroll-to-top button. Fixed positioned, starts `opacity-0`. Hook listens to `scroll` event (passive), toggles `opacity-100` beyond threshold. Click: `window.scrollTo({top:0, behavior: "smooth"})`. Cleanup in `destroyed()`. **15 tests**.

### New JS Hooks

- `priv/templates/js/hooks/copy_button.js` — `PhiaCopyButton`
- `priv/templates/js/hooks/editable.js` — `PhiaEditable`
- `priv/templates/js/hooks/color_picker.js` — `PhiaColorPicker`
- `priv/templates/js/hooks/back_top.js` — `PhiaBackTop`

### Test Coverage

- **336 new tests** for 15 new components — **0 failures**
- **2945 total tests** — **0 failures**
- Component registry: **75 entries** (62 → 75, replacing 2 planned entries with implemented)

---

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
