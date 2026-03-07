# Navigation

33 navigation components — sidebar, topbar, breadcrumbs, tabs, pagination, command palette, table of contents, and mobile navigation patterns.

**Module**: `PhiaUi.Components.Navigation`

```elixir
import PhiaUi.Components.Navigation
```

---

## Table of Contents

**App Shell**
- [sidebar](#sidebar) / [topbar](#topbar) / [shell](#shell)
- [mobile_sidebar_toggle](#mobile_sidebar_toggle)
- [app_shell](#app_shell)

**Primary Navigation**
- [navigation_menu](#navigation_menu)
- [mega_menu](#mega_menu)
- [menubar](#menubar)
- [vertical_nav](#vertical_nav)
- [nav_link](#nav_link)
- [nav_list](#nav_list)

**Tabs**
- [tabs](#tabs)
- [tabs_nav](#tabs_nav)

**Breadcrumbs & Steps**
- [breadcrumb](#breadcrumb)
- [stepper_nav](#stepper_nav)

**Pagination**
- [pagination](#pagination)
- [cursor_pagination](#cursor_pagination)
- [load_more](#load_more)

**Contextual Navigation (v0.1.10)**
- [command_palette](#command_palette)
- [toc](#toc) — Table of Contents
- [back_to_top](#back_to_top)
- [page_progress](#page_progress)
- [link_group](#link_group)
- [context_nav](#context_nav)
- [nav_rail](#nav_rail)

**Mobile & Overlay Nav**
- [bottom_navigation](#bottom_navigation)
- [chip_nav](#chip_nav)
- [dot_navigation](#dot_navigation)
- [floating_nav](#floating_nav)
- [dock](#dock)
- [speed_dial](#speed_dial)
- [toolbar](#toolbar)
- [action_sheet](#action_sheet)

---

## sidebar

Fixed sidebar navigation panel. Collapsible. Use inside `shell/1`.

```heex
<.shell>
  <:sidebar>
    <.sidebar>
      <:brand>
        <div class="flex items-center gap-2 px-4 py-3">
          <img src="/logo.svg" class="h-6 w-6" alt="Logo" />
          <span class="font-semibold">MyApp</span>
        </div>
      </:brand>

      <:nav_items>
        <.sidebar_item icon="home" href="/" active={@active == :home}>Dashboard</.sidebar_item>
        <.sidebar_item icon="users" href="/users" active={@active == :users}>Users</.sidebar_item>
        <.sidebar_item icon="bar-chart-2" href="/analytics" active={@active == :analytics}>Analytics</.sidebar_item>
        <.sidebar_item icon="settings" href="/settings" active={@active == :settings}>Settings</.sidebar_item>
      </:nav_items>

      <:footer_items>
        <.sidebar_item icon="help-circle" href="/help">Help</.sidebar_item>
        <.sidebar_item icon="log-out" phx-click="logout">Sign out</.sidebar_item>
      </:footer_items>
    </.sidebar>
  </:sidebar>

  <:main>
    <%= @inner_content %>
  </:main>
</.shell>
```

---

## topbar

Sticky top bar with logo, search, actions, and user menu slots.

```heex
<.topbar>
  <:left>
    <.mobile_sidebar_toggle target="main-sidebar" />
    <.inline_search phx-change="search" />
  </:left>
  <:right>
    <.dark_mode_toggle />
    <.badge_button count={@notifications} phx-click="open_notifications">
      <.icon name="bell" />
    </.badge_button>
    <.avatar size="sm">
      <.avatar_image src={@user.avatar_url} />
      <.avatar_fallback name={@user.name} />
    </.avatar>
  </:right>
</.topbar>
```

---

## tabs

Content tabs with URL or state-driven active panel.

**Variants**: `:underline` · `:solid` · `:pill` · `:scrollable`

```heex
<.tabs active={@tab} on_change="set_tab">
  <:tab value="overview">Overview</:tab>
  <:tab value="activity">Activity</:tab>
  <:tab value="settings">Settings</:tab>

  <:panel value="overview">
    <.overview_panel />
  </:panel>
  <:panel value="activity">
    <.activity_list />
  </:panel>
  <:panel value="settings">
    <.settings_form />
  </:panel>
</.tabs>
```

```heex
<%!-- Pill variant --%>
<.tabs active={@tab} on_change="set_tab" variant={:pill}>
  <:tab value="all">All</:tab>
  <:tab value="active">Active</:tab>
  <:tab value="archived">Archived</:tab>
</.tabs>
```

---

## tabs_nav

Standalone tab navigation bar — use when the tab panels are managed separately.

```heex
<.tabs_nav active={@tab} on_change="set_tab" variant={:underline}>
  <:tab value="profile">Profile</:tab>
  <:tab value="security">Security</:tab>
  <:tab value="billing">Billing</:tab>
</.tabs_nav>

<div class="mt-4">
  <%= if @tab == "profile", do: live_render(@socket, ProfileLive) %>
</div>
```

---

## breadcrumb

Accessible breadcrumb trail with separator.

```heex
<.breadcrumb>
  <:item href="/">Home</:item>
  <:item href="/products">Products</:item>
  <:item href="/products/electronics">Electronics</:item>
  <:item>MacBook Pro</:item>
</.breadcrumb>
```

---

## stepper_nav

Multi-step wizard progress indicator.

```heex
<.stepper_nav current={@step} total={4}>
  <:step label="Account" />
  <:step label="Profile" />
  <:step label="Plan" />
  <:step label="Confirm" />
</.stepper_nav>
```

**Attrs**: `current` (1-based integer), `total` (integer), `on_step` (event name for clicking completed steps)

---

## pagination

Offset-based pagination with page numbers.

```heex
<.pagination
  page={@page}
  total_pages={@total_pages}
  on_page="goto_page"
/>
```

**Attrs**: `page`, `total_pages`, `on_page` (event name), `show_edges` (boolean, show first/last buttons)

---

## cursor_pagination

Previous / Next cursor-based pagination for infinite data.

```heex
<.cursor_pagination
  previous_cursor={@prev_cursor}
  next_cursor={@next_cursor}
  on_prev="paginate_prev"
  on_next="paginate_next"
/>
```

```elixir
def handle_event("paginate_next", _params, socket) do
  {:noreply, assign(socket, data: fetch_page(socket.assigns.next_cursor))}
end
```

---

## load_more

"Load more" button for append-style pagination.

```heex
<.load_more
  loading={@loading_more}
  has_more={@has_more}
  on_load="load_more"
  label="Load more posts"
/>
```

---

## command_palette

⌘K command palette with groups, items, empty state, and keyboard navigation. Hook: `PhiaCommand`.

```heex
<.command_palette id="cmd" open={@cmd_open} on_close="close_cmd">
  <.command_palette_group label="Navigation">
    <.command_palette_item icon="home" href="/" shortcut="G H">Dashboard</.command_palette_item>
    <.command_palette_item icon="users" href="/users" shortcut="G U">Users</.command_palette_item>
  </.command_palette_group>

  <.command_palette_group label="Actions">
    <.command_palette_item icon="plus" phx-click="new_project">New Project</.command_palette_item>
    <.command_palette_item icon="upload" phx-click="import">Import data</.command_palette_item>
  </.command_palette_group>

  <.command_palette_empty>No results found.</.command_palette_empty>
</.command_palette>
```

```heex
<%!-- Trigger --%>
<.button variant="outline" phx-click="open_cmd" class="gap-2">
  <.icon name="search" size="sm" />
  Search…
  <.kbd>⌘</.kbd><.kbd>K</.kbd>
</.button>
```

---

## toc

Auto-generated table of contents with active section highlighting. Hook: `PhiaToc`.

```heex
<aside class="sticky top-20">
  <.toc id="article-toc" label="On this page">
    <.toc_item href="#introduction" depth={1}>Introduction</.toc_item>
    <.toc_item href="#installation" depth={1}>Installation</.toc_item>
    <.toc_item href="#configuration" depth={2}>Configuration</.toc_item>
    <.toc_item href="#usage" depth={1}>Usage</.toc_item>
  </.toc>
</aside>
```

The `PhiaToc` hook uses `IntersectionObserver` to set `data-toc-active` on the currently visible section's link.

---

## back_to_top

Scroll-to-top button that appears after scrolling past a threshold. Hook: `PhiaBackTop`.

```heex
<.back_to_top id="back-btn" threshold={400} />
```

---

## page_progress

Thin progress bar at the top of the page showing scroll position. Hook: `PhiaPageProgress`.

```heex
<.page_progress id="read-progress" class="fixed top-0 left-0 z-50" />
```

---

## link_group

Grouped set of links with an optional heading — common in footers and sidebars.

```heex
<.link_group>
  <.link_group_heading>Product</.link_group_heading>
  <.link_group_item href="/features">Features</.link_group_item>
  <.link_group_item href="/pricing">Pricing</.link_group_item>
  <.link_group_item href="/changelog">Changelog</.link_group_item>
</.link_group>
```

---

## context_nav

Contextual sidebar navigation for settings-style pages.

```heex
<div class="flex gap-8">
  <aside class="w-56 shrink-0">
    <.context_nav>
      <.context_nav_item href="/settings/profile" active={@section == :profile}>
        Profile
      </.context_nav_item>
      <.context_nav_item href="/settings/security" active={@section == :security}>
        Security
      </.context_nav_item>
      <.context_nav_item href="/settings/billing" active={@section == :billing}>
        Billing
      </.context_nav_item>
    </.context_nav>
  </aside>
  <main class="flex-1"><%= @inner_content %></main>
</div>
```

---

## nav_rail

Compact vertical icon navigation (Material-style).

```heex
<.nav_rail>
  <.nav_rail_item icon="home" href="/" label="Home" active={@active == :home} />
  <.nav_rail_item icon="search" href="/search" label="Search" active={@active == :search} />
  <.nav_rail_item icon="bell" href="/notifications" label="Alerts" badge={@unread} />
  <.nav_rail_item icon="settings" href="/settings" label="Settings" />
</.nav_rail>
```

---

## bottom_navigation

Mobile bottom tab bar (iOS/Android style).

```heex
<.bottom_navigation active={@tab} on_change="set_tab">
  <:item value="home" icon="home" label="Home" />
  <:item value="search" icon="search" label="Search" />
  <:item value="inbox" icon="inbox" label="Inbox" badge={@unread} />
  <:item value="profile" icon="user" label="Profile" />
</.bottom_navigation>
```

---

## chip_nav

Horizontally scrollable filter chip navigation row.

```heex
<.chip_nav active={@category} on_change="set_category">
  <:item value="all">All</:item>
  <:item value="design">Design</:item>
  <:item value="engineering">Engineering</:item>
  <:item value="product">Product</:item>
</.chip_nav>
```

---

## floating_nav

Floating pill navigation bar — centered at the bottom of the viewport.

```heex
<.floating_nav active={@page}>
  <.floating_nav_item href="/" icon="home" label="Home" />
  <.floating_nav_item href="/explore" icon="compass" label="Explore" />
  <.floating_nav_item href="/create" icon="plus-circle" label="Create" />
  <.floating_nav_item href="/profile" icon="user" label="Profile" />
</.floating_nav>
```

---

## speed_dial

Floating action button that expands into multiple options.

```heex
<.speed_dial icon="plus" position={:bottom_right} label="New">
  <:action icon="file-text" phx-click="new_doc" label="Document" />
  <:action icon="image" phx-click="new_image" label="Image" />
  <:action icon="folder" phx-click="new_folder" label="Folder" />
</.speed_dial>
```
