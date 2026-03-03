# Dashboard & Analytics Components

Components for building enterprise dashboards: layout shell, navigation, data tables, metrics, and chart integration.

- [Dashboard Shell](#dashboard-shell)
- [Dark Mode Toggle](#dark-mode-toggle)
- [Color Theme Switching](#color-theme-switching)
- [Table](#table)
- [DataGrid with Sorting](#datagrid-with-sorting)
- [Stat Card](#stat-card)
- [Metric Grid](#metric-grid)
- [Chart Shell](#chart-shell)
- [Chart (PhiaChart)](#chart-phiachart)

---

## Dashboard Shell

Full-page layout with CSS Grid sidebar + main content. Mobile drawer auto-closes on `md:` breakpoint.

```heex
<.shell>
  <:topbar>
    <.topbar>
      <:brand>
        <span class="font-bold text-lg">MyApp</span>
      </:brand>
      <:actions>
        <.dark_mode_toggle id="theme-toggle" />
        <.dropdown_menu id="user-menu">
          <%!-- user avatar menu --%>
        </.dropdown_menu>
      </:actions>
      <.mobile_sidebar_toggle />
    </.topbar>
  </:topbar>

  <:sidebar>
    <.sidebar>
      <:brand>
        <.icon name="layers" />
        <span class="font-bold">MyApp</span>
      </:brand>
      <:nav_items>
        <.sidebar_item href={~p"/dashboard"} active={@current_path == "/dashboard"}>
          <.icon name="layout-dashboard" /> Dashboard
        </.sidebar_item>
        <.sidebar_item href={~p"/analytics"} active={@current_path == "/analytics"}>
          <.icon name="bar-chart-2" /> Analytics
        </.sidebar_item>
        <.sidebar_item href={~p"/users"} active={@current_path == "/users"}>
          <.icon name="users" /> Users
        </.sidebar_item>
        <.sidebar_item href={~p"/reports"} active={@current_path == "/reports"}>
          <.icon name="file-text" /> Reports
        </.sidebar_item>
        <.sidebar_item href={~p"/settings"} active={@current_path == "/settings"}>
          <.icon name="settings" /> Settings
        </.sidebar_item>
      </:nav_items>
      <:footer>
        <.sidebar_item href={~p"/help"}>
          <.icon name="help-circle" /> Help & Docs
        </.sidebar_item>
      </:footer>
    </.sidebar>
  </:sidebar>

  <main class="flex flex-col gap-6 p-6 overflow-y-auto">
    <%= @inner_content %>
  </main>
</.shell>
```

### Embedding in a LiveView layout

```elixir
# lib/my_app_web/layouts/dashboard.html.heex
<.shell>
  <:topbar>…</:topbar>
  <:sidebar>…</:sidebar>
  <main class="p-6">
    <%= @inner_content %>
  </main>
</.shell>
```

### With breadcrumb in topbar

```heex
<.topbar>
  <:brand>
    <.breadcrumb>
      <.breadcrumb_list>
        <.breadcrumb_item>
          <.breadcrumb_link navigate={~p"/dashboard"}>Dashboard</.breadcrumb_link>
        </.breadcrumb_item>
        <.breadcrumb_separator />
        <.breadcrumb_item>
          <.breadcrumb_page><%= @page_title %></.breadcrumb_page>
        </.breadcrumb_item>
      </.breadcrumb_list>
    </.breadcrumb>
  </:brand>
  <:actions>
    <.dark_mode_toggle id="theme-toggle" />
  </:actions>
</.topbar>
```

---

## Dark Mode Toggle

Toggles `.dark` class on `<html>`, persists preference in `localStorage`, respects `prefers-color-scheme` on first load.

```heex
<.dark_mode_toggle id="dark-mode-toggle" />
```

### With custom label (via class)

```heex
<div class="flex items-center gap-2">
  <.dark_mode_toggle id="theme-btn" />
  <span class="text-sm text-muted-foreground sr-only">Toggle theme</span>
</div>
```

### Prevent FOUC

Add this script **before** `</head>` in your `root.html.heex`:

```html
<script>
  (function() {
    var mode = localStorage.getItem('phia-mode') || localStorage.getItem('phia-theme');
    if (mode === 'dark' || (!mode && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
      document.documentElement.classList.add('dark');
    }
    var ct = localStorage.getItem('phia-color-theme');
    if (ct) document.documentElement.setAttribute('data-phia-theme', ct);
  })();
</script>
```

### TailwindCSS v4 setup

Add to your `theme.css`:

```css
@custom-variant dark (&:where(.dark, .dark *));
```

Then use `dark:` utilities in your components:

```html
<div class="bg-background dark:bg-slate-950">…</div>
```

### Required hook

```javascript
import PhiaDarkMode from "./phia_hooks/dark_mode"
```

---

## Color Theme Switching

PhiaUI includes 8 built-in OKLCH color presets. The CSS-first theme system uses `data-phia-theme`
attribute selectors — activating a theme is a single `setAttribute` call with zero runtime overhead.

### Setup

Generate the multi-theme CSS file and auto-import it:

```bash
mix phia.theme install
```

This creates `assets/css/phia-themes.css` and injects `@import "./phia-themes.css";` into your `app.css`.

### Available presets

| Preset | `data-phia-theme` |
|--------|------------------|
| Zinc (default) | `zinc` |
| Slate | `slate` |
| Blue | `blue` |
| Rose | `rose` |
| Orange | `orange` |
| Green | `green` |
| Violet | `violet` |
| Neutral | `neutral` |

### Activate a preset in HTML

```heex
<%!-- Entire app uses blue theme --%>
<html lang="en" data-phia-theme="blue" class="dark">
```

### Scoped to a section via ThemeProvider

```heex
<%!-- Only this section uses the rose preset --%>
<.theme_provider theme={:rose} class="p-4 rounded-lg border">
  <.button>Rose Button</.button>
  <.badge variant="default">Active</.badge>
</.theme_provider>
```

### Runtime switching with PhiaTheme hook

The `PhiaTheme` hook lets users switch presets without a page reload. Works with buttons and selects.

**Select dropdown:**

```heex
<select phx-hook="PhiaTheme" id="theme-picker" class="...">
  <option value="zinc">Zinc</option>
  <option value="blue">Blue</option>
  <option value="rose">Rose</option>
  <option value="orange">Orange</option>
  <option value="green">Green</option>
  <option value="violet">Violet</option>
</select>
```

**Button group:**

```heex
<.button_group>
  <.button phx-hook="PhiaTheme" id="t-zinc" data-theme="zinc" variant="outline" size="sm">Zinc</.button>
  <.button phx-hook="PhiaTheme" id="t-blue" data-theme="blue" variant="outline" size="sm">Blue</.button>
  <.button phx-hook="PhiaTheme" id="t-rose" data-theme="rose" variant="outline" size="sm">Rose</.button>
</.button_group>
```

The hook persists the selection to `localStorage['phia-color-theme']` and dispatches a
`phia:color-theme-changed` CustomEvent so other hooks (e.g. `PhiaChart`) can re-render with new colors.

### Required hook

```javascript
import PhiaTheme from "./phia_hooks/theme"

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { PhiaTheme, PhiaDarkMode, /* ... */ }
})
```

---

## Table

Streams-compatible data table. The body uses `phx-update="stream"` for O(1) row updates.

```heex
<.table>
  <.table_header>
    <.table_row>
      <.table_head>Customer</.table_head>
      <.table_head>Status</.table_head>
      <.table_head>Amount</.table_head>
      <.table_head class="text-right">Actions</.table_head>
    </.table_row>
  </.table_header>
  <.table_body>
    <.table_row :for={{dom_id, row} <- @streams.orders} id={dom_id}>
      <.table_cell class="font-medium"><%= row.customer_name %></.table_cell>
      <.table_cell>
        <.badge variant={badge_variant(row.status)}><%= row.status %></.badge>
      </.table_cell>
      <.table_cell><%= Number.Currency.number_to_currency(row.amount) %></.table_cell>
      <.table_cell class="text-right">
        <.dropdown_menu id={"actions-#{dom_id}"}>
          <%!-- actions --%>
        </.dropdown_menu>
      </.table_cell>
    </.table_row>
  </.table_body>
  <.table_footer>
    <.table_row>
      <.table_head colspan="2">Total</.table_head>
      <.table_head><%= @total_amount %></.table_head>
      <.table_head />
    </.table_row>
  </.table_footer>
</.table>
```

### With caption

```heex
<.table>
  <.table_caption>Orders for November 2024</.table_caption>
  <%!-- header + body --%>
</.table>
```

---

## DataGrid with Sorting

Extended table with clickable column headers for server-side sorting. Streams-compatible.

```heex
<.data_grid>
  <.data_grid_head
    sort_key="name"
    sort_dir={if @sort_key == "name", do: @sort_dir, else: :none}
    on_sort="sort"
  >
    Name
  </.data_grid_head>
  <.data_grid_head
    sort_key="revenue"
    sort_dir={if @sort_key == "revenue", do: @sort_dir, else: :none}
    on_sort="sort"
  >
    Revenue
  </.data_grid_head>
  <.data_grid_head>Actions</.data_grid_head>

  <.data_grid_body id="grid-body" phx-update="stream">
    <.data_grid_row :for={{dom_id, row} <- @streams.rows} id={dom_id}>
      <.data_grid_cell><%= row.name %></.data_grid_cell>
      <.data_grid_cell class="tabular-nums">
        <%= Number.Currency.number_to_currency(row.revenue) %>
      </.data_grid_cell>
      <.data_grid_cell>
        <.button variant="ghost" size="sm" phx-click="view" phx-value-id={row.id}>View</.button>
      </.data_grid_cell>
    </.data_grid_row>
  </.data_grid_body>
</.data_grid>
```

### LiveView sort handler

```elixir
def mount(_params, _session, socket) do
  {:ok,
   socket
   |> assign(sort_key: "name", sort_dir: :asc)
   |> stream(:rows, load_rows("name", :asc))}
end

def handle_event("sort", %{"key" => key, "dir" => dir}, socket) do
  sort_dir = String.to_existing_atom(dir)
  rows = load_rows(key, sort_dir)
  {:noreply,
   socket
   |> assign(sort_key: key, sort_dir: sort_dir)
   |> stream(:rows, rows, reset: true)}
end

defp load_rows(key, dir) do
  Reports.list_rows(order_by: [{dir, String.to_atom(key)}])
end
```

### Sort direction atoms

| `sort_dir` | Icon shown | Sends `dir` |
|------------|------------|-------------|
| `:none` | ↕ (chevrons-up-down) | `"asc"` |
| `:asc` | ↑ (chevron-up) | `"desc"` |
| `:desc` | ↓ (chevron-down) | `"none"` |

---

## Stat Card

KPI card with trend indicator, optional icon slot, and footer slot.

```heex
<.stat_card
  title="Monthly Revenue"
  value="$48,290"
  trend="up"
  trend_value="+12.5%"
  description="vs last month"
>
  <:icon><.icon name="dollar-sign" size="lg" class="text-primary" /></:icon>
</.stat_card>
```

### All trend variants

```heex
<.stat_card title="Revenue" value="$48,290" trend="up" trend_value="+12.5%" description="vs last month" />
<.stat_card title="Churn Rate" value="3.1%" trend="down" trend_value="-0.4%" description="this month" />
<.stat_card title="Avg Session" value="4m 32s" trend="neutral" trend_value="0%" description="no change" />
```

### With footer slot

```heex
<.stat_card title="Active Users" value="2,840" trend="up" trend_value="+8.2%">
  <:footer>
    <.button variant="ghost" size="sm" phx-click="view-users">
      View all users <.icon name="arrow-right" size="sm" />
    </.button>
  </:footer>
</.stat_card>
```

---

## Metric Grid

Responsive KPI grid for multiple stat cards.

```heex
<.metric_grid cols={4}>
  <.stat_card title="Revenue" value="$48,290" trend="up" trend_value="+12.5%" description="vs last month">
    <:icon><.icon name="dollar-sign" size="lg" /></:icon>
  </.stat_card>
  <.stat_card title="Active Users" value="2,840" trend="up" trend_value="+8.2%" description="daily active" />
  <.stat_card title="Churn Rate" value="3.1%" trend="down" trend_value="-0.4%" description="this month" />
  <.stat_card title="Avg Session" value="4m 32s" trend="neutral" trend_value="0%" description="no change" />
</.metric_grid>
```

| `cols` | Breakpoint | Layout |
|--------|-----------|--------|
| 1 | any | 1-col always |
| 2 | sm+ | 2-col |
| 3 | sm+/lg+ | 1 → 2 → 3 |
| 4 | sm+/lg+ | 1 → 2 → 4 |

---

## Chart Shell

Titled card container for any chart library. Compatible with VegaLite, Chart.js, ECharts, D3.

```heex
<.chart_shell
  title="Monthly Revenue"
  description="MRR for the past 12 months"
  period="Jan–Dec 2024"
  min_height="320px"
>
  <:actions>
    <.button variant="outline" size="sm">
      <.icon name="download" size="sm" /> Export
    </.button>
  </:actions>
  <%!-- Drop any chart canvas/div here --%>
  <canvas id="revenue-chart" phx-hook="MyRevenueChart" />
</.chart_shell>
```

### With VegaLite

```heex
<.chart_shell title="Distribution" min_height="300px">
  <div id="vega-chart" phx-hook="VegaLite" data-spec={Jason.encode!(@spec)} />
</.chart_shell>
```

---

## Chart (PhiaChart)

Full ECharts integration via the `PhiaChart` hook. JSON config generated server-side, rendered client-side.

```heex
<%!-- Line chart --%>
<.phia_chart
  id="revenue-line"
  type={:line}
  title="Monthly Revenue"
  description="MRR last 12 months"
  series={[%{name: "MRR", data: @mrr_data}]}
  labels={@month_labels}
  height="320px"
/>

<%!-- Bar chart --%>
<.phia_chart
  id="users-bar"
  type={:bar}
  series={[
    %{name: "New", data: @new_users},
    %{name: "Returning", data: @returning_users}
  ]}
  labels={@week_labels}
  height="280px"
/>

<%!-- Area chart --%>
<.phia_chart
  id="sessions-area"
  type={:area}
  series={[%{name: "Sessions", data: @session_data}]}
  labels={@day_labels}
  height="200px"
/>

<%!-- Pie chart --%>
<.phia_chart
  id="traffic-pie"
  type={:pie}
  series={[%{name: "Traffic", data: @traffic_data}]}
  labels={["Organic", "Paid", "Referral", "Direct"]}
  height="300px"
/>
```

### Real-time updates via push_event

```elixir
# Send new series data from the server
def handle_info(:refresh_chart, socket) do
  fresh_data = Analytics.load_mrr()
  {:noreply,
   socket
   |> assign(mrr_data: fresh_data)
   |> push_event("update-chart-revenue-line", %{series: [%{name: "MRR", data: fresh_data}]})}
end
```

### Full dashboard page example

```heex
<div class="space-y-6">
  <.metric_grid cols={4}>
    <.stat_card title="MRR" value={format_currency(@mrr)} trend="up" trend_value="+12.5%" />
    <.stat_card title="Active" value={@active_users} trend="up" trend_value="+8%" />
    <.stat_card title="Churn" value={@churn_rate} trend="down" trend_value="-0.3%" />
    <.stat_card title="NPS" value={@nps} trend="up" trend_value="+5" />
  </.metric_grid>

  <div class="grid grid-cols-2 gap-6">
    <.phia_chart
      id="mrr-chart"
      type={:area}
      title="Revenue"
      description="Monthly recurring revenue"
      series={[%{name: "MRR", data: @mrr_series}]}
      labels={@month_labels}
    />
    <.phia_chart
      id="traffic-chart"
      type={:pie}
      title="Traffic Sources"
      series={[%{name: "Visits", data: @traffic_data}]}
      labels={@traffic_labels}
    />
  </div>

  <.data_grid>
    <.data_grid_head sort_key="customer" sort_dir={@sort_dir_customer} on_sort="sort">Customer</.data_grid_head>
    <.data_grid_head sort_key="mrr" sort_dir={@sort_dir_mrr} on_sort="sort">MRR</.data_grid_head>
    <.data_grid_head>Plan</.data_grid_head>
    <.data_grid_body id="customers-body" phx-update="stream">
      <.data_grid_row :for={{dom_id, c} <- @streams.customers} id={dom_id}>
        <.data_grid_cell><%= c.name %></.data_grid_cell>
        <.data_grid_cell><%= format_currency(c.mrr) %></.data_grid_cell>
        <.data_grid_cell><.badge><%= c.plan %></.badge></.data_grid_cell>
      </.data_grid_row>
    </.data_grid_body>
  </.data_grid>
</div>
```

### ECharts setup

```bash
npm install echarts
```

```javascript
// assets/js/app.js
import * as echarts from "echarts"
window.echarts = echarts   // make globally available for PhiaChart hook

import PhiaChart from "./phia_hooks/chart"
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { PhiaChart }
})
```

### Or via CDN (no npm)

```html
<!-- in root.html.heex, before your app.js -->
<script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>
```

### Required hook

```javascript
import PhiaChart from "./phia_hooks/chart"
```

---

← [Back to README](../../README.md)
