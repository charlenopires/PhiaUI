defmodule PhiaUi.ComponentRegistry do
  @moduledoc """
  Source of truth for all 309 PhiaUI components.

  Each entry is keyed by an atom and contains:

  - `:name` — snake_case string identifier
  - `:module` — the Elixir module that will be generated on ejection
  - `:template_file` — path inside `priv/templates/` for the EEx source
  - `:js_hooks` — list of JS hook names required by this component
  - `:dependencies` — list of component atoms this component composes
  - `:tier` — domain tier (`:primitive | :interactive | :form | :navigation | :shell | :widget`)
  - `:shadcn_equivalent` — matching shadcn/ui component name, or `nil`
  - `:status` — `:planned` or `:implemented`

  ## Usage

      # All components
      PhiaUi.ComponentRegistry.all()

      # Single lookup
      PhiaUi.ComponentRegistry.get(:button)

      # Filter by tier
      PhiaUi.ComponentRegistry.by_tier(:primitive)
  """

  @type tier :: :primitive | :interactive | :form | :navigation | :shell | :widget | :layout | :animation
  @type status :: :planned | :implemented

  @type component_meta :: %{
          name: String.t(),
          module: module(),
          template_file: String.t(),
          js_hooks: [String.t()],
          dependencies: [atom()],
          tier: tier(),
          shadcn_equivalent: String.t() | nil,
          status: status()
        }

  # ---------------------------------------------------------------------------
  # Registry definition
  # ---------------------------------------------------------------------------

  @registry %{
    # ── Primitive Components ──────────────────────────────────────────────────
    button: %{
      name: "button",
      module: PhiaUi.Components.Button,
      template_file: "priv/templates/components/buttons/button.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: "Button",
      status: :implemented
    },
    card: %{
      name: "card",
      module: PhiaUi.Components.Card,
      template_file: "priv/templates/components/cards/card.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: "Card",
      status: :implemented
    },
    badge: %{
      name: "badge",
      module: PhiaUi.Components.Badge,
      template_file: "priv/templates/components/display/badge.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: "Badge",
      status: :implemented
    },
    input: %{
      name: "input",
      module: PhiaUi.Components.Input,
      template_file: "priv/templates/components/inputs/input.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: "Input",
      status: :implemented
    },
    label: %{
      name: "label",
      module: PhiaUi.Components.Label,
      template_file: "priv/templates/components/forms/label.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: "Label",
      status: :implemented
    },
    separator: %{
      name: "separator",
      module: PhiaUi.Components.Separator,
      template_file: "priv/templates/components/layout/separator.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: "Separator",
      status: :implemented
    },
    skeleton: %{
      name: "skeleton",
      module: PhiaUi.Components.Skeleton,
      template_file: "priv/templates/components/feedback/skeleton.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: "Skeleton",
      status: :implemented
    },
    avatar: %{
      name: "avatar",
      module: PhiaUi.Components.Avatar,
      template_file: "priv/templates/components/display/avatar.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: "Avatar",
      status: :implemented
    },
    progress: %{
      name: "progress",
      module: PhiaUi.Components.Progress,
      template_file: "priv/templates/components/feedback/progress.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: "Progress",
      status: :implemented
    },
    table: %{
      name: "table",
      module: PhiaUi.Components.Table,
      template_file: "priv/templates/components/data/table.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: "Table",
      status: :implemented
    },
    aspect_ratio: %{
      name: "aspect_ratio",
      module: PhiaUi.Components.AspectRatio,
      template_file: "priv/templates/components/layout/aspect_ratio.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: "AspectRatio",
      status: :implemented
    },
    toggle: %{
      name: "toggle",
      module: PhiaUi.Components.Toggle,
      template_file: "priv/templates/components/buttons/toggle.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: "Toggle",
      status: :implemented
    },
    toggle_group: %{
      name: "toggle_group",
      module: PhiaUi.Components.ToggleGroup,
      template_file: "priv/templates/components/buttons/toggle_group.ex",
      js_hooks: [],
      dependencies: [:toggle],
      tier: :primitive,
      shadcn_equivalent: "ToggleGroup",
      status: :implemented
    },

    # ── Interactive Components ────────────────────────────────────────────────
    dialog: %{
      name: "dialog",
      module: PhiaUi.Components.Dialog,
      template_file: "priv/templates/components/overlay/dialog.ex",
      js_hooks: ["FocusTrap", "Dialog"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Dialog",
      status: :implemented
    },
    dropdown_menu: %{
      name: "dropdown_menu",
      module: PhiaUi.Components.DropdownMenu,
      template_file: "priv/templates/components/overlay/dropdown_menu.ex",
      js_hooks: ["ClickOutside", "DropdownMenu"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "DropdownMenu",
      status: :implemented
    },
    sheet: %{
      name: "sheet",
      module: PhiaUi.Components.Sheet,
      template_file: "priv/templates/components/overlay/sheet.ex",
      js_hooks: ["FocusTrap", "Sheet"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Sheet",
      status: :implemented
    },
    tabs: %{
      name: "tabs",
      module: PhiaUi.Components.Tabs,
      template_file: "priv/templates/components/navigation/tabs.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Tabs",
      status: :implemented
    },
    accordion: %{
      name: "accordion",
      module: PhiaUi.Components.Accordion,
      template_file: "priv/templates/components/layout/accordion.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Accordion",
      status: :implemented
    },
    popover: %{
      name: "popover",
      module: PhiaUi.Components.Popover,
      template_file: "priv/templates/components/overlay/popover.ex",
      js_hooks: ["PhiaPopover"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Popover",
      status: :implemented
    },
    tooltip: %{
      name: "tooltip",
      module: PhiaUi.Components.Tooltip,
      template_file: "priv/templates/components/overlay/tooltip.ex",
      js_hooks: ["PhiaTooltip"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Tooltip",
      status: :implemented
    },
    select: %{
      name: "select",
      module: PhiaUi.Components.Select,
      template_file: "priv/templates/components/inputs/select.ex",
      js_hooks: ["Select"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Select",
      status: :implemented
    },
    checkbox: %{
      name: "checkbox",
      module: PhiaUi.Components.Checkbox,
      template_file: "priv/templates/components/inputs/checkbox.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Checkbox",
      status: :implemented
    },
    switch: %{
      name: "switch",
      module: PhiaUi.Components.Switch,
      template_file: "priv/templates/components/inputs/switch.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Switch",
      status: :implemented
    },
    slider: %{
      name: "slider",
      module: PhiaUi.Components.Slider,
      template_file: "priv/templates/components/inputs/slider.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Slider",
      status: :implemented
    },
    radio_group: %{
      name: "radio_group",
      module: PhiaUi.Components.RadioGroup,
      template_file: "priv/templates/components/inputs/radio_group.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "RadioGroup",
      status: :implemented
    },
    collapsible: %{
      name: "collapsible",
      module: PhiaUi.Components.Collapsible,
      template_file: "priv/templates/components/layout/collapsible.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Collapsible",
      status: :implemented
    },
    hover_card: %{
      name: "hover_card",
      module: PhiaUi.Components.HoverCard,
      template_file: "priv/templates/components/overlay/hover_card.ex",
      js_hooks: ["HoverCard"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "HoverCard",
      status: :implemented
    },
    command: %{
      name: "command",
      module: PhiaUi.Components.Command,
      template_file: "priv/templates/components/overlay/command.ex",
      js_hooks: ["PhiaCommand"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Command",
      status: :implemented
    },
    calendar: %{
      name: "calendar",
      module: PhiaUi.Components.Calendar,
      template_file: "priv/templates/components/calendar/calendar.ex",
      js_hooks: ["Calendar"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Calendar",
      status: :implemented
    },
    carousel: %{
      name: "carousel",
      module: PhiaUi.Components.Carousel,
      template_file: "priv/templates/components/media/carousel.ex",
      js_hooks: ["Carousel"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Carousel",
      status: :implemented
    },
    context_menu: %{
      name: "context_menu",
      module: PhiaUi.Components.ContextMenu,
      template_file: "priv/templates/components/overlay/context_menu.ex",
      js_hooks: ["ContextMenu"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "ContextMenu",
      status: :implemented
    },
    drawer: %{
      name: "drawer",
      module: PhiaUi.Components.Drawer,
      template_file: "priv/templates/components/overlay/drawer.ex",
      js_hooks: ["FocusTrap", "Drawer"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Drawer",
      status: :implemented
    },
    navigation_menu: %{
      name: "navigation_menu",
      module: PhiaUi.Components.NavigationMenu,
      template_file: "priv/templates/components/navigation/navigation_menu.ex",
      js_hooks: ["NavigationMenu"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "NavigationMenu",
      status: :implemented
    },
    resizable: %{
      name: "resizable",
      module: PhiaUi.Components.Resizable,
      template_file: "priv/templates/components/layout/resizable.ex",
      js_hooks: ["PhiaResizable"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Resizable",
      status: :implemented
    },
    date_picker: %{
      name: "date_picker",
      module: PhiaUi.Components.DatePicker,
      template_file: "priv/templates/components/calendar/date_picker.ex",
      js_hooks: ["Calendar", "ClickOutside"],
      dependencies: [:calendar, :popover],
      tier: :interactive,
      shadcn_equivalent: "DatePicker",
      status: :implemented
    },
    combobox: %{
      name: "combobox",
      module: PhiaUi.Components.Combobox,
      template_file: "priv/templates/components/inputs/combobox.ex",
      js_hooks: ["Command", "ClickOutside"],
      dependencies: [:command, :popover],
      tier: :interactive,
      shadcn_equivalent: "Combobox",
      status: :implemented
    },

    # ── Form Integration ──────────────────────────────────────────────────────
    form_field: %{
      name: "form_field",
      module: PhiaUi.Components.FormField,
      template_file: "priv/templates/components/forms/form_field.ex",
      js_hooks: [],
      dependencies: [:label],
      tier: :form,
      shadcn_equivalent: "FormField",
      status: :implemented
    },
    phia_input: %{
      name: "phia_input",
      module: PhiaUi.Components.PhiaInput,
      template_file: "priv/templates/components/inputs/phia_input.ex",
      js_hooks: [],
      dependencies: [:input, :label, :form_field],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    textarea: %{
      name: "textarea",
      module: PhiaUi.Components.Textarea,
      template_file: "priv/templates/components/inputs/textarea.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: "Textarea",
      status: :implemented
    },
    # ── Navigation & Feedback ─────────────────────────────────────────────────
    breadcrumb: %{
      name: "breadcrumb",
      module: PhiaUi.Components.Breadcrumb,
      template_file: "priv/templates/components/navigation/breadcrumb.ex",
      js_hooks: [],
      dependencies: [],
      tier: :navigation,
      shadcn_equivalent: "Breadcrumb",
      status: :implemented
    },
    pagination: %{
      name: "pagination",
      module: PhiaUi.Components.Pagination,
      template_file: "priv/templates/components/navigation/pagination.ex",
      js_hooks: [],
      dependencies: [],
      tier: :navigation,
      shadcn_equivalent: "Pagination",
      status: :implemented
    },
    scroll_area: %{
      name: "scroll_area",
      module: PhiaUi.Components.ScrollArea,
      template_file: "priv/templates/components/layout/scroll_area.ex",
      js_hooks: [],
      dependencies: [],
      tier: :navigation,
      shadcn_equivalent: "ScrollArea",
      status: :implemented
    },
    alert: %{
      name: "alert",
      module: PhiaUi.Components.Alert,
      template_file: "priv/templates/components/feedback/alert.ex",
      js_hooks: [],
      dependencies: [],
      tier: :navigation,
      shadcn_equivalent: "Alert",
      status: :implemented
    },
    alert_dialog: %{
      name: "alert_dialog",
      module: PhiaUi.Components.AlertDialog,
      template_file: "priv/templates/components/feedback/alert_dialog.ex",
      js_hooks: ["FocusTrap", "Dialog"],
      dependencies: [:dialog],
      tier: :navigation,
      shadcn_equivalent: "AlertDialog",
      status: :implemented
    },
    toast: %{
      name: "toast",
      module: PhiaUi.Components.Toast,
      template_file: "priv/templates/components/feedback/toast.ex",
      js_hooks: ["PhiaToast"],
      dependencies: [],
      tier: :navigation,
      shadcn_equivalent: "Toast",
      status: :implemented
    },
    sonner: %{
      name: "sonner",
      module: PhiaUi.Components.Sonner,
      template_file: "priv/templates/components/feedback/sonner.ex",
      js_hooks: ["Sonner"],
      dependencies: [],
      tier: :navigation,
      shadcn_equivalent: "Sonner",
      status: :implemented
    },
    timeline: %{
      name: "timeline",
      module: PhiaUi.Components.Timeline,
      template_file: "priv/templates/components/display/timeline.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    rating: %{
      name: "rating",
      module: PhiaUi.Components.Rating,
      template_file: "priv/templates/components/inputs/rating.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    kbd: %{
      name: "kbd",
      module: PhiaUi.Components.Kbd,
      template_file: "priv/templates/components/display/kbd.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # ── Dashboard Shell ───────────────────────────────────────────────────────
    shell: %{
      name: "shell",
      module: PhiaUi.Components.Shell,
      template_file: "priv/templates/components/layout/shell.ex",
      js_hooks: [],
      dependencies: [],
      tier: :shell,
      shadcn_equivalent: nil,
      status: :implemented
    },
    sidebar: %{
      name: "sidebar",
      module: PhiaUi.Components.Sidebar,
      template_file: "priv/templates/components/navigation/sidebar.ex",
      js_hooks: [],
      dependencies: [],
      tier: :shell,
      shadcn_equivalent: "Sidebar",
      status: :implemented
    },
    topbar: %{
      name: "topbar",
      module: PhiaUi.Components.Topbar,
      template_file: "priv/templates/components/navigation/topbar.ex",
      js_hooks: [],
      dependencies: [],
      tier: :shell,
      shadcn_equivalent: nil,
      status: :implemented
    },
    mobile_sidebar_toggle: %{
      name: "mobile_sidebar_toggle",
      module: PhiaUi.Components.MobileSidebarToggle,
      template_file: "priv/templates/components/navigation/mobile_sidebar_toggle.ex",
      js_hooks: [],
      dependencies: [:sidebar],
      tier: :shell,
      shadcn_equivalent: nil,
      status: :implemented
    },
    dark_mode_toggle: %{
      name: "dark_mode_toggle",
      module: PhiaUi.Components.DarkModeToggle,
      template_file: "priv/templates/components/display/dark_mode_toggle.ex",
      js_hooks: ["PhiaDarkMode"],
      dependencies: [:icon],
      tier: :shell,
      shadcn_equivalent: nil,
      status: :implemented
    },
    date_range_picker: %{
      name: "date_range_picker",
      module: PhiaUi.Components.DateRangePicker,
      template_file: "priv/templates/components/calendar/date_range_picker.ex",
      js_hooks: ["PhiaDateRangePicker"],
      dependencies: [:icon],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    data_grid: %{
      name: "data_grid",
      module: PhiaUi.Components.DataGrid,
      template_file: "priv/templates/components/data/data_grid.ex",
      js_hooks: [],
      dependencies: [:icon],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # ── Dashboard Widgets ─────────────────────────────────────────────────────
    stat_card: %{
      name: "stat_card",
      module: PhiaUi.Components.StatCard,
      template_file: "priv/templates/components/cards/stat_card.ex",
      js_hooks: [],
      dependencies: [:card, :badge],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    metric_grid: %{
      name: "metric_grid",
      module: PhiaUi.Components.MetricGrid,
      template_file: "priv/templates/components/cards/metric_grid.ex",
      js_hooks: [],
      dependencies: [:stat_card, :card],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    chart_shell: %{
      name: "chart_shell",
      module: PhiaUi.Components.ChartShell,
      template_file: "priv/templates/components/data/chart_shell.ex",
      js_hooks: [],
      dependencies: [:card],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    chart: %{
      name: "chart",
      module: PhiaUi.Components.Chart,
      template_file: "priv/templates/components/data/chart.ex",
      js_hooks: ["PhiaChart"],
      dependencies: [:chart_shell],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # -------------------------------------------------------------------------
    # Wave 1 — High Priority Gap Components (2026-03-04)
    # -------------------------------------------------------------------------
    input_otp: %{
      name: "input_otp",
      module: PhiaUi.Components.InputOtp,
      template_file: "priv/templates/components/inputs/input_otp.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: "InputOTP",
      status: :implemented
    },
    spinner: %{
      name: "spinner",
      module: PhiaUi.Components.Spinner,
      template_file: "priv/templates/components/feedback/spinner.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    number_input: %{
      name: "number_input",
      module: PhiaUi.Components.NumberInput,
      template_file: "priv/templates/components/inputs/number_input.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    password_input: %{
      name: "password_input",
      module: PhiaUi.Components.PasswordInput,
      template_file: "priv/templates/components/inputs/password_input.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    copy_button: %{
      name: "copy_button",
      module: PhiaUi.Components.CopyButton,
      template_file: "priv/templates/components/buttons/copy_button.ex",
      js_hooks: ["PhiaCopyButton"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # -------------------------------------------------------------------------
    # Wave 2 — Medium Priority Gap Components (2026-03-04)
    # -------------------------------------------------------------------------
    segmented_control: %{
      name: "segmented_control",
      module: PhiaUi.Components.SegmentedControl,
      template_file: "priv/templates/components/inputs/segmented_control.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    chip: %{
      name: "chip",
      module: PhiaUi.Components.Chip,
      template_file: "priv/templates/components/inputs/chip.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    editable: %{
      name: "editable",
      module: PhiaUi.Components.Editable,
      template_file: "priv/templates/components/inputs/editable.ex",
      js_hooks: ["PhiaEditable"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    file_upload: %{
      name: "file_upload",
      module: PhiaUi.Components.FileUpload,
      template_file: "priv/templates/components/inputs/file_upload.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    menubar: %{
      name: "menubar",
      module: PhiaUi.Components.Menubar,
      template_file: "priv/templates/components/navigation/menubar.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Menubar",
      status: :implemented
    },

    # -------------------------------------------------------------------------
    # Wave 3 — Lower Priority Gap Components (2026-03-04)
    # -------------------------------------------------------------------------
    color_picker: %{
      name: "color_picker",
      module: PhiaUi.Components.ColorPicker,
      template_file: "priv/templates/components/inputs/color_picker.ex",
      js_hooks: ["PhiaColorPicker"],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    float_button: %{
      name: "float_button",
      module: PhiaUi.Components.FloatButton,
      template_file: "priv/templates/components/buttons/float_button.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    multi_select: %{
      name: "multi_select",
      module: PhiaUi.Components.MultiSelect,
      template_file: "priv/templates/components/inputs/multi_select.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    tree: %{
      name: "tree",
      module: PhiaUi.Components.Tree,
      template_file: "priv/templates/components/data/tree.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    back_top: %{
      name: "back_top",
      module: PhiaUi.Components.BackTop,
      template_file: "priv/templates/components/buttons/back_top.ex",
      js_hooks: ["PhiaBackTop"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # -------------------------------------------------------------------------
    # Wave 4 — UI Analysis Gap Components (2026-03-04)
    # -------------------------------------------------------------------------
    audio_player: %{
      name: "audio_player",
      module: PhiaUi.Components.AudioPlayer,
      template_file: "priv/templates/components/media/audio_player.ex",
      js_hooks: ["PhiaAudioPlayer"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    bottom_navigation: %{
      name: "bottom_navigation",
      module: PhiaUi.Components.BottomNavigation,
      template_file: "priv/templates/components/navigation/bottom_navigation.ex",
      js_hooks: [],
      dependencies: [],
      tier: :navigation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    week_day_picker: %{
      name: "week_day_picker",
      module: PhiaUi.Components.WeekDayPicker,
      template_file: "priv/templates/components/calendar/week_day_picker.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    qr_code: %{
      name: "qr_code",
      module: PhiaUi.Components.QrCode,
      template_file: "priv/templates/components/media/qr_code.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    toolbar: %{
      name: "toolbar",
      module: PhiaUi.Components.Toolbar,
      template_file: "priv/templates/components/navigation/toolbar.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Toolbar",
      status: :implemented
    },

    # -------------------------------------------------------------------------
    # Wave 5 — UI Analysis Gap Components (2026-03-04)
    # -------------------------------------------------------------------------
    avatar_group: %{
      name: "avatar_group",
      module: PhiaUi.Components.AvatarGroup,
      template_file: "priv/templates/components/display/avatar_group.ex",
      js_hooks: [],
      dependencies: [:avatar],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    selectable_card: %{
      name: "selectable_card",
      module: PhiaUi.Components.SelectableCard,
      template_file: "priv/templates/components/cards/selectable_card.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    input_addon: %{
      name: "input_addon",
      module: PhiaUi.Components.InputAddon,
      template_file: "priv/templates/components/inputs/input_addon.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    # Wave 6 — UI Analysis Gap Components /imgs/4 (2026-03-05)
    # -------------------------------------------------------------------------
    circular_progress: %{
      name: "circular_progress",
      module: PhiaUi.Components.CircularProgress,
      template_file: "priv/templates/components/feedback/circular_progress.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    event_calendar: %{
      name: "event_calendar",
      module: PhiaUi.Components.EventCalendar,
      template_file: "priv/templates/components/calendar/event_calendar.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    uptime_bar: %{
      name: "uptime_bar",
      module: PhiaUi.Components.UptimeBar,
      template_file: "priv/templates/components/data/uptime_bar.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    receipt_card: %{
      name: "receipt_card",
      module: PhiaUi.Components.ReceiptCard,
      template_file: "priv/templates/components/cards/receipt_card.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # ── Wave 7 (UI analysis /imgs/5) ─────────────────────────────────────────
    heatmap_calendar: %{
      name: "heatmap_calendar",
      module: PhiaUi.Components.HeatmapCalendar,
      template_file: "priv/templates/components/calendar/heatmap_calendar.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    sparkline_card: %{
      name: "sparkline_card",
      module: PhiaUi.Components.SparklineCard,
      template_file: "priv/templates/components/data/sparkline_card.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    gauge_chart: %{
      name: "gauge_chart",
      module: PhiaUi.Components.GaugeChart,
      template_file: "priv/templates/components/data/gauge_chart.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    gantt_chart: %{
      name: "gantt_chart",
      module: PhiaUi.Components.GanttChart,
      template_file: "priv/templates/components/data/gantt_chart.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    snackbar: %{
      name: "snackbar",
      module: PhiaUi.Components.Snackbar,
      template_file: "priv/templates/components/feedback/snackbar.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    time_picker: %{
      name: "time_picker",
      module: PhiaUi.Components.TimePicker,
      template_file: "priv/templates/components/calendar/time_picker.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    month_picker: %{
      name: "month_picker",
      module: PhiaUi.Components.MonthPicker,
      template_file: "priv/templates/components/calendar/month_picker.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    date_time_picker: %{
      name: "date_time_picker",
      module: PhiaUi.Components.DateTimePicker,
      template_file: "priv/templates/components/calendar/date_time_picker.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    week_picker: %{
      name: "week_picker",
      module: PhiaUi.Components.WeekPicker,
      template_file: "priv/templates/components/calendar/week_picker.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    year_picker: %{
      name: "year_picker",
      module: PhiaUi.Components.YearPicker,
      template_file: "priv/templates/components/calendar/year_picker.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    date_field: %{
      name: "date_field",
      module: PhiaUi.Components.DateField,
      template_file: "priv/templates/components/calendar/date_field.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    calendar_time_picker: %{
      name: "calendar_time_picker",
      module: PhiaUi.Components.CalendarTimePicker,
      template_file: "priv/templates/components/calendar/calendar_time_picker.ex",
      js_hooks: ["PhiaCalendar"],
      dependencies: [:calendar],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    date_range_presets: %{
      name: "date_range_presets",
      module: PhiaUi.Components.DateRangePresets,
      template_file: "priv/templates/components/calendar/date_range_presets.ex",
      js_hooks: ["PhiaCalendar"],
      dependencies: [:calendar],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    big_calendar: %{
      name: "big_calendar",
      module: PhiaUi.Components.BigCalendar,
      template_file: "priv/templates/components/calendar/big_calendar.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    calendar_week_view: %{
      name: "calendar_week_view",
      module: PhiaUi.Components.CalendarWeekView,
      template_file: "priv/templates/components/calendar/calendar_week_view.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    date_card: %{
      name: "date_card",
      module: PhiaUi.Components.DateCard,
      template_file: "priv/templates/components/calendar/date_card.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    date_strip: %{
      name: "date_strip",
      module: PhiaUi.Components.DateStrip,
      template_file: "priv/templates/components/calendar/date_strip.ex",
      js_hooks: [],
      dependencies: [:date_card],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    week_calendar: %{
      name: "week_calendar",
      module: PhiaUi.Components.WeekCalendar,
      template_file: "priv/templates/components/calendar/week_calendar.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    range_calendar: %{
      name: "range_calendar",
      module: PhiaUi.Components.RangeCalendar,
      template_file: "priv/templates/components/calendar/range_calendar.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: "Calendar",
      status: :implemented
    },
    time_slot_grid: %{
      name: "time_slot_grid",
      module: PhiaUi.Components.TimeSlotGrid,
      template_file: "priv/templates/components/calendar/time_slot_grid.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    wheel_picker: %{
      name: "wheel_picker",
      module: PhiaUi.Components.WheelPicker,
      template_file: "priv/templates/components/calendar/wheel_picker.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    multi_select_calendar: %{
      name: "multi_select_calendar",
      module: PhiaUi.Components.MultiSelectCalendar,
      template_file: "priv/templates/components/calendar/multi_select_calendar.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: "Calendar",
      status: :implemented
    },
    badge_calendar: %{
      name: "badge_calendar",
      module: PhiaUi.Components.BadgeCalendar,
      template_file: "priv/templates/components/calendar/badge_calendar.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    daily_agenda: %{
      name: "daily_agenda",
      module: PhiaUi.Components.DailyAgenda,
      template_file: "priv/templates/components/calendar/daily_agenda.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    schedule_event_card: %{
      name: "schedule_event_card",
      module: PhiaUi.Components.ScheduleEventCard,
      template_file: "priv/templates/components/calendar/schedule_event_card.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: "Card",
      status: :implemented
    },
    countdown_timer: %{
      name: "countdown_timer",
      module: PhiaUi.Components.CountdownTimer,
      template_file: "priv/templates/components/calendar/countdown_timer.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    time_slot_list: %{
      name: "time_slot_list",
      module: PhiaUi.Components.TimeSlotList,
      template_file: "priv/templates/components/calendar/time_slot_list.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    time_slider_picker: %{
      name: "time_slider_picker",
      module: PhiaUi.Components.TimeSliderPicker,
      template_file: "priv/templates/components/calendar/time_slider_picker.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # -------------------------------------------------------------------------
    # Wave — Eleken Calendar UI Gap Analysis (2026-03-05)
    # -------------------------------------------------------------------------
    booking_calendar: %{
      name: "booking_calendar",
      module: PhiaUi.Components.BookingCalendar,
      template_file: "priv/templates/components/calendar/booking_calendar.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    streak_calendar: %{
      name: "streak_calendar",
      module: PhiaUi.Components.StreakCalendar,
      template_file: "priv/templates/components/calendar/streak_calendar.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    schedule_view: %{
      name: "schedule_view",
      module: PhiaUi.Components.ScheduleView,
      template_file: "priv/templates/components/calendar/schedule_view.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    multi_month_calendar: %{
      name: "multi_month_calendar",
      module: PhiaUi.Components.MultiMonthCalendar,
      template_file: "priv/templates/components/calendar/multi_month_calendar.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # ── Layout Primitives (v0.1.6) ────────────────────────────────────────────
    box: %{
      name: "box",
      module: PhiaUi.Components.Layout.Box,
      template_file: "priv/templates/components/layout/box.ex",
      js_hooks: [],
      dependencies: [],
      tier: :layout,
      shadcn_equivalent: nil,
      status: :implemented
    },
    spacer: %{
      name: "spacer",
      module: PhiaUi.Components.Layout.Spacer,
      template_file: "priv/templates/components/layout/spacer.ex",
      js_hooks: [],
      dependencies: [],
      tier: :layout,
      shadcn_equivalent: nil,
      status: :implemented
    },
    center: %{
      name: "center",
      module: PhiaUi.Components.Layout.Center,
      template_file: "priv/templates/components/layout/center.ex",
      js_hooks: [],
      dependencies: [],
      tier: :layout,
      shadcn_equivalent: nil,
      status: :implemented
    },
    section: %{
      name: "section",
      module: PhiaUi.Components.Layout.Section,
      template_file: "priv/templates/components/layout/section.ex",
      js_hooks: [],
      dependencies: [],
      tier: :layout,
      shadcn_equivalent: nil,
      status: :implemented
    },
    sticky: %{
      name: "sticky",
      module: PhiaUi.Components.Layout.Sticky,
      template_file: "priv/templates/components/layout/sticky.ex",
      js_hooks: [],
      dependencies: [],
      tier: :layout,
      shadcn_equivalent: nil,
      status: :implemented
    },
    fixed_bar: %{
      name: "fixed_bar",
      module: PhiaUi.Components.Layout.FixedBar,
      template_file: "priv/templates/components/layout/fixed_bar.ex",
      js_hooks: [],
      dependencies: [],
      tier: :layout,
      shadcn_equivalent: nil,
      status: :implemented
    },
    layout_flex: %{
      name: "flex",
      module: PhiaUi.Components.Layout.Flex,
      template_file: "priv/templates/components/layout/flex.ex",
      js_hooks: [],
      dependencies: [],
      tier: :layout,
      shadcn_equivalent: nil,
      status: :implemented
    },
    stack: %{
      name: "stack",
      module: PhiaUi.Components.Layout.Stack,
      template_file: "priv/templates/components/layout/stack.ex",
      js_hooks: [],
      dependencies: [],
      tier: :layout,
      shadcn_equivalent: nil,
      status: :implemented
    },
    layout_wrap: %{
      name: "wrap",
      module: PhiaUi.Components.Layout.Wrap,
      template_file: "priv/templates/components/layout/wrap.ex",
      js_hooks: [],
      dependencies: [],
      tier: :layout,
      shadcn_equivalent: nil,
      status: :implemented
    },
    layout_grid: %{
      name: "grid",
      module: PhiaUi.Components.Layout.Grid,
      template_file: "priv/templates/components/layout/grid.ex",
      js_hooks: [],
      dependencies: [],
      tier: :layout,
      shadcn_equivalent: nil,
      status: :implemented
    },
    simple_grid: %{
      name: "simple_grid",
      module: PhiaUi.Components.Layout.SimpleGrid,
      template_file: "priv/templates/components/layout/simple_grid.ex",
      js_hooks: [],
      dependencies: [],
      tier: :layout,
      shadcn_equivalent: nil,
      status: :implemented
    },
    container: %{
      name: "container",
      module: PhiaUi.Components.Layout.Container,
      template_file: "priv/templates/components/layout/container.ex",
      js_hooks: [],
      dependencies: [],
      tier: :layout,
      shadcn_equivalent: nil,
      status: :implemented
    },
    layout_divider: %{
      name: "divider",
      module: PhiaUi.Components.Layout.Divider,
      template_file: "priv/templates/components/layout/divider.ex",
      js_hooks: [],
      dependencies: [],
      tier: :layout,
      shadcn_equivalent: "Separator",
      status: :implemented
    },
    media_object: %{
      name: "media_object",
      module: PhiaUi.Components.Layout.MediaObject,
      template_file: "priv/templates/components/layout/media_object.ex",
      js_hooks: [],
      dependencies: [],
      tier: :layout,
      shadcn_equivalent: nil,
      status: :implemented
    },
    masonry_grid: %{
      name: "masonry_grid",
      module: PhiaUi.Components.Layout.MasonryGrid,
      template_file: "priv/templates/components/layout/masonry_grid.ex",
      js_hooks: [],
      dependencies: [],
      tier: :layout,
      shadcn_equivalent: nil,
      status: :implemented
    },
    description_list: %{
      name: "description_list",
      module: PhiaUi.Components.Layout.DescriptionList,
      template_file: "priv/templates/components/layout/description_list.ex",
      js_hooks: [],
      dependencies: [],
      tier: :layout,
      shadcn_equivalent: nil,
      status: :implemented
    },
    page_layout: %{
      name: "page_layout",
      module: PhiaUi.Components.Layout.PageLayout,
      template_file: "priv/templates/components/layout/page_layout.ex",
      js_hooks: [],
      dependencies: [],
      tier: :layout,
      shadcn_equivalent: nil,
      status: :implemented
    },
    split_layout: %{
      name: "split_layout",
      module: PhiaUi.Components.Layout.SplitLayout,
      template_file: "priv/templates/components/layout/split_layout.ex",
      js_hooks: [],
      dependencies: [],
      tier: :layout,
      shadcn_equivalent: nil,
      status: :implemented
    },
    page_header: %{
      name: "page_header",
      module: PhiaUi.Components.Layout.PageHeader,
      template_file: "priv/templates/components/layout/page_header.ex",
      js_hooks: [],
      dependencies: [],
      tier: :layout,
      shadcn_equivalent: nil,
      status: :implemented
    },
    nav_list: %{
      name: "nav_list",
      module: PhiaUi.Components.Layout.NavList,
      template_file: "priv/templates/components/layout/nav_list.ex",
      js_hooks: [],
      dependencies: [],
      tier: :layout,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # -------------------------------------------------------------------------
    # Card Suite — 15 new components (2026-03-06)
    # -------------------------------------------------------------------------
    image_card: %{
      name: "image_card",
      module: PhiaUi.Components.ImageCard,
      template_file: "priv/templates/components/cards/image_card.ex",
      js_hooks: [],
      dependencies: [:card],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    profile_card: %{
      name: "profile_card",
      module: PhiaUi.Components.ProfileCard,
      template_file: "priv/templates/components/cards/profile_card.ex",
      js_hooks: [],
      dependencies: [:card, :avatar],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    feature_card: %{
      name: "feature_card",
      module: PhiaUi.Components.FeatureCard,
      template_file: "priv/templates/components/cards/feature_card.ex",
      js_hooks: [],
      dependencies: [:card],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    article_card: %{
      name: "article_card",
      module: PhiaUi.Components.ArticleCard,
      template_file: "priv/templates/components/cards/article_card.ex",
      js_hooks: [],
      dependencies: [:card, :badge, :avatar],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    testimonial_card: %{
      name: "testimonial_card",
      module: PhiaUi.Components.TestimonialCard,
      template_file: "priv/templates/components/cards/testimonial_card.ex",
      js_hooks: [],
      dependencies: [:card, :avatar],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    pricing_card: %{
      name: "pricing_card",
      module: PhiaUi.Components.PricingCard,
      template_file: "priv/templates/components/cards/pricing_card.ex",
      js_hooks: [],
      dependencies: [:card, :badge, :button],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    product_card: %{
      name: "product_card",
      module: PhiaUi.Components.ProductCard,
      template_file: "priv/templates/components/cards/product_card.ex",
      js_hooks: [],
      dependencies: [:card, :badge, :button],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    progress_card: %{
      name: "progress_card",
      module: PhiaUi.Components.ProgressCard,
      template_file: "priv/templates/components/cards/progress_card.ex",
      js_hooks: [],
      dependencies: [:card, :progress],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    notification_card: %{
      name: "notification_card",
      module: PhiaUi.Components.NotificationCard,
      template_file: "priv/templates/components/cards/notification_card.ex",
      js_hooks: [],
      dependencies: [:card],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    file_card: %{
      name: "file_card",
      module: PhiaUi.Components.FileCard,
      template_file: "priv/templates/components/cards/file_card.ex",
      js_hooks: [],
      dependencies: [:card, :badge],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    event_card: %{
      name: "event_card",
      module: PhiaUi.Components.EventCard,
      template_file: "priv/templates/components/cards/event_card.ex",
      js_hooks: [],
      dependencies: [:card, :avatar],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    team_card: %{
      name: "team_card",
      module: PhiaUi.Components.TeamCard,
      template_file: "priv/templates/components/cards/team_card.ex",
      js_hooks: [],
      dependencies: [:card, :avatar, :badge],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    link_preview_card: %{
      name: "link_preview_card",
      module: PhiaUi.Components.LinkPreviewCard,
      template_file: "priv/templates/components/cards/link_preview_card.ex",
      js_hooks: [],
      dependencies: [:card],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    color_swatch_card: %{
      name: "color_swatch_card",
      module: PhiaUi.Components.ColorSwatchCard,
      template_file: "priv/templates/components/cards/color_swatch_card.ex",
      js_hooks: [],
      dependencies: [:copy_button],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    cta_card: %{
      name: "cta_card",
      module: PhiaUi.Components.CtaCard,
      template_file: "priv/templates/components/cards/cta_card.ex",
      js_hooks: [],
      dependencies: [:card],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # ── Typography Suite (v0.1.7) ─────────────────────────────────────────────
    heading: %{
      name: "heading",
      module: PhiaUi.Components.Typography,
      template_file: "priv/templates/components/typography/typography.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    display_text: %{
      name: "display_text",
      module: PhiaUi.Components.Typography,
      template_file: "priv/templates/components/typography/typography.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    text: %{
      name: "text",
      module: PhiaUi.Components.Typography,
      template_file: "priv/templates/components/typography/typography.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    paragraph: %{
      name: "paragraph",
      module: PhiaUi.Components.Typography,
      template_file: "priv/templates/components/typography/typography.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    lead: %{
      name: "lead",
      module: PhiaUi.Components.Typography,
      template_file: "priv/templates/components/typography/typography.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    blockquote: %{
      name: "blockquote",
      module: PhiaUi.Components.Typography,
      template_file: "priv/templates/components/typography/typography.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    inline_code: %{
      name: "inline_code",
      module: PhiaUi.Components.Typography,
      template_file: "priv/templates/components/typography/typography.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    code_block: %{
      name: "code_block",
      module: PhiaUi.Components.Typography,
      template_file: "priv/templates/components/typography/typography.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    mark: %{
      name: "mark",
      module: PhiaUi.Components.Typography,
      template_file: "priv/templates/components/typography/typography.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    text_link: %{
      name: "text_link",
      module: PhiaUi.Components.Typography,
      template_file: "priv/templates/components/typography/typography.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    overline: %{
      name: "overline",
      module: PhiaUi.Components.Typography,
      template_file: "priv/templates/components/typography/typography.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    caption: %{
      name: "caption",
      module: PhiaUi.Components.Typography,
      template_file: "priv/templates/components/typography/typography.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    abbr: %{
      name: "abbr",
      module: PhiaUi.Components.Typography,
      template_file: "priv/templates/components/typography/typography.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    prose_list: %{
      name: "prose_list",
      module: PhiaUi.Components.Typography,
      template_file: "priv/templates/components/typography/typography.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    ordered_list: %{
      name: "ordered_list",
      module: PhiaUi.Components.Typography,
      template_file: "priv/templates/components/typography/typography.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    gradient_text: %{
      name: "gradient_text",
      module: PhiaUi.Components.Typography,
      template_file: "priv/templates/components/typography/typography.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    truncated_text: %{
      name: "truncated_text",
      module: PhiaUi.Components.Typography,
      template_file: "priv/templates/components/typography/typography.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    prose: %{
      name: "prose",
      module: PhiaUi.Components.Typography,
      template_file: "priv/templates/components/typography/typography.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # ── v0.1.7 Widget Wave — 12 new components (2026-03-06) ──────────────────
    badge_delta: %{
      name: "badge_delta",
      module: PhiaUi.Components.BadgeDelta,
      template_file: "priv/templates/components/data/badge_delta.ex",
      js_hooks: [],
      dependencies: [:icon],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    bar_list: %{
      name: "bar_list",
      module: PhiaUi.Components.BarList,
      template_file: "priv/templates/components/data/bar_list.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    category_bar: %{
      name: "category_bar",
      module: PhiaUi.Components.CategoryBar,
      template_file: "priv/templates/components/data/category_bar.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    meter_group: %{
      name: "meter_group",
      module: PhiaUi.Components.MeterGroup,
      template_file: "priv/templates/components/data/meter_group.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    funnel_chart: %{
      name: "funnel_chart",
      module: PhiaUi.Components.FunnelChart,
      template_file: "priv/templates/components/data/funnel_chart.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    nps_widget: %{
      name: "nps_widget",
      module: PhiaUi.Components.NpsWidget,
      template_file: "priv/templates/components/data/nps_widget.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    comparison_table: %{
      name: "comparison_table",
      module: PhiaUi.Components.ComparisonTable,
      template_file: "priv/templates/components/data/comparison_table.ex",
      js_hooks: [],
      dependencies: [:icon],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    leaderboard: %{
      name: "leaderboard",
      module: PhiaUi.Components.Leaderboard,
      template_file: "priv/templates/components/data/leaderboard.ex",
      js_hooks: [],
      dependencies: [:badge_delta],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    watermark: %{
      name: "watermark",
      module: PhiaUi.Components.Watermark,
      template_file: "priv/templates/components/media/watermark.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    result_state: %{
      name: "result_state",
      module: PhiaUi.Components.ResultState,
      template_file: "priv/templates/components/feedback/result_state.ex",
      js_hooks: [],
      dependencies: [:icon],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    popconfirm: %{
      name: "popconfirm",
      module: PhiaUi.Components.Popconfirm,
      template_file: "priv/templates/components/feedback/popconfirm.ex",
      js_hooks: [],
      dependencies: [:icon, :button],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    image_comparison: %{
      name: "image_comparison",
      module: PhiaUi.Components.ImageComparison,
      template_file: "priv/templates/components/media/image_comparison.ex",
      js_hooks: ["PhiaImageComparison"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # ── Input & Upload Wave (v0.1.7+) ─────────────────────────────────────────
    search_input: %{
      name: "search_input",
      module: PhiaUi.Components.SearchInput,
      template_file: "priv/templates/components/inputs/search_input.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    clearable_input: %{
      name: "clearable_input",
      module: PhiaUi.Components.ClearableInput,
      template_file: "priv/templates/components/inputs/clearable_input.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    textarea_counter: %{
      name: "textarea_counter",
      module: PhiaUi.Components.TextareaCounter,
      template_file: "priv/templates/components/inputs/textarea_counter.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    copy_input: %{
      name: "copy_input",
      module: PhiaUi.Components.CopyInput,
      template_file: "priv/templates/components/inputs/copy_input.ex",
      js_hooks: ["PhiaCopyButton"],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    url_input: %{
      name: "url_input",
      module: PhiaUi.Components.UrlInput,
      template_file: "priv/templates/components/inputs/url_input.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    phone_input: %{
      name: "phone_input",
      module: PhiaUi.Components.PhoneInput,
      template_file: "priv/templates/components/inputs/phone_input.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    input_group: %{
      name: "input_group",
      module: PhiaUi.Components.InputGroup,
      template_file: "priv/templates/components/inputs/input_group.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: "InputGroup",
      status: :implemented
    },
    inline_search: %{
      name: "inline_search",
      module: PhiaUi.Components.InlineSearch,
      template_file: "priv/templates/components/inputs/inline_search.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    unit_input: %{
      name: "unit_input",
      module: PhiaUi.Components.UnitInput,
      template_file: "priv/templates/components/inputs/unit_input.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    autocomplete_input: %{
      name: "autocomplete_input",
      module: PhiaUi.Components.AutocompleteInput,
      template_file: "priv/templates/components/inputs/autocomplete_input.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: "Combobox",
      status: :implemented
    },
    avatar_upload: %{
      name: "avatar_upload",
      module: PhiaUi.Components.AvatarUpload,
      template_file: "priv/templates/components/inputs/avatar_upload.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    upload_button: %{
      name: "upload_button",
      module: PhiaUi.Components.UploadButton,
      template_file: "priv/templates/components/inputs/upload_button.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    image_gallery_upload: %{
      name: "image_gallery_upload",
      module: PhiaUi.Components.ImageGalleryUpload,
      template_file: "priv/templates/components/inputs/image_gallery_upload.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    document_upload: %{
      name: "document_upload",
      module: PhiaUi.Components.DocumentUpload,
      template_file: "priv/templates/components/inputs/document_upload.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    upload_progress: %{
      name: "upload_progress",
      module: PhiaUi.Components.UploadProgress,
      template_file: "priv/templates/components/inputs/upload_progress.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    upload_card: %{
      name: "upload_card",
      module: PhiaUi.Components.UploadCard,
      template_file: "priv/templates/components/inputs/upload_card.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    upload_queue: %{
      name: "upload_queue",
      module: PhiaUi.Components.UploadQueue,
      template_file: "priv/templates/components/inputs/upload_queue.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: nil,
      status: :implemented
    },
    fullscreen_drop: %{
      name: "fullscreen_drop",
      module: PhiaUi.Components.FullscreenDrop,
      template_file: "priv/templates/components/inputs/fullscreen_drop.ex",
      js_hooks: ["PhiaFullscreenDrop"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # ── Animation Suite (v0.1.7) ──────────────────────────────────────────────
    marquee: %{
      name: "marquee",
      module: PhiaUi.Components.Animation,
      template_file: "priv/templates/components/animation/animation.ex",
      js_hooks: ["PhiaMarquee"],
      dependencies: [],
      tier: :animation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    orbit: %{
      name: "orbit",
      module: PhiaUi.Components.Animation,
      template_file: "priv/templates/components/animation/animation.ex",
      js_hooks: [],
      dependencies: [],
      tier: :animation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    aurora: %{
      name: "aurora",
      module: PhiaUi.Components.Animation,
      template_file: "priv/templates/components/animation/animation.ex",
      js_hooks: [],
      dependencies: [],
      tier: :animation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    meteor_shower: %{
      name: "meteor_shower",
      module: PhiaUi.Components.Animation,
      template_file: "priv/templates/components/animation/animation.ex",
      js_hooks: [],
      dependencies: [],
      tier: :animation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    dot_pattern: %{
      name: "dot_pattern",
      module: PhiaUi.Components.Animation,
      template_file: "priv/templates/components/animation/animation.ex",
      js_hooks: [],
      dependencies: [],
      tier: :animation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    grid_pattern: %{
      name: "grid_pattern",
      module: PhiaUi.Components.Animation,
      template_file: "priv/templates/components/animation/animation.ex",
      js_hooks: [],
      dependencies: [],
      tier: :animation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    ripple_bg: %{
      name: "ripple_bg",
      module: PhiaUi.Components.Animation,
      template_file: "priv/templates/components/animation/animation.ex",
      js_hooks: [],
      dependencies: [],
      tier: :animation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    shimmer_text: %{
      name: "shimmer_text",
      module: PhiaUi.Components.Animation,
      template_file: "priv/templates/components/animation/animation.ex",
      js_hooks: [],
      dependencies: [],
      tier: :animation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    typewriter: %{
      name: "typewriter",
      module: PhiaUi.Components.Animation,
      template_file: "priv/templates/components/animation/animation.ex",
      js_hooks: ["PhiaTypewriter"],
      dependencies: [],
      tier: :animation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    word_rotate: %{
      name: "word_rotate",
      module: PhiaUi.Components.Animation,
      template_file: "priv/templates/components/animation/animation.ex",
      js_hooks: ["PhiaWordRotate"],
      dependencies: [],
      tier: :animation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    text_scramble: %{
      name: "text_scramble",
      module: PhiaUi.Components.Animation,
      template_file: "priv/templates/components/animation/animation.ex",
      js_hooks: ["PhiaTextScramble"],
      dependencies: [],
      tier: :animation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    fade_in: %{
      name: "fade_in",
      module: PhiaUi.Components.Animation,
      template_file: "priv/templates/components/animation/animation.ex",
      js_hooks: ["PhiaScrollReveal"],
      dependencies: [],
      tier: :animation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    float: %{
      name: "float",
      module: PhiaUi.Components.Animation,
      template_file: "priv/templates/components/animation/animation.ex",
      js_hooks: [],
      dependencies: [],
      tier: :animation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    spotlight: %{
      name: "spotlight",
      module: PhiaUi.Components.Animation,
      template_file: "priv/templates/components/animation/animation.ex",
      js_hooks: ["PhiaSpotlight"],
      dependencies: [],
      tier: :animation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    tilt_card: %{
      name: "tilt_card",
      module: PhiaUi.Components.Animation,
      template_file: "priv/templates/components/animation/animation.ex",
      js_hooks: ["PhiaTiltCard"],
      dependencies: [],
      tier: :animation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    number_ticker: %{
      name: "number_ticker",
      module: PhiaUi.Components.Animation,
      template_file: "priv/templates/components/animation/animation.ex",
      js_hooks: ["PhiaNumberTicker"],
      dependencies: [],
      tier: :animation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    animated_border: %{
      name: "animated_border",
      module: PhiaUi.Components.Animation,
      template_file: "priv/templates/components/animation/animation.ex",
      js_hooks: [],
      dependencies: [],
      tier: :animation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    pulse_ring: %{
      name: "pulse_ring",
      module: PhiaUi.Components.Animation,
      template_file: "priv/templates/components/animation/animation.ex",
      js_hooks: [],
      dependencies: [],
      tier: :animation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    typing_indicator: %{
      name: "typing_indicator",
      module: PhiaUi.Components.Animation,
      template_file: "priv/templates/components/animation/animation.ex",
      js_hooks: [],
      dependencies: [],
      tier: :animation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    wave_loader: %{
      name: "wave_loader",
      module: PhiaUi.Components.Animation,
      template_file: "priv/templates/components/animation/animation.ex",
      js_hooks: [],
      dependencies: [],
      tier: :animation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    confetti_burst: %{
      name: "confetti_burst",
      module: PhiaUi.Components.Animation,
      template_file: "priv/templates/components/animation/animation.ex",
      js_hooks: ["PhiaConfetti"],
      dependencies: [],
      tier: :animation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    particle_bg: %{
      name: "particle_bg",
      module: PhiaUi.Components.Animation,
      template_file: "priv/templates/components/animation/animation.ex",
      js_hooks: ["PhiaParticleBg"],
      dependencies: [],
      tier: :animation,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # ── Chart Suite (v0.1.7+) — 16 new SVG chart components ──────────────────
    bar_chart: %{
      name: "bar_chart",
      module: PhiaUi.Components.BarChart,
      template_file: "priv/templates/components/data/bar_chart.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    line_chart: %{
      name: "line_chart",
      module: PhiaUi.Components.LineChart,
      template_file: "priv/templates/components/data/line_chart.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    area_chart: %{
      name: "area_chart",
      module: PhiaUi.Components.AreaChart,
      template_file: "priv/templates/components/data/area_chart.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    pie_chart: %{
      name: "pie_chart",
      module: PhiaUi.Components.PieChart,
      template_file: "priv/templates/components/data/pie_chart.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    donut_chart: %{
      name: "donut_chart",
      module: PhiaUi.Components.DonutChart,
      template_file: "priv/templates/components/data/donut_chart.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    radar_chart: %{
      name: "radar_chart",
      module: PhiaUi.Components.RadarChart,
      template_file: "priv/templates/components/data/radar_chart.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    scatter_chart: %{
      name: "scatter_chart",
      module: PhiaUi.Components.ScatterChart,
      template_file: "priv/templates/components/data/scatter_chart.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    bubble_chart: %{
      name: "bubble_chart",
      module: PhiaUi.Components.BubbleChart,
      template_file: "priv/templates/components/data/bubble_chart.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    radial_bar_chart: %{
      name: "radial_bar_chart",
      module: PhiaUi.Components.RadialBarChart,
      template_file: "priv/templates/components/data/radial_bar_chart.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    histogram_chart: %{
      name: "histogram_chart",
      module: PhiaUi.Components.HistogramChart,
      template_file: "priv/templates/components/data/histogram_chart.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    waterfall_chart: %{
      name: "waterfall_chart",
      module: PhiaUi.Components.WaterfallChart,
      template_file: "priv/templates/components/data/waterfall_chart.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    heatmap_chart: %{
      name: "heatmap_chart",
      module: PhiaUi.Components.HeatmapChart,
      template_file: "priv/templates/components/data/heatmap_chart.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    bullet_chart: %{
      name: "bullet_chart",
      module: PhiaUi.Components.BulletChart,
      template_file: "priv/templates/components/data/bullet_chart.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    slope_chart: %{
      name: "slope_chart",
      module: PhiaUi.Components.SlopeChart,
      template_file: "priv/templates/components/data/slope_chart.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    treemap_chart: %{
      name: "treemap_chart",
      module: PhiaUi.Components.TreemapChart,
      template_file: "priv/templates/components/data/treemap_chart.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    timeline_chart: %{
      name: "timeline_chart",
      module: PhiaUi.Components.TimelineChart,
      template_file: "priv/templates/components/data/timeline_chart.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # ── Interaction / DnD Suite (v0.1.7) ─────────────────────────────────────
    drag_handle: %{
      name: "drag_handle",
      module: PhiaUi.Components.Sortable,
      template_file: "priv/templates/components/interaction/sortable.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    drop_indicator: %{
      name: "drop_indicator",
      module: PhiaUi.Components.Sortable,
      template_file: "priv/templates/components/interaction/sortable.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    sortable_list: %{
      name: "sortable_list",
      module: PhiaUi.Components.Sortable,
      template_file: "priv/templates/components/interaction/sortable.ex",
      js_hooks: ["PhiaSortable"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    sortable_item: %{
      name: "sortable_item",
      module: PhiaUi.Components.Sortable,
      template_file: "priv/templates/components/interaction/sortable.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    sortable_grid: %{
      name: "sortable_grid",
      module: PhiaUi.Components.SortableGrid,
      template_file: "priv/templates/components/interaction/sortable_grid.ex",
      js_hooks: ["PhiaSortableGrid"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    sortable_grid_item: %{
      name: "sortable_grid_item",
      module: PhiaUi.Components.SortableGrid,
      template_file: "priv/templates/components/interaction/sortable_grid.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    kanban_board: %{
      name: "kanban_board",
      module: PhiaUi.Components.KanbanBoard,
      template_file: "priv/templates/components/data/kanban_board.ex",
      js_hooks: ["PhiaKanban"],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    kanban_column: %{
      name: "kanban_column",
      module: PhiaUi.Components.KanbanBoard,
      template_file: "priv/templates/components/data/kanban_board.ex",
      js_hooks: [],
      dependencies: [:kanban_board],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    kanban_card: %{
      name: "kanban_card",
      module: PhiaUi.Components.KanbanBoard,
      template_file: "priv/templates/components/data/kanban_board.ex",
      js_hooks: [],
      dependencies: [:kanban_column],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    drop_zone: %{
      name: "drop_zone",
      module: PhiaUi.Components.DropZone,
      template_file: "priv/templates/components/interaction/drop_zone.ex",
      js_hooks: ["PhiaDropZone"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    drag_transfer_list: %{
      name: "drag_transfer_list",
      module: PhiaUi.Components.DropZone,
      template_file: "priv/templates/components/interaction/drop_zone.ex",
      js_hooks: ["PhiaDragTransferList"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    multi_drag_list: %{
      name: "multi_drag_list",
      module: PhiaUi.Components.MultiDrag,
      template_file: "priv/templates/components/interaction/multi_drag.ex",
      js_hooks: ["PhiaMultiDrag"],
      dependencies: [:sortable_item],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    draggable_tree: %{
      name: "draggable_tree",
      module: PhiaUi.Components.DraggableTree,
      template_file: "priv/templates/components/interaction/draggable_tree.ex",
      js_hooks: ["PhiaDraggableTree"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    draggable_tree_node: %{
      name: "draggable_tree_node",
      module: PhiaUi.Components.DraggableTree,
      template_file: "priv/templates/components/interaction/draggable_tree.ex",
      js_hooks: [],
      dependencies: [:draggable_tree],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # ── Editor Suite — 19 new components (v0.1.7+) ───────────────────────────
    # TipTap-inspired (most popular rich text editor, 2.5M+ weekly npm downloads)
    # All components in PhiaUi.Components.Editor — priv/templates/components/editor/editor.ex

    # Group A — Toolbar Primitives (no JS hooks)
    editor_toolbar: %{
      name: "editor_toolbar",
      module: PhiaUi.Components.Editor,
      template_file: "priv/templates/components/editor/editor.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    toolbar_button: %{
      name: "toolbar_button",
      module: PhiaUi.Components.Editor,
      template_file: "priv/templates/components/editor/editor.ex",
      js_hooks: [],
      dependencies: [:editor_toolbar],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    toolbar_group: %{
      name: "toolbar_group",
      module: PhiaUi.Components.Editor,
      template_file: "priv/templates/components/editor/editor.ex",
      js_hooks: [],
      dependencies: [:editor_toolbar],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    toolbar_separator: %{
      name: "toolbar_separator",
      module: PhiaUi.Components.Editor,
      template_file: "priv/templates/components/editor/editor.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # Group B — Floating / Contextual (JS hooks)
    bubble_menu: %{
      name: "bubble_menu",
      module: PhiaUi.Components.Editor,
      template_file: "priv/templates/components/editor/editor.ex",
      js_hooks: ["PhiaBubbleMenu"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    floating_menu: %{
      name: "floating_menu",
      module: PhiaUi.Components.Editor,
      template_file: "priv/templates/components/editor/editor.ex",
      js_hooks: ["PhiaFloatingMenu"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    slash_command_menu: %{
      name: "slash_command_menu",
      module: PhiaUi.Components.Editor,
      template_file: "priv/templates/components/editor/editor.ex",
      js_hooks: ["PhiaSlashCommand"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # Group C — Enhanced Inline Editing
    inline_edit: %{
      name: "inline_edit",
      module: PhiaUi.Components.Editor,
      template_file: "priv/templates/components/editor/editor.ex",
      js_hooks: ["PhiaEditable"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    inline_edit_group: %{
      name: "inline_edit_group",
      module: PhiaUi.Components.Editor,
      template_file: "priv/templates/components/editor/editor.ex",
      js_hooks: [],
      dependencies: [:inline_edit],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # Group D — Rich Text Utilities
    editor_color_picker: %{
      name: "editor_color_picker",
      module: PhiaUi.Components.Editor,
      template_file: "priv/templates/components/editor/editor.ex",
      js_hooks: ["PhiaEditorColorPicker"],
      dependencies: [:editor_toolbar],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    editor_toolbar_dropdown: %{
      name: "editor_toolbar_dropdown",
      module: PhiaUi.Components.Editor,
      template_file: "priv/templates/components/editor/editor.ex",
      js_hooks: ["PhiaEditorDropdown"],
      dependencies: [:editor_toolbar],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    editor_link_dialog: %{
      name: "editor_link_dialog",
      module: PhiaUi.Components.Editor,
      template_file: "priv/templates/components/editor/editor.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    editor_code_block: %{
      name: "editor_code_block",
      module: PhiaUi.Components.Editor,
      template_file: "priv/templates/components/editor/editor.ex",
      js_hooks: ["PhiaCopyButton"],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    editor_character_count: %{
      name: "editor_character_count",
      module: PhiaUi.Components.Editor,
      template_file: "priv/templates/components/editor/editor.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    markdown_editor: %{
      name: "markdown_editor",
      module: PhiaUi.Components.Editor,
      template_file: "priv/templates/components/editor/editor.ex",
      js_hooks: ["PhiaMarkdownEditor"],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },
    rich_text_viewer: %{
      name: "rich_text_viewer",
      module: PhiaUi.Components.Editor,
      template_file: "priv/templates/components/editor/editor.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    editor_find_replace: %{
      name: "editor_find_replace",
      module: PhiaUi.Components.Editor,
      template_file: "priv/templates/components/editor/editor.ex",
      js_hooks: ["PhiaEditorFindReplace"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    editor_word_count: %{
      name: "editor_word_count",
      module: PhiaUi.Components.Editor,
      template_file: "priv/templates/components/editor/editor.ex",
      js_hooks: [],
      dependencies: [],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # Bonus — TipTap-Inspired Full Editor
    advanced_editor: %{
      name: "advanced_editor",
      module: PhiaUi.Components.Editor,
      template_file: "priv/templates/components/editor/editor.ex",
      js_hooks: [
        "PhiaAdvancedEditor",
        "PhiaBubbleMenu",
        "PhiaEditorColorPicker",
        "PhiaEditorDropdown",
        "PhiaEditorFindReplace"
      ],
      dependencies: [
        :editor_toolbar, :toolbar_button, :toolbar_group, :toolbar_separator,
        :bubble_menu, :editor_toolbar_dropdown, :editor_color_picker,
        :editor_link_dialog, :editor_find_replace, :editor_word_count
      ],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # ── Menu Suite (v0.1.7) ───────────────────────────────────────────────────
    # 39 new components across navigation + overlay extensions

    # Group: Dot Navigation
    dot_navigation: %{
      name: "dot_navigation",
      module: PhiaUi.Components.DotNavigation,
      template_file: "priv/templates/components/navigation/dot_navigation.ex",
      js_hooks: [],
      dependencies: [],
      tier: :navigation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    dot_navigation_item: %{
      name: "dot_navigation_item",
      module: PhiaUi.Components.DotNavigation,
      template_file: "priv/templates/components/navigation/dot_navigation.ex",
      js_hooks: [],
      dependencies: [:dot_navigation],
      tier: :navigation,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # Group: Chip Nav
    chip_nav: %{
      name: "chip_nav",
      module: PhiaUi.Components.ChipNav,
      template_file: "priv/templates/components/navigation/chip_nav.ex",
      js_hooks: [],
      dependencies: [],
      tier: :navigation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    chip_nav_item: %{
      name: "chip_nav_item",
      module: PhiaUi.Components.ChipNav,
      template_file: "priv/templates/components/navigation/chip_nav.ex",
      js_hooks: [],
      dependencies: [:chip_nav],
      tier: :navigation,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # Group: Floating Nav
    floating_nav: %{
      name: "floating_nav",
      module: PhiaUi.Components.FloatingNav,
      template_file: "priv/templates/components/navigation/floating_nav.ex",
      js_hooks: [],
      dependencies: [],
      tier: :navigation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    floating_nav_item: %{
      name: "floating_nav_item",
      module: PhiaUi.Components.FloatingNav,
      template_file: "priv/templates/components/navigation/floating_nav.ex",
      js_hooks: [],
      dependencies: [:floating_nav],
      tier: :navigation,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # Group: Dock
    dock: %{
      name: "dock",
      module: PhiaUi.Components.Dock,
      template_file: "priv/templates/components/navigation/dock.ex",
      js_hooks: [],
      dependencies: [],
      tier: :navigation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    dock_item: %{
      name: "dock_item",
      module: PhiaUi.Components.Dock,
      template_file: "priv/templates/components/navigation/dock.ex",
      js_hooks: [],
      dependencies: [:dock],
      tier: :navigation,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # Group: Nav Link
    nav_link: %{
      name: "nav_link",
      module: PhiaUi.Components.NavLink,
      template_file: "priv/templates/components/navigation/nav_link.ex",
      js_hooks: [],
      dependencies: [],
      tier: :navigation,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # Group: Vertical Nav
    vertical_nav: %{
      name: "vertical_nav",
      module: PhiaUi.Components.VerticalNav,
      template_file: "priv/templates/components/navigation/vertical_nav.ex",
      js_hooks: [],
      dependencies: [],
      tier: :navigation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    vertical_nav_item: %{
      name: "vertical_nav_item",
      module: PhiaUi.Components.VerticalNav,
      template_file: "priv/templates/components/navigation/vertical_nav.ex",
      js_hooks: [],
      dependencies: [:vertical_nav],
      tier: :navigation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    vertical_nav_group: %{
      name: "vertical_nav_group",
      module: PhiaUi.Components.VerticalNav,
      template_file: "priv/templates/components/navigation/vertical_nav.ex",
      js_hooks: [],
      dependencies: [:vertical_nav],
      tier: :navigation,
      shadcn_equivalent: nil,
      status: :implemented
    },
    vertical_nav_separator: %{
      name: "vertical_nav_separator",
      module: PhiaUi.Components.VerticalNav,
      template_file: "priv/templates/components/navigation/vertical_nav.ex",
      js_hooks: [],
      dependencies: [:vertical_nav],
      tier: :navigation,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # Group: App Shell
    app_shell: %{
      name: "app_shell",
      module: PhiaUi.Components.AppShell,
      template_file: "priv/templates/components/navigation/app_shell.ex",
      js_hooks: [],
      dependencies: [],
      tier: :shell,
      shadcn_equivalent: nil,
      status: :implemented
    },
    app_shell_header: %{
      name: "app_shell_header",
      module: PhiaUi.Components.AppShell,
      template_file: "priv/templates/components/navigation/app_shell.ex",
      js_hooks: [],
      dependencies: [:app_shell],
      tier: :shell,
      shadcn_equivalent: nil,
      status: :implemented
    },
    app_shell_sidebar: %{
      name: "app_shell_sidebar",
      module: PhiaUi.Components.AppShell,
      template_file: "priv/templates/components/navigation/app_shell.ex",
      js_hooks: [],
      dependencies: [:app_shell],
      tier: :shell,
      shadcn_equivalent: nil,
      status: :implemented
    },
    app_shell_aside: %{
      name: "app_shell_aside",
      module: PhiaUi.Components.AppShell,
      template_file: "priv/templates/components/navigation/app_shell.ex",
      js_hooks: [],
      dependencies: [:app_shell],
      tier: :shell,
      shadcn_equivalent: nil,
      status: :implemented
    },
    app_shell_footer: %{
      name: "app_shell_footer",
      module: PhiaUi.Components.AppShell,
      template_file: "priv/templates/components/navigation/app_shell.ex",
      js_hooks: [],
      dependencies: [:app_shell],
      tier: :shell,
      shadcn_equivalent: nil,
      status: :implemented
    },
    app_shell_main: %{
      name: "app_shell_main",
      module: PhiaUi.Components.AppShell,
      template_file: "priv/templates/components/navigation/app_shell.ex",
      js_hooks: [],
      dependencies: [:app_shell],
      tier: :shell,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # Group: Mega Menu
    mega_menu: %{
      name: "mega_menu",
      module: PhiaUi.Components.MegaMenu,
      template_file: "priv/templates/components/navigation/mega_menu.ex",
      js_hooks: ["PhiaMegaMenu"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    mega_menu_trigger: %{
      name: "mega_menu_trigger",
      module: PhiaUi.Components.MegaMenu,
      template_file: "priv/templates/components/navigation/mega_menu.ex",
      js_hooks: [],
      dependencies: [:mega_menu],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    mega_menu_content: %{
      name: "mega_menu_content",
      module: PhiaUi.Components.MegaMenu,
      template_file: "priv/templates/components/navigation/mega_menu.ex",
      js_hooks: [],
      dependencies: [:mega_menu],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    mega_menu_section: %{
      name: "mega_menu_section",
      module: PhiaUi.Components.MegaMenu,
      template_file: "priv/templates/components/navigation/mega_menu.ex",
      js_hooks: [],
      dependencies: [:mega_menu_content],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    mega_menu_item: %{
      name: "mega_menu_item",
      module: PhiaUi.Components.MegaMenu,
      template_file: "priv/templates/components/navigation/mega_menu.ex",
      js_hooks: [],
      dependencies: [:mega_menu_content],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    mega_menu_featured: %{
      name: "mega_menu_featured",
      module: PhiaUi.Components.MegaMenu,
      template_file: "priv/templates/components/navigation/mega_menu.ex",
      js_hooks: [],
      dependencies: [:mega_menu_content],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # Group: Speed Dial
    speed_dial: %{
      name: "speed_dial",
      module: PhiaUi.Components.SpeedDial,
      template_file: "priv/templates/components/navigation/speed_dial.ex",
      js_hooks: ["PhiaSpeedDial"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    speed_dial_item: %{
      name: "speed_dial_item",
      module: PhiaUi.Components.SpeedDial,
      template_file: "priv/templates/components/navigation/speed_dial.ex",
      js_hooks: [],
      dependencies: [:speed_dial],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # Group: Action Sheet
    action_sheet: %{
      name: "action_sheet",
      module: PhiaUi.Components.ActionSheet,
      template_file: "priv/templates/components/navigation/action_sheet.ex",
      js_hooks: ["PhiaActionSheet"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    action_sheet_trigger: %{
      name: "action_sheet_trigger",
      module: PhiaUi.Components.ActionSheet,
      template_file: "priv/templates/components/navigation/action_sheet.ex",
      js_hooks: [],
      dependencies: [:action_sheet],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    action_sheet_content: %{
      name: "action_sheet_content",
      module: PhiaUi.Components.ActionSheet,
      template_file: "priv/templates/components/navigation/action_sheet.ex",
      js_hooks: [],
      dependencies: [:action_sheet],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    action_sheet_item: %{
      name: "action_sheet_item",
      module: PhiaUi.Components.ActionSheet,
      template_file: "priv/templates/components/navigation/action_sheet.ex",
      js_hooks: [],
      dependencies: [:action_sheet_content],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },
    action_sheet_cancel: %{
      name: "action_sheet_cancel",
      module: PhiaUi.Components.ActionSheet,
      template_file: "priv/templates/components/navigation/action_sheet.ex",
      js_hooks: [],
      dependencies: [:action_sheet_content],
      tier: :interactive,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # Group: Sidebar Extension
    sidebar_item_expandable: %{
      name: "sidebar_item_expandable",
      module: PhiaUi.Components.Sidebar,
      template_file: "priv/templates/components/navigation/sidebar.ex",
      js_hooks: [],
      dependencies: [:sidebar],
      tier: :shell,
      shadcn_equivalent: nil,
      status: :implemented
    },

    # Group: Dropdown Menu Sub (extension)
    dropdown_menu_sub: %{
      name: "dropdown_menu_sub",
      module: PhiaUi.Components.DropdownMenu,
      template_file: "priv/templates/components/overlay/dropdown_menu.ex",
      js_hooks: [],
      dependencies: [:dropdown_menu],
      tier: :interactive,
      shadcn_equivalent: "DropdownMenuSub",
      status: :implemented
    },
    dropdown_menu_sub_trigger: %{
      name: "dropdown_menu_sub_trigger",
      module: PhiaUi.Components.DropdownMenu,
      template_file: "priv/templates/components/overlay/dropdown_menu.ex",
      js_hooks: [],
      dependencies: [:dropdown_menu_sub],
      tier: :interactive,
      shadcn_equivalent: "DropdownMenuSubTrigger",
      status: :implemented
    },
    dropdown_menu_sub_content: %{
      name: "dropdown_menu_sub_content",
      module: PhiaUi.Components.DropdownMenu,
      template_file: "priv/templates/components/overlay/dropdown_menu.ex",
      js_hooks: [],
      dependencies: [:dropdown_menu_sub],
      tier: :interactive,
      shadcn_equivalent: "DropdownMenuSubContent",
      status: :implemented
    }
  }

  # ---------------------------------------------------------------------------
  # Public API
  # ---------------------------------------------------------------------------

  @doc "Returns the full registry map — all 309 component metadata entries."
  @spec all() :: %{atom() => component_meta()}
  def all, do: @registry

  @doc "Returns metadata for a single component by key, or `nil` if not found."
  @spec get(atom()) :: component_meta() | nil
  def get(name) when is_atom(name), do: Map.get(@registry, name)

  @doc "Returns all components in a given tier."
  @spec by_tier(tier()) :: [component_meta()]
  def by_tier(tier), do: @registry |> Map.values() |> Enum.filter(&(&1.tier == tier))
end
