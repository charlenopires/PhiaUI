defmodule PhiaUi.Components.StatCard do
  @moduledoc """
  Dashboard KPI widget built on top of the `Card` and `Badge` primitives.

  A `stat_card` displays a single key performance indicator with:

  - A metric title (e.g. "Monthly Revenue")
  - A prominent numeric value (e.g. "$12,345")
  - An optional trend badge showing direction and percentage change
  - An optional description providing comparison context
  - An optional icon slot in the header (top-right corner)
  - An optional footer slot for timestamps, sparklines, or extra notes

  ## When to use

  Use `stat_card` on executive dashboards, BI panels, financial terminals, and
  any view where at-a-glance KPI monitoring is the primary goal. Combine
  multiple cards inside `metric_grid/1` for a responsive multi-column layout.

  ## Trend variants

  | `:trend`   | Badge variant    | Icon rendered   | Typical use              |
  |------------|------------------|-----------------|--------------------------|
  | `:up`      | `:default`       | `trending-up`   | Positive growth          |
  | `:down`    | `:destructive`   | `trending-down` | Decline or regression    |
  | `:neutral` | `:secondary`     | `minus`         | Flat / no change         |

  ## Basic example

      <.stat_card
        title="Total Revenue"
        value="$12,345"
        trend={:up}
        trend_value="+12%"
        description="vs. last month"
      />

  ## With icon and footer slots

      <.stat_card
        title="Active Users"
        value="1,024"
        trend={:down}
        trend_value="-3%"
        description="vs. last 30 days"
      >
        <:icon><.icon name="users" /></:icon>
        <:footer>Last updated 2 min ago</:footer>
      </.stat_card>

  ## Full dashboard row with metric_grid

      <.metric_grid cols={4}>
        <.stat_card title="Revenue"    value="$48,295" trend={:up}      trend_value="+18%" description="vs. last quarter" />
        <.stat_card title="New Users"  value="3,847"   trend={:up}      trend_value="+7%"  description="vs. last month"   />
        <.stat_card title="Churn Rate" value="2.4%"    trend={:down}    trend_value="-0.3%" description="vs. last month"  />
        <.stat_card title="NPS"        value="62"      trend={:neutral} trend_value="→"    description="no change"        />
      </.metric_grid>

  ## Accessibility

  The trend badge icon is purely decorative (`aria-hidden` on the icon
  itself). Screen readers will read the `trend_value` text directly, which
  should be self-explanatory (e.g. "+12%" or "-3%").
  """

  use Phoenix.Component

  import PhiaUi.Components.Card
  import PhiaUi.Components.Badge
  import PhiaUi.Components.Icon, only: [icon: 1]
  import PhiaUi.Components.BadgeDelta, only: [badge_delta: 1]
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:title, :string,
    required: true,
    doc: """
    Metric label shown above the value in `text-sm text-muted-foreground`.
    Keep it short (2–4 words): "Monthly Revenue", "Active Users", "Churn Rate".
    """
  )

  attr(:value, :string,
    required: true,
    doc: """
    The main metric value rendered in `text-2xl font-bold`. Pass a
    pre-formatted string: `"$12,345"`, `"1,024"`, `"98.6%"`. Formatting
    is left to the caller so locale, currency symbol, and precision remain
    in application code.
    """
  )

  attr(:trend, :atom,
    values: [:up, :down, :neutral],
    default: :neutral,
    doc: """
    Direction of the trend indicator. Controls both the badge color variant
    and the icon rendered inside the badge. Only visible when `trend_value`
    is also provided.
    """
  )

  attr(:trend_value, :string,
    default: nil,
    doc: """
    Text displayed inside the trend badge (e.g. `"+12%"`, `"-3%"`, `"→"`).
    When `nil` (default), the badge is not rendered at all — useful for
    metrics where trend comparison is not yet available.
    """
  )

  attr(:description, :string,
    default: nil,
    doc: """
    Secondary context text rendered below the value in `text-xs text-muted-foreground`.
    Typically a comparison period: `"vs. last month"`, `"year to date"`, `"30-day avg"`.
    When `nil`, no description paragraph is rendered.
    """
  )

  attr(:delta, :string,
    default: nil,
    doc: "Delta value for `BadgeDelta` (e.g. \"+12%\"). Requires `delta_type` to render."
  )

  attr(:delta_type, :atom,
    default: nil,
    values: [:increase, :moderate_increase, :decrease, :moderate_decrease, :unchanged, nil],
    doc: "Delta type for `BadgeDelta`. Rendered only when both `delta` and `delta_type` are set."
  )

  attr(:sparkline_data, :list,
    default: [],
    doc: "List of numbers for a mini sparkline SVG in the card footer."
  )

  attr(:href, :string,
    default: nil,
    doc: "Optional URL. When set, wraps the card in an `<a>` link."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes applied to the outer card")

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the outer card element (e.g. `phx-click`, `data-*`)"
  )

  slot(:icon,
    doc: """
    Optional icon displayed in the top-right corner of the card header.
    Rendered next to the trend badge. Use a small icon (16–20 px):

        <:icon><.icon name="dollar-sign" /></:icon>

    When both an icon and a trend badge are present, the icon appears first
    (left) and the badge appears second (right).
    """
  )

  slot(:footer,
    doc: """
    Optional content rendered at the bottom of the card in `text-xs
    text-muted-foreground`. Use for timestamps, data source labels,
    or inline sparkline charts:

        <:footer>Updated 2 min ago</:footer>
        <:footer><canvas id="sparkline-mrr" phx-hook="Sparkline" /></:footer>
    """
  )

  @doc """
  Renders a single KPI stat card.

  The card layout is a standard PhiaUI `Card` with three regions:

      ┌──────────────────────────────────────────────┐
      │  card_header                                 │
      │  ┌─────────────────────┐  ┌───────────────┐ │
      │  │ title (muted text)  │  │ icon | badge  │ │
      │  └─────────────────────┘  └───────────────┘ │
      ├──────────────────────────────────────────────┤
      │  card_content                                │
      │  value (2xl bold)                            │
      │  description (xs muted)                      │
      ├──────────────────────────────────────────────┤
      │  card_footer (only when footer slot used)    │
      └──────────────────────────────────────────────┘
  """
  def stat_card(assigns) do
    sparkline_points =
      if assigns.sparkline_data != [],
        do: build_sparkline_points(assigns.sparkline_data, 120, 32),
        else: ""

    assigns = assign(assigns, :sparkline_points, sparkline_points)

    ~H"""
    <a :if={@href} href={@href} class="block">
      <.stat_card_body {assigns} />
    </a>
    <.stat_card_body :if={!@href} {assigns} />
    """
  end

  defp stat_card_body(assigns) do
    ~H"""
    <.card class={cn(["shadow-sm", @class])} {@rest}>
      <.card_header class="flex flex-row items-center justify-between space-y-0 pb-2">
        <.card_title class="text-sm font-medium text-muted-foreground">
          <%= @title %>
        </.card_title>
        <div class="flex items-center gap-2">
          <%!-- Icon is optional; wrap in shrink-0 container to prevent compression --%>
          <span :if={@icon != []} class="text-muted-foreground">
            <%= render_slot(@icon) %>
          </span>
          <%!-- Delta badge (new) — rendered when both delta + delta_type present --%>
          <.badge_delta
            :if={@delta && @delta_type}
            value={@delta}
            delta_type={@delta_type}
            size={:sm}
          />
          <%!-- Trend badge: only rendered when trend_value is provided --%>
          <.badge :if={@trend_value && !(@delta && @delta_type)} variant={trend_badge_variant(@trend)}>
            <.icon name={trend_icon_name(@trend)} size={:xs} /> <%= @trend_value %>
          </.badge>
        </div>
      </.card_header>
      <.card_content>
        <%!-- tracking-tight on large values improves readability of long numbers --%>
        <div class="text-xl sm:text-2xl font-bold tracking-tight" aria-label={"#{@value} #{@title}"}><%= @value %></div>
        <p :if={@description} class="mt-1 text-xs text-muted-foreground">
          <%= @description %>
        </p>
      </.card_content>
      <.card_footer :if={@footer != [] || @sparkline_points != ""} class="pt-0 text-xs text-muted-foreground flex items-center">
        <%= render_slot(@footer) %>
        <svg
          :if={@sparkline_points != ""}
          width="120"
          height="32"
          viewBox="0 0 120 32"
          preserveAspectRatio="none"
          aria-hidden="true"
          class="ml-auto"
        >
          <polyline
            points={@sparkline_points}
            fill="none"
            stroke="currentColor"
            stroke-width="1.5"
            stroke-linecap="round"
            stroke-linejoin="round"
            class="text-primary"
          />
        </svg>
      </.card_footer>
    </.card>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Map trend direction to a Badge variant so color semantics are consistent
  # with the rest of the UI: green/default = positive, red/destructive = negative.
  defp trend_badge_variant(:up), do: :default
  defp trend_badge_variant(:down), do: :destructive
  defp trend_badge_variant(:neutral), do: :secondary

  # Map trend direction to a Lucide icon name from the icon component.
  # These names must match the icon set installed in the project.
  defp trend_icon_name(:up), do: "trending-up"
  defp trend_icon_name(:down), do: "trending-down"
  defp trend_icon_name(:neutral), do: "minus"

  # Sparkline polyline math — adapted from SparklineCard.build_points/3
  defp build_sparkline_points([], _w, _h), do: ""
  defp build_sparkline_points([_single], w, h), do: "0,#{h / 2} #{w},#{h / 2}"

  defp build_sparkline_points(data, w, h) do
    min_v = Enum.min(data)
    max_v = Enum.max(data)
    range = if max_v == min_v, do: 1, else: max_v - min_v
    count = length(data)
    padding = 2

    data
    |> Enum.with_index()
    |> Enum.map_join(" ", fn {v, i} ->
      x = Float.round(i / (count - 1) * w, 2)
      y = Float.round(padding + (1 - (v - min_v) / range) * (h - padding * 2), 2)
      "#{x},#{y}"
    end)
  end
end
