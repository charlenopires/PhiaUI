# Tutorial: Charts — Complete Guide

PhiaUI ships 19 chart types rendered entirely as server-side SVG with zero JavaScript required. This tutorial covers every chart component, data formats, customisation hooks, composable patterns, and real-time LiveView integration.

## What you'll learn

- How data is structured for every chart type
- All 19 chart components and their key attributes
- Composable charts with `xy_chart` (mixed bar + line + area)
- Responsive wrappers and aspect-ratio scaling
- Theme overrides, custom colours, animation control
- Real-time dashboard with Phoenix LiveView streams
- Advanced patterns: mark lines, data zoom, chart toolbox

---

## Prerequisites

- Elixir 1.17+ and Phoenix 1.7+ with LiveView 1.0+
- TailwindCSS v4 configured in your project
- PhiaUI installed: `{:phia_ui, "~> 0.1.14"}` in `mix.exs`

---

## Step 1 — Install PhiaUI

```bash
mix deps.get
mix phia.install
```

Import the CSS layer in `assets/css/app.css`:

```css
@import "../../deps/phia_ui/priv/static/theme.css";
```

Import PhiaUI hooks in `assets/js/app.js`:

```javascript
import { PhiaHooks } from "./phia_hooks"

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { ...PhiaHooks }
})
```

Import the `Data` module in any LiveView that renders charts:

```elixir
import PhiaUi.Components.Data
```

---

## Step 2 — Data format

All PhiaUI charts use a consistent data format so you can swap chart types without changing your data pipeline.

### Series-based charts (bar, line, area, radar, scatter)

```elixir
# Single series
series = [%{name: "Revenue", data: [120, 200, 150, 80, 250, 190]}]

# Multi-series — grouped or stacked
series = [
  %{name: "Desktop", data: [120, 200, 150, 80, 250, 190]},
  %{name: "Mobile",  data: [90,  140, 110, 60, 180, 150]}
]

# X-axis category labels
categories = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
```

### Slice-based charts (pie, donut, polar area)

```elixir
data = [
  %{label: "Direct",   value: 40},
  %{label: "Organic",  value: 30},
  %{label: "Referral", value: 20},
  %{label: "Social",   value: 10}
]
```

### Scatter / bubble

```elixir
# Scatter: {x, y} tuples
series = [%{name: "Cluster A", data: [{1.2, 3.4}, {2.1, 4.5}, {3.8, 2.9}]}]

# Bubble: {x, y, r} tuples where r is bubble radius
series = [%{name: "Segments", data: [{1, 2, 10}, {3, 4, 25}, {5, 1, 15}]}]
```

### Heatmap

```elixir
# series is a list of row maps; categories is a list of column labels
series = [
  %{name: "Mon", data: [12, 8, 4, 20, 15, 9, 3]},
  %{name: "Tue", data: [7,  3, 18, 11, 6, 14, 10]},
  %{name: "Wed", data: [5, 16, 9, 2, 18, 7, 13]}
]
categories = ~w[00:00 04:00 08:00 12:00 16:00 20:00 23:00]
```

### Waterfall

```elixir
data = [
  %{label: "Start",       value: 100},
  %{label: "New sales",   value: 50},
  %{label: "Refunds",     value: -20},
  %{label: "Upsell",      value: 30},
  %{label: "Churn",       value: -15},
  %{label: "End",         value: 145}
]
```

### Treemap

```elixir
data = [
  %{label: "Engineering", value: 60},
  %{label: "Marketing",   value: 30},
  %{label: "Sales",       value: 25},
  %{label: "Design",      value: 15},
  %{label: "Support",     value: 10}
]
```

---

## Step 3 — All 19 chart types

### Bar chart

Vertical bars, grouped, stacked, or horizontal. Best for categorical comparisons.

