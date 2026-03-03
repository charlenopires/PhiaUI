defmodule PhiaUi.ComponentRegistry do
  @moduledoc """
  Source of truth for all 55 PhiaUI components.

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
      template_file: "priv/templates/components/button.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: "Button",
      status: :planned
    },
    card: %{
      name: "card",
      module: PhiaUi.Components.Card,
      template_file: "priv/templates/components/card.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: "Card",
      status: :planned
    },
    badge: %{
      name: "badge",
      module: PhiaUi.Components.Badge,
      template_file: "priv/templates/components/badge.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: "Badge",
      status: :planned
    },
    input: %{
      name: "input",
      module: PhiaUi.Components.Input,
      template_file: "priv/templates/components/input.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: "Input",
      status: :planned
    },
    label: %{
      name: "label",
      module: PhiaUi.Components.Label,
      template_file: "priv/templates/components/label.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: "Label",
      status: :planned
    },
    separator: %{
      name: "separator",
      module: PhiaUi.Components.Separator,
      template_file: "priv/templates/components/separator.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: "Separator",
      status: :planned
    },
    skeleton: %{
      name: "skeleton",
      module: PhiaUi.Components.Skeleton,
      template_file: "priv/templates/components/skeleton.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: "Skeleton",
      status: :implemented
    },
    avatar: %{
      name: "avatar",
      module: PhiaUi.Components.Avatar,
      template_file: "priv/templates/components/avatar.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: "Avatar",
      status: :planned
    },
    progress: %{
      name: "progress",
      module: PhiaUi.Components.Progress,
      template_file: "priv/templates/components/progress.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: "Progress",
      status: :planned
    },
    table: %{
      name: "table",
      module: PhiaUi.Components.Table,
      template_file: "priv/templates/components/table.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: "Table",
      status: :planned
    },
    aspect_ratio: %{
      name: "aspect_ratio",
      module: PhiaUi.Components.AspectRatio,
      template_file: "priv/templates/components/aspect_ratio.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: "AspectRatio",
      status: :planned
    },
    toggle: %{
      name: "toggle",
      module: PhiaUi.Components.Toggle,
      template_file: "priv/templates/components/toggle.ex",
      js_hooks: [],
      dependencies: [],
      tier: :primitive,
      shadcn_equivalent: "Toggle",
      status: :planned
    },
    toggle_group: %{
      name: "toggle_group",
      module: PhiaUi.Components.ToggleGroup,
      template_file: "priv/templates/components/toggle_group.ex",
      js_hooks: [],
      dependencies: [:toggle],
      tier: :primitive,
      shadcn_equivalent: "ToggleGroup",
      status: :planned
    },

    # ── Interactive Components ────────────────────────────────────────────────
    dialog: %{
      name: "dialog",
      module: PhiaUi.Components.Dialog,
      template_file: "priv/templates/components/dialog.ex",
      js_hooks: ["FocusTrap", "Dialog"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Dialog",
      status: :planned
    },
    dropdown_menu: %{
      name: "dropdown_menu",
      module: PhiaUi.Components.DropdownMenu,
      template_file: "priv/templates/components/dropdown_menu.ex",
      js_hooks: ["ClickOutside", "DropdownMenu"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "DropdownMenu",
      status: :planned
    },
    sheet: %{
      name: "sheet",
      module: PhiaUi.Components.Sheet,
      template_file: "priv/templates/components/sheet.ex",
      js_hooks: ["FocusTrap", "Sheet"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Sheet",
      status: :planned
    },
    tabs: %{
      name: "tabs",
      module: PhiaUi.Components.Tabs,
      template_file: "priv/templates/components/tabs.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Tabs",
      status: :planned
    },
    accordion: %{
      name: "accordion",
      module: PhiaUi.Components.Accordion,
      template_file: "priv/templates/components/accordion.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Accordion",
      status: :planned
    },
    popover: %{
      name: "popover",
      module: PhiaUi.Components.Popover,
      template_file: "priv/templates/components/popover.ex",
      js_hooks: ["PhiaPopover"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Popover",
      status: :implemented
    },
    tooltip: %{
      name: "tooltip",
      module: PhiaUi.Components.Tooltip,
      template_file: "priv/templates/components/tooltip.ex",
      js_hooks: ["PhiaTooltip"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Tooltip",
      status: :implemented
    },
    select: %{
      name: "select",
      module: PhiaUi.Components.Select,
      template_file: "priv/templates/components/select.ex",
      js_hooks: ["Select"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Select",
      status: :planned
    },
    checkbox: %{
      name: "checkbox",
      module: PhiaUi.Components.Checkbox,
      template_file: "priv/templates/components/checkbox.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Checkbox",
      status: :planned
    },
    switch: %{
      name: "switch",
      module: PhiaUi.Components.Switch,
      template_file: "priv/templates/components/switch.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Switch",
      status: :planned
    },
    slider: %{
      name: "slider",
      module: PhiaUi.Components.Slider,
      template_file: "priv/templates/components/slider.ex",
      js_hooks: ["Slider"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Slider",
      status: :planned
    },
    radio_group: %{
      name: "radio_group",
      module: PhiaUi.Components.RadioGroup,
      template_file: "priv/templates/components/radio_group.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "RadioGroup",
      status: :planned
    },
    collapsible: %{
      name: "collapsible",
      module: PhiaUi.Components.Collapsible,
      template_file: "priv/templates/components/collapsible.ex",
      js_hooks: [],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Collapsible",
      status: :planned
    },
    hover_card: %{
      name: "hover_card",
      module: PhiaUi.Components.HoverCard,
      template_file: "priv/templates/components/hover_card.ex",
      js_hooks: ["HoverCard"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "HoverCard",
      status: :planned
    },
    command: %{
      name: "command",
      module: PhiaUi.Components.Command,
      template_file: "priv/templates/components/command.ex",
      js_hooks: ["Command"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Command",
      status: :planned
    },
    calendar: %{
      name: "calendar",
      module: PhiaUi.Components.Calendar,
      template_file: "priv/templates/components/calendar.ex",
      js_hooks: ["Calendar"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Calendar",
      status: :planned
    },
    carousel: %{
      name: "carousel",
      module: PhiaUi.Components.Carousel,
      template_file: "priv/templates/components/carousel.ex",
      js_hooks: ["Carousel"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Carousel",
      status: :planned
    },
    context_menu: %{
      name: "context_menu",
      module: PhiaUi.Components.ContextMenu,
      template_file: "priv/templates/components/context_menu.ex",
      js_hooks: ["ContextMenu"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "ContextMenu",
      status: :planned
    },
    drawer: %{
      name: "drawer",
      module: PhiaUi.Components.Drawer,
      template_file: "priv/templates/components/drawer.ex",
      js_hooks: ["FocusTrap", "Drawer"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Drawer",
      status: :planned
    },
    menubar: %{
      name: "menubar",
      module: PhiaUi.Components.Menubar,
      template_file: "priv/templates/components/menubar.ex",
      js_hooks: ["Menubar"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Menubar",
      status: :planned
    },
    navigation_menu: %{
      name: "navigation_menu",
      module: PhiaUi.Components.NavigationMenu,
      template_file: "priv/templates/components/navigation_menu.ex",
      js_hooks: ["NavigationMenu"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "NavigationMenu",
      status: :planned
    },
    resizable: %{
      name: "resizable",
      module: PhiaUi.Components.Resizable,
      template_file: "priv/templates/components/resizable.ex",
      js_hooks: ["Resizable"],
      dependencies: [],
      tier: :interactive,
      shadcn_equivalent: "Resizable",
      status: :planned
    },
    date_picker: %{
      name: "date_picker",
      module: PhiaUi.Components.DatePicker,
      template_file: "priv/templates/components/date_picker.ex",
      js_hooks: ["Calendar", "ClickOutside"],
      dependencies: [:calendar, :popover],
      tier: :interactive,
      shadcn_equivalent: "DatePicker",
      status: :planned
    },
    combobox: %{
      name: "combobox",
      module: PhiaUi.Components.Combobox,
      template_file: "priv/templates/components/combobox.ex",
      js_hooks: ["Command", "ClickOutside"],
      dependencies: [:command, :popover],
      tier: :interactive,
      shadcn_equivalent: "Combobox",
      status: :planned
    },

    # ── Form Integration ──────────────────────────────────────────────────────
    form_field: %{
      name: "form_field",
      module: PhiaUi.Components.FormField,
      template_file: "priv/templates/components/form_field.ex",
      js_hooks: [],
      dependencies: [:label],
      tier: :form,
      shadcn_equivalent: "FormField",
      status: :planned
    },
    phia_input: %{
      name: "phia_input",
      module: PhiaUi.Components.PhiaInput,
      template_file: "priv/templates/components/phia_input.ex",
      js_hooks: [],
      dependencies: [:input, :label, :form_field],
      tier: :form,
      shadcn_equivalent: nil,
      status: :planned
    },
    textarea: %{
      name: "textarea",
      module: PhiaUi.Components.Textarea,
      template_file: "priv/templates/components/textarea.ex",
      js_hooks: [],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: "Textarea",
      status: :planned
    },
    input_otp: %{
      name: "input_otp",
      module: PhiaUi.Components.InputOTP,
      template_file: "priv/templates/components/input_otp.ex",
      js_hooks: ["InputOTP"],
      dependencies: [],
      tier: :form,
      shadcn_equivalent: "InputOTP",
      status: :planned
    },

    # ── Navigation & Feedback ─────────────────────────────────────────────────
    breadcrumb: %{
      name: "breadcrumb",
      module: PhiaUi.Components.Breadcrumb,
      template_file: "priv/templates/components/breadcrumb.ex",
      js_hooks: [],
      dependencies: [],
      tier: :navigation,
      shadcn_equivalent: "Breadcrumb",
      status: :implemented
    },
    pagination: %{
      name: "pagination",
      module: PhiaUi.Components.Pagination,
      template_file: "priv/templates/components/pagination.ex",
      js_hooks: [],
      dependencies: [],
      tier: :navigation,
      shadcn_equivalent: "Pagination",
      status: :implemented
    },
    scroll_area: %{
      name: "scroll_area",
      module: PhiaUi.Components.ScrollArea,
      template_file: "priv/templates/components/scroll_area.ex",
      js_hooks: [],
      dependencies: [],
      tier: :navigation,
      shadcn_equivalent: "ScrollArea",
      status: :planned
    },
    alert: %{
      name: "alert",
      module: PhiaUi.Components.Alert,
      template_file: "priv/templates/components/alert.ex",
      js_hooks: [],
      dependencies: [],
      tier: :navigation,
      shadcn_equivalent: "Alert",
      status: :implemented
    },
    alert_dialog: %{
      name: "alert_dialog",
      module: PhiaUi.Components.AlertDialog,
      template_file: "priv/templates/components/alert_dialog.ex",
      js_hooks: ["FocusTrap", "Dialog"],
      dependencies: [:dialog],
      tier: :navigation,
      shadcn_equivalent: "AlertDialog",
      status: :planned
    },
    toast: %{
      name: "toast",
      module: PhiaUi.Components.Toast,
      template_file: "priv/templates/components/toast.ex",
      js_hooks: ["PhiaToast"],
      dependencies: [],
      tier: :navigation,
      shadcn_equivalent: "Toast",
      status: :implemented
    },
    sonner: %{
      name: "sonner",
      module: PhiaUi.Components.Sonner,
      template_file: "priv/templates/components/sonner.ex",
      js_hooks: ["Sonner"],
      dependencies: [],
      tier: :navigation,
      shadcn_equivalent: "Sonner",
      status: :planned
    },

    # ── Dashboard Shell ───────────────────────────────────────────────────────
    shell: %{
      name: "shell",
      module: PhiaUi.Components.Shell,
      template_file: "priv/templates/components/shell.ex",
      js_hooks: [],
      dependencies: [],
      tier: :shell,
      shadcn_equivalent: nil,
      status: :planned
    },
    sidebar: %{
      name: "sidebar",
      module: PhiaUi.Components.Sidebar,
      template_file: "priv/templates/components/sidebar.ex",
      js_hooks: [],
      dependencies: [],
      tier: :shell,
      shadcn_equivalent: "Sidebar",
      status: :planned
    },
    topbar: %{
      name: "topbar",
      module: PhiaUi.Components.Topbar,
      template_file: "priv/templates/components/topbar.ex",
      js_hooks: [],
      dependencies: [],
      tier: :shell,
      shadcn_equivalent: nil,
      status: :planned
    },
    mobile_sidebar_toggle: %{
      name: "mobile_sidebar_toggle",
      module: PhiaUi.Components.MobileSidebarToggle,
      template_file: "priv/templates/components/mobile_sidebar_toggle.ex",
      js_hooks: [],
      dependencies: [:sidebar],
      tier: :shell,
      shadcn_equivalent: nil,
      status: :planned
    },
    dark_mode_toggle: %{
      name: "dark_mode_toggle",
      module: PhiaUi.Components.DarkModeToggle,
      template_file: "priv/templates/components/dark_mode_toggle.ex",
      js_hooks: ["PhiaDarkMode"],
      dependencies: [:icon],
      tier: :shell,
      shadcn_equivalent: nil,
      status: :implemented
    },

    data_grid: %{
      name: "data_grid",
      module: PhiaUi.Components.DataGrid,
      template_file: "priv/templates/components/data_grid.ex",
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
      template_file: "priv/templates/components/stat_card.ex",
      js_hooks: [],
      dependencies: [:card, :badge],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :planned
    },
    metric_grid: %{
      name: "metric_grid",
      module: PhiaUi.Components.MetricGrid,
      template_file: "priv/templates/components/metric_grid.ex",
      js_hooks: [],
      dependencies: [:stat_card, :card],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :planned
    },
    chart_shell: %{
      name: "chart_shell",
      module: PhiaUi.Components.ChartShell,
      template_file: "priv/templates/components/chart_shell.ex",
      js_hooks: [],
      dependencies: [:card],
      tier: :widget,
      shadcn_equivalent: nil,
      status: :planned
    }
  }

  # ---------------------------------------------------------------------------
  # Public API
  # ---------------------------------------------------------------------------

  @doc "Returns the full registry map — all 55 component metadata entries."
  @spec all() :: %{atom() => component_meta()}
  def all, do: @registry

  @doc "Returns metadata for a single component by key, or `nil` if not found."
  @spec get(atom()) :: component_meta() | nil
  def get(name) when is_atom(name), do: Map.get(@registry, name)

  @doc "Returns all components in a given tier."
  @spec by_tier(tier()) :: [component_meta()]
  def by_tier(tier), do: @registry |> Map.values() |> Enum.filter(&(&1.tier == tier))
end
