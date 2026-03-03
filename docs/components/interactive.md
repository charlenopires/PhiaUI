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

## Collapsible

Expand/collapse section using only `Phoenix.LiveView.JS` — no external hook required.

```heex
<%!-- Basic collapsible --%>
<.collapsible id="info-panel" open={@panel_open}>
  <.collapsible_trigger collapsible_id="info-panel" open={@panel_open}>
    <div class="flex items-center justify-between w-full py-2">
      <span class="font-medium">More information</span>
      <.icon name={if @panel_open, do: "chevron-up", else: "chevron-down"} size="sm" />
    </div>
  </.collapsible_trigger>
  <.collapsible_content id="info-panel-content" open={@panel_open}>
    <div class="pt-2 pb-4 text-sm text-muted-foreground">
      <p>This content is hidden by default and revealed when triggered.</p>
    </div>
  </.collapsible_content>
</.collapsible>

<%!-- Server-controlled state (LiveView assign) --%>
def handle_event("toggle-panel", _, socket) do
  {:noreply, assign(socket, :panel_open, !socket.assigns.panel_open)}
end
```

### LiveView integration

The collapsible state lives in the LiveView. Pass the current `:open` assign to both trigger and content:

```elixir
# mount/3
assign(conn, :panel_open, false)

# handle_event
def handle_event("toggle-" <> id, _, socket) do
  key = String.to_existing_atom("#{id}_open")
  {:noreply, assign(socket, key, !socket.assigns[key])}
end
```

---

## Alert Dialog

Confirmation modal for destructive or irreversible actions. Uses `role="alertdialog"` and reuses the `PhiaDialog` JS hook.

```heex
<%!-- Delete confirmation --%>
<.alert_dialog id="delete-confirm" open={@show_delete_confirm}
  aria-labelledby="delete-title" aria-describedby="delete-desc">
  <.alert_dialog_header>
    <.alert_dialog_title id="delete-title">Delete project?</.alert_dialog_title>
    <.alert_dialog_description id="delete-desc">
      This will permanently delete <strong>{@project.name}</strong> and all its data.
      This action cannot be undone.
    </.alert_dialog_description>
  </.alert_dialog_header>
  <.alert_dialog_footer>
    <.alert_dialog_cancel phx-click="cancel-delete">Cancel</.alert_dialog_cancel>
    <.alert_dialog_action variant="destructive" phx-click="confirm-delete" phx-value-id={@project.id}>
      Delete Project
    </.alert_dialog_action>
  </.alert_dialog_footer>
</.alert_dialog>

<%!-- Trigger button --%>
<.button variant="destructive" phx-click="open-delete-confirm">
  Delete Project
</.button>
```

```elixir
# LiveView handlers
def handle_event("open-delete-confirm", _, socket) do
  {:noreply, assign(socket, :show_delete_confirm, true)}
end

def handle_event("cancel-delete", _, socket) do
  {:noreply, assign(socket, :show_delete_confirm, false)}
end

def handle_event("confirm-delete", %{"id" => id}, socket) do
  Projects.delete_project!(id)
  {:noreply, socket
    |> assign(:show_delete_confirm, false)
    |> put_flash(:info, "Project deleted.")}
end
```

### Variants

The action button supports `:variant` attr:

- `"default"` — primary action (e.g. "Confirm", "Yes, proceed")
- `"destructive"` — destructive action (e.g. "Delete", "Remove", "Clear all")

---

## Carousel

Multi-slide carousel with touch swipe, keyboard navigation, and optional loop.