```heex
<%!-- Basic vertical bar --%>
<.bar_chart
  id="bar-basic"
  series={[%{name: "Sales", data: [120, 200, 150, 80, 250, 190]}]}
  categories={["Jan", "Feb", "Mar", "Apr", "May", "Jun"]}
/>

<%!-- Grouped (multi-series, default) --%>
<.bar_chart
  id="bar-grouped"
  series={[
    %{name: "Desktop", data: [120, 200, 150, 80, 250, 190]},
    %{name: "Mobile",  data: [90,  140, 110, 60, 180, 150]}
  ]}
  categories={["Jan", "Feb", "Mar", "Apr", "May", "Jun"]}
/>

<%!-- Stacked --%>
<.bar_chart
  id="bar-stacked"
  series={@series}
  categories={@categories}
  stacked={true}
  show_totals={true}
/>

<%!-- Horizontal --%>
<.bar_chart
  id="bar-horizontal"
  series={@series}
  categories={@categories}
  orientation={:horizontal}
  border_radius={4}
/>
```

Key attributes: `stacked`, `orientation` (`:vertical` / `:horizontal`), `border_radius`, `show_totals`, `animate`, `animation_duration`, `colors`, `theme`.

---

### Line chart

Continuous line with optional dots. Supports 6 curve modes.

```heex
<%!-- Default linear --%>
<.line_chart id="line" series={@series} categories={@categories} />

<%!-- Smooth Catmull-Rom spline --%>
<.line_chart id="line-smooth" series={@series} categories={@categories} curve={:smooth} />

<%!-- Monotone cubic (no overshoot, recommended for time series) --%>
<.line_chart id="line-mono" series={@series} categories={@categories} curve={:monotone} />

<%!-- Step variants --%>
<.line_chart id="line-step"        series={@series} categories={@categories} curve={:step_after} />
<.line_chart id="line-step-before" series={@series} categories={@categories} curve={:step_before} />
<.line_chart id="line-step-mid"    series={@series} categories={@categories} curve={:step_middle} />

<%!-- With point labels --%>
<.line_chart id="line-labels" series={@series} categories={@categories} show_point_labels={true} />
```

Key attributes: `curve` (`:linear` / `:smooth` / `:monotone` / `:step_before` / `:step_after` / `:step_middle`), `show_point_labels`, `animate`, `animation_duration`, `colors`, `theme`.

---

### Area chart

Filled line chart. Stacking is correct — areas use cumulative baselines.

```heex
<%!-- Basic filled area --%>
<.area_chart id="area" series={@series} categories={@categories} />

<%!-- Stacked areas --%>
<.area_chart id="area-stacked" series={@series} categories={@categories} stacked={true} />

<%!-- Smooth curve + point labels --%>
<.area_chart
  id="area-smooth"
  series={@series}
  categories={@categories}
  curve={:smooth}
  show_point_labels={true}
/>
```

Key attributes: same as line chart, plus `stacked`.

---

### Pie chart

360° slice chart with optional leader-line labels.

```heex
<.pie_chart
  id="pie"
  data={[
    %{label: "Direct",   value: 40},
    %{label: "Organic",  value: 30},
    %{label: "Referral", value: 20},
    %{label: "Social",   value: 10}
  ]}
/>

<%!-- With arc link labels (Nivo-style leader lines) --%>
<.pie_chart
  id="pie-links"
  data={@pie_data}
  show_link_labels={true}
  spacing={2}
  corner_radius={4}
/>
```

Key attributes: `data`, `colors`, `spacing`, `corner_radius`, `show_link_labels`, `animate`.

---

### Donut chart

Pie chart with a hollow centre. Accepts a `center_label` slot for KPI text.

```heex
<.donut_chart
  id="donut"
  data={[
    %{label: "Chrome",  value: 62},
    %{label: "Safari",  value: 20},
    %{label: "Firefox", value: 12},
    %{label: "Other",   value: 6}
  ]}
>
  <:center_label>
    Browsers<br/>100%
  </:center_label>
</.donut_chart>
```

