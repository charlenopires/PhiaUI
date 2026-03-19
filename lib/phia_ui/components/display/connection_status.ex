defmodule PhiaUi.Components.Display.ConnectionStatus do
  @moduledoc """
  Connection status indicator for real-time collaboration.

  Shows one of three states with an icon and tooltip:
  - `:connected` — green cloud-check, "Connected"
  - `:reconnecting` — amber spinning cloud, "Reconnecting..."
  - `:offline` — red cloud-off, "Offline — changes will sync when reconnected"

  ## Examples

      <.connection_status status={:connected} />
      <.connection_status status={:offline} class="ml-2" />
  """

  use Phoenix.Component

  attr :status, :atom, default: :connected, values: [:connected, :reconnecting, :offline]
  attr :class, :string, default: nil

  def connection_status(assigns) do
    assigns = assign(assigns, :icon_markup, icon_path(assigns.status))

    ~H"""
    <div
      class={["inline-flex items-center gap-1", @class]}
      title={tooltip(@status)}
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
        class={[
          "h-4 w-4",
          icon_color(@status),
          if(@status == :reconnecting, do: "animate-pulse", else: "")
        ]}
      >
        <%= Phoenix.HTML.raw(@icon_markup) %>
      </svg>
    </div>
    """
  end

  # Cloud with check mark
  defp icon_path(:connected) do
    """
    <path d="M20 16.2A4.5 4.5 0 0 0 17.5 8h-1.8A7 7 0 1 0 4 14.9"/>
    <polyline points="9 15 12 12 15 15"/>
    """
  end

  # Cloud (plain — with pulse animation via CSS)
  defp icon_path(:reconnecting) do
    """
    <path d="M20 16.2A4.5 4.5 0 0 0 17.5 8h-1.8A7 7 0 1 0 4 14.9"/>
    <path d="M12 13v5"/>
    <path d="M9.5 15.5 12 13l2.5 2.5"/>
    """
  end

  # Cloud with X
  defp icon_path(:offline) do
    """
    <path d="M20 16.2A4.5 4.5 0 0 0 17.5 8h-1.8A7 7 0 1 0 4 14.9"/>
    <line x1="10" y1="12" x2="14" y2="16"/>
    <line x1="14" y1="12" x2="10" y2="16"/>
    """
  end

  defp icon_color(:connected), do: "text-green-500"
  defp icon_color(:reconnecting), do: "text-amber-500"
  defp icon_color(:offline), do: "text-red-500"

  defp tooltip(:connected), do: "Connected"
  defp tooltip(:reconnecting), do: "Reconnecting..."
  defp tooltip(:offline), do: "Offline — changes will sync when reconnected"
end
