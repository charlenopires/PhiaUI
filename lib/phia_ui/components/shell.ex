defmodule PhiaUi.Components.Shell do
  @moduledoc """
  Full-height application shell with a responsive sidebar and topbar.

  This is the outermost layout primitive for admin panels, dashboards, and
  SaaS applications. It uses **CSS Grid on desktop** and collapses to a
  **flex column with a JS-toggled overlay drawer on mobile** — no Alpine.js,
  no custom JavaScript required.

  ## Layout structure

      ┌──────────────────────────────────────────┐
      │  topbar (col-span-full, h-14)            │
      ├─────────────────┬────────────────────────┤
      │                 │                        │
      │  sidebar        │  main content          │
      │  (240 px)       │  (overflow-y-auto)     │
      │                 │                        │
      └─────────────────┴────────────────────────┘

  Desktop: `grid grid-cols-[240px_1fr] h-screen overflow-hidden`
  Mobile: `flex flex-col`; the `<aside>` becomes a fixed overlay drawer.

  ## CSS theme tokens

  All background colors reference CSS custom properties:

  - `--background` — main content area and topbar
  - `--sidebar-background` — sidebar background
  - `--sidebar-foreground` — sidebar text
  - `--sidebar-border` — sidebar border color

  These tokens are defined in `priv/static/theme.css` and overridden per
  preset by `phia-themes.css` (generated via `mix phia.theme install`).
  Switching themes or toggling dark mode automatically updates colors without
  any prop changes to the shell.

  ## Sub-components

  | Component               | Purpose                                                    |
  |-------------------------|------------------------------------------------------------|
  | `shell/1`               | Outer CSS Grid wrapper; receives named slots               |
  | `sidebar/1`             | Collapsible 240 px aside; supports `:default`/`:dark` variants |
  | `sidebar_item/1`        | Navigation link with active highlight, icon, and badge     |
  | `sidebar_section/1`     | Groups nav items under an uppercase section label          |
  | `topbar/1`              | Sticky top bar (h-14, border-b); standalone or via slot    |
  | `mobile_sidebar_toggle/1` | Hamburger button that calls `JS.toggle/1`; hidden on md+  |

  ## Complete dashboard example

      defmodule MyAppWeb.DashboardLive do
        use MyAppWeb, :live_view

        def mount(_params, _session, socket) do
          {:ok, socket}
        end

        def handle_params(_params, _uri, socket) do
          {:noreply, socket}
        end

        def render(assigns) do
          ~H\"\"\"
          <.shell>
            <:topbar>
              <%!-- Hamburger is hidden on md+ via Tailwind; shown on mobile --%>
              <.mobile_sidebar_toggle />
              <span class="ml-2 font-semibold text-foreground">Acme Corp</span>
              <div class="ml-auto flex items-center gap-3">
                <.dark_mode_toggle id="dm-toggle" />
                <span class="text-sm text-muted-foreground">Jane Smith</span>
              </div>
            </:topbar>

            <:sidebar>
              <.sidebar>
                <:brand>
                  <span class="text-lg font-bold text-foreground">⬡ Acme</span>
                </:brand>

                <:nav_items>
                  <.sidebar_section label="Main Menu">
                    <.sidebar_item href="/dashboard" active={@live_action == :index}>
                      <:icon><.icon name="layout-dashboard" /></:icon>
                      Dashboard
                    </.sidebar_item>
                    <.sidebar_item href="/analytics" active={@live_action == :analytics}>
                      <:icon><.icon name="bar-chart-2" /></:icon>
                      Analytics
                    </.sidebar_item>
                    <.sidebar_item
                      href="/inbox"
                      active={@live_action == :inbox}
                      badge={@unread_count}
                    >
                      <:icon><.icon name="inbox" /></:icon>
                      Inbox
                    </.sidebar_item>
                  </.sidebar_section>

                  <.sidebar_section label="Management">
                    <.sidebar_item href="/customers" active={@live_action == :customers}>
                      <:icon><.icon name="users" /></:icon>
                      Customers
                    </.sidebar_item>
                    <.sidebar_item href="/reports" active={@live_action == :reports}>
                      <:icon><.icon name="file-text" /></:icon>
                      Reports
                    </.sidebar_item>
                  </.sidebar_section>
                </:nav_items>

                <:footer_items>
                  <.sidebar_item href="/settings" active={@live_action == :settings}>
                    <:icon><.icon name="settings" /></:icon>
                    Settings
                  </.sidebar_item>
                  <.sidebar_item href="/help">
                    <:icon><.icon name="help-circle" /></:icon>
                    Help & Support
                  </.sidebar_item>
                </:footer_items>
              </.sidebar>
            </:sidebar>

            <%!-- Main content — scrollable, occupies the remaining grid column --%>
            <main class="overflow-y-auto p-6">
              <h1 class="text-2xl font-semibold tracking-tight">Dashboard</h1>
              <p class="mt-1 text-muted-foreground">Welcome back, Jane.</p>
            </main>
          </.shell>
          \"\"\"
        end
      end

  ## Dark sidebar variant

  The `:dark` variant forces a dark enterprise look regardless of the current
  color mode, which is common for tools like Vercel, Linear, or Notion:

      <.sidebar variant={:dark}>
        ...
      </.sidebar>

  ## Mobile behavior

  On small screens the sidebar is `hidden` by default. Clicking the
  `mobile_sidebar_toggle/1` button calls `Phoenix.LiveView.JS.toggle/1` which
  slides the sidebar in/out with a 300 ms CSS transition. The transition is
  declarative — no hook or WebSocket round-trip required.
  """

  use Phoenix.Component

  alias Phoenix.LiveView.JS

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # shell/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the outermost wrapper div")
  attr(:rest, :global, doc: "HTML attributes forwarded to the wrapper div (e.g. id, data-* attrs)")

  slot(:sidebar,
    required: true,
    doc: """
    Sidebar content (required). On desktop this renders as a 240 px fixed
    aside column. On mobile it is hidden by default and shown as an overlay
    drawer when the user taps `mobile_sidebar_toggle/1`.
    """
  )

  slot(:topbar,
    doc: """
    Top navigation bar spanning the full width above the grid (optional).
    When omitted the grid starts at the very top of the viewport.
    Place `mobile_sidebar_toggle/1` and user actions here.
    """
  )

  slot(:inner_block,
    required: true,
    doc: """
    Main content area. Receives `flex-1` and `overflow-y-auto` — wrap your
    page content in a `<main>` or `<div>` here with appropriate padding.
    """
  )

  @doc """
  Full-height application shell using CSS Grid on desktop.

  The outer wrapper grows to `h-screen` and clips overflow so that only the
  main content column scrolls — the sidebar and topbar stay fixed.

  On mobile (below `md:` breakpoint) the layout switches to `flex flex-col`.
  The sidebar becomes `position: fixed` and is toggled via `JS.toggle/1`.

  ## Slots

  - `:topbar` — optional full-width header row (spans both grid columns)
  - `:sidebar` — required aside column (240 px wide on desktop, drawer on mobile)
  - `:inner_block` — main scrollable content area

  ## Example

      <.shell>
        <:topbar>...</:topbar>
        <:sidebar><.sidebar>...</.sidebar></:sidebar>
        <main class="p-6">Page content</main>
      </.shell>
  """
  def shell(assigns) do
    ~H"""
    <div
      class={cn([
        "h-screen overflow-hidden flex flex-col",
        # CSS Grid kicks in at the md breakpoint: fixed 240 px sidebar + flexible main
        "md:grid md:grid-cols-[240px_1fr] md:grid-rows-[auto_1fr]",
        @class
      ])}
      {@rest}
    >
      <%!-- Topbar spans both columns via col-span-full; only rendered when the slot is used --%>
      <%= if @topbar != [] do %>
        <header class="col-span-full flex h-14 shrink-0 items-center border-b bg-(--background) px-4">
          <%= render_slot(@topbar) %>
        </header>
      <% end %>
      <%!-- On desktop: static flex column in the first grid cell.
          On mobile:  position: fixed, full height, z-50 overlay (toggled by JS). --%>
      <aside
        id="mobile-sidebar"
        class="hidden fixed inset-y-0 left-0 z-50 w-60 flex-col bg-(--sidebar-background) md:static md:inset-auto md:z-auto md:flex md:w-auto md:flex-col"
      >
        <%= render_slot(@sidebar) %>
      </aside>
      <main class="flex-1 overflow-y-auto bg-(--background)">
        <%= render_slot(@inner_block) %>
      </main>
    </div>
    """
  end

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

      <.sidebar_section label="Settings">
        <.sidebar_item href="/team">Team</.sidebar_item>
        <.sidebar_item href="/billing">Billing</.sidebar_item>
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
  # topbar/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the header element")
  attr(:rest, :global)

  slot(:inner_block, required: true, doc: "Topbar content — brand, search, actions, user avatar")

  @doc """
  Standalone sticky top navigation bar (h-14, border-b, bg-background).

  This component is useful when building a topbar-only layout (no sidebar), or
  when you need to render a topbar outside of a `shell/1`. When using `shell/1`,
  prefer the `:topbar` slot directly — it renders the same markup internally.

  ## Example

      <%!-- Standalone topbar for a non-sidebar layout --%>
      <.topbar>
        <a href="/" class="font-semibold text-foreground">Acme</a>
        <nav class="ml-6 flex gap-4 text-sm text-muted-foreground">
          <a href="/docs">Docs</a>
          <a href="/pricing">Pricing</a>
        </nav>
        <div class="ml-auto">
          <.dark_mode_toggle id="topbar-dm" />
        </div>
      </.topbar>
  """
  def topbar(assigns) do
    ~H"""
    <header class={cn(["flex h-14 items-center border-b bg-(--background) px-4", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </header>
    """
  end

  # ---------------------------------------------------------------------------
  # mobile_sidebar_toggle/1
  # ---------------------------------------------------------------------------

  attr(:target, :string,
    default: "#mobile-sidebar",
    doc: """
    CSS selector for the element toggled by `JS.toggle/1`. Defaults to
    `#mobile-sidebar`, which matches the `<aside>` rendered by `shell/1`.
    Override this if you use a custom sidebar element ID.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)

  @doc """
  Hamburger/menu button that toggles the mobile sidebar via `Phoenix.LiveView.JS`.

  The button is **hidden on `md:` and wider** (`md:hidden`) so it does not
  appear on desktop where the sidebar is always visible. Place it in the
  `:topbar` slot of `shell/1` so it appears at the left edge of the topbar
  on mobile.

  The toggle uses `JS.toggle/1` with `transition-transform duration-300
  ease-in-out` classes: the sidebar slides in from the left on open and out
  on close. No server round-trip is required.

  ## Example

      <:topbar>
        <%!-- Only visible on mobile (< md breakpoint) --%>
        <.mobile_sidebar_toggle />
        <span class="ml-2 font-semibold">Acme</span>
      </:topbar>
  """
  def mobile_sidebar_toggle(assigns) do
    ~H"""
    <button
      type="button"
      phx-click={
        JS.toggle(
          to: @target,
          display: "flex",
          in: {"transition-transform duration-300 ease-in-out", "-translate-x-full",
           "translate-x-0"},
          out: {"transition-transform duration-300 ease-in-out", "translate-x-0",
           "-translate-x-full"}
        )
      }
      class={cn([
        "inline-flex h-10 w-10 items-center justify-center rounded-md",
        "text-muted-foreground hover:bg-accent hover:text-accent-foreground",
        # Hidden on desktop where the sidebar is always present in the grid layout
        "md:hidden",
        @class
      ])}
      aria-label="Toggle sidebar"
      {@rest}
    >
      <.icon name="menu" />
    </button>
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
