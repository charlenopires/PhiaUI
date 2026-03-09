# Layout

26 layout components — page shell, structural grid/flex primitives, accordion, resizable panels, and scroll areas.

**Module**: `PhiaUi.Components.Layout`

```elixir
import PhiaUi.Components.Layout
```

---

## Table of Contents

**Page Structure**
- [shell](#shell) / [app_shell](#app_shell)
- [page_layout](#page_layout) / [split_layout](#split_layout)
- [page_header](#page_header)
- [fixed_bar](#fixed_bar) / [sticky](#sticky)

**Grid & Flex**
- [container](#container)
- [box](#box)
- [flex](#flex) / [stack](#stack) / [wrap](#wrap)
- [grid](#grid) / [simple_grid](#simple_grid)
- [masonry_grid](#masonry_grid)
- [center](#center)
- [spacer](#spacer)
- [section](#section)
- [media_object](#media_object)
- [description_list](#description_list)
- [nav_list](#nav_list)

**Panels**
- [accordion](#accordion)
- [collapsible](#collapsible)
- [resizable](#resizable)

**Utility**
- [scroll_area](#scroll_area)
- [aspect_ratio](#aspect_ratio)
- [separator / divider](#separator--divider)

---

## shell

Full-page app shell. Coordinates sidebar + topbar + main content area.

```heex
<.shell>
  <:sidebar>
    <.sidebar>
      <:brand><img src="/logo.svg" alt="App" class="h-7" /></:brand>
      <:nav_items>
        <.sidebar_item icon="home" href="/" active={@active == :home}>Dashboard</.sidebar_item>
        <.sidebar_item icon="users" href="/users">Users</.sidebar_item>
        <.sidebar_item icon="settings" href="/settings">Settings</.sidebar_item>
      </:nav_items>
    </.sidebar>
  </:sidebar>

  <:topbar>
    <.topbar>
      <:right>
        <.dark_mode_toggle />
        <.avatar size="sm"><.avatar_fallback name={@current_user.name} /></.avatar>
      </:right>
    </.topbar>
  </:topbar>

  <:main>
    <div class="p-6">
      <%= @inner_content %>
    </div>
  </:main>
</.shell>
```

---

## page_layout

Standard page with header, optional sidebar, and main content.

```heex
<.page_layout>
  <:header>
    <.page_header title="Users" description="Manage your team members." />
  </:header>
  <:sidebar>
    <.context_nav>…</.context_nav>
  </:sidebar>
  <:content>
    <.table rows={@users}>…</.table>
  </:content>
</.page_layout>
```

---

## split_layout

Two-column layout — list + detail panel.

```heex
<.split_layout ratio={:two_thirds}>
  <:left>
    <.data_grid id="users" rows={@users}>…</.data_grid>
  </:left>
  <:right>
    <%= if @selected_user do %>
      <.user_detail user={@selected_user} />
    <% else %>
      <.empty_state icon="user" title="Select a user" />
    <% end %>
  </:right>
</.split_layout>
```

**Attrs**: `ratio` (`:half` | `:one_third` | `:two_thirds`, default `:half`)

---

## page_header

Page title + description + optional action slot.

```heex
<.page_header title="Projects" description="All active projects and their status.">
  <:actions>
    <.button phx-click="new_project">
      <:icon><.icon name="plus" /></:icon>
      New project
    </.button>
  </:actions>
</.page_header>
```

---

## fixed_bar

Stuck to the top or bottom of the viewport.

```heex
<.fixed_bar position={:bottom} class="border-t bg-card px-6 py-3 flex justify-end gap-2">
  <.button variant="outline" phx-click="cancel">Cancel</.button>
  <.button type="submit">Save changes</.button>
</.fixed_bar>
```

---

## sticky

Position-sticky wrapper with configurable top offset.

```heex
<.sticky top={64}>
  <div class="bg-card border-b px-6 py-2 flex items-center gap-3">
    <.inline_search phx-change="search" />
    <.button variant="outline" size="sm">Filter</.button>
  </div>
</.sticky>
```

---

## container

Responsive centred container with max-width.

```heex
<.container>
  <.page_header title="Dashboard" />
  <.table rows={@data}>…</.table>
</.container>

<.container max_width="max-w-3xl">
  <.prose><%= @article.body %></.prose>
</.container>
```

---

## flex / stack / wrap / box

Spacing and alignment primitives.

```heex
<%!-- Vertical stack --%>
<.stack gap={4}>
  <.card>Item 1</.card>
  <.card>Item 2</.card>
</.stack>

<%!-- Horizontal flex --%>
<.flex align={:center} justify={:between} class="border-b px-4 py-2">
  <span class="font-semibold">Title</span>
  <.button size="sm">Action</.button>
</.flex>

<%!-- Wrapping flex (tag cloud) --%>
<.wrap gap={2}>
  <%= for tag <- @tags do %>
    <.badge><%= tag %></.badge>
  <% end %>
</.wrap>

<%!-- Padded box --%>
<.box padding={6} class="border rounded-lg">
  <p>Content</p>
</.box>
```

---

## grid / simple_grid

CSS Grid containers.

```heex
<.grid cols={3} gap={6}>
  <%= for item <- @items do %>
    <.card><%= item.title %></.card>
  <% end %>
</.grid>

<.simple_grid cols={2} gap={4}>
  <.stat_card title="MRR" value="$24,500" />
  <.stat_card title="ARR" value="$294,000" />
</.simple_grid>
```

---

## masonry_grid

CSS column-based masonry layout.

```heex
<.masonry_grid cols={3} gap={4}>
  <%= for post <- @posts do %>
    <.article_card {post} />
  <% end %>
</.masonry_grid>
```

---

## center

Centres content both horizontally and vertically.

```heex
<.center class="min-h-screen">
  <.card class="w-96 p-8">
    <h1 class="text-2xl font-bold mb-6">Sign in</h1>
    <.login_form />
  </.card>
</.center>
```

---

## section

Padded page section with optional title.

```heex
<.section title="Recent activity">
  <.activity_feed>…</.activity_feed>
</.section>
```

---

## media_object

Image/icon left, text content right.

```heex
<.media_object>
  <:media>
    <.avatar size="md">
      <.avatar_image src={@user.avatar_url} />
      <.avatar_fallback name={@user.name} />
    </.avatar>
  </:media>
  <:content>
    <p class="font-medium"><%= @user.name %></p>
    <p class="text-sm text-muted-foreground"><%= @comment.body %></p>
  </:content>
</.media_object>
```

---

## description_list

Label + value pairs.

```heex
<.description_list>
  <:item label="Status"><.badge>Active</.badge></:item>
  <:item label="Plan">Pro</:item>
  <:item label="Member since"><.relative_time datetime={@user.inserted_at} /></:item>
  <:item label="API Key"><.copy_input value={@user.api_key} /></:item>
</.description_list>
```

---

## accordion

Expand/collapse panels.

```heex
<.accordion type="single" collapsible={true}>
  <.accordion_item value="faq-1">
    <.accordion_trigger>What is PhiaUI?</.accordion_trigger>
    <.accordion_content>
      PhiaUI is a copy-paste Phoenix LiveView component library with 623 components.
    </.accordion_content>
  </.accordion_item>
  <.accordion_item value="faq-2">
    <.accordion_trigger>How do I install it?</.accordion_trigger>
    <.accordion_content>
      Run <code>mix phia.install</code> after adding the dependency.
    </.accordion_content>
  </.accordion_item>
</.accordion>
```

---

## collapsible

Single collapse toggle.

```heex
<.collapsible id="advanced-opts">
  <:trigger :let={open}>
    <.button variant="ghost" size="sm" class="gap-1">
      Advanced options
      <.icon name={if open, do: "chevron-up", else: "chevron-down"} size="sm" />
    </.button>
  </:trigger>
  <.phia_input field={@form[:webhook_url]} label="Webhook URL" class="mt-3" />
</.collapsible>
```

---

## resizable

Draggable split panels. Hook: `PhiaResizable`.

```heex
<.resizable id="editor-split" direction={:horizontal} default_size={50}>
  <:panel>
    <.code_textarea id="editor" name="code" value={@code} />
  </:panel>
  <:panel>
    <div class="prose p-4"><%= raw(@preview) %></div>
  </:panel>
</.resizable>
```

**Attrs**: `id` (required), `direction` (`:horizontal` | `:vertical`), `default_size` (%, default 50)

---

## scroll_area

Custom-styled scrollbar container.

```heex
<.scroll_area class="h-72 rounded-md border">
  <%= for item <- @long_list do %>
    <div class="px-4 py-2 hover:bg-muted/50"><%= item.name %></div>
  <% end %>
</.scroll_area>
```

---

## aspect_ratio

Maintains a fixed aspect ratio for images and embeds.

```heex
<.aspect_ratio ratio={16 / 9} class="overflow-hidden rounded-lg">
  <img src={@image_url} class="w-full h-full object-cover" />
</.aspect_ratio>

<.aspect_ratio ratio={1} class="w-32">
  <iframe src="https://www.youtube.com/embed/dQw4w9WgXcQ" class="w-full h-full" />
</.aspect_ratio>
```

---

## separator / divider

Horizontal or vertical separator line.

```heex
<.separator />
<.separator orientation={:vertical} class="h-6 mx-2" />

<%!-- With label --%>
<.divider label="or" />
<.divider label="Continue with" />
```
