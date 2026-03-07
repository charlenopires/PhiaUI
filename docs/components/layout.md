# Layout

Structural composition components: dashboard shell, collapsible regions, resizable panels, scroll areas, dividers, and 20 layout primitive components added in v0.1.5.

## Table of Contents

### Interactive Layout

- [shell](#shell)
- [accordion](#accordion)
- [collapsible](#collapsible)
- [resizable](#resizable)
- [scroll_area](#scroll_area)
- [separator](#separator)
- [aspect_ratio](#aspect_ratio)

### Layout Primitives (new in 0.1.5)

- [box](#box)
- [spacer](#spacer)
- [center](#center)
- [section](#section)
- [sticky](#sticky)
- [fixed_bar](#fixed_bar)
- [flex](#flex)
- [stack](#stack)
- [wrap](#wrap)
- [grid](#grid)
- [simple_grid](#simple_grid)
- [container](#container)
- [divider](#divider)
- [media_object](#media_object)
- [masonry_grid](#masonry_grid)
- [description_list](#description_list)
- [page_layout](#page_layout)
- [split_layout](#split_layout)
- [page_header](#page_header)
- [nav_list](#nav_list)

---

## shell

CSS Grid desktop layout. Fixed sidebar (240px) + fluid main content (1fr). Mobile sidebar auto-closes at `md:` breakpoint.

**Slots**: `:topbar`, `:sidebar`, inner content (default slot)

```heex
<%!-- Full dashboard shell — put in a layout file --%>
<.shell>
  <:topbar>
    <.topbar>
      <:brand>
        <.icon name="layers" class="h-5 w-5" />
        <span class="font-bold text-lg">MyApp</span>
      </:brand>
      <:actions>
        <.dark_mode_toggle id="theme-toggle" />
        <.dropdown_menu id="user-menu">
          <:trigger>
            <.avatar size="sm">
              <.avatar_fallback name={@current_user.name} />
            </.avatar>
          </:trigger>
          <:content>
            <.dropdown_menu_label><%= @current_user.email %></.dropdown_menu_label>
            <.dropdown_menu_separator />
            <.dropdown_menu_item phx-click="sign-out">Sign out</.dropdown_menu_item>
          </:content>
        </.dropdown_menu>
      </:actions>
      <.mobile_sidebar_toggle />
    </.topbar>
  </:topbar>

  <:sidebar>
    <.sidebar>
      <:brand>
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
        <.sidebar_item href={~p"/help"}>
          <:icon><.icon name="help-circle" /></:icon>
          Help & Docs
        </.sidebar_item>
      </:footer_items>
    </.sidebar>
  </:sidebar>

  <main class="flex flex-col gap-6 p-6 overflow-y-auto">
    <%= @inner_content %>
  </main>
</.shell>
```

### Using shell in a Phoenix layout

```elixir
# lib/my_app_web/layouts/dashboard.html.heex
<.shell>
  <:topbar>…</:topbar>
  <:sidebar>…</:sidebar>
  <%= @inner_content %>
</.shell>
```

```elixir
# lib/my_app_web/live/dashboard_live.ex
use MyAppWeb, :live_view

@impl true
def mount(_params, _session, socket) do
  {:ok, assign(socket, current_path: "/dashboard")}
end
```

---

## accordion

Single or multiple expand mode. Uses `Phoenix.LiveView.JS` — no custom hook required.

**Sub-components**: `accordion_item/1`, `accordion_trigger/1`, `accordion_content/1`
**Modes**: `type="single"` (default), `type="multiple"`

```heex
<%!-- Single open at a time (FAQ pattern) --%>
<.accordion type="single" class="w-full">
  <.accordion_item value="item-1">
    <.accordion_trigger>Is PhiaUI free to use?</.accordion_trigger>
    <.accordion_content>
      Yes. PhiaUI is MIT licensed. You can use it in any project.
    </.accordion_content>
  </.accordion_item>
  <.accordion_item value="item-2">
    <.accordion_trigger>Do I need to install npm packages?</.accordion_trigger>
    <.accordion_content>
      No. All JS hooks are vanilla JavaScript. No npm runtime dependencies.
    </.accordion_content>
  </.accordion_item>
  <.accordion_item value="item-3">
    <.accordion_trigger>Can I customize the components?</.accordion_trigger>
    <.accordion_content>
      Absolutely. Components are ejected to your project — you own the code.
    </.accordion_content>
  </.accordion_item>
</.accordion>

<%!-- Multiple open at once (settings panel) --%>
<.accordion type="multiple">
  <.accordion_item value="profile">
    <.accordion_trigger>Profile Settings</.accordion_trigger>
    <.accordion_content class="space-y-4">
      <.phia_input field={@form[:name]} label="Full name" />
      <.phia_input field={@form[:bio]} label="Bio" />
    </.accordion_content>
  </.accordion_item>
  <.accordion_item value="security">
    <.accordion_trigger>Security</.accordion_trigger>
    <.accordion_content class="space-y-4">
      <.phia_input field={@form[:current_password]} type="password" label="Current password" />
      <.phia_input field={@form[:new_password]} type="password" label="New password" />
    </.accordion_content>
  </.accordion_item>
</.accordion>
```

---

## collapsible

Single-panel show/hide. Server-controlled open state via `Phoenix.LiveView.JS`.

**Sub-components**: `collapsible_trigger/1`, `collapsible_content/1`

```heex
<.collapsible open={@show_advanced} on_open_change="toggle-advanced">
  <.collapsible_trigger class="flex items-center justify-between w-full">
    <span class="text-sm font-medium">Advanced options</span>
    <.icon name={if @show_advanced, do: "chevron-up", else: "chevron-down"} size="sm" />
  </.collapsible_trigger>
  <.collapsible_content class="space-y-4 mt-4">
    <.phia_input field={@form[:timeout]} label="Timeout (ms)" type="number" />
    <.phia_input field={@form[:retry_count]} label="Retry count" type="number" />
  </.collapsible_content>
</.collapsible>
```

```elixir
def handle_event("toggle-advanced", _params, socket) do
  {:noreply, update(socket, :show_advanced, &(!&1))}
end
```

---

## resizable

Drag-to-resize split panels. Uses `PhiaResizable` hook.

**Sub-components**: `resizable_panel_group/1`, `resizable_panel/1`, `resizable_handle/1`

**Hook**: `PhiaResizable`

```heex
<%!-- Horizontal split (code editor style) --%>
<.resizable_panel_group id="editor" direction="horizontal" class="h-[500px] border rounded-lg">
  <.resizable_panel default_size={30} min_size={20}>
    <div class="h-full p-4 overflow-y-auto">
      <h3 class="font-medium mb-2">File Explorer</h3>
      <.tree>
        <%!-- file tree items --%>
      </.tree>
    </div>
  </.resizable_panel>
  <.resizable_handle />
  <.resizable_panel>
    <div class="h-full p-4">
      <.rich_text_editor field={@form[:code]} />
    </div>
  </.resizable_panel>
</.resizable_panel_group>

<%!-- Vertical split --%>
<.resizable_panel_group id="preview" direction="vertical" class="h-[600px]">
  <.resizable_panel default_size={60}>
    <div class="h-full p-4"><.rich_text_editor field={@form[:content]} /></div>
  </.resizable_panel>
  <.resizable_handle />
  <.resizable_panel>
    <div class="h-full p-4 prose"><%= raw @preview_html %></div>
  </.resizable_panel>
</.resizable_panel_group>
```

---

## scroll_area

Custom scrollbar overlay for fixed-height containers.

**Attrs**: `orientation` (vertical/horizontal/both)

```heex
<%!-- Fixed-height list --%>
<.scroll_area class="h-[300px] rounded-md border">
  <div class="p-4 space-y-4">
    <div :for={item <- @long_list} class="flex items-center gap-3">
      <.avatar size="sm"><.avatar_fallback name={item.name} /></.avatar>
      <span class="text-sm"><%= item.name %></span>
    </div>
  </div>
</.scroll_area>

<%!-- Horizontal scroll for a table --%>
<.scroll_area orientation="horizontal" class="w-full">
  <.table>
    <%!-- wide table content --%>
  </.table>
</.scroll_area>
```

---

## separator

Horizontal or vertical `<hr>`-style divider with `role="separator"`.

```heex
<%!-- Horizontal (default) --%>
<.separator />
<.separator class="my-4" />

<%!-- Vertical (in a flex row) --%>
<div class="flex items-center gap-4 h-6">
  <span>Section A</span>
  <.separator orientation="vertical" />
  <span>Section B</span>
  <.separator orientation="vertical" />
  <span>Section C</span>
</div>

<%!-- With label --%>
<div class="relative">
  <.separator />
  <span class="absolute left-1/2 -translate-x-1/2 -translate-y-1/2 bg-background px-2 text-xs text-muted-foreground">
    OR
  </span>
</div>
```

---

## aspect_ratio

CSS padding-top trick for responsive ratio containers.

**Attr**: `ratio` (string, e.g. `"16/9"`, `"4/3"`, `"1/1"`)

```heex
<%!-- Video embed --%>
<.aspect_ratio ratio="16/9" class="rounded-lg overflow-hidden">
  <iframe src="https://www.youtube.com/embed/..." class="w-full h-full" allow="autoplay" />
</.aspect_ratio>

<%!-- Square image grid --%>
<div class="grid grid-cols-3 gap-2">
  <.aspect_ratio :for={img <- @gallery_images} ratio="1/1" class="rounded overflow-hidden">
    <img src={img.url} alt={img.alt} class="object-cover w-full h-full" />
  </.aspect_ratio>
</div>

<%!-- Map embed --%>
<.aspect_ratio ratio="4/3" class="rounded-xl overflow-hidden border">
  <.skeleton class="w-full h-full" />
</.aspect_ratio>
```

---

## Layout Primitives (new in 0.1.5)

### box

Generic block container. Renders as any HTML tag via `:as` attr.

**Attrs**: `as` (default `"div"`), `class`

```heex
<.box as="section" class="p-6 bg-card rounded-lg">
  Content
</.box>
```

### spacer

Flex spacer that pushes siblings apart, or a fixed-size gap element.

**Attrs**: `size` (Tailwind spacing value, e.g. `"4"`, `"8"`)

```heex
<div class="flex">
  <span>Left</span>
  <.spacer />
  <span>Right (pushed far right)</span>
</div>
```

### center

Flex centering wrapper. Centers children horizontally or both axes.

**Attrs**: `both` (boolean, default `false`)

```heex
<.center both class="min-h-screen">
  <.card>Centered content</.card>
</.center>
```

### section

Semantic `<section>` wrapper with consistent vertical padding.

**Attrs**: `class`

```heex
<.section class="bg-muted/20">
  <.heading level={2}>Features</.heading>
</.section>
```

### sticky

`position: sticky` wrapper with configurable `top` or `bottom` offset.

**Attrs**: `top`, `bottom` (Tailwind spacing values), `class`

```heex
<.sticky top="0" class="z-10 bg-background/90 backdrop-blur">
  <.topbar />
</.sticky>
```

### fixed_bar

Fixed-position top or bottom bar for persistent UI chrome.

**Attrs**: `position` (`"top"`, `"bottom"`), `class`

```heex
<.fixed_bar position="bottom" class="border-t">
  <.button class="w-full">Save</.button>
</.fixed_bar>
```

### flex

Flex container with gap, direction, align, and justify props.

**Attrs**: `gap`, `direction` (`"row"`, `"col"`), `align`, `justify`, `wrap`, `class`

```heex
<.flex gap="4" align="center" justify="between">
  <.heading level={3}>Title</.heading>
  <.button>Action</.button>
</.flex>
```

### stack

Vertical flex stack with uniform gap. Shortcut for `flex direction="col"`.

**Attrs**: `gap` (default `"4"`), `class`

```heex
<.stack gap="6">
  <.card>Card 1</.card>
  <.card>Card 2</.card>
  <.card>Card 3</.card>
</.stack>
```

### wrap

Flex-wrap container for tag clouds, button groups, and pill rows.

**Attrs**: `gap`, `class`

```heex
<.wrap gap="2">
  <%= for tag <- @tags do %>
    <.badge>{tag}</.badge>
  <% end %>
</.wrap>
```

### grid

CSS Grid container with configurable cols, rows, and gap.

**Attrs**: `cols` (e.g. `"3"`, `"4"`), `gap`, `class`

```heex
<.grid cols="3" gap="6">
  <%= for card <- @cards do %>
    <.stat_card {card} />
  <% end %>
</.grid>
```

### simple_grid

Responsive equal-column grid using auto-fill/auto-fit.

**Attrs**: `min_col_width` (default `"200px"`), `gap`, `class`

```heex
<.simple_grid min_col_width="280px" gap="4">
  <%= for item <- @items do %>
    <.card>{item.title}</.card>
  <% end %>
</.simple_grid>
```

### container

Responsive max-width wrapper with configurable size and horizontal padding.

**Attrs**: `size` (`"sm"`, `"md"`, `"lg"`, `"xl"`, `"2xl"`, `"full"`), `class`

```heex
<.container size="lg" class="py-12">
  <.heading level={1}>Page Title</.heading>
</.container>
```

### divider

Horizontal or vertical divider with optional label text.

**Attrs**: `orientation` (`"horizontal"`, `"vertical"`), `label`, `class`

```heex
<.divider label="Or continue with" />
<.divider orientation="vertical" class="h-8 mx-4" />
```

### media_object

Horizontal image/icon + text layout pattern (email-client compatible).

**Attrs**: `class`

```heex
<.media_object>
  <:media><.avatar src={@user.avatar} size={:md} /></:media>
  <:body>
    <p class="font-medium">{@user.name}</p>
    <p class="text-sm text-muted-foreground">{@user.role}</p>
  </:body>
</.media_object>
```

### masonry_grid

CSS column-count masonry layout for unequal-height cards.

**Attrs**: `cols` (default `"3"`), `gap`, `class`

```heex
<.masonry_grid cols="4" gap="4">
  <%= for item <- @items do %>
    <div class="mb-4 break-inside-avoid">
      <.card>{item.content}</.card>
    </div>
  <% end %>
</.masonry_grid>
```

### description_list

Semantic `<dl>` with responsive term/detail layout.

**Attrs**: `class`

```heex
<.description_list>
  <:item term="Status">Active</:item>
  <:item term="Created">2026-03-07</:item>
  <:item term="Plan">Pro</:item>
</.description_list>
```

### page_layout

Two-column or three-column content/sidebar page layout.

**Attrs**: `variant` (`"sidebar-right"`, `"sidebar-left"`, `"two-col"`), `class`

```heex
<.page_layout variant="sidebar-right">
  <:main>
    <.heading level={1}>Article Title</.heading>
    <.prose>{@article.body}</.prose>
  </:main>
  <:sidebar>
    <.card>Related</.card>
  </:sidebar>
</.page_layout>
```

### split_layout

Two-pane resizable split panel with configurable ratio.

**Attrs**: `ratio` (default `"1/2"`), `direction` (`"horizontal"`, `"vertical"`), `class`

```heex
<.split_layout ratio="1/3">
  <:left><.sidebar_panel /></:left>
  <:right><.main_content /></:right>
</.split_layout>
```

### page_header

Consistent page heading region with breadcrumb and action slot.

**Attrs**: `title`, `description`, `class`

```heex
<.page_header title="Users" description="Manage your team members.">
  <:actions>
    <.button phx-click="new_user">Invite user</.button>
  </:actions>
</.page_header>
```

### nav_list

Styled vertical navigation list with item and group slots.

**Attrs**: `class`

```heex
<.nav_list>
  <:group label="Account">
    <:item href="/profile" active={@path == "/profile"} icon="user">Profile</:item>
    <:item href="/settings" active={@path == "/settings"} icon="settings">Settings</:item>
  </:group>
</.nav_list>
```

← [Back to README](../../README.md)