```heex
<%!-- Basic carousel --%>
<.carousel id="hero-carousel" class="w-full max-w-2xl mx-auto">
  <.carousel_content>
    <.carousel_item>
      <.card>
        <.card_content class="p-6">
          <h3 class="text-xl font-bold">Slide 1</h3>
          <p class="text-muted-foreground mt-2">Content for the first slide.</p>
        </.card_content>
      </.card>
    </.carousel_item>
    <.carousel_item>
      <.card>
        <.card_content class="p-6">
          <h3 class="text-xl font-bold">Slide 2</h3>
          <p class="text-muted-foreground mt-2">Content for the second slide.</p>
        </.card_content>
      </.card>
    </.carousel_item>
    <.carousel_item>
      <img src="/banner-3.jpg" alt="Slide 3" class="w-full h-64 object-cover rounded-lg" />
    </.carousel_item>
  </.carousel_content>
  <.carousel_previous />
  <.carousel_next />
</.carousel>

<%!-- Loop mode with vertical orientation --%>
<.carousel id="vert" orientation="vertical" loop={true} class="h-80">
  <.carousel_content>
    <.carousel_item :for={item <- @items}>
      <div class="p-4">{item.title}</div>
    </.carousel_item>
  </.carousel_content>
</.carousel>

<%!-- With dot indicators --%>
<.carousel id="dots-carousel">
  <.carousel_content>
    <.carousel_item :for={slide <- @slides}>
      <img src={slide.url} alt={slide.title} class="w-full h-48 object-cover" />
    </.carousel_item>
  </.carousel_content>
  <.carousel_previous />
  <.carousel_next />
  <:indicators>
    <span :for={_i <- @slides} class="w-2 h-2 rounded-full bg-muted-foreground/50" />
  </:indicators>
</.carousel>
```

### Hook registration

```javascript
import PhiaCarousel from "./phia_hooks/carousel"
// Add to your hooks object
```

---

## Context Menu

Right-click context menu with smart viewport-aware positioning.

```heex
<.context_menu id="file-ctx">
  <.context_menu_trigger context_menu_id="file-ctx">
    <div class="p-8 border-2 border-dashed rounded-lg text-center text-muted-foreground">
      Right-click anywhere in this area
    </div>
  </.context_menu_trigger>
  <.context_menu_content id="file-ctx-content">
    <.context_menu_label>File Actions</.context_menu_label>
    <.context_menu_separator />
    <.context_menu_item phx-click="open-file">Open</.context_menu_item>
    <.context_menu_item phx-click="rename-file">Rename</.context_menu_item>
    <.context_menu_separator />
    <.context_menu_checkbox_item checked={@show_preview} phx-click="toggle-preview">
      Show Preview
    </.context_menu_checkbox_item>
    <.context_menu_separator />
    <.context_menu_item phx-click="delete-file" class="text-destructive">
      Delete
    </.context_menu_item>
  </.context_menu_content>
</.context_menu>
```

### Hook registration

```javascript
import PhiaContextMenu from "./phia_hooks/context_menu"
```

---

## Drawer

Slide-in modal panel from any edge of the screen. Bottom sheet on mobile, side panel on desktop.

```heex
<%!-- Bottom sheet (mobile-first) --%>
<.drawer id="filters-drawer">
  <.drawer_trigger drawer_id="filters-drawer">
    <.button variant="outline"><.icon name="sliders" size="sm" class="mr-2" />Filters</.button>
  </.drawer_trigger>
</drawer>

<.drawer_content id="filters-drawer-content" open={@drawer_open} direction="bottom">
  <.drawer_header>
    <h2 class="text-lg font-semibold" id="filters-title">Filters</h2>
    <p class="text-sm text-muted-foreground">Adjust your search filters.</p>
  </.drawer_header>
  <.drawer_close />
  <div class="px-6 pb-6 space-y-4">
    <.field>
      <.field_label>Category</.field_label>
      <.phia_select field={@form[:category]} options={@categories} />
    </.field>
    <.field>
      <.field_label>Price Range</.field_label>
      <!-- range slider -->
    </.field>
  </div>
  <.drawer_footer>
    <.button phx-click="apply-filters">Apply Filters</.button>
    <.button variant="outline" phx-click="reset-filters">Reset</.button>
  </.drawer_footer>
</.drawer_content>

<%!-- Side panel (right) --%>
<.drawer_content id="details-panel" open={@panel_open} direction="right">
  <.drawer_header>
    <h2 class="text-lg font-semibold">Order Details</h2>
  </.drawer_header>
  <.drawer_close />
  <div class="px-6 pb-6">
    <!-- order details content -->
  </div>
</.drawer_content>
```

