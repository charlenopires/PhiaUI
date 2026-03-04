# Enterprise Components

Advanced data management, collaboration, and navigation components for production applications.

| Component | Function | Description |
|-----------|----------|-------------|
| [Activity Feed](#activity-feed) | `activity_feed/1` | Chronological event log with 6 activity types |
| [Heatmap Calendar](#heatmap-calendar) | `heatmap_calendar/1` | GitHub-style contribution grid |
| [Kanban Board](#kanban-board) | `kanban_board/1` | Drag-ready column + card layout |
| [Chat Message](#chat-message) | `chat_message/1` | Full AI/human chat UI system |
| [Mention Input](#mention-input) | `mention_input/1` | `@mention` textarea with server autocomplete |
| [Filter Bar](#filter-bar) | `filter_bar/1` | Horizontal filter toolbar |
| [Filter Builder](#filter-builder) | `filter_builder/1` | Dynamic query builder with rules |
| [Bulk Action Bar](#bulk-action-bar) | `bulk_action_bar/1` | Contextual toolbar for row selection |
| [Step Tracker](#step-tracker) | `step_tracker/1` | Multi-step wizard progress indicator |
| [Navigation Menu](#navigation-menu) | `navigation_menu/1` | Horizontal nav with dropdown panels |

← [Back to README](../../README.md)

---

## Activity Feed

A chronological event log component for real-time activity streams. Groups events by date, supports 6 built-in activity types with icons, and accepts an avatar slot for user identification.

### Anatomy

- `activity_feed/1` — root container (`role="log"`, `aria-live="polite"`) with optional `:footer` slot
- `activity_group/1` — date group with label and ordered list
- `activity_item/1` — single activity row with icon, text, timestamp, and optional avatar

### Activity Types

| Type | Icon | Background |
|------|------|------------|
| `mention` | at-sign | `bg-primary/10` |
| `file` | file-text | `bg-blue-500/10` |
| `call` | phone | `bg-green-500/10` |
| `task` | check-square | `bg-orange-500/10` |
| `reaction` | heart | `bg-pink-500/10` |
| `system` | info | `bg-muted` |

### Example

```heex
<.activity_feed>
  <.activity_group label="Today">
    <.activity_item
      type="mention"
      name="Alice Martin"
      description="mentioned you in a comment on Project Alpha"
      timestamp="2 minutes ago"
    >
      <:avatar>
        <.avatar size="sm">
          <.avatar_image src="/images/alice.jpg" alt="Alice" />
          <.avatar_fallback name="Alice Martin" />
        </.avatar>
      </:avatar>
    </.activity_item>

    <.activity_item
      type="task"
      name="Bob Chen"
      description="completed: Deploy hotfix to production"
      timestamp="15 minutes ago"
    />

    <.activity_item
      type="file"
      name="Carol White"
      description="uploaded design-mockup-v3.fig"
      timestamp="1 hour ago"
    />
  </.activity_group>

  <.activity_group label="Yesterday">
    <.activity_item
      type="call"
      name="Team Standup"
      description="30-minute call with 4 participants"
      timestamp="Yesterday at 10:00 AM"
    />
  </.activity_group>

  <:footer>
    <div class="px-4 py-3 border-t border-border">
      <.button variant="ghost" size="sm" phx-click="load_more_activity">
        Load more activity
      </.button>
    </div>
  </:footer>
</.activity_feed>
```

### LiveView integration

```elixir
def mount(_params, _session, socket) do
  {:ok, assign(socket, activities: MyApp.list_activities(limit: 20))}
end

# With streams for large feeds:
def mount(_params, _session, socket) do
  {:ok, stream(socket, :activities, MyApp.list_activities())}
end
```

```heex
<.activity_feed>
  <.activity_group :for={{date, items} <- grouped_activities(@activities)} label={date}>
    <.activity_item
      :for={item <- items}
      type={item.type}
      name={item.actor_name}
      description={item.description}
      timestamp={item.inserted_at |> Calendar.strftime("%b %d at %I:%M %p")}
    />
  </.activity_group>
</.activity_feed>
```

### Attrs

#### `activity_feed/1`
- `class` — additional CSS classes
- `:footer` slot — content below the activity list (load more button, etc.)

#### `activity_group/1`
- `label` (required) — date/section header text
- `class` — additional CSS classes

#### `activity_item/1`
- `type` (required) — `"mention"` | `"file"` | `"call"` | `"task"` | `"reaction"` | `"system"`
- `name` (required) — actor name
- `description` (required) — activity description text
- `timestamp` (required) — formatted time string
- `class` — additional CSS classes
- `:avatar` slot — optional avatar component

---

## Heatmap Calendar

A GitHub-style contribution heatmap that renders a configurable grid of colored cells based on activity intensity.

### Example

```heex
<.heatmap_calendar
  data={@contribution_data}
  rows={7}
  cols={52}
  max_value={10}
  col_labels={@week_labels}
  row_labels={~w(Mon Tue Wed Thu Fri Sat Sun)}
  show_legend={true}
/>
```

### Generating data

```elixir
def mount(_params, _session, socket) do
  today = Date.utc_today()
  start_date = Date.add(today, -364)

  contribution_data =
    MyApp.Commits.count_by_date(start_date, today)
    |> Enum.reduce(%{}, fn {date, count}, acc ->
      days_ago = Date.diff(today, date)
      col = div(364 - days_ago, 7)
      row = rem(Date.day_of_week(date) - 1, 7)
      Map.put(acc, {col, row}, count)
    end)

  {:ok, assign(socket,
    contribution_data: contribution_data,
    week_labels: generate_week_labels(today, 52)
  )}
end
```

### Intensity CSS

The component assigns `heatmap-0` through `heatmap-4` classes. Define them in your CSS:

```css
.heatmap-0 { background-color: var(--color-muted); }
.heatmap-1 { background-color: oklch(0.7 0.15 142); }
.heatmap-2 { background-color: oklch(0.6 0.18 142); }
.heatmap-3 { background-color: oklch(0.5 0.21 142); }
.heatmap-4 { background-color: oklch(0.4 0.24 142); }
```

### Attrs

- `data` (required) — `%{{col, row} => integer}` map of values
- `rows` — integer, number of rows (default: 7)
- `cols` — integer, number of columns (default: 52)
- `max_value` — integer, value that maps to `heatmap-4` (default: 10)
- `col_labels` — list of strings for column headers
- `row_labels` — list of strings for row labels (left side)
- `show_legend` — boolean, show intensity legend (default: false)
- `class` — additional CSS classes

---

## Kanban Board

A multi-column project board for task management. Cards support priority levels with color-coded left borders and multiple content slots.

### Anatomy

- `kanban_board/1` — horizontal scroll wrapper
- `kanban_column/1` — named column with count badge and card list
- `kanban_card/1` — individual task card with priority, title, slots

### Priority Levels

| Priority | Border Color |
|----------|-------------|
| `critical` | `border-l-destructive` (red) |
| `high` | `border-l-orange-500` |
| `medium` | `border-l-yellow-500` |
| `low` | `border-l-muted-foreground/40` |

### Example

```heex
<.kanban_board>
  <.kanban_column label="Backlog" count={length(@backlog)}>
    <.kanban_card
      :for={card <- @backlog}
      id={"card-#{card.id}"}
      title={card.title}
      priority={card.priority}
    >
      <:tags>
        <.badge :for={tag <- card.tags} variant="secondary">{tag}</.badge>
      </:tags>
      <:footer>
        <span class="text-xs text-muted-foreground">Due {card.due_date}</span>
      </:footer>
    </.kanban_card>
  </.kanban_column>

  <.kanban_column label="In Progress" count={length(@in_progress)}>
    <.kanban_card
      :for={card <- @in_progress}
      id={"card-#{card.id}"}
      title={card.title}
      priority={card.priority}
    >
      <:avatar>
        <.avatar size="xs">
          <.avatar_fallback name={card.assignee} />
        </.avatar>
      </:avatar>
    </.kanban_card>
  </.kanban_column>

  <.kanban_column label="Done" count={length(@done)}>
    <.kanban_card
      :for={card <- @done}
      id={"card-#{card.id}"}
      title={card.title}
      priority="low"
    />
  </.kanban_column>
</.kanban_board>
```

### Moving cards

```elixir
def handle_event("move_card", %{"id" => id, "column" => column}, socket) do
  {:ok, card} = MyApp.move_card(id, column)
  {:noreply, update_board(socket, card)}
end
```

### Attrs

#### `kanban_board/1`
- `class` — additional CSS classes

#### `kanban_column/1`
- `label` (required) — column heading text
- `count` — integer, shown in the column header badge
- `class` — additional CSS classes

#### `kanban_card/1`
- `id` (required) — DOM id for the card element
- `title` (required) — card title text
- `priority` — `"critical"` | `"high"` | `"medium"` | `"low"` (default: `"low"`)
- `class` — additional CSS classes
- `:avatar` slot — user avatar(s) beside the card
- `:tags` slot — badge chips below the title
- `:footer` slot — bottom row (due date, action buttons)

---

## Chat Message

A complete AI/human chat UI system with role-based message alignment, feedback buttons, suggestion chips, and a compose form.

### Anatomy

- `chat_container/1` — scrollable `role="log"` container with `aria-live="polite"`
- `chat_message/1` — message row, aligned by role
- `chat_bubble/1` — styled content balloon with optional avatar and feedback
- `chat_suggestions/1` — row of suggestion chips
- `chat_input/1` — bottom compose form with `phx-submit`

### Message Roles

| Role | Alignment | Background |
|------|-----------|------------|
| `user` | Right | `bg-primary text-primary-foreground` |
| `assistant` | Left | `bg-muted text-foreground` |
| `system` | Center | `text-xs text-muted-foreground italic` |

### Full example

```heex
<.chat_container id="ai-chat" class="h-[500px] px-4">
  <.chat_message role="assistant" id="msg-0">
    <.chat_bubble role="assistant" timestamp="2:30 PM">
      <:avatar>
        <.avatar size="sm">
          <.avatar_image src="/images/bot.png" alt="AI" />
          <.avatar_fallback name="AI Bot" />
        </.avatar>
      </:avatar>
      Welcome! How can I help you today?
    </.chat_bubble>
    <.chat_suggestions
      suggestions={["What are key features?", "Show me a code example", "Pricing info"]}
      on_select="select_suggestion"
    />
  </.chat_message>

  <.chat_message role="user" id="msg-1">
    <.chat_bubble role="user" timestamp="2:31 PM">
      Show me a code example
    </.chat_bubble>
  </.chat_message>

  <.chat_message role="assistant" id="msg-2">
    <.chat_bubble
      role="assistant"
      on_feedback="handle_feedback"
      message_id="msg-2"
      timestamp="2:31 PM"
    >
      Here's a simple LiveView component:
      <pre><code>&lt;.button variant="primary"&gt;Click me&lt;/.button&gt;</code></pre>
    </.chat_bubble>
  </.chat_message>

  <.chat_message role="system" id="msg-sys">
    <.chat_bubble role="system">
      Session started — context window: 4096 tokens
    </.chat_bubble>
  </.chat_message>
</.chat_container>

<.chat_input
  id="chat-compose"
  on_submit="send_message"
  placeholder="Ask anything…"
  max_chars={1000}
>
  <:attachments>
    <span :for={file <- @attachments} class="inline-flex items-center gap-1 rounded-full
      bg-muted px-2 py-0.5 text-xs">
      <.icon name="paperclip" size={:xs} />
      {file.name}
    </span>
  </:attachments>
</.chat_input>
```

### LiveView handlers

```elixir
def handle_event("send_message", %{"message" => text}, socket) when text != "" do
  msg = %{id: Ecto.UUID.generate(), role: "user", body: text, sent_at: "now"}
  {:noreply, socket
    |> stream_insert(:messages, msg)
    |> push_event("phia-toast", %{title: "Sent", variant: "success"})
    |> start_async(:ai_reply, fn -> MyApp.AI.respond(text) end)}
end

def handle_async(:ai_reply, {:ok, reply}, socket) do
  msg = %{id: Ecto.UUID.generate(), role: "assistant", body: reply, sent_at: "now"}
  {:noreply, stream_insert(socket, :messages, msg)}
end

def handle_event("handle_feedback", %{"message-id" => id, "feedback" => vote}, socket) do
  MyApp.record_feedback(id, vote)
  {:noreply, socket}
end

def handle_event("select_suggestion", %{"suggestion" => text}, socket) do
  # Pre-fill input or send directly
  {:noreply, assign(socket, :input_value, text)}
end
```

### Attrs — `chat_bubble/1`
- `role` (required) — `"user"` | `"assistant"` | `"system"`
- `timestamp` — string, optional time label
- `on_feedback` — `phx-click` event for thumbs up/down (assistant only)
- `message_id` — passed as `phx-value-message-id` to feedback buttons
- `class` — additional CSS classes
- `:avatar` slot — avatar component for assistant messages
- `:inner_block` slot (required) — message text

### Attrs — `chat_input/1`
- `id` (required) — DOM id for the form element
- `on_submit` (required) — `phx-submit` event name
- `placeholder` — textarea placeholder (default: `"Type a message..."`)
- `max_chars` — integer, shows character counter when provided
- `class` — additional CSS classes
- `:attachments` slot — optional file chip rows above textarea

---

## Mention Input

A textarea with `@mention` autocomplete. Detects `@` typing, emits a server event with the search query, and renders a suggestion dropdown with the server's response. Selected mentions are tracked in a hidden CSV input.

### Setup

Register the `PhiaMentionInput` JS hook:

```javascript
import PhiaMentionInput from "./phia_hooks/mention_input"

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { PhiaMentionInput }
})
```

### Example

```heex
<.mention_input
  id="comment-field"
  name="comment"
  suggestions={@mention_suggestions}
  open={@mention_open}
  search={@mention_search}
  mentioned_ids={@mentioned_ids}
  on_mention="mention_search"
  on_select="mention_select"
  placeholder="Leave a comment… type @ to mention someone"
/>
```

### LiveView handlers

```elixir
def handle_event("mention_search", %{"query" => q}, socket) do
  suggestions =
    MyApp.Users.search(q)
    |> Enum.map(&%{id: &1.id, name: &1.name, avatar: &1.avatar_url})

  {:noreply, assign(socket,
    mention_suggestions: suggestions,
    mention_open: true,
    mention_search: q
  )}
end

def handle_event("mention_select", %{"id" => id, "name" => name}, socket) do
  ids = [id | socket.assigns.mentioned_ids] |> Enum.uniq()
  {:noreply, assign(socket,
    mentioned_ids: ids,
    mention_open: false,
    mention_search: ""
  )}
end

def handle_event("mention_close", _params, socket) do
  {:noreply, assign(socket, mention_open: false, mention_suggestions: [])}
end
```

### Form submission

The component renders a hidden `<input name="comment_ids" value="u1,u2,u3">` alongside the textarea. In your `handle_event("submit", ...)`, extract the IDs:

```elixir
def handle_event("submit_comment", %{"comment" => text, "comment_ids" => ids_csv}, socket) do
  user_ids = String.split(ids_csv, ",", trim: true)
  MyApp.Comments.create(%{body: text, mentioned_ids: user_ids})
  {:noreply, socket}
end
```

### Server-rendered mention chip

For displaying resolved mentions in read-only content:

```heex
<p>
  Thanks
  <.mention_chip name="Alice Martin" user_id="u1" />
  for the review!
</p>
```

### Attrs — `mention_input/1`
- `id` (required) — DOM id (used by the PhiaMentionInput hook)
- `name` (required) — form field name (hidden input will use `name_ids`)
- `suggestions` — list of `%{id, name, avatar}` maps (default: `[]`)
- `open` — boolean, controls dropdown visibility (default: `false`)
- `search` — current search term (default: `""`)
- `value` — current textarea value (default: `""`)
- `mentioned_ids` — list of already-selected user IDs (default: `[]`)
- `on_mention` — event fired by hook when user types after `@`
- `on_select` — event fired when suggestion clicked (default: `"mention_select"`)
- `placeholder` — textarea placeholder
- `class` — additional CSS classes

---

## Filter Bar

A horizontal toolbar for composing simple table filters inline. Ideal above a `data_grid/1` or `table/1`.

### Example

```heex
<.filter_bar class="mb-4">
  <.filter_search
    placeholder="Search customers…"
    on_search="search_customers"
    value={@search_query}
  />
  <.filter_select
    label="Status"
    name="status"
    options={[{"All", ""}, {"Active", "active"}, {"Churned", "churned"}, {"Trial", "trial"}]}
    value={@status_filter}
    on_change="filter_by_status"
  />
  <.filter_select
    label="Plan"
    name="plan"
    options={[{"All", ""}, {"Free", "free"}, {"Pro", "pro"}, {"Enterprise", "enterprise"}]}
    value={@plan_filter}
    on_change="filter_by_plan"
  />
  <.filter_toggle
    label="Verified only"
    name="verified"
    checked={@show_verified_only}
    on_change="toggle_verified"
  />
  <.filter_reset on_click="reset_all_filters" />
</.filter_bar>
```

### LiveView handlers

```elixir
def handle_event("search_customers", %{"search" => q}, socket) do
  {:noreply, assign(socket, search_query: q) |> reload_customers()}
end

def handle_event("filter_by_status", %{"status" => status}, socket) do
  {:noreply, assign(socket, status_filter: status) |> reload_customers()}
end

def handle_event("toggle_verified", %{"verified" => checked}, socket) do
  {:noreply, assign(socket, show_verified_only: checked == "true") |> reload_customers()}
end

def handle_event("reset_all_filters", _params, socket) do
  {:noreply, socket
    |> assign(search_query: "", status_filter: "", plan_filter: "", show_verified_only: false)
    |> reload_customers()}
end
```

### Sub-component attrs

#### `filter_search/1`
- `on_search` (required) — `phx-change` event
- `placeholder` — input placeholder (default: `"Search…"`)
- `value` — current value
- `name` — input name (default: `"search"`)

#### `filter_select/1`
- `label` (required) — text shown beside the select
- `name` (required) — select name attribute
- `options` (required) — list of `{label, value}` tuples
- `value` — currently selected value
- `on_change` (required) — `phx-change` event

#### `filter_toggle/1`
- `label` (required) — visible label text
- `name` (required) — checkbox name attribute
- `checked` — boolean (default: `false`)
- `on_change` (required) — `phx-change` event

#### `filter_reset/1`
- `on_click` (required) — `phx-click` event
- `label` — button text (default: `"Reset"`)

---

## Filter Builder

An advanced query builder UI for constructing dynamic filter rules. Each rule is a row of: field + operator + value + remove button. Rules are added/removed via server events.

### Example

```heex
<.filter_builder
  fields={[
    %{name: "name",       label: "Name",       type: "text"},
    %{name: "email",      label: "Email",      type: "text"},
    %{name: "status",     label: "Status",     type: "select",
      options: [{"Active", "active"}, {"Inactive", "inactive"}]},
    %{name: "created_at", label: "Created",    type: "date"},
    %{name: "score",      label: "Score",      type: "number"}
  ]}
  rules={@filter_rules}
  on_add="add_filter_rule"
  on_remove="remove_filter_rule"
  on_change="update_filter_rule"
/>
```

### LiveView handlers

```elixir
def mount(_params, _session, socket) do
  {:ok, assign(socket, filter_rules: [])}
end

def handle_event("add_filter_rule", _params, socket) do
  rule = %{
    id: :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower),
    field: "name",
    operator: "contains",
    value: ""
  }
  {:noreply, update(socket, :filter_rules, &[rule | &1])}
end

def handle_event("remove_filter_rule", %{"id" => id}, socket) do
  {:noreply, update(socket, :filter_rules, &Enum.reject(&1, fn r -> r.id == id end))}
end

def handle_event("update_filter_rule", params, socket) do
  id = params["id"]
  updated = Enum.map(socket.assigns.filter_rules, fn rule ->
    if rule.id == id do
      %{rule |
        field:    params["filter"][id]["field"]    || rule.field,
        operator: params["filter"][id]["operator"] || rule.operator,
        value:    params["filter"][id]["value"]    || rule.value
      }
    else
      rule
    end
  end)
  {:noreply, assign(socket, :filter_rules, updated)}
end
```

### Applying the rules

```elixir
defp apply_filters(query, rules) do
  Enum.reduce(rules, query, fn rule, q ->
    case {rule.field, rule.operator, rule.value} do
      {"name",   "contains",   v} -> where(q, [u], ilike(u.name, ^"%#{v}%"))
      {"status", "equals",     v} -> where(q, [u], u.status == ^v)
      {"score",  "gt",         v} -> where(q, [u], u.score > ^String.to_integer(v))
      _ -> q
    end
  end)
end
```

### Field Schema

Each field map:
- `name` — unique identifier
- `label` — display label
- `type` — `"text"` | `"select"` | `"date"` | `"number"`
- `options` — `[{label, value}]` (required for `type: "select"` only)

### Built-in operators by type

| Field type | Operators |
|------------|-----------|
| `text` | `contains`, `equals`, `starts_with`, `ends_with`, `is_empty` |
| `select` | `equals`, `not_equals` |
| `date` | `equals`, `before`, `after`, `between` |
| `number` | `equals`, `gt`, `lt`, `between` |

---

## Bulk Action Bar

A contextual toolbar that appears when rows are selected in a table. Hidden automatically when no rows are selected (`count == 0`).

### Example

```heex
<.bulk_action_bar
  count={@selected_count}
  label="records selected"
  on_clear="clear_selection"
>
  <.bulk_action label="Delete"  on_click="bulk_delete"  variant="destructive" icon="trash" />
  <.bulk_action label="Archive" on_click="bulk_archive" icon="archive" />
  <.bulk_action label="Export"  on_click="bulk_export"  icon="download"
    phx-value-format="csv" />
</.bulk_action_bar>
```

### Integration with a DataGrid

```heex
<.bulk_action_bar count={MapSet.size(@selected)} on_clear="clear_selection">
  <.bulk_action label="Delete selected"
    on_click="bulk_delete"
    variant="destructive"
    phx-value-ids={MapSet.to_list(@selected) |> Enum.join(",")} />
</.bulk_action_bar>

<.data_grid id="customers-grid" rows={@customers} ...>
  <:col label="">
    <:cell :let={row}>
      <input type="checkbox"
        checked={MapSet.member?(@selected, row.id)}
        phx-click="toggle_select"
        phx-value-id={row.id} />
    </:cell>
  </:col>
  ...
</.data_grid>
```

### LiveView handlers

```elixir
def handle_event("toggle_select", %{"id" => id}, socket) do
  selected = socket.assigns.selected
  updated =
    if MapSet.member?(selected, id),
      do: MapSet.delete(selected, id),
      else: MapSet.put(selected, id)
  {:noreply, assign(socket, selected: updated, selected_count: MapSet.size(updated))}
end

def handle_event("clear_selection", _params, socket) do
  {:noreply, assign(socket, selected: MapSet.new(), selected_count: 0)}
end

def handle_event("bulk_delete", _params, socket) do
  MyApp.delete_all(MapSet.to_list(socket.assigns.selected))
  {:noreply, socket
    |> assign(selected: MapSet.new(), selected_count: 0)
    |> push_event("phia-toast", %{title: "Deleted", variant: "success"})}
end
```

### Attrs — `bulk_action_bar/1`
- `count` (required) — integer; bar renders nothing when `0`
- `label` — string after count (default: `"selected"`)
- `on_clear` (required) — `phx-click` event to deselect all

### Attrs — `bulk_action/1`
- `label` (required) — button text
- `on_click` (required) — `phx-click` event
- `variant` — `"default"` | `"destructive"` (default: `"default"`)
- `icon` — Lucide icon name, shown before label
- `class` — additional CSS classes
- `:rest` — forwarded globals (e.g. `phx-value-ids`, `disabled`)

---

## Step Tracker

A multi-step wizard progress indicator. Displays completed, active, and upcoming steps with connecting lines.

### Example

```heex
<%!-- Horizontal (default) --%>
<.step_tracker>
  <.step status="complete" label="Account"  step={1} />
  <.step status="active"   label="Profile"  step={2} description="Fill in your details" />
  <.step status="upcoming" label="Payment"  step={3} />
  <.step status="upcoming" label="Confirm"  step={4} />
</.step_tracker>

<%!-- Vertical --%>
<.step_tracker orientation="vertical">
  <.step status="complete" label="Order placed"    step={1} description="March 1 at 10:00 AM" />
  <.step status="complete" label="Payment confirmed" step={2} description="March 1 at 10:05 AM" />
  <.step status="active"   label="In transit"      step={3} description="Estimated March 5" />
  <.step status="upcoming" label="Delivered"       step={4} />
</.step_tracker>
```

### Dynamic status from LiveView

```elixir
def current_step_status(current, step_number) do
  cond do
    step_number < current -> "complete"
    step_number == current -> "active"
    true -> "upcoming"
  end
end
```

```heex
<.step_tracker>
  <.step :for={{step, i} <- Enum.with_index(@steps, 1)}
    status={current_step_status(@current_step, i)}
    label={step.label}
    step={i}
    description={step.description}
  />
</.step_tracker>
```

### Attrs — `step_tracker/1`
- `orientation` — `"horizontal"` | `"vertical"` (default: `"horizontal"`)
- `class` — additional CSS classes

### Attrs — `step/1`
- `status` (required) — `"complete"` | `"active"` | `"upcoming"`
- `label` (required) — step label text
- `step` — integer, displayed inside the circle
- `description` — optional subtitle below label
- `class` — additional CSS classes

---

## Navigation Menu

A horizontal navigation bar with support for simple links and dropdown trigger+content panels.

### Example

```heex
<.navigation_menu>
  <.navigation_menu_list>
    <.navigation_menu_item>
      <.navigation_menu_link href="/" active={@current_path == "/"}>
        Home
      </.navigation_menu_link>
    </.navigation_menu_item>

    <.navigation_menu_item>
      <.navigation_menu_trigger label="Products" />
      <.navigation_menu_content class="w-[400px]">
        <ul class="grid grid-cols-2 gap-3 p-4">
          <li>
            <a href="/products/web" class="block rounded-md p-3 hover:bg-muted">
              <p class="font-medium">Web Platform</p>
              <p class="text-sm text-muted-foreground">Build web applications</p>
            </a>
          </li>
          <li>
            <a href="/products/mobile" class="block rounded-md p-3 hover:bg-muted">
              <p class="font-medium">Mobile SDK</p>
              <p class="text-sm text-muted-foreground">iOS and Android apps</p>
            </a>
          </li>
        </ul>
      </.navigation_menu_content>
    </.navigation_menu_item>

    <.navigation_menu_item>
      <.navigation_menu_trigger label="Resources" />
      <.navigation_menu_content>
        <ul class="flex flex-col gap-1 p-2">
          <li><a href="/docs" class="block rounded-md px-3 py-2 hover:bg-muted">Documentation</a></li>
          <li><a href="/blog" class="block rounded-md px-3 py-2 hover:bg-muted">Blog</a></li>
          <li><a href="/changelog" class="block rounded-md px-3 py-2 hover:bg-muted">Changelog</a></li>
        </ul>
      </.navigation_menu_content>
    </.navigation_menu_item>

    <.navigation_menu_item>
      <.navigation_menu_link href="/pricing" active={@current_path == "/pricing"}>
        Pricing
      </.navigation_menu_link>
    </.navigation_menu_item>
  </.navigation_menu_list>
</.navigation_menu>
```

### Active link tracking

```elixir
def mount(_params, _session, socket) do
  {:ok, assign(socket, :current_path, "/")}
end

def handle_params(_params, uri, socket) do
  %URI{path: path} = URI.parse(uri)
  {:noreply, assign(socket, :current_path, path)}
end
```

### Attrs — `navigation_menu_link/1`
- `href` (required) — destination URL
- `active` — boolean, sets `aria-current="page"` and active styling (default: `false`)
- `class` — additional CSS classes

### Attrs — `navigation_menu_trigger/1`
- `label` (required) — button text
- `class` — additional CSS classes

← [Back to README](../../README.md)