Key attributes: same as `pie_chart`, plus the `center_label` slot.

---

### Radar chart

Spider-web polygon. Best for multi-dimensional profile comparisons.

```heex
<.radar_chart
  id="radar"
  series={[
    %{name: "Product A", data: [80, 60, 90, 70, 85]},
    %{name: "Product B", data: [60, 75, 55, 90, 65]}
  ]}
  categories={["Performance", "Design", "Reliability", "Support", "Value"]}
/>
```

---

### Scatter chart

X/Y point cloud. Data is `{x, y}` tuples inside each series.

```heex
<.scatter_chart
  id="scatter"
  series={[
    %{name: "Group A", data: [{1.2, 3.4}, {2.1, 4.5}, {0.8, 2.1}, {3.5, 5.0}]},
    %{name: "Group B", data: [{4.0, 1.8}, {5.1, 2.9}, {3.8, 3.2}]}
  ]}
  show_point_labels={false}
/>
```

---

### Bubble chart

Scatter chart where each point `{x, y, r}` includes a radius.

```heex
<.bubble_chart
  id="bubble"
  series={[
    %{name: "Segments", data: [
      {1, 2, 10},
      {3, 4, 25},
      {5, 1, 15},
      {2, 5, 20}
    ]}
  ]}
/>
```

---

### Radial bar chart

Progress arcs arranged concentrically. Useful for multi-metric attainment.

```heex
<.radial_bar_chart
  id="radial"
  series={[
    %{name: "Revenue",     data: [78]},
    %{name: "Users",       data: [63]},
    %{name: "Conversions", data: [45]}
  ]}
/>
```

---

### Histogram chart

Frequency distribution with configurable bin count.

```heex
<.histogram_chart
  id="hist"
  series={[%{name: "Response Time (ms)", data: [42,85,67,120,95,200,55,73,88,140,110,62]}]}
  bins={8}
/>
```

Key attributes: `bins` (default 10).

---

### Waterfall chart

Running total with positive/negative segments. Accepts explicit `%{label, value}` list.

```heex
<.waterfall_chart
  id="waterfall"
  data={[
    %{label: "Q1 Revenue",  value: 500_000},
    %{label: "New Deals",   value: 120_000},
    %{label: "Churn",       value: -45_000},
    %{label: "Upsell",      value: 80_000},
    %{label: "COGS",        value: -200_000},
    %{label: "Net",         value: 455_000}
  ]}
/>
```

---

### Heatmap chart

Grid of coloured cells. Intensity maps from min → max value.

```heex
<.heatmap_chart
  id="heat"
  series={[
    %{name: "Mon", data: [12, 8,  4, 20, 15,  9,  3]},
    %{name: "Tue", data: [ 7, 3, 18, 11,  6, 14, 10]},
    %{name: "Wed", data: [ 5,16,  9,  2, 18,  7, 13]},
    %{name: "Thu", data: [19, 4, 14,  8, 11,  3, 16]},
    %{name: "Fri", data: [ 2,17,  7, 13,  4, 20,  8]}
  ]}
  categories={["00:00", "04:00", "08:00", "12:00", "16:00", "20:00", "23:00"]}
/>
```

---

### Bullet chart

Compact progress bar with a target marker. Useful for KPI attainment.

```heex
<.bullet_chart
  id="bullet"
  series={[
    %{name: "Revenue",     data: [78],  target: 90, ranges: [60, 80, 100]},
    %{name: "Users",       data: [63],  target: 75, ranges: [50, 70, 100]},
    %{name: "Conversions", data: [45],  target: 60, ranges: [30, 55, 100]}
  ]}
/>
```

---

### Slope chart

Before/after comparison across two time points.

```heex
<.slope_chart
  id="slope"
  series={[
    %{name: "Product A", data: [42, 68]},
    %{name: "Product B", data: [75, 55]},
    %{name: "Product C", data: [30, 52]}
  ]}
  categories={["2023", "2024"]}
/>
```

