defmodule PhiaUi.Components.ContextMenu do
  @moduledoc """
  Context menu component triggered by right-click (contextmenu event).

  Requires the `PhiaContextMenu` JavaScript Hook registered in `app.js`.

  ## Registration in app.js

      import PhiaContextMenu from "./phia_hooks/context_menu.js"

      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaContextMenu, ...yourOtherHooks }
      })

  ## Sub-components

  | Function                        | Element | Purpose                                    |
  |---------------------------------|---------|--------------------------------------------|
  | `context_menu/1`                | `div`   | Root container with unique ID              |
  | `context_menu_trigger/1`        | `div`   | Right-clickable area with hook anchor      |
  | `context_menu_content/1`        | `div`   | Floating panel, positioned fixed           |
  | `context_menu_item/1`           | `div`   | Clickable menu item (role=menuitem)        |
  | `context_menu_separator/1`      | `hr`    | Visual divider between item groups         |
  | `context_menu_checkbox_item/1`  | `div`   | Toggleable item with check mark indicator  |
  | `context_menu_label/1`          | `div`   | Non-interactive section label              |

  ## Behaviour

  - Right-clicking on `context_menu_trigger/1` opens `context_menu_content/1`
    at the exact cursor position (via the `PhiaContextMenu` JS hook).
  - The hook prevents the native browser context menu.
  - Smart viewport-aware positioning: the panel flips direction if it would
    overflow the viewport edge.
  - Clicking outside the panel or pressing `Escape` closes it.
  - `ArrowUp` / `ArrowDown` navigate between items; `Enter` activates the
    focused item.

  ## Example

      <.context_menu id="file-ctx">
        <.context_menu_trigger context_menu_id="file-ctx">
          <div class="p-4 border rounded">Right-click me</div>
        </.context_menu_trigger>
        <.context_menu_content id="file-ctx-content">
          <.context_menu_label>File</.context_menu_label>
          <.context_menu_item phx-click="open">Open</.context_menu_item>
          <.context_menu_item phx-click="rename">Rename</.context_menu_item>
          <.context_menu_separator />
          <.context_menu_checkbox_item checked={@show_preview} phx-click="toggle_preview">
            Show Preview
          </.context_menu_checkbox_item>
        </.context_menu_content>
      </.context_menu>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # context_menu/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "Unique context menu ID")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the container div")

  slot(:inner_block, required: true, doc: "context_menu_trigger and context_menu_content")

  @doc "Renders the context menu root container."
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

  attr(:context_menu_id, :string, required: true, doc: "ID of the parent context_menu")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the trigger div")

  slot(:inner_block, required: true, doc: "Trigger content (right-clickable area)")

  @doc """
  Renders the context menu trigger area.

  Attach `phx-hook="PhiaContextMenu"` — the hook listens for the `contextmenu`
  event, prevents the native browser menu, and positions `context_menu_content/1`
  at the cursor location.
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
    doc: "Content element ID (must be context_menu_id <> '-content')"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the panel div")

  slot(:inner_block, required: true, doc: "Menu items")

  @doc """
  Renders the context menu content panel.

  Initially hidden via `display:none; position:fixed;`. The `PhiaContextMenu`
  hook reveals and positions the panel on right-click.
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
  attr(:rest, :global, doc: "HTML attributes forwarded to the item div (phx-click, etc.)")

  slot(:inner_block, required: true, doc: "Menu item content")

  @doc """
  Renders a context menu item with `role=menuitem`.

  Keyboard-navigable via `ArrowUp` / `ArrowDown`; activated with `Enter`.

      <.context_menu_item phx-click="open">Open file</.context_menu_item>
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
  attr(:rest, :global, doc: "HTML attributes forwarded to the hr element")

  @doc "Renders a horizontal separator between groups of menu items."
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

  attr(:checked, :boolean, default: false, doc: "Whether the checkbox item is checked")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the item div (phx-click, etc.)")

  slot(:inner_block, required: true, doc: "Checkbox item content")

  @doc """
  Renders a toggleable context menu item with a check mark indicator.

  Uses `role="menuitemcheckbox"` and `aria-checked` for accessibility.
  Pass the toggle action via `phx-click`.

      <.context_menu_checkbox_item checked={@show_grid} phx-click="toggle_grid">
        Show Grid
      </.context_menu_checkbox_item>
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
  attr(:rest, :global, doc: "HTML attributes forwarded to the label div")

  slot(:inner_block, required: true, doc: "Label text content")

  @doc "Renders a non-interactive section label inside the context menu."
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
