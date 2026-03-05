# Buttons

Interactive action components: primary actions, toolbars, clipboard utilities, floating actions, and toggles.

## Table of Contents

- [button](#button)
- [button_group](#button_group)
- [back_top](#back_top)
- [copy_button](#copy_button)
- [float_button](#float_button)
- [toggle](#toggle)
- [toggle_group](#toggle_group)

---

## button

The primary action element. 6 variants × 4 sizes, icon slot, loading state, and `cn/1` class override.

**Variants**: `default`, `secondary`, `destructive`, `outline`, `ghost`, `link`
**Sizes**: `sm`, `default`, `lg`, `icon`

```heex
<%!-- Variants --%>
<.button>Default</.button>
<.button variant="secondary">Secondary</.button>
<.button variant="destructive">Delete</.button>
<.button variant="outline">Outline</.button>
<.button variant="ghost">Ghost</.button>
<.button variant="link">Link</.button>

<%!-- Sizes --%>
<.button size="sm">Small</.button>
<.button size="lg">Large</.button>
<.button size="icon"><.icon name="plus" /></.button>

<%!-- With icon --%>
<.button variant="outline" size="sm">
  <.icon name="download" size="sm" /> Export CSV
</.button>
<.button variant="destructive">
  <.icon name="trash" size="sm" /> Delete
</.button>

<%!-- States --%>
<.button disabled>Disabled</.button>
<.button phx-click="save" phx-disable-with="Saving…">Save</.button>

<%!-- Full width --%>
<.button class="w-full">Submit</.button>
```

### LiveView pattern

```elixir
# Disable during async operation
def handle_event("save", _params, socket) do
  # Button shows "Saving…" via phx-disable-with during this handler
  case MyApp.save(socket.assigns.data) do
    {:ok, _} -> {:noreply, push_navigate(socket, to: ~p"/items")}
    {:error, changeset} -> {:noreply, assign(socket, form: to_form(changeset))}
  end
end
```

---

## button_group

Groups buttons into a single toolbar with shared border styling. Use for formatting bars, view switchers, and action toolbars.

```heex
<%!-- Text formatting toolbar --%>
<.button_group>
  <.button variant="outline" size="icon"><.icon name="bold" size="sm" /></.button>
  <.button variant="outline" size="icon"><.icon name="italic" size="sm" /></.button>
  <.button variant="outline" size="icon"><.icon name="underline" size="sm" /></.button>
</.button_group>

<%!-- View mode switcher --%>
<.button_group>
  <.button variant={if @view == "list", do: "default", else: "outline"}
    phx-click="set-view" phx-value-view="list">
    <.icon name="list" size="sm" /> List
  </.button>
  <.button variant={if @view == "grid", do: "default", else: "outline"}
    phx-click="set-view" phx-value-view="grid">
    <.icon name="grid" size="sm" /> Grid
  </.button>
</.button_group>

<%!-- Vertical orientation --%>
<.button_group orientation="vertical">
  <.button variant="outline">Top</.button>
  <.button variant="outline">Middle</.button>
  <.button variant="outline">Bottom</.button>
</.button_group>
```

---

## back_top

A fixed "scroll to top" button that appears after the user scrolls past a threshold. Uses the `PhiaBackTop` hook.

**Hook**: `PhiaBackTop`

```heex
<%!-- Mount once, usually in a layout --%>
<.back_top id="back-to-top" />

<%!-- Custom threshold and label --%>
<.back_top id="back-to-top" threshold={400} />
```

```javascript
// app.js — register the hook
import PhiaBackTop from "./phia_hooks/back_top"
// hooks: { PhiaBackTop }
```

---

## copy_button

A clipboard copy button with visual feedback (check icon) and `aria-live` announcement for screen readers.

**Hook**: `PhiaCopyButton`

```heex
<%!-- Copy an API key --%>
<div class="flex items-center gap-2">
  <code class="text-sm bg-muted px-2 py-1 rounded font-mono"><%= @api_key %></code>
  <.copy_button value={@api_key} label="Copy API key" />
</div>

<%!-- Copy a URL --%>
<div class="flex items-center gap-2 border rounded-md px-3 py-2">
  <span class="text-sm text-muted-foreground flex-1 truncate"><%= @share_url %></span>
  <.copy_button value={@share_url} />
</div>

<%!-- Copy code snippet in docs --%>
<div class="relative">
  <pre class="bg-muted p-4 rounded-lg"><code><%= @code_sample %></code></pre>
  <div class="absolute top-2 right-2">
    <.copy_button value={@code_sample} label="Copy code" />
  </div>
</div>
```

---

## float_button

A fixed-position circular action button (FAB). Supports a speed-dial variant with expandable sub-items.

```heex
<%!-- Simple FAB --%>
<.float_button id="new-item" phx-click="create-item" position="bottom-right">
  <.icon name="plus" />
</.float_button>

<%!-- Speed-dial with expandable actions --%>
<.float_button id="speed-dial" position="bottom-right" variant="speed_dial">
  <:trigger><.icon name="plus" /></:trigger>
  <:item phx-click="create-document" label="Document">
    <.icon name="file-text" size="sm" />
  </:item>
  <:item phx-click="create-folder" label="Folder">
    <.icon name="folder" size="sm" />
  </:item>
  <:item phx-click="upload-file" label="Upload">
    <.icon name="upload" size="sm" />
  </:item>
</.float_button>
```

---

## toggle

A stateful `aria-pressed` button. Use for mute/unmute, show/hide, pinned/unpinned, and similar binary states.

**Variants**: `default`, `outline`
**Sizes**: `sm`, `default`, `lg`

```heex
<%!-- Basic toggle --%>
<.toggle pressed={@bold} phx-click="toggle-bold">
  <.icon name="bold" size="sm" />
</.toggle>

<%!-- With label --%>
<.toggle pressed={@muted} phx-click="toggle-mute" variant="outline">
  <.icon name={if @muted, do: "volume-x", else: "volume-2"} size="sm" />
  <%= if @muted, do: "Unmute", else: "Mute" %>
</.toggle>

<%!-- Formatting toggles in an editor --%>
<div class="flex gap-1">
  <.toggle pressed={@bold}    phx-click="toggle-format" phx-value-format="bold">
    <.icon name="bold" size="sm" />
  </.toggle>
  <.toggle pressed={@italic}  phx-click="toggle-format" phx-value-format="italic">
    <.icon name="italic" size="sm" />
  </.toggle>
  <.toggle pressed={@underline} phx-click="toggle-format" phx-value-format="underline">
    <.icon name="underline" size="sm" />
  </.toggle>
</div>
```

```elixir
def handle_event("toggle-format", %{"format" => format}, socket) do
  {:noreply, update(socket, String.to_atom(format), &(!&1))}
end
```

---

## toggle_group

Wraps multiple toggles for single or multiple selection. Uses `:let` to pass the current `value` down to each toggle.

```heex
<%!-- Single selection (like a tab bar) --%>
<.toggle_group value={@alignment} on_change="set-alignment" type="single">
  <:option value="left">
    <.icon name="align-left" size="sm" />
  </:option>
  <:option value="center">
    <.icon name="align-center" size="sm" />
  </:option>
  <:option value="right">
    <.icon name="align-right" size="sm" />
  </:option>
</.toggle_group>

<%!-- Multiple selection --%>
<.toggle_group value={@selected_days} on_change="toggle-day" type="multiple">
  <:option value="mon">Mon</:option>
  <:option value="tue">Tue</:option>
  <:option value="wed">Wed</:option>
  <:option value="thu">Thu</:option>
  <:option value="fri">Fri</:option>
</.toggle_group>
```

```elixir
# Single selection handler
def handle_event("set-alignment", %{"value" => alignment}, socket) do
  {:noreply, assign(socket, alignment: alignment)}
end

# Multiple selection handler
def handle_event("toggle-day", %{"value" => day}, socket) do
  days = socket.assigns.selected_days
  updated = if day in days, do: List.delete(days, day), else: [day | days]
  {:noreply, assign(socket, selected_days: updated)}
end
```

← [Back to README](../../README.md)