---

### Treemap chart

Nested rectangles with area proportional to value.

```heex
<.treemap_chart
  id="treemap"
  data={[
    %{label: "Engineering", value: 60},
    %{label: "Marketing",   value: 30},
    %{label: "Sales",       value: 25},
    %{label: "Design",      value: 15},
    %{label: "Support",     value: 10}
  ]}
/>
```

---

### Timeline chart

Gantt-style horizontal bars across a time axis.

```heex
<.timeline_chart
  id="timeline"
  data={[
    %{label: "Discovery",    start: 1, finish: 3},
    %{label: "Design",       start: 2, finish: 5},
    %{label: "Development",  start: 4, finish: 10},
    %{label: "QA",           start: 9, finish: 11},
    %{label: "Launch",       start: 11, finish: 12}
  ]}
  categories={["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]}
/>
```

---

### Polar area chart

Equal-angle wedges with variable radius (Chart.js PolarArea pattern).

```heex
<.polar_area_chart
  id="polar"
  data={[
    %{label: "North", value: 80},
    %{label: "East",  value: 55},
    %{label: "South", value: 70},
    %{label: "West",  value: 45}
  ]}
/>
```

---

### Gauge chart

Semicircular dial. Supports coloured zones and a threshold marker.

```heex
<.gauge_chart
  id="gauge"
  value={73}
  max={100}
  zones={[{0, 40, "#ef4444"}, {40, 70, "#f59e0b"}, {70, 100, "#22c55e"}]}
  animate={true}
>
  <:center_label>
    <tspan font-size="24" font-weight="700">73%</tspan>
    <tspan x="0" dy="18" font-size="11">Health Score</tspan>
  </:center_label>
</.gauge_chart>
```

Key attributes: `value`, `min`, `max`, `zones`, `threshold`, `animate`, `animation_duration`, `center_label` slot.

---

### Sparkline card

Inline KPI card with a tiny line chart. No axes.

```heex
<.sparkline_card
  id="orders"
  title="Orders"
  value="1,247"
  sparkline_data={[80, 95, 110, 90, 125, 140, 130]}
  delta={12.5}
  delta_type={:increase}
  animate={true}
/>
```

---

## Step 4 — Composable charts with `xy_chart`

`xy_chart` lets you mix bar, line, and area series in a single viewport without writing any SVG.

```heex
<.xy_chart
  id="mixed"
  categories={["Jan", "Feb", "Mar", "Apr", "May", "Jun"]}
>
  <:series type={:bar}  name="Revenue"   data={[120, 200, 150, 80, 250, 190]} />
  <:series type={:line} name="Trend"     data={[100, 160, 140, 120, 210, 180]} />
  <:series type={:area} name="Forecast"  data={[140, 180, 160, 130, 230, 200]} />
</.xy_chart>
```

`xy_chart` uses `ChartCoord.auto_cartesian` to compute domains automatically and `ChartSeriesRegistry.render` to dispatch to the correct renderer per series type.

You can also add scatter series:

```heex
<.xy_chart id="scatter-mixed" categories={@categories}>
  <:series type={:bar}     name="Volume"  data={@volumes} />
  <:series type={:scatter} name="Outliers" data={[{1, 150}, {3, 210}, {5, 95}]} />
</.xy_chart>
```

---

## Step 5 — Responsive charts

Wrap any chart in `responsive_chart` to apply a CSS `aspect-ratio` container that scales the SVG automatically on all screen sizes.

```heex
<%!-- 16:9 — good for area/line --%>
<.responsive_chart ratio="16/9">
  <.line_chart id="resp-line" series={@series} categories={@categories} />
</.responsive_chart>

<%!-- 4:3 — good for bar charts --%>
<.responsive_chart ratio="4/3">
  <.bar_chart id="resp-bar" series={@series} categories={@categories} />
</.responsive_chart>

<%!-- Square — good for pie/donut --%>
<.responsive_chart ratio="1/1">
  <.donut_chart id="resp-donut" data={@pie_data} />
</.responsive_chart>
```

