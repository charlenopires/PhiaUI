defmodule PhiaUi.Components.DropdownMenu do
  @moduledoc """
  DropdownMenu component with smart positioning, click-outside detection,
  and full WAI-ARIA keyboard navigation.

  Requires the `PhiaDropdownMenu` JavaScript Hook registered in `app.js`.

  ## Registration in app.js

      import PhiaDropdownMenu from "./phia_hooks/dropdown_menu.js"

      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaDropdownMenu, ...yourOtherHooks }
      })

  ## Sub-components

  | Function                          | Element | Purpose                              |
  |-----------------------------------|---------|--------------------------------------|
  | `dropdown_menu/1`                 | `div`   | Relative container + hook anchor     |
  | `dropdown_menu_trigger/1`         | `button`| Toggle button with ARIA attrs        |
  | `dropdown_menu_content/1`         | `div`   | Floating menu panel                  |
  | `dropdown_menu_item/1`            | `div`   | Clickable item (`:variant` default/destructive) |
  | `dropdown_menu_label/1`           | `div`   | Non-interactive section label        |
  | `dropdown_menu_separator/1`       | `hr`    | Visual divider                       |
  | `dropdown_menu_group/1`           | `div`   | Logical item grouping                |
  | `dropdown_menu_checkbox_item/1`   | `div`   | Toggle item with checkmark indicator |
  | `dropdown_menu_radio_group/1`     | `div`   | Container for mutually exclusive items |
  | `dropdown_menu_radio_item/1`      | `div`   | Radio item with bullet indicator     |
  | `dropdown_menu_shortcut/1`        | `span`  | Right-aligned keyboard shortcut hint |

  ## Example

      <.dropdown_menu id="user-menu">
        <.dropdown_menu_trigger>Account</.dropdown_menu_trigger>
        <.dropdown_menu_content>
          <.dropdown_menu_label>My Account</.dropdown_menu_label>
          <.dropdown_menu_separator />
          <.dropdown_menu_group>
            <.dropdown_menu_item phx-click="profile">Profile</.dropdown_menu_item>
            <.dropdown_menu_item phx-click="settings">Settings</.dropdown_menu_item>
          </.dropdown_menu_group>
          <.dropdown_menu_separator />
          <.dropdown_menu_item phx-click="logout">Log out</.dropdown_menu_item>
        </.dropdown_menu_content>
      </.dropdown_menu>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # dropdown_menu/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, default: nil, doc: "Unique ID — required when using the JS Hook")
  attr(:class, :string, default: nil)
  attr(:rest, :global, doc: "HTML attributes forwarded to the container div")

  slot(:inner_block, required: true, doc: "Trigger + content sub-components")

  @doc "Renders the relative container and JS Hook anchor for the dropdown."
  def dropdown_menu(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook={@id && "PhiaDropdownMenu"}
      class={cn(["relative inline-block", @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # dropdown_menu_trigger/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil)
  attr(:rest, :global, doc: "HTML attributes forwarded to the button element")

  slot(:inner_block, required: true, doc: "Trigger label or icon")

  @doc "Renders the trigger button with WAI-ARIA menu attributes."
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

  attr(:class, :string, default: nil)
  attr(:rest, :global, doc: "HTML attributes forwarded to the menu panel")

  slot(:inner_block, doc: "Menu items, labels, separators, and groups")

  @doc "Renders the floating menu panel. Hidden by default; shown by the JS Hook."
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
    doc: "Visual style variant — 'destructive' renders red text for dangerous actions"
  )

  attr(:class, :string, default: nil)
  attr(:disabled, :boolean, default: false, doc: "Marks the item as non-interactive")
  attr(:rest, :global, doc: "HTML attributes forwarded to the item element (phx-click, etc.)")

  slot(:inner_block, required: true, doc: "Item content")

  @doc """
  Renders a menu item with role=menuitem and keyboard navigation support.

  Use `variant="destructive"` for irreversible actions like deletion.
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

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, required: true, doc: "Label text for a group of items")

  @doc "Renders a non-interactive section label inside the menu."
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

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  @doc "Renders a horizontal separator between menu sections."
  def dropdown_menu_separator(assigns) do
    ~H"""
    <hr class={cn(["-mx-1 my-1 h-px border-0 bg-muted", @class])} {@rest} />
    """
  end

  # ---------------------------------------------------------------------------
  # dropdown_menu_group/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, required: true, doc: "Grouped menu items")

  @doc "Wraps a logical group of menu items."
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

  attr(:checked, :boolean, default: false, doc: "Whether the option is currently checked")
  attr(:disabled, :boolean, default: false, doc: "Marks the item as non-interactive")
  attr(:class, :string, default: nil)

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the item (phx-click, phx-value-*, etc.)"
  )

  slot(:inner_block, required: true, doc: "Item label")

  @doc """
  Renders a toggleable menu item with a checkmark indicator.

  Uses `role="menuitemcheckbox"` and `aria-checked` for accessibility.
  Pass the toggle event via `phx-click`.

      <.dropdown_menu_checkbox_item checked={@show_toolbar} phx-click="toggle_toolbar">
        Show Toolbar
      </.dropdown_menu_checkbox_item>
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

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, required: true, doc: "Radio items")

  @doc """
  Wraps a set of mutually exclusive `dropdown_menu_radio_item/1` components.

  Pass `checked={item_value == @selected_value}` to each child radio item —
  the group is a stateless container.

      <.dropdown_menu_radio_group>
        <.dropdown_menu_radio_item :for={opt <- @themes}
          checked={opt == @theme}
          phx-click="set_theme"
          phx-value-value={opt}>
          {opt}
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

  attr(:checked, :boolean, default: false, doc: "Whether this option is selected")
  attr(:disabled, :boolean, default: false, doc: "Marks the item as non-interactive")
  attr(:class, :string, default: nil)

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the item (phx-click, phx-value-*, etc.)"
  )

  slot(:inner_block, required: true, doc: "Item label")

  @doc """
  Renders a radio-style menu item.

  Uses `role="menuitemradio"` and `aria-checked`. Renders a filled bullet when
  `:checked` is true. Intended to be used inside `dropdown_menu_radio_group/1`.
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

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, required: true, doc: "Shortcut text, e.g. '⌘K' or 'Ctrl+S'")

  @doc """
  Renders a right-aligned keyboard shortcut hint inside a menu item.

      <.dropdown_menu_item>
        New File
        <.dropdown_menu_shortcut>⌘N</.dropdown_menu_shortcut>
      </.dropdown_menu_item>
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
end
