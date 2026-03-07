defmodule PhiaUi.Components.ActionButtonTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ActionButton

    # close_button helpers
    def render_close_default(assigns) do
      ~H"""
      <.close_button />
      """
    end

    def render_close_size(assigns) do
      ~H"""
      <.close_button size={@size} />
      """
    end

    def render_close_variant(assigns) do
      ~H"""
      <.close_button variant={@variant} />
      """
    end

    def render_close_circle(assigns) do
      ~H"""
      <.close_button shape={:circle} />
      """
    end

    def render_close_custom_label(assigns) do
      ~H"""
      <.close_button label="Dismiss notification" />
      """
    end

    def render_close_disabled(assigns) do
      ~H"""
      <.close_button disabled={true} />
      """
    end

    # badge_button helpers
    def render_badge_default(assigns) do
      ~H"""
      <.badge_button count={@count} variant={:default} size={:default} badge_color={:destructive} badge_position={:top_right} max_count={99} disabled={false} loading={false} class={nil}>
        Notifications
      </.badge_button>
      """
    end

    def render_badge_zero(assigns) do
      ~H"""
      <.badge_button count={0} variant={:default} size={:default} badge_color={:destructive} badge_position={:top_right} max_count={99} disabled={false} loading={false} class={nil}>
        Notifications
      </.badge_button>
      """
    end

    def render_badge_nil(assigns) do
      ~H"""
      <.badge_button count={nil} variant={:default} size={:default} badge_color={:destructive} badge_position={:top_right} max_count={99} disabled={false} loading={false} class={nil}>
        Notifications
      </.badge_button>
      """
    end

    def render_badge_overflow(assigns) do
      ~H"""
      <.badge_button count={150} variant={:default} size={:default} badge_color={:destructive} badge_position={:top_right} max_count={99} disabled={false} loading={false} class={nil}>
        Messages
      </.badge_button>
      """
    end

    def render_badge_loading(assigns) do
      ~H"""
      <.badge_button count={3} variant={:default} size={:default} badge_color={:destructive} badge_position={:top_right} max_count={99} disabled={false} loading={true} class={nil}>
        Loading
      </.badge_button>
      """
    end

    # confirm_button helpers
    def render_confirm_default(assigns) do
      ~H"""
      <.confirm_button id="confirm-1" label="Delete" confirm_label="Yes, delete" cancel_label="Cancel" on_confirm={nil} confirm_value={nil} variant={:destructive} confirm_variant={:destructive} size={:default} timeout={3000} disabled={false} class={nil} />
      """
    end

    def render_confirm_with_event(assigns) do
      ~H"""
      <.confirm_button id="confirm-2" label="Remove" confirm_label="Yes, remove" cancel_label="Cancel" on_confirm="remove_item" confirm_value="42" variant={:destructive} confirm_variant={:destructive} size={:default} timeout={3000} disabled={false} class={nil} />
      """
    end

    # countdown_button helpers
    def render_countdown_default(assigns) do
      ~H"""
      <.countdown_button id="countdown-1" seconds={60} label="Resend" counting_label="Resend in {n}s" variant={:outline} size={:default} auto_start={true} disabled={false} class={nil} />
      """
    end

    def render_countdown_custom(assigns) do
      ~H"""
      <.countdown_button id="countdown-2" seconds={30} label="Retry" counting_label="Wait {n}s" variant={:default} size={:sm} auto_start={false} disabled={false} class={nil} />
      """
    end
  end

  defp render_close_default, do: render_component(&H.render_close_default/1, %{})
  defp render_close_size(s), do: render_component(&H.render_close_size/1, %{size: s})
  defp render_close_variant(v), do: render_component(&H.render_close_variant/1, %{variant: v})
  defp render_close_circle, do: render_component(&H.render_close_circle/1, %{})
  defp render_close_custom_label, do: render_component(&H.render_close_custom_label/1, %{})
  defp render_close_disabled, do: render_component(&H.render_close_disabled/1, %{})
  defp render_badge(count), do: render_component(&H.render_badge_default/1, %{count: count})
  defp render_badge_zero, do: render_component(&H.render_badge_zero/1, %{})
  defp render_badge_nil, do: render_component(&H.render_badge_nil/1, %{})
  defp render_badge_overflow, do: render_component(&H.render_badge_overflow/1, %{})
  defp render_badge_loading, do: render_component(&H.render_badge_loading/1, %{})
  defp render_confirm_default, do: render_component(&H.render_confirm_default/1, %{})
  defp render_confirm_with_event, do: render_component(&H.render_confirm_with_event/1, %{})
  defp render_countdown_default, do: render_component(&H.render_countdown_default/1, %{})
  defp render_countdown_custom, do: render_component(&H.render_countdown_custom/1, %{})

  # ---------------------------------------------------------------------------
  # close_button/1
  # ---------------------------------------------------------------------------

  describe "close_button/1" do
    test "renders button element" do
      assert render_close_default() =~ "<button"
    end

    test "default aria-label is Close" do
      assert render_close_default() =~ ~s(aria-label="Close")
    end

    test "custom aria-label used" do
      assert render_close_custom_label() =~ ~s(aria-label="Dismiss notification")
    end

    test "renders inline X SVG path" do
      assert render_close_default() =~ ~s(d="M6 6L18 18M18 6L6 18")
    end

    test "does not render .icon component" do
      refute render_close_default() =~ "phx-hook"
    end

    test "xs size applies h-5 w-5" do
      assert render_close_size(:xs) =~ "h-5 w-5"
    end

    test "sm size applies h-7 w-7" do
      assert render_close_size(:sm) =~ "h-7 w-7"
    end

    test "default size applies h-8 w-8" do
      assert render_close_default() =~ "h-8 w-8"
    end

    test "lg size applies h-10 w-10" do
      assert render_close_size(:lg) =~ "h-10 w-10"
    end

    test "ghost variant (default) has hover:bg-accent" do
      assert render_close_default() =~ "hover:bg-accent"
    end

    test "outline variant has border" do
      assert render_close_variant(:outline) =~ "border"
    end

    test "filled variant has bg-muted" do
      assert render_close_variant(:filled) =~ "bg-muted"
    end

    test "circle shape applies rounded-full" do
      assert render_close_circle() =~ "rounded-full"
    end

    test "disabled adds opacity-50" do
      assert render_close_disabled() =~ "opacity-50"
    end

    test "function is exported" do
      assert function_exported?(PhiaUi.Components.ActionButton, :close_button, 1)
    end
  end

  # ---------------------------------------------------------------------------
  # badge_button/1
  # ---------------------------------------------------------------------------

  describe "badge_button/1" do
    test "renders button element" do
      assert render_badge(3) =~ "<button"
    end

    test "renders content" do
      assert render_badge(3) =~ "Notifications"
    end

    test "renders badge when count > 0" do
      assert render_badge(3) =~ "3"
    end

    test "badge is in a <span>" do
      html = render_badge(5)
      assert html =~ "<span"
      assert html =~ "5"
    end

    test "hides badge when count is nil" do
      refute render_badge_nil() =~ "min-w-"
    end

    test "hides badge when count is 0" do
      html = render_badge_zero()
      # badge_text is nil so badge span is not rendered at all
      refute html =~ "min-w-[1.25rem]"
    end

    test "shows max+ when count exceeds max_count" do
      assert render_badge_overflow() =~ "99+"
    end

    test "loading shows spinner" do
      assert render_badge_loading() =~ "animate-spin"
    end

    test "wrapper has relative positioning" do
      assert render_badge(3) =~ "relative"
    end

    test "function is exported" do
      assert function_exported?(PhiaUi.Components.ActionButton, :badge_button, 1)
    end
  end

  # ---------------------------------------------------------------------------
  # confirm_button/1
  # ---------------------------------------------------------------------------

  describe "confirm_button/1" do
    test "renders wrapper div with id" do
      assert render_confirm_default() =~ ~s(id="confirm-1")
    end

    test "has phx-hook=\"PhiaConfirmButton\"" do
      assert render_confirm_default() =~ ~s(phx-hook="PhiaConfirmButton")
    end

    test "has data-timeout" do
      assert render_confirm_default() =~ ~s(data-timeout="3000")
    end

    test "initial button has data-confirm-initial" do
      assert render_confirm_default() =~ "data-confirm-initial"
    end

    test "initial button renders label" do
      assert render_confirm_default() =~ "Delete"
    end

    test "confirm state has data-confirm-state" do
      assert render_confirm_default() =~ "data-confirm-state"
    end

    test "confirm state is hidden by default" do
      assert render_confirm_default() =~ ~r/data-confirm-state[^>]*class="hidden/
    end

    test "confirm state shows 'Are you sure?' text" do
      assert render_confirm_default() =~ "Are you sure?"
    end

    test "yes button has data-confirm-yes" do
      assert render_confirm_default() =~ "data-confirm-yes"
    end

    test "yes button renders confirm_label" do
      assert render_confirm_default() =~ "Yes, delete"
    end

    test "cancel button has data-confirm-cancel" do
      assert render_confirm_default() =~ "data-confirm-cancel"
    end

    test "cancel button renders cancel_label" do
      assert render_confirm_default() =~ "Cancel"
    end

    test "yes button has phx-click with on_confirm event" do
      assert render_confirm_with_event() =~ ~s(phx-click="remove_item")
    end

    test "yes button has phx-value-confirm" do
      assert render_confirm_with_event() =~ ~s(phx-value-confirm="42")
    end

    test "function is exported" do
      assert function_exported?(PhiaUi.Components.ActionButton, :confirm_button, 1)
    end
  end

  # ---------------------------------------------------------------------------
  # countdown_button/1
  # ---------------------------------------------------------------------------

  describe "countdown_button/1" do
    test "renders button element" do
      assert render_countdown_default() =~ "<button"
    end

    test "has phx-hook=\"PhiaCountdownButton\"" do
      assert render_countdown_default() =~ ~s(phx-hook="PhiaCountdownButton")
    end

    test "has correct id" do
      assert render_countdown_default() =~ ~s(id="countdown-1")
    end

    test "has data-seconds" do
      assert render_countdown_default() =~ ~s(data-seconds="60")
    end

    test "has data-label" do
      assert render_countdown_default() =~ ~s(data-label="Resend")
    end

    test "has data-counting-label" do
      assert render_countdown_default() =~ "data-counting-label"
    end

    test "has data-auto-start" do
      assert render_countdown_default() =~ "data-auto-start"
    end

    test "is always disabled initially" do
      assert render_countdown_default() =~ "disabled"
    end

    test "has disabled:opacity-50 class" do
      assert render_countdown_default() =~ "disabled:opacity-50"
    end

    test "has data-countdown-text span" do
      assert render_countdown_default() =~ "data-countdown-text"
    end

    test "span renders the label" do
      assert render_countdown_default() =~ "Resend"
    end

    test "custom seconds reflected in data-seconds" do
      assert render_countdown_custom() =~ ~s(data-seconds="30")
    end

    test "auto_start=false reflected in data-auto-start" do
      assert render_countdown_custom() =~ ~s(data-auto-start="false")
    end

    test "function is exported" do
      assert function_exported?(PhiaUi.Components.ActionButton, :countdown_button, 1)
    end
  end
end
