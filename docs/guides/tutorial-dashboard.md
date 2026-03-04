# Tutorial: Building a Dashboard with PhiaUI

This guide walks you through building a complete analytics dashboard using PhiaUI components in Phoenix LiveView — from project setup to a fully functional interface with charts, data tables, KPI cards, and interactive elements.

**What we'll build:**
- A responsive shell with sidebar navigation
- KPI stat cards with trend indicators
- A revenue area chart (ECharts)
- A sortable data table with streams
- A command palette (Ctrl+K)
- Dark mode toggle
- A toast notification system

![Dashboard Preview](../dashboard-preview.png)

---

## Prerequisites

- Phoenix 1.8+ with LiveView 1.1+
- TailwindCSS v4 configured
- Node.js (for ECharts)

---

## Step 1 — Install PhiaUI

Add to `mix.exs`:

```elixir
def deps do
  [
    {:phia_ui, "~> 0.1.3"}
  ]
end
```

```bash
mix deps.get
mix phia.install
```

This copies JS hooks to `assets/js/phia_hooks/` and creates a theme reference file.

---

## Step 2 — Configure TailwindCSS

In `assets/css/app.css`:

```css
@import "tailwindcss";
@import "../../../deps/phia_ui/priv/static/theme.css";
```

The theme file provides semantic OKLCH design tokens (`bg-primary`, `text-muted-foreground`, etc.) and automatic dark mode support.

---

## Step 3 — Eject the components we need

```bash
mix phia.add shell sidebar topbar dark_mode_toggle
mix phia.add stat_card metric_grid chart_shell phia_chart
mix phia.add table data_grid
mix phia.add command toast button badge
mix phia.add dialog alert_dialog
```

Each command copies Elixir modules to `lib/your_app_web/components/ui/`.

---

## Step 4 — Register JS Hooks

In `assets/js/app.js`:

```javascript
import PhiaDarkMode        from "./phia_hooks/dark_mode"
import PhiaCommand         from "./phia_hooks/command"
import PhiaToast           from "./phia_hooks/toast"
import PhiaChart           from "./phia_hooks/chart"
import PhiaDialog          from "./phia_hooks/dialog"
import PhiaDropdownMenu    from "./phia_hooks/dropdown_menu"
import PhiaTooltip         from "./phia_hooks/tooltip"

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: {
    PhiaDarkMode,
    PhiaCommand,
    PhiaToast,
    PhiaChart,
    PhiaDialog,
    PhiaDropdownMenu,
    PhiaTooltip,
  }
})
```

---

## Step 5 — Install ECharts (for charts)

```bash
cd assets && npm install echarts
```

In `assets/js/app.js`, import before liveSocket:

```javascript
import * as echarts from "echarts"
window.echarts = echarts
```

---

## Step 6 — Create the Dashboard LiveView

Create `lib/your_app_web/live/dashboard_live.ex`:

