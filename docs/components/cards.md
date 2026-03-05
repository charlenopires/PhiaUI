# Cards

Structured surface components for content grouping, KPI metrics, financial receipts, and selectable items.

## Table of Contents

- [card](#card)
- [stat_card](#stat_card)
- [metric_grid](#metric_grid)
- [receipt_card](#receipt_card)
- [selectable_card](#selectable_card)

---

## card

The base composable card. Use `card_header`, `card_content`, and `card_footer` to build any card layout.

**Sub-components**: `card_header/1`, `card_title/1`, `card_description/1`, `card_content/1`, `card_footer/1`

```heex
<%!-- Basic information card --%>
<.card>
  <.card_header>
    <.card_title>Team Members</.card_title>
    <.card_description>Manage your workspace members.</.card_description>
  </.card_header>
  <.card_content>
    <.avatar_group :for={user <- @team} max={5}>
      <.avatar><.avatar_fallback name={user.name} /></.avatar>
    </.avatar_group>
  </.card_content>
  <.card_footer class="flex justify-between items-center">
    <span class="text-sm text-muted-foreground"><%= length(@team) %> members</span>
    <.button variant="outline" size="sm" phx-click="invite">Invite</.button>
  </.card_footer>
</.card>

<%!-- Media card (horizontal layout) --%>
<.card class="flex flex-row overflow-hidden">
  <img src={@cover_url} class="w-32 object-cover shrink-0" alt={@title} />
  <div class="flex flex-col flex-1">
    <.card_header>
      <.card_title><%= @title %></.card_title>
    </.card_header>
    <.card_content>
      <p class="text-sm text-muted-foreground line-clamp-2"><%= @excerpt %></p>
    </.card_content>
  </div>
</.card>

<%!-- Settings card --%>
<.card>
  <.card_header>
    <.card_title>Email Notifications</.card_title>
    <.card_description>Choose what you receive in your inbox.</.card_description>
  </.card_header>
  <.card_content class="space-y-4">
    <div class="flex items-center justify-between">
      <div>
        <p class="text-sm font-medium">Marketing emails</p>
        <p class="text-xs text-muted-foreground">Promotions and offers</p>
      </div>
      <.form_switch field={@form[:marketing_emails]} />
    </div>
    <.separator />
    <div class="flex items-center justify-between">
      <div>
        <p class="text-sm font-medium">Security alerts</p>
        <p class="text-xs text-muted-foreground">Login attempts and changes</p>
      </div>
      <.form_switch field={@form[:security_alerts]} />
    </div>
  </.card_content>
  <.card_footer>
    <.button phx-click="save-notifications">Save preferences</.button>
  </.card_footer>
</.card>

<%!-- Pricing card --%>
<.card class={if @plan == "pro", do: "border-primary ring-2 ring-primary", else: ""}>
  <.card_header>
    <.card_title>Pro</.card_title>
    <.card_description>For growing teams</.card_description>
  </.card_header>
  <.card_content>
    <p class="text-4xl font-bold">$49<span class="text-base font-normal text-muted-foreground">/mo</span></p>
    <ul class="mt-4 space-y-2 text-sm">
      <li class="flex items-center gap-2"><.icon name="check" size="sm" class="text-green-500" /> Unlimited projects</li>
      <li class="flex items-center gap-2"><.icon name="check" size="sm" class="text-green-500" /> Priority support</li>
      <li class="flex items-center gap-2"><.icon name="check" size="sm" class="text-green-500" /> Advanced analytics</li>
    </ul>
  </.card_content>
  <.card_footer>
    <.button class="w-full" phx-click="subscribe" phx-value-plan="pro">Get started</.button>
  </.card_footer>
</.card>
```

---

## stat_card

KPI metric card with title, primary value, trend direction, and optional sparkline slot.

**Attrs**: `title`, `value`, `trend` (up/down/neutral), `trend_value`, `description`, `icon`

```heex
<%!-- Basic KPI cards --%>
<.stat_card
  title="Monthly Revenue"
  value="$48,290"
  trend="up"
  trend_value="+12.5%"
  description="vs. last month"
/>

<.stat_card
  title="Active Users"
  value="2,840"
  trend="up"
  trend_value="+8.2%"
/>

<.stat_card
  title="Churn Rate"
  value="3.1%"
  trend="down"
  trend_value="-0.4%"
  description="30-day rolling"
/>

<.stat_card
  title="NPS Score"
  value="67"
  trend="neutral"
  trend_value="No change"
/>

<%!-- With icon --%>
<.stat_card
  title="Open Tickets"
  value="142"
  trend="up"
  trend_value="+23"
  icon="ticket"
/>
```

### Trend color convention

| `trend` value | Color |
|---------------|-------|
| `"up"` | Green (positive by default; use `trend_positive={false}` for metrics where up is bad) |
| `"down"` | Red |
| `"neutral"` | Muted gray |

---

## metric_grid

Responsive CSS Grid wrapper for `stat_card` components. Supports 1–4 columns with mobile-first breakpoints.

```heex
<%!-- 4-column KPI row --%>
<.metric_grid cols={4}>
  <.stat_card title="MRR"   value="$48,290" trend="up"      trend_value="+12.5%" />
  <.stat_card title="Users" value="2,840"   trend="up"      trend_value="+8.2%" />
  <.stat_card title="Churn" value="3.1%"    trend="down"    trend_value="-0.4%" />
  <.stat_card title="NPS"   value="67"      trend="neutral" trend_value="—" />
</.metric_grid>

<%!-- 3-column for dashboards with wider cards --%>
<.metric_grid cols={3}>
  <.stat_card title="Revenue" value="$124k" trend="up" trend_value="+18%" />
  <.stat_card title="Orders"  value="1,293" trend="up" trend_value="+4%" />
  <.stat_card title="Refunds" value="23"    trend="down" trend_value="+2" />
</.metric_grid>

<%!-- 2-column for narrow layouts --%>
<.metric_grid cols={2}>
  <.stat_card title="Uptime" value="99.98%" trend="up" trend_value="+0.01%" />
  <.stat_card title="Latency (p99)" value="142ms" trend="down" trend_value="+8ms" />
</.metric_grid>
```

---

## receipt_card

Receipt/invoice layout card. Sub-components: `receipt_row/1` for line items, `receipt_divider/1`, and `receipt_total/1`.

```heex
<.receipt_card>
  <.card_header>
    <.card_title>Order #38291</.card_title>
    <.card_description>March 5, 2026 · 14:32</.card_description>
  </.card_header>
  <.card_content>
    <.receipt_row label="PhiaUI Pro (1 year)" value="$149.00" />
    <.receipt_row label="Team add-on (5 seats)" value="$49.00" />
    <.receipt_row label="Discount (LAUNCH20)" value="-$39.60" class="text-green-600" />
    <.receipt_divider />
    <.receipt_row label="Subtotal" value="$158.40" />
    <.receipt_row label="Tax (8%)" value="$12.67" />
    <.receipt_divider />
    <.receipt_total label="Total" value="$171.07" />
  </.card_content>
  <.card_footer class="flex justify-between">
    <.button variant="outline" size="sm" phx-click="download-receipt">
      <.icon name="download" size="sm" /> PDF
    </.button>
    <.button variant="ghost" size="sm" phx-click="email-receipt">
      <.icon name="mail" size="sm" /> Email
    </.button>
  </.card_footer>
</.receipt_card>
```

---

## selectable_card

A card with a selection state (checkbox-style ring highlight). Use for service selection, plan pickers, and preference grids.

**Attrs**: `id`, `selected` (bool), `on_select` (event name), `value`

```heex
<%!-- Service type selection --%>
<div class="grid grid-cols-3 gap-4">
  <.selectable_card
    :for={service <- @services}
    id={"service-#{service.id}"}
    selected={@selected_service == service.id}
    on_select="select-service"
    value={service.id}
  >
    <.icon name={service.icon} class="h-8 w-8 text-primary mb-2" />
    <p class="font-medium"><%= service.name %></p>
    <p class="text-xs text-muted-foreground mt-1"><%= service.description %></p>
  </.selectable_card>
</div>

<%!-- Notification preferences --%>
<div class="grid grid-cols-2 gap-3">
  <.selectable_card
    id="notif-email"
    selected={"email" in @notify_via}
    on_select="toggle-notify"
    value="email"
  >
    <.icon name="mail" class="h-6 w-6 mb-1" />
    <p class="text-sm font-medium">Email</p>
  </.selectable_card>
  <.selectable_card
    id="notif-sms"
    selected={"sms" in @notify_via}
    on_select="toggle-notify"
    value="sms"
  >
    <.icon name="message-square" class="h-6 w-6 mb-1" />
    <p class="text-sm font-medium">SMS</p>
  </.selectable_card>
</div>
```

```elixir
def handle_event("select-service", %{"value" => id}, socket) do
  {:noreply, assign(socket, selected_service: id)}
end

def handle_event("toggle-notify", %{"value" => channel}, socket) do
  channels = socket.assigns.notify_via
  updated = if channel in channels, do: List.delete(channels, channel), else: [channel | channels]
  {:noreply, assign(socket, notify_via: updated)}
end
```

← [Back to README](../../README.md)
