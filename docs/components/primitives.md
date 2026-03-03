# Primitive Components

Stateless HEEx components. No JavaScript. Composable sub-component anatomy following shadcn/ui.

- [Button](#button)
- [Card](#card)
- [Badge](#badge)
- [Icon](#icon)
- [Alert](#alert)
- [Skeleton](#skeleton)
- [Breadcrumb](#breadcrumb)
- [Pagination](#pagination)

---

## Button

6 variants × 4 sizes. Use `disabled` for pointer-events-none + opacity.

```heex
<%!-- Variants --%>
<.button>Default</.button>
<.button variant="destructive">Delete</.button>
<.button variant="outline">Outline</.button>
<.button variant="secondary">Secondary</.button>
<.button variant="ghost">Ghost</.button>
<.button variant="link">Link</.button>

<%!-- Sizes --%>
<.button size="sm">Small</.button>
<.button size="lg">Large</.button>
<.button size="icon"><.icon name="plus" /></.button>

<%!-- States --%>
<.button disabled>Disabled</.button>
<.button phx-click="save" phx-disable-with="Saving…">Save</.button>
```

### With icon

```heex
<.button variant="outline">
  <.icon name="download" size="sm" />
  Export CSV
</.button>

<.button variant="destructive">
  <.icon name="trash" size="sm" />
  Delete
</.button>
```

### Custom class via cn/1

```heex
<.button class="w-full">Full-width</.button>
<.button class="rounded-full px-6">Pill</.button>
```

---

## Card

Composable card with header, content, and footer slots.

```heex
<.card>
  <.card_header>
    <.card_title>Revenue</.card_title>
    <.card_description>Monthly recurring revenue</.card_description>
  </.card_header>
  <.card_content>
    <p class="text-3xl font-bold">$48,290</p>
    <p class="text-sm text-muted-foreground mt-1">+12.5% from last month</p>
  </.card_content>
  <.card_footer class="flex justify-between">
    <.badge variant="secondary">+12.5%</.badge>
    <.button variant="ghost" size="sm">Details</.button>
  </.card_footer>
</.card>
```

### Horizontal media card

```heex
<.card class="flex flex-row overflow-hidden">
  <img src={@cover_url} class="w-32 object-cover" />
  <div>
    <.card_header>
      <.card_title><%= @title %></.card_title>
    </.card_header>
    <.card_content>
      <p class="text-sm text-muted-foreground"><%= @excerpt %></p>
    </.card_content>
  </div>
</.card>
```

### Settings card pattern

```heex
<.card>
  <.card_header>
    <.card_title>Notifications</.card_title>
    <.card_description>Choose how you receive alerts.</.card_description>
  </.card_header>
  <.card_content class="space-y-4">
    <%!-- settings rows --%>
  </.card_content>
  <.card_footer>
    <.button phx-click="save-notifications">Save</.button>
  </.card_footer>
</.card>
```

---

## Badge

Status labels and category tags.

```heex
<%!-- Variants --%>
<.badge>Default</.badge>
<.badge variant="secondary">Secondary</.badge>
<.badge variant="destructive">Error</.badge>
<.badge variant="outline">Outline</.badge>
```

### Status badges in a table

```heex
<.table_cell>
  <.badge variant={status_variant(@order.status)}>
    <%= @order.status %>
  </.badge>
</.table_cell>
```

```elixir
defp status_variant("active"), do: "default"
defp status_variant("inactive"), do: "secondary"
defp status_variant("error"), do: "destructive"
defp status_variant(_), do: "outline"
```

---

## Icon

Lucide icon sprite, 4 sizes. Generate the sprite with `mix phia.icons`.

```heex
<.icon name="check" />
<.icon name="alert-triangle" size="lg" class="text-destructive" />
<.icon name="loader" size="sm" class="animate-spin" />
```

| Size atom | CSS class | Pixels |
|-----------|-----------|--------|
| `:xs` | `h-3 w-3` | 12px |
| `:sm` | `h-4 w-4` | 16px |
| `:md` (default) | `h-5 w-5` | 20px |
| `:lg` | `h-6 w-6` | 24px |

### Common icon names

```heex
<.icon name="home" />
<.icon name="settings" />
<.icon name="user" />
<.icon name="log-out" />
<.icon name="search" />
<.icon name="plus" />
<.icon name="trash" />
<.icon name="pencil" />
<.icon name="chevron-right" />
<.icon name="chevron-down" />
<.icon name="x" />
<.icon name="check" />
<.icon name="arrow-up-right" />
<.icon name="trending-up" />
<.icon name="bar-chart-2" />
```

---

## Alert

Non-interactive feedback banners with an optional icon slot. Pure HEEx, no JS.

```heex
<%!-- Variants --%>
<.alert>
  <.alert_title>Heads up!</.alert_title>
  <.alert_description>Your trial expires in 3 days.</.alert_description>
</.alert>

<.alert variant="destructive">
  <:icon><.icon name="alert-circle" /></:icon>
  <.alert_title>Error</.alert_title>
  <.alert_description>Failed to process payment. Please try again.</.alert_description>
</.alert>

<.alert variant="warning">
  <:icon><.icon name="alert-triangle" /></:icon>
  <.alert_title>Storage limit</.alert_title>
  <.alert_description>You've used 90% of your quota.</.alert_description>
</.alert>

<.alert variant="success">
  <:icon><.icon name="check-circle" /></:icon>
  <.alert_title>Published</.alert_title>
  <.alert_description>Your post is now live.</.alert_description>
</.alert>
```

### Conditional rendering in LiveView

```heex
<.alert :if={@flash["error"]} variant="destructive">
  <.alert_title>Error</.alert_title>
  <.alert_description><%= @flash["error"] %></.alert_description>
</.alert>
```

---

## Skeleton

Animated loading placeholders using Tailwind's `animate-pulse`. Pure CSS, no JS.

```heex
<%!-- Basic skeleton shapes --%>
<.skeleton class="h-4 w-48" />
<.skeleton class="h-10 w-10 rounded-full" />
<.skeleton class="h-24 w-full rounded-md" />
```

### Skeleton card (composed)

```heex
<.skeleton_card />

<%!-- Or build your own: --%>
<.card>
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
```

### Skeleton table

```heex
<.table>
  <.table_body>
    <.table_row :for={_ <- 1..5}>
      <.table_cell><.skeleton class="h-4 w-28" /></.table_cell>
      <.table_cell><.skeleton class="h-4 w-20" /></.table_cell>
      <.table_cell><.skeleton class="h-6 w-16 rounded-full" /></.table_cell>
    </.table_row>
  </.table_body>
</.table>
```

### Loading state pattern in LiveView

```heex
<%= if @loading do %>
  <.skeleton_card />
<% else %>
  <.card>
    <%!-- real content --%>
  </.card>
<% end %>
```

---

## Breadcrumb

Accessible navigation trail with `aria-current="page"` on the active item.

```heex
<.breadcrumb>
  <.breadcrumb_list>
    <.breadcrumb_item>
      <.breadcrumb_link href="/">Home</.breadcrumb_link>
    </.breadcrumb_item>
    <.breadcrumb_separator />
    <.breadcrumb_item>
      <.breadcrumb_link href="/settings">Settings</.breadcrumb_link>
    </.breadcrumb_item>
    <.breadcrumb_separator />
    <.breadcrumb_item>
      <.breadcrumb_page>Profile</.breadcrumb_page>
    </.breadcrumb_item>
  </.breadcrumb_list>
</.breadcrumb>
```

### With custom separator

```heex
<.breadcrumb>
  <.breadcrumb_list>
    <.breadcrumb_item>
      <.breadcrumb_link navigate={~p"/"}>Home</.breadcrumb_link>
    </.breadcrumb_item>
    <.breadcrumb_separator>
      <.icon name="chevron-right" size="sm" />
    </.breadcrumb_separator>
    <.breadcrumb_item>
      <.breadcrumb_page>Current page</.breadcrumb_page>
    </.breadcrumb_item>
  </.breadcrumb_list>
</.breadcrumb>
```

### With ellipsis for long paths

```heex
<.breadcrumb>
  <.breadcrumb_list>
    <.breadcrumb_item>
      <.breadcrumb_link href="/">Home</.breadcrumb_link>
    </.breadcrumb_item>
    <.breadcrumb_separator />
    <.breadcrumb_item>
      <.breadcrumb_ellipsis />
    </.breadcrumb_item>
    <.breadcrumb_separator />
    <.breadcrumb_item>
      <.breadcrumb_page>Current</.breadcrumb_page>
    </.breadcrumb_item>
  </.breadcrumb_list>
</.breadcrumb>
```

### Building from a list in LiveView

```heex
<.breadcrumb>
  <.breadcrumb_list>
    <%= for {label, url, last?} <- breadcrumb_items(@path) do %>
      <.breadcrumb_item>
        <%= if last? do %>
          <.breadcrumb_page><%= label %></.breadcrumb_page>
        <% else %>
          <.breadcrumb_link href={url}><%= label %></.breadcrumb_link>
        <% end %>
      </.breadcrumb_item>
      <.breadcrumb_separator :if={not last?} />
    <% end %>
  </.breadcrumb_list>
</.breadcrumb>
```

---

## Pagination

Server-side pagination navigation. Fires `phx-click` events; your LiveView controls the current page.

```heex
<.pagination>
  <.pagination_content>
    <.pagination_item>
      <.pagination_previous on_change="paginate" current_page={@page} />
    </.pagination_item>

    <.pagination_item :for={n <- page_range(@page, @total_pages)}>
      <%= if n == :ellipsis do %>
        <.pagination_ellipsis />
      <% else %>
        <.pagination_link on_change="paginate" page={n} current_page={@page}>
          <%= n %>
        </.pagination_link>
      <% end %>
    </.pagination_item>

    <.pagination_item>
      <.pagination_next on_change="paginate" current_page={@page} total_pages={@total_pages} />
    </.pagination_item>
  </.pagination_content>
</.pagination>
```

### LiveView handler

```elixir
def handle_event("paginate", %{"page" => page}, socket) do
  page = String.to_integer(page)
  {:noreply, assign(socket, page: page, rows: load_page(page))}
end
```

### Page range helper

```elixir
defp page_range(current, total) when total <= 7 do
  Enum.to_list(1..total)
end
defp page_range(current, total) do
  cond do
    current <= 4 -> [1, 2, 3, 4, 5, :ellipsis, total]
    current >= total - 3 -> [1, :ellipsis, total-4, total-3, total-2, total-1, total]
    true -> [1, :ellipsis, current-1, current, current+1, :ellipsis, total]
  end
end
```

---

← [Back to README](../../README.md)
