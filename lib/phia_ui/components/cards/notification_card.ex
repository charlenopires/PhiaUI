defmodule PhiaUi.Components.NotificationCard do
  @moduledoc """
  Notification/alert card with type-based color coding and dismiss support.

  Displays a title, optional message body, timestamp, and an icon that
  automatically matches the `type`. Optionally shows a dismiss button that
  fires a LiveView event when clicked. The card can be visually dimmed to
  indicate "already read" state.

  ## Severity types

  | `:type`      | Left border colour | Default icon         |
  |--------------|--------------------|----------------------|
  | `:info`      | `border-l-blue-500`    | `information-circle` |
  | `:success`   | `border-l-emerald-500` | `check-circle`       |
  | `:warning`   | `border-l-amber-500`   | `exclamation-triangle`|
  | `:error`     | `border-l-red-500`     | `x-circle`           |

  ## Dismiss support

  Set `dismissible={true}` and provide `on_dismiss` with a LiveView event
  name. An `×` button renders at the top-right; clicking it fires the event
  with `phx-click`. Handle the event in your LiveView to remove the
  notification from state.

  ## Read state

  Set `read={true}` to apply `opacity-60` — useful for marking a notification
  as acknowledged without removing it from the list.

  ## Custom icon slot

  Override the default type icon by providing the `:icon` slot:

      <.notification_card title="Build succeeded" type={:success}>
        <:icon><.icon name="rocket" class="text-emerald-500" /></:icon>
      </.notification_card>

  ## Examples

      <%!-- Info notification --%>
      <.notification_card
        title="New message from Alice"
        message="Hey, are you free for a call?"
        timestamp="2 min ago"
        type={:info}
      />

      <%!-- Error with dismiss --%>
      <.notification_card
        title="Payment failed"
        message="Your card was declined. Please update your billing information."
        type={:error}
        dismissible={true}
        on_dismiss="dismiss_notification"
        read={false}
      />

      <%!-- Notification list from state --%>
      <div class="space-y-2">
        <.notification_card
          :for={notif <- @notifications}
          title={notif.title}
          message={notif.body}
          timestamp={notif.relative_time}
          type={notif.type}
          read={notif.read}
          dismissible={true}
          on_dismiss="dismiss_notif"
        />
      </div>
  """

  use Phoenix.Component

  import PhiaUi.Components.Icon, only: [icon: 1]
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:title, :string, required: true, doc: "Notification title")
  attr(:message, :string, default: nil, doc: "Notification body text")
  attr(:timestamp, :string, default: nil, doc: "Timestamp label (e.g. '2 min ago')")

  attr(:type, :atom,
    default: :info,
    values: [:info, :success, :warning, :error],
    doc: "Severity type — controls border color and icon"
  )

  attr(:dismissible, :boolean, default: false, doc: "Show dismiss (X) button")
  attr(:on_dismiss, :string, default: nil, doc: "phx-click event for dismiss button")
  attr(:read, :boolean, default: false, doc: "Dim the card when already read")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the outer div")

  slot(:icon, doc: "Custom icon override (replaces default type icon)")
  slot(:actions, doc: "Action buttons rendered at the bottom")

  @doc """
  Renders a notification card with a colored left border and type icon.

  The card has three optional regions:

  - **Icon area** — type-specific icon on the left (or custom `:icon` slot).
  - **Content area** — title, optional body `message`, optional `timestamp`.
  - **Actions slot** — buttons rendered below the message.

  A dismiss button (`×`) appears at the top-right when `dismissible={true}`.
  The `on_dismiss` event name drives a `phx-click` attribute on that button.

  ## Examples

      <%!-- Success notification --%>
      <.notification_card
        title="Profile updated"
        message="Your changes have been saved."
        type={:success}
        timestamp="just now"
      />

      <%!-- Dismissible error --%>
      <.notification_card
        title="Upload failed"
        message="File exceeds the 10 MB limit."
        type={:error}
        dismissible={true}
        on_dismiss="clear_error"
      />
  """
  def notification_card(assigns) do
    ~H"""
    <div
      class={cn([
        "relative flex gap-3 rounded-lg border border-l-4 bg-card p-4 shadow-sm",
        type_border(@type),
        @read && "opacity-60",
        @class
      ])}
      {@rest}
    >
      <%!-- Left icon --%>
      <div class="shrink-0 mt-0.5">
        <span :if={@icon != []}>
          {render_slot(@icon)}
        </span>
        <.icon
          :if={@icon == []}
          name={type_icon(@type)}
          size={:sm}
          class={type_icon_class(@type)}
        />
      </div>

      <%!-- Content --%>
      <div class="flex-1 min-w-0">
        <p class="font-semibold text-sm">{@title}</p>
        <p :if={@message} class="text-sm text-muted-foreground mt-0.5">{@message}</p>
        <p :if={@timestamp} class="text-xs text-muted-foreground mt-1">{@timestamp}</p>

        <div :if={@actions != []} class="mt-2">
          {render_slot(@actions)}
        </div>
      </div>

      <%!-- Dismiss button --%>
      <button
        :if={@dismissible}
        type="button"
        class="absolute right-3 top-3 rounded-sm text-muted-foreground hover:text-foreground focus:outline-none"
        phx-click={@on_dismiss}
        aria-label="Dismiss notification"
      >
        <.icon name="x" size={:xs} />
      </button>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp type_border(:info), do: "border-l-blue-500"
  defp type_border(:success), do: "border-l-emerald-500"
  defp type_border(:warning), do: "border-l-amber-500"
  defp type_border(:error), do: "border-l-red-500"

  defp type_icon(:info), do: "information-circle"
  defp type_icon(:success), do: "check-circle"
  defp type_icon(:warning), do: "exclamation-triangle"
  defp type_icon(:error), do: "x-circle"

  defp type_icon_class(:info), do: "text-blue-500"
  defp type_icon_class(:success), do: "text-emerald-500"
  defp type_icon_class(:warning), do: "text-amber-500"
  defp type_icon_class(:error), do: "text-red-500"
end
