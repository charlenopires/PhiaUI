# Interaction

Drag-and-drop primitives for sortable lists, grids, Kanban workflows, transfer lists, and hierarchical tree reordering. All 14 components use vanilla JS hooks with no npm dependencies. Components live in `PhiaUi.Components.Interaction` and related modules.

```elixir
import PhiaUi.Components.Interaction.Sortable
import PhiaUi.Components.Interaction.SortableGrid
import PhiaUi.Components.Interaction.DropZone
import PhiaUi.Components.Interaction.MultiDrag
import PhiaUi.Components.Interaction.DraggableTree
import PhiaUi.Components.Data.KanbanBoard   # for DnD kanban
```

---

## drag_handle/1

**Module**: `PhiaUi.Components.Interaction.Sortable`
**Tier**: primitive

Grip icon handle for initiating drag operations. Used inside `sortable_item/1` or `kanban_card/1` to restrict drag initiation to this handle zone.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.sortable_item id="item-1" value="item-1">
  <.drag_handle />
  <span>Item content</span>
</.sortable_item>
```

---

## drop_indicator/1

**Module**: `PhiaUi.Components.Interaction.Sortable`
**Tier**: primitive

Visual line or zone indicator for valid drop targets. Appears between items during drag operations.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `variant` | `:string` | `"line"` | Visual style: `"line"` or `"zone"` |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.drop_indicator variant="line" />
```

---

## sortable_list/1 and sortable_item/1

**Module**: `PhiaUi.Components.Interaction.Sortable`
**Tier**: interactive
**Hook**: `PhiaSortable`

Vertical drag-to-reorder list. Items emit `phx-click` events with the reordered list on drop.

### Attributes — `sortable_list/1`

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Required for hook |
| `on_reorder` | `:string` | required | Event fired with `%{"order" => ["id1","id2",...]}` |
| `class` | `:string` | `nil` | Additional CSS classes |

### Attributes — `sortable_item/1`

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Unique item ID (used as drag key) |
| `value` | `:string` | required | Value emitted in reorder event |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.sortable_list id="task-list" on_reorder="reorder_tasks">
  <%= for task <- @tasks do %>
    <.sortable_item id={"task-#{task.id}"} value={to_string(task.id)}>
      <.drag_handle />
      <span>{task.title}</span>
    </.sortable_item>
  <% end %>
</.sortable_list>
```

### LiveView Example

```elixir
def handle_event("reorder_tasks", %{"order" => ids}, socket) do
  tasks = Enum.map(ids, fn id ->
    Enum.find(socket.assigns.tasks, &(to_string(&1.id) == id))
  end)
  {:noreply, assign(socket, tasks: tasks)}
end
```

---

## sortable_grid/1 and sortable_grid_item/1

**Module**: `PhiaUi.Components.Interaction.SortableGrid`
**Tier**: interactive
**Hook**: `PhiaSortableGrid`

Grid drag-to-reorder layout. Items can be dragged to any grid position.

### Attributes — `sortable_grid/1`

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Required for hook |
| `cols` | `:integer` | `3` | Number of grid columns |
| `on_reorder` | `:string` | required | Event fired on drop |
| `class` | `:string` | `nil` | Additional CSS classes |

### Attributes — `sortable_grid_item/1`

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Unique item ID |
| `value` | `:string` | required | Value emitted in reorder event |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.sortable_grid id="widget-grid" cols={4} on_reorder="reorder_widgets">
  <%= for widget <- @widgets do %>
    <.sortable_grid_item id={"widget-#{widget.id}"} value={to_string(widget.id)}>
      <.card class="p-4">{widget.title}</.card>
    </.sortable_grid_item>
  <% end %>
</.sortable_grid>
```

---

## kanban_board/1, kanban_column/1, kanban_card/1 (DnD)

**Module**: `PhiaUi.Components.Data.KanbanBoard`
**Tier**: widget
**Hook**: `PhiaKanban`

Full drag-and-drop Kanban board with cross-column card dragging. Cards emit server events on drop with the new column and position.

