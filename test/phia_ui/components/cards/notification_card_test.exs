defmodule PhiaUi.Components.NotificationCardTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.NotificationCard

    attr :title, :string, default: "New message"
    attr :message, :string, default: nil
    attr :timestamp, :string, default: nil
    attr :type, :atom, default: :info
    attr :dismissible, :boolean, default: false
    attr :on_dismiss, :string, default: nil
    attr :read, :boolean, default: false
    attr :class, :string, default: nil

    def render_notification_card(assigns) do
      ~H"""
      <.notification_card
        title={@title}
        message={@message}
        timestamp={@timestamp}
        type={@type}
        dismissible={@dismissible}
        on_dismiss={@on_dismiss}
        read={@read}
        class={@class}
      />
      """
    end

    def render_with_icon(assigns) do
      ~H"""
      <.notification_card title="Custom">
        <:icon>
          <span class="custom-icon">!</span>
        </:icon>
      </.notification_card>
      """
    end

    def render_with_actions(assigns) do
      ~H"""
      <.notification_card title="Action required">
        <:actions>
          <button class="action-btn">View details</button>
        </:actions>
      </.notification_card>
      """
    end
  end

  defp render_notification_card(attrs \\ %{}) do
    render_component(&H.render_notification_card/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # Basic rendering
  # ---------------------------------------------------------------------------

  describe "notification_card/1 basic rendering" do
    test "renders without errors" do
      html = render_notification_card()
      assert html =~ "<div"
    end

    test "renders title" do
      html = render_notification_card(%{title: "System update available"})
      assert html =~ "System update available"
    end

    test "title has font-semibold text-sm styling" do
      html = render_notification_card(%{title: "Alert"})
      assert html =~ "font-semibold"
      assert html =~ "text-sm"
    end

    test "renders message when provided" do
      html = render_notification_card(%{message: "Please restart your app"})
      assert html =~ "Please restart your app"
    end

    test "message has text-muted-foreground styling" do
      html = render_notification_card(%{message: "Details here"})
      assert html =~ "text-muted-foreground"
    end

    test "does not render message element when nil" do
      html = render_notification_card(%{message: nil})
      refute html =~ "Please restart"
    end

    test "renders timestamp when provided" do
      html = render_notification_card(%{timestamp: "3 min ago"})
      assert html =~ "3 min ago"
    end

    test "does not render timestamp when nil" do
      html = render_notification_card(%{timestamp: nil})
      refute html =~ "min ago"
    end
  end

  # ---------------------------------------------------------------------------
  # Type — border colors
  # ---------------------------------------------------------------------------

  describe "notification_card/1 type :info" do
    test "applies border-l-blue-500" do
      html = render_notification_card(%{type: :info})
      assert html =~ "border-l-blue-500"
    end

    test "shows information-circle icon" do
      html = render_notification_card(%{type: :info})
      assert html =~ "icon-information-circle"
    end

    test "icon has text-blue-500 class" do
      html = render_notification_card(%{type: :info})
      assert html =~ "text-blue-500"
    end
  end

  describe "notification_card/1 type :success" do
    test "applies border-l-emerald-500" do
      html = render_notification_card(%{type: :success})
      assert html =~ "border-l-emerald-500"
    end

    test "shows check-circle icon" do
      html = render_notification_card(%{type: :success})
      assert html =~ "icon-check-circle"
    end

    test "icon has text-emerald-500 class" do
      html = render_notification_card(%{type: :success})
      assert html =~ "text-emerald-500"
    end
  end

  describe "notification_card/1 type :warning" do
    test "applies border-l-amber-500" do
      html = render_notification_card(%{type: :warning})
      assert html =~ "border-l-amber-500"
    end

    test "shows exclamation-triangle icon" do
      html = render_notification_card(%{type: :warning})
      assert html =~ "icon-exclamation-triangle"
    end

    test "icon has text-amber-500 class" do
      html = render_notification_card(%{type: :warning})
      assert html =~ "text-amber-500"
    end
  end

  describe "notification_card/1 type :error" do
    test "applies border-l-red-500" do
      html = render_notification_card(%{type: :error})
      assert html =~ "border-l-red-500"
    end

    test "shows x-circle icon" do
      html = render_notification_card(%{type: :error})
      assert html =~ "icon-x-circle"
    end

    test "icon has text-red-500 class" do
      html = render_notification_card(%{type: :error})
      assert html =~ "text-red-500"
    end
  end

  # ---------------------------------------------------------------------------
  # Read state
  # ---------------------------------------------------------------------------

  describe "notification_card/1 read state" do
    test "applies opacity-60 when read=true" do
      html = render_notification_card(%{read: true})
      assert html =~ "opacity-60"
    end

    test "does not apply opacity-60 when read=false" do
      html = render_notification_card(%{read: false})
      refute html =~ "opacity-60"
    end
  end

  # ---------------------------------------------------------------------------
  # Dismiss button
  # ---------------------------------------------------------------------------

  describe "notification_card/1 dismissible" do
    test "renders dismiss button when dismissible=true" do
      html = render_notification_card(%{dismissible: true})
      assert html =~ "Dismiss notification"
    end

    test "dismiss button has phx-click event" do
      html = render_notification_card(%{dismissible: true, on_dismiss: "dismiss_notification"})
      assert html =~ ~s(phx-click="dismiss_notification")
    end

    test "does not render dismiss button when dismissible=false" do
      html = render_notification_card(%{dismissible: false})
      refute html =~ "Dismiss notification"
    end
  end

  # ---------------------------------------------------------------------------
  # Slots
  # ---------------------------------------------------------------------------

  describe "notification_card/1 :icon slot" do
    test "renders custom icon slot" do
      html = render_component(&H.render_with_icon/1, %{})
      assert html =~ "custom-icon"
      assert html =~ "!"
    end
  end

  describe "notification_card/1 :actions slot" do
    test "renders actions slot content" do
      html = render_component(&H.render_with_actions/1, %{})
      assert html =~ "View details"
      assert html =~ "action-btn"
    end
  end

  # ---------------------------------------------------------------------------
  # Class forwarding
  # ---------------------------------------------------------------------------

  describe "notification_card/1 class forwarding" do
    test "accepts custom class" do
      html = render_notification_card(%{class: "my-notification"})
      assert html =~ "my-notification"
    end
  end
end
