defmodule PhiaUi.ComponentRegistry do
  @moduledoc """
  Source of truth for all 119 PhiaUI components.

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

  @type tier :: :primitive | :interactive | :form | :navigation | :shell | :widget
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
    }
  }

  # ---------------------------------------------------------------------------
  # Public API
  # ---------------------------------------------------------------------------

  @doc "Returns the full registry map — all 119 component metadata entries."
  @spec all() :: %{atom() => component_meta()}
  def all, do: @registry

  @doc "Returns metadata for a single component by key, or `nil` if not found."
  @spec get(atom()) :: component_meta() | nil
  def get(name) when is_atom(name), do: Map.get(@registry, name)

  @doc "Returns all components in a given tier."
  @spec by_tier(tier()) :: [component_meta()]
  def by_tier(tier), do: @registry |> Map.values() |> Enum.filter(&(&1.tier == tier))
end
