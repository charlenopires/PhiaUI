defmodule PhiaUi.Components.Menubar do
  @moduledoc """
  Menubar component — a horizontal bar of menus for application-level navigation.

  Follows the WAI-ARIA Menu Button pattern. Each menu within the bar is
  triggered by a button (`menubutton` role) and reveals a floating content
  panel (`menu` role) containing `menuitem` children.

  The component renders full DOM structure with `data-menubar-*` attributes for
  JS hook wiring. Content panels are hidden by default via the `hidden` class;
  a JS hook toggles visibility at runtime.

  ## Sub-components

  | Function              | Element  | Purpose                                     |
  |-----------------------|----------|---------------------------------------------|
  | `menubar/1`           | `div`    | Horizontal container with `role="menubar"`  |
  | `menubar_menu/1`      | `div`    | Relative wrapper for one menu + its content |
  | `menubar_trigger/1`   | `button` | Toggle button (`role="menubutton"`)          |
  | `menubar_content/1`   | `div`    | Floating panel (`role="menu"`, hidden)       |
  | `menubar_item/1`      | `button` | Clickable item (`role="menuitem"`)           |
  | `menubar_separator/1` | `div`    | Visual divider (`role="separator"`)          |

  ## Example

      <.menubar id="main-menubar">
        <.menubar_menu>
          <.menubar_trigger>File</.menubar_trigger>
          <.menubar_content>
            <.menubar_item on_click="new_file">New File</.menubar_item>
            <.menubar_separator />
            <.menubar_item on_click="save" shortcut="⌘S">Save</.menubar_item>
          </.menubar_content>
        </.menubar_menu>
        <.menubar_menu>
          <.menubar_trigger>Edit</.menubar_trigger>
          <.menubar_content>
            <.menubar_item disabled>Undo</.menubar_item>
          </.menubar_content>
        </.menubar_menu>
      </.menubar>

  ## Accessibility

  - The outer container has `role="menubar"`.
  - Each trigger button has `role="menubutton"`, `aria-haspopup="menu"`, and
    `aria-expanded="false"` (updated by the JS hook when the panel is open).
  - Each content panel has `role="menu"`.
  - Each item has `role="menuitem"`.
  - Disabled items use the HTML `disabled` attribute on the button, which
    prevents interaction while keeping the item visible.
  - Separators use `role="separator"`.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # menubar/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "Unique element ID for the menubar container")

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the container")

  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the container `<div>`")

  slot(:inner_block, required: true, doc: "One or more `menubar_menu/1` components")

  @doc """
  Renders the horizontal menubar container.

  This is the top-level wrapper that holds all menus. It uses `role="menubar"`
  to mark it as a menubar widget for assistive technology.
  """
  def menubar(assigns) do
    ~H"""
    <div
      id={@id}
      role="menubar"
      class={cn([
        "flex items-center gap-1 border border-border rounded-lg bg-background px-1 py-1",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # menubar_menu/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the menu container")

  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the container `<div>`")

  slot(:inner_block,
    required: true,
    doc: "Must contain one `menubar_trigger/1` and one `menubar_content/1`"
  )

  @doc """
  Renders the relative-positioned wrapper for a single menu within the menubar.

  Each `menubar_menu/1` groups a trigger button with its associated content
  panel. The `data-menubar-menu` attribute is used by the JS hook to discover
  menu boundaries for open/close behaviour and click-outside detection.
  """
  def menubar_menu(assigns) do
    ~H"""
    <div class={cn(["relative", @class])} data-menubar-menu {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # menubar_trigger/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the trigger button")

  attr(:disabled, :boolean,
    default: false,
    doc: "Disables the trigger button, preventing menu open"
  )

  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the `<button>`")

  slot(:inner_block, required: true, doc: "Trigger label content")

  @doc """
  Renders the trigger button for a menubar menu.

  Sets WAI-ARIA attributes for the menu button pattern:
  - `role="menubutton"` — identifies this as a menu-opening button
  - `aria-haspopup="menu"` — indicates the button controls a menu
  - `aria-expanded="false"` — initial closed state; the JS hook updates this

  The `disabled` attribute prevents interaction when set.
  """
  def menubar_trigger(assigns) do
    ~H"""
    <button
      type="button"
      role="menubutton"
      aria-haspopup="menu"
      aria-expanded="false"
      disabled={@disabled}
      class={cn([
        "inline-flex items-center gap-1 px-3 py-1.5 text-sm font-medium rounded-md",
        "hover:bg-accent focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
        @disabled && "pointer-events-none opacity-50",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # menubar_content/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the content panel")

  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the menu panel `<div>`")

  slot(:inner_block, doc: "Menu items and separators")

  @doc """
  Renders the floating content panel for a menubar menu.

  Hidden by default via the `hidden` Tailwind class. The JS hook removes this
  class when the associated trigger is activated and re-adds it on close.

  The panel uses `role="menu"` and is positioned absolutely below the trigger
  via `absolute left-0 top-full mt-1`.
  """
  def menubar_content(assigns) do
    ~H"""
    <div
      role="menu"
      data-menubar-content
      class={cn([
        "absolute left-0 top-full mt-1 z-50 min-w-[8rem] overflow-hidden",
        "rounded-md border border-border bg-popover p-1 shadow-md hidden",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # menubar_item/1
  # ---------------------------------------------------------------------------

  attr(:on_click, :string, default: nil, doc: "LiveView event name for `phx-click`")

  attr(:shortcut, :string,
    default: nil,
    doc: "Keyboard shortcut label displayed right-aligned (e.g. `⌘S`)"
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "Disables the item; adds `disabled` attr and visual dimming"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the item button")

  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the `<button>`")

  slot(:inner_block, required: true, doc: "Item label content")

  @doc """
  Renders a clickable menu item with `role="menuitem"`.

  Wire up a LiveView action with the `:on_click` attribute:

      <.menubar_item on_click="save">Save</.menubar_item>

  Add a keyboard shortcut hint with `:shortcut`:

      <.menubar_item on_click="save" shortcut="⌘S">Save</.menubar_item>

  Use `:disabled` to prevent interaction:

      <.menubar_item disabled>Undo</.menubar_item>
  """
  def menubar_item(assigns) do
    ~H"""
    <button
      type="button"
      role="menuitem"
      phx-click={@on_click}
      disabled={@disabled}
      class={cn([
        "relative flex w-full cursor-default select-none items-center rounded-sm px-2 py-1.5 text-sm outline-none",
        "hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground",
        @disabled && "opacity-50 cursor-not-allowed",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
      <span :if={@shortcut} class="ml-auto text-xs text-muted-foreground">
        {@shortcut}
      </span>
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # menubar_separator/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the separator")

  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the separator `<div>`")

  @doc """
  Renders a horizontal visual divider between groups of menu items.

  Uses `role="separator"` and the `bg-border` token for the line colour.
  The `-mx-1` negative margin ensures the separator spans the full width of
  the content panel.
  """
  def menubar_separator(assigns) do
    ~H"""
    <div role="separator" class={cn(["-mx-1 my-1 h-px bg-border", @class])} {@rest} />
    """
  end
end