---

## Step 6 — Customisation

### Custom colours

Pass a list of hex colours. PhiaUI cycles through them when there are more series than colours.

```heex
<.bar_chart
  id="custom-colors"
  series={@series}
  categories={@categories}
  colors={["#6366f1", "#f59e0b", "#10b981", "#ef4444"]}
/>
```

### Theme overrides

The `theme` attribute deep-merges onto the default `ChartTheme`. Useful for adjusting axis font size, grid colour, or legend positioning.

```heex
<.bar_chart
  id="themed"
  series={@series}
  categories={@categories}
  theme={%{
    axis:   %{font_size: 14, color: "#6b7280"},
    grid:   %{stroke: "#e5e7eb", stroke_dasharray: "4 2"},
    legend: %{position: :bottom}
  }}
/>
```

### Animation control

All charts with `animate` support an `animation_duration` attribute (milliseconds).

```heex
<.line_chart
  id="animated"
  series={@series}
  categories={@categories}
  animate={true}
  animation_duration={1200}
/>

<%!-- Disable for reduced-motion environments --%>
<.bar_chart id="no-anim" series={@series} categories={@categories} animate={false} />
```

> **Note:** PhiaUI automatically respects `prefers-reduced-motion` via a CSS rule in `theme.css`. Setting `animate={true}` is safe for all users.

### Border radius (bar charts)

```heex
<.bar_chart
  id="rounded"
  series={@series}
  categories={@categories}
  border_radius={8}
/>
```

---

## Step 7 — Advanced: mark lines and mark points

Add reference lines (average, median, custom threshold) or marker symbols to any SVG chart.

```heex
<%!-- Dashed average line --%>
<.bar_chart id="bar-mark" series={@series} categories={@categories}>
  <.chart_mark_line type={:average} label="Avg" />
</.bar_chart>

<%!-- Custom threshold --%>
<.bar_chart id="bar-threshold" series={@series} categories={@categories}>
  <.chart_mark_line type={:custom} value={150} label="Target" />
</.bar_chart>

<%!-- Max point marker --%>
<.line_chart id="line-mark" series={@series} categories={@categories}>
  <.chart_mark_point type={:max} symbol={:diamond} />
  <.chart_mark_point type={:min} symbol={:circle} />
</.line_chart>
```

---

## Step 8 — Advanced: data zoom

`data_zoom` adds a range slider beneath the chart. Drag the handles to zoom into a region. The `PhiaDataZoom` hook handles pointer interaction.

```heex
<div class="space-y-2">
  <.line_chart id="zoom-chart" series={@series} categories={@categories} />
  <.data_zoom id="zoom-bar" target="zoom-chart" initial_start={0} initial_end={100} />
</div>
```

---

## Step 9 — Advanced: chart toolbox

Download, reset, and toggle series visibility with `chart_toolbox`.

```heex
<div class="space-y-2">
  <.chart_toolbox id="toolbox" target="my-chart" />
  <.bar_chart id="my-chart" series={@series} categories={@categories} />
</div>
```

---

## Step 10 — Real-time dashboard with LiveView

Charts update instantly when you push new data using `assign` or streams. No JavaScript coordination needed — LiveView diffs the SVG in the DOM.

