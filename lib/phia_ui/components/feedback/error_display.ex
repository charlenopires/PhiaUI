defmodule PhiaUi.Components.ErrorDisplay do
  @moduledoc """
  Structured error display components for showing application errors, API failures,
  and standard HTTP error pages.

  Inspired by Ant Design Result, GitHub's error pages, Sentry's error UI,
  and Vercel's edge error displays.

  Pure HEEx — no JavaScript required.

  ## Sub-components

  | Component           | Purpose                                                        |
  |---------------------|----------------------------------------------------------------|
  | `error_display/1`   | Structured error box with code, message, and expandable trace  |
  | `error_boundary/1`  | Error catch container with retry and back actions              |
  | `http_error/1`      | Styled 404/500/403/503 full-page error with illustration       |

  ## Structured error (API/runtime error)

      <.error_display
        code="PAYMENT_FAILED"
        message="The payment processor declined the charge."
        detail="Card ending in 4242 was declined with reason: insufficient_funds."
      />

  ## Error boundary (with retry)

      <.error_boundary :if={@load_error} phx-click-retry="reload_data">
        Failed to load dashboard data.
        <:detail>Check your network connection and try again.</:detail>
      </.error_boundary>

  ## HTTP error page

      <.http_error status={404} />
      <.http_error status={500} message="Something went wrong on our end." />
      <.http_error status={403} title="Access denied" message="You don't have permission." />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # error_display/1
  # ---------------------------------------------------------------------------

  attr(:code, :string,
    default: nil,
    doc: "Optional machine error code (e.g. `\"PAYMENT_FAILED\"`, `\"E4042\"`)."
  )

  attr(:message, :string,
    required: true,
    doc: "Human-readable error message."
  )

  attr(:detail, :string,
    default: nil,
    doc: "Optional additional detail text."
  )

  attr(:trace, :string,
    default: nil,
    doc: "Optional stack trace or raw error string — shown in an expandable `<details>` block."
  )

  attr(:variant, :atom,
    values: [:destructive, :warning, :default],
    default: :destructive,
    doc: "Visual severity variant."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attrs forwarded to the root `<div>`.")

  @doc """
  Renders a structured error display box.

  Use when you need to surface a specific, identifiable error — API failures,
  validation errors, runtime exceptions — with enough detail for the user
  (or developer in dev mode) to understand and potentially resolve the issue.

  ## Example

      <.error_display
        code="RATE_LIMIT_EXCEEDED"
        message="Too many requests."
        detail="You have exceeded the limit of 100 requests per minute. Please wait before retrying."
      />

      <%!-- Dev mode with stack trace --%>
      <.error_display
        :if={@dev_mode}
        message={@exception.message}
        trace={@exception.stack}
      />
  """
  def error_display(assigns) do
    detail_id = "error-trace-#{System.unique_integer([:positive])}"
    assigns = assign(assigns, :detail_id, detail_id)

    ~H"""
    <div
      role="alert"
      class={cn([
        "rounded-lg border p-4 space-y-2",
        error_variant_class(@variant),
        @class
      ])}
      {@rest}
    >
      <%!-- Header row --%>
      <div class="flex items-start gap-2">
        <.icon
          name={error_variant_icon(@variant)}
          class={cn(["h-4 w-4 shrink-0 mt-0.5", error_icon_color(@variant)])}
        />
        <div class="flex-1 min-w-0 space-y-0.5">
          <div class="flex items-center gap-2 flex-wrap">
            <p class="text-sm font-semibold text-foreground">{@message}</p>
            <code :if={@code} class={cn([
              "text-xs font-mono px-1.5 py-0.5 rounded",
              error_code_class(@variant)
            ])}>
              {@code}
            </code>
          </div>
          <p :if={@detail} class="text-xs text-muted-foreground">{@detail}</p>
        </div>
      </div>

      <%!-- Expandable trace --%>
      <details :if={@trace} id={@detail_id} class="mt-2">
        <summary class="text-xs text-muted-foreground cursor-pointer hover:text-foreground transition-colors select-none">
          Show stack trace
        </summary>
        <pre class="mt-2 text-xs font-mono bg-muted/50 rounded p-3 overflow-x-auto whitespace-pre-wrap break-all text-muted-foreground">{@trace}</pre>
      </details>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # error_boundary/1
  # ---------------------------------------------------------------------------

  attr(:title, :string,
    default: "Something went wrong",
    doc: "Heading text for the error boundary."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attrs forwarded to the root `<div>`.")

  slot(:inner_block, required: true, doc: "Error message text.")
  slot(:detail, doc: "Optional additional detail rendered in muted text below the message.")
  slot(:actions, doc: "Optional action buttons (retry, back, contact support).")

  @doc """
  Renders an error boundary container with a retry action.

  Use as a fallback UI when a section of your LiveView fails to load data.
  Wire the retry action to re-trigger your mount or data loading logic.

  ## Example

      <.error_boundary :if={@load_error}>
        Failed to load project data.
        <:detail>The server returned a 503 error. Our team has been notified.</:detail>
        <:actions>
          <.button phx-click="retry_load" variant={:outline} size={:sm}>
            <.icon name="refresh-cw" class="h-4 w-4" />
            Try again
          </.button>
          <.button navigate={~p"/"} variant={:ghost} size={:sm}>Go home</.button>
        </:actions>
      </.error_boundary>
  """
  def error_boundary(assigns) do
    ~H"""
    <div
      role="alert"
      class={cn([
        "flex flex-col items-center justify-center text-center gap-4 py-10 px-6",
        "rounded-lg border border-destructive/20 bg-destructive/5",
        @class
      ])}
      {@rest}
    >
      <div class="flex h-12 w-12 items-center justify-center rounded-full bg-destructive/10">
        <.icon name="circle-x" class="h-6 w-6 text-destructive" />
      </div>
      <div class="space-y-1 max-w-sm">
        <h3 class="text-base font-semibold text-foreground">{@title}</h3>
        <p class="text-sm text-foreground/80">{render_slot(@inner_block)}</p>
        <p :if={@detail != []} class="text-xs text-muted-foreground mt-1">
          {render_slot(@detail)}
        </p>
      </div>
      <div :if={@actions != []} class="flex flex-wrap items-center justify-center gap-2">
        {render_slot(@actions)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # http_error/1
  # ---------------------------------------------------------------------------

  attr(:status, :integer,
    required: true,
    values: [400, 401, 403, 404, 408, 429, 500, 502, 503],
    doc: "HTTP status code. Controls default title, message, and icon."
  )

  attr(:title, :string,
    default: nil,
    doc: "Override the default title for this status code."
  )

  attr(:message, :string,
    default: nil,
    doc: "Override the default message for this status code."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root element.")
  attr(:rest, :global, doc: "HTML attrs forwarded to the root `<div>`.")

  slot(:actions,
    doc: "Call-to-action buttons (e.g. 'Go home', 'Contact support'). Falls back to defaults."
  )

  @doc """
  Renders a full-page styled HTTP error.

  Provides default titles, messages, and icons for common HTTP error codes.
  All defaults can be overridden via `:title`, `:message`, and `:actions` slot.

  ## Example

      <%!-- In a LiveView error route --%>
      <.http_error status={404} />

      <%!-- Custom 503 --%>
      <.http_error
        status={503}
        title="Under maintenance"
        message="We'll be back shortly. Check our status page."
      >
        <:actions>
          <.button href="/status" variant={:outline}>View status</.button>
        </:actions>
      </.http_error>
  """
  def http_error(assigns) do
    assigns =
      assigns
      |> assign(:resolved_title, assigns.title || http_title(assigns.status))
      |> assign(:resolved_message, assigns.message || http_message(assigns.status))

    ~H"""
    <div
      class={cn([
        "flex flex-col items-center justify-center text-center gap-6 py-20 px-6 min-h-[60vh]",
        @class
      ])}
      {@rest}
    >
      <%!-- Status code --%>
      <div class="space-y-1">
        <p class="text-7xl font-bold text-muted-foreground/30 tabular-nums leading-none">
          {@status}
        </p>
      </div>

      <%!-- Icon --%>
      <div class={cn([
        "flex h-16 w-16 items-center justify-center rounded-full",
        http_icon_bg(@status)
      ])}>
        <.icon name={http_icon(@status)} class={cn(["h-8 w-8", http_icon_color(@status)])} />
      </div>

      <%!-- Text --%>
      <div class="space-y-2 max-w-md">
        <h1 class="text-2xl font-bold text-foreground">{@resolved_title}</h1>
        <p class="text-sm text-muted-foreground leading-relaxed">{@resolved_message}</p>
      </div>

      <%!-- Actions --%>
      <div class="flex flex-wrap items-center justify-center gap-3">
        {render_slot(@actions)}
        <%!-- Default actions when slot is empty --%>
        <a
          :if={@actions == []}
          href="/"
          class={cn([
            "inline-flex items-center gap-2 rounded-md bg-primary px-4 py-2",
            "text-sm font-medium text-primary-foreground shadow transition-colors",
            "hover:bg-primary/90 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
          ])}
        >
          <.icon name="house" class="h-4 w-4" />
          Go home
        </a>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp error_variant_class(:destructive), do: "border-destructive/30 bg-destructive/5"
  defp error_variant_class(:warning), do: "border-warning/30 bg-warning/5"
  defp error_variant_class(:default), do: "border-border bg-muted/30"

  defp error_variant_icon(:destructive), do: "circle-x"
  defp error_variant_icon(:warning), do: "triangle-alert"
  defp error_variant_icon(:default), do: "info"

  defp error_icon_color(:destructive), do: "text-destructive"
  defp error_icon_color(:warning), do: "text-warning"
  defp error_icon_color(:default), do: "text-muted-foreground"

  defp error_code_class(:destructive), do: "bg-destructive/10 text-destructive font-mono"
  defp error_code_class(:warning), do: "bg-warning/10 text-warning font-mono"
  defp error_code_class(:default), do: "bg-muted text-muted-foreground font-mono"

  defp http_title(400), do: "Bad Request"
  defp http_title(401), do: "Authentication Required"
  defp http_title(403), do: "Access Denied"
  defp http_title(404), do: "Page Not Found"
  defp http_title(408), do: "Request Timeout"
  defp http_title(429), do: "Too Many Requests"
  defp http_title(500), do: "Internal Server Error"
  defp http_title(502), do: "Bad Gateway"
  defp http_title(503), do: "Service Unavailable"
  defp http_title(_), do: "An Error Occurred"

  defp http_message(400), do: "The request was invalid or malformed. Please check your input and try again."
  defp http_message(401), do: "You need to sign in to access this page."
  defp http_message(403), do: "You don't have permission to view this page. Contact your administrator if you think this is a mistake."
  defp http_message(404), do: "The page you're looking for doesn't exist. It may have been moved, deleted, or the URL might be incorrect."
  defp http_message(408), do: "The server timed out waiting for the request. Please try again."
  defp http_message(429), do: "You've made too many requests. Please wait a moment before trying again."
  defp http_message(500), do: "Something went wrong on our end. Our team has been notified and we're working on a fix."
  defp http_message(502), do: "The server received an invalid response. Please try again in a few moments."
  defp http_message(503), do: "The service is temporarily unavailable. We're working to restore it as quickly as possible."
  defp http_message(_), do: "An unexpected error occurred. Please try again or contact support."

  defp http_icon(401), do: "lock"
  defp http_icon(403), do: "shield-off"
  defp http_icon(404), do: "file-question"
  defp http_icon(408), do: "clock"
  defp http_icon(429), do: "gauge"
  defp http_icon(503), do: "cloud-off"
  defp http_icon(_), do: "circle-x"

  defp http_icon_bg(404), do: "bg-muted"
  defp http_icon_bg(401), do: "bg-primary/10"
  defp http_icon_bg(403), do: "bg-warning/10"
  defp http_icon_bg(429), do: "bg-warning/10"
  defp http_icon_bg(_), do: "bg-destructive/10"

  defp http_icon_color(404), do: "text-muted-foreground"
  defp http_icon_color(401), do: "text-primary"
  defp http_icon_color(403), do: "text-warning"
  defp http_icon_color(429), do: "text-warning"
  defp http_icon_color(_), do: "text-destructive"
end
