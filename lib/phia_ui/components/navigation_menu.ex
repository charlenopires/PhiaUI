defmodule PhiaUi.Components.NavigationMenu do
  @moduledoc """
  NavigationMenu component for PhiaUI.

  A fully accessible horizontal navigation menu with support for simple links
  and dropdown trigger+content panels. Follows WAI-ARIA navigation landmark
  patterns. CSS-only layout — dropdown visibility is controlled server-side.

  ## Sub-components

  - `navigation_menu/1` — root `<nav>` wrapper
  - `navigation_menu_list/1` — horizontal `<ul>` list
  - `navigation_menu_item/1` — `<li>` item, container for link or trigger+content
  - `navigation_menu_link/1` — a styled `<a>` link with active state
  - `navigation_menu_trigger/1` — a button that opens a dropdown panel
  - `navigation_menu_content/1` — the dropdown content panel

  ## Example

      <.navigation_menu>
        <.navigation_menu_list>
          <.navigation_menu_item>
            <.navigation_menu_link href="/" active={@current_path == "/"}>
              Home
            </.navigation_menu_link>
          </.navigation_menu_item>

          <.navigation_menu_item>
            <.navigation_menu_trigger label="Products" />
            <.navigation_menu_content>
              <ul class="grid grid-cols-2 gap-2 p-4">
                <li><a href="/products/web">Web</a></li>
                <li><a href="/products/mobile">Mobile</a></li>
              </ul>
            </.navigation_menu_content>
          </.navigation_menu_item>

          <.navigation_menu_item>
            <.navigation_menu_link href="/contact">Contact</.navigation_menu_link>
          </.navigation_menu_item>
        </.navigation_menu_list>
      </.navigation_menu>

  ## ARIA

  - `<nav>` root has `aria-label="Main navigation"`
  - Active links carry `aria-current="page"`
  - Triggers carry `aria-haspopup="true"` and `aria-expanded`
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # navigation_menu/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root nav element")
  attr(:rest, :global, doc: "HTML attributes forwarded to the nav element")

  slot(:inner_block, required: true, doc: "navigation_menu_list/1 child")

  @doc """
  Renders the navigation menu root `<nav>` element.

  Wraps `navigation_menu_list/1` and provides the ARIA landmark.
  """
  def navigation_menu(assigns) do
    ~H"""
    <nav
      aria-label="Main navigation"
      class={cn(["relative flex items-center", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </nav>
    """
  end

  # ---------------------------------------------------------------------------
  # navigation_menu_list/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the ul element")

  slot(:inner_block, required: true, doc: "navigation_menu_item/1 children")

  @doc """
  Renders the horizontal menu list.

  Contains `navigation_menu_item/1` children in a flex row.
  """
  def navigation_menu_list(assigns) do
    ~H"""
    <ul
      class={cn(["flex flex-row items-center gap-1", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </ul>
    """
  end

  # ---------------------------------------------------------------------------
  # navigation_menu_item/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the li element")

  slot(:inner_block, required: true, doc: "navigation_menu_link/1 or trigger+content children")

  @doc """
  Renders a single navigation menu item.

  Contains either a `navigation_menu_link/1` (simple link) or a
  `navigation_menu_trigger/1` + `navigation_menu_content/1` pair (dropdown).
  """
  def navigation_menu_item(assigns) do
    ~H"""
    <li class={cn(["relative", @class])} {@rest}>
      {render_slot(@inner_block)}
    </li>
    """
  end

  # ---------------------------------------------------------------------------
  # navigation_menu_link/1
  # ---------------------------------------------------------------------------

  attr(:href, :string, required: true, doc: "Link destination URL")
  attr(:active, :boolean, default: false, doc: "Whether this link is the current page")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the anchor element")

  slot(:inner_block, required: true, doc: "Link text/content")

  @doc """
  Renders a styled navigation link.

  Uses `aria-current="page"` when active. Applies `bg-accent` background
  for the active state so it is visually distinguishable.
  """
  def navigation_menu_link(assigns) do
    ~H"""
    <a
      href={@href}
      aria-current={if @active, do: "page", else: nil}
      class={cn([
        "inline-flex items-center rounded-md px-3 py-2 text-sm font-medium",
        "text-foreground transition-colors",
        "hover:bg-accent hover:text-accent-foreground",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
        @active && "bg-accent text-accent-foreground",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </a>
    """
  end

  # ---------------------------------------------------------------------------
  # navigation_menu_trigger/1
  # ---------------------------------------------------------------------------

  attr(:label, :string, required: true, doc: "Button label text")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the button element")

  @doc """
  Renders a trigger button for a dropdown navigation panel.

  Displays a label and a chevron-down icon. Carries `aria-haspopup="true"`.
  Pair with `navigation_menu_content/1` inside a `navigation_menu_item/1`.
  """
  def navigation_menu_trigger(assigns) do
    ~H"""
    <button
      type="button"
      aria-haspopup="true"
      aria-expanded="false"
      class={cn([
        "inline-flex items-center gap-1 rounded-md px-3 py-2 text-sm font-medium",
        "text-foreground transition-colors",
        "hover:bg-accent hover:text-accent-foreground",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
        @class
      ])}
      {@rest}
    >
      {@label}
      <.icon name="chevron-down" size={:xs} class="text-muted-foreground" />
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # navigation_menu_content/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the content div")

  slot(:inner_block, required: true, doc: "Dropdown content")

  @doc """
  Renders the dropdown content panel for a trigger.

  Positioned absolutely below its parent `navigation_menu_item/1`. Place
  immediately after a `navigation_menu_trigger/1` within the same item.
  """
  def navigation_menu_content(assigns) do
    ~H"""
    <div
      class={cn([
        "absolute left-0 top-full z-50 min-w-[220px] rounded-md border border-border",
        "bg-background p-2 shadow-md",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