```elixir
defmodule MyAppWeb.RealtimeDashboardLive do
  use MyAppWeb, :live_view
  import PhiaUi.Components.Data
  import PhiaUi.Components.Cards

  @update_interval_ms 5_000

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: schedule_update()

    {:ok,
     socket
     |> assign(:categories, last_12_months())
     |> assign(:revenue_series, revenue_series())
     |> assign(:pie_data, traffic_sources())}
  end

  @impl true
  def handle_info(:update_charts, socket) do
    schedule_update()

    {:noreply,
     socket
     |> assign(:revenue_series, revenue_series())
     |> assign(:pie_data, traffic_sources())}
  end

  defp schedule_update do
    Process.send_after(self(), :update_charts, @update_interval_ms)
  end

  defp last_12_months do
    today = Date.utc_today()
    for i <- 11..0//-1 do
      today
      |> Date.add(-i * 30)
      |> Calendar.strftime("%b")
    end
  end

  defp revenue_series do
    # Replace with real DB queries
    [%{name: "Revenue", data: Enum.map(1..12, fn _ -> :rand.uniform(500) + 100 end)}]
  end

  defp traffic_sources do
    [
      %{label: "Direct",   value: :rand.uniform(50) + 20},
      %{label: "Organic",  value: :rand.uniform(40) + 15},
      %{label: "Referral", value: :rand.uniform(30) + 10},
      %{label: "Social",   value: :rand.uniform(20) + 5}
    ]
  end
end
```

```heex
<%!-- lib/my_app_web/live/realtime_dashboard_live.html.heex --%>
<div class="p-6 space-y-6">
  <h1 class="text-2xl font-bold tracking-tight">Real-time Dashboard</h1>

  <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
    <%!-- Revenue line chart updates every 5 seconds --%>
    <div class="rounded-lg border bg-card p-4 space-y-2">
      <p class="text-sm font-medium text-muted-foreground">Revenue (12 months)</p>
      <.responsive_chart ratio="16/9">
        <.line_chart
          id="rt-revenue"
          series={@revenue_series}
          categories={@categories}
          curve={:monotone}
          animate={false}
        />
      </.responsive_chart>
    </div>

    <%!-- Traffic source donut --%>
    <div class="rounded-lg border bg-card p-4 space-y-2">
      <p class="text-sm font-medium text-muted-foreground">Traffic Sources</p>
      <.responsive_chart ratio="1/1">
        <.donut_chart id="rt-traffic" data={@pie_data} show_link_labels={true}>
          <:center_label>Sources</:center_label>
        </.donut_chart>
      </.responsive_chart>
    </div>
  </div>
</div>
```

> **Tip:** Set `animate={false}` for real-time charts to avoid re-triggering CSS animations on every update.

---

## Step 11 — Complete analytics page example

A full-page analytics view with KPI cards, mixed chart, heatmap, and sparklines:

```elixir
defmodule MyAppWeb.AnalyticsLive do
  use MyAppWeb, :live_view
  import PhiaUi.Components.Data
  import PhiaUi.Components.Cards
  import PhiaUi.Components.Display

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:categories, ~w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec])
     |> assign(:revenue_series, [
          %{name: "Desktop", data: [120, 200, 150, 80, 250, 190, 210, 180, 230, 270, 300, 320]},
          %{name: "Mobile",  data: [ 90, 140, 110, 60, 180, 150, 170, 140, 190, 220, 250, 280]}
        ])
     |> assign(:pie_data, [
          %{label: "Direct", value: 40},
          %{label: "Organic", value: 30},
          %{label: "Referral", value: 20},
          %{label: "Social", value: 10}
        ])
     |> assign(:heatmap_series, build_heatmap())
     |> assign(:heatmap_categories, ~w[Mon Tue Wed Thu Fri Sat Sun])}
  end

  defp build_heatmap do
    hours = ~w[00 04 08 12 16 20]
    for h <- hours do
      %{name: "#{h}:00", data: Enum.map(1..7, fn _ -> :rand.uniform(20) end)}
    end
  end
end
```

