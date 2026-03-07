defmodule PhiaUi.Components.NotificationCard do
  @moduledoc """
  Notification/alert card with type-based color coding and dismiss support.

  Displays a title, optional message, timestamp, and type icon. Supports
  four severity levels (:info, :success, :warning, :error) with matching
  left-border color and icon. Optionally dismissible with a phx-click handler.
  """

  use Phoenix.Component

  import PhiaUi.Components.Icon, only: [icon: 1]
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :title, :string, required: true, doc: "Notification title"
  attr :message, :string, default: nil, doc: "Notification body text"
  attr :timestamp, :string, default: nil, doc: "Timestamp label (e.g. '2 min ago')"

  attr :type, :atom,
    default: :info,
    values: [:info, :success, :warning, :error],
    doc: "Severity type — controls border color and icon"

  attr :dismissible, :boolean, default: false, doc: "Show dismiss (X) button"
  attr :on_dismiss, :string, default: nil, doc: "phx-click event for dismiss button"
  attr :read, :boolean, default: false, doc: "Dim the card when already read"
  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to the outer div"

  slot :icon, doc: "Custom icon override (replaces default type icon)"
  slot :actions, doc: "Action buttons rendered at the bottom"

  @doc "Renders a notification card."
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
