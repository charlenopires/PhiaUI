# Overlay

9 overlay components — modal dialogs, side drawers, sheets, dropdown menus, context menus, popovers, tooltips, hover cards, and the command menu primitive.

**Module**: `PhiaUi.Components.Overlay`

```elixir
import PhiaUi.Components.Overlay
```

All overlays use `Phoenix.LiveView.JS` for open/close with focus management. No extra hooks needed except where noted.

---

## Table of Contents

- [dialog](#dialog)
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

**Sub-components**: `dialog_trigger`, `dialog_content`, `dialog_header`, `dialog_title`, `dialog_description`, `dialog_footer`, `dialog_close`

```heex
<%!-- Trigger + dialog --%>
<.dialog id="edit-user">
  <:trigger>
    <.button variant="outline">Edit user</.button>
  </:trigger>

  <:content>
    <.dialog_header>
      <.dialog_title>Edit user</.dialog_title>
      <.dialog_description>Update the user's profile information.</.dialog_description>
    </.dialog_header>

    <.form for={@form} phx-submit="update_user" class="space-y-4 mt-4">
      <.phia_input field={@form[:name]} label="Name" />
      <.phia_input field={@form[:email]} type="email" label="Email" />

      <.dialog_footer>
        <.dialog_close><.button variant="outline">Cancel</.button></.dialog_close>
        <.button type="submit">Save changes</.button>
      </.dialog_footer>
    </.form>
  </:content>
</.dialog>
```

```heex
<%!-- Server-controlled dialog --%>
<.button phx-click={JS.show(to: "#confirm-dialog")}>Delete</.button>

<.dialog id="confirm-dialog">
  <:content>
    <.dialog_header>
      <.dialog_title>Confirm deletion</.dialog_title>
    </.dialog_header>
    <p class="text-muted-foreground">This action cannot be undone.</p>
    <.dialog_footer class="mt-4">
      <.button variant="outline" phx-click={JS.hide(to: "#confirm-dialog")}>Cancel</.button>
      <.button variant="destructive" phx-click="confirm_delete">Delete</.button>
    </.dialog_footer>
  </:content>
</.dialog>
```

---

## drawer

Full-height side panel that slides in from left or right.

```heex
<.drawer id="user-details" side={:right}>
  <:trigger>
    <.button variant="ghost" size="sm">View details</.button>
  </:trigger>

  <:content>
    <div class="p-6 h-full overflow-y-auto">
      <h2 class="text-lg font-semibold"><%= @user.name %></h2>
      <p class="text-muted-foreground"><%= @user.email %></p>
      <.separator class="my-6" />
      <.description_list>
        <:item label="Role"><.badge><%= @user.role %></.badge></:item>
        <:item label="Joined"><.relative_time datetime={@user.inserted_at} /></:item>
        <:item label="Status"><.status_indicator status={if @user.active, do: :online, else: :offline} /></:item>
      </.description_list>
    </div>
  </:content>
</.drawer>
```

**Attrs**: `id` (required), `side` (`:left` | `:right`, default `:right`), `size` (`:sm` | `:md` | `:lg` | `:full`)

---

## sheet

Smaller bottom or side sheet. Ideal for mobile overlays or quick actions.

```heex
<.sheet id="quick-add" side={:bottom}>
  <:trigger>
    <.button><.icon name="plus" class="mr-2" />New task</.button>
  </:trigger>

  <:content>
    <div class="p-4 space-y-3">
      <h3 class="font-semibold">New task</h3>
      <.input name="title" placeholder="Task title…" />
      <.button class="w-full" phx-click="add_task">Add</.button>
    </div>
  </:content>
</.sheet>
```

**Attrs**: `side` (`:top` | `:right` | `:bottom` | `:left`)

---

## dropdown_menu

Dropdown with items, submenus, separators, and labels.

```heex
<.dropdown_menu id="actions-dd">
  <:trigger>
    <.button variant="ghost" size="icon" aria-label="More options">
      <.icon name="more-horizontal" />
    </.button>
  </:trigger>

  <:content>
    <.dropdown_menu_item phx-click="edit" phx-value-id={@record.id}>
      <.icon name="pencil" size="sm" class="mr-2" />Edit
    </.dropdown_menu_item>
    <.dropdown_menu_item phx-click="duplicate">
      <.icon name="copy" size="sm" class="mr-2" />Duplicate
    </.dropdown_menu_item>
    <.dropdown_menu_separator />
    <.dropdown_menu_item variant="destructive" phx-click="delete" phx-value-id={@record.id}>
      <.icon name="trash" size="sm" class="mr-2" />Delete
    </.dropdown_menu_item>
  </:content>
</.dropdown_menu>
```

---

## context_menu

Right-click context menu.

```heex
<.context_menu id="row-ctx">
  <:trigger>
    <div class="p-3 hover:bg-muted/50 rounded cursor-context-menu">
      Right-click me
    </div>
  </:trigger>

  <:content>
    <.context_menu_item phx-click="open">Open</.context_menu_item>
    <.context_menu_item phx-click="rename">Rename</.context_menu_item>
    <.context_menu_separator />
    <.context_menu_item variant="destructive" phx-click="delete">Delete</.context_menu_item>
  </:content>
</.context_menu>
```

---

## popover

Non-modal popup anchored to a trigger — for forms, colour pickers, or rich content.

```heex
<.popover id="date-picker-pop">
  <:trigger>
    <.button variant="outline" class="gap-2">
      <.icon name="calendar" size="sm" />
      <%= if @date, do: Calendar.strftime(@date, "%b %d, %Y"), else: "Pick a date" %>
    </.button>
  </:trigger>

  <:content>
    <.calendar id="pop-calendar" selected={@date} on_select="set_date" />
  </:content>
</.popover>
```

---

## tooltip

Hover tooltip anchored to any element.

```heex
<.tooltip content="Copy to clipboard">
  <.button variant="ghost" size="icon" phx-click="copy">
    <.icon name="copy" />
  </.button>
</.tooltip>

<%!-- Rich tooltip with side --%>
<.tooltip side={:right}>
  <:content>
    <p class="font-medium">Pro plan</p>
    <p class="text-xs text-muted-foreground">Unlimited seats, priority support</p>
  </:content>
  <.button variant="outline">Upgrade</.button>
</.tooltip>
```

**Attrs**: `content` (string shorthand), `side` (`:top` | `:right` | `:bottom` | `:left`), `delay` (ms)

---

## hover_card

Larger hover card — show preview content on mouse-over.

```heex
<.hover_card id="user-hc">
  <:trigger>
    <a href={~p"/users/#{@user}"} class="font-medium hover:underline"><%= @user.name %></a>
  </:trigger>

  <:content>
    <div class="flex gap-3 p-1">
      <.avatar size="md">
        <.avatar_image src={@user.avatar_url} />
        <.avatar_fallback name={@user.name} />
      </.avatar>
      <div>
        <p class="font-semibold"><%= @user.name %></p>
        <p class="text-sm text-muted-foreground"><%= @user.bio %></p>
        <div class="flex gap-2 mt-2">
          <.badge variant="secondary"><%= @user.role %></.badge>
          <.relative_time datetime={@user.inserted_at} class="text-xs text-muted-foreground" />
        </div>
      </div>
    </div>
  </:content>
</.hover_card>
```

---

## command

Low-level command menu primitive — used to build `command_palette`. Use this for custom command UIs embedded within pages.

```heex
<.command id="inline-cmd">
  <.command_input placeholder="Type a command…" />
  <.command_list>
    <.command_group label="Suggestions">
      <.command_item phx-click="new_file">
        <.icon name="file-plus" class="mr-2" />New file
      </.command_item>
      <.command_item phx-click="new_folder">
        <.icon name="folder-plus" class="mr-2" />New folder
      </.command_item>
    </.command_group>
  </.command_list>
</.command>
```

For the full keyboard-accessible command palette (⌘K), use `command_palette` from the Navigation module.
