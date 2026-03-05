defmodule PhiaUi.Components.ChartShell do
  @moduledoc """
  Titled card container for charts and data visualisations.

  `chart_shell/1` wraps any charting library output in a semantic PhiaUI
  `Card`, providing consistent header chrome (title, description, period
  label, action buttons) and a minimum-height content area — all without
  coupling to a specific charting library.

  ## When to use

  Use `chart_shell/1` when you want the standard PhiaUI card presentation
  around a chart but need full control over the chart itself (custom hooks,
  third-party libraries, canvas elements, SVG, etc.). For a batteries-included
  experience, use `phia_chart/1` which combines `chart_shell/1` with the
  `PhiaChart` hook automatically.

  ## Anatomy

      ┌──────────────────────────────────────────────────────┐
      │  card_header                                         │
      │  ┌──────────────────────────┐  ┌──────────────────┐ │
      │  │ title                    │  │ period  | actions │ │
      │  │ description (optional)   │  │                   │ │
      │  └──────────────────────────┘  └──────────────────┘ │
      ├──────────────────────────────────────────────────────┤
      │  card_content                                        │
      │  ┌────────────────────────────────────────────────┐ │
      │  │  chart content area (min-height: 300px)        │ │
      │  └────────────────────────────────────────────────┘ │
      └──────────────────────────────────────────────────────┘

  ## Basic example — custom Chart.js hook

      <.chart_shell
        title="Revenue Over Time"
        description="Monthly recurring revenue"
        period="Last 12 months"
        min_height="350px"
      >
        <:actions>
          <.button variant={:outline} size={:sm}>Export CSV</.button>
        </:actions>
        <canvas id="revenue-chart" phx-hook="RevenueChart" class="w-full h-full" />
      </.chart_shell>

  ## Example with ECharts (manual hook wiring)

      <.chart_shell title="User Growth" period="Last 90 days" min_height="400px">
        <div
          id="growth-chart"
          phx-hook="PhiaChart"
          data-config={Jason.encode!(@chart_config)}
          data-series={Jason.encode!(@chart_series)}
          style="height: 400px"
          class="w-full"
        />
      </.chart_shell>

  ## Example with multiple action buttons

      <.chart_shell
        title="Conversion Funnel"
        description="Visitors to paying customers"
        period="Q1 2026"
        min_height="300px"
      >
        <:actions>
          <.button variant={:ghost} size={:sm}><.icon name="refresh-cw" /></.button>
          <.button variant={:outline} size={:sm}>Download</.button>
        </:actions>
        <canvas id="funnel-chart" phx-hook="FunnelChart" />
      </.chart_shell>

  ## Responsive min-height

  The `min_height` attribute accepts any CSS length: `"300px"`, `"20rem"`,
  `"50vh"`. The container enforces this minimum so that the chart area does
  not collapse to zero before the JS hook mounts and sizes the canvas.

  ## Library compatibility

  `chart_shell/1` renders a plain `<div>` inside its content area. Any
  charting library that targets a DOM element can be used:

  - **ECharts** via the `PhiaChart` hook (built-in)
  - **Chart.js** via the `PhiaChart` hook fallback or a custom hook
  - **D3.js** — mount on the container div ID
  - **Vega-Lite** — target the inner div
  - **SVG charts** — render inline SVG directly as inner block
  """

  use Phoenix.Component

  import PhiaUi.Components.Card
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:title, :string,
    required: true,
    doc: """
    Chart heading rendered in `card_title`. Always visible — use a clear,
    metric-focused label: "Revenue Over Time", "Active Users by Region".
    """
  )

  attr(:description, :string,
    default: nil,
    doc: """
    Supporting text shown below the title in smaller muted text (omitted when
    `nil`). Use for metric clarification: "Monthly recurring revenue (USD)",
    "Unique sessions, excluding bots".
    """
  )

  attr(:period, :string,
    default: nil,
    doc: """
    Time-range label displayed in the header to the right of the title block.
    Typical values: `"Last 30 days"`, `"Q1 2026"`, `"YTD"`. Omitted when `nil`.
    This is a plain string; for interactive period selectors use the `:actions` slot.
    """
  )

  attr(:min_height, :string,
    default: "300px",
    doc: """
    Minimum CSS height of the chart content area. Prevents the container from
    collapsing before the JS chart hook has had time to mount and measure.
    Accepts any CSS length value: `"300px"`, `"20rem"`, `"50vh"`.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the outer card element")

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the outer card element (e.g. `id`, `data-*`)"
  )

  slot(:actions,
    doc: """
    Optional header action buttons rendered to the right of the period label.
    Use for download, refresh, period-selector, or settings buttons. Multiple
    actions are laid out in a horizontal flex row with `gap-1` between them.

        <:actions>
          <.button variant={:ghost} size={:sm}><.icon name="refresh-cw" /></.button>
          <.button variant={:outline} size={:sm}>Export</.button>
        </:actions>
    """
  )

  slot(:inner_block,
    required: true,
    doc: """
    The chart content itself. Render any chart library output here:
    a `<canvas>` for Chart.js, a `<div>` for ECharts or D3, or inline SVG.
    The content area has `min-height` applied via inline style.
    """
  )

  @doc """
  Renders a titled card shell around a chart or data visualisation.

  The header layout uses a two-column flex row:
  - Left: title + optional description (allows text to truncate on narrow screens)
  - Right: optional period label + optional action buttons (shrink-0, never truncated)

  The content area wraps the inner block in a div with `min-height` applied as
  an inline style — this prevents the card from collapsing before the chart JS
  hook initialises.

  ## Example

      <.chart_shell
        title="MRR Growth"
        description="Monthly recurring revenue"
        period="Last 12 months"
        min_height="350px"
      >
        <:actions>
          <.button variant={:outline} size={:sm}>Export</.button>
        </:actions>
        <canvas id="mrr-chart" phx-hook="PhiaChart" />
      </.chart_shell>
  """
  def chart_shell(assigns) do
    ~H"""
    <.card class={cn([@class])} {@rest}>
      <.card_header>
        <%!-- Two-column flex: title/description on the left (truncatable),
            period + actions on the right (never shrink, never truncate) --%>
        <div class="flex items-start justify-between gap-2">
          <div class="min-w-0">
            <.card_title><%= @title %></.card_title>
            <.card_description :if={@description}>
              <%= @description %>
            </.card_description>
          </div>
          <div class="flex shrink-0 items-center gap-2">
            <span :if={@period} class="text-sm text-muted-foreground whitespace-nowrap">
              <%= @period %>
            </span>
            <%= if @actions != [] do %>
              <div class="flex items-center gap-1">
                <%= render_slot(@actions) %>
              </div>
            <% end %>
          </div>
        </div>
      </.card_header>
      <.card_content>
        <%!-- min-height via inline style so any CSS length value is accepted,
            not just the ones in Tailwind's static safelist --%>
        <div role="img" style={"min-height: #{@min_height}"}>
          <p :if={@description} class="sr-only">{@description}</p>
          <%= render_slot(@inner_block) %>
        </div>
      </.card_content>
    </.card>
    """
  end
end