### Directions

| Value | Description | Use case |
|-------|-------------|----------|
| `"bottom"` | Slides up from bottom | Mobile sheets, filters |
| `"top"` | Slides down from top | Notifications, alerts |
| `"left"` | Slides from left | Navigation drawer |
| `"right"` | Slides from right | Detail panels, carts |

### Hook registration

```javascript
import PhiaDrawer from "./phia_hooks/drawer"
```

---

## Combobox

Search-filtered dropdown select with keyboard navigation.

```heex
<%!-- Standalone combobox --%>
<.combobox
  id="framework-picker"
  options={[
    %{value: "phoenix", label: "Phoenix"},
    %{value: "rails", label: "Ruby on Rails"},
    %{value: "django", label: "Django"},
    %{value: "laravel", label: "Laravel"}
  ]}
  value={@selected_framework}
  open={@combobox_open}
  search={@combobox_search}
  on_toggle="toggle-framework-picker"
  on_change="select-framework"
  on_search="search-framework"
  placeholder="Select a framework..."
/>

<%!-- With FormField integration --%>
<.form for={@form} phx-submit="save">
  <.form_combobox
    field={@form[:country]}
    id="country-picker"
    options={@countries}
    value={@selected_country}
    open={@country_open}
    search={@country_search}
    placeholder="Select country..."
    on_toggle="toggle-country"
    on_change="select-country"
    on_search="search-country"
  />
  <.button type="submit">Save</.button>
</.form>
```

```elixir
# LiveView assigns and handlers
def mount(_, _, socket) do
  {:ok, assign(socket,
    combobox_open: false,
    combobox_search: "",
    selected_framework: nil
  )}
end

def handle_event("toggle-framework-picker", _, socket) do
  {:noreply, assign(socket, combobox_open: !socket.assigns.combobox_open)}
end

def handle_event("search-framework", %{"query" => q}, socket) do
  {:noreply, assign(socket, combobox_search: q)}
end

def handle_event("select-framework", %{"value" => v}, socket) do
  {:noreply, assign(socket, selected_framework: v, combobox_open: false, combobox_search: "")}
end
```

---

## Date Picker

Calendar dropdown for single date selection with form integration.

```heex
<%!-- Standalone --%>
<.date_picker
  id="start-date"
  value={@start_date}
  open={@date_picker_open}
  current_month={@current_month}
  on_toggle="toggle-date-picker"
  on_change="calendar-change"
  on_prev_month="calendar-prev-month"
  on_next_month="calendar-next-month"
  placeholder="Select a date"
  format="%B %d, %Y"
/>

<%!-- With FormField --%>
<.form for={@form} phx-submit="save">
  <.form_date_picker
    field={@form[:birth_date]}
    id="birth-date-picker"
    value={@selected_date}
    open={@picker_open}
    current_month={@current_month}
  />
  <.button type="submit">Save</.button>
</.form>
```

```elixir
def handle_event("toggle-date-picker", _, socket) do
  {:noreply, assign(socket, date_picker_open: !socket.assigns.date_picker_open)}
end

def handle_event("calendar-change", %{"date" => iso}, socket) do
  date = Date.from_iso8601!(iso)
  {:noreply, assign(socket,
    selected_date: date,
    date_picker_open: false,
    current_month: Date.beginning_of_month(date)
  )}
end

def handle_event("calendar-prev-month", %{"month" => iso}, socket) do
  {:noreply, assign(socket, current_month: Date.from_iso8601!(iso))}
end

def handle_event("calendar-next-month", %{"month" => iso}, socket) do
  {:noreply, assign(socket, current_month: Date.from_iso8601!(iso))}
end
```

← [Back to README](../../README.md)
