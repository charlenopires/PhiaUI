defmodule PhiaUi.Components.Shell do
  @moduledoc """
  Dashboard layout shell with responsive sidebar and topbar.

  CSS Grid on desktop (`grid-cols-[240px_1fr] h-screen overflow-hidden`);
  sidebar becomes a JS-toggled drawer on mobile via `Phoenix.LiveView.JS` —
  no Alpine.js required.

  Backgrounds reference CSS custom properties (`--sidebar-background`,
  `--background`) so switching themes or enabling dark mode works automatically
  via `@theme` tokens.

  ## Sub-components

  - `shell/1` — outer CSS Grid wrapper with named slots
  - `sidebar/1` — collapsible sidebar with `:brand`, `:nav_items`, `:footer_items` slots
  - `sidebar_item/1` — navigation item with active state
  - `topbar/1` — standalone sticky top navigation bar
  - `mobile_sidebar_toggle/1` — hamburger button that calls `JS.toggle/1`

  ## Example

  A complete dashboard page using all shell sub-components:

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
              <%!-- Hamburger button — hidden on md+, shown on mobile --%>
              <.mobile_sidebar_toggle />
              <span class="font-semibold text-foreground">Acme Corp</span>
              <div class="ml-auto flex items-center gap-2">
                <span class="text-sm text-muted-foreground">Jane Smith</span>
              </div>
            </:topbar>

            <:sidebar>
              <.sidebar>
                <:brand>
                  <span class="text-lg font-bold text-foreground">⬡ Acme</span>
                </:brand>

                <:nav_items>
                  <.sidebar_item href="/dashboard" active={@live_action == :index}>
                    Dashboard
                  </.sidebar_item>
                  <.sidebar_item href="/analytics" active={@live_action == :analytics}>
                    Analytics
                  </.sidebar_item>
                  <.sidebar_item href="/reports" active={@live_action == :reports}>
                    Reports
                  </.sidebar_item>
                  <.sidebar_item href="/customers" active={@live_action == :customers}>
                    Customers
                  </.sidebar_item>
                </:nav_items>

                <:footer_items>
                  <.sidebar_item href="/settings" active={@live_action == :settings}>
                    Settings
                  </.sidebar_item>
                  <.sidebar_item href="/help">
                    Help & Support
                  </.sidebar_item>
                </:footer_items>
              </.sidebar>
            </:sidebar>

            <%!-- Main content — scrollable, receives flex-1 from shell --%>
            <main class="overflow-y-auto p-6">
              <h1 class="text-2xl font-semibold">Dashboard</h1>
              <p class="mt-2 text-muted-foreground">Welcome back, Jane.</p>
            </main>
          </.shell>
          \"\"\"
        end
      end
  """

  use Phoenix.Component

  alias Phoenix.LiveView.JS

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # shell/1
  # ---------------------------------------------------------------------------

  attr :class, :string, default: nil, doc: "Additional CSS classes for the outer wrapper"
  attr :rest, :global, doc: "HTML attributes forwarded to the wrapper div"

  slot :sidebar, required: true, doc: "Sidebar content (required) — rendered in aside on desktop, drawer on mobile"
  slot :topbar, doc: "Top navigation bar (optional) — spans full width above the grid"
  slot :inner_block, required: true, doc: "Main content area"

  @doc """
  Full-height application shell using CSS Grid on desktop.

  - Desktop: `grid-cols-[240px_1fr] h-screen overflow-hidden`
  - Mobile: `flex flex-col`; sidebar becomes a JS-toggled overlay drawer.
  """
  def shell(assigns) do
    ~H"""
    <div
      class={cn([
        "h-screen overflow-hidden flex flex-col",
        "md:grid md:grid-cols-[240px_1fr]",
        @class
      ])}
      {@rest}
    >
      <%= if @topbar != [] do %>
        <header class="col-span-full flex h-14 shrink-0 items-center border-b bg-[--background] px-4">
          <%= render_slot(@topbar) %>
        </header>
      <% end %>
      <aside
        id="mobile-sidebar"
        class="hidden fixed inset-y-0 left-0 z-50 w-60 flex-col border-r bg-[--sidebar-background] md:static md:inset-auto md:z-auto md:flex md:w-auto md:flex-col"
      >
        <%= render_slot(@sidebar) %>
      </aside>
      <main class="flex-1 overflow-y-auto bg-[--background]">
        <%= render_slot(@inner_block) %>
      </main>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # sidebar/1
  # ---------------------------------------------------------------------------

  attr :id, :string, default: "sidebar-drawer", doc: "Element id used by JS.toggle"

  attr :collapsed, :boolean,
    default: false,
    doc: "Collapses the sidebar (translates off-screen)"

  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to the aside element"

  slot :brand, doc: "Logo / application name area at the top of the sidebar"
  slot :nav_items, doc: "Primary navigation items"
  slot :footer_items, doc: "Secondary items at the bottom of the sidebar"
  slot :inner_block, doc: "Fallback slot for custom sidebar content"

  @doc """
  Responsive sidebar.

  On desktop: full-height 240 px aside with `border-r`.
  On mobile: hidden by default; toggled as overlay via `mobile_sidebar_toggle/1`.

  ## Slots

  - `:brand` — logo or app name area (top)
  - `:nav_items` — primary navigation
  - `:footer_items` — secondary / footer links
  - `:inner_block` — raw fallback if named slots are not used
  """
  def sidebar(assigns) do
    ~H"""
    <aside
      id={@id}
      class={cn([
        "flex w-60 flex-col border-r",
        @collapsed && "-translate-x-full",
        @class
      ])}
      {@rest}
    >
      <%= if @brand != [] do %>
        <div class="flex h-14 shrink-0 items-center border-b px-4">
          <%= render_slot(@brand) %>
        </div>
      <% end %>
      <nav class="flex-1 overflow-y-auto px-2 py-4">
        <%= if @nav_items != [] do %>
          <%= render_slot(@nav_items) %>
        <% else %>
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

  attr :href, :string, default: "#", doc: "Navigation href"
  attr :active, :boolean, default: false, doc: "Highlights the item as the current route"
  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to the anchor element"

  slot :inner_block, required: true, doc: "Item label"

  @doc "A navigation item inside the sidebar, with active-state highlighting."
  def sidebar_item(assigns) do
    ~H"""
    <a
      href={@href}
      class={cn([
        "flex items-center gap-2 rounded-md px-3 py-2 text-sm font-medium transition-colors",
        "text-muted-foreground hover:bg-accent hover:text-accent-foreground",
        @active && "bg-accent text-accent-foreground",
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </a>
    """
  end

  # ---------------------------------------------------------------------------
  # topbar/1
  # ---------------------------------------------------------------------------

  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global

  slot :inner_block, required: true

  @doc "Horizontal top navigation bar (h-14, border-b). Use inside shell's :topbar slot or standalone."
  def topbar(assigns) do
    ~H"""
    <header class={cn(["flex h-14 items-center border-b bg-[--background] px-4", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </header>
    """
  end

  # ---------------------------------------------------------------------------
  # mobile_sidebar_toggle/1
  # ---------------------------------------------------------------------------

  attr :target, :string,
    default: "#mobile-sidebar",
    doc: "CSS selector for the element to toggle (defaults to #mobile-sidebar on shell)"

  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global

  @doc """
  Hamburger button that toggles the mobile sidebar via `Phoenix.LiveView.JS`.

  Hidden on `md:` and above — only shown on mobile.
  """
  def mobile_sidebar_toggle(assigns) do
    ~H"""
    <button
      type="button"
      phx-click={
        JS.toggle(to: @target,
          display: "flex",
          in: {"transition-transform duration-300 ease-in-out", "-translate-x-full", "translate-x-0"},
          out: {"transition-transform duration-300 ease-in-out", "translate-x-0", "-translate-x-full"}
        )
      }
      class={cn([
        "inline-flex items-center justify-center rounded-md p-2",
        "text-muted-foreground hover:bg-accent hover:text-accent-foreground",
        "md:hidden",
        @class
      ])}
      aria-label="Toggle sidebar"
      {@rest}
    >
      ☰
    </button>
    """
  end
end
