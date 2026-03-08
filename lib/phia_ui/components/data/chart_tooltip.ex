defmodule PhiaUi.Components.Data.ChartTooltip do
  @moduledoc """
  Chart tooltip components — pre-positioned SVG tooltip shell and HTML tooltip composition.

  Provides two patterns:

  1. **SVG tooltip** (`chart_tooltip/1`) — `<foreignObject>` inside SVG, zero JS
  2. **HTML tooltip composition** — Tremor-inspired Frame + Row pattern for building
     rich tooltip content outside SVG

  ## SVG Tooltip Example

      <.chart_tooltip x={100} y={50}>
        <span>Revenue: $350</span>
      </.chart_tooltip>

  ## HTML Tooltip Composition Example

      <.chart_tooltip_frame>
        <.chart_tooltip_header label="January 2024" />
        <.chart_tooltip_row name="Revenue" value="$1,234" color="oklch(0.60 0.20 240)" />
        <.chart_tooltip_row name="Cost" value="$890" color="oklch(0.65 0.22 30)" />
      </.chart_tooltip_frame>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartTheme

  # ---------------------------------------------------------------------------
  # SVG Tooltip (foreignObject)
  # ---------------------------------------------------------------------------

  attr :x, :any, required: true, doc: "X position in SVG coordinates."
  attr :y, :any, required: true, doc: "Y position in SVG coordinates."
  attr :visible, :boolean, default: true, doc: "Whether the tooltip is visible."
  attr :width, :integer, default: 120, doc: "Tooltip width in px."
  attr :height, :integer, default: 40, doc: "Tooltip height in px."
  attr :theme, :map, default: %{}, doc: "Chart theme overrides."
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  def chart_tooltip(assigns) do
    theme = ChartTheme.merge(assigns.theme)

    # Offset based on tooltip dimensions to center above the point
    fo_x = assigns.x - assigns.width / 2
    fo_y = assigns.y - assigns.height - 4

    assigns =
      assigns
      |> assign(:fo_x, fo_x)
      |> assign(:fo_y, fo_y)
      |> assign(:tooltip_class, cn([
        "rounded-md px-2 py-1 text-xs shadow-md",
        theme.tooltip.bg_class,
        theme.tooltip.text_class,
        theme.tooltip.border_class,
        assigns.class
      ]))

    ~H"""
    <foreignObject
      :if={@visible}
      x={@fo_x}
      y={@fo_y}
      width={@width}
      height={@height}
      {@rest}
    >
      <div xmlns="http://www.w3.org/1999/xhtml" class={@tooltip_class}>
        {render_slot(@inner_block)}
      </div>
    </foreignObject>
    """
  end

  # ---------------------------------------------------------------------------
  # Tooltip Frame (HTML) — Tremor-inspired
  # ---------------------------------------------------------------------------

  @doc """
  Styled tooltip container with rounded corners, shadow, and border.

  Inspired by Tremor's `ChartTooltipFrame`. Use as a wrapper around
  `chart_tooltip_header` and `chart_tooltip_row` components.
  """
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def chart_tooltip_frame(assigns) do
    ~H"""
    <div
      class={cn([
        "rounded-lg text-sm border shadow-md",
        "bg-popover text-popover-foreground border-border",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Tooltip Header (HTML) — Tremor-inspired
  # ---------------------------------------------------------------------------

  @doc """
  Tooltip header row with label text and bottom border.

  Inspired by Tremor's tooltip label section.
  """
  attr :label, :string, required: true, doc: "Header label text."
  attr :class, :string, default: nil

  def chart_tooltip_header(assigns) do
    ~H"""
    <div class={cn(["border-b border-border px-3 py-1.5", @class])}>
      <p class="font-medium text-foreground">{@label}</p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Tooltip Row (HTML) — Tremor-inspired
  # ---------------------------------------------------------------------------

  @doc """
  Individual tooltip row with color swatch, name, and value.

  Inspired by Tremor's `ChartTooltipRow`. Shows a colored dot indicator,
  the series name, and the formatted value.
  """
  attr :name, :string, required: true, doc: "Series/category name."
  attr :value, :string, required: true, doc: "Formatted value string."
  attr :color, :string, required: true, doc: "Swatch color (CSS color string)."
  attr :class, :string, default: nil

  def chart_tooltip_row(assigns) do
    ~H"""
    <div class={cn(["flex items-center justify-between gap-x-8 px-3 py-1", @class])}>
      <div class="flex items-center gap-x-2">
        <span
          class="shrink-0 rounded-full border-2 border-background shadow-sm size-3"
          style={"background-color: #{@color}"}
        />
        <p class="text-right whitespace-nowrap text-muted-foreground">{@name}</p>
      </div>
      <p class="font-medium tabular-nums text-right whitespace-nowrap text-foreground">
        {@value}
      </p>
    </div>
    """
  end
end
