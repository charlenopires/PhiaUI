defmodule PhiaUi.Components.NotificationTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Notification

    def render_notification(assigns) do
      ~H"""
      <.notification id="notif-1" title="Test notification" variant={:default} />
      """
    end

    def render_with_description(assigns) do
      ~H"""
      <.notification id="notif-2" title="Hello" description="Supporting text here." />
      """
    end

    def render_with_timestamp(assigns) do
      ~H"""
      <.notification id="notif-3" title="Hello" timestamp="5 min ago" />
      """
    end

    def render_success(assigns) do
      ~H"""
      <.notification id="notif-success" title="Done" variant={:success} />
      """
    end

    def render_destructive(assigns) do
      ~H"""
      <.notification id="notif-err" title="Error" variant={:destructive} />
      """
    end

    def render_warning(assigns) do
      ~H"""
      <.notification id="notif-warn" title="Warning" variant={:warning} />
      """
    end

    def render_info(assigns) do
      ~H"""
      <.notification id="notif-info" title="Info" variant={:info} />
      """
    end

    def render_not_closeable(assigns) do
      ~H"""
      <.notification id="notif-nc" title="Persistent" closeable={false} />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.notification id="notif-cls" title="Test" class="my-notif-class" />
      """
    end

    def render_with_rest(assigns) do
      ~H"""
      <.notification id="notif-rest" title="Test" data-testid="notif-widget" />
      """
    end

    def render_item(assigns) do
      ~H"""
      <.notification_item title="Alice mentioned you" description="@you in #general" timestamp="3m" />
      """
    end

    def render_item_unread(assigns) do
      ~H"""
      <.notification_item title="Unread notification" read={false} />
      """
    end

    def render_item_read(assigns) do
      ~H"""
      <.notification_item title="Read notification" read={true} />
      """
    end

    def render_center(assigns) do
      ~H"""
      <.notification_center>
        <.notification_item title="First" />
        <.notification_item title="Second" />
      </.notification_center>
      """
    end

    def render_center_empty(assigns) do
      ~H"""
      <.notification_center />
      """
    end

    def render_badge(assigns) do
      ~H"""
      <.notification_badge count={5}>
        <button>Bell</button>
      </.notification_badge>
      """
    end

    def render_badge_zero(assigns) do
      ~H"""
      <.notification_badge count={0}>
        <button>Bell</button>
      </.notification_badge>
      """
    end

    def render_badge_overflow(assigns) do
      ~H"""
      <.notification_badge count={150} max={99}>
        <button>Bell</button>
      </.notification_badge>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # notification/1
  # ---------------------------------------------------------------------------

  describe "notification/1 base" do
    test "renders with role=alert" do
      html = render_component(&H.render_notification/1, %{})
      assert html =~ ~s(role="alert")
    end

    test "renders title" do
      html = render_component(&H.render_notification/1, %{})
      assert html =~ "Test notification"
    end

    test "renders dismiss button by default" do
      html = render_component(&H.render_notification/1, %{})
      assert html =~ "Dismiss notification"
    end

    test "does not render dismiss when closeable=false" do
      html = render_component(&H.render_not_closeable/1, %{})
      refute html =~ "Dismiss notification"
    end

    test "renders description when provided" do
      html = render_component(&H.render_with_description/1, %{})
      assert html =~ "Supporting text here."
    end

    test "renders timestamp when provided" do
      html = render_component(&H.render_with_timestamp/1, %{})
      assert html =~ "5 min ago"
    end

    test "accepts :class override" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "my-notif-class"
    end

    test "passes :rest attrs" do
      html = render_component(&H.render_with_rest/1, %{})
      assert html =~ ~s(data-testid="notif-widget")
    end
  end

  describe "notification/1 variants" do
    test ":success renders success border" do
      html = render_component(&H.render_success/1, %{})
      assert html =~ "border-success"
    end

    test ":destructive renders destructive border" do
      html = render_component(&H.render_destructive/1, %{})
      assert html =~ "border-destructive"
    end

    test ":warning renders warning border" do
      html = render_component(&H.render_warning/1, %{})
      assert html =~ "border-warning"
    end

    test ":info renders blue border" do
      html = render_component(&H.render_info/1, %{})
      assert html =~ "border-blue-500"
    end
  end

  # ---------------------------------------------------------------------------
  # notification_item/1
  # ---------------------------------------------------------------------------

  describe "notification_item/1" do
    test "renders title" do
      html = render_component(&H.render_item/1, %{})
      assert html =~ "Alice mentioned you"
    end

    test "renders description" do
      html = render_component(&H.render_item/1, %{})
      assert html =~ "@you in #general"
    end

    test "renders timestamp" do
      html = render_component(&H.render_item/1, %{})
      assert html =~ "3m"
    end

    test "unread item has unread indicator" do
      html = render_component(&H.render_item_unread/1, %{})
      assert html =~ "bg-primary"
    end

    test "read item has no unread indicator" do
      html = render_component(&H.render_item_read/1, %{})
      refute html =~ ~s(aria-label="Unread")
    end

    test "unread item has font-medium title" do
      html = render_component(&H.render_item_unread/1, %{})
      assert html =~ "font-medium"
    end
  end

  # ---------------------------------------------------------------------------
  # notification_center/1
  # ---------------------------------------------------------------------------

  describe "notification_center/1" do
    test "renders Notifications heading by default" do
      html = render_component(&H.render_center/1, %{})
      assert html =~ "Notifications"
    end

    test "renders notification items" do
      html = render_component(&H.render_center/1, %{})
      assert html =~ "First"
      assert html =~ "Second"
    end

    test "renders empty state when no items" do
      html = render_component(&H.render_center_empty/1, %{})
      assert html =~ "No notifications yet"
    end

    test "renders region role" do
      html = render_component(&H.render_center/1, %{})
      assert html =~ ~s(role="region")
    end
  end

  # ---------------------------------------------------------------------------
  # notification_badge/1
  # ---------------------------------------------------------------------------

  describe "notification_badge/1" do
    test "renders count when > 0" do
      html = render_component(&H.render_badge/1, %{})
      assert html =~ "5 unread notifications"
    end

    test "does not render badge when count=0" do
      html = render_component(&H.render_badge_zero/1, %{})
      refute html =~ "unread notifications"
    end

    test "renders N+ when count exceeds max" do
      html = render_component(&H.render_badge_overflow/1, %{})
      assert html =~ "99+"
    end

    test "renders inner block content" do
      html = render_component(&H.render_badge/1, %{})
      assert html =~ "Bell"
    end

    test "badge has aria-label with count" do
      html = render_component(&H.render_badge/1, %{})
      assert html =~ "5 unread notifications"
    end
  end
end
