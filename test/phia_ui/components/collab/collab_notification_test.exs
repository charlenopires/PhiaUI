defmodule PhiaUi.Components.Collab.CollabNotificationTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ── Test Helper Module ──────────────────────────────────────────────────

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Collab.CollabNotification

    # -- collab_inbox_notification --

    def render_inbox_notification(assigns) do
      ~H"<.collab_inbox_notification id={@id} notification={@notification} />"
    end

    def render_inbox_notification_custom(assigns) do
      ~H"<.collab_inbox_notification id={@id} notification={@notification} on_click={@on_click} on_dismiss={@on_dismiss} class={@class} />"
    end

    # -- collab_inbox_list --

    def render_inbox_list(assigns) do
      ~H"<.collab_inbox_list id={@id} notifications={@notifications} />"
    end

    def render_inbox_list_empty(assigns) do
      ~H"<.collab_inbox_list id={@id} notifications={[]} empty_message={@empty_message} />"
    end

    # -- collab_inbox_panel --

    def render_inbox_panel(assigns) do
      ~H"<.collab_inbox_panel id={@id} notifications={@notifications} />"
    end

    def render_inbox_panel_tab(assigns) do
      ~H"<.collab_inbox_panel id={@id} notifications={@notifications} active_tab={@active_tab} />"
    end

    # -- collab_notification_badge --

    def render_badge(assigns) do
      ~H"<.collab_notification_badge count={@count} />"
    end

    def render_badge_zero(assigns) do
      assigns = Phoenix.Component.assign(assigns, :count, 0)
      ~H"<.collab_notification_badge count={@count} />"
    end

    # -- collab_mention_notification --

    def render_mention(assigns) do
      ~H"<.collab_mention_notification id={@id} notification={@notification} />"
    end

    # -- collab_thread_notification --

    def render_thread(assigns) do
      ~H"<.collab_thread_notification id={@id} notification={@notification} />"
    end
  end

  # ── Test Data ──────────────────────────────────────────────────────────

  @unread_notification %{
    id: "n-1",
    type: :mention,
    user_name: "Alice Adams",
    user_color: "#3B82F6",
    user_avatar_url: nil,
    message: "mentioned you in Chapter 1",
    preview: "Hey check this out",
    read: false,
    created_at: ~U[2026-03-19 10:00:00Z],
    thread_id: nil,
    comment_id: nil
  }

  @read_notification %{
    id: "n-2",
    type: :comment,
    user_name: "Bob Baker",
    user_color: "#10B981",
    user_avatar_url: "/avatars/bob.jpg",
    message: "commented on your document",
    preview: nil,
    read: true,
    created_at: ~U[2026-03-18 09:00:00Z],
    thread_id: nil,
    comment_id: "c-1"
  }

  @thread_notification %{
    id: "n-3",
    type: :thread_reply,
    user_name: "Carol Chen",
    user_color: "#8B5CF6",
    user_avatar_url: nil,
    message: "replied to your thread",
    preview: "Great point!",
    read: false,
    created_at: ~U[2026-03-19 11:00:00Z],
    thread_id: "t-1",
    comment_id: nil
  }

  # ── collab_inbox_notification/1 ────────────────────────────────────────

  describe "collab_inbox_notification/1" do
    test "renders unread notification with dot and user info" do
      html = render_component(&H.render_inbox_notification/1, %{
        id: "test-notif",
        notification: @unread_notification
      })

      assert html =~ "test-notif"
      assert html =~ "Alice Adams"
      assert html =~ "mentioned you in Chapter 1"
      assert html =~ "Unread"
      assert html =~ "Hey check this out"
    end

    test "renders read notification without unread dot" do
      html = render_component(&H.render_inbox_notification/1, %{
        id: "test-notif-read",
        notification: @read_notification
      })

      assert html =~ "Bob Baker"
      assert html =~ "commented on your document"
      refute html =~ "Unread"
    end

    test "renders user avatar when provided" do
      html = render_component(&H.render_inbox_notification/1, %{
        id: "test-notif-avatar",
        notification: @read_notification
      })

      assert html =~ "/avatars/bob.jpg"
    end

    test "renders user initials when no avatar" do
      html = render_component(&H.render_inbox_notification/1, %{
        id: "test-notif-initials",
        notification: @unread_notification
      })

      assert html =~ "AA"
    end

    test "supports custom event names and class" do
      html = render_component(&H.render_inbox_notification_custom/1, %{
        id: "test-custom",
        notification: @unread_notification,
        on_click: "my:click",
        on_dismiss: "my:dismiss",
        class: "custom-class"
      })

      assert html =~ "my:click"
      assert html =~ "my:dismiss"
      assert html =~ "custom-class"
    end

    test "renders dismiss button" do
      html = render_component(&H.render_inbox_notification/1, %{
        id: "test-dismiss",
        notification: @unread_notification
      })

      assert html =~ "Dismiss notification"
    end
  end

  # ── collab_inbox_list/1 ────────────────────────────────────────────────

  describe "collab_inbox_list/1" do
    test "renders list of notifications" do
      html = render_component(&H.render_inbox_list/1, %{
        id: "test-list",
        notifications: [@unread_notification, @read_notification]
      })

      assert html =~ "Alice Adams"
      assert html =~ "Bob Baker"
      assert html =~ "feed"
    end

    test "renders empty state" do
      html = render_component(&H.render_inbox_list_empty/1, %{
        id: "test-list-empty",
        empty_message: "Nothing here"
      })

      assert html =~ "Nothing here"
    end

    test "renders default empty message" do
      html = render_component(&H.render_inbox_list/1, %{
        id: "test-list-default-empty",
        notifications: []
      })

      assert html =~ "No notifications"
    end
  end

  # ── collab_inbox_panel/1 ───────────────────────────────────────────────

  describe "collab_inbox_panel/1" do
    test "renders panel with header and tabs" do
      html = render_component(&H.render_inbox_panel/1, %{
        id: "test-panel",
        notifications: [@unread_notification, @read_notification, @thread_notification]
      })

      assert html =~ "Notifications"
      assert html =~ "All"
      assert html =~ "Mentions"
      assert html =~ "Threads"
      assert html =~ "Unread"
      assert html =~ "Mark all as read"
    end

    test "renders all notifications in all tab" do
      html = render_component(&H.render_inbox_panel/1, %{
        id: "test-panel-all",
        notifications: [@unread_notification, @read_notification]
      })

      assert html =~ "Alice Adams"
      assert html =~ "Bob Baker"
    end

    test "filters mentions tab" do
      html = render_component(&H.render_inbox_panel_tab/1, %{
        id: "test-panel-mentions",
        notifications: [@unread_notification, @read_notification],
        active_tab: :mentions
      })

      assert html =~ "Alice Adams"
      refute html =~ "Bob Baker"
    end

    test "filters threads tab" do
      html = render_component(&H.render_inbox_panel_tab/1, %{
        id: "test-panel-threads",
        notifications: [@unread_notification, @thread_notification],
        active_tab: :threads
      })

      assert html =~ "Carol Chen"
      refute html =~ "Alice Adams"
    end

    test "filters unread tab" do
      html = render_component(&H.render_inbox_panel_tab/1, %{
        id: "test-panel-unread",
        notifications: [@unread_notification, @read_notification],
        active_tab: :unread
      })

      assert html =~ "Alice Adams"
      refute html =~ "Bob Baker"
    end

    test "hides mark-all-read when all are read" do
      all_read = [%{@read_notification | id: "r-1"}, %{@read_notification | id: "r-2"}]

      html = render_component(&H.render_inbox_panel/1, %{
        id: "test-panel-no-unread",
        notifications: all_read
      })

      refute html =~ "Mark all as read"
    end
  end

  # ── collab_notification_badge/1 ────────────────────────────────────────

  describe "collab_notification_badge/1" do
    test "renders badge with count" do
      html = render_component(&H.render_badge/1, %{count: 5})
      assert html =~ "5"
      assert html =~ "5 unread notifications"
    end

    test "hidden when count is 0" do
      html = render_component(&H.render_badge_zero/1, %{})
      refute html =~ "unread notifications"
    end

    test "shows 99+ for large counts" do
      html = render_component(&H.render_badge/1, %{count: 150})
      assert html =~ "99+"
    end
  end

  # ── collab_mention_notification/1 ──────────────────────────────────────

  describe "collab_mention_notification/1" do
    test "renders mention with at-sign icon and message" do
      html = render_component(&H.render_mention/1, %{
        id: "mention-test",
        notification: @unread_notification
      })

      assert html =~ "Alice Adams"
      assert html =~ "mentioned you in Chapter 1"
      assert html =~ "Hey check this out"
      assert html =~ "circle"
    end

    test "renders read mention with muted styling" do
      read_mention = %{@unread_notification | read: true}

      html = render_component(&H.render_mention/1, %{
        id: "mention-read",
        notification: read_mention
      })

      assert html =~ "Alice Adams"
      assert html =~ "text-muted-foreground"
    end
  end

  # ── collab_thread_notification/1 ───────────────────────────────────────

  describe "collab_thread_notification/1" do
    test "renders thread reply with reply icon and message" do
      html = render_component(&H.render_thread/1, %{
        id: "thread-test",
        notification: @thread_notification
      })

      assert html =~ "Carol Chen"
      assert html =~ "replied to your thread"
      assert html =~ "Great point!"
      assert html =~ "polyline"
    end

    test "renders read thread reply with muted styling" do
      read_thread = %{@thread_notification | read: true}

      html = render_component(&H.render_thread/1, %{
        id: "thread-read",
        notification: read_thread
      })

      assert html =~ "Carol Chen"
      assert html =~ "text-muted-foreground"
    end
  end
end
