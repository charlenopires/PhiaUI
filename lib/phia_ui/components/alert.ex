defmodule PhiaUi.Components.Alert do
  @moduledoc """
  Alert component for inline feedback messages.

  Provides 4 semantic variants following the shadcn/ui Alert anatomy.
  Pure HEEx — no JavaScript required.

  ## Sub-components

  - `alert/1` — root container with `role="alert"`
  - `alert_title/1` — bold heading inside the alert
  - `alert_description/1` — muted supporting text
  - `alert_action/1` — inline action button (dismiss, learn more, etc.)

  ## Variants

  | Variant         | Use case                                  |
  |-----------------|-------------------------------------------|
  | `:default`      | General informational message             |
  | `:destructive`  | Error or dangerous action feedback        |
  | `:warning`      | Caution / non-critical issue              |
  | `:success`      | Confirmation of a successful action       |

  ## Examples

      <.alert>
        <.alert_title>Heads up!</.alert_title>
        <.alert_description>You can change this in settings.</.alert_description>
      </.alert>

      <.alert variant={:destructive}>
        <:icon><.icon name="circle-x" /></:icon>
        <.alert_title>Error</.alert_title>
        <.alert_description>Your session has expired.</.alert_description>
      </.alert>

      <.alert variant={:success}>
        <.alert_title>Payment confirmed</.alert_title>
        <.alert_description>Your invoice has been sent.</.alert_description>
      </.alert>

  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:variant, :atom,
    values: [:default, :destructive, :warning, :success],
    default: :default,
    doc: "Visual style variant"
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes (merged via cn/1)"
  )

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the root element (data-*, aria-*, etc.)"
  )

  slot(:icon,
    doc: "Optional leading icon (e.g. <.icon name='circle-alert' />)"
  )

  slot(:inner_block,
    required: true,
    doc: "Alert content — typically alert_title/1 and alert_description/1"
  )

  @doc """
  Renders a styled alert container with `role=\"alert\"` for screen readers.

  Place `alert_title/1` and `alert_description/1` inside as inner content.
  Optionally provide an `:icon` slot for a leading icon.
  """
  def alert(assigns) do
    ~H"""
    <div
      role="alert"
      class={cn([base_class(), variant_class(@variant), @class])}
      {@rest}
    >
      <%= if @icon != [] do %>
        <span class="[&>svg]:absolute [&>svg]:left-4 [&>svg]:top-4 [&>svg]:size-4">
          <%= render_slot(@icon) %>
        </span>
      <% end %>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  slot(:inner_block, required: true, doc: "Title text")

  @doc """
  Renders the alert heading in bold with tight leading.
  """
  def alert_title(assigns) do
    ~H"""
    <p class={cn(["mb-1 font-medium leading-none tracking-tight", @class])}>
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  slot(:inner_block, required: true, doc: "Description text")

  @doc """
  Renders the alert supporting text in muted, small type.
  """
  def alert_description(assigns) do
    ~H"""
    <p class={cn(["text-sm text-muted-foreground", @class])}>
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the button element")
  slot(:inner_block, required: true, doc: "Action label text")

  @doc """
  Renders an inline action button inside the alert (dismiss, learn more, CTA).

      <.alert variant={:warning}>
        <.alert_title>Session expiring</.alert_title>
        <.alert_description>Your session expires in 5 minutes.</.alert_description>
        <.alert_action phx-click="renew_session">Renew</.alert_action>
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

  defp base_class do
    "relative w-full rounded-lg border p-4 [&>svg~*]:pl-7 [&>svg+div]:translate-y-[-3px] [&>svg]:absolute [&>svg]:left-4 [&>svg]:top-4 [&>svg]:size-4 [&>svg]:text-current"
  end

  defp variant_class(:default),
    do: "bg-background text-foreground"

  defp variant_class(:destructive),
    do: "border-destructive/50 bg-destructive/10 text-destructive [&>svg]:text-destructive"

  defp variant_class(:warning),
    do:
      "border-yellow-200 bg-yellow-50 text-yellow-800 [&>svg]:text-yellow-600 dark:border-yellow-800 dark:bg-yellow-950 dark:text-yellow-400"

  defp variant_class(:success),
    do:
      "border-green-200 bg-green-50 text-green-800 [&>svg]:text-green-600 dark:border-green-800 dark:bg-green-950 dark:text-green-400"
end
