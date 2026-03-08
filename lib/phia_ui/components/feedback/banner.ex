defmodule PhiaUi.Components.Banner do
  @moduledoc """
  Full-width page-level feedback banners inspired by Atlassian Design System Banner,
  Bootstrap Alerts, and GitHub's site-wide announcement banners.

  These components occupy the full width of their container and are used for
  system-wide messages, marketing announcements, and consent requirements.

  ## Sub-components

  | Component           | Purpose                                                          |
  |---------------------|------------------------------------------------------------------|
  | `banner/1`          | Full-width dismissible feedback strip (top/inline)              |
  | `announcement_bar/1`| Slim sticky marketing/system announcement at the very top       |
  | `cookie_consent/1`  | GDPR-compliant cookie consent panel (bottom of viewport)        |

  ## Banner (full-width inline feedback)

      <.banner variant={:warning} :if={@maintenance_mode}>
        <:icon><.icon name="triangle-alert" class="h-4 w-4" /></:icon>
        Scheduled maintenance on Saturday 2–4 AM UTC.
        <:action href="/status">View status</:action>
      </.banner>

  ## Announcement bar (sticky top)

      <.announcement_bar>
        🎉 PhiaUI 1.0 is out! Read the
        <:link href="/blog/v1">release notes</:link>.
      </.announcement_bar>

  ## Cookie consent (bottom overlay)

      <.cookie_consent :if={!@cookies_accepted}>
        We use cookies to improve your experience.
        <:action phx-click="accept_cookies">Accept all</:action>
        <:secondary phx-click="open_cookie_settings">Settings</:secondary>
      </.cookie_consent>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  alias Phoenix.LiveView.JS

  # ---------------------------------------------------------------------------
  # banner/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, default: nil, doc: "Optional ID — required for JS.hide dismiss.")

  attr(:variant, :atom,
    values: [:default, :info, :success, :warning, :destructive],
    default: :default,
    doc: "Visual style controlling background, border and icon defaults."
  )

  attr(:closeable, :boolean,
    default: true,
    doc: "When `true`, renders an × dismiss button using `JS.hide`."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attrs forwarded to the root `<div>`.")

  slot(:icon, doc: "Optional leading icon (recommended: `h-4 w-4`).")
  slot(:inner_block, required: true, doc: "Banner message text.")
  slot(:action, doc: "Primary action — rendered as a link/button on the right.")

  @doc """
  Renders a full-width, optionally dismissible feedback banner.

  Use for page-level alerts that need more visual prominence than an `Alert`
  component but should not block the user like a modal would. Common uses:
  maintenance windows, rate limit warnings, subscription expiry notices.

  ## Example

      <.banner id="trial-banner" variant={:warning}>
        <:icon><.icon name="clock" class="h-4 w-4" /></:icon>
        Your trial expires in 3 days.
        <:action phx-click="open_billing">Upgrade now</:action>
      </.banner>
  """
  def banner(assigns) do
    ~H"""
    <div
      id={@id}
      role="alert"
      class={cn(["w-full flex flex-col sm:flex-row items-start sm:items-center gap-3 px-4 py-3 text-sm", banner_variant_class(@variant), @class])}
      {@rest}
    >
      <%!-- Icon --%>
      <span :if={@icon != []} class="shrink-0 [&>svg]:size-4 [&>svg]:text-current" aria-hidden="true">
        {render_slot(@icon)}
      </span>

      <%!-- Message --%>
      <span class="flex-1 min-w-0">{render_slot(@inner_block)}</span>

      <%!-- Action --%>
      <span :if={@action != []} class="shrink-0">
        {render_slot(@action)}
      </span>

      <%!-- Dismiss --%>
      <button
        :if={@closeable && @id}
        type="button"
        aria-label="Dismiss"
        phx-click={JS.hide(to: "##{@id}", transition: {"transition-opacity duration-150", "opacity-100", "opacity-0"})}
        class="shrink-0 ml-auto rounded p-1 opacity-70 hover:opacity-100 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring transition-opacity"
      >
        <.icon name="x" class="h-4 w-4" />
      </button>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # announcement_bar/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, default: nil, doc: "Optional ID — required for JS.hide dismiss.")

  attr(:dismissable, :boolean,
    default: true,
    doc: "When `true`, renders a close button."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attrs forwarded to the root `<div>`.")

  slot(:inner_block, required: true, doc: "Announcement text. Can include inline HTML elements.")
  slot(:link, doc: "Inline link rendered inside the text — rendered as an `<a>` tag.")

  @doc """
  Renders a slim sticky announcement bar at the top of the page.

  Used for high-priority marketing or system announcements (new releases,
  feature announcements, system notices). Typically placed above the navigation
  header in the root layout.

  ## Example

      <.announcement_bar id="release-bar">
        PhiaUI 1.0 is here!
        <:link href="/changelog">See what's new</:link>
      </.announcement_bar>
  """
  def announcement_bar(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn([
        "w-full bg-primary text-primary-foreground",
        "flex items-center justify-center gap-2 px-4 py-2 text-sm font-medium",
        @class
      ])}
      role="banner"
      {@rest}
    >
      <span class="flex items-center gap-1.5">
        {render_slot(@inner_block)}
        <a
          :for={link <- @link}
          class="underline underline-offset-2 hover:no-underline font-semibold"
          {link}
        >
          {render_slot(link)}
        </a>
      </span>

      <button
        :if={@dismissable && @id}
        type="button"
        aria-label="Dismiss announcement"
        phx-click={JS.hide(to: "##{@id}", transition: {"transition-all duration-200", "opacity-100 max-h-12", "opacity-0 max-h-0"})}
        class="absolute right-3 rounded p-1 opacity-70 hover:opacity-100 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-foreground/50 transition-opacity"
      >
        <.icon name="x" class="h-4 w-4" />
      </button>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # cookie_consent/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, default: "phia-cookie-consent", doc: "Unique ID for the consent panel.")

  attr(:title, :string,
    default: "Cookie preferences",
    doc: "Heading text for the consent panel."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attrs forwarded to the root `<div>`.")

  slot(:inner_block, required: true, doc: "Privacy description text.")

  slot(:action,
    required: true,
    doc: "Primary accept button — wire with `phx-click` to set consent state."
  )

  slot(:secondary,
    doc: "Secondary button for granular settings — optional."
  )

  @doc """
  Renders a GDPR-compliant cookie consent panel at the bottom of the viewport.

  The panel is fixed to the bottom of the screen, full-width on mobile and
  card-style on desktop. Use the `:action` slot for the primary accept button
  and the `:secondary` slot for a settings or reject link.

  Control visibility server-side via a LiveView assign — hide by setting
  `:if={!@cookies_accepted}`.

  ## Example

      <.cookie_consent id="cookie-bar" :if={!@cookies_accepted}>
        We use cookies to provide a better experience and analyze traffic.
        <a href="/privacy" class="underline">Privacy policy</a>.
        <:action phx-click="accept_all_cookies">Accept all</:action>
        <:secondary phx-click="cookie_settings">Manage preferences</:secondary>
      </.cookie_consent>
  """
  def cookie_consent(assigns) do
    ~H"""
    <div
      id={@id}
      role="dialog"
      aria-modal="false"
      aria-label={@title}
      class={cn([
        "fixed bottom-0 left-0 right-0 z-50",
        "flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4",
        "bg-background border-t border-border shadow-lg px-4 sm:px-6 py-4",
        @class
      ])}
      {@rest}
    >
      <%!-- Text --%>
      <div class="flex-1 min-w-0">
        <p class="text-sm font-semibold text-foreground mb-1">{@title}</p>
        <p class="text-sm text-muted-foreground">{render_slot(@inner_block)}</p>
      </div>

      <%!-- Actions --%>
      <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-2 shrink-0">
        <span :if={@secondary != []} class="[&>button]:text-sm [&>a]:text-sm">
          {render_slot(@secondary)}
        </span>
        <span class="[&>button]:text-sm [&>a]:text-sm">
          {render_slot(@action)}
        </span>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp banner_variant_class(:default), do: "bg-muted text-foreground border-b border-border"
  defp banner_variant_class(:info), do: "bg-blue-50 text-blue-900 border-b border-blue-200 dark:bg-blue-950/50 dark:text-blue-200 dark:border-blue-800"
  defp banner_variant_class(:success), do: "bg-success/10 text-success border-b border-success/30"
  defp banner_variant_class(:warning), do: "bg-warning/10 text-warning border-b border-warning/30"
  defp banner_variant_class(:destructive), do: "bg-destructive/10 text-destructive border-b border-destructive/30"
end
