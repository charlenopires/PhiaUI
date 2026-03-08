defmodule PhiaUi.Components.DropdownMenu do
  @moduledoc """
  Dropdown menu component with smart positioning, click-outside detection,
  and full WAI-ARIA keyboard navigation.

  Requires the `PhiaDropdownMenu` JavaScript hook registered in `app.js`.
  The hook handles all interactivity: opening/closing the panel, focusing
  the first menu item on open, and full keyboard navigation (Arrow keys,
  Home, End, Escape, Tab).

  ## Hook Registration

  Copy the hook via `mix phia.add dropdown_menu`, then register it:

      # assets/js/app.js
      import PhiaDropdownMenu from "./hooks/dropdown_menu"

      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaDropdownMenu }
      })

  ## Sub-components

  | Function                          | Element  | Purpose                                          |
  |-----------------------------------|----------|--------------------------------------------------|
  | `dropdown_menu/1`                 | `div`    | Relative container — JS hook anchor              |
  | `dropdown_menu_trigger/1`         | `button` | Toggle button with `aria-haspopup`/`aria-expanded` |
  | `dropdown_menu_content/1`         | `div`    | Floating menu panel (`role="menu"`)              |
  | `dropdown_menu_item/1`            | `div`    | Clickable item (`role="menuitem"`)               |
  | `dropdown_menu_label/1`           | `div`    | Non-interactive section heading                  |
  | `dropdown_menu_separator/1`       | `hr`     | Visual divider between sections                  |
  | `dropdown_menu_group/1`           | `div`    | Logical grouping wrapper                         |
  | `dropdown_menu_checkbox_item/1`   | `div`    | Toggle item (`role="menuitemcheckbox"`)           |
  | `dropdown_menu_radio_group/1`     | `div`    | Container for mutually exclusive items           |
  | `dropdown_menu_radio_item/1`      | `div`    | Radio item (`role="menuitemradio"`)              |
  | `dropdown_menu_shortcut/1`        | `span`   | Right-aligned keyboard shortcut hint             |

  ## Basic Example — Account Menu

      <.dropdown_menu id="user-menu">
        <.dropdown_menu_trigger>
          My Account
        </.dropdown_menu_trigger>
        <.dropdown_menu_content>
          <.dropdown_menu_label>My Account</.dropdown_menu_label>
          <.dropdown_menu_separator />
          <.dropdown_menu_group>
            <.dropdown_menu_item phx-click="goto_profile">
              Profile
              <.dropdown_menu_shortcut>⌘P</.dropdown_menu_shortcut>
            </.dropdown_menu_item>
            <.dropdown_menu_item phx-click="goto_settings">
              Settings
              <.dropdown_menu_shortcut>⌘S</.dropdown_menu_shortcut>
            </.dropdown_menu_item>
          </.dropdown_menu_group>
          <.dropdown_menu_separator />
          <.dropdown_menu_item variant="destructive" phx-click="logout">
            Log out
          </.dropdown_menu_item>
        </.dropdown_menu_content>
      </.dropdown_menu>

  ## Checkbox Items Example — View Options

      <.dropdown_menu id="view-menu">
        <.dropdown_menu_trigger>View</.dropdown_menu_trigger>
        <.dropdown_menu_content>
          <.dropdown_menu_label>Appearance</.dropdown_menu_label>
          <.dropdown_menu_separator />
          <.dropdown_menu_checkbox_item
            checked={@show_toolbar}
            phx-click="toggle_toolbar">
            Show Toolbar
          </.dropdown_menu_checkbox_item>
          <.dropdown_menu_checkbox_item
            checked={@show_statusbar}
            phx-click="toggle_statusbar">
            Show Status Bar
          </.dropdown_menu_checkbox_item>
        </.dropdown_menu_content>
      </.dropdown_menu>

  ## Radio Items Example — Theme Selector

      <.dropdown_menu id="theme-menu">
        <.dropdown_menu_trigger>Theme</.dropdown_menu_trigger>
        <.dropdown_menu_content>
          <.dropdown_menu_radio_group>
            <.dropdown_menu_radio_item
              :for={theme <- ~w(Light Dark System)}
              checked={theme == @current_theme}
              phx-click="set_theme"
              phx-value-theme={theme}>
              {theme}
            </.dropdown_menu_radio_item>
          </.dropdown_menu_radio_group>
        </.dropdown_menu_content>
      </.dropdown_menu>

  ## Keyboard Navigation

  The `PhiaDropdownMenu` hook provides full WAI-ARIA keyboard support:
  - `Enter` / `Space` — opens the menu when trigger is focused
  - `ArrowDown` / `ArrowUp` — moves focus between items
  - `Home` / `End` — jumps to first / last item
  - `Escape` — closes the menu and returns focus to the trigger
  - `Tab` — closes the menu naturally (focus leaves the component)

  ## Accessibility

  - Trigger has `aria-haspopup="menu"` and `aria-expanded` (toggled by hook)
  - Menu panel has `role="menu"` and `aria-orientation="vertical"`
  - Each item has `role="menuitem"` (or `menuitemcheckbox` / `menuitemradio`)
  - Disabled items use `aria-disabled="true"` and `pointer-events-none` rather
    than the HTML `disabled` attribute, because `disabled` removes items from
    the accessibility tree and breaks keyboard navigation
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # dropdown_menu/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    default: nil,
    doc: """
    Unique element ID. **Required** when using the `PhiaDropdownMenu` JS hook —
    without it the hook will not attach and the menu will not be interactive.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the container")

  attr(:rest, :global, doc: "Any extra HTML attributes forwarded to the container `<div>`")

  slot(:inner_block,
    required: true,
    doc: "Must contain exactly one `dropdown_menu_trigger/1` and one `dropdown_menu_content/1`"
  )

  @doc """
  Renders the relative-positioned container that anchors the JS hook.

  This `<div>` is the hook mount point. The hook uses it as the boundary for
  click-outside detection and as the positioning reference for the floating
  content panel.

  The `id` attribute is used by `phx-hook` — omitting it means the hook will
  not attach and the menu will render but not function.
  """
  def dropdown_menu(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook={@id && "PhiaDropdownMenu"}
      class={cn(["relative inline-block z-50", @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # dropdown_menu_trigger/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the trigger button")

  attr(:rest, :global,
    doc: "Extra HTML attributes forwarded to the `<button>` (e.g. `phx-click`, `disabled`)"
  )

  slot(:inner_block, required: true, doc: "Trigger label, text, or icon content")

  @doc """
  Renders the trigger button that opens and closes the dropdown menu.

  Sets the WAI-ARIA attributes required for menu buttons:
  - `aria-haspopup="menu"` — tells assistive technology that activating this
    button reveals a menu
  - `aria-expanded="false"` — initial state; the JS hook updates this to
    `"true"` when the menu is open

  The hook also handles the `Enter`, `Space`, and `ArrowDown` key events on
  this button to open the menu and immediately move focus to the first item.
  """
  def dropdown_menu_trigger(assigns) do
    ~H"""
    <button
      type="button"
      aria-haspopup="menu"
      aria-expanded="false"
      data-dropdown-trigger
      class={cn([
        "inline-flex items-center justify-center rounded-md text-sm font-medium",
        "ring-offset-background transition-colors",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # dropdown_menu_content/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the floating panel")

  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the menu panel `<div>`")

  slot(:inner_block,
    doc: "Menu items, labels, separators, and groups"
  )

  @doc """
  Renders the floating menu panel.

  Hidden by default via `display: none` (the `hidden` Tailwind class). The
  `PhiaDropdownMenu` hook removes the hidden class and positions the panel
  relative to the trigger when the menu is opened.

  The panel uses `role="menu"` and `aria-orientation="vertical"`, which tells
  screen readers that the Arrow keys should navigate between the contained
  `role="menuitem"` children.

  The `min-w-[8rem]` ensures the panel never collapses to the trigger width —
  useful when the trigger is a small icon button.
  """
  def dropdown_menu_content(assigns) do
    ~H"""
    <div
      role="menu"
      aria-orientation="vertical"
      data-dropdown-content
      class={cn([
        "absolute z-50 min-w-[8rem] hidden",
        "overflow-hidden rounded-md border bg-popover p-1 text-popover-foreground shadow-md",
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # dropdown_menu_item/1
  # ---------------------------------------------------------------------------

  attr(:variant, :string,
    default: "default",
    values: ~w(default destructive),
    doc: """
    Visual style variant.
    - `"default"` — standard muted hover style
    - `"destructive"` — red text with red hover background; use for irreversible
      actions like deleting records or revoking access
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the item")

  attr(:disabled, :boolean,
    default: false,
    doc: """
    Marks the item as non-interactive. Applies `aria-disabled="true"`,
    `pointer-events-none`, and `opacity-50`. Note: uses `aria-disabled` rather
    than the HTML `disabled` attribute so the item remains in the focus order
    and screen readers can still announce it as disabled.
    """
  )

  attr(:rest, :global,
    doc: "Extra HTML attributes forwarded to the item `<div>` (e.g. `phx-click`, `phx-value-*`)"
  )

  slot(:inner_block, required: true, doc: "Item content — text, icon, and optional shortcut")

  @doc """
  Renders a clickable menu item with `role="menuitem"`.

  Wire up a LiveView action with `phx-click`. For actions that carry data,
  use `phx-value-*` attributes:

      <.dropdown_menu_item phx-click="set_status" phx-value-status="active">
        Mark as Active
      </.dropdown_menu_item>

  For destructive actions, add the `variant="destructive"` to give users a
  clear visual warning:

      <.dropdown_menu_item variant="destructive" phx-click="delete_record">
        Delete
        <.dropdown_menu_shortcut>⌘⌫</.dropdown_menu_shortcut>
      </.dropdown_menu_item>

  The `tabindex="-1"` removes items from the natural Tab order — the JS hook
  manages focus programmatically via `ArrowUp` / `ArrowDown`, matching the
  WAI-ARIA Menu Button pattern.
  """
  def dropdown_menu_item(assigns) do
    ~H"""
    <div
      role="menuitem"
      tabindex="-1"
      data-dropdown-item
      aria-disabled={@disabled && "true"}
      class={cn([
        "relative flex cursor-default select-none items-center rounded-sm px-2 py-1.5 text-sm outline-none",
        "transition-colors focus:bg-accent focus:text-accent-foreground",
        "hover:bg-accent hover:text-accent-foreground",
        @variant == "destructive" &&
          "text-destructive focus:bg-destructive/10 focus:text-destructive hover:bg-destructive/10 hover:text-destructive",
        @disabled && "pointer-events-none opacity-50",
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # dropdown_menu_label/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the label `<div>`")

  slot(:inner_block, required: true, doc: "Label text for a section of related menu items")

  @doc """
  Renders a non-interactive section heading inside the menu.

  Use labels to group related items semantically. Place a label before each
  `dropdown_menu_group/1` or above a cluster of related items:

      <.dropdown_menu_label>My Account</.dropdown_menu_label>
      <.dropdown_menu_separator />
      <.dropdown_menu_group>
        <.dropdown_menu_item phx-click="profile">Profile</.dropdown_menu_item>
        <.dropdown_menu_item phx-click="billing">Billing</.dropdown_menu_item>
      </.dropdown_menu_group>

  Labels are not focusable and do not have a `role` attribute — they are
  presentational only.
  """
  def dropdown_menu_label(assigns) do
    ~H"""
    <div class={cn(["px-2 py-1.5 text-sm font-semibold", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # dropdown_menu_separator/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the `<hr>`")

  @doc """
  Renders a horizontal visual separator between groups of menu items.

  Use separators to create clear visual boundaries between groups of related
  actions. Rendered as an `<hr>` with `role` implied by the element type.

      <.dropdown_menu_item phx-click="profile">Profile</.dropdown_menu_item>
      <.dropdown_menu_separator />
      <.dropdown_menu_item variant="destructive" phx-click="logout">
        Log out
      </.dropdown_menu_item>
  """
  def dropdown_menu_separator(assigns) do
    ~H"""
    <hr class={cn(["-mx-1 my-1 h-px border-0 bg-muted", @class])} {@rest} />
    """
  end

  # ---------------------------------------------------------------------------
  # dropdown_menu_group/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the group `<div>`")

  slot(:inner_block, required: true, doc: "Grouped menu items")

  @doc """
  Wraps a logical group of menu items together.

  `dropdown_menu_group/1` is a layout-only wrapper — it does not render any
  visible elements of its own. Use it to keep related items visually and
  semantically together, especially when separated from other groups by a
  `dropdown_menu_separator/1`.

      <.dropdown_menu_group>
        <.dropdown_menu_item phx-click="copy">Copy</.dropdown_menu_item>
        <.dropdown_menu_item phx-click="cut">Cut</.dropdown_menu_item>
        <.dropdown_menu_item phx-click="paste">Paste</.dropdown_menu_item>
      </.dropdown_menu_group>
  """
  def dropdown_menu_group(assigns) do
    ~H"""
    <div class={cn([@class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # dropdown_menu_checkbox_item/1
  # ---------------------------------------------------------------------------

  attr(:checked, :boolean,
    default: false,
    doc:
      "Whether the option is currently checked (enabled). Drives `aria-checked` and the checkmark icon."
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "Marks the item as non-interactive — applies `aria-disabled` and `opacity-50`"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")

  attr(:rest, :global,
    doc: "Extra HTML attributes forwarded to the item `<div>` (e.g. `phx-click`, `phx-value-*`)"
  )

  slot(:inner_block, required: true, doc: "Item label text")

  @doc """
  Renders a toggleable menu item with a checkmark indicator.

  Uses `role="menuitemcheckbox"` and `aria-checked` so assistive technology
  announces the current state. Manage state in your LiveView and pass a
  boolean to `:checked`:

      # In the LiveView
      def handle_event("toggle_toolbar", _params, socket) do
        {:noreply, update(socket, :show_toolbar, &(!&1))}
      end

      # In the template
      <.dropdown_menu_checkbox_item
        checked={@show_toolbar}
        phx-click="toggle_toolbar">
        Show Toolbar
      </.dropdown_menu_checkbox_item>

  The checkmark icon is rendered with an inline SVG only when `:checked` is
  `true` — no external icon dependency needed.
  """
  def dropdown_menu_checkbox_item(assigns) do
    ~H"""
    <div
      role="menuitemcheckbox"
      tabindex="-1"
      data-dropdown-item
      aria-checked={to_string(@checked)}
      aria-disabled={@disabled && "true"}
      class={cn([
        "relative flex cursor-default select-none items-center rounded-sm py-1.5 pl-8 pr-2 text-sm outline-none",
        "transition-colors focus:bg-accent focus:text-accent-foreground",
        "hover:bg-accent hover:text-accent-foreground",
        @disabled && "pointer-events-none opacity-50",
        @class
      ])}
      {@rest}
    >
      <%!-- Checkmark indicator: rendered only when the item is checked --%>
      <span class="absolute left-2 flex h-3.5 w-3.5 items-center justify-center">
        <%= if @checked do %>
          <svg
            class="h-4 w-4"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <polyline points="20 6 9 17 4 12" />
          </svg>
        <% end %>
      </span>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # dropdown_menu_radio_group/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the group `<div>`")

  slot(:inner_block, required: true, doc: "`dropdown_menu_radio_item/1` children")

  @doc """
  Wraps a set of mutually exclusive `dropdown_menu_radio_item/1` components.

  This component is a stateless container — it does not manage which item is
  selected. Pass `checked={item_value == @selected_value}` to each child item
  and handle state in your LiveView:

      # In the LiveView
      def handle_event("set_sort", %{"value" => value}, socket) do
        {:noreply, assign(socket, :sort_by, value)}
      end

      # In the template
      <.dropdown_menu_radio_group>
        <.dropdown_menu_radio_item
          :for={opt <- ~w(name date size)}
          checked={opt == @sort_by}
          phx-click="set_sort"
          phx-value-value={opt}>
          Sort by {opt}
        </.dropdown_menu_radio_item>
      </.dropdown_menu_radio_group>
  """
  def dropdown_menu_radio_group(assigns) do
    ~H"""
    <div role="group" class={cn([@class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # dropdown_menu_radio_item/1
  # ---------------------------------------------------------------------------

  attr(:checked, :boolean,
    default: false,
    doc:
      "Whether this option is currently selected. Drives `aria-checked` and the bullet indicator."
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "Marks the item as non-interactive"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")

  attr(:rest, :global,
    doc: "Extra HTML attributes forwarded to the item `<div>` (e.g. `phx-click`, `phx-value-*`)"
  )

  slot(:inner_block, required: true, doc: "Item label text")

  @doc """
  Renders a radio-style menu item with a filled bullet indicator.

  Uses `role="menuitemradio"` and `aria-checked`. Intended for use inside
  `dropdown_menu_radio_group/1` to represent a group of mutually exclusive
  options such as sort order, view mode, or theme selection.

  The filled circle SVG is rendered inline only when `:checked` is `true`,
  keeping the DOM lean when the item is not selected.
  """
  def dropdown_menu_radio_item(assigns) do
    ~H"""
    <div
      role="menuitemradio"
      tabindex="-1"
      data-dropdown-item
      aria-checked={to_string(@checked)}
      aria-disabled={@disabled && "true"}
      class={cn([
        "relative flex cursor-default select-none items-center rounded-sm py-1.5 pl-8 pr-2 text-sm outline-none",
        "transition-colors focus:bg-accent focus:text-accent-foreground",
        "hover:bg-accent hover:text-accent-foreground",
        @disabled && "pointer-events-none opacity-50",
        @class
      ])}
      {@rest}
    >
      <%!-- Bullet indicator: rendered only when this radio item is selected --%>
      <span class="absolute left-2 flex h-3.5 w-3.5 items-center justify-center">
        <%= if @checked do %>
          <svg class="h-2 w-2 fill-current" viewBox="0 0 24 24">
            <circle cx="12" cy="12" r="10" />
          </svg>
        <% end %>
      </span>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # dropdown_menu_shortcut/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the `<span>`")

  slot(:inner_block, required: true, doc: "Shortcut text, e.g. `⌘K`, `Ctrl+S`, or `Del`")

  @doc """
  Renders a right-aligned keyboard shortcut hint inside a menu item.

  This is a purely presentational hint — it does not register any event
  listeners. The shortcut text should match an actual keyboard shortcut
  handled elsewhere in your application.

      <.dropdown_menu_item phx-click="new_file">
        New File
        <.dropdown_menu_shortcut>⌘N</.dropdown_menu_shortcut>
      </.dropdown_menu_item>

      <.dropdown_menu_item variant="destructive" phx-click="delete">
        Delete
        <.dropdown_menu_shortcut>⌘⌫</.dropdown_menu_shortcut>
      </.dropdown_menu_item>

  The `ml-auto` class pushes the shortcut to the far right of the flex
  container, aligned opposite the item label.
  """
  def dropdown_menu_shortcut(assigns) do
    ~H"""
    <span
      class={cn(["ml-auto text-xs tracking-widest opacity-60", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end

  # ---------------------------------------------------------------------------
  # dropdown_menu_sub/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the sub-menu wrapper")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the wrapper `<div>`")

  slot(:inner_block, required: true, doc: "Must contain a sub_trigger and sub_content")

  @doc """
  Wraps a submenu — a trigger item that reveals a nested menu panel.

  Place inside `dropdown_menu_content/1`. Requires exactly one
  `dropdown_menu_sub_trigger/1` and one `dropdown_menu_sub_content/1` child.
  """
  def dropdown_menu_sub(assigns) do
    ~H"""
    <div class={cn(["relative", @class])} data-dropdown-sub {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # dropdown_menu_sub_trigger/1
  # ---------------------------------------------------------------------------

  attr(:disabled, :boolean, default: false, doc: "Marks the trigger as non-interactive")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the trigger `<div>`")

  slot(:inner_block, required: true, doc: "Trigger label text")

  @doc """
  Renders an item that opens a submenu on hover or click.

  Displays a chevron-right arrow on the right edge to indicate there are
  nested items. The arrow is rendered inline — no icon dependency needed.
  """
  def dropdown_menu_sub_trigger(assigns) do
    ~H"""
    <div
      role="menuitem"
      tabindex="-1"
      data-dropdown-item
      data-dropdown-sub-trigger
      aria-haspopup="menu"
      aria-expanded="false"
      aria-disabled={@disabled && "true"}
      class={cn([
        "relative flex cursor-default select-none items-center justify-between rounded-sm px-2 py-1.5 text-sm outline-none",
        "transition-colors focus:bg-accent focus:text-accent-foreground",
        "hover:bg-accent hover:text-accent-foreground",
        @disabled && "pointer-events-none opacity-50",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
      <svg
        class="ml-2 h-4 w-4 shrink-0 opacity-60"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
      >
        <polyline points="9 18 15 12 9 6" />
      </svg>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # dropdown_menu_sub_content/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the sub-menu panel")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the panel `<div>`")

  slot(:inner_block, required: true, doc: "Nested menu items")

  @doc """
  Renders the submenu content panel positioned to the right of the trigger.

  Hidden by default via `hidden`. The `PhiaDropdownMenu` hook shows this panel
  when the parent `dropdown_menu_sub_trigger/1` is hovered or clicked.
  """
  def dropdown_menu_sub_content(assigns) do
    ~H"""
    <div
      role="menu"
      aria-orientation="vertical"
      data-dropdown-sub-content
      class={cn([
        "absolute left-full top-0 z-50 min-w-[180px] hidden",
        "overflow-hidden rounded-md border bg-popover p-1 text-popover-foreground shadow-md",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
