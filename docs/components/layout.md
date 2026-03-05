# Layout

Structural composition components: dashboard shell, collapsible regions, resizable panels, scroll areas, and dividers.

## Table of Contents

- [shell](#shell)
- [accordion](#accordion)
- [collapsible](#collapsible)
- [resizable](#resizable)
- [scroll_area](#scroll_area)
- [separator](#separator)
- [aspect_ratio](#aspect_ratio)

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

← [Back to README](../../README.md)
