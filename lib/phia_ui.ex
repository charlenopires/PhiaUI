defmodule PhiaUi do
  @moduledoc """
  PhiaUI — a shadcn/ui-inspired component library for Phoenix LiveView.

  PhiaUI brings the composable, anatomy-driven design system of
  [shadcn/ui](https://ui.shadcn.com) to the Phoenix ecosystem. Every component
  is a stateless HEEx function component that integrates with
  `Phoenix.HTML.Form`, Ecto changesets, and LiveView's JS command system. There
  are no npm dependencies and no Alpine.js. JS hooks (where required) are
  plain vanilla JavaScript files that you own after ejection.

  ## Design Principles

  1. **Copy-paste ownership** — run `mix phia.add ComponentName` and the source
     file is yours; PhiaUI never regenerates it.
  2. **Composition over configuration** — small, single-purpose components that
     you assemble rather than a single mega-component with dozens of props.
  3. **Accessibility first** — every interactive component implements the
     relevant WAI-ARIA pattern (roles, states, keyboard navigation).
  4. **Semantic Tailwind v4 tokens** — uses `--color-primary`, `--radius`, etc.
     from `priv/static/theme.css`; never hard-codes hex values.
  5. **Zero JS dependencies** — hooks are vanilla JavaScript (~50–150 LOC each)
     copied into your `assets/js/hooks/` directory.
  6. **LiveView-native** — state lives in the LiveView process; hooks only
     handle DOM-level behaviour (focus traps, pointer events, scroll).
  7. **Dark mode first** — every component ships with `dark:` variants driven by
     the `.dark` class on `<html>`, toggled by `PhiaDarkMode`.
  8. **Beautiful defaults, fully customisable** — sensible out-of-the-box
     Tailwind classes, overridable via the `class` attribute on every component.
  9. **Enterprise by default** — DataGrid, KanbanBoard, FilterBuilder, and
     ActivityFeed are production-ready, not demo toys.
  10. **Elixir-idiomatic** — no macros, no metaprogramming; just plain function
      components and straightforward pattern matching.

  ## Architecture

  PhiaUI is organised into eight layers:

  ### 1. Primitive Components

  Stateless, zero-JS layout and display components. Safe to use in any context,
  including dead views and email templates.

  - `PhiaUi.Components.Button` — 6 variants × 4 sizes; `button_group/1` for
    segmented controls
  - `PhiaUi.Components.Card` — `card/1`, `card_header/1`, `card_title/1`,
    `card_description/1`, `card_content/1`, `card_footer/1`
  - `PhiaUi.Components.Badge` — 4 semantic variants: `default`, `secondary`,
    `destructive`, `outline`
  - `PhiaUi.Components.Table` — streams-compatible; anatomy: `table/1`,
    `thead/1`, `tbody/1`, `tr/1`, `th/1`, `td/1`, `table_caption/1`
  - `PhiaUi.Components.Icon` — Lucide SVG sprite, 4 sizes (`xs/sm/md/lg`)
  - `PhiaUi.Components.Alert` — `alert/1` with `default` and `destructive`
    variants; slots for icon, title and description
  - `PhiaUi.Components.Skeleton` — `skeleton/1` shimmer placeholder for
    loading states
  - `PhiaUi.Components.Breadcrumb` — `breadcrumb/1`, `breadcrumb_item/1`,
    `breadcrumb_separator/1`; ARIA `nav[aria-label="breadcrumb"]`
  - `PhiaUi.Components.Pagination` — `pagination/1` with page-window
    algorithm; emits `phx-click` events
  - `PhiaUi.Components.Avatar` — `avatar/1` with image + fallback initials;
    `avatar_group/1` for stacked avatars with overflow count
  - `PhiaUi.Components.ButtonGroup` — horizontal/vertical segmented button
    strips using CSS `[&>*]` selectors
  - `PhiaUi.Components.EmptyState` — `empty_state/1` with five named slots:
    `icon`, `title`, `description`, `action`, `secondary_action`
  - `PhiaUi.Components.Progress` — `progress/1`; CSS-only `role=progressbar`,
    indeterminate animation variant
  - `PhiaUi.Components.Separator` — `separator/1`; horizontal/vertical `hr`
    or `div[role=separator]`
  - `PhiaUi.Components.AspectRatio` — `aspect_ratio/1`; CSS `padding-top`
    trick for 16:9, 4:3, 1:1, etc.
  - `PhiaUi.Components.Direction` — `direction/1`; wraps content in
    `dir="ltr"` or `dir="rtl"` for RTL support
  - `PhiaUi.Components.Kbd` — `kbd/1`; semantic `<kbd>` element for keyboard
    shortcut display

  ### 2. Form Integration

  Fully integrated with `Phoenix.HTML.FormField` and Ecto changeset errors.
  All form components forward `field` errors automatically; no manual wiring.

  - `PhiaUi.Components.Input` — `phia_input/1` — label + input + description +
    inline error display
  - `PhiaUi.Components.Textarea` — `phia_textarea/1` — multi-line text with
    auto error display
  - `PhiaUi.Components.Select` — `phia_select/1` — native `<select>` with
    custom chevron overlay
  - `PhiaUi.Components.Form` — `form_field/1`, `form_label/1`,
    `form_message/1` — flexible unstyled form anatomy primitives
  - `PhiaUi.Components.Field` — `field/1`, `field_label/1`,
    `field_description/1`, `field_message/1` — four sub-components for
    structured field layout
  - `PhiaUi.Components.Checkbox` — native `<input type="checkbox">` with
    indeterminate state support; `form_checkbox/1` FormField wrapper
  - `PhiaUi.Components.RadioGroup` — `radio_group/1` + `radio_group_item/1`;
    uses `:let` context to pass group state into items
  - `PhiaUi.Components.Switch` — `switch/1`; `role=switch`, CSS slide
    animation; `form_switch/1` FormField wrapper
  - `PhiaUi.Components.Toggle` — `toggle/1`; `aria-pressed`, 2 variants × 3
    sizes
  - `PhiaUi.Components.ToggleGroup` — `toggle_group/1` + `toggle_group_item/1`;
    single/multiple selection using `:let` context
  - `PhiaUi.Components.TagsInput` — `tags_input/1` — CSV hidden input +
    chip display; `PhiaTagsInput` hook for keyboard management
  - `PhiaUi.Components.ImageUpload` — `image_upload/1` — native LiveView
    uploads integration with drag-and-drop zone
  - `PhiaUi.Components.RichTextEditor` — `rich_text_editor/1` — 14 toolbar
    commands (`bold`, `italic`, `link`, `h1`–`h3`, lists, etc.); zero npm;
    uses `contenteditable` + `document.execCommand()` + Selection API
  - `PhiaUi.Components.Slider` — `slider/1`; CSS-only `input[type=range]`
    with `accent-primary` token; `form_slider/1` FormField wrapper
  - `PhiaUi.Components.Rating` — `rating/1`; CSS-only star rating using hidden
    radio inputs; `form_rating/1` FormField wrapper
  - `PhiaUi.Components.Combobox` — `combobox/1`; server-side filterable
    option list; `form_combobox/1` FormField wrapper
  - `PhiaUi.Components.MentionInput` — `mention_input/1`; `@username` trigger,
    `mention_dropdown/1`; `PhiaMentionInput` hook for caret tracking

  ### 3. Interactive Components

  WAI-ARIA compliant components backed by lightweight vanilla JS hooks. Each
  hook is self-contained (~50–150 LOC) and has no external dependencies.

  - `PhiaUi.Components.Dialog` — `dialog/1` — focus trap, Escape key, scroll
    lock (`PhiaDialog` hook)
  - `PhiaUi.Components.AlertDialog` — `alert_dialog/1` — `role=alertdialog`,
    requires explicit confirmation; reuses `PhiaDialog` hook
  - `PhiaUi.Components.DropdownMenu` — `dropdown_menu/1` — smart viewport
    positioning, arrow key navigation (`PhiaDropdownMenu` hook)
  - `PhiaUi.Components.Accordion` — `accordion/1` — single/multiple open
    panels; pure `Phoenix.LiveView.JS` (no hook required)
  - `PhiaUi.Components.Collapsible` — `collapsible/1` — single toggle
    expand/collapse; pure `Phoenix.LiveView.JS`
  - `PhiaUi.Components.Sheet` — `sheet/1` — slide-in panel from any of 4
    sides × 5 sizes; reuses `PhiaDialog` hook
  - `PhiaUi.Components.Drawer` — `drawer/1` — mobile-first bottom/top/left/
    right sheet with focus trap and swipe-to-dismiss (`PhiaDrawer` hook)
  - `PhiaUi.Components.Tooltip` — `tooltip/1` — hover + focus activation,
    smart placement (`PhiaTooltip` hook)
  - `PhiaUi.Components.Popover` — `popover/1` — click-activated overlay with
    focus trap and smart positioning (`PhiaPopover` hook)
  - `PhiaUi.Components.HoverCard` — `hover_card/1` + `hover_card_trigger/1` +
    `hover_card_content/1`; `role=tooltip`, CSS-only hover delay
  - `PhiaUi.Components.Toast` — `toast/1` — server-pushed notifications via
    `push_event/3`; `PhiaToast` hook auto-dismisses after timeout
  - `PhiaUi.Components.Command` — `command_menu/1` — `Ctrl+K` / `Cmd+K`
    global command palette with fuzzy search (`PhiaCommand` hook)
  - `PhiaUi.Components.ContextMenu` — `context_menu/1` — right-click (or
    long-press) contextual menu (`PhiaContextMenu` hook)
  - `PhiaUi.Components.ScrollArea` — `scroll_area/1` — styled scrollable
    region; 3 orientations (`vertical`, `horizontal`, `both`); CSS-only

  ### 4. Navigation and Tabs

  Structural navigation patterns for multi-page and multi-section UIs.

  - `PhiaUi.Components.Tabs` — `tabs/1`, `tab_list/1`, `tab_trigger/1`,
    `tab_content/1`; server-rendered active tab; `:let` context
  - `PhiaUi.Components.TabsNav` — `tabs_nav/1`, `tabs_nav_item/1`; 3 variants:
    `underline`, `pills`, `segment`; lightweight URL-based tab navigation
  - `PhiaUi.Components.NavigationMenu` — `navigation_menu/1` with nested
    dropdown panels; hover-activated, keyboard accessible
  - `PhiaUi.Components.StepTracker` — `step_tracker/1` + `step/1`; horizontal
    and vertical step progress; `aria-current="step"` on active step

  ### 5. Dashboard Shell

  Enterprise-grade layout shell using `CSS Grid` (`grid-cols-[240px_1fr]
  h-screen`) on desktop and a Flexbox drawer on mobile. The shell is
  self-contained and requires no external CSS.

  - `PhiaUi.Components.Shell` — `shell/1` — outer page grid; optional
    collapsible sidebar
  - `PhiaUi.Components.Shell` — `sidebar/1` — `:variant` (`:default` /
    `:dark`); `sidebar_item/1` with `:badge` attr and `:icon` slot;
    `sidebar_section/1` for grouped nav links
  - `PhiaUi.Components.Shell` — `topbar/1` — sticky top bar with left/right
    action slots; `mobile_sidebar_toggle/1`
  - `PhiaUi.Components.DarkModeToggle` — `dark_mode_toggle/1` — reads
    `prefers-color-scheme`, persists to `localStorage['phia-mode']`, toggles
    `.dark` on `<html>` (`PhiaDarkMode` hook)
  - `PhiaUi.Components.ThemeProvider` — `theme_provider/1` — sets
    `data-phia-theme` on a wrapper element; reads preset from
    `localStorage['phia-color-theme']` via `PhiaTheme` hook. Requires
    `phia-themes.css` generated by `mix phia.theme install`

  ### 6. Dashboard Widgets

  Composed analytics widgets for BI dashboards and KPI monitors.

  - `PhiaUi.Components.StatCard` — `stat_card/1` — trend indicator (up/down
    arrow), icon slot, footer slot; `shadow-sm tracking-tight` polish
  - `PhiaUi.Components.MetricGrid` — `metric_grid/1` — responsive 1–4 column
    grid that wraps `stat_card/1` children
  - `PhiaUi.Components.ChartShell` — `chart_shell/1` — titled card wrapper for
    any charting library; description and actions slots
  - `PhiaUi.Components.Chart` — `chart/1` — `PhiaChart` hook; auto-detects
    `window.echarts` (Apache ECharts) or `window.Chart` (Chart.js); passes
    config and series via `data-config` / `data-series` JSON attributes
  - `PhiaUi.Components.DataGrid` — `data_grid/1` — sortable columns via
    `phx-click` + `phx-value`; streams-compatible; sort direction cycles
    `asc → desc → none`

  ### 7. Enterprise Components

  Production-ready components for complex data workflows and collaboration UIs.

  - `PhiaUi.Components.KanbanBoard` — `kanban_board/1`, `kanban_column/1`,
    `kanban_card/1`; drag-and-drop lane management; `PhiaKanban` hook
  - `PhiaUi.Components.ActivityFeed` — `activity_feed/1`, `activity_item/1`;
    timestamped event log with icon, actor, and body slots
  - `PhiaUi.Components.ChatMessage` — `chat_message/1`; sent/received bubbles,
    avatar, timestamp, read receipts
  - `PhiaUi.Components.FilterBar` — `filter_bar/1`; inline filter chips with
    add/remove/clear actions; emits `phx-click` events
  - `PhiaUi.Components.FilterBuilder` — `filter_builder/1`; structured
    rule-based filter UI (field + operator + value); supports `text`,
    `number`, `date`, and `select` field types
  - `PhiaUi.Components.BulkActionBar` — `bulk_action_bar/1`; renders empty
    `~H""` when `count: 0`, toolbar otherwise; sticky bottom action bar
    for bulk selection workflows
  - `PhiaUi.Components.HeatmapCalendar` — `heatmap_calendar/1`; GitHub-style
    contribution heatmap; accepts a `{date, count}` list

  ### 8. Utility Components

  Date pickers, carousels, and layout utilities used across multiple contexts.

  - `PhiaUi.Components.Timeline` — `timeline/1`, `timeline_item/1`; vertical
    connector line; icon, title, description, and timestamp slots
  - `PhiaUi.Components.Resizable` — `resizable/1`, `resizable_panel/1`; split
    panes with drag/touch/keyboard resize (`PhiaResizable` hook);
    `data-direction` attribute controls horizontal/vertical layout
  - `PhiaUi.Components.Carousel` — `carousel/1`; swipe, keyboard, and button
    navigation (`PhiaCarousel` hook); optional auto-play
  - `PhiaUi.Components.Calendar` — `calendar/1`; full calendar grid rendered
    server-side; date selection via `phx-click` (`PhiaCalendar` hook)
  - `PhiaUi.Components.DatePicker` — `date_picker/1`; composes `Calendar` +
    `Popover` into a single click-to-open date field
  - `PhiaUi.Components.DateRangePicker` — `date_range_picker/1`; dual calendar
    with range highlight; start/end date selection (`PhiaDateRangePicker` hook)

  ## Installation

  Add PhiaUI to your `mix.exs` dependencies:

      def deps do
        [
          {:phia_ui, "~> 0.1"}
        ]
      end

  Then run the installer to copy hooks and the Tailwind theme into your project:

      mix phia.install

  Install the optional theme CSS for multi-theme support:

      mix phia.theme install

  This generates `assets/css/phia-themes.css` (all 8 presets × 2 selectors)
  and injects an `@import` into `assets/css/app.css` idempotently.

  To add individual components as ejectable source files:

      mix phia.add Button
      mix phia.add Card Badge Table

  ## Quick Start

  A minimal LiveView using several PhiaUI components:

      defmodule MyAppWeb.DemoLive do
        use MyAppWeb, :live_view

        import PhiaUi.Components.Button
        import PhiaUi.Components.Card
        import PhiaUi.Components.Badge
        import PhiaUi.Components.Input

        def render(assigns) do
          ~H\"\"\"
          <.card>
            <.card_header>
              <.card_title>Welcome</.card_title>
              <.card_description>
                Manage your account settings.
                <.badge variant={:secondary}>Beta</.badge>
              </.card_description>
            </.card_header>
            <.card_content>
              <.form for={@form} phx-change="validate" phx-submit="save">
                <.phia_input field={@form[:email]} label="Email" phx-debounce="blur" />
                <.button type="submit" class="mt-4">Save</.button>
              </.form>
            </.card_content>
          </.card>
          \"\"\"
        end
      end

  A dashboard LiveView using the shell layout with a sidebar:

      defmodule MyAppWeb.DashboardLive do
        use MyAppWeb, :live_view

        import PhiaUi.Components.Shell
        import PhiaUi.Components.StatCard
        import PhiaUi.Components.MetricGrid

        def render(assigns) do
          ~H\"\"\"
          <.shell>
            <:sidebar>
              <.sidebar>
                <.sidebar_section label="Main">
                  <.sidebar_item icon="home" label="Dashboard" href="/dashboard" active />
                  <.sidebar_item icon="users" label="Team" href="/team" />
                </.sidebar_section>
              </.sidebar>
            </:sidebar>
            <:main>
              <.topbar title="Dashboard" />
              <.metric_grid>
                <.stat_card title="MRR" value="$12,400" trend="+8%" trend_direction={:up} />
                <.stat_card title="DAU" value="3,210" trend="-2%" trend_direction={:down} />
              </.metric_grid>
            </:main>
          </.shell>
          \"\"\"
        end
      end

  ## ClassMerger / cn/1

  `PhiaUi.ClassMerger.cn/1` is PhiaUI's Tailwind class conflict resolver —
  equivalent to `clsx` + `tailwind-merge` in the JS ecosystem, implemented
  natively in Elixir without any external dependencies.

  Pass a list of class strings (or `nil` / `false` values, which are ignored).
  When two classes target the same Tailwind utility group (e.g. `px-2` and
  `px-4`), the **last one wins**:

      cn(["px-2 py-1", nil, "px-4"])
      #=> "py-1 px-4"

  Every component accepts a `:class` attribute that is merged through `cn/1`,
  so you can safely override individual utilities without worrying about
  duplication:

      <.button class="px-8">Wide Button</.button>

  ## Theme System

  PhiaUI ships with 8 built-in colour presets: `zinc`, `slate`, `blue`, `rose`,
  `orange`, `green`, `violet`, and `neutral`. The active theme is set by placing
  a `data-phia-theme` attribute on any ancestor element (or `<html>` for a
  global theme).

  ### Runtime theme switching (colour preset)

  Add the `PhiaTheme` hook to a button or `<select>` with a `data-theme`
  attribute, and the hook will update `data-phia-theme` on `<html>` and persist
  the selection to `localStorage['phia-color-theme']`:

      <button data-theme="rose" phx-hook="PhiaTheme" id="theme-rose">
        Rose
      </button>

  ### Anti-FOUC setup

  Add the following snippet to the `<head>` of your `root.html.heex` **before**
  any stylesheet links to restore both dark mode and colour preset without a
  flash of unstyled content:

      <script>
        (function(){
          var m = localStorage.getItem('phia-mode') || localStorage.getItem('phia-theme');
          if (m === 'dark') document.documentElement.classList.add('dark');
          var t = localStorage.getItem('phia-color-theme');
          if (t) document.documentElement.setAttribute('data-phia-theme', t);
        })();
      </script>

  ## JS Hooks

  The following components use vanilla JS hooks for accessible behaviour that
  cannot be achieved with `Phoenix.LiveView.JS` alone. After running
  `mix phia.install`, all hook files are copied into your `assets/js/hooks/`
  directory and wired into your `LiveSocket` automatically.

  | Hook                  | Component(s)                          |
  |-----------------------|---------------------------------------|
  | `PhiaDialog`          | Dialog, AlertDialog, Sheet            |
  | `PhiaDropdownMenu`    | DropdownMenu                          |
  | `PhiaTagsInput`       | TagsInput                             |
  | `PhiaRichTextEditor`  | RichTextEditor                        |
  | `PhiaTooltip`         | Tooltip                               |
  | `PhiaPopover`         | Popover, DatePicker                   |
  | `PhiaToast`           | Toast                                 |
  | `PhiaDarkMode`        | DarkModeToggle                        |
  | `PhiaTheme`           | ThemeProvider                         |
  | `PhiaCommand`         | Command                               |
  | `PhiaCalendar`        | Calendar                              |
  | `PhiaCarousel`        | Carousel                              |
  | `PhiaContextMenu`     | ContextMenu                           |
  | `PhiaDrawer`          | Drawer                                |
  | `PhiaChart`           | Chart                                 |
  | `PhiaDateRangePicker` | DateRangePicker                       |
  | `PhiaMentionInput`    | MentionInput                          |
  | `PhiaResizable`       | Resizable                             |
  | `PhiaKanban`          | KanbanBoard                           |

  ## Ejectable Architecture

  Every component can be ejected — copied as editable source into your project —
  so you always own the code:

      mix phia.add Button Card Badge

  Ejected files appear under `lib/your_app_web/components/` and are fully
  independent of the PhiaUI package. You can modify them freely without
  upgrading or forking. This is the same model as shadcn/ui: PhiaUI is a
  distribution mechanism, not a runtime dependency you are locked into.
  """

  @doc false
  def hello, do: :world
end
