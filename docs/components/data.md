# Data

~80 data components — 16 SVG chart types, 9 table variants, data grid with 19 sub-components, tree views (standard + 10 enhanced variants), Kanban board, filters, and analytics widgets.

**Modules**:
- `PhiaUi.Components.Data` — charts, tables, data_grid, kanban, filters
- `PhiaUi.Components.TreeEnhanced` — icon_tree, checkbox_tree, searchable_tree, file_tree, lazy_tree, virtual_tree (v0.1.11)

```elixir
import PhiaUi.Components.Data
import PhiaUi.Components.TreeEnhanced
```

---

## Table of Contents

**Charts**
- [bar_chart](#bar_chart) / [line_chart](#line_chart) / [area_chart](#area_chart)
- [pie_chart](#pie_chart) / [donut_chart](#donut_chart)
- [radar_chart](#radar_chart) / [scatter_chart](#scatter_chart) / [bubble_chart](#bubble_chart)
- [radial_bar_chart](#radial_bar_chart) / [histogram_chart](#histogram_chart)
- [waterfall_chart](#waterfall_chart) / [heatmap_chart](#heatmap_chart)
- [bullet_chart](#bullet_chart) / [slope_chart](#slope_chart)
- [treemap_chart](#treemap_chart) / [timeline_chart](#timeline_chart)

**Analytics Widgets**
- [gauge_chart](#gauge_chart) / [sparkline_card](#sparkline_card)
- [uptime_bar](#uptime_bar) / [badge_delta](#badge_delta)
- [bar_list](#bar_list) / [category_bar](#category_bar)
- [meter_group](#meter_group) / [funnel_chart](#funnel_chart)
- [nps_widget](#nps_widget) / [comparison_table](#comparison_table) / [leaderboard](#leaderboard)

**Tables**
- [table](#table) — base table with sorting
- [data_table](#data_table) — column-definition driven
- [expandable_table](#expandable_table) — row expand/collapse
- [table_group](#table_group) — grouped rows
- [inline_edit_table](#inline_edit_table) — click-to-edit cells
- [timeline_table](#timeline_table) — date-keyed rows
- [responsive_table](#responsive_table) — stacks on mobile
- [pivot_table](#pivot_table) — cross-tabulation
- [table_state](#table_state) — loading/empty/error states

**Data Grid**
- [data_grid](#data_grid) — sortable, paginated, selectable
- [data_grid_head / data_grid_cell](#column-and-cell-components)
- [data_grid_column_group](#data_grid_column_group) (v0.1.11)
- [data_grid_pinned_row](#data_grid_pinned_row) (v0.1.11)
- [data_grid_detail_row](#data_grid_detail_row) (v0.1.11)
- [data_grid_group_row](#data_grid_group_row) (v0.1.11)
- [data_grid_aggregation_row](#data_grid_aggregation_row) (v0.1.11)
- [data_grid_export_button](#data_grid_export_button) (v0.1.11)
- [data_grid_density_toggle](#data_grid_density_toggle) (v0.1.11)
- [data_grid_filter_chip / data_grid_active_filters](#filter-chips) (v0.1.11)

**Kanban & Filters**
- [kanban_board](#kanban_board)
- [filter_bar](#filter_bar) / [filter_builder](#filter_builder)
- [bulk_action_bar](#bulk_action_bar)

**Tree Views**
- [tree / tree_item](#tree--tree_item) — zero-JS details/summary tree
- [icon_tree](#icon_tree) (v0.1.11)
- [checkbox_tree](#checkbox_tree) (v0.1.11)
- [searchable_tree](#searchable_tree) (v0.1.11)
- [file_tree](#file_tree) (v0.1.11)
- [lazy_tree](#lazy_tree) (v0.1.11)
- [virtual_tree](#virtual_tree) (v0.1.11)

---

## Charts

All charts are pure SVG — zero JavaScript, zero npm packages. They use `@keyframes` for animations and `prefers-reduced-motion` guards.

### bar_chart

```heex
<.bar_chart
  series={[
    %{name: "Revenue", data: [120, 145, 98, 167, 200, 189]},
    %{name: "Expenses", data: [80, 90, 70, 110, 130, 120]}
  ]}
  labels={["Jan", "Feb", "Mar", "Apr", "May", "Jun"]}
  height={280}
  animate={true}
/>
```

### line_chart

```heex
<.line_chart
  series={[%{name: "Users", data: [100, 120, 115, 140, 180, 165]}]}
  labels={["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]}
  height={240}
  show_dots={true}
  curve={:smooth}
/>
```

### area_chart

```heex
<.area_chart
  series={[%{name: "Signups", data: [12, 18, 15, 25, 30, 28]}]}
  labels={["Jan", "Feb", "Mar", "Apr", "May", "Jun"]}
  height={200}
  fill_opacity={0.2}
/>
```

### pie_chart / donut_chart

```heex
<.pie_chart
  series={[%{name: "Direct", value: 45}, %{name: "Referral", value: 30}, %{name: "Social", value: 25}]}
  height={240}
/>

<.donut_chart
  series={[%{name: "Chrome", value: 65}, %{name: "Safari", value: 18}, %{name: "Firefox", value: 10}]}
  height={240}
  center_label="Browsers"
/>
```

### Other chart types

```heex
<%!-- Radar — compare multiple metrics across categories --%>
<.radar_chart series={@radar_series} labels={@radar_labels} height={300} />

<%!-- Scatter — correlation plots --%>
<.scatter_chart series={@scatter_series} height={280} />

<%!-- Bubble — scatter with size dimension --%>
<.bubble_chart series={@bubble_series} height={280} />

<%!-- Histogram — frequency distribution --%>
<.histogram_chart data={@values} bins={20} height={200} />

<%!-- Waterfall — running total / bridge chart --%>
<.waterfall_chart series={@waterfall_series} labels={@labels} height={240} />

<%!-- Heatmap — intensity grid (GitHub contribution style) --%>
<.heatmap_chart data={@daily_counts} height={120} />

<%!-- Treemap — hierarchical area chart --%>
<.treemap_chart data={@tree_data} height={300} />

<%!-- Timeline chart — Gantt-style event bars --%>
<.timeline_chart series={@events} height={200} />
```

---

## Analytics Widgets

### gauge_chart

Semicircular gauge with zones and threshold marker.

```heex
<.gauge_chart
  value={72}
  min={0}
  max={100}
  zones={[{0, 30, "red"}, {30, 70, "orange"}, {70, 100, "green"}]}
  threshold={60}
  animate={true}
/>
```

### sparkline_card

Mini line/area sparkline inside a stat card.

```heex
<.sparkline_card
  title="Weekly Revenue"
  value="$24,500"
  delta={"+12%"}
  delta_type={:increase}
  data={[45, 52, 48, 61, 58, 67, 72]}
  trend={:up}
/>
```

### uptime_bar

Segment bar showing historical uptime (GitHub-style).

```heex
<.uptime_bar
  segments={@uptime_segments}
  label="API"
  current_status={:up}
/>
```

### badge_delta

Delta value with directional colour.

```heex
<.badge_delta value="+12.5%" delta_type={:increase} />
<.badge_delta value="-3.2%" delta_type={:decrease} />
<.badge_delta value="0%" delta_type={:neutral} />
```

### bar_list

Horizontal bar list — great for top-10 breakdowns.

```heex
<.bar_list
  items={[
    %{name: "Homepage", value: 4523, href: "/"},
    %{name: "Pricing", value: 3201, href: "/pricing"},
    %{name: "Docs", value: 1987, href: "/docs"}
  ]}
  value_label="Page views"
/>
```

### category_bar

Single horizontal bar split into coloured segments.

```heex
<.category_bar
  categories={[
    %{name: "Direct", value: 45, color: "blue"},
    %{name: "Referral", value: 30, color: "violet"},
    %{name: "Social", value: 25, color: "pink"}
  ]}
/>
```

### meter_group

Multiple labeled meter bars stacked vertically.

```heex
<.meter_group
  items={[
    %{label: "Storage", value: 68, max: 100, unit: "GB"},
    %{label: "Bandwidth", value: 12, max: 50, unit: "GB"},
    %{label: "API calls", value: 1200, max: 10000, unit: "reqs"}
  ]}
/>
```

---

## Tables

### table

Base sortable table. Used by most table variants.

```heex
<.table id="orders" rows={@orders} sort_key={@sort_key} sort_dir={@sort_dir} on_sort="sort">
  <:col :let={order} key="id" label="Order">#<%= order.id %></:col>
  <:col :let={order} key="customer" label="Customer"><%= order.customer %></:col>
  <:col :let={order} key="total" label="Total" align={:right}>
    $<%= order.total %>
  </:col>
  <:col :let={order} key="status" label="Status">
    <.badge variant={status_variant(order.status)}><%= order.status %></.badge>
  </:col>
</.table>
```

### data_table

Column-definition driven table — define columns as data structures.

```heex
<.data_table
  id="users-dt"
  rows={@users}
  columns={[
    %{key: "name", label: "Name", sortable: true},
    %{key: "email", label: "Email"},
    %{key: "role", label: "Role"},
    %{key: "created_at", label: "Joined", type: :date}
  ]}
  on_sort="sort_users"
/>
```

### expandable_table

Rows that expand to reveal a detail panel.

```heex
<.expandable_table id="orders-exp" rows={@orders}>
  <:col :let={order} label="Order">#<%= order.id %></:col>
  <:col :let={order} label="Total">$<%= order.total %></:col>
  <:row_detail :let={order}>
    <div class="p-4 grid grid-cols-3 gap-4">
      <%= for item <- order.items do %>
        <div><%= item.name %> × <%= item.qty %></div>
      <% end %>
    </div>
  </:row_detail>
</.expandable_table>
```

### responsive_table

Stacks as labeled key-value pairs on mobile.

```heex
<.responsive_table id="contacts" rows={@contacts}>
  <:col :let={c} key="name" label="Name"><%= c.name %></:col>
  <:col :let={c} key="email" label="Email"><%= c.email %></:col>
  <:col :let={c} key="phone" label="Phone"><%= c.phone %></:col>
</.responsive_table>
```

---

## Data Grid

Full-featured data grid: sorting, density, pinning, grouping, aggregation, CSV export, filter chips.

```heex
<.data_grid id="products-grid" rows={@products} sort_key={@sort} sort_dir={@dir}
  loading={@loading} sticky_header={true}>
  <:toolbar>
    <.data_grid_density_toggle density={@density} on_change="set_density" />
    <.data_grid_active_filters filters={@active_filters} on_remove="remove_filter" />
    <.data_grid_export_button id="export" target_id="products-grid" filename="products.csv" label="Export CSV" />
  </:toolbar>

  <.data_grid_head sort_key="name" on_sort="sort">Name</.data_grid_head>
  <.data_grid_head sort_key="price" on_sort="sort">Price</.data_grid_head>
  <.data_grid_head sort_key="stock" on_sort="sort">Stock</.data_grid_head>
  <.data_grid_head>Actions</.data_grid_head>

  <:row :let={product}>
    <.data_grid_cell><%= product.name %></.data_grid_cell>
    <.data_grid_cell align={:right}>$<%= product.price %></.data_grid_cell>
    <.data_grid_cell align={:right}><%= product.stock %></.data_grid_cell>
    <.data_grid_cell>
      <.icon_button icon="pencil" label="Edit" phx-click="edit" phx-value-id={product.id} variant="ghost" size="sm" />
    </.data_grid_cell>
  </:row>

  <%!-- Aggregation footer row --%>
  <.data_grid_aggregation_row>
    <.data_grid_cell>Totals</.data_grid_cell>
    <.data_grid_cell align={:right}>$<%= @total_value %></.data_grid_cell>
    <.data_grid_cell align={:right}><%= @total_stock %></.data_grid_cell>
    <.data_grid_cell />
  </.data_grid_aggregation_row>
</.data_grid>
```

### data_grid_column_group

Multi-level column headers spanning multiple columns.

```heex
<thead>
  <tr>
    <.data_grid_column_group colspan={2} label="Identity" />
    <.data_grid_column_group colspan={3} label="Work Details" />
  </tr>
  <tr>
    <.data_grid_head>Name</.data_grid_head>
    <.data_grid_head>Email</.data_grid_head>
    <.data_grid_head>Department</.data_grid_head>
    <.data_grid_head>Title</.data_grid_head>
    <.data_grid_head>Salary</.data_grid_head>
  </tr>
</thead>
```

### data_grid_pinned_row

Sticky summary row at the top or bottom of the grid.

```heex
<.data_grid_pinned_row position={:bottom}>
  <.data_grid_cell><strong>Total</strong></.data_grid_cell>
  <.data_grid_cell align={:right}><strong>$<%= @grand_total %></strong></.data_grid_cell>
</.data_grid_pinned_row>
```

### data_grid_detail_row

Full-width expandable detail panel inside a row group.

```heex
<.data_grid_detail_row colspan={5}>
  <div class="p-4 bg-muted/30 rounded-lg">
    <h4 class="font-medium">Order details</h4>
    <%= for item <- @expanded_order.items do %>
      <div class="flex justify-between py-1"><%= item.name %> <span>$<%= item.price %></span></div>
    <% end %>
  </div>
</.data_grid_detail_row>
```

### data_grid_group_row

Collapsible group header inside the grid body.

```heex
<.data_grid_group_row
  label="Electronics"
  count={42}
  expanded={@expanded_groups["electronics"]}
  value="electronics"
  colspan={5}
  on_toggle="toggle_group"
/>
```

### Filter Chips

```heex
<%!-- Active filter chip --%>
<.data_grid_filter_chip label="Category: Electronics" value="category" on_remove="remove_filter" />

<%!-- Full active filters bar --%>
<.data_grid_active_filters
  filters={[
    %{label: "Category: Electronics", value: "category"},
    %{label: "Price: > $100", value: "price"}
  ]}
  on_remove="remove_filter"
/>
```

---

## Kanban Board

```heex
<.kanban_board id="tasks-board" on_move="move_card">
  <%= for column <- @columns do %>
    <.kanban_column id={"col-#{column.id}"} title={column.title} count={length(column.cards)}>
      <%= for card <- column.cards do %>
        <.kanban_card
          id={"card-#{card.id}"}
          title={card.title}
          description={card.description}
          assignee={card.assignee}
          due_date={card.due_date}
          priority={card.priority}
          phx-click="open_card"
          phx-value-id={card.id}
        />
      <% end %>
    </.kanban_column>
  <% end %>
</.kanban_board>
```

Hook: `PhiaKanban`

---

## Tree Views

### tree / tree_item

Zero-JS expand/collapse via native `<details>/<summary>`. WAI-ARIA roles.

```heex
<.tree id="file-browser">
  <.tree_item label="src" expandable={true}>
    <.tree_item label="app.ex" />
    <.tree_item label="router.ex" />
    <.tree_item label="components" expandable={true}>
      <.tree_item label="ui" expandable={true}>
        <.tree_item label="button.ex" />
      </.tree_item>
    </.tree_item>
  </.tree_item>
  <.tree_item label="mix.exs" />
</.tree>
```

### icon_tree (v0.1.11)

Tree with Lucide icons per node, badges, and href links.

```heex
<.icon_tree id="nav-tree">
  <.icon_tree_item label="Settings" icon="settings" href="/settings" />
  <.icon_tree_item label="Users" icon="users" expandable={true}>
    <.icon_tree_item label="Admins" icon="shield" badge={@admin_count} href="/users/admins" />
    <.icon_tree_item label="Members" icon="user" badge={@member_count} href="/users/members" />
  </.icon_tree_item>
</.icon_tree>
```

### checkbox_tree (v0.1.11)

Tree with tri-state checkboxes for permission or category selection.

```heex
<.checkbox_tree id="permissions-tree">
  <.checkbox_tree_item id="perm-read" label="Read" value="read" checked={true} />
  <.checkbox_tree_item id="perm-write" label="Write" value="write" checked={false} indeterminate={true}>
    <.checkbox_tree_item id="perm-create" label="Create" value="create" checked={false} />
    <.checkbox_tree_item id="perm-update" label="Update" value="update" checked={true} />
  </.checkbox_tree_item>
</.checkbox_tree>
```

### searchable_tree (v0.1.11)

Tree with a debounced search input — filtering logic is in LiveView.

```heex
<.searchable_tree id="cat-tree" search_value={@query} on_search="search_categories">
  <%= for cat <- @filtered_categories do %>
    <.icon_tree_item label={cat.name} icon="folder" />
  <% end %>
</.searchable_tree>
```

### file_tree (v0.1.11)

File system browser with extension-based icons.

```heex
<.file_tree id="project-files">
  <.file_tree_item label="lib" type={:folder} expanded={true}>
    <.file_tree_item label="app.ex" type={:file} />
    <.file_tree_item label="logo.png" type={:file} />
    <.file_tree_item label="config.json" type={:file} />
  </.file_tree_item>
  <.file_tree_item label="mix.exs" type={:file} />
  <.file_tree_item label="README.md" type={:file} />
</.file_tree>
```

### lazy_tree (v0.1.11)

Tree with deferred children loading — fires a LiveView event on first expand.

```heex
<.lazy_tree id="org-tree" on_expand="load_children">
  <.lazy_tree_item id="node-root" label="Engineering" expandable={true} loaded={false} loading={false} />
</.lazy_tree>
```

```elixir
# In your LiveView
def handle_event("load_children", %{"id" => id}, socket) do
  children = fetch_children(id)
  {:noreply, assign(socket, tree_nodes: insert_children(socket.assigns.tree_nodes, id, children))}
end
```

### virtual_tree (v0.1.11)

Virtualised tree for very large datasets. Hook: `PhiaVirtualTree`.

```heex
<.virtual_tree
  id="big-tree"
  nodes={@flat_nodes}
  row_height={32}
  height={400}
/>
```

`nodes` is a flat list of `%{id, label, depth, expandable, expanded}` maps. Hook manages DOM virtualization and fires `"virtual_tree_select"` on click.

---

## filter_bar / filter_builder

```heex
<%!-- Simple filter bar with preset filter chips --%>
<.filter_bar filters={@filters} on_change="set_filters" on_clear="clear_filters" />

<%!-- Advanced dynamic filter builder --%>
<.filter_builder
  id="adv-filters"
  fields={[
    %{key: "name", label: "Name", type: :text},
    %{key: "status", label: "Status", type: :select, options: ["active", "inactive"]},
    %{key: "created_at", label: "Created", type: :date}
  ]}
  on_apply="apply_filters"
/>
```
