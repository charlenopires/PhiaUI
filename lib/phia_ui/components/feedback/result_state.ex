defmodule PhiaUi.Components.ResultState do
  @moduledoc """
  Result state — centered page-level feedback with icon, title, description, and actions.

  Inspired by Ant Design `Result`. Used for success confirmations, error pages,
  not-found states, forbidden access, and informational feedback.

  ## Examples

      <.result_state status={:success} title="Payment Complete!" description="Your order has been placed." >
        <:actions>
          <.button>Go to Orders</.button>
        </:actions>
      </.result_state>

      <.result_state status={:not_found} title="Page not found" />

      <.result_state status={:error} title="Something went wrong" description="Please try again later.">
        <:extra><p class="text-xs text-muted-foreground">Error code: 500</p></:extra>
        <:actions><.button variant={:outline}>Contact support</.button></:actions>
      </.result_state>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  attr(:status, :atom,
    required: true,
    values: [:success, :error, :warning, :info, :not_found, :forbidden],
    doc: "Controls the icon and color scheme."
  )

  attr(:title, :string, required: true, doc: "Primary heading.")

  attr(:description, :string,
    default: nil,
    doc: "Optional secondary description rendered below the title."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root element.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>`.")

  slot(:extra, doc: "Optional extra content below the description.")
  slot(:actions, doc: "Optional CTA buttons below the extra content.")

  def result_state(assigns) do
    ~H"""
    <div
      class={cn(["flex flex-col items-center justify-center gap-4 py-12 text-center px-4", @class])}
      {@rest}
    >
      <.icon name={status_icon(@status)} class={cn(["h-16 w-16", status_color(@status)])} />
      <div class="space-y-2">
        <h2 class="text-xl font-semibold text-foreground">{@title}</h2>
        <p :if={@description} class="text-sm text-muted-foreground max-w-sm">
          {@description}
        </p>
      </div>
      <div :if={@extra != []} class="text-sm text-muted-foreground">
        {render_slot(@extra)}
      </div>
      <div :if={@actions != []} class="flex gap-2 flex-wrap justify-center">
        {render_slot(@actions)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp status_icon(:success), do: "circle-check"
  defp status_icon(:error), do: "circle-x"
  defp status_icon(:warning), do: "triangle-alert"
  defp status_icon(:info), do: "info"
  defp status_icon(:not_found), do: "file-question"
  defp status_icon(:forbidden), do: "shield-off"

  defp status_color(:success), do: "text-green-500"
  defp status_color(:error), do: "text-red-500"
  defp status_color(:warning), do: "text-amber-500"
  defp status_color(:info), do: "text-blue-500"
  defp status_color(:not_found), do: "text-muted-foreground"
  defp status_color(:forbidden), do: "text-muted-foreground"
end
