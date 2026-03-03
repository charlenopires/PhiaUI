# Interactive Components

These components require vanilla JS hooks for accessible behaviors: focus trapping, keyboard navigation, positioning, and event-driven state. All hooks are zero-dependency — no npm packages.

- [Dialog](#dialog)
- [Dropdown Menu](#dropdown-menu)
- [Accordion](#accordion)
- [Tooltip](#tooltip)
- [Popover](#popover)
- [Toast](#toast)
- [Command Menu (Ctrl+K)](#command-menu-ctrlk)
- [Date Range Picker](#date-range-picker)

---

## Dialog

Modal dialog with focus trap, Escape key, scroll locking, and automatic first-element focus.

```heex
<.dialog id="confirm-delete">
  <.dialog_trigger>
    <.button variant="destructive">Delete record</.button>
  </.dialog_trigger>
  <.dialog_content>
    <.dialog_header>
      <.dialog_title>Are you sure?</.dialog_title>
      <.dialog_description>
        This will permanently delete the record. This action cannot be undone.
      </.dialog_description>
    </.dialog_header>
    <.dialog_footer>
      <.dialog_close><.button variant="outline">Cancel</.button></.dialog_close>
      <.button variant="destructive" phx-click="confirm-delete">Delete</.button>
    </.dialog_footer>
  </.dialog_content>
</.dialog>
```

### Form inside a dialog

```heex
<.dialog id="edit-user-dialog">
  <.dialog_trigger>
    <.button variant="outline" size="sm">Edit user</.button>
  </.dialog_trigger>
  <.dialog_content>
    <.dialog_header>
      <.dialog_title>Edit user</.dialog_title>
    </.dialog_header>
    <.form for={@form} phx-submit="save-user" phx-change="validate-user" class="space-y-4">
      <.phia_input field={@form[:name]} label="Name" />
      <.phia_input field={@form[:email]} type="email" label="Email" />
      <.phia_select field={@form[:role]} options={["admin", "editor", "viewer"]} label="Role" />
      <.dialog_footer>
        <.dialog_close><.button type="button" variant="outline">Cancel</.button></.dialog_close>
        <.button type="submit">Save changes</.button>
      </.dialog_footer>
    </.form>
  </.dialog_content>
</.dialog>
```

### Programmatic open from LiveView

```elixir
# Open dialog from a LiveView event
def handle_event("trigger-modal", _, socket) do
  {:noreply, push_event(socket, "open-dialog", %{id: "edit-user-dialog"})}
end
```

### Required hook

```javascript
import PhiaDialog from "./phia_hooks/dialog"
```

---

## Dropdown Menu

Contextual menu with smart auto-flip positioning, click-outside detection, and Arrow Up/Down keyboard navigation.

```heex
<.dropdown_menu id="row-actions">
  <.dropdown_menu_trigger>
    <.button variant="ghost" size="icon">
      <.icon name="more-horizontal" />
    </.button>
  </.dropdown_menu_trigger>
  <.dropdown_menu_content>
    <.dropdown_menu_label>Actions</.dropdown_menu_label>
    <.dropdown_menu_separator />
    <.dropdown_menu_item phx-click="edit" phx-value-id={@row.id}>
      <.icon name="pencil" size="sm" />
      Edit
    </.dropdown_menu_item>
    <.dropdown_menu_item phx-click="duplicate" phx-value-id={@row.id}>
      <.icon name="copy" size="sm" />
      Duplicate
    </.dropdown_menu_item>
    <.dropdown_menu_separator />
    <.dropdown_menu_item phx-click="delete" phx-value-id={@row.id} class="text-destructive">
      <.icon name="trash" size="sm" />
      Delete
    </.dropdown_menu_item>
  </.dropdown_menu_content>
</.dropdown_menu>
```

### Navigation dropdown

```heex
<.dropdown_menu id="user-menu">
  <.dropdown_menu_trigger>
    <button class="flex items-center gap-2 rounded-full">
      <img src={@current_user.avatar} class="h-8 w-8 rounded-full" />
      <span class="text-sm"><%= @current_user.name %></span>
      <.icon name="chevron-down" size="sm" />
    </button>
  </.dropdown_menu_trigger>
  <.dropdown_menu_content>
    <.dropdown_menu_label><%= @current_user.email %></.dropdown_menu_label>
    <.dropdown_menu_separator />
    <.dropdown_menu_item phx-click={JS.navigate(~p"/settings")}>
      <.icon name="settings" size="sm" /> Settings
    </.dropdown_menu_item>
    <.dropdown_menu_separator />
    <.dropdown_menu_item phx-click="sign-out" class="text-destructive">
      <.icon name="log-out" size="sm" /> Sign out
    </.dropdown_menu_item>
  </.dropdown_menu_content>
</.dropdown_menu>
```

### Required hook

```javascript
import PhiaDropdownMenu from "./phia_hooks/dropdown_menu"
```

---

## Accordion

Expandable content sections. Uses `Phoenix.LiveView.JS` — no external hook required.

```heex
<%!-- Single: only one item open at a time --%>
<.accordion type="single">
  <.accordion_item accordion_id="faq-1">
    <.accordion_trigger accordion_id="faq-1">
      What is the refund policy?
    </.accordion_trigger>
    <.accordion_content accordion_id="faq-1">
      We offer full refunds within 30 days of purchase.
    </.accordion_content>
  </.accordion_item>
  <.accordion_item accordion_id="faq-2">
    <.accordion_trigger accordion_id="faq-2">
      How do I cancel?
    </.accordion_trigger>
    <.accordion_content accordion_id="faq-2">
      Go to Settings → Billing and click "Cancel subscription".
    </.accordion_content>
  </.accordion_item>
</.accordion>

<%!-- Multiple: several can be open simultaneously --%>
<.accordion type="multiple">
  <%!-- same anatomy --%>
</.accordion>
```

### FAQ from a list

```heex
<.accordion type="single">
  <.accordion_item :for={item <- @faqs} accordion_id={"faq-#{item.id}"}>
    <.accordion_trigger accordion_id={"faq-#{item.id}"}>
      <%= item.question %>
    </.accordion_trigger>
    <.accordion_content accordion_id={"faq-#{item.id}"}>
      <%= item.answer %>
    </.accordion_content>
  </.accordion_item>
</.accordion>
```

---

## Tooltip

Hover/focus tooltips with configurable position and smart viewport flip.

```heex
<%!-- Basic tooltip --%>
<.tooltip id="save-tip">
  <.tooltip_trigger tooltip_id="save-tip">
    <.button size="icon" variant="ghost"><.icon name="save" /></.button>
  </.tooltip_trigger>
  <.tooltip_content tooltip_id="save-tip">
    Save document (Ctrl+S)
  </.tooltip_content>
</.tooltip>

<%!-- Positions: :top (default), :bottom, :left, :right --%>
<.tooltip id="help-tip">
  <.tooltip_trigger tooltip_id="help-tip">
    <.icon name="help-circle" size="sm" class="text-muted-foreground" />
  </.tooltip_trigger>
  <.tooltip_content tooltip_id="help-tip" position={:bottom}>
    Click to open the documentation
  </.tooltip_content>
</.tooltip>
```

### Custom delay

```heex
<.tooltip id="delayed-tip" delay_ms={500}>
  <.tooltip_trigger tooltip_id="delayed-tip">
    <span>Hover me</span>
  </.tooltip_trigger>
  <.tooltip_content tooltip_id="delayed-tip">
    Appears after 500ms
  </.tooltip_content>
</.tooltip>
```

### Required hook

```javascript
import PhiaTooltip from "./phia_hooks/tooltip"
```

---

## Popover

Click-to-open floating panel with focus trap and click-outside dismissal.

```heex
<.popover id="filter-popover">
  <.popover_trigger popover_id="filter-popover">
    <.button variant="outline">
      <.icon name="filter" size="sm" />
      Filter
    </.button>
  </.popover_trigger>
  <.popover_content popover_id="filter-popover" class="w-64 space-y-4">
    <p class="text-sm font-semibold">Filter by status</p>
    <label class="flex items-center gap-2 text-sm">
      <input type="checkbox" phx-click="filter" phx-value-status="active" />
      Active
    </label>
    <label class="flex items-center gap-2 text-sm">
      <input type="checkbox" phx-click="filter" phx-value-status="inactive" />
      Inactive
    </label>
    <.button size="sm" class="w-full" phx-click="apply-filters">Apply</.button>
  </.popover_content>
</.popover>
```

### Profile popover

```heex
<.popover id="profile-popover">
  <.popover_trigger popover_id="profile-popover">
    <button class="rounded-full ring-2 ring-border hover:ring-primary transition-all">
      <img src={@user.avatar} class="h-9 w-9 rounded-full" />
    </button>
  </.popover_trigger>
  <.popover_content popover_id="profile-popover" class="w-56">
    <div class="flex items-center gap-3 p-1">
      <img src={@user.avatar} class="h-10 w-10 rounded-full" />
      <div>
        <p class="text-sm font-medium"><%= @user.name %></p>
        <p class="text-xs text-muted-foreground"><%= @user.email %></p>
      </div>
    </div>
    <div class="mt-2 border-t border-border pt-2 space-y-1">
      <.button variant="ghost" size="sm" class="w-full justify-start" phx-click={JS.navigate(~p"/settings")}>
        <.icon name="settings" size="sm" /> Settings
      </.button>
      <.button variant="ghost" size="sm" class="w-full justify-start text-destructive" phx-click="sign-out">
        <.icon name="log-out" size="sm" /> Sign out
      </.button>
    </div>
  </.popover_content>
</.popover>
```

### Required hook

```javascript
import PhiaPopover from "./phia_hooks/popover"
```

---

## Toast

Non-blocking notifications triggered from the server via `push_event`. Supports auto-dismiss, stacking, and 4 variants.

```heex
<%!-- Mount the viewport once (e.g. in root.html.heex) --%>
<.toast id="toast-viewport" />
```

### Trigger from LiveView

```elixir
# Success toast
{:noreply, push_event(socket, "phia-toast", %{
  title: "Saved",
  description: "Your changes have been saved.",
  variant: "success",
  duration: 4000
})}

# Error toast
{:noreply, push_event(socket, "phia-toast", %{
  title: "Error",
  description: "Failed to process payment.",
  variant: "destructive"
})}

# Warning toast
{:noreply, push_event(socket, "phia-toast", %{
  title: "Storage limit",
  description: "You are nearing your storage quota.",
  variant: "warning"
})}

# Plain default
{:noreply, push_event(socket, "phia-toast", %{
  title: "Import started",
  description: "We'll notify you when it's ready."
})}
```

### Variants

| Variant | Use case |
|---------|----------|
| `"default"` | Neutral information |
| `"success"` | Successful actions |
| `"destructive"` | Errors and failures |
| `"warning"` | Non-blocking warnings |

### Required hook

```javascript
import PhiaToast from "./phia_hooks/toast"
```

---

## Command Menu (Ctrl+K)

Global search palette with keyboard navigation. Hook registers `Ctrl+K` / `Cmd+K` globally. Results are filtered server-side via `phx-change`.

```heex
<%!-- Mount the command modal once in your root layout --%>
<.command id="command-menu">
  <.command_input
    id="command-search"
    on_change="command-search"
    placeholder="Search commands…"
  />
  <.command_list id="command-results">
    <.command_empty>No results found.</.command_empty>

    <.command_group label="Navigation">
      <.command_item on_click="navigate" value="/dashboard">
        <.icon name="layout-dashboard" size="sm" />
        Dashboard
        <.command_shortcut>G D</.command_shortcut>
      </.command_item>
      <.command_item on_click="navigate" value="/reports">
        <.icon name="bar-chart-2" size="sm" />
        Reports
      </.command_item>
    </.command_group>

    <.command_separator />

    <.command_group label="Actions" :if={@command_results != []}>
      <.command_item :for={item <- @command_results} on_click="run-command" value={item.id}>
        <.icon name={item.icon} size="sm" />
        <%= item.label %>
      </.command_item>
    </.command_group>
  </.command_list>
</.command>
```

### LiveView handler

```elixir
def handle_event("command-search", %{"value" => query}, socket) do
  results = Commands.search(query)
  {:noreply, assign(socket, command_results: results)}
end

def handle_event("run-command", %{"value" => id}, socket) do
  Commands.execute(id, socket.assigns.current_user)
  {:noreply, push_event(socket, "close-command", %{})}
end
```

### Required hook

```javascript
import PhiaCommand from "./phia_hooks/command"
```

---

## Date Range Picker

Dual-calendar server-side picker for booking and reporting flows. Calendar grid rendered in Elixir, state managed in your LiveView.

```heex
<.date_range_picker
  id="booking-range"
  view_month={@view_month}
  from={@date_from}
  to={@date_to}
  on_change="select-date"
  on_month_change="change-month"
  min_date={Date.utc_today()}
/>
```

### With max date

```heex
<.date_range_picker
  id="report-range"
  view_month={@view_month}
  from={@from}
  to={@to}
  on_change="range-selected"
  on_month_change="change-month"
  min_date={~D[2024-01-01]}
  max_date={Date.utc_today()}
/>
```

### LiveView handlers

```elixir
def mount(_params, _session, socket) do
  {:ok, assign(socket,
    view_month: Date.utc_today(),
    date_from: nil,
    date_to: nil
  )}
end

def handle_event("select-date", %{"date" => date_str}, socket) do
  date = Date.from_iso8601!(date_str)
  socket = cond do
    is_nil(socket.assigns.date_from) ->
      assign(socket, date_from: date, date_to: nil)
    is_nil(socket.assigns.date_to) and Date.compare(date, socket.assigns.date_from) != :lt ->
      assign(socket, date_to: date)
    true ->
      assign(socket, date_from: date, date_to: nil)
  end
  {:noreply, socket}
end

def handle_event("change-month", %{"dir" => "next"}, socket) do
  {:noreply, assign(socket, view_month: Date.shift(socket.assigns.view_month, month: 1))}
end

def handle_event("change-month", %{"dir" => "prev"}, socket) do
  {:noreply, assign(socket, view_month: Date.shift(socket.assigns.view_month, month: -1))}
end
```

### Booking form example

```heex
<.card>
  <.card_header>
    <.card_title>Book a stay</.card_title>
  </.card_header>
  <.card_content class="space-y-4">
    <.date_range_picker
      id="stay-range"
      view_month={@view_month}
      from={@check_in}
      to={@check_out}
      on_change="select-date"
      on_month_change="change-month"
      min_date={Date.utc_today()}
    />
    <div class="flex gap-2 text-sm">
      <span class="font-medium">Check-in:</span>
      <span><%= format_date(@check_in) || "—" %></span>
      <span class="mx-2">→</span>
      <span class="font-medium">Check-out:</span>
      <span><%= format_date(@check_out) || "—" %></span>
    </div>
    <.button class="w-full" disabled={is_nil(@check_in) or is_nil(@check_out)}>
      Search availability
    </.button>
  </.card_content>
</.card>
```

### Required hook

```javascript
import PhiaDateRangePicker from "./phia_hooks/date_range_picker"
```

---

← [Back to README](../../README.md)
