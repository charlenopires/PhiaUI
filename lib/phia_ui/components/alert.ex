defmodule PhiaUi.Components.Alert do
  @moduledoc """
  Inline feedback alert for communicating status, errors, and warnings.

  Provides 4 semantic variants following the shadcn/ui Alert anatomy. Alerts
  are inline, static components — they appear in the document flow and do not
  auto-dismiss. For transient notifications that appear and disappear
  automatically, use `PhiaUi.Components.Toast` instead.

  Pure HEEx — no JavaScript required.

  ## Sub-components

  | Component           | Element    | Purpose                                         |
  |---------------------|------------|-------------------------------------------------|
  | `alert/1`           | `<div>`    | Root container with `role="alert"`              |
  | `alert_title/1`     | `<p>`      | Bold heading inside the alert                   |
  | `alert_description/1`| `<p>`     | Muted supporting text                           |
  | `alert_action/1`    | `<button>` | Inline action (dismiss, renew, learn more, etc.)|

  ## Variants

  | Variant        | Background / border        | Typical use cases                              |
  |----------------|----------------------------|------------------------------------------------|
  | `:default`     | Neutral background         | General info, tips, feature announcements      |
  | `:destructive` | Red tint                   | Errors, failed operations, danger warnings     |
  | `:warning`     | Yellow tint (light/dark)   | Caution, non-critical issues, expiry notices   |
  | `:success`     | Green tint (light/dark)    | Successful operations, confirmations           |

  ## Informational alert

      <.alert>
        <.alert_title>Heads up</.alert_title>
        <.alert_description>
          You can configure this in your account settings.
        </.alert_description>
      </.alert>

  ## Destructive / error alert

      <.alert variant={:destructive}>
        <:icon><.icon name="circle-x" /></:icon>
        <.alert_title>Something went wrong</.alert_title>
        <.alert_description>
          We couldn't save your changes. Please try again.
        </.alert_description>
      </.alert>

  ## Warning alert with action

      <.alert variant={:warning}>
        <:icon><.icon name="triangle-alert" /></:icon>
        <.alert_title>Your session is about to expire</.alert_title>
        <.alert_description>
          You will be logged out in 5 minutes due to inactivity.
        </.alert_description>
        <.alert_action phx-click="renew_session">Stay logged in</.alert_action>
      </.alert>

  ## Success alert after form submit

      <.alert variant={:success}>
        <:icon><.icon name="circle-check" /></:icon>
        <.alert_title>Payment confirmed</.alert_title>
        <.alert_description>
          Your invoice has been sent to {@user.email}.
        </.alert_description>
      </.alert>

  ## Inline form validation alert

      <%= if @form.errors != [] do %>
        <.alert variant={:destructive}>
          <:icon><.icon name="circle-x" /></:icon>
          <.alert_title>Please fix the following errors</.alert_title>
          <.alert_description>
            <ul class="mt-1 list-disc list-inside space-y-0.5">
              <%= for {field, {message, _}} <- @form.errors do %>
                <li>{Phoenix.Naming.humanize(field)}: {message}</li>
              <% end %>
            </ul>
          </.alert_description>
        </.alert>
      <% end %>

  ## Deprecation / maintenance notice

      <.alert>
        <:icon><.icon name="info" /></:icon>
        <.alert_title>Scheduled maintenance</.alert_title>
        <.alert_description>
          The platform will be unavailable on Saturday, March 8 from 2–4 AM UTC.
        </.alert_description>
        <.alert_action href="/status">View status page</.alert_action>
      </.alert>

  ## Accessibility

  - The root `<div>` carries `role="alert"` so assistive technologies
    announce newly rendered alerts immediately (live region behaviour).
  - For alerts that should not interrupt the user mid-task, use
    `role="status"` by passing `rest={%{role: "status"}}`.
  - The `:icon` slot's icon should not carry an accessible name (it is
    decorative); the title and description provide the textual context.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:variant, :atom,
    values: [:default, :destructive, :warning, :success],
    default: :default,
    doc: "Visual and semantic variant. Use `:destructive` for errors, `:warning` for cautions, `:success` for confirmations, `:default` for general info."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged via `cn/1`."
  )

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the root `<div>` element. Use `role=\"status\"` to override the default `role=\"alert\"` for non-urgent messages."
  )

  slot(:icon,
    doc: "Optional leading icon, e.g. `<.icon name=\"circle-alert\" />`. Positioned absolutely at the top-left. The icon colour automatically matches the variant via `[&>svg]:text-current`."
  )

  slot(:inner_block,
    required: true,
    doc: "Alert body. Typically `alert_title/1` followed by `alert_description/1`. May also include `alert_action/1`."
  )

  @doc """
  Renders a styled alert container with `role="alert"` for screen readers.

  Use `alert_title/1`, `alert_description/1`, and optionally `alert_action/1`
  as the inner content. Provide an `:icon` slot for a leading icon.

  ## Example

      <.alert variant={:warning}>
        <:icon><.icon name="triangle-alert" /></:icon>
        <.alert_title>Billing required</.alert_title>
        <.alert_description>
          Add a payment method to continue using the service.
        </.alert_description>
        <.alert_action phx-click="open_billing">Add payment</.alert_action>
      </.alert>
  """
  def alert(assigns) do
    ~H"""
    <div
      role="alert"
      class={cn([base_class(), variant_class(@variant), @class])}
      {@rest}
    >
      <%!-- Icon sits in a flex row, shrink-0 so it never compresses --%>
      <span :if={@icon != []} class="shrink-0 mt-0.5 [&>svg]:size-4 [&>svg]:text-current">
        <%= render_slot(@icon) %>
      </span>
      <div class="flex-1 min-w-0">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # alert_title/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes applied to the title `<p>` element.")
  slot(:inner_block, required: true, doc: "Title text. Keep it short — typically 3–8 words.")

  @doc """
  Renders the alert heading in bold with tight leading.

  Styled with `font-medium leading-none tracking-tight` to match the visual
  hierarchy established by shadcn/ui. Place this as the first child of the
  `alert/1` component.

  ## Example

      <.alert_title>Account suspended</.alert_title>
  """
  def alert_title(assigns) do
    ~H"""
    <p class={cn(["mb-1 font-medium leading-none tracking-tight", @class])}>
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  # ---------------------------------------------------------------------------
  # alert_description/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes applied to the description `<p>` element.")
  slot(:inner_block, required: true, doc: "Description text or content. Rendered in small muted type.")

  @doc """
  Renders the alert supporting text in muted, small type.

  Follows the title and provides additional context. Can contain plain text,
  links, or simple lists.

  ## Example

      <.alert_description>
        Your account has been locked after 5 failed login attempts.
        Contact support to regain access.
      </.alert_description>
  """
  def alert_description(assigns) do
    ~H"""
    <p class={cn(["text-sm text-muted-foreground", @class])}>
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  # ---------------------------------------------------------------------------
  # alert_action/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes applied to the `<button>` element.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the `<button>` element. Use `phx-click` for LiveView events or pass `href` for navigation.")
  slot(:inner_block, required: true, doc: "Action label text (e.g. `\"Dismiss\"`, `\"Learn more\"`, `\"Renew\"`).")

  @doc """
  Renders an inline action button inside the alert.

  Use for common alert actions such as dismissing the message, navigating
  to a related page, or triggering a remediation flow.

  ## Examples

      <%!-- Session expiry warning with renew action --%>
      <.alert variant={:warning}>
        <.alert_title>Session expiring</.alert_title>
        <.alert_description>You'll be logged out in 5 minutes.</.alert_description>
        <.alert_action phx-click="renew_session">Stay logged in</.alert_action>
      </.alert>

      <%!-- Error with retry action --%>
      <.alert variant={:destructive}>
        <.alert_title>Upload failed</.alert_title>
        <.alert_description>The file exceeds the 10 MB limit.</.alert_description>
        <.alert_action phx-click="retry_upload">Try again</.alert_action>
      </.alert>
  """
  def alert_action(assigns) do
    ~H"""
    <button
      type="button"
      class={cn([
        "mt-2 inline-flex items-center rounded-md px-3 py-1.5 text-sm font-medium",
        "transition-colors focus-visible:outline-none focus-visible:ring-2",
        "focus-visible:ring-ring focus-visible:ring-offset-2",
        "hover:bg-accent hover:text-accent-foreground",
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers — pattern matching only, no case/cond
  # ---------------------------------------------------------------------------

  # Flex row layout: icon (shrink-0) + content (flex-1). No absolute positioning needed.
  defp base_class do
    "w-full rounded-lg border p-4 flex items-start gap-3 text-sm"
  end

  # Default: neutral bg, no tint — general info / announcements
  defp variant_class(:default),
    do: "bg-background text-foreground border-border"

  # Destructive: red tint — errors, critical failures
  defp variant_class(:destructive),
    do: "border-destructive/40 bg-destructive/10 text-destructive"

  # Warning: amber tint using theme warning tokens
  defp variant_class(:warning),
    do: "border-warning/40 bg-warning/10 text-warning dark:border-warning/30 dark:bg-warning/15"

  # Success: green tint using theme success tokens
  defp variant_class(:success),
    do: "border-success/40 bg-success/10 text-success dark:border-success/30 dark:bg-success/15"
end