```elixir
defmodule YourAppWeb.DashboardLive do
  use YourAppWeb, :live_view

  import YourAppWeb.Components.UI.Shell
  import YourAppWeb.Components.UI.Sidebar
  import YourAppWeb.Components.UI.Topbar
  import YourAppWeb.Components.UI.DarkModeToggle
  import YourAppWeb.Components.UI.StatCard
  import YourAppWeb.Components.UI.MetricGrid
  import YourAppWeb.Components.UI.PhiaChart
  import YourAppWeb.Components.UI.DataGrid
  import YourAppWeb.Components.UI.Command
  import YourAppWeb.Components.UI.Toast
  import YourAppWeb.Components.UI.Button
  import YourAppWeb.Components.UI.Badge

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Dashboard")
     |> assign(:command_open, false)
     |> assign(:sort_by, "name")
     |> assign(:sort_dir, "asc")
     |> assign(:orders, sample_orders())
     |> assign(:mrr_data, [38_200, 41_500, 39_800, 44_100, 46_300, 48_290])
     |> assign(:month_labels, ~w(Oct Nov Dec Jan Feb Mar))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%!-- Mount the toast viewport once --%>
    <.toast id="toast-viewport" />

    <%!-- Command palette (Ctrl+K) --%>
    <.command id="cmd" open={@command_open}>
      <.command_input id="cmd-input" on_change="search" placeholder="Search…" />
      <.command_list id="cmd-results">
        <.command_empty>No results found.</.command_empty>
        <.command_group label="Navigation">
          <.command_item on_click="navigate" value="/dashboard">Dashboard</.command_item>
          <.command_item on_click="navigate" value="/orders">Orders</.command_item>
          <.command_item on_click="navigate" value="/customers">Customers</.command_item>
        </.command_group>
      </.command_list>
    </.command>

    <%!-- Main shell layout --%>
    <.shell>
      <:sidebar>
        <.sidebar>
          <:brand>
            <div class="flex items-center gap-2 px-6 py-4">
              <div class="h-8 w-8 rounded-lg bg-primary flex items-center justify-center">
                <span class="text-primary-foreground font-bold text-sm">A</span>
              </div>
              <span class="font-semibold">Acme Corp</span>
            </div>
          </:brand>
          <:nav>
            <nav class="px-3 space-y-1">
              <.sidebar_item href="/dashboard" active={true}>
                <.icon name="layout-dashboard" size="sm" class="mr-2" />
                Dashboard
              </.sidebar_item>
              <.sidebar_item href="/orders">
                <.icon name="shopping-cart" size="sm" class="mr-2" />
                Orders
              </.sidebar_item>
              <.sidebar_item href="/customers">
                <.icon name="users" size="sm" class="mr-2" />
                Customers
              </.sidebar_item>
              <.sidebar_item href="/analytics">
                <.icon name="bar-chart-2" size="sm" class="mr-2" />
                Analytics
              </.sidebar_item>
              <.sidebar_item href="/settings">
                <.icon name="settings" size="sm" class="mr-2" />
                Settings
              </.sidebar_item>
            </nav>
          </:nav>
          <:footer>
            <div class="px-3 py-4 flex items-center justify-between">
              <div class="flex items-center gap-2">
                <.avatar size="sm">
                  <.avatar_fallback name="Admin User" />
                </.avatar>
                <span class="text-sm font-medium">Admin</span>
              </div>
              <.dark_mode_toggle />
            </div>
          </:footer>
        </.sidebar>
      </:sidebar>
      <:topbar>
        <.topbar>
          <:left>
            <h1 class="text-lg font-semibold">Dashboard</h1>
          </:left>
          <:right>
            <.button variant="outline" size="sm" phx-click="open-command">
              <.icon name="search" size="sm" class="mr-2" />
              Search
              <kbd class="ml-2 text-xs bg-muted px-1.5 py-0.5 rounded">⌘K</kbd>
            </.button>
          </:right>
        </.topbar>
      </:topbar>
      <:content>
        <div class="p-6 space-y-6">
          <%!-- KPI Cards --%>
          <.metric_grid cols={4}>
            <.stat_card
              title="Monthly Revenue"
              value="$48,290"
              trend="up"
              trend_value="+12.5%"
              description="vs last month"
            />
            <.stat_card
              title="Active Users"
              value="2,840"
              trend="up"
              trend_value="+8.2%"
              description="vs last month"
            />
            <.stat_card
              title="Churn Rate"
              value="3.1%"
              trend="down"
              trend_value="-0.4%"
              description="improvement"
            />
            <.stat_card
              title="NPS Score"
              value="67"
              trend="neutral"
              trend_value="0"
              description="no change"
            />
          </.metric_grid>

          <%!-- Revenue Chart --%>
          <.phia_chart
            id="revenue-chart"
            type={:area}
            title="Monthly Revenue"
            series={[%{name: "MRR", data: @mrr_data}]}
            labels={@month_labels}
            height="300px"
          />

          <%!-- Orders Table --%>
          <.card>
            <.card_header>
              <div class="flex items-center justify-between">
                <.card_title>Recent Orders</.card_title>
                <.button variant="outline" size="sm">View All</.button>
              </div>
            </.card_header>
            <.card_content class="p-0">
              <.data_grid
                id="orders-grid"
                rows={@orders}
                sort_by={@sort_by}
                sort_dir={@sort_dir}
                on_sort="sort-orders"
              >
                <:col field="id" label="Order #" sortable={true} />
                <:col field="customer" label="Customer" sortable={true} />
                <:col field="amount" label="Amount" sortable={true} />
                <:col field="status" label="Status">
                  <:cell :let={row}>
                    <.badge variant={status_variant(row.status)}>{row.status}</.badge>
                  </:cell>
                </:col>
                <:col field="date" label="Date" sortable={true} />
              </.data_grid>
            </.card_content>
          </.card>
        </div>
      </:content>
    </.shell>
    """
  end

  @impl true
  def handle_event("open-command", _, socket) do
    {:noreply, assign(socket, :command_open, true)}
  end

  def handle_event("sort-orders", %{"field" => field, "dir" => dir}, socket) do
    sorted = sort_orders(socket.assigns.orders, field, dir)
    {:noreply, assign(socket, sort_by: field, sort_dir: dir, orders: sorted)}
  end

  def handle_event("notify", _, socket) do
    {:noreply, push_event(socket, "phia-toast", %{
      title: "Success",
      description: "Dashboard refreshed.",
      variant: "success"
    })}
  end

  # Helpers

  defp status_variant("paid"), do: "default"
  defp status_variant("pending"), do: "secondary"
  defp status_variant("failed"), do: "destructive"
  defp status_variant(_), do: "outline"

  defp sample_orders do
    [
      %{id: "#1042", customer: "Alice Martin",  amount: "$320.00", status: "paid",    date: "Mar 3"},
      %{id: "#1041", customer: "Bob Chen",      amount: "$89.50",  status: "pending", date: "Mar 2"},
      %{id: "#1040", customer: "Carol White",   amount: "$1,200",  status: "paid",    date: "Mar 1"},
      %{id: "#1039", customer: "David Kim",     amount: "$45.00",  status: "failed",  date: "Feb 28"},
      %{id: "#1038", customer: "Emma Davis",    amount: "$660.00", status: "paid",    date: "Feb 27"},
    ]
  end

  defp sort_orders(orders, field, "asc"),  do: Enum.sort_by(orders, &Map.get(&1, String.to_existing_atom(field)))
  defp sort_orders(orders, field, "desc"), do: Enum.sort_by(orders, &Map.get(&1, String.to_existing_atom(field)), :desc)
  defp sort_orders(orders, _field, _),     do: orders
end
```

