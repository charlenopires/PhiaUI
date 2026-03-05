# Data

Enterprise data management: tables, sortable grids, charts, Gantt timelines, Kanban boards, advanced filters, and visualizations.

## Table of Contents

- [table](#table)
- [data_grid](#data_grid)
- [chart / phia_chart](#chart--phia_chart)
- [chart_shell](#chart_shell)
- [filter_bar](#filter_bar)
- [filter_builder](#filter_builder)
- [bulk_action_bar](#bulk_action_bar)
- [kanban_board](#kanban_board)
- [tree](#tree)
- [gantt_chart](#gantt_chart)
- [gauge_chart](#gauge_chart)
- [sparkline_card](#sparkline_card)
- [uptime_bar](#uptime_bar)

---

## table

8 sub-components for composable tables. Fully compatible with `phx-update="stream"` for server-side streaming.

**Sub-components**: `table_header/1`, `table_body/1`, `table_row/1`, `table_head/1`, `table_cell/1`, `table_caption/1`, `table_footer/1`

```heex
<%!-- Basic table --%>
<.table>
  <.table_header>
    <.table_row>
      <.table_head>Name</.table_head>
      <.table_head>Email</.table_head>
      <.table_head>Status</.table_head>
      <.table_head>Joined</.table_head>
      <.table_head class="w-[50px]"></.table_head>
    </.table_row>
  </.table_header>
  <.table_body>
    <.table_row :for={user <- @users} id={"user-#{user.id}"}>
      <.table_cell class="font-medium"><%= user.name %></.table_cell>
      <.table_cell><%= user.email %></.table_cell>
      <.table_cell>
        <.badge variant={status_variant(user.status)}><%= user.status %></.badge>
      </.table_cell>
      <.table_cell class="text-muted-foreground">
        <%= Calendar.strftime(user.inserted_at, "%b %d, %Y") %>
      </.table_cell>
      <.table_cell>
        <.dropdown_menu id={"user-menu-#{user.id}"}>
          <:trigger><.button variant="ghost" size="icon"><.icon name="more-horizontal" /></.button></:trigger>
          <:content>
            <.dropdown_menu_item phx-click="edit-user" phx-value-id={user.id}>Edit</.dropdown_menu_item>
            <.dropdown_menu_item phx-click="delete-user" phx-value-id={user.id}>Delete</.dropdown_menu_item>
          </:content>
        </.dropdown_menu>
      </.table_cell>
    </.table_row>
  </.table_body>
</.table>

<%!-- With streaming and LiveView streams --%>
<.table>
  <.table_body id="users-stream" phx-update="stream">
    <.table_row :for={{dom_id, user} <- @streams.users} id={dom_id}>
      <.table_cell><%= user.name %></.table_cell>
      <.table_cell><%= user.email %></.table_cell>
    </.table_row>
  </.table_body>
</.table>
```

```elixir
def mount(_params, _session, socket) do
  {:ok, stream(socket, :users, Accounts.list_users())}
end

def handle_info({:user_created, user}, socket) do
  {:noreply, stream_insert(socket, :users, user, at: 0)}
end
```

---

## data_grid

Sortable data table with `phx-click` sort events and direction cycling.

**Attrs**: `columns` (list of maps), `rows`, `sort_by`, `sort_dir`, `on_sort` (event name), `id`

```heex
<.data_grid
  id="orders-grid"
  rows={@orders}
  columns={[
    %{key: "order_id",    label: "Order #",  sortable: true},
    %{key: "customer",    label: "Customer", sortable: true},
    %{key: "total",       label: "Total",    sortable: true},
    %{key: "status",      label: "Status",   sortable: false},
    %{key: "created_at",  label: "Date",     sortable: true}
  ]}
  sort_by={@sort_by}
  sort_dir={@sort_dir}
  on_sort="sort_orders"
/>
```

```elixir
def mount(_params, _session, socket) do
  {:ok, assign(socket,
    sort_by: "created_at",
    sort_dir: "desc",
    orders: Orders.list(sort_by: "created_at", sort_dir: :desc)
  )}
end

def handle_event("sort_orders", %{"key" => key, "dir" => dir}, socket) do
  sort_dir = String.to_existing_atom(dir)
  {:noreply, assign(socket,
    sort_by: key,
    sort_dir: dir,
    orders: Orders.list(sort_by: key, sort_dir: sort_dir)
  )}
end
```

---

## chart / phia_chart

ECharts integration. Supports area, bar, line, pie, scatter, and radar chart types.

**Hook**: `PhiaChart`
**Attrs**: `id`, `type` (atom), `title`, `description`, `series`, `labels`, `height`, `options` (raw ECharts map)

```heex
<%!-- Area chart --%>
<.phia_chart
  id="revenue-chart"
  type={:area}
  title="Monthly Revenue"
  description="Last 12 months"
  series={[%{name: "MRR", data: @mrr_data}]}
  labels={@month_labels}
  height="320px"
/>

<%!-- Grouped bar chart --%>
<.phia_chart
  id="comparison-chart"
  type={:bar}
  title="Q1 vs Q2"
  series={[
    %{name: "Q1 2025", data: [42, 58, 63, 71, 68, 75]},
    %{name: "Q2 2025", data: [55, 62, 78, 85, 92, 88]}
  ]}
  labels={["Jan", "Feb", "Mar", "Apr", "May", "Jun"]}
  height="300px"
/>

<%!-- Pie chart --%>
<.phia_chart
  id="status-pie"
  type={:pie}
  title="Ticket Status"
  series={[%{
    name: "Status",
    data: [
      %{name: "Open",    value: 42},
      %{name: "Pending", value: 23},
      %{name: "Closed",  value: 135}
    ]
  }]}
  height="280px"
/>

<%!-- Live-updating chart via push_event --%>
<.phia_chart id="live-chart" type={:line} series={@series} labels={@labels} height="260px" />
```

```elixir
# Update chart data from LiveView
def handle_info(:update_chart, socket) do
  series = [%{name: "Active Users", data: Metrics.last_24h()}]
  {:noreply,
    socket
    |> assign(series: series)
    |> push_event("phia-chart-update:live-chart", %{series: series})}
end
```

---

## chart_shell

Consistent card wrapper for any chart. Use to standardize chart cards in a dashboard.

**Sub-components**: `chart_shell_header/1`, `chart_shell_title/1`, `chart_shell_description/1`

```heex
<.chart_shell>
  <.chart_shell_header>
    <.chart_shell_title>Revenue Overview</.chart_shell_title>
    <.chart_shell_description>Monthly recurring revenue, last 12 months</.chart_shell_description>
    <:actions>
      <.select options={[{"Last 12 months", "12m"}, {"Last 6 months", "6m"}]}
        value={@period} on_change="set-period" />
    </:actions>
  </.chart_shell_header>
  <.phia_chart id="revenue" type={:area} series={@series} labels={@labels} height="280px" />
</.chart_shell>
```

---

## filter_bar

Horizontal filter toolbar for quick table filtering.

**Sub-components**: `filter_search/1`, `filter_select/1`, `filter_toggle/1`, `filter_reset/1`

```heex
<.filter_bar>
  <.filter_search
    value={@search}
    placeholder="Search users…"
    on_search="search_users"
    phx-debounce="300"
  />
  <.filter_select
    label="Status"
    name="status"
    options={[{"All", ""}, {"Active", "active"}, {"Inactive", "inactive"}, {"Banned", "banned"}]}
    value={@status_filter}
    on_change="filter_status"
  />
  <.filter_select
    label="Role"
    name="role"
    options={[{"All roles", ""}, {"Admin", "admin"}, {"Member", "member"}]}
    value={@role_filter}
    on_change="filter_role"
  />
  <.filter_toggle
    label="Verified"
    name="verified"
    checked={@verified_only}
    on_change="toggle_verified"
  />
  <.filter_reset on_click="reset_filters" />
</.filter_bar>
```

```elixir
def handle_event("search_users", %{"query" => q}, socket) do
  {:noreply, assign(socket, search: q, users: Users.search(q, socket.assigns.filters))}
end

def handle_event("reset_filters", _params, socket) do
  {:noreply, assign(socket, search: "", status_filter: "", role_filter: "", verified_only: false,
    users: Users.list_all())}
end
```

---

## filter_builder

Dynamic query builder with field/operator/value rule rows.

**Attrs**: `fields` (list of %{name, label, type, options}), `rules`, `on_add`, `on_remove`, `on_change`

```heex
<.filter_builder
  fields={[
    %{name: "name",       label: "Name",       type: "text"},
    %{name: "status",     label: "Status",     type: "select",
      options: [{"Active", "active"}, {"Inactive", "inactive"}]},
    %{name: "role",       label: "Role",       type: "select",
      options: [{"Admin", "admin"}, {"Member", "member"}]},
    %{name: "created_at", label: "Created At", type: "date"},
    %{name: "age",        label: "Age",        type: "number"}
  ]}
  rules={@filter_rules}
  on_add="add_filter_rule"
  on_remove="remove_filter_rule"
  on_change="update_filter_rule"
/>
```

```elixir
def handle_event("add_filter_rule", _params, socket) do
  new_rule = %{id: Ecto.UUID.generate(), field: "name", op: "contains", value: ""}
  {:noreply, update(socket, :filter_rules, &[&1 | [new_rule]])}
end

def handle_event("remove_filter_rule", %{"id" => id}, socket) do
  {:noreply, update(socket, :filter_rules, &Enum.reject(&1, fn r -> r.id == id end))}
end
```

---

## bulk_action_bar

Contextual toolbar that appears when rows are selected.

**Attrs**: `count`, `label`, `on_clear`
**Sub-components**: `bulk_action/1` (label, on_click, variant, icon)

```heex
<.bulk_action_bar count={@selected_count} label="posts selected" on_clear="clear_selection">
  <.bulk_action label="Publish"  on_click="bulk_publish"  icon="send" />
  <.bulk_action label="Archive"  on_click="bulk_archive"  icon="archive" />
  <.bulk_action label="Delete"   on_click="bulk_delete"   icon="trash" variant="destructive" />
</.bulk_action_bar>
```

```elixir
def handle_event("bulk_publish", _params, socket) do
  Posts.publish_many(socket.assigns.selected_ids)
  {:noreply, assign(socket, selected_ids: [], selected_count: 0)}
end
```

---

## kanban_board

Drag-ready column and card layout for project management, editorial workflows, and pipeline views.

**Sub-components**: `kanban_column/1`, `kanban_card/1`

```heex
<.kanban_board>
  <.kanban_column label="Backlog" count={length(@backlog)}>
    <.kanban_card
      :for={item <- @backlog}
      id={"card-#{item.id}"}
      title={item.title}
      priority={item.priority}
    >
      <:tags>
        <.badge :for={tag <- item.tags} variant="secondary" class="text-xs"><%= tag %></.badge>
      </:tags>
      <:footer>
        <.avatar size="xs"><.avatar_fallback name={item.assignee} /></.avatar>
        <span class="text-xs text-muted-foreground">Due <%= item.due_date %></span>
      </:footer>
    </.kanban_card>
  </.kanban_column>

  <.kanban_column label="In Progress" count={length(@in_progress)}>
    <.kanban_card
      :for={item <- @in_progress}
      id={"card-#{item.id}"}
      title={item.title}
      priority={item.priority}
    />
  </.kanban_column>

  <.kanban_column label="Review" count={length(@review)}>
    <.kanban_card :for={item <- @review} id={"card-#{item.id}"} title={item.title} />
  </.kanban_column>

  <.kanban_column label="Done" count={length(@done)}>
    <.kanban_card :for={item <- @done} id={"card-#{item.id}"} title={item.title} />
  </.kanban_column>
</.kanban_board>
```

---

## tree

Hierarchical tree view using native `<details>/<summary>` — zero JavaScript.

**Sub-components**: `tree_item/1`
**Attrs on tree_item**: `label`, `icon`, `open` (bool), `phx-click`

```heex
<.tree>
  <.tree_item label="src" icon="folder" open={true}>
    <.tree_item label="components" icon="folder">
      <.tree_item label="button.ex" icon="file-text" phx-click="open-file" phx-value-path="components/button.ex" />
      <.tree_item label="card.ex"   icon="file-text" phx-click="open-file" phx-value-path="components/card.ex" />
    </.tree_item>
    <.tree_item label="live" icon="folder">
      <.tree_item label="dashboard_live.ex" icon="file-text" phx-click="open-file" phx-value-path="live/dashboard_live.ex" />
    </.tree_item>
  </.tree_item>
  <.tree_item label="test" icon="folder" />
  <.tree_item label="mix.exs" icon="file-code" phx-click="open-file" phx-value-path="mix.exs" />
</.tree>
```

---

## gantt_chart

Horizontal SVG project timeline with task bars, progress indicators, and today marker.

**Attrs**: `tasks` (list of maps), `start_date`, `end_date`

```heex
<.gantt_chart
  start_date={~D[2026-03-01]}
  end_date={~D[2026-06-30]}
  tasks={[
    %{id: "1", label: "Discovery",      start: ~D[2026-03-01], end: ~D[2026-03-15], progress: 100, color: "blue"},
    %{id: "2", label: "Design",         start: ~D[2026-03-10], end: ~D[2026-04-05], progress: 80,  color: "purple"},
    %{id: "3", label: "Development",    start: ~D[2026-04-01], end: ~D[2026-05-30], progress: 45,  color: "green"},
    %{id: "4", label: "QA & Testing",   start: ~D[2026-05-15], end: ~D[2026-06-10], progress: 0,   color: "orange"},
    %{id: "5", label: "Launch",         start: ~D[2026-06-15], end: ~D[2026-06-30], progress: 0,   color: "red"}
  ]}
/>
```

---

## gauge_chart

SVG semi-circular gauge with configurable zones.

**Attrs**: `value` (0–100 or custom max), `label`, `max`, `color`, `segments`

```heex
<.gauge_chart value={72} label="Performance Score" />
<.gauge_chart value={@cpu_usage} label="CPU Usage" max={100} />
<.gauge_chart value={@nps} label="NPS" max={100}
  segments={[
    %{from: 0,  to: 50,  color: "red"},
    %{from: 50, to: 75,  color: "yellow"},
    %{from: 75, to: 100, color: "green"}
  ]}
/>
```

---

## sparkline_card

Inline SVG sparkline polyline with metric value and trend badge. Use inside `metric_grid/1`.

**Attrs**: `title`, `value`, `trend` (up/down/neutral), `trend_value`, `data` (list of numbers), `color`

```heex
<.metric_grid cols={3}>
  <.sparkline_card
    title="Revenue"
    value="$48,290"
    trend="up"
    trend_value="+12.5%"
    data={@mrr_sparkline}
    color="green"
  />
  <.sparkline_card
    title="Active Users"
    value="2,840"
    trend="up"
    trend_value="+8.2%"
    data={@users_sparkline}
  />
  <.sparkline_card
    title="Error Rate"
    value="0.12%"
    trend="down"
    trend_value="+0.02%"
    data={@error_sparkline}
    color="red"
  />
</.metric_grid>
```

---

## uptime_bar

Segmented uptime visualization. Each segment is a day/interval with status.

**Attrs**: `segments` (list of %{status: :up/:down/:degraded, date, tooltip}), `show_legend`

```heex
<.card>
  <.card_header>
    <.card_title>API Uptime — Last 90 days</.card_title>
    <.card_description>
      <.badge variant="default">99.98% uptime</.badge>
    </.card_description>
  </.card_header>
  <.card_content>
    <.uptime_bar segments={@uptime_segments} show_legend={true} />
  </.card_content>
</.card>
```

```elixir
# Build segments from incident history
def uptime_segments(incidents, days \\ 90) do
  today = Date.utc_today()
  Enum.map(0..days-1, fn offset ->
    date = Date.add(today, -offset)
    status = if incident = Enum.find(incidents, &(&1.date == date)) do
      if incident.degraded, do: :degraded, else: :down
    else
      :up
    end
    %{date: date, status: status, tooltip: Date.to_string(date)}
  end)
  |> Enum.reverse()
end
```

← [Back to README](../../README.md)
