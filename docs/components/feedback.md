# Feedback

20 feedback components — alerts, banners, loading states, progress, skeletons, notifications, toasts, error displays, and confirmation patterns.

**Module**: `PhiaUi.Components.Feedback`

```elixir
import PhiaUi.Components.Feedback
```

---

## Table of Contents

**Alerts & Banners**
- [alert](#alert)
- [banner](#banner)
- [announcement_bar](#announcement_bar)
- [cookie_consent](#cookie_consent)
- [global_message](#global_message)

**Loading**
- [spinner](#spinner)
- [loading_overlay](#loading_overlay)
- [loading_dots](#loading_dots)
- [loading_bar](#loading_bar)
- [skeleton](#skeleton)

**Progress**
- [progress](#progress)
- [circular_progress](#circular_progress)
- [labeled_progress](#labeled_progress)
- [segmented_progress](#segmented_progress)
- [quota_bar](#quota_bar)
- [step_progress_bar](#step_progress_bar)

**Status**
- [status_indicator](#status_indicator)
- [connection_status](#connection_status)
- [live_indicator](#live_indicator)

**Notifications & Toasts**
- [toast](#toast)
- [snackbar](#snackbar)
- [sonner](#sonner)
- [notification](#notification)

**Error & Empty States**
- [empty_state](#empty_state)
- [result_state](#result_state)
- [error_display](#error_display)

**Confirmation**
- [popconfirm](#popconfirm)
- [step_tracker](#step_tracker)

---

## alert

Non-interactive feedback banner with variants and optional icon slot.

**Variants**: `default` · `destructive` · `warning` · `success`

```heex
<.alert variant="success">
  <:icon><.icon name="check-circle" /></:icon>
  Your changes have been saved.
</.alert>

<.alert variant="destructive">
  <:icon><.icon name="x-circle" /></:icon>
  Failed to process payment. Please try again.
</.alert>

<.alert variant="warning">
  <:icon><.icon name="alert-triangle" /></:icon>
  Your trial expires in 3 days.
  <:action><.button size="sm" variant="outline">Upgrade</.button></:action>
</.alert>

<%!-- Dismissable --%>
<.alert variant="default" phx-click="dismiss_alert" id="info-alert">
  New features are available in this version.
</.alert>
```

---

## banner

Top-of-page notification bar with optional action and dismiss button.

```heex
<.banner variant="info" phx-click="dismiss_banner">
  System maintenance scheduled for Sunday 2am–4am UTC.
  <:action><.button size="sm" variant="ghost">Learn more</.button></:action>
</.banner>
```

---

## announcement_bar

Marquee-scrolling announcement banner.

```heex
<.announcement_bar items={["Free shipping on orders over $50", "New products added weekly", "Use code SAVE20 for 20% off"]} />
```

---

## cookie_consent

GDPR-style cookie consent banner with accept/decline.

```heex
<.cookie_consent
  on_accept="accept_cookies"
  on_decline="decline_cookies"
  policy_url="/privacy"
/>
```

---

## global_message

App-level flash-style message bar. Hook: `PhiaGlobalMessage`.

```heex
<%!-- In your root layout --%>
<.global_message id="app-flash" />
```

```elixir
# Trigger from LiveView
def handle_info({:show_message, msg}, socket) do
  {:noreply, push_event(socket, "phia-global-message", %{message: msg, type: "success"})}
end
```

---

## spinner

Inline loading spinner.

```heex
<.spinner />
<.spinner size="lg" class="text-primary" />

<%!-- Inside a button --%>
<.button disabled={@loading}>
  <%= if @loading do %>
    <.spinner size="sm" class="mr-2" /> Loading…
  <% else %>
    Save
  <% end %>
</.button>
```

**Sizes**: `:sm` · `:md` (default) · `:lg`

---

## loading_overlay

Full-container overlay with spinner and optional message.

```heex
<div class="relative">
  <.loading_overlay visible={@loading} message="Loading data…" />
  <.table rows={@rows}>…</.table>
</div>
```

---

## loading_dots

Three animated dots — use for chat "typing" indicators.

```heex
<.loading_dots />
<.loading_dots size="lg" class="text-primary" />
```

---

## loading_bar

Indeterminate top-of-page loading bar (like YouTube/GitHub).

```heex
<.loading_bar visible={@page_loading} />
```

---

## skeleton

Content placeholder while data loads.

```heex
<%!-- Inline --%>
<.skeleton class="h-4 w-32 rounded" />
<.skeleton class="h-10 w-full rounded-lg" />

<%!-- Pre-built variants --%>
<.skeleton_list items={5} />    <%!-- 5 row skeletons --%>
<.skeleton_form fields={4} />   <%!-- 4 input field skeletons --%>
<.skeleton_table_row cols={4} />
<.skeleton_profile />           <%!-- Avatar + text lines --%>
```

---

## progress

Horizontal progress bar.

```heex
<.progress value={65} />
<.progress value={@percent} class="h-2 [&>div]:bg-green-500" />
```

**Attrs**: `value` (0–100), `class`

---

## circular_progress

SVG circular progress ring.

```heex
<.circular_progress value={75} size={80} stroke_width={6} />
<.circular_progress value={@cpu_usage} label="CPU" />
```

---

## labeled_progress

Progress bar with label and percentage text.

```heex
<.labeled_progress label="Storage" value={68} unit="GB used of 100GB" />
```

---

## segmented_progress

Multi-section progress bar for multi-step flows.

```heex
<.segmented_progress steps={4} current_step={2} />
```

---

## quota_bar

Stacked bar showing quota usage with colour zones.

```heex
<.quota_bar used={8.2} total={10} unit="GB" warn_at={80} danger_at={90} />
```

---

## step_progress_bar

Horizontal bar with step dots and labels.

```heex
<.step_progress_bar current={2} steps={["Details", "Address", "Payment", "Review"]} />
```

---

## status_indicator

Dot indicator with colour-coded status.

```heex
<div class="flex items-center gap-2">
  <.status_indicator status={:online} />
  <span>Alice Smith</span>
</div>
```

**Statuses**: `:online` · `:offline` · `:away` · `:busy` · `:error`

---

## connection_status

Shows LiveView socket connection state.

```heex
<.connection_status />
```

---

## live_indicator

Pulsing "LIVE" badge.

```heex
<.live_indicator />
<.live_indicator label="Broadcasting" />
```

---

## toast

Programmatic toast notification. Fire with `put_flash/3` or `push_event/3`.

```heex
<%!-- In root layout --%>
<.toast flash={@flash} />
```

```elixir
# In a LiveView event handler
def handle_event("save", _params, socket) do
  case save(socket.assigns.form) do
    {:ok, _} ->
      {:noreply, put_flash(socket, :info, "Saved successfully!")}
    {:error, _} ->
      {:noreply, put_flash(socket, :error, "Failed to save.")}
  end
end
```

---

## snackbar

Bottom-anchored notification with action button.

```heex
<.snackbar id="undo-snack" message="Item deleted" action_label="Undo" on_action="undo_delete" />
```

---

## sonner

Toast stack manager inspired by Sonner. Supports queueing multiple toasts. Hook: `PhiaSonner`.

```heex
<%!-- In root layout --%>
<.sonner id="app-toasts" position={:bottom_right} />
```

```elixir
# Trigger from LiveView
push_event(socket, "phia-sonner", %{
  type: "success",
  title: "Saved",
  description: "Your changes have been saved.",
  duration: 4000
})
```

---

## notification

Notification item in a notification list or notification_center.

```heex
<.notification_center id="notif-center">
  <%= for n <- @notifications do %>
    <.notification_item
      title={n.title}
      body={n.body}
      timestamp={n.inserted_at}
      read={n.read_at != nil}
      icon={n.icon}
      phx-click="mark_read"
      phx-value-id={n.id}
    />
  <% end %>
</.notification_center>
```

---

## empty_state

Centred placeholder for empty lists.

```heex
<.empty_state
  icon="inbox"
  title="No messages"
  description="When you receive messages, they'll appear here."
>
  <:action>
    <.button phx-click="compose">Compose message</.button>
  </:action>
</.empty_state>
```

---

## result_state

Success / error / warning full-page or section result screen.

```heex
<.result_state
  status={:success}
  title="Payment confirmed"
  description="Your order #1234 has been placed."
>
  <:action>
    <.button href="/orders">View orders</.button>
  </:action>
</.result_state>
```

**Statuses**: `:success` · `:error` · `:warning` · `:info`

---

## error_display

Formatted error message with stack trace (development mode).

```heex
<.error_display error={@error} show_trace={Mix.env() == :dev} />
```

---

## popconfirm

Inline confirm/cancel popover for destructive actions.

```heex
<.popconfirm
  id="delete-confirm"
  message="Are you sure you want to delete this record? This cannot be undone."
  on_confirm="delete_record"
  confirm_label="Yes, delete"
>
  <.button variant="destructive">Delete</.button>
</.popconfirm>
```

---

## step_tracker

Multi-step wizard tracker with icons and statuses.

```heex
<.step_tracker current={@step}>
  <:step status={:complete} icon="check">Account</:step>
  <:step status={:active} icon="user">Profile</:step>
  <:step status={:pending}>Plan</:step>
  <:step status={:pending}>Confirm</:step>
</.step_tracker>
```
