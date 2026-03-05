defmodule PhiaUi.Components.ContextMenu do
  @moduledoc """
  Context menu component triggered by right-click (`contextmenu` browser event).

  A context menu provides a contextual set of actions for a specific element —
  just like the browser's native right-click menu, but fully customisable and
  integrated with your LiveView. Common use cases include file managers,
  spreadsheets, canvas editors, data grids, and any UI where per-item actions
  should be discoverable on right-click.

  Requires the `PhiaContextMenu` JavaScript hook registered in `app.js`. The
  hook intercepts the `contextmenu` event on the trigger area, prevents the
  native browser menu, and positions the custom panel at the exact cursor
  coordinates.

  ## Hook Registration

  Copy the hook via `mix phia.add context_menu`, then register it:

      # assets/js/app.js
      import PhiaContextMenu from "./hooks/context_menu"

      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaContextMenu }
      })

  ## Hook Behaviour

  - Right-clicking inside `context_menu_trigger/1` opens the menu at the cursor
  - The native browser context menu is suppressed
  - Smart viewport-aware positioning: the panel flips if it would overflow the
    viewport edge (right→left, bottom→top)
  - Clicking outside the open panel or pressing `Escape` closes it
  - `ArrowUp` / `ArrowDown` navigate between items; `Enter` activates the
    focused item
  - Only one context menu can be open at a time — opening a new one closes
    the previous

  ## Sub-components

  | Function                       | Element | Purpose                                       |
  |--------------------------------|---------|-----------------------------------------------|
  | `context_menu/1`               | `div`   | Root container                                |
  | `context_menu_trigger/1`       | `div`   | Right-clickable area with hook anchor         |
  | `context_menu_content/1`       | `div`   | Floating panel (positioned fixed by hook)     |
  | `context_menu_item/1`          | `div`   | Clickable item (`role="menuitem"`)            |
  | `context_menu_separator/1`     | `hr`    | Visual divider between item groups            |
  | `context_menu_checkbox_item/1` | `div`   | Toggleable item (`role="menuitemcheckbox"`)   |
  | `context_menu_label/1`         | `div`   | Non-interactive section heading               |

  ## Example — File Manager

  A classic context menu for file operations:

      <.context_menu id="file-ctx">
        <.context_menu_trigger context_menu_id="file-ctx">
          <div class="flex items-center gap-2 p-3 rounded-md hover:bg-muted cursor-default">
            <.icon name="file" />
            {file.name}
          </div>
        </.context_menu_trigger>
        <.context_menu_content id="file-ctx-content">
          <.context_menu_label>{@file.name}</.context_menu_label>
          <.context_menu_separator />
          <.context_menu_item phx-click="open_file" phx-value-id={@file.id}>
            Open
          </.context_menu_item>
          <.context_menu_item phx-click="rename_file" phx-value-id={@file.id}>
            Rename...
          </.context_menu_item>
          <.context_menu_item phx-click="duplicate_file" phx-value-id={@file.id}>
            Duplicate
          </.context_menu_item>
          <.context_menu_separator />
          <.context_menu_checkbox_item
            checked={@file.starred}
            phx-click="toggle_star"
            phx-value-id={@file.id}>
            Starred
          </.context_menu_checkbox_item>
          <.context_menu_separator />
          <.context_menu_item phx-click="delete_file" phx-value-id={@file.id}
            class="text-destructive focus:text-destructive">
            Move to Trash
          </.context_menu_item>
        </.context_menu_content>
      </.context_menu>

  ## Example — Data Grid Row

  Context menus work well on table rows in data grids:

      <tr :for={row <- @rows}>
        <.context_menu id={"row-ctx-\#{row.id}"}>
          <.context_menu_trigger context_menu_id={"row-ctx-\#{row.id}"}>
            <td class="px-4 py-2">{row.name}</td>
            <td class="px-4 py-2">{row.status}</td>
          </.context_menu_trigger>
          <.context_menu_content id={"row-ctx-\#{row.id}-content"}>
            <.context_menu_item phx-click="view_row" phx-value-id={row.id}>View</.context_menu_item>
            <.context_menu_item phx-click="edit_row" phx-value-id={row.id}>Edit</.context_menu_item>
            <.context_menu_separator />
            <.context_menu_item phx-click="archive_row" phx-value-id={row.id}>Archive</.context_menu_item>
          </.context_menu_content>
        </.context_menu>
      </tr>

  ## Example — Canvas / Drawing Area

  For design tools where the trigger is the entire canvas:

      <.context_menu id="canvas-ctx">
        <.context_menu_trigger context_menu_id="canvas-ctx">
          <div id="drawing-canvas" class="w-full h-96 bg-muted rounded border">
            <%# canvas content %>
          </div>
        </.context_menu_trigger>
        <.context_menu_content id="canvas-ctx-content">
          <.context_menu_item phx-click="paste">Paste</.context_menu_item>
          <.context_menu_item phx-click="select_all">Select All</.context_menu_item>
          <.context_menu_separator />
          <.context_menu_label>View</.context_menu_label>
          <.context_menu_checkbox_item checked={@show_grid} phx-click="toggle_grid">
            Show Grid
          </.context_menu_checkbox_item>
          <.context_menu_checkbox_item checked={@snap_to_grid} phx-click="toggle_snap">
            Snap to Grid
          </.context_menu_checkbox_item>
        </.context_menu_content>
      </.context_menu>

  ## Accessibility

  - `context_menu_trigger/1` has `aria-haspopup="menu"` to signal the
    right-click behaviour to assistive technology
  - `context_menu_content/1` has `role="menu"` and `aria-orientation="vertical"`
  - Items have `role="menuitem"` (or `menuitemcheckbox` for toggleable items)
  - All items have `tabindex="-1"` so keyboard navigation is hook-managed via
    `[data-disabled]` and `focus()` calls, matching the WAI-ARIA menu pattern
  - The panel is `position: fixed` (not absolute) so it appears at the cursor
    coordinates regardless of the containing element's scroll position or
    `overflow` setting
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # context_menu/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    required: true,
    doc: """
    Unique context menu ID. Used by `context_menu_trigger/1` to build the
    `data-content-id` attribute that tells the hook which panel to position.
    Must be unique on the page. When rendering in lists, use per-item IDs:
    `"file-ctx-\#{file.id}"`.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the root `<div>`")

  slot(:inner_block,
    required: true,
    doc: "Must contain one `context_menu_trigger/1` and one `context_menu_content/1`"
  )

  @doc """
  Renders the context menu root container.

  The root is `relative` so child elements can be positioned within it.
  The trigger and content are referenced by ID — the root itself is a
  layout-only wrapper.
  """
  def context_menu(assigns) do
    ~H"""
    <div id={@id} class={cn(["relative", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # context_menu_trigger/1
  # ---------------------------------------------------------------------------

  attr(:context_menu_id, :string,
    required: true,
    doc: """
    ID of the parent `context_menu/1`. The hook uses this to build the content
    panel ID (`context_menu_id <> "-content"`) and show it at the cursor
    position on right-click.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the trigger `<div>`")

  slot(:inner_block, required: true, doc: "The right-clickable area — any content or element")

  @doc """
  Renders the context menu trigger area.

  The `PhiaContextMenu` hook mounts on this element (via `phx-hook`) and
  intercepts `contextmenu` events (right-click / two-finger tap on macOS).
  It prevents the native browser context menu and shows the custom panel at
  the exact cursor `(clientX, clientY)` coordinates.

  `data-content-id` tells the hook which panel element to position and show.
  This must equal `"{context_menu_id}-content"`.

  The trigger can wrap any content — a div, a table row, a canvas — as long
  as it is a valid container for the right-click area you want to cover.
  """
  def context_menu_trigger(assigns) do
    ~H"""
    <div
      data-context-trigger
      aria-haspopup="menu"
      phx-hook="PhiaContextMenu"
      data-content-id={"#{@context_menu_id}-content"}
      class={cn([@class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # context_menu_content/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    required: true,
    doc: """
    Element ID for the content panel. **Must follow the pattern
    `"{context_menu_id}-content"`** — this is the ID the hook looks up via
    `data-content-id` on the trigger to position the panel.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the panel `<div>`")

  slot(:inner_block, required: true, doc: "Menu items, labels, separators, and checkbox items")

  @doc """
  Renders the context menu content panel.

  Initially hidden via `style="display:none; position:fixed;"`. Using
  `position: fixed` (not absolute) is critical — it ensures the panel
  appears at the cursor's viewport coordinates regardless of the page
  scroll position or the trigger's containing block.

  The hook reveals the panel and sets `top`/`left` inline styles to the
  right-click cursor position, then adjusts if the panel would overflow
  the viewport edge.

  `tabindex="-1"` allows the panel to receive programmatic focus from the
  hook after opening, enabling keyboard navigation to work immediately
  without the user needing to Tab into the panel.
  """
  def context_menu_content(assigns) do
    ~H"""
    <div
      id={@id}
      role="menu"
      aria-orientation="vertical"
      style="display:none; position:fixed;"
      class={cn([
        "z-50 min-w-[8rem] overflow-hidden rounded-md border bg-popover p-1",
        "text-popover-foreground shadow-md",
        @class
      ])}
      tabindex="-1"
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # context_menu_item/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")

  attr(:rest, :global,
    doc: "Extra HTML attributes forwarded to the item `<div>` (e.g. `phx-click`, `phx-value-*`)"
  )

  slot(:inner_block, required: true, doc: "Menu item content")

  @doc """
  Renders a context menu item with `role="menuitem"`.

  Wire LiveView actions using `phx-click` and pass data via `phx-value-*`:

      <.context_menu_item phx-click="rename" phx-value-id={@file.id}>
        Rename
      </.context_menu_item>

  The hook handles `ArrowUp` / `ArrowDown` focus management between items
  (via programmatic `focus()`) and `Enter` to activate the focused item.

  Disabled items should use `data-disabled` attribute — the hook checks for
  this and skips them during keyboard navigation. The `data-[disabled]` CSS
  selector applies the visual disabled style.
  """
  def context_menu_item(assigns) do
    ~H"""
    <div
      role="menuitem"
      tabindex="-1"
      class={cn([
        "relative flex cursor-default select-none items-center rounded-sm px-2 py-1.5",
        "text-sm outline-none transition-colors",
        "focus:bg-accent focus:text-accent-foreground",
        "data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # context_menu_separator/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the `<hr>`")

  @doc """
  Renders a horizontal visual separator between groups of context menu items.

  Use separators to create clear visual groupings between related and unrelated
  actions. For example, separate "Open", "Rename", "Duplicate" from destructive
  actions like "Delete" or "Archive".

      <.context_menu_item phx-click="copy">Copy</.context_menu_item>
      <.context_menu_item phx-click="paste">Paste</.context_menu_item>
      <.context_menu_separator />
      <.context_menu_item phx-click="delete" class="text-destructive">
        Delete
      </.context_menu_item>
  """
  def context_menu_separator(assigns) do
    ~H"""
    <hr
      role="separator"
      class={cn(["-mx-1 my-1 h-px border-0 bg-muted", @class])}
      {@rest}
    />
    """
  end

  # ---------------------------------------------------------------------------
  # context_menu_checkbox_item/1
  # ---------------------------------------------------------------------------

  attr(:checked, :boolean,
    default: false,
    doc: """
    Whether the checkbox item is currently checked. Drives `aria-checked` and
    the visible check mark indicator. Manage state in your LiveView and pass
    the current value here.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")

  attr(:rest, :global,
    doc: "Extra HTML attributes forwarded to the item `<div>` (e.g. `phx-click`, `phx-value-*`)"
  )

  slot(:inner_block, required: true, doc: "Item label text")

  @doc """
  Renders a toggleable context menu item with a check mark indicator.

  Uses `role="menuitemcheckbox"` and `aria-checked` so assistive technology
  announces the current state. Toggle the state in your LiveView:

      # LiveView
      def handle_event("toggle_grid", _params, socket) do
        {:noreply, update(socket, :show_grid, &(!&1))}
      end

      # Template
      <.context_menu_checkbox_item
        checked={@show_grid}
        phx-click="toggle_grid">
        Show Grid
      </.context_menu_checkbox_item>

  The check mark (`&#10003;`) is rendered only when `:checked` is `true`,
  keeping the item label left-aligned whether checked or not.
  """
  def context_menu_checkbox_item(assigns) do
    ~H"""
    <div
      role="menuitemcheckbox"
      aria-checked={to_string(@checked)}
      tabindex="-1"
      class={cn([
        "relative flex cursor-default select-none items-center rounded-sm py-1.5 pl-8 pr-2",
        "text-sm outline-none transition-colors",
        "focus:bg-accent focus:text-accent-foreground",
        @class
      ])}
      {@rest}
    >
      <%!-- Check mark: absolute-positioned in the left gutter; visible only when checked --%>
      <span class="absolute left-2 flex h-3.5 w-3.5 items-center justify-center">
        <span :if={@checked}>&#10003;</span>
      </span>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # context_menu_label/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the label `<div>`")

  slot(:inner_block, required: true, doc: "Label text content")

  @doc """
  Renders a non-interactive section heading inside the context menu.

  Use labels to give context to a group of related items — for example,
  showing the name of the right-clicked item at the top of the menu:

      <.context_menu_content id="file-ctx-content">
        <.context_menu_label>{@file.name}</.context_menu_label>
        <.context_menu_separator />
        <.context_menu_item phx-click="open">Open</.context_menu_item>
      </.context_menu_content>

  Labels are not focusable and are skipped by the hook's keyboard navigation.
  """
  def context_menu_label(assigns) do
    ~H"""
    <div
      class={cn(["px-2 py-1.5 text-sm font-semibold text-foreground", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
