# Navigation

Application chrome: sidebar, topbar, breadcrumbs, tabs, pagination, and mobile navigation.

## Table of Contents

- [sidebar](#sidebar)
- [topbar](#topbar)
- [mobile_sidebar_toggle](#mobile_sidebar_toggle)
- [tabs](#tabs)
- [tabs_nav](#tabs_nav)
- [pagination](#pagination)
- [breadcrumb](#breadcrumb)
- [navigation_menu](#navigation_menu)
- [menubar](#menubar)
- [toolbar](#toolbar)
- [bottom_navigation](#bottom_navigation)

---

## sidebar

Fixed sidebar navigation panel. Used inside `shell/1`. Brand, nav, and footer slots.

**Sub-components**: `sidebar_item/1`
**Slots**: `:brand`, `:nav_items`, `:footer_items`

```heex
<.sidebar>
  <:brand>
    <.icon name="layers" class="h-5 w-5 text-primary" />
    <span class="font-bold">MyApp</span>
  </:brand>
  <:nav_items>
    <.sidebar_item href={~p"/dashboard"} active={@current_path == "/dashboard"}>
      <:icon><.icon name="layout-dashboard" /></:icon>
      Dashboard
    </.sidebar_item>
    <.sidebar_item href={~p"/users"} active={String.starts_with?(@current_path, "/users")}>
      <:icon><.icon name="users" /></:icon>
      Users
      <:badge>12</:badge>
    </.sidebar_item>
    <.sidebar_item href={~p"/analytics"} active={@current_path == "/analytics"}>
      <:icon><.icon name="bar-chart-2" /></:icon>
      Analytics
    </.sidebar_item>
    <.sidebar_item href={~p"/settings"} active={@current_path == "/settings"}>
      <:icon><.icon name="settings" /></:icon>
      Settings
    </.sidebar_item>
  </:nav_items>
  <:footer_items>
    <.sidebar_item href="/docs">
      <:icon><.icon name="book-open" /></:icon>
      Documentation
    </.sidebar_item>
  </:footer_items>
</.sidebar>
```

---

## topbar

Full-width application header with brand, center, and actions slots.

**Slots**: `:brand`, `:center`, `:actions`

```heex
<.topbar>
  <:brand>
    <.icon name="layers" class="h-5 w-5" />
    <span class="font-bold">MyApp</span>
  </:brand>
  <:center>
    <.input placeholder="Search…" class="w-64" />
  </:center>
  <:actions>
    <.button variant="ghost" size="icon">
      <.icon name="bell" />
    </.button>
    <.dark_mode_toggle id="topbar-theme" />
    <.dropdown_menu id="user-menu">
      <:trigger>
        <.avatar size="sm"><.avatar_fallback name={@current_user.name} /></.avatar>
      </:trigger>
      <:content>
        <.dropdown_menu_label><%= @current_user.email %></.dropdown_menu_label>
        <.dropdown_menu_separator />
        <.dropdown_menu_item navigate={~p"/settings"}>Settings</.dropdown_menu_item>
        <.dropdown_menu_item phx-click="sign-out">Sign out</.dropdown_menu_item>
      </:content>
    </.dropdown_menu>
  </:actions>
  <.mobile_sidebar_toggle />
</.topbar>
```

---

## mobile_sidebar_toggle

Hamburger button that opens the sidebar drawer on mobile. Always place inside `topbar/1`.

```heex
<%!-- Already used in the topbar example above.
     It reads mobile sidebar state from shell/1 automatically. --%>
<.mobile_sidebar_toggle />
```

---

## tabs

Server-rendered content tabs. `active` attribute controls which panel is shown. Uses `:let` context.

**Sub-components**: `tabs_list/1`, `tabs_trigger/1`, `tabs_content/1`
**Attrs**: `active` (string, matches `tab` attr on trigger/content)

```heex
<%!-- Basic tabs --%>
<.tabs active={@active_tab}>
  <:tab_list>
    <.tabs_trigger tab="overview" phx-click="change-tab" phx-value-tab="overview">
      Overview
    </.tabs_trigger>
    <.tabs_trigger tab="analytics" phx-click="change-tab" phx-value-tab="analytics">
      Analytics
    </.tabs_trigger>
    <.tabs_trigger tab="settings" phx-click="change-tab" phx-value-tab="settings">
      Settings
    </.tabs_trigger>
  </:tab_list>
  <.tabs_content tab="overview">
    <.metric_grid cols={3}>
      <.stat_card title="Revenue" value="$48k" trend="up" trend_value="+12%" />
      <.stat_card title="Users" value="2,840" trend="up" trend_value="+8%" />
      <.stat_card title="Churn" value="3.1%" trend="down" trend_value="-0.4%" />
    </.metric_grid>
  </.tabs_content>
  <.tabs_content tab="analytics">
    <.phia_chart id="tab-chart" type={:line} series={@series} labels={@labels} height="300px" />
  </.tabs_content>
  <.tabs_content tab="settings">
    <.form for={@settings_form} phx-submit="save-settings">
      <.phia_input field={@settings_form[:name]} label="Project name" />
      <.button type="submit" class="mt-4">Save</.button>
    </.form>
  </.tabs_content>
</.tabs>
```

```elixir
def mount(_params, _session, socket) do
  {:ok, assign(socket, active_tab: "overview")}
end

def handle_event("change-tab", %{"tab" => tab}, socket) do
  {:noreply, assign(socket, active_tab: tab)}
end
```

---

## tabs_nav

URL-based tab navigation bar. 3 visual variants. Use for top-level page navigation.

**Variants**: `underline`, `solid`, `pill`
**Sub-components**: `tabs_nav_item/1`

```heex
<%!-- Underline variant (default) --%>
<.tabs_nav>
  <.tabs_nav_item href={~p"/settings"} active={@current_path == "/settings"}>
    General
  </.tabs_nav_item>
  <.tabs_nav_item href={~p"/settings/security"} active={@current_path == "/settings/security"}>
    Security
  </.tabs_nav_item>
  <.tabs_nav_item href={~p"/settings/billing"} active={@current_path == "/settings/billing"}>
    Billing
  </.tabs_nav_item>
  <.tabs_nav_item href={~p"/settings/team"} active={@current_path == "/settings/team"}>
    Team
  </.tabs_nav_item>
</.tabs_nav>

<%!-- Pill variant --%>
<.tabs_nav variant="pill">
  <.tabs_nav_item href="/docs/intro" active={@page_id == "intro"}>Introduction</.tabs_nav_item>
  <.tabs_nav_item href="/docs/install" active={@page_id == "install"}>Installation</.tabs_nav_item>
  <.tabs_nav_item href="/docs/usage" active={@page_id == "usage"}>Usage</.tabs_nav_item>
</.tabs_nav>
```

---

## pagination

Server-side page navigation. Fires `phx-click` events; your LiveView controls current page.

**Sub-components**: `pagination_content/1`, `pagination_item/1`, `pagination_link/1`, `pagination_previous/1`, `pagination_next/1`, `pagination_ellipsis/1`

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

```elixir
def handle_event("paginate", %{"page" => page}, socket) do
  page = String.to_integer(page)
  {:noreply, assign(socket, page: page, rows: load_page(page, socket.assigns.per_page))}
end

defp page_range(current, total) when total <= 7, do: Enum.to_list(1..total)
defp page_range(current, total) do
  cond do
    current <= 4 -> [1, 2, 3, 4, 5, :ellipsis, total]
    current >= total - 3 -> [1, :ellipsis, total-4, total-3, total-2, total-1, total]
    true -> [1, :ellipsis, current-1, current, current+1, :ellipsis, total]
  end
end
```

---

## breadcrumb

Accessible navigation trail with `aria-current="page"` on the active item.

**Sub-components**: `breadcrumb_list/1`, `breadcrumb_item/1`, `breadcrumb_link/1`, `breadcrumb_separator/1`, `breadcrumb_page/1`, `breadcrumb_ellipsis/1`

```heex
<.breadcrumb>
  <.breadcrumb_list>
    <.breadcrumb_item>
      <.breadcrumb_link navigate={~p"/"}>Home</.breadcrumb_link>
    </.breadcrumb_item>
    <.breadcrumb_separator />
    <.breadcrumb_item>
      <.breadcrumb_link navigate={~p"/settings"}>Settings</.breadcrumb_link>
    </.breadcrumb_item>
    <.breadcrumb_separator />
    <.breadcrumb_item>
      <.breadcrumb_page>Billing</.breadcrumb_page>
    </.breadcrumb_item>
  </.breadcrumb_list>
</.breadcrumb>

<%!-- Built from a list --%>
<.breadcrumb>
  <.breadcrumb_list>
    <%= for {label, path, last?} <- @breadcrumbs do %>
      <.breadcrumb_item>
        <%= if last? do %>
          <.breadcrumb_page><%= label %></.breadcrumb_page>
        <% else %>
          <.breadcrumb_link navigate={path}><%= label %></.breadcrumb_link>
        <% end %>
      </.breadcrumb_item>
      <.breadcrumb_separator :if={not last?} />
    <% end %>
  </.breadcrumb_list>
</.breadcrumb>
```

---

## navigation_menu

Horizontal navigation with links and mega-menu dropdown content panels.

**Sub-components**: `navigation_menu_list/1`, `navigation_menu_item/1`, `navigation_menu_link/1`, `navigation_menu_trigger/1`, `navigation_menu_content/1`

```heex
<.navigation_menu>
  <.navigation_menu_list>
    <.navigation_menu_item>
      <.navigation_menu_link href="/" active={@path == "/"}>Home</.navigation_menu_link>
    </.navigation_menu_item>
    <.navigation_menu_item>
      <.navigation_menu_trigger label="Products" />
      <.navigation_menu_content>
        <ul class="grid grid-cols-2 gap-3 p-4 w-96">
          <li>
            <a href="/products/analytics" class="block p-3 rounded-md hover:bg-muted">
              <p class="font-medium text-sm">Analytics</p>
              <p class="text-xs text-muted-foreground mt-1">Real-time business insights</p>
            </a>
          </li>
          <li>
            <a href="/products/crm" class="block p-3 rounded-md hover:bg-muted">
              <p class="font-medium text-sm">CRM</p>
              <p class="text-xs text-muted-foreground mt-1">Customer relationship management</p>
            </a>
          </li>
        </ul>
      </.navigation_menu_content>
    </.navigation_menu_item>
    <.navigation_menu_item>
      <.navigation_menu_link href="/pricing" active={@path == "/pricing"}>Pricing</.navigation_menu_link>
    </.navigation_menu_item>
  </.navigation_menu_list>
</.navigation_menu>
```

---

## menubar

Desktop application-style menu bar with keyboard navigation.

**Sub-components**: `menubar_menu/1`, `menubar_trigger/1`, `menubar_content/1`, `menubar_item/1`, `menubar_separator/1`, `menubar_label/1`

```heex
<.menubar>
  <.menubar_menu>
    <.menubar_trigger>File</.menubar_trigger>
    <.menubar_content>
      <.menubar_item phx-click="new-document">New Document</.menubar_item>
      <.menubar_item phx-click="open-document">Open…</.menubar_item>
      <.menubar_separator />
      <.menubar_item phx-click="save">Save <.kbd>⌘S</.kbd></.menubar_item>
      <.menubar_item phx-click="save-as">Save As… <.kbd>⇧⌘S</.kbd></.menubar_item>
    </.menubar_content>
  </.menubar_menu>
  <.menubar_menu>
    <.menubar_trigger>Edit</.menubar_trigger>
    <.menubar_content>
      <.menubar_item phx-click="undo">Undo <.kbd>⌘Z</.kbd></.menubar_item>
      <.menubar_item phx-click="redo">Redo <.kbd>⇧⌘Z</.kbd></.menubar_item>
      <.menubar_separator />
      <.menubar_item phx-click="find">Find <.kbd>⌘F</.kbd></.menubar_item>
    </.menubar_content>
  </.menubar_menu>
</.menubar>
```

---

## toolbar

Horizontal action toolbar for top of content areas. `role="toolbar"` with keyboard navigation.

**Sub-components**: `toolbar_group/1`, `toolbar_separator/1`, `toolbar_toggle/1`, `toolbar_button/1`

```heex
<.toolbar aria-label="Text formatting">
  <.toolbar_group>
    <.toolbar_toggle :for={fmt <- ["bold", "italic", "underline"]}
      pressed={fmt in @active_formats}
      phx-click="toggle-format"
      phx-value-format={fmt}
    >
      <.icon name={fmt} size="sm" />
    </.toolbar_toggle>
  </.toolbar_group>
  <.toolbar_separator />
  <.toolbar_group>
    <.toolbar_toggle pressed={@align == "left"} phx-click="set-align" phx-value-align="left">
      <.icon name="align-left" size="sm" />
    </.toolbar_toggle>
    <.toolbar_toggle pressed={@align == "center"} phx-click="set-align" phx-value-align="center">
      <.icon name="align-center" size="sm" />
    </.toolbar_toggle>
    <.toolbar_toggle pressed={@align == "right"} phx-click="set-align" phx-value-align="right">
      <.icon name="align-right" size="sm" />
    </.toolbar_toggle>
  </.toolbar_group>
</.toolbar>
```

---

## bottom_navigation

Mobile fixed bottom navigation bar. Use on small screens as an alternative to a sidebar.

**Sub-components**: `bottom_nav_item/1`
**Attrs**: `href`, `active` (bool), `label`

```heex
<.bottom_navigation>
  <.bottom_nav_item href={~p"/"} active={@current_path == "/"} label="Home">
    <.icon name="home" />
  </.bottom_nav_item>
  <.bottom_nav_item href={~p"/search"} active={@current_path == "/search"} label="Search">
    <.icon name="search" />
  </.bottom_nav_item>
  <.bottom_nav_item href={~p"/notifications"} active={@current_path == "/notifications"} label="Alerts">
    <.icon name="bell" />
  </.bottom_nav_item>
  <.bottom_nav_item href={~p"/profile"} active={@current_path == "/profile"} label="Profile">
    <.icon name="user" />
  </.bottom_nav_item>
</.bottom_navigation>
```

> **Tip:** Combine `bottom_navigation` with `shell/1` for responsive layouts — show `sidebar` on desktop and `bottom_navigation` on mobile using Tailwind's `md:hidden` / `hidden md:block` classes.

← [Back to README](../../README.md)
