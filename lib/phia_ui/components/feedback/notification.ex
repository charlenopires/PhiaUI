defmodule PhiaUi.Components.Notification do
  @moduledoc """
  Rich in-app notification components inspired by Ant Design Notification, Mantine Notifications,
  and Atlassian Flag system.

  Distinct from `Toast` (ephemeral, auto-dismiss after seconds) and `Alert` (inline static):
  notifications are semi-persistent messages representing events — payments received, mentions,
  deployments finished, system events. They can live in a notification center panel or as
  corner cards manually dismissed by the user.

  ## Sub-components

  | Component               | Purpose                                                     |
  |-------------------------|-------------------------------------------------------------|
  | `notification/1`        | Floating corner notification card (manually dismissed)      |
  | `notification_item/1`   | Row entry inside a notification center list                 |
  | `notification_center/1` | Dropdown panel container listing `notification_item/1` rows |
  | `notification_badge/1`  | Unread count badge wrapper for a bell/trigger element       |

  ## Floating corner notification

      <.notification
        id="notif-payment"
        variant={:success}
        title="Payment received"
        description="$99.00 received from Acme Corp."
        timestamp="Just now"
      />

  ## Notification center with badge

      <.notification_badge count={@unread_count}>
        <.button variant={:ghost} size={:icon} phx-click="open_notifications">
          <.icon name="bell" class="h-5 w-5" />
        </.button>
      </.notification_badge>

      <.notification_center :if={@notifications_open}>
        <.notification_item
          :for={n <- @notifications}
          title={n.title}
          description={n.body}
          timestamp={n.time_ago}
          read={n.read}
          variant={n.variant}
        />
        <:footer>
          <.button variant={:ghost} size={:sm} class="w-full">
            View all notifications
          </.button>
        </:footer>
      </.notification_center>

  ## Accessibility

  - `notification/1` uses `role="alert"` + `aria-atomic="true"` so screen readers
    announce new notifications immediately.
  - `notification_center/1` uses `role="region"` with `aria-label`.
  - `notification_badge/1` provides an `aria-label` with the count for screen readers.
  - Close button on `notification/1` has an explicit `aria-label`.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  alias Phoenix.LiveView.JS

  # ---------------------------------------------------------------------------
  # notification/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "Unique ID — used for JS.hide dismiss animation.")

  attr(:title, :string, required: true, doc: "Short notification heading.")

  attr(:description, :string, default: nil, doc: "Supporting body text.")

  attr(:timestamp, :string,
    default: nil,
    doc: "Relative or absolute timestamp string shown below the description (e.g. 'Just now', '3 min ago')."
  )

  attr(:variant, :atom,
    values: [:default, :success, :destructive, :warning, :info],
    default: :default,
    doc: "Controls the border tint and default icon."
  )

  attr(:closeable, :boolean,
    default: true,
    doc: "When `true`, renders an × dismiss button. Set to `false` for persistent notifications."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root element.")
  attr(:rest, :global, doc: "HTML attrs forwarded to the root `<div>`.")

  slot(:icon, doc: "Optional custom icon replacing the default variant icon.")
  slot(:actions, doc: "Optional action buttons rendered below the description.")

  @doc """
  Renders a floating notification card, typically placed at a corner of the viewport.

  Use for semi-persistent events (payments, mentions, deployments) where the user
  needs to explicitly dismiss the notification. For auto-dismissing transient messages,
  use `Toast` or `GlobalMessage`.

  ## Example

      <.notification
        id="notif-deploy"
        variant={:success}
        title="Deployment complete"
        description="v2.4.1 is now live on production."
        timestamp="2 min ago"
      >
        <:actions>
          <.button size={:xs} variant={:ghost} phx-click="view_deploy">View</.button>
        </:actions>
      </.notification>
  """
  def notification(assigns) do
    ~H"""
    <div
      id={@id}
      role="alert"
      aria-atomic="true"
      class={cn([
        "pointer-events-auto relative w-80 rounded-lg border bg-background p-4 shadow-lg",
        "flex gap-3",
        notif_variant_class(@variant),
        @class
      ])}
      {@rest}
    >
      <%!-- Icon: custom slot or default variant icon --%>
      <div class="shrink-0 mt-0.5">
        <span :if={@icon != []} class="[&>svg]:size-5 [&>svg]:text-current">
          {render_slot(@icon)}
        </span>
        <.icon
          :if={@icon == []}
          name={notif_variant_icon(@variant)}
          class={cn(["h-5 w-5", notif_icon_color(@variant)])}
        />
      </div>

      <%!-- Content --%>
      <div class="flex-1 min-w-0">
        <p class="text-sm font-semibold text-foreground leading-tight">{@title}</p>
        <p :if={@description} class="mt-0.5 text-xs text-muted-foreground leading-normal">
          {@description}
        </p>
        <p :if={@timestamp} class="mt-1.5 text-xs text-muted-foreground/60">{@timestamp}</p>
        <div :if={@actions != []} class="mt-2 flex flex-wrap gap-2">
          {render_slot(@actions)}
        </div>
      </div>

      <%!-- Dismiss button --%>
      <button
        :if={@closeable}
        type="button"
        aria-label="Dismiss notification"
        phx-click={JS.hide(to: "##{@id}", transition: {"transition-all duration-200 ease-in", "opacity-100 scale-100", "opacity-0 scale-95"})}
        class={
          cn([
            "absolute right-2 top-2 rounded p-1",
            "text-muted-foreground hover:text-foreground hover:bg-accent",
            "transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
          ])
        }
      >
        <.icon name="x" class="h-3.5 w-3.5" />
      </button>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # notification_item/1
  # ---------------------------------------------------------------------------

  attr(:title, :string, required: true, doc: "Notification heading.")

  attr(:description, :string, default: nil, doc: "Supporting detail text.")

  attr(:timestamp, :string,
    default: nil,
    doc: "Relative timestamp string (e.g. '3 min ago')."
  )

  attr(:read, :boolean,
    default: false,
    doc: "When `false`, renders an unread dot and bold title."
  )

  attr(:variant, :atom,
    values: [:default, :success, :destructive, :warning, :info],
    default: :default,
    doc: "Controls the default icon color."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attrs forwarded to the root `<div>`.")

  slot(:icon, doc: "Optional custom icon slot.")
  slot(:actions, doc: "Optional action buttons shown below description.")

  @doc """
  Renders a single notification row for use inside `notification_center/1`.

  Displays an unread indicator dot (when `read={false}`), a variant icon,
  title, description, timestamp, and optional inline actions.

  ## Example

      <.notification_item
        title="Alice mentioned you"
        description="@you in #general — 'Can you review my PR?'"
        timestamp="5 min ago"
        read={false}
        variant={:info}
      />
  """
  def notification_item(assigns) do
    ~H"""
    <div
      class={cn([
        "relative flex gap-3 px-4 py-3 hover:bg-accent/50 transition-colors cursor-pointer",
        !@read && "bg-primary/5",
        @class
      ])}
      {@rest}
    >
      <%!-- Unread indicator dot --%>
      <span
        :if={!@read}
        class="absolute left-1.5 top-[18px] h-1.5 w-1.5 rounded-full bg-primary"
        aria-hidden="true"
      ></span>

      <%!-- Icon --%>
      <div class="shrink-0 mt-0.5">
        <span :if={@icon != []} class="[&>svg]:size-5 [&>svg]:text-current">
          {render_slot(@icon)}
        </span>
        <.icon
          :if={@icon == []}
          name={notif_variant_icon(@variant)}
          class={cn(["h-5 w-5", notif_icon_color(@variant)])}
        />
      </div>

      <%!-- Content --%>
      <div class="flex-1 min-w-0">
        <p class={cn(["text-sm text-foreground leading-tight", !@read && "font-medium"])}>
          {@title}
        </p>
        <p :if={@description} class="mt-0.5 text-xs text-muted-foreground line-clamp-2">
          {@description}
        </p>
        <div :if={@actions != []} class="mt-1.5 flex flex-wrap gap-2">
          {render_slot(@actions)}
        </div>
      </div>

      <%!-- Timestamp --%>
      <span :if={@timestamp} class="shrink-0 text-xs text-muted-foreground/60 mt-0.5 whitespace-nowrap">
        {@timestamp}
      </span>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # notification_center/1
  # ---------------------------------------------------------------------------

  attr(:title, :string, default: "Notifications", doc: "Panel heading text.")

  attr(:empty_text, :string,
    default: "No notifications yet",
    doc: "Message shown when no items are rendered."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the panel.")
  attr(:rest, :global, doc: "HTML attrs forwarded to the root `<div>`.")

  slot(:header_actions,
    doc: "Buttons/links placed next to the title, e.g. 'Mark all read', 'Settings'."
  )

  slot(:inner_block, doc: "Contains `notification_item/1` entries.")

  slot(:footer,
    doc: "Optional footer row, e.g. 'View all notifications' link."
  )

  @doc """
  Renders a dropdown notification center panel.

  Place inside a positioned container (e.g. a Popover) to show as a dropdown.
  Put `notification_item/1` components as the inner content.

  ## Example

      <.notification_center>
        <:header_actions>
          <.button variant={:ghost} size={:sm} phx-click="mark_all_read">
            Mark all read
          </.button>
        </:header_actions>
        <.notification_item title="New comment" timestamp="1 min ago" />
        <.notification_item title="PR merged" read={true} timestamp="2h ago" />
        <:footer>
          <.button variant={:ghost} size={:sm} class="w-full">View all</.button>
        </:footer>
      </.notification_center>
  """
  def notification_center(assigns) do
    ~H"""
    <div
      class={cn([
        "flex flex-col w-80 sm:w-96 rounded-lg border border-border bg-background shadow-lg overflow-hidden",
        @class
      ])}
      role="region"
      aria-label={@title}
      {@rest}
    >
      <%!-- Header --%>
      <div class="flex items-center justify-between px-4 py-3 border-b border-border shrink-0">
        <h3 class="text-sm font-semibold text-foreground">{@title}</h3>
        <div :if={@header_actions != []} class="flex items-center gap-1">
          {render_slot(@header_actions)}
        </div>
      </div>

      <%!-- Body — scrollable list --%>
      <div class="flex-1 overflow-y-auto max-h-80 divide-y divide-border">
        {render_slot(@inner_block)}
        <%!-- Empty state --%>
        <div
          :if={@inner_block == []}
          class="flex flex-col items-center justify-center py-12 text-center px-4"
        >
          <.icon name="bell-off" class="h-8 w-8 text-muted-foreground mb-3" />
          <p class="text-sm text-muted-foreground">{@empty_text}</p>
        </div>
      </div>

      <%!-- Footer --%>
      <div :if={@footer != []} class="border-t border-border px-4 py-2 shrink-0">
        {render_slot(@footer)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # notification_badge/1
  # ---------------------------------------------------------------------------

  attr(:count, :integer,
    default: 0,
    doc: "Number of unread notifications. Badge is hidden when 0 (unless `show_zero`)."
  )

  attr(:max, :integer,
    default: 99,
    doc: "Maximum count displayed before showing `N+`. Default: `99`."
  )

  attr(:show_zero, :boolean,
    default: false,
    doc: "When `true`, the badge is rendered even when `count` is 0."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the wrapper.")
  attr(:rest, :global, doc: "HTML attrs forwarded to the wrapper `<div>`.")

  slot(:inner_block, required: true, doc: "The trigger element (button, icon) to wrap.")

  @doc """
  Wraps a trigger element with an unread notification count badge.

  The badge uses `position: absolute` relative to the wrapper, so the wrapper
  uses `relative inline-flex`. Place your bell icon button as the inner block.

  ## Example

      <.notification_badge count={@unread}>
        <.button variant={:ghost} size={:icon} aria-label="Open notifications">
          <.icon name="bell" class="h-5 w-5" />
        </.button>
      </.notification_badge>
  """
  def notification_badge(assigns) do
    ~H"""
    <div class={cn(["relative inline-flex", @class])} {@rest}>
      {render_slot(@inner_block)}
      <span
        :if={@count > 0 || @show_zero}
        aria-label={"#{min(@count, @max)} unread notifications"}
        class={cn([
          "absolute -top-1.5 -right-1.5 flex items-center justify-center",
          "min-w-[18px] h-[18px] rounded-full bg-destructive text-destructive-foreground",
          "text-[10px] font-bold leading-none px-1 pointer-events-none"
        ])}
      >
        {if @count > @max, do: "#{@max}+", else: @count}
      </span>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp notif_variant_icon(:success), do: "circle-check"
  defp notif_variant_icon(:destructive), do: "circle-x"
  defp notif_variant_icon(:warning), do: "triangle-alert"
  defp notif_variant_icon(:info), do: "info"
  defp notif_variant_icon(:default), do: "bell"

  defp notif_icon_color(:success), do: "text-success"
  defp notif_icon_color(:destructive), do: "text-destructive"
  defp notif_icon_color(:warning), do: "text-warning"
  defp notif_icon_color(:info), do: "text-blue-500"
  defp notif_icon_color(:default), do: "text-muted-foreground"

  defp notif_variant_class(:success), do: "border-success/30"
  defp notif_variant_class(:destructive), do: "border-destructive/30"
  defp notif_variant_class(:warning), do: "border-warning/30"
  defp notif_variant_class(:info), do: "border-blue-500/30"
  defp notif_variant_class(:default), do: "border-border"
end
