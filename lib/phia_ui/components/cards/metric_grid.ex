defmodule PhiaUi.Components.MetricGrid do
  @moduledoc """
  Responsive CSS Grid wrapper for `stat_card/1` KPI widgets.

  `metric_grid/1` takes care of the responsive column math so you do not have
  to hand-craft Tailwind breakpoint classes for every dashboard. Pass the
  desired maximum column count and the grid automatically collapses to fewer
  columns on smaller screens.

  ## Column breakpoints

  | `:cols` | Mobile (`< sm`) | Tablet (`sm+`) | Desktop (`lg+`) |
  |---------|-----------------|----------------|-----------------|
  | `1`     | 1               | 1              | 1               |
  | `2`     | 1               | 2              | 2               |
  | `3`     | 1               | 2              | 3               |
  | `4`     | 1               | 2              | 4               |

  The single-column mobile layout ensures that stat cards never appear
  side-by-side when they would be too narrow to be readable.

  ## Basic example

      <.metric_grid cols={4}>
        <.stat_card title="Revenue"    value="$48,295" trend={:up}      trend_value="+18%" description="vs. last quarter" />
        <.stat_card title="New Users"  value="3,847"   trend={:up}      trend_value="+7%"  description="vs. last month"   />
        <.stat_card title="Churn Rate" value="2.4%"    trend={:down}    trend_value="-0.3%" description="vs. last month"  />
        <.stat_card title="NPS"        value="62"      trend={:neutral} trend_value="→"    description="no change"        />
      </.metric_grid>

  ## Three-column variant

  When a fourth metric is not available or the layout needs more breathing
  room, use `cols={3}`:

      <.metric_grid cols={3}>
        <.stat_card title="MRR"          value="$24,150" trend={:up}   trend_value="+11%" />
        <.stat_card title="Active Users" value="892"     trend={:up}   trend_value="+5%"  />
        <.stat_card title="Avg Session"  value="4m 32s"  trend={:down} trend_value="-8s"  />
      </.metric_grid>

  ## Mixed content

  `metric_grid/1` is a plain CSS Grid wrapper — any card-shaped element works
  inside it, not just `stat_card/1`:

      <.metric_grid cols={3}>
        <.stat_card title="Revenue" value="$12,345" />
        <.chart_shell title="Trend" min_height="120px">
          <.phia_chart id="mini-chart" type={:area} series={@series} labels={@labels} height="120px" />
        </.chart_shell>
        <.stat_card title="NPS" value="68" trend={:up} trend_value="+4" />
      </.metric_grid>

  ## Integration with Shell

  Place `metric_grid/1` directly inside the `<main>` of `shell/1`:

      <main class="overflow-y-auto p-6 space-y-6">
        <.metric_grid cols={4}>
          <%= for kpi <- @kpis do %>
            <.stat_card
              title={kpi.label}
              value={kpi.formatted_value}
              trend={kpi.trend}
              trend_value={kpi.trend_text}
              description={kpi.period}
            />
          <% end %>
        </.metric_grid>
      </main>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:cols, :integer,
    values: [1, 2, 3, 4],
    default: 4,
    doc: """
    Maximum number of columns in the grid (1–4). The grid automatically
    collapses to fewer columns at smaller breakpoints:
    - Mobile (< sm): always 1 column
    - Tablet (sm+): up to 2 columns
    - Desktop (lg+): up to the specified `:cols` value
    """
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes for the grid wrapper (e.g. `mt-6` for vertical spacing)"
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the wrapper div")

  slot(:inner_block,
    required: true,
    doc: "`stat_card/1` components or other card-shaped children to lay out in the grid"
  )

  @doc """
  Renders a responsive CSS Grid wrapper for dashboard KPI cards.

  The grid uses `gap-4` between cells. Add vertical spacing between this
  component and others using a wrapper class or a `space-y-*` parent.

  ## Example

      <.metric_grid cols={4}>
        <.stat_card title="Revenue" value="$12,345" trend={:up} trend_value="+8%" />
        <.stat_card title="Users"   value="1,024"   trend={:up} trend_value="+3%" />
        <.stat_card title="Churn"   value="2.1%"    trend={:down} trend_value="-0.4%" />
        <.stat_card title="NPS"     value="62"       trend={:neutral} trend_value="→" />
      </.metric_grid>
  """
  def metric_grid(assigns) do
    ~H"""
    <div class={cn(["grid gap-4", grid_class(@cols), @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Each clause emits a precise set of Tailwind grid-cols-* classes rather than
  # computing them at runtime, which is important for Tailwind's static scan:
  # if the full class string never appears in source, Tailwind won't emit the
  # CSS for it.  Pattern-matching on an integer is the idiomatic Elixir approach
  # and is more readable than a map lookup or cond block.

  # 1-column: no responsiveness needed — single metric displays like a hero card
  defp grid_class(1), do: "grid-cols-1"

  # 2-column: 1 on mobile (phones often hold only one card at a time comfortably)
  # then 2 from the sm breakpoint (640 px) onward
  defp grid_class(2), do: "grid-cols-1 sm:grid-cols-2"

  # 3-column: 2 on tablet (sm), 3 on desktop (lg 1024 px)
  # The sm=2 prevents the cards from being too narrow on mid-sized tablets
  defp grid_class(3), do: "grid-cols-1 sm:grid-cols-2 lg:grid-cols-3"

  # 4-column: 2 on tablet (sm), 4 on desktop (lg)
  # Skipping 3 columns at an intermediate breakpoint keeps the layout symmetric
  defp grid_class(4), do: "grid-cols-1 sm:grid-cols-2 lg:grid-cols-4"
end
