defmodule PhiaUi.Components.ActionButton do
  @moduledoc """
  Specialized action buttons for common UI interaction patterns.

  Exports four components:

  - `close_button/1` — X / dismiss button for modals, drawers, and cards
  - `badge_button/1` — button with a notification count badge overlay
  - `confirm_button/1` — inline two-step confirmation (no popover)
  - `countdown_button/1` — timer-locked button for OTP resend / rate limiting

  ## Notes

  - `close_button` renders an inline X SVG — does NOT use `<.icon>` component.
  - `badge_button` uses `attr :count, :any` (not `:integer`) so that `nil`
    (no badge) is valid without a compile-time type error.
  - `confirm_button` puts `@rest` on the root `<div>`, NOT on inner buttons,
    to avoid double-binding phx-click etc.
  - `countdown_button` always renders `disabled={true}` initially; the
    `PhiaCountdownButton` hook removes the attribute when the timer expires.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # close_button/1
  # ---------------------------------------------------------------------------

  attr :size, :atom,
    values: [:xs, :sm, :default, :lg],
    default: :default,
    doc: "Button dimensions"

  attr :variant, :atom,
    values: [:ghost, :outline, :filled],
    default: :ghost,
    doc: "Visual style — :ghost (default), :outline, or :filled"

  attr :label, :string,
    default: "Close",
    doc: "aria-label text for screen readers"

  attr :shape, :atom,
    values: [:square, :circle],
    default: :square,
    doc: "Corner radius"

  attr :disabled, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a dedicated close / dismiss button with an inline X SVG.

  Does NOT use the `<.icon>` component — the X is always rendered inline so
  this component has zero external dependencies.

  ## Example

      <.close_button phx-click={JS.hide(to: "#modal")} />

      <.close_button size={:lg} shape={:circle} label="Dismiss notification" />
  """
  def close_button(assigns) do
    ~H"""
    <button
      type="button"
      aria-label={@label}
      class={cn([
        "inline-flex items-center justify-center transition-colors",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
        close_variant_class(@variant),
        close_size_class(@size),
        close_shape_class(@shape),
        @disabled && "pointer-events-none opacity-50",
        @class
      ])}
      disabled={@disabled}
      {@rest}
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        class={close_icon_size(@size)}
        aria-hidden="true"
      >
        <path d="M6 6L18 18M18 6L6 18" />
      </svg>
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # badge_button/1
  # ---------------------------------------------------------------------------

  attr :count, :any,
    default: nil,
    doc: "Badge count — nil hides badge, 0 hides badge, > max_count shows 'max+'"

  attr :max_count, :integer,
    default: 99,
    doc: "Maximum displayed count — exceeded values show as 'max+'"

  attr :badge_color, :atom,
    values: [:destructive, :primary, :warning, :success],
    default: :destructive,
    doc: "Badge background color"

  attr :badge_position, :atom,
    values: [:top_right, :top_left, :bottom_right, :bottom_left],
    default: :top_right,
    doc: "Badge overlay position relative to the button"

  attr :variant, :atom,
    values: [:default, :destructive, :outline, :secondary, :ghost],
    default: :default

  attr :size, :atom,
    values: [:sm, :default, :lg],
    default: :default

  attr :disabled, :boolean, default: false
  attr :loading, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true, doc: "Button content"

  @doc """
  Renders a button with a notification count badge overlaid in a corner.

  Set `count={nil}` or `count={0}` to hide the badge. Values exceeding
  `max_count` are shown as "99+" (or the custom max + "+").

  ## Example

      <.badge_button count={@unread_count}>
        <.icon name="bell" class="h-4 w-4" />
        Notifications
      </.badge_button>

      <.badge_button count={3} badge_color={:primary} variant={:outline}>
        Messages
      </.badge_button>
  """
  def badge_button(assigns) do
    assigns = assign(assigns, :badge_text, format_count(assigns.count, assigns.max_count))

    ~H"""
    <div class="relative inline-flex">
      <button
        type="button"
        class={cn([
          badge_btn_base(),
          badge_variant_class(@variant),
          badge_size_class(@size),
          (@disabled or @loading) && "pointer-events-none opacity-50",
          @class
        ])}
        disabled={@disabled}
        aria-busy={@loading && "true"}
        {@rest}
      >
        <%= if @loading do %>
          <svg
            class="animate-spin h-4 w-4"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            aria-hidden="true"
          >
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
          </svg>
        <% end %>
        <%= render_slot(@inner_block) %>
      </button>

      <%= if @badge_text do %>
        <span
          class={cn([
            "absolute pointer-events-none",
            "flex items-center justify-center min-w-[1.25rem] h-5 rounded-full px-1",
            "text-xs font-bold leading-none",
            badge_position_class(@badge_position),
            badge_color_class(@badge_color)
          ])}
          aria-hidden="true"
        >
          {@badge_text}
        </span>
      <% end %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # confirm_button/1
  # ---------------------------------------------------------------------------

  attr :id, :string,
    required: true,
    doc: "Unique DOM ID — required for the PhiaConfirmButton hook"

  attr :label, :string,
    default: "Delete",
    doc: "Initial button label"

  attr :confirm_label, :string,
    default: "Yes, delete",
    doc: "Label on the Yes button in the confirmation state"

  attr :cancel_label, :string,
    default: "Cancel",
    doc: "Label on the Cancel button"

  attr :on_confirm, :string,
    default: nil,
    doc: "LiveView event name sent on Yes click (phx-click)"

  attr :confirm_value, :string,
    default: nil,
    doc: "phx-value-confirm passed with the on_confirm event"

  attr :variant, :atom,
    values: [:default, :destructive, :outline, :secondary, :ghost],
    default: :destructive,
    doc: "Variant for the initial button"

  attr :confirm_variant, :atom,
    values: [:default, :destructive, :outline, :secondary, :ghost],
    default: :destructive,
    doc: "Variant for the Yes confirmation button"

  attr :size, :atom,
    values: [:sm, :default, :lg],
    default: :default

  attr :timeout, :integer,
    default: 3000,
    doc: "Milliseconds before the confirmation state auto-resets"

  attr :disabled, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global, doc: "HTML attributes forwarded to the root <div>"

  @doc """
  Renders an inline two-step confirmation button.

  On first click, the button transforms inline into "Are you sure?" + Yes +
  Cancel — no popover or modal required. Auto-resets after `timeout` ms.

  `@rest` is forwarded to the wrapper `<div>` — NOT to inner buttons —
  to avoid double-binding `phx-click` or other LiveView bindings.

  ## Example

      <.confirm_button
        id="delete-account"
        label="Delete account"
        on_confirm="delete_account"
        confirm_value={@user_id}
      />
  """
  def confirm_button(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaConfirmButton"
      data-timeout={@timeout}
      class={cn(["inline-block", @class])}
      {@rest}
    >
      <%!-- Initial button — visible by default --%>
      <button
        type="button"
        data-confirm-initial
        class={cn([
          confirm_base(),
          confirm_variant_class(@variant),
          confirm_size_class(@size),
          @disabled && "pointer-events-none opacity-50"
        ])}
        disabled={@disabled}
      >
        {@label}
      </button>

      <%!-- Confirmation state — hidden by default, shown by hook --%>
      <div data-confirm-state class="hidden inline-flex items-center gap-2">
        <span class="text-sm text-foreground whitespace-nowrap">Are you sure?</span>

        <button
          type="button"
          data-confirm-yes
          class={cn([
            confirm_base(),
            confirm_variant_class(@confirm_variant),
            confirm_size_class(@size)
          ])}
          phx-click={@on_confirm}
          phx-value-confirm={@confirm_value}
        >
          {@confirm_label}
        </button>

        <button
          type="button"
          data-confirm-cancel
          class={cn([
            confirm_base(),
            confirm_variant_class(:ghost),
            confirm_size_class(@size)
          ])}
        >
          {@cancel_label}
        </button>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # countdown_button/1
  # ---------------------------------------------------------------------------

  attr :id, :string,
    required: true,
    doc: "Unique DOM ID — required for the PhiaCountdownButton hook"

  attr :seconds, :integer,
    default: 60,
    doc: "Countdown duration in seconds"

  attr :label, :string,
    default: "Resend",
    doc: "Label shown when the countdown ends and button is enabled"

  attr :counting_label, :string,
    default: "Resend in {n}s",
    doc: "Label shown during countdown — the hook replaces {n} with the remaining seconds"

  attr :variant, :atom,
    values: [:default, :destructive, :outline, :secondary, :ghost, :link],
    default: :outline

  attr :size, :atom,
    values: [:xs, :sm, :default, :lg],
    default: :default

  attr :auto_start, :boolean,
    default: true,
    doc: "Start the countdown immediately on mount"

  attr :disabled, :boolean,
    default: false,
    doc: "When true, the hook will not re-enable the button after the countdown ends"

  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders a timer-locked button for OTP resend, rate-limit cooldowns, etc.

  The button is always rendered with `disabled={true}` on the server side.
  The `PhiaCountdownButton` hook removes `disabled` when the timer reaches
  zero. `data-user-disabled` carries the `disabled` attr value so the hook
  knows not to re-enable when the user explicitly disabled the button.

  The `counting_label` string supports a `{n}` placeholder that the hook
  replaces on each tick (e.g. "Resend in {n}s" → "Resend in 42s").

  ## Example

      <.countdown_button id="resend-otp" seconds={60} phx-click="resend_otp" />

      <.countdown_button
        id="retry-btn"
        seconds={30}
        label="Retry"
        counting_label="Please wait {n}s"
        variant={:default}
      />
  """
  def countdown_button(assigns) do
    ~H"""
    <button
      id={@id}
      type="button"
      phx-hook="PhiaCountdownButton"
      data-seconds={@seconds}
      data-label={@label}
      data-counting-label={@counting_label}
      data-auto-start={"#{@auto_start}"}
      data-user-disabled={"#{@disabled}"}
      disabled={true}
      class={cn([
        countdown_base(),
        countdown_variant_class(@variant),
        countdown_size_class(@size),
        "disabled:opacity-50 disabled:pointer-events-none",
        @class
      ])}
      {@rest}
    >
      <span data-countdown-text>{@label}</span>
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers — close_button
  # ---------------------------------------------------------------------------

  defp close_variant_class(:ghost),
    do: "text-muted-foreground hover:bg-accent hover:text-accent-foreground"

  defp close_variant_class(:outline),
    do: "border border-input bg-background text-foreground hover:bg-accent hover:text-accent-foreground"

  defp close_variant_class(:filled),
    do: "bg-muted text-muted-foreground hover:bg-muted/80"

  defp close_size_class(:xs), do: "h-5 w-5"
  defp close_size_class(:sm), do: "h-7 w-7"
  defp close_size_class(:default), do: "h-8 w-8"
  defp close_size_class(:lg), do: "h-10 w-10"

  defp close_shape_class(:square), do: "rounded-md"
  defp close_shape_class(:circle), do: "rounded-full"

  defp close_icon_size(:xs), do: "h-3 w-3"
  defp close_icon_size(:sm), do: "h-3.5 w-3.5"
  defp close_icon_size(:default), do: "h-4 w-4"
  defp close_icon_size(:lg), do: "h-5 w-5"

  # ---------------------------------------------------------------------------
  # Private helpers — badge_button
  # ---------------------------------------------------------------------------

  defp badge_btn_base do
    "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md " <>
      "text-sm font-medium ring-offset-background transition-colors " <>
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
  end

  defp badge_variant_class(:default),
    do: "bg-primary text-primary-foreground shadow hover:bg-primary/90"

  defp badge_variant_class(:destructive),
    do: "bg-destructive text-destructive-foreground shadow-sm hover:bg-destructive/90"

  defp badge_variant_class(:outline),
    do: "border border-input bg-background shadow-sm hover:bg-accent hover:text-accent-foreground"

  defp badge_variant_class(:secondary),
    do: "bg-secondary text-secondary-foreground shadow-sm hover:bg-secondary/80"

  defp badge_variant_class(:ghost),
    do: "hover:bg-accent hover:text-accent-foreground"

  defp badge_size_class(:sm), do: "h-9 px-3"
  defp badge_size_class(:default), do: "h-10 px-4 py-2"
  defp badge_size_class(:lg), do: "h-11 px-8"

  defp badge_position_class(:top_right), do: "-top-1.5 -right-1.5"
  defp badge_position_class(:top_left), do: "-top-1.5 -left-1.5"
  defp badge_position_class(:bottom_right), do: "-bottom-1.5 -right-1.5"
  defp badge_position_class(:bottom_left), do: "-bottom-1.5 -left-1.5"

  defp badge_color_class(:destructive),
    do: "bg-destructive text-destructive-foreground"

  defp badge_color_class(:primary),
    do: "bg-primary text-primary-foreground"

  defp badge_color_class(:warning),
    do: "bg-yellow-500 text-white"

  defp badge_color_class(:success),
    do: "bg-green-500 text-white"

  defp format_count(nil, _), do: nil
  defp format_count(0, _), do: nil

  defp format_count(count, max) when is_integer(count) do
    if count > max, do: "#{max}+", else: "#{count}"
  end

  defp format_count(count, max) do
    case Integer.parse(to_string(count)) do
      {n, _} -> format_count(n, max)
      :error -> nil
    end
  end

  # ---------------------------------------------------------------------------
  # Private helpers — confirm_button
  # ---------------------------------------------------------------------------

  defp confirm_base do
    "inline-flex items-center justify-center whitespace-nowrap rounded-md " <>
      "text-sm font-medium ring-offset-background transition-colors " <>
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
  end

  defp confirm_variant_class(:default),
    do: "bg-primary text-primary-foreground shadow hover:bg-primary/90"

  defp confirm_variant_class(:destructive),
    do: "bg-destructive text-destructive-foreground shadow-sm hover:bg-destructive/90"

  defp confirm_variant_class(:outline),
    do: "border border-input bg-background shadow-sm hover:bg-accent hover:text-accent-foreground"

  defp confirm_variant_class(:secondary),
    do: "bg-secondary text-secondary-foreground shadow-sm hover:bg-secondary/80"

  defp confirm_variant_class(:ghost),
    do: "hover:bg-accent hover:text-accent-foreground"

  defp confirm_size_class(:sm), do: "h-9 px-3"
  defp confirm_size_class(:default), do: "h-10 px-4 py-2"
  defp confirm_size_class(:lg), do: "h-11 px-8"

  # ---------------------------------------------------------------------------
  # Private helpers — countdown_button
  # ---------------------------------------------------------------------------

  defp countdown_base do
    "inline-flex items-center justify-center whitespace-nowrap rounded-md " <>
      "text-sm font-medium ring-offset-background transition-colors " <>
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
  end

  defp countdown_variant_class(:default),
    do: "bg-primary text-primary-foreground shadow hover:bg-primary/90"

  defp countdown_variant_class(:destructive),
    do: "bg-destructive text-destructive-foreground shadow-sm hover:bg-destructive/90"

  defp countdown_variant_class(:outline),
    do: "border border-input bg-background shadow-sm hover:bg-accent hover:text-accent-foreground"

  defp countdown_variant_class(:secondary),
    do: "bg-secondary text-secondary-foreground shadow-sm hover:bg-secondary/80"

  defp countdown_variant_class(:ghost),
    do: "hover:bg-accent hover:text-accent-foreground"

  defp countdown_variant_class(:link),
    do: "text-primary underline-offset-4 hover:underline"

  defp countdown_size_class(:xs), do: "h-7 px-2 text-xs"
  defp countdown_size_class(:sm), do: "h-9 px-3"
  defp countdown_size_class(:default), do: "h-10 px-4 py-2"
  defp countdown_size_class(:lg), do: "h-11 px-8"
end
