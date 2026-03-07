# Feedback

Loading states, alerts, progress indicators, notification systems, and confirmation patterns.

## Table of Contents

- [alert](#alert)
- [alert_dialog](#alert_dialog)
- [spinner](#spinner)
- [skeleton](#skeleton)
- [progress](#progress)
- [circular_progress](#circular_progress)
- [empty_state](#empty_state)
- [step_tracker](#step_tracker)
- [toast](#toast)
- [snackbar](#snackbar)
- [sonner](#sonner)
- [popconfirm](#popconfirm) _(new in 0.1.7)_
- [result_state](#result_state) _(new in 0.1.7)_

---

## alert

Non-interactive feedback banner. 4 variants with optional icon slot.

**Variants**: `default`, `destructive`, `warning`, `success`

```heex
<%!-- Default --%>
<.alert>
  <.alert_title>Heads up!</.alert_title>
  <.alert_description>Your trial expires in 3 days. Upgrade to keep access.</.alert_description>
</.alert>

<%!-- Destructive with icon --%>
<.alert variant="destructive">
  <:icon><.icon name="alert-circle" /></:icon>
  <.alert_title>Payment failed</.alert_title>
  <.alert_description>Your card was declined. Please update your payment method.</.alert_description>
</.alert>

<%!-- Warning --%>
<.alert variant="warning">
  <:icon><.icon name="alert-triangle" /></:icon>
  <.alert_title>Storage limit approaching</.alert_title>
  <.alert_description>You've used 90% of your 5GB quota.</.alert_description>
</.alert>

<%!-- Success --%>
<.alert variant="success">
  <:icon><.icon name="check-circle" /></:icon>
  <.alert_title>Published</.alert_title>
  <.alert_description>Your post is now live and visible to subscribers.</.alert_description>
</.alert>

<%!-- Conditional render from flash --%>
<.alert :if={@flash["error"]} variant="destructive">
  <.alert_title>Error</.alert_title>
  <.alert_description><%= @flash["error"] %></.alert_description>
</.alert>
```

---

## alert_dialog

Modal confirmation dialog. Uses `PhiaDialog` hook. `role="alertdialog"` for screen readers.

**Sub-components**: `alert_dialog_header/1`, `alert_dialog_title/1`, `alert_dialog_description/1`, `alert_dialog_footer/1`, `alert_dialog_cancel/1`, `alert_dialog_action/1`

```heex
<%!-- Delete confirmation --%>
<.alert_dialog id="delete-confirm" open={@show_confirm}>
  <.alert_dialog_header>
    <.alert_dialog_title>Delete this item?</.alert_dialog_title>
    <.alert_dialog_description>
      This action cannot be undone. The item and all associated data will be permanently removed.
    </.alert_dialog_description>
  </.alert_dialog_header>
  <.alert_dialog_footer>
    <.alert_dialog_cancel phx-click="cancel-delete">Cancel</.alert_dialog_cancel>
    <.alert_dialog_action variant="destructive" phx-click="confirm-delete" phx-value-id={@item_id}>
      Delete
    </.alert_dialog_action>
  </.alert_dialog_footer>
</.alert_dialog>
```

```elixir
def handle_event("show-confirm", %{"id" => id}, socket) do
  {:noreply, assign(socket, show_confirm: true, item_id: id)}
end

def handle_event("cancel-delete", _params, socket) do
  {:noreply, assign(socket, show_confirm: false, item_id: nil)}
end

def handle_event("confirm-delete", %{"id" => id}, socket) do
  MyApp.delete_item(id)
  {:noreply, assign(socket, show_confirm: false, item_id: nil)}
end
```

---

## spinner

CSS SVG animated loading indicator. 5 sizes, `role="status"`, `aria-live="polite"`.

**Sizes**: `:xs`, `:sm`, `:md` (default), `:lg`, `:xl`

```heex
<.spinner />
<.spinner size="lg" class="text-primary" />
<.spinner size="sm" label="Loading users…" />

<%!-- In a button during loading --%>
<.button phx-click="save" disabled={@saving}>
  <.spinner :if={@saving} size="xs" class="mr-2" />
  <%= if @saving, do: "Saving…", else: "Save" %>
</.button>

<%!-- Full-page loading overlay --%>
<div :if={@loading} class="flex items-center justify-center h-64">
  <div class="text-center space-y-2">
    <.spinner size="xl" class="text-primary mx-auto" />
    <p class="text-sm text-muted-foreground">Loading your data…</p>
  </div>
</div>
```

---

## skeleton

`animate-pulse` placeholder blocks for content that is loading.

```heex
<%!-- Basic shapes --%>
<.skeleton class="h-4 w-48" />
<.skeleton class="h-10 w-10 rounded-full" />
<.skeleton class="h-24 w-full rounded-md" />

<%!-- User card skeleton --%>
<.card :if={@loading}>
  <.card_header>
    <div class="flex items-center gap-4">
      <.skeleton class="h-12 w-12 rounded-full" />
      <div class="space-y-2">
        <.skeleton class="h-4 w-32" />
        <.skeleton class="h-3 w-24" />
      </div>
    </div>
  </.card_header>
  <.card_content class="space-y-2">
    <.skeleton class="h-4 w-full" />
    <.skeleton class="h-4 w-5/6" />
    <.skeleton class="h-4 w-4/6" />
  </.card_content>
</.card>

<%!-- Table skeleton --%>
<.table :if={@loading}>
  <.table_body>
    <.table_row :for={_ <- 1..5}>
      <.table_cell><.skeleton class="h-4 w-28" /></.table_cell>
      <.table_cell><.skeleton class="h-4 w-40" /></.table_cell>
      <.table_cell><.skeleton class="h-6 w-16 rounded-full" /></.table_cell>
      <.table_cell><.skeleton class="h-4 w-20" /></.table_cell>
    </.table_row>
  </.table_body>
</.table>
```

---

## progress

Horizontal progress bar. `role="progressbar"`, `aria-valuenow`. Set `value={nil}` for indeterminate (animated).

```heex
<%!-- Determinate --%>
<.progress value={75} max={100} aria-label="Upload progress" />
<.progress value={@step} max={@total_steps} />

<%!-- Indeterminate --%>
<.progress aria-label="Loading…" />

<%!-- File upload with label --%>
<div class="space-y-1">
  <div class="flex justify-between text-sm">
    <span>Uploading report.pdf</span>
    <span><%= @upload_percent %>%</span>
  </div>
  <.progress value={@upload_percent} max={100} />
</div>
```

---

## circular_progress

SVG circular progress ring. Shows percentage label inside.

**Attrs**: `value` (0–100), `size`, `stroke_width`, `color`

```heex
<.circular_progress value={72} />
<.circular_progress value={@disk_usage} size={120} stroke_width={8} color="text-orange-500" />
<.circular_progress value={100} color="text-green-500" />

<%!-- In a stat card --%>
<.card>
  <.card_content class="flex items-center gap-4 pt-4">
    <.circular_progress value={@completion_rate} size={80} />
    <div>
      <p class="text-2xl font-bold"><%= @completion_rate %>%</p>
      <p class="text-sm text-muted-foreground">Tasks completed</p>
    </div>
  </.card_content>
</.card>
```

---

## empty_state

Centered placeholder for empty lists, no search results, or onboarding.

**Sub-components**: use slots `:icon`, `:title`, `:description`, `:action`

```heex
<%!-- Empty list --%>
<.empty_state :if={@items == []}>
  <:icon><.icon name="inbox" class="h-12 w-12 text-muted-foreground" /></:icon>
  <:title>No items yet</:title>
  <:description>Create your first item to get started.</:description>
  <:action>
    <.button phx-click="create-item">
      <.icon name="plus" size="sm" /> Create item
    </.button>
  </:action>
</.empty_state>

<%!-- No search results --%>
<.empty_state :if={@search != "" and @results == []}>
  <:icon><.icon name="search" class="h-12 w-12 text-muted-foreground" /></:icon>
  <:title>No results for "<%= @search %>"</:title>
  <:description>Try adjusting your search or filter to find what you're looking for.</:description>
  <:action>
    <.button variant="outline" phx-click="clear-search">Clear search</.button>
  </:action>
</.empty_state>

<%!-- Error state --%>
<.empty_state>
  <:icon><.icon name="alert-triangle" class="h-12 w-12 text-destructive" /></:icon>
  <:title>Something went wrong</:title>
  <:description>We couldn't load your data. Please try again.</:description>
  <:action>
    <.button phx-click="retry-load">Try again</.button>
  </:action>
</.empty_state>
```

---

## step_tracker

Multi-step wizard progress indicator. Horizontal or vertical orientation.

**Sub-components**: `step/1` with attrs: `status` (complete/active/upcoming), `label`, `step` (number), `description`

```heex
<%!-- Horizontal (default) --%>
<.step_tracker>
  <.step status="complete" label="Account"  step={1} />
  <.step status="complete" label="Profile"  step={2} />
  <.step status="active"   label="Billing"  step={3} description="Enter payment details" />
  <.step status="upcoming" label="Confirm"  step={4} />
</.step_tracker>

<%!-- Vertical --%>
<.step_tracker orientation="vertical">
  <.step status="complete" label="Choose plan" step={1} />
  <.step status="active"   label="Payment"     step={2} description="Secure checkout" />
  <.step status="upcoming" label="Activate"    step={3} />
</.step_tracker>
```

```elixir
# LiveView with step navigation
def handle_event("next-step", _params, socket) do
  {:noreply, update(socket, :step, &min(&1 + 1, socket.assigns.total_steps))}
end

def handle_event("prev-step", _params, socket) do
  {:noreply, update(socket, :step, &max(&1 - 1, 1))}
end

defp step_status(current, step_num) do
  cond do
    step_num < current -> "complete"
    step_num == current -> "active"
    true -> "upcoming"
  end
end
```

---

## toast

`push_event`-driven toast notification. Mount once in `root.html.heex`, trigger from any LiveView.

**Hook**: `PhiaToast`
**Variants**: `default`, `success`, `destructive`, `warning`, `info`

```heex
<%!-- Mount once in root.html.heex or app.html.heex --%>
<.toast id="toast-viewport" />
```

```elixir
# Trigger from any LiveView event handler
{:noreply, push_event(socket, "phia-toast", %{
  title: "Saved",
  description: "Your changes have been saved successfully.",
  variant: "success",
  duration_ms: 4000
})}

# Error toast
{:noreply, push_event(socket, "phia-toast", %{
  title: "Error",
  description: "Failed to save. Please try again.",
  variant: "destructive"
})}

# Simple toast (no description)
{:noreply, push_event(socket, "phia-toast", %{title: "Copied to clipboard!"})}
```

---

## snackbar

Material-style bottom-center notification. Component-controlled (not push_event). Good for undo patterns.

**Attrs**: `message`, `variant` (default/success/error/warning), `action_label`, `on_action`

```heex
<.snackbar
  :if={@snackbar_message}
  message={@snackbar_message}
  variant={@snackbar_variant}
  action_label="Undo"
  on_action="undo_delete"
/>
```

```elixir
def handle_event("delete-item", %{"id" => id}, socket) do
  MyApp.soft_delete(id)
  Process.send_after(self(), :clear_snackbar, 5000)
  {:noreply, assign(socket,
    snackbar_message: "Item deleted",
    snackbar_variant: "default",
    last_deleted_id: id
  )}
end

def handle_event("undo_delete", _params, socket) do
  MyApp.restore(socket.assigns.last_deleted_id)
  {:noreply, assign(socket, snackbar_message: nil, last_deleted_id: nil)}
end

def handle_info(:clear_snackbar, socket) do
  {:noreply, assign(socket, snackbar_message: nil)}
end
```

---

## sonner

Rich stacking toast notifications (Sonner-style). Push multiple toasts; they stack with animations.

**Hook**: `PhiaSonner`

```heex
<%!-- Mount once in root.html.heex --%>
<.sonner id="sonner-viewport" />
```

```elixir
# Types: "success", "error", "warning", "info", "default"
{:noreply, push_event(socket, "phia-sonner", %{
  message: "Post published!",
  type: "success"
})}

{:noreply, push_event(socket, "phia-sonner", %{
  message: "Build failed",
  description: "See logs for details.",
  type: "error"
})}
```

---

## popconfirm

_(new in 0.1.7)_

Inline confirmation popover that appears before a destructive action is committed. Avoids full modal dialogs for lightweight confirmations.

**Module**: `PhiaUi.Components.Feedback`
**Attrs**: `id`, `message`, `on_confirm`, `on_cancel`, `placement` (`"top"`, `"bottom"`, `"left"`, `"right"`)

```heex
<.popconfirm
  id="delete-confirm"
  message="Delete this record? This cannot be undone."
  on_confirm="delete_record"
  placement="top"
>
  <.button variant="destructive">Delete</.button>
</.popconfirm>
```

### Use Cases

- Delete row confirmation
- Archive/unarchive actions
- Disconnect confirmation

---

## result_state

_(new in 0.1.7)_

Full-page outcome display component for success, error, warning, and info states. Renders a centered icon, title, description, and action buttons.

**Module**: `PhiaUi.Components.Feedback`
**Attrs**: `type` (`"success"`, `"error"`, `"warning"`, `"info"`), `title`, `description`

```heex
<.result_state type="success" title="Payment successful!" description="Your order has been confirmed.">
  <:primary_action>
    <.button phx-click="go_home">Back to home</.button>
  </:primary_action>
  <:secondary_action>
    <.button variant="outline" phx-click="view_order">View order</.button>
  </:secondary_action>
</.result_state>
```

```heex
<.result_state type="error" title="Payment failed" description="Your card was declined.">
  <:primary_action>
    <.button phx-click="retry">Try again</.button>
  </:primary_action>
</.result_state>
```

### Use Cases

- Payment outcome pages
- Form submission confirmations
- Permission denied / 403 pages
- Empty state with action

← [Back to README](../../README.md)
