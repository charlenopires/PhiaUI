defmodule PhiaUi.Components.MobileSidebarToggle do
  @moduledoc """
  Mobile hamburger button that toggles the sidebar via `Phoenix.LiveView.JS`.

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

  use Phoenix.Component

  alias Phoenix.LiveView.JS

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

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

  ## Example

      <.mobile_sidebar_toggle />
      <.mobile_sidebar_toggle target="#my-sidebar" />
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
end