### Attributes — `kanban_board/1`

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Required for hook |
| `on_move` | `:string` | required | Event fired: `%{"card_id" => id, "column_id" => col, "index" => idx}` |
| `class` | `:string` | `nil` | Additional CSS classes |

### Attributes — `kanban_column/1`

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Column identifier |
| `label` | `:string` | required | Column header label |
| `count` | `:integer` | `nil` | Optional item count badge |
| `class` | `:string` | `nil` | Additional CSS classes |

### Attributes — `kanban_card/1`

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Card identifier |
| `column_id` | `:string` | required | Parent column identifier |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.kanban_board id="project-board" on_move="move_card">
  <%= for column <- @columns do %>
    <.kanban_column id={column.id} label={column.name} count={length(column.cards)}>
      <%= for card <- column.cards do %>
        <.kanban_card id={card.id} column_id={column.id}>
          <.drag_handle />
          <p class="font-medium">{card.title}</p>
          <.badge variant="secondary">{card.priority}</.badge>
        </.kanban_card>
      <% end %>
    </.kanban_column>
  <% end %>
</.kanban_board>
```

---

## drop_zone/1

**Module**: `PhiaUi.Components.Interaction.DropZone`
**Tier**: interactive
**Hook**: `PhiaDropZone`

Generic file or item drop target with visual hover feedback.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Required for hook |
| `on_drop` | `:string` | required | Event fired on drop |
| `label` | `:string` | `"Drop here"` | Label text shown in zone |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.drop_zone id="file-drop" on_drop="files_dropped" label="Drop files to upload" />
```

---

## drag_transfer_list/1

**Module**: `PhiaUi.Components.Interaction.DropZone`
**Tier**: interactive
**Hook**: `PhiaDragTransferList`

Two-column drag-between-lists transfer. Items can be dragged from "available" to "selected" and back.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Required for hook |
| `available` | `:list` | required | List of available item maps `%{id, label}` |
| `selected` | `:list` | required | List of selected item maps `%{id, label}` |
| `on_change` | `:string` | required | Event fired with updated selection |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.drag_transfer_list
  id="permission-transfer"
  available={@available_roles}
  selected={@selected_roles}
  on_change="update_roles"
/>
```

---

## multi_drag_list/1

**Module**: `PhiaUi.Components.Interaction.MultiDrag`
**Tier**: interactive
**Hook**: `PhiaMultiDrag`

Multi-select drag list. Shift-click or Ctrl-click selects multiple items, then the group can be dragged together.

### Attributes

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Required for hook |
| `items` | `:list` | required | List of item maps `%{id, label}` |
| `on_reorder` | `:string` | required | Event fired on drop |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.multi_drag_list
  id="song-queue"
  items={Enum.map(@songs, &%{id: to_string(&1.id), label: &1.title})}
  on_reorder="reorder_songs"
/>
```

---

## draggable_tree/1 and draggable_tree_node/1

**Module**: `PhiaUi.Components.Interaction.DraggableTree`
**Tier**: interactive
**Hook**: `PhiaDraggableTree`

Hierarchical tree with drag-to-reorder nodes. Supports nesting, expanding/collapsing, and drag-into-folder behavior.

### Attributes — `draggable_tree/1`

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Required for hook |
| `on_reorder` | `:string` | required | Event fired with new tree structure |
| `class` | `:string` | `nil` | Additional CSS classes |

### Attributes — `draggable_tree_node/1`

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `:string` | required | Node identifier |
| `label` | `:string` | required | Node display label |
| `parent_id` | `:string` | `nil` | Parent node ID (nil = root) |
| `expanded` | `:boolean` | `true` | Whether children are visible |
| `class` | `:string` | `nil` | Additional CSS classes |

### Usage

```heex
<.draggable_tree id="file-tree" on_reorder="update_tree">
  <.draggable_tree_node id="root" label="Project">
    <.draggable_tree_node id="src" label="lib" parent_id="root">
      <.draggable_tree_node id="comp" label="components" parent_id="src" />
    </.draggable_tree_node>
    <.draggable_tree_node id="docs" label="docs" parent_id="root" />
  </.draggable_tree_node>
</.draggable_tree>
```

### Use Cases

- File/folder tree reordering
- Navigation item management
- Category hierarchy editing
