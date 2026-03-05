defmodule PhiaUi.Components.Sidebar do
  @moduledoc """
  Sidebar navigation component with brand area, scrollable nav, and pinned footer.

  Provides three components:

  - `sidebar/1` — collapsible 240 px aside with `:default`/`:dark` variants
  - `sidebar_item/1` — navigation link with active highlight, icon, and badge
  - `sidebar_section/1` — groups nav items under an uppercase section label

  ## Example

      <.sidebar variant={:default}>
        <:brand>
          <img src="/logo.svg" alt="Acme" class="h-6 w-auto" />
        </:brand>
        <:nav_items>
          <.sidebar_section label="Main Menu">
            <.sidebar_item href="/dashboard" active={@live_action == :index}>
              Dashboard
            </.sidebar_item>
          </.sidebar_section>
        </:nav_items>
        <:footer_items>
          <.sidebar_item href="/settings">Settings</.sidebar_item>
        </:footer_items>
      </.sidebar>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # sidebar/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    default: "sidebar-drawer",
    doc: """
    Element ID used by `mobile_sidebar_toggle/1`'s `JS.toggle/1` call.
    Keep the default unless you render multiple shells on the same page.
    """
  )

  attr(:collapsed, :boolean,
    default: false,
    doc: """
    When `true`, translates the sidebar off-screen via `-translate-x-full`.
    Useful for programmatic collapse without the mobile overlay pattern.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")

  attr(:variant, :atom,
    values: [:default, :dark],
    default: :default,
    doc: """
    Visual variant for the sidebar background.

    - `:default` — uses `--sidebar-background` and `--sidebar-foreground` tokens,
      which respect the current color theme and dark mode.
    - `:dark` — forces a dark background regardless of color mode. Applies
      `dark bg-sidebar-background text-sidebar-foreground` classes directly,
      producing the "always dark" look used by tools like Vercel or Linear.
    """
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the aside element")

  slot(:brand,
    doc: """
    Logo or application name area rendered at the top of the sidebar inside a
    `h-14` row that aligns with the topbar height. Typically holds a wordmark,
    icon-plus-name combo, or workspace switcher.
    """
  )

  slot(:nav_items,
    doc: """
    Primary navigation items (the main middle section of the sidebar).
    This slot is placed in an `overflow-y-auto` `<nav>` element so that
    long navigation lists scroll independently of the footer.
    Use `sidebar_section/1` and `sidebar_item/1` inside this slot.
    """
  )

  slot(:footer_items,
    doc: """
    Secondary items anchored to the bottom of the sidebar (above the fold).
    Typically holds Settings and Help links. Rendered in a `shrink-0` div
    with a top border separating it from the primary nav.
    """
  )

  slot(:inner_block,
    doc: """
    Fallback slot for fully custom sidebar content when the named slots
    (`:brand`, `:nav_items`, `:footer_items`) do not provide enough structure.
    Only rendered when `:nav_items` is empty.
    """
  )

  @doc """
  Responsive sidebar with brand area, scrollable nav, and pinned footer.

  The sidebar is **always 240 px wide** (set on the CSS Grid column). On desktop
  it is a static grid cell with `flex flex-col` and `border-r`. On mobile the
  parent `shell/1` component manages its visibility as an overlay.

  The layout is a vertical flex container divided into three parts:

      ┌──────────────────────────┐  ← h-14 brand area (shrink-0, border-b)
      │  brand slot              │
      ├──────────────────────────┤
      │                          │  ← flex-1, overflow-y-auto
      │  nav_items slot          │
      │                          │
      ├──────────────────────────┤  ← shrink-0, border-t
      │  footer_items slot       │
      └──────────────────────────┘

  ## Example

      <.sidebar variant={:default}>
        <:brand>
          <img src="/logo.svg" alt="Acme" class="h-6 w-auto" />
        </:brand>
        <:nav_items>
          <.sidebar_item href="/dashboard" active>Dashboard</.sidebar_item>
        </:nav_items>
        <:footer_items>
          <.sidebar_item href="/settings">Settings</.sidebar_item>
        </:footer_items>
      </.sidebar>
  """
  def sidebar(assigns) do
    ~H"""
    <aside
      id={@id}
      class={cn([
        "flex w-60 flex-col border-r",
        sidebar_variant_class(@variant),
        # Translate off-screen when collapsed; transition is handled by the toggle button
        @collapsed && "-translate-x-full",
        @class
      ])}
      {@rest}
    >
      <%= if @brand != [] do %>
        <%!-- h-14 matches the topbar height so the horizontal grid lines align perfectly --%>
        <div class="flex h-14 shrink-0 items-center border-b px-4">
          <%= render_slot(@brand) %>
        </div>
      <% end %>
      <nav class="flex-1 overflow-y-auto px-2 py-4">
        <%= if @nav_items != [] do %>
          <%= render_slot(@nav_items) %>
        <% else %>
          <%!-- Fallback: render raw inner_block when no structured nav_items are provided --%>
          <%= render_slot(@inner_block) %>
        <% end %>
      </nav>
      <%= if @footer_items != [] do %>
        <div class="shrink-0 border-t px-2 py-4">
          <%= render_slot(@footer_items) %>
        </div>
      <% end %>
    </aside>
    """
  end

  # ---------------------------------------------------------------------------
  # sidebar_item/1
  # ---------------------------------------------------------------------------

  attr(:href, :string, default: "#", doc: "Navigation href for the anchor element")

  attr(:active, :boolean,
    default: false,
    doc: """
    Highlights this item as the currently active route. Adds
    `bg-accent text-accent-foreground` when `true`. Typically derived from
    `@live_action == :route_name` in your LiveView.
    """
  )

  attr(:badge, :integer,
    default: nil,
    doc: """
    Optional notification badge count displayed on the right side of the item.
    Pass `nil` (the default) to hide the badge entirely. Common for unread
    message counts, pending task counts, etc.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the anchor element")
  attr(:rest, :global, doc: "HTML attributes forwarded to the anchor element")

  slot(:icon,
    doc: """
    Optional icon displayed before the label. Use `<.icon name=\"...\">` inside
    this slot. The icon is wrapped in `shrink-0` so it does not compress when
    the label is long.
    """
  )

  slot(:inner_block, required: true, doc: "The text label for this navigation item")

  @doc """
  A navigation link inside the sidebar.

  Renders a full-width anchor element with:
  - Active state highlighting via `bg-accent text-accent-foreground`
  - Optional leading icon in its own `shrink-0` container
  - Optional trailing badge count (circular pill with `bg-primary`)
  - Keyboard focus outline inherited from the global focus ring tokens

  ## Example

      <%!-- Basic item --%>
      <.sidebar_item href="/dashboard" active={@live_action == :index}>
        Dashboard
      </.sidebar_item>

      <%!-- Item with icon and notification badge --%>
      <.sidebar_item href="/inbox" active={@live_action == :inbox} badge={@unread}>
        <:icon><.icon name="inbox" /></:icon>
        Inbox
      </.sidebar_item>
  """
  def sidebar_item(assigns) do
    ~H"""
    <a
      href={@href}
      class={cn([
        "flex items-center gap-2 rounded-md px-3 py-2 text-sm font-medium transition-colors",
        "text-muted-foreground hover:bg-accent hover:text-accent-foreground",
        # Active item uses the same accent tokens so it works correctly in all themes
        @active && "bg-accent text-accent-foreground",
        @class
      ])}
      {@rest}
    >
      <span :if={@icon != []} class="shrink-0">
        <%= render_slot(@icon) %>
      </span>
      <span class="flex-1"><%= render_slot(@inner_block) %></span>
      <%!-- Badge: circular pill anchored to the right edge of the item row --%>
      <span
        :if={@badge}
        class="ml-auto flex h-5 min-w-5 items-center justify-center rounded-full bg-primary px-1 text-xs font-medium text-primary-foreground"
      >
        <%= @badge %>
      </span>
    </a>
    """
  end

  # ---------------------------------------------------------------------------
  # sidebar_section/1
  # ---------------------------------------------------------------------------

  attr(:label, :string,
    default: nil,
    doc: """
    Section heading displayed in small uppercase muted text above the items.
    Pass `nil` to render the items without any heading (useful for the first
    section where a heading is redundant).
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the section wrapper")
  attr(:rest, :global)

  slot(:inner_block, required: true, doc: "sidebar_item/1 components to group under this section")

  @doc """
  Groups sidebar navigation items under an optional section label.

  Use multiple `sidebar_section/1` components inside the `:nav_items` slot of
  `sidebar/1` to create a visually separated, labelled hierarchy of links.

  Section labels use `text-xs uppercase tracking-wider` for a compact
  enterprise-style appearance. Items within the section are spaced with
  `space-y-0.5` for tight, scannable lists.

  ## Example

      <.sidebar_section label="Analytics">
        <.sidebar_item href="/revenue" active={@live_action == :revenue}>
          Revenue
        </.sidebar_item>
        <.sidebar_item href="/retention">Retention</.sidebar_item>
      </.sidebar_section>
  """
  def sidebar_section(assigns) do
    ~H"""
    <div class={cn(["mb-4", @class])} {@rest}>
      <p
        :if={@label}
        class="mb-1 px-3 text-xs font-semibold uppercase tracking-wider text-muted-foreground/70"
      >
        <%= @label %>
      </p>
      <div class="space-y-0.5">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # :default variant adds no extra classes; sidebar tokens come from CSS custom
  # properties in theme.css and are overridden per theme in phia-themes.css.
  defp sidebar_variant_class(:default), do: nil

  # :dark forces a dark appearance by applying the `dark` Tailwind variant
  # directly to the element, making it dark regardless of the document's
  # color scheme. The sidebar-specific tokens (bg-sidebar-background, etc.)
  # are then resolved from the dark @theme block in theme.css.
  defp sidebar_variant_class(:dark),
    do: "dark bg-sidebar-background text-sidebar-foreground border-sidebar-border"
end
