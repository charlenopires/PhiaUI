# Overlay

Modal dialogs, drawers, dropdowns, command palette, popovers, and tooltips — all with focus management and keyboard navigation.

## Table of Contents

- [dialog](#dialog)
- [alert_dialog](#alert_dialog)
- [drawer](#drawer)
- [sheet](#sheet)
- [dropdown_menu](#dropdown_menu)
- [context_menu](#context_menu)
- [popover](#popover)
- [tooltip](#tooltip)
- [hover_card](#hover_card)
- [command](#command)

---

## dialog

Modal dialog with focus trap, Escape to close, and scroll lock.

**Hook**: `PhiaDialog`
**Sub-components**: `dialog_trigger/1`, `dialog_content/1`, `dialog_header/1`, `dialog_title/1`, `dialog_description/1`, `dialog_footer/1`, `dialog_close/1`

```heex
<%!-- Dialog with trigger button --%>
<.dialog id="edit-user">
  <:trigger>
    <.button variant="outline">Edit profile</.button>
  </:trigger>
  <.dialog_content>
    <.dialog_header>
      <.dialog_title>Edit profile</.dialog_title>
      <.dialog_description>
        Update your name and avatar. Click Save when done.
      </.dialog_description>
    </.dialog_header>
    <div class="py-4 space-y-4">
      <.phia_input field={@form[:name]} label="Full name" />
      <.phia_input field={@form[:bio]} label="Bio" />
    </div>
    <.dialog_footer>
      <.dialog_close>
        <.button variant="outline">Cancel</.button>
      </.dialog_close>
      <.button phx-click="save-profile">Save changes</.button>
    </.dialog_footer>
  </.dialog_content>
</.dialog>

<%!-- Server-controlled open state --%>
<.dialog id="import-data" open={@show_import}>
  <.dialog_content>
    <.dialog_header>
      <.dialog_title>Import Data</.dialog_title>
    </.dialog_header>
    <.file_upload id="import-upload" phx-change="validate-file" phx-drop-target={@uploads.data.ref}>
      <.live_file_input upload={@uploads.data} class="hidden" />
      <div class="text-center p-8">
        <.icon name="upload" class="h-8 w-8 text-muted-foreground mx-auto mb-2" />
        <p class="text-sm text-muted-foreground">Drop CSV here or click to browse</p>
      </div>
    </.file_upload>
    <.dialog_footer>
      <.button phx-click="close-import" variant="outline">Cancel</.button>
      <.button phx-click="start-import" disabled={@uploads.data.entries == []}>Import</.button>
    </.dialog_footer>
  </.dialog_content>
</.dialog>
```

---

## alert_dialog

Confirmation dialog. `role="alertdialog"`. See [feedback/alert_dialog](feedback.md#alert_dialog) for full details.

---

## drawer

Side or bottom slide-in panel. 4 directions, focus trap, backdrop-click close.

**Hook**: `PhiaDrawer`
**Sub-components**: `drawer_content/1`, `drawer_header/1`, `drawer_footer/1`, `drawer_close/1`
**Directions**: `right` (default), `left`, `top`, `bottom`

```heex
<%!-- Right-side filter drawer --%>
<.button variant="outline" phx-click="open-filters">
  <.icon name="filter" size="sm" /> Filters
</.button>

<.drawer_content id="filters-drawer" open={@filters_open} direction="right">
  <.drawer_header>
    <h2 class="text-lg font-semibold">Filters</h2>
    <p class="text-sm text-muted-foreground">Narrow down your results</p>
  </.drawer_header>
  <.drawer_close phx-click="close-filters" />
  <div class="px-6 py-4 space-y-6 flex-1 overflow-y-auto">
    <.filter_builder
      fields={@filter_fields}
      rules={@filter_rules}
      on_add="add_rule"
      on_remove="remove_rule"
      on_change="update_rule"
    />
  </div>
  <.drawer_footer>
    <.button class="flex-1" phx-click="apply-filters">Apply filters</.button>
    <.button variant="outline" phx-click="reset-filters">Reset</.button>
  </.drawer_footer>
</.drawer_content>

<%!-- Bottom sheet for mobile --%>
<.drawer_content id="mobile-actions" open={@actions_open} direction="bottom">
  <.drawer_header>
    <h2 class="text-base font-semibold">Actions for <%= @selected_item.name %></h2>
  </.drawer_header>
  <div class="px-4 pb-6 space-y-2">
    <.button variant="outline" class="w-full" phx-click="edit-item">
      <.icon name="pencil" size="sm" /> Edit
    </.button>
    <.button variant="destructive" class="w-full" phx-click="delete-item">
      <.icon name="trash" size="sm" /> Delete
    </.button>
  </div>
</.drawer_content>
```

---

## sheet

Side-panel modal (drawer-style but modal). 4 sides, 5 sizes.

**Hook**: `PhiaDialog`
**Sub-components**: `sheet_trigger/1`, `sheet_content/1`, `sheet_header/1`, `sheet_title/1`, `sheet_description/1`, `sheet_footer/1`, `sheet_close/1`
**Sizes**: `sm`, `default`, `lg`, `xl`, `full`

```heex
<.sheet id="cart">
  <:trigger>
    <.button variant="outline" size="icon">
      <.icon name="shopping-cart" />
    </.button>
  </:trigger>
  <.sheet_content side="right" size="lg">
    <.sheet_header>
      <.sheet_title>Shopping cart</.sheet_title>
      <.sheet_description><%= @cart_count %> items</.sheet_description>
    </.sheet_header>
    <div class="flex-1 overflow-y-auto py-4 space-y-4">
      <div :for={item <- @cart_items} class="flex items-center gap-4">
        <img src={item.image} class="h-16 w-16 rounded object-cover" />
        <div class="flex-1">
          <p class="font-medium text-sm"><%= item.name %></p>
          <p class="text-sm text-muted-foreground"><%= item.variant %></p>
        </div>
        <div class="text-right">
          <p class="font-medium">$<%= item.price %></p>
          <.button variant="ghost" size="sm" phx-click="remove-from-cart" phx-value-id={item.id}>
            Remove
          </.button>
        </div>
      </div>
    </div>
    <.sheet_footer class="flex-col gap-2">
      <div class="flex justify-between text-sm font-medium">
        <span>Total</span>
        <span>$<%= @cart_total %></span>
      </div>
      <.button class="w-full" phx-click="checkout">Checkout</.button>
    </.sheet_footer>
  </.sheet_content>
</.sheet>
```

---

## dropdown_menu

Trigger + dropdown menu with smart flip, click-outside, and arrow-key navigation.

**Hook**: `PhiaDropdownMenu`
**Sub-components**: `dropdown_menu_trigger/1`, `dropdown_menu_content/1`, `dropdown_menu_item/1`, `dropdown_menu_separator/1`, `dropdown_menu_label/1`, `dropdown_menu_checkbox_item/1`, `dropdown_menu_radio_group/1`, `dropdown_menu_radio_item/1`

```heex
<%!-- Row actions in a table --%>
<.dropdown_menu id={"actions-#{@item.id}"}>
  <:trigger>
    <.button variant="ghost" size="icon">
      <.icon name="more-horizontal" />
    </.button>
  </:trigger>
  <:content>
    <.dropdown_menu_item phx-click="edit" phx-value-id={@item.id}>
      <.icon name="pencil" size="sm" /> Edit
    </.dropdown_menu_item>
    <.dropdown_menu_item phx-click="duplicate" phx-value-id={@item.id}>
      <.icon name="copy" size="sm" /> Duplicate
    </.dropdown_menu_item>
    <.dropdown_menu_separator />
    <.dropdown_menu_item
      class="text-destructive focus:text-destructive"
      phx-click="delete"
      phx-value-id={@item.id}
    >
      <.icon name="trash" size="sm" /> Delete
    </.dropdown_menu_item>
  </:content>
</.dropdown_menu>

<%!-- View options with checkboxes --%>
<.dropdown_menu id="view-options">
  <:trigger>
    <.button variant="outline" size="sm">
      <.icon name="settings-2" size="sm" /> View
    </.button>
  </:trigger>
  <:content>
    <.dropdown_menu_label>Show columns</.dropdown_menu_label>
    <.dropdown_menu_separator />
    <.dropdown_menu_checkbox_item
      :for={col <- @columns}
      checked={col.visible}
      phx-click="toggle-column"
      phx-value-key={col.key}
    >
      <%= col.label %>
    </.dropdown_menu_checkbox_item>
  </:content>
</.dropdown_menu>
```

---

## context_menu

Right-click context menu with smart positioning and WAI-ARIA `role="menu"`.

**Hook**: `PhiaContextMenu`
**Sub-components**: `context_menu_trigger/1`, `context_menu_content/1`, `context_menu_item/1`, `context_menu_separator/1`, `context_menu_label/1`

```heex
<%!-- File manager context menu --%>
<.context_menu id={"file-ctx-#{@file.id}"}>
  <:trigger>
    <div class="p-4 rounded border cursor-pointer hover:bg-muted" phx-value-id={@file.id}>
      <.icon name="file-text" class="h-8 w-8 text-muted-foreground" />
      <p class="text-xs mt-2 text-center truncate"><%= @file.name %></p>
    </div>
  </:trigger>
  <:content>
    <.context_menu_item phx-click="open-file" phx-value-id={@file.id}>Open</.context_menu_item>
    <.context_menu_item phx-click="rename-file" phx-value-id={@file.id}>Rename</.context_menu_item>
    <.context_menu_item phx-click="download-file" phx-value-id={@file.id}>Download</.context_menu_item>
    <.context_menu_separator />
    <.context_menu_item class="text-destructive" phx-click="delete-file" phx-value-id={@file.id}>
      Move to trash
    </.context_menu_item>
  </:content>
</.context_menu>
```

---

## popover

Click-open floating panel with focus trap and click-outside close.

**Hook**: `PhiaPopover`
**Sub-components**: `popover_trigger/1`, `popover_content/1`

```heex
<%!-- Date picker in a popover --%>
<.popover id="date-picker-pop">
  <:trigger>
    <.button variant="outline" class="w-48 justify-start text-left">
      <.icon name="calendar" size="sm" class="mr-2" />
      <%= if @selected_date, do: Date.to_string(@selected_date), else: "Pick a date" %>
    </.button>
  </:trigger>
  <:content>
    <.calendar value={@selected_date} on_change="set-date" />
  </:content>
</.popover>

<%!-- Color picker popover --%>
<.popover id="color-pop">
  <:trigger>
    <button class="h-8 w-8 rounded border shadow" style={"background:#{@color}"} />
  </:trigger>
  <:content>
    <.color_picker id="cp" value={@color} on_change="set-color" />
  </:content>
</.popover>
```

---

## tooltip

Hover + focus tooltip. 4 positions, smart flip.

**Hook**: `PhiaTooltip`
**Sub-components**: `tooltip_trigger/1`, `tooltip_content/1`
**Positions**: `top` (default), `right`, `bottom`, `left`

```heex
<%!-- Icon button with tooltip --%>
<.tooltip>
  <:trigger>
    <.button variant="ghost" size="icon">
      <.icon name="info" />
    </.button>
  </:trigger>
  <:content>
    This is your unique API key. Do not share it.
  </:content>
</.tooltip>

<%!-- Disabled button explanation --%>
<.tooltip>
  <:trigger>
    <span class="inline-block">
      <.button disabled>Publish</.button>
    </span>
  </:trigger>
  <:content>
    Complete all required fields to publish.
  </:content>
</.tooltip>

<%!-- Position variants --%>
<.tooltip position="right">
  <:trigger><.button variant="ghost" size="icon"><.icon name="settings" /></.button></:trigger>
  <:content>Settings</:content>
</.tooltip>
```

---

## hover_card

Hover preview card with `role="tooltip"`. Pure HEEx, no hook.

**Sub-components**: `hover_card_trigger/1`, `hover_card_content/1`

```heex
<%!-- User profile preview --%>
<.hover_card>
  <:trigger>
    <a href={~p"/users/#{@user.id}"} class="font-medium underline-offset-4 hover:underline">
      @<%= @user.username %>
    </a>
  </:trigger>
  <:content class="w-72">
    <div class="flex items-start gap-3">
      <.avatar size="lg">
        <.avatar_image src={@user.avatar_url} />
        <.avatar_fallback name={@user.name} />
      </.avatar>
      <div>
        <p class="font-semibold"><%= @user.name %></p>
        <p class="text-sm text-muted-foreground">@<%= @user.username %></p>
        <p class="text-sm mt-2"><%= @user.bio %></p>
        <div class="flex gap-4 mt-3 text-sm text-muted-foreground">
          <span><strong class="text-foreground"><%= @user.following_count %></strong> Following</span>
          <span><strong class="text-foreground"><%= @user.followers_count %></strong> Followers</span>
        </div>
      </div>
    </div>
  </:content>
</.hover_card>
```

---

## command

Ctrl+K command palette with server-side filtering and arrow-key navigation.

**Hook**: `PhiaCommand`
**Sub-components**: `command_dialog/1`, `command_input/1`, `command_list/1`, `command_group/1`, `command_item/1`, `command_separator/1`, `command_empty/1`

```heex
<%!-- Global command palette --%>
<.command_dialog id="command-palette" open={@command_open}>
  <.command_input
    value={@command_query}
    placeholder="Search commands…"
    on_change="search-commands"
  />
  <.command_list>
    <.command_empty>No results found.</.command_empty>

    <.command_group label="Navigation">
      <.command_item :for={item <- @nav_results}
        on_click="navigate-to"
        value={item.href}
      >
        <.icon name={item.icon} size="sm" class="mr-2" />
        <%= item.label %>
        <kbd class="ml-auto text-xs text-muted-foreground"><%= item.shortcut %></kbd>
      </.command_item>
    </.command_group>

    <.command_separator />

    <.command_group label="Recent documents">
      <.command_item :for={doc <- @recent_docs}
        on_click="open-document"
        value={doc.id}
      >
        <.icon name="file-text" size="sm" class="mr-2" />
        <%= doc.title %>
      </.command_item>
    </.command_group>
  </.command_list>
</.command_dialog>
```

```elixir
def mount(_params, _session, socket) do
  {:ok, assign(socket,
    command_open: false,
    command_query: "",
    nav_results: nav_commands(),
    recent_docs: []
  )}
end

def handle_event("search-commands", %{"query" => q}, socket) do
  results = filter_commands(nav_commands(), q)
  {:noreply, assign(socket, command_query: q, nav_results: results)}
end

def handle_event("navigate-to", %{"value" => href}, socket) do
  {:noreply, assign(socket, command_open: false) |> push_navigate(to: href)}
end

# Keyboard shortcut: Ctrl+K opens the palette
# The PhiaCommand hook handles this automatically.
```

← [Back to README](../../README.md)
