defmodule PhiaUi.Components.NavigationMenu do
  @moduledoc """
  Horizontal navigation menu with optional dropdown panels.

  A fully accessible horizontal navigation bar following the WAI-ARIA
  navigation landmark pattern. Supports both simple link items and
  trigger-plus-content dropdown panels. CSS-only layout — no JavaScript
  hook is required for static dropdowns; use server-side `assigns` to
  toggle panel visibility when needed.

  ## Sub-components

  | Component                    | Element    | Purpose                                          |
  |------------------------------|------------|--------------------------------------------------|
  | `navigation_menu/1`          | `<nav>`    | Root landmark with `aria-label="Main navigation"`|
  | `navigation_menu_list/1`     | `<ul>`     | Horizontal flex list of items                    |
  | `navigation_menu_item/1`     | `<li>`     | Container for a link or trigger+content pair     |
  | `navigation_menu_link/1`     | `<a>`      | Styled link with active-state highlight          |
  | `navigation_menu_trigger/1`  | `<button>` | Dropdown toggle button with chevron icon         |
  | `navigation_menu_content/1`  | `<div>`    | Absolutely-positioned dropdown panel             |

  ## Simple links only

      <.navigation_menu>
        <.navigation_menu_list>
          <.navigation_menu_item>
            <.navigation_menu_link href="/" active={@current_path == "/"}>
              Home
            </.navigation_menu_link>
          </.navigation_menu_item>
          <.navigation_menu_item>
            <.navigation_menu_link href="/pricing" active={@current_path == "/pricing"}>
              Pricing
            </.navigation_menu_link>
          </.navigation_menu_item>
          <.navigation_menu_item>
            <.navigation_menu_link href="/contact" active={@current_path == "/contact"}>
              Contact
            </.navigation_menu_link>
          </.navigation_menu_item>
        </.navigation_menu_list>
      </.navigation_menu>

  ## With a dropdown panel

  Pair `navigation_menu_trigger/1` and `navigation_menu_content/1` inside
  the same `navigation_menu_item/1`. The content panel is positioned
  absolutely below the item:

      <.navigation_menu>
        <.navigation_menu_list>
          <.navigation_menu_item>
            <.navigation_menu_link href="/" active={@current_path == "/"}>Home</.navigation_menu_link>
          </.navigation_menu_item>

          <.navigation_menu_item>
            <.navigation_menu_trigger label="Products" />
            <.navigation_menu_content>
              <ul class="grid grid-cols-2 gap-3 p-4 w-[400px]">
                <li>
                  <a href="/products/web" class="block rounded-md p-3 hover:bg-accent">
                    <p class="font-medium">Web Platform</p>
                    <p class="text-sm text-muted-foreground">Build scalable web apps</p>
                  </a>
                </li>
                <li>
                  <a href="/products/mobile" class="block rounded-md p-3 hover:bg-accent">
                    <p class="font-medium">Mobile SDK</p>
                    <p class="text-sm text-muted-foreground">Native iOS and Android</p>
                  </a>
                </li>
              </ul>
            </.navigation_menu_content>
          </.navigation_menu_item>

          <.navigation_menu_item>
            <.navigation_menu_link href="/docs">Docs</.navigation_menu_link>
          </.navigation_menu_item>
        </.navigation_menu_list>
      </.navigation_menu>

  ## Marking the current page

  Pass `active={true}` to `navigation_menu_link/1` for the item matching the
  current route. In a LiveView, compare against `@current_path` or use the
  route helpers:

      active={URI.parse(@current_url).path == "/pricing"}

  ## Accessibility

  - The `<nav>` root has `aria-label="Main navigation"` to distinguish it
    from other navigation landmarks (e.g. breadcrumb, pagination).
  - Active links carry `aria-current="page"` so screen readers announce the
    current location.
  - Trigger buttons carry `aria-haspopup="true"` and `aria-expanded="false"`
    to communicate dropdown availability to assistive technologies.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # navigation_menu/1
  # ---------------------------------------------------------------------------

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the root `<nav>` element."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<nav>` element.")

  slot(:inner_block, required: true, doc: "Should contain a single `navigation_menu_list/1`.")

  @doc """
  Renders the navigation menu root `<nav>` element.

  Provides the `aria-label="Main navigation"` landmark. Place a
  `navigation_menu_list/1` inside.

  ## Example

      <.navigation_menu>
        <.navigation_menu_list>
          ...
        </.navigation_menu_list>
      </.navigation_menu>
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

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the `<ul>` element."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<ul>` element.")

  slot(:inner_block, required: true, doc: "Should contain `navigation_menu_item/1` children.")

  @doc """
  Renders the horizontal menu list.

  Uses `flex flex-row items-center gap-1` for a compact horizontal layout.
  Place `navigation_menu_item/1` children inside.
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

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the `<li>` element."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<li>` element.")

  slot(:inner_block,
    required: true,
    doc:
      "A `navigation_menu_link/1` alone, or a `navigation_menu_trigger/1` + `navigation_menu_content/1` pair."
  )

  @doc """
  Renders a single navigation menu item.

  Each item is a `<li>` with `position: relative` so that dropdown content
  panels can be absolutely positioned relative to it.

  Use case A — simple link:

      <.navigation_menu_item>
        <.navigation_menu_link href="/about">About</.navigation_menu_link>
      </.navigation_menu_item>

  Use case B — dropdown:

      <.navigation_menu_item>
        <.navigation_menu_trigger label="Resources" />
        <.navigation_menu_content>
          ...
        </.navigation_menu_content>
      </.navigation_menu_item>
  """
  def navigation_menu_item(assigns) do
    ~H"""
    <li class={cn(["relative z-50", @class])} {@rest}>
      {render_slot(@inner_block)}
    </li>
    """
  end

  # ---------------------------------------------------------------------------
  # navigation_menu_link/1
  # ---------------------------------------------------------------------------

  attr(:href, :string, required: true, doc: "The link destination URL.")

  attr(:active, :boolean,
    default: false,
    doc:
      "Whether this link represents the current page. Sets `aria-current=\"page\"` and applies an accent background."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes applied to the `<a>` element.")

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the `<a>` element (e.g. `target`, `rel`)."
  )

  slot(:inner_block, required: true, doc: "Link text or content.")

  @doc """
  Renders a styled navigation link.

  When `active={true}`, the link receives:
  - `aria-current="page"` for screen readers.
  - `bg-accent text-accent-foreground` background to visually indicate the
    current location.

  On hover, all links display an accent background for clear affordance.
  Focus is indicated via a `ring-2 ring-ring` outline.

  ## Example

      <.navigation_menu_link href="/blog" active={String.starts_with?(@path, "/blog")}>
        Blog
      </.navigation_menu_link>
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

  attr(:label, :string, required: true, doc: "The button label text shown in the navigation bar.")

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the `<button>` element."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<button>` element.")

  @doc """
  Renders a trigger button that opens a dropdown navigation panel.

  Displays the `label` text and a small `chevron-down` icon. Carries
  `aria-haspopup="true"` and `aria-expanded="false"` to communicate
  dropdown availability to assistive technologies.

  Always pair with `navigation_menu_content/1` inside the same
  `navigation_menu_item/1`:

      <.navigation_menu_item>
        <.navigation_menu_trigger label="Solutions" />
        <.navigation_menu_content>
          ...dropdown content...
        </.navigation_menu_content>
      </.navigation_menu_item>

  To control visibility server-side, wrap the content panel in a
  `<div :if={@open}>` or toggle a CSS class.
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
      <%!-- Chevron communicates that this button opens a dropdown panel --%>
      <.icon name="chevron-down" size={:xs} class="text-muted-foreground" />
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # navigation_menu_content/1
  # ---------------------------------------------------------------------------

  attr(:class, :string,
    default: nil,
    doc:
      "Additional CSS classes applied to the content `<div>`. Use `w-[N]` to control panel width."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the content `<div>`.")

  slot(:inner_block,
    required: true,
    doc: "Dropdown content — typically a grid of links or descriptions."
  )

  @doc """
  Renders the dropdown content panel for a trigger.

  Positioned absolutely (`top-full left-0 z-50`) below its parent
  `navigation_menu_item/1`. Always place it immediately after a
  `navigation_menu_trigger/1` inside the same `navigation_menu_item/1`.

  The panel has a border, background, rounded corners, and box shadow.
  Use `class="w-[400px]"` or similar to control the panel width.

  ## Example

      <.navigation_menu_content class="w-[320px]">
        <ul class="grid gap-2 p-4">
          <li>
            <a href="/docs/getting-started" class="block rounded-md p-2 hover:bg-accent">
              Getting Started
            </a>
          </li>
        </ul>
      </.navigation_menu_content>
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