```heex
<div class="p-6 space-y-8">
  <%!-- KPI row --%>
  <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
    <.sparkline_card id="sp-revenue" title="Revenue"    value="$142k"
      sparkline_data={[80, 95, 110, 90, 125, 140, 130]} delta={12.5} delta_type={:increase} />
    <.sparkline_card id="sp-users"   title="Users"      value="8,420"
      sparkline_data={[60, 70, 65, 80, 75, 90, 85]}    delta={5.3}  delta_type={:increase} />
    <.sparkline_card id="sp-orders"  title="Orders"     value="1,247"
      sparkline_data={[40, 55, 50, 65, 60, 70, 68]}    delta={-2.1} delta_type={:decrease} />
    <.sparkline_card id="sp-churn"   title="Churn Rate" value="2.3%"
      sparkline_data={[3.1, 2.8, 2.5, 2.6, 2.4, 2.3, 2.3]} delta={-0.8} delta_type={:decrease} />
  </div>

  <%!-- Revenue: stacked area + donut side by side --%>
  <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
    <div class="lg:col-span-2 rounded-lg border bg-card p-4 space-y-2">
      <p class="text-sm font-medium">Revenue by channel (stacked)</p>
      <.area_chart
        id="revenue-area"
        series={@revenue_series}
        categories={@categories}
        stacked={true}
        curve={:monotone}
        animate={true}
      />
    </div>
    <div class="rounded-lg border bg-card p-4 space-y-2">
      <p class="text-sm font-medium">Traffic sources</p>
      <.donut_chart id="traffic-donut" data={@pie_data} show_link_labels={true}>
        <:center_label>Traffic</:center_label>
      </.donut_chart>
    </div>
  </div>

  <%!-- Composable mixed chart --%>
  <div class="rounded-lg border bg-card p-4 space-y-2">
    <p class="text-sm font-medium">Volume vs. Trend</p>
    <.xy_chart id="mixed" categories={@categories}>
      <:series type={:bar}  name="Volume" data={[120, 200, 150, 80, 250, 190, 210, 180, 230, 270, 300, 320]} />
      <:series type={:line} name="Trend"  data={[100, 150, 130, 90, 200, 170, 190, 160, 210, 245, 275, 300]} />
    </.xy_chart>
  </div>

  <%!-- Activity heatmap --%>
  <div class="rounded-lg border bg-card p-4 space-y-2">
    <p class="text-sm font-medium">Activity heatmap (hour × weekday)</p>
    <.heatmap_chart
      id="activity-heat"
      series={@heatmap_series}
      categories={@heatmap_categories}
    />
  </div>
</div>
```

---

## Chart component quick reference

| Component | Data input | Best for |
|---|---|---|
| `bar_chart` | `series` + `categories` | Categorical comparison |
| `line_chart` | `series` + `categories` | Trends over time |
| `area_chart` | `series` + `categories` | Volume + trend |
| `pie_chart` | `data` list | Part-to-whole |
| `donut_chart` | `data` list | Part-to-whole + KPI centre |
| `radar_chart` | `series` + `categories` | Multi-axis profiles |
| `scatter_chart` | `series` with `{x,y}` tuples | Correlation |
| `bubble_chart` | `series` with `{x,y,r}` tuples | Weighted correlation |
| `radial_bar_chart` | `series` | Multi-metric attainment |
| `histogram_chart` | `series` + `bins` | Distribution |
| `waterfall_chart` | `data` list | Running totals |
| `heatmap_chart` | `series` + `categories` | Matrix intensity |
| `bullet_chart` | `series` with `target`/`ranges` | KPI vs. target |
| `slope_chart` | `series` + 2 `categories` | Before/after |
| `treemap_chart` | `data` list | Hierarchical size |
| `timeline_chart` | `data` with `start`/`finish` | Gantt / project schedule |
| `polar_area_chart` | `data` list | Directional / polar categories |
| `gauge_chart` | `value` scalar | Single KPI dial |
| `sparkline_card` | `sparkline_data` list | Inline mini-trend |
| `xy_chart` | `series` slots (bar/line/area/scatter) | Composable mixed chart |

---

## Related guides

- [Analytics Dashboard tutorial](tutorial-dashboard.md) — full shell + data grid + chart
- [Charts & Data components reference](data.md)
- [Design System](theme-system.md) — colour tokens and dark mode