---

## Step 7 — Add the route

In `lib/your_app_web/router.ex`:

```elixir
scope "/", YourAppWeb do
  pipe_through :browser

  live "/dashboard", DashboardLive
end
```

---

## Step 8 — Add dark mode support to root layout

In `lib/your_app_web/components/layouts/root.html.heex`, add the `PhiaDarkMode` hook to the `<html>` tag:

```heex
<html lang="en" phx-hook="PhiaDarkMode" id="html-root">
```

This hook reads `localStorage` on mount and applies/removes the `.dark` class automatically.

---

## Step 9 — Run the application

```bash
mix phx.server
```

Visit [http://localhost:4000/dashboard](http://localhost:4000/dashboard) — you should see:

- ✅ Sidebar with navigation links and dark mode toggle
- ✅ Top bar with Ctrl+K search trigger
- ✅ 4 KPI stat cards with trend indicators
- ✅ Area chart showing MRR over 6 months
- ✅ Sortable orders table with status badges

---

## Going further

### Real-time updates with push_event

Push live chart updates from your LiveView:

```elixir
def handle_info({:new_order, order}, socket) do
  new_data = socket.assigns.mrr_data ++ [order.amount]
  {:noreply, socket
    |> assign(:mrr_data, new_data)
    |> push_event("update-chart-revenue-chart", %{
        series: [%{name: "MRR", data: new_data}]
      })}
end
```

### Toast notifications

```elixir
def handle_event("save", params, socket) do
  case MyApp.save(params) do
    {:ok, _} ->
      {:noreply, push_event(socket, "phia-toast", %{
        title: "Saved",
        description: "Your changes have been saved.",
        variant: "success"
      })}
    {:error, changeset} ->
      {:noreply, push_event(socket, "phia-toast", %{
        title: "Error",
        description: "Please check the form for errors.",
        variant: "error"
      })}
  end
end
```

### Streams for large datasets

For tables with hundreds or thousands of rows, use LiveView streams:

```elixir
def mount(_, _, socket) do
  {:ok, stream(socket, :orders, MyApp.list_orders())}
end

# In template:
# <.table_body id="orders-body" phx-update="stream">
#   <.table_row :for={{id, order} <- @streams.orders} id={id}>
#     ...
#   </.table_row>
# </.table_body>
```

### Adding a confirmation dialog

```heex
<.alert_dialog id="delete-order" open={@confirm_delete}>
  <.alert_dialog_header>
    <.alert_dialog_title>Delete order?</.alert_dialog_title>
    <.alert_dialog_description>
      Order {@order_to_delete} will be permanently removed.
    </.alert_dialog_description>
  </.alert_dialog_header>
  <.alert_dialog_footer>
    <.alert_dialog_cancel phx-click="cancel-delete">Cancel</.alert_dialog_cancel>
    <.alert_dialog_action variant="destructive" phx-click="confirm-delete">
      Delete Order
    </.alert_dialog_action>
  </.alert_dialog_footer>
</.alert_dialog>
```

### Enterprise components — FilterBar + BulkActionBar

For a more powerful data management interface, add filtering and bulk operations:

```bash
mix phia.add filter_bar bulk_action_bar step_tracker activity_feed
```

```elixir
# In your LiveView mount/3:
|> assign(:selected_ids, [])
|> assign(:filters, %{search: "", status: "all"})
|> assign(:active_filters, [])

# Handle filter changes:
def handle_event("filter-search", %{"value" => q}, socket) do
  {:noreply, put_in(socket.assigns.filters.search, q) |> apply_filters()}
end

def handle_event("bulk-delete", _, socket) do
  ids = socket.assigns.selected_ids
  MyApp.delete_orders(ids)
  {:noreply, assign(socket, selected_ids: [])}
end
```

```heex
<%!-- Bulk action bar — hides when count = 0 --%>
<.bulk_action_bar count={length(@selected_ids)} label="orders selected">
  <.bulk_action icon="download" on_click="bulk-export">Export</.bulk_action>
  <.bulk_action icon="trash-2" variant="destructive" on_click="bulk-delete">Delete</.bulk_action>
</.bulk_action_bar>

<%!-- FilterBar above the data grid --%>
<.filter_bar>
  <.filter_search placeholder="Search orders…" on_search="filter-search" />
  <.filter_select label="Status" options={[{"All", "all"}, {"Paid", "paid"}, {"Pending", "pending"}]}
    value={@filters.status} on_change="filter-status" />
  <.filter_reset on_click="reset-filters" />
</.filter_bar>
```

### Activity Feed for audit logs

```heex
<.activity_feed>
  <%= for event <- @audit_log do %>
    <.activity_item
      actor={event.user}
      action={event.action}
      target={event.resource}
      timestamp={event.inserted_at}
      icon={activity_icon(event.type)}
    />
  <% end %>
</.activity_feed>
```

### StepTracker for onboarding flows

```heex
<.step_tracker>
  <.step status="complete" title="Account" />
  <.step status="active" title="Profile" description="Add your photo and bio" />
  <.step status="upcoming" title="Billing" />
  <.step status="upcoming" title="Done" />
</.step_tracker>
```

### Adding filters with a Drawer

```heex
<.drawer_content id="filters-drawer" open={@filters_open} direction="right">
  <.drawer_header>
    <h2 class="text-lg font-semibold">Filters</h2>
  </.drawer_header>
  <.drawer_close />
  <div class="px-6 space-y-4">
    <.field>
      <.field_label>Date Range</.field_label>
      <.date_range_picker id="dr" value={@date_range} />
    </.field>
    <.field>
      <.field_label>Status</.field_label>
      <.combobox
        id="status-filter"
        options={[
          %{value: "all", label: "All"},
          %{value: "paid", label: "Paid"},
          %{value: "pending", label: "Pending"},
          %{value: "failed", label: "Failed"}
        ]}
        value={@status_filter}
        open={@filter_combobox_open}
        search={@filter_search}
        on_toggle="toggle-filter-combo"
        on_change="set-status-filter"
        on_search="search-filter"
      />
    </.field>
  </div>
  <.drawer_footer>
    <.button phx-click="apply-filters">Apply</.button>
    <.button variant="outline" phx-click="reset-filters">Reset</.button>
  </.drawer_footer>
</.drawer_content>
```

---

## Complete component reference (75 components)

| Category | Components |
|----------|-----------|
| Layout | `shell/1`, `sidebar/1`, `sidebar_item/1`, `sidebar_section/1`, `topbar/1`, `mobile_sidebar_toggle/1` |
| KPI | `stat_card/1`, `metric_grid/1`, `chart_shell/1` |
| Charts | `phia_chart/1` |
| Data | `table/1`, `data_grid/1` |
| Feedback | `toast/1`, `alert/1`, `badge/1`, `skeleton/1`, `progress/1` |
| Inputs | `phia_input/1`, `phia_textarea/1`, `phia_select/1`, `checkbox/1`, `form_checkbox/1`, `switch/1`, `slider/1`, `form_slider/1`, `rating/1`, `form_rating/1`, `radio_group/1`, `tags_input/1`, `combobox/1`, `date_picker/1`, `date_range_picker/1`, `calendar/1`, `rich_text_editor/1`, `image_upload/1` |
| Navigation | `breadcrumb/1`, `pagination/1`, `command/1`, `navigation_menu/1`, `tabs_nav/1` |
| Overlay | `dialog/1`, `alert_dialog/1`, `drawer/1`, `popover/1`, `tooltip/1`, `hover_card/1`, `context_menu/1` |
| Display | `accordion/1`, `tabs/1`, `collapsible/1`, `carousel/1`, `toggle/1`, `toggle_group/1` |
| Utility | `aspect_ratio/1`, `direction/1`, `empty/1`, `field/1`, `button_group/1`, `avatar/1`, `avatar_group/1`, `scroll_area/1`, `separator/1`, `resizable/1`, `timeline/1`, `kbd/1`, `theme_provider/1`, `dark_mode_toggle/1` |
| Enterprise | `activity_feed/1`, `heatmap_calendar/1`, `kanban_board/1`, `chat_message/1`, `mention_input/1`, `filter_bar/1`, `filter_builder/1`, `bulk_action_bar/1`, `step_tracker/1`, `navigation_menu/1` |

← [Back to README](../../README.md)
