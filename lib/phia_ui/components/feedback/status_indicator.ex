defmodule PhiaUi.Components.StatusIndicator do
  @moduledoc """
  Status indicator components for displaying live system status, user presence,
  connection state, and service health.

  Inspired by Atlassian Design System Lozenge, GitHub's status dots, Discord's
  user presence indicators, and Vercel/Linear's service status pages.

  Pure HEEx — no JavaScript required.

  ## Sub-components

  | Component              | Purpose                                                    |
  |------------------------|------------------------------------------------------------|
  | `status_indicator/1`   | Colored dot with optional label (online/offline/away/busy) |
  | `connection_status/1`  | Online/offline/reconnecting state display                  |
  | `live_indicator/1`     | Pulsing "LIVE" badge (YouTube/Twitch style)                |
  | `service_status_row/1` | Service name + status for status pages                     |

  ## Status indicator (user presence)

      <div class="flex items-center gap-2">
        <.avatar src={@user.avatar} />
        <.status_indicator status={:online} label="Online" />
      </div>

  ## Connection status

      <.connection_status status={:reconnecting} />

  ## Live badge

      <.live_indicator />
      <.live_indicator label="STREAMING" />

  ## Service status page row

      <.service_status_row name="API" status={:operational} />
      <.service_status_row name="Database" status={:degraded} />
      <.service_status_row name="CDN" status={:outage} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # status_indicator/1
  # ---------------------------------------------------------------------------

  attr(:status, :atom,
    values: [:online, :offline, :away, :busy, :idle, :error, :unknown],
    default: :unknown,
    doc: "Presence/connection state controlling the dot color."
  )

  attr(:label, :string,
    default: nil,
    doc: "Optional text label shown beside the dot."
  )

  attr(:size, :atom,
    values: [:sm, :default, :lg],
    default: :default,
    doc: "Dot size."
  )

  attr(:show_pulse, :boolean,
    default: false,
    doc: "When `true`, animates the dot with a pulse ring (draws attention for active states)."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attrs forwarded to the wrapper `<span>`.")

  @doc """
  Renders a colored status dot with optional label.

  Use to convey presence (online/offline), process state, or health status.
  The dot inherits a semantic color based on `:status`.

  ## Example

      <%!-- User presence in a list --%>
      <.status_indicator status={:online} label="Online" />
      <.status_indicator status={:away} label="Away" />
      <.status_indicator status={:busy} label="Do not disturb" />
      <.status_indicator status={:offline} label="Offline" />

      <%!-- With pulse animation for live state --%>
      <.status_indicator status={:online} show_pulse />
  """
  def status_indicator(assigns) do
    ~H"""
    <span
      class={cn(["inline-flex items-center gap-1.5", @class])}
      aria-label={@label || status_aria_label(@status)}
      {@rest}
    >
      <span class="relative inline-flex shrink-0">
        <span class={cn(["rounded-full", dot_size_class(@size), status_dot_class(@status)])}></span>
        <%!-- Pulse ring for show_pulse --%>
        <span
          :if={@show_pulse}
          class={cn([
            "absolute inset-0 rounded-full animate-ping motion-reduce:animate-none opacity-75",
            status_dot_class(@status)
          ])}
        ></span>
      </span>
      <span :if={@label} class="text-sm text-muted-foreground">{@label}</span>
    </span>
    """
  end

  # ---------------------------------------------------------------------------
  # connection_status/1
  # ---------------------------------------------------------------------------

  attr(:status, :atom,
    values: [:online, :offline, :reconnecting, :connecting],
    default: :online,
    doc: "Current connection state."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attrs forwarded to the wrapper `<div>`.")

  @doc """
  Renders a connection state indicator with icon, colored text, and label.

  Use in application headers, status bars, or realtime feature areas to communicate
  the current WebSocket/network connection state to the user.

  ## Example

      <%!-- In a LiveView that monitors connection --%>
      <.connection_status status={if @connected, do: :online, else: :reconnecting} />
  """
  def connection_status(assigns) do
    ~H"""
    <div
      class={cn(["inline-flex items-center gap-1.5 text-xs font-medium", conn_text_class(@status), @class])}
      role="status"
      aria-live="polite"
      aria-label={conn_aria_label(@status)}
      {@rest}
    >
      <span class="relative inline-flex h-2 w-2 shrink-0">
        <span class={cn(["rounded-full h-full w-full", conn_dot_class(@status)])}></span>
        <span
          :if={@status == :reconnecting || @status == :connecting}
          class={cn(["absolute inset-0 rounded-full animate-ping motion-reduce:animate-none opacity-75", conn_dot_class(@status)])}
        ></span>
      </span>
      <span>{conn_label(@status)}</span>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # live_indicator/1
  # ---------------------------------------------------------------------------

  attr(:label, :string,
    default: "LIVE",
    doc: "Text displayed inside the badge."
  )

  attr(:pulse, :boolean,
    default: true,
    doc: "When `true`, animates the dot with a ping pulse."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attrs forwarded to the `<span>`.")

  @doc """
  Renders a pulsing "LIVE" badge, similar to YouTube/Twitch live stream indicators.

  Use for real-time feeds, live dashboards, active broadcasts, or streaming events.

  ## Example

      <div class="flex items-center gap-2">
        <.live_indicator />
        <span class="text-sm font-medium">Daily Standup</span>
      </div>

      <%!-- Custom label --%>
      <.live_indicator label="RECORDING" />
  """
  def live_indicator(assigns) do
    ~H"""
    <span
      class={cn([
        "inline-flex items-center gap-1.5 rounded-full bg-destructive px-2.5 py-0.5",
        "text-destructive-foreground text-xs font-bold tracking-wide uppercase",
        @class
      ])}
      role="status"
      aria-label="Currently live"
      {@rest}
    >
      <span class="relative inline-flex h-1.5 w-1.5 shrink-0">
        <span class="rounded-full h-full w-full bg-current"></span>
        <span
          :if={@pulse}
          class="absolute inset-0 rounded-full bg-current animate-ping motion-reduce:animate-none opacity-75"
        ></span>
      </span>
      {@label}
    </span>
    """
  end

  # ---------------------------------------------------------------------------
  # service_status_row/1
  # ---------------------------------------------------------------------------

  attr(:name, :string, required: true, doc: "Service name (e.g. 'API', 'Database', 'CDN').")

  attr(:status, :atom,
    values: [:operational, :degraded, :partial_outage, :outage, :maintenance, :unknown],
    default: :unknown,
    doc: "Current service health status."
  )

  attr(:description, :string,
    default: nil,
    doc: "Optional detail text (e.g. 'Response times elevated' or 'All systems normal')."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attrs forwarded to the root `<div>`.")

  @doc """
  Renders a single row for a service status page.

  Combines a service name, optional description, and a colored status lozenge.
  Stack multiple rows inside a container for a full status page.

  ## Example

      <div class="space-y-2 divide-y divide-border">
        <.service_status_row name="API" status={:operational} />
        <.service_status_row name="Database" status={:degraded} description="Elevated response times" />
        <.service_status_row name="CDN" status={:maintenance} description="Scheduled until 4 AM UTC" />
      </div>
  """
  def service_status_row(assigns) do
    ~H"""
    <div
      class={cn(["flex items-center justify-between py-3 gap-4", @class])}
      {@rest}
    >
      <div class="min-w-0 flex-1">
        <p class="text-sm font-medium text-foreground">{@name}</p>
        <p :if={@description} class="text-xs text-muted-foreground mt-0.5">{@description}</p>
      </div>
      <span class={cn([
        "shrink-0 inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-xs font-medium",
        service_lozenge_class(@status)
      ])}>
        <span class={cn(["h-1.5 w-1.5 rounded-full", service_dot_class(@status)])}></span>
        {service_label(@status)}
      </span>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp dot_size_class(:sm), do: "h-2 w-2"
  defp dot_size_class(:default), do: "h-2.5 w-2.5"
  defp dot_size_class(:lg), do: "h-3 w-3"

  defp status_dot_class(:online), do: "bg-success"
  defp status_dot_class(:offline), do: "bg-muted-foreground"
  defp status_dot_class(:away), do: "bg-warning"
  defp status_dot_class(:busy), do: "bg-destructive"
  defp status_dot_class(:idle), do: "bg-warning/70"
  defp status_dot_class(:error), do: "bg-destructive"
  defp status_dot_class(:unknown), do: "bg-muted-foreground/50"

  defp status_aria_label(:online), do: "Online"
  defp status_aria_label(:offline), do: "Offline"
  defp status_aria_label(:away), do: "Away"
  defp status_aria_label(:busy), do: "Do not disturb"
  defp status_aria_label(:idle), do: "Idle"
  defp status_aria_label(:error), do: "Error"
  defp status_aria_label(:unknown), do: "Unknown status"

  defp conn_dot_class(:online), do: "bg-success"
  defp conn_dot_class(:offline), do: "bg-muted-foreground"
  defp conn_dot_class(:reconnecting), do: "bg-warning"
  defp conn_dot_class(:connecting), do: "bg-primary"

  defp conn_text_class(:online), do: "text-success"
  defp conn_text_class(:offline), do: "text-muted-foreground"
  defp conn_text_class(:reconnecting), do: "text-warning"
  defp conn_text_class(:connecting), do: "text-primary"

  defp conn_label(:online), do: "Connected"
  defp conn_label(:offline), do: "Disconnected"
  defp conn_label(:reconnecting), do: "Reconnecting..."
  defp conn_label(:connecting), do: "Connecting..."

  defp conn_aria_label(:online), do: "Connection status: Connected"
  defp conn_aria_label(:offline), do: "Connection status: Disconnected"
  defp conn_aria_label(:reconnecting), do: "Connection status: Reconnecting"
  defp conn_aria_label(:connecting), do: "Connection status: Connecting"

  defp service_label(:operational), do: "Operational"
  defp service_label(:degraded), do: "Degraded"
  defp service_label(:partial_outage), do: "Partial Outage"
  defp service_label(:outage), do: "Outage"
  defp service_label(:maintenance), do: "Maintenance"
  defp service_label(:unknown), do: "Unknown"

  defp service_lozenge_class(:operational), do: "bg-success/10 text-success"
  defp service_lozenge_class(:degraded), do: "bg-warning/10 text-warning"
  defp service_lozenge_class(:partial_outage), do: "bg-warning/10 text-warning"
  defp service_lozenge_class(:outage), do: "bg-destructive/10 text-destructive"
  defp service_lozenge_class(:maintenance), do: "bg-blue-50 text-blue-700 dark:bg-blue-950/50 dark:text-blue-300"
  defp service_lozenge_class(:unknown), do: "bg-muted text-muted-foreground"

  defp service_dot_class(:operational), do: "bg-success"
  defp service_dot_class(:degraded), do: "bg-warning"
  defp service_dot_class(:partial_outage), do: "bg-warning"
  defp service_dot_class(:outage), do: "bg-destructive"
  defp service_dot_class(:maintenance), do: "bg-blue-500"
  defp service_dot_class(:unknown), do: "bg-muted-foreground"
end
