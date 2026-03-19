defmodule PhiaUi.Components.Collab.CollabNotification do
  @moduledoc """
  Collaborative notification components for real-time multi-user interfaces.

  Provides an inbox system with notification items, filtered lists, a tabbed
  panel, badge counters, and specialized notification types for mentions and
  thread replies.

  ## Components

  | Component                      | Purpose                                        |
  |--------------------------------|------------------------------------------------|
  | `collab_inbox_notification/1`  | Single inbox notification item                 |
  | `collab_inbox_list/1`          | Scrollable list of notifications               |
  | `collab_inbox_panel/1`         | Full inbox panel with tabs and mark-all-read   |
  | `collab_notification_badge/1`  | Unread count badge (red circle)                |
  | `collab_mention_notification/1`| Specialized @mention notification              |
  | `collab_thread_notification/1` | Specialized thread reply notification          |

  ## Notification map shape

  Components that accept a `:notification` map expect:

      %{
        id: "notif-1",
        type: :mention | :thread_reply | :comment | :edit | :join,
        user_name: "Alice Adams",
        user_color: "#3B82F6",
        user_avatar_url: "/avatars/alice.jpg",  # optional
        message: "mentioned you in Chapter 1",
        preview: "Hey @Bob, check this out...",  # optional
        read: false,
        created_at: ~U[2026-03-19 10:00:00Z],
        thread_id: "thread-1",                    # optional
        comment_id: "comment-1"                   # optional
      }
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Collab.CollabHelpers, only: [format_relative_time: 1, user_initials: 1]

  # ---------------------------------------------------------------------------
  # collab_inbox_notification/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :notification, :map, required: true
  attr :on_click, :string, default: "collab:notification:click"
  attr :on_dismiss, :string, default: "collab:notification:dismiss"
  attr :class, :string, default: nil

  @doc """
  Renders a single inbox notification item.

  Shows an unread indicator dot, type icon, user avatar, message text,
  relative timestamp, and a dismiss button visible on hover.

  ## Example

      <.collab_inbox_notification
        id="notif-1"
        notification={%{id: "1", type: :mention, user_name: "Alice", message: "mentioned you", read: false, created_at: ~U[2026-03-19T10:00:00Z]}}
      />
  """
  def collab_inbox_notification(assigns) do
    notif = assigns.notification
    read = Map.get(notif, :read, false)
    created_at = Map.get(notif, :created_at)
    notif_type = Map.get(notif, :type, :comment)

    assigns =
      assigns
      |> assign(:read, read)
      |> assign(:time_label, format_relative_time(created_at))
      |> assign(:notif_type, notif_type)

    ~H"""
    <div
      id={@id}
      class={cn([
        "group relative flex items-start gap-3 rounded-lg px-3 py-2.5",
        "cursor-pointer transition-colors duration-150",
        if(!@read, do: "bg-accent/50", else: "hover:bg-accent/30"),
        @class
      ])}
      phx-click={@on_click}
      phx-value-id={@notification.id}
      role="article"
      aria-label={"Notification from #{Map.get(@notification, :user_name, "Unknown")}"}
    >
      <span
        :if={!@read}
        class="absolute left-1 top-1/2 -translate-y-1/2 h-2 w-2 rounded-full bg-primary"
        aria-label="Unread"
      />

      <div class="flex-shrink-0 mt-0.5">
        <div class={cn([
          "flex h-8 w-8 items-center justify-center rounded-full text-xs font-medium",
          notification_icon_bg(@notif_type)
        ])}>
          <span :if={Map.get(@notification, :user_avatar_url)} class="h-8 w-8 overflow-hidden rounded-full">
            <img
              src={Map.get(@notification, :user_avatar_url)}
              alt={Map.get(@notification, :user_name, "")}
              class="h-full w-full object-cover"
            />
          </span>
          <span
            :if={!Map.get(@notification, :user_avatar_url)}
            class="flex h-8 w-8 items-center justify-center rounded-full text-white"
            style={"background-color: #{Map.get(@notification, :user_color, "#6B7280")}"}
          >
            {user_initials(Map.get(@notification, :user_name))}
          </span>
        </div>
      </div>

      <div class="flex-1 min-w-0">
        <div class="flex items-start justify-between gap-2">
          <p class={cn(["text-sm leading-snug", if(!@read, do: "font-medium text-foreground", else: "text-muted-foreground")])}>
            <span class="font-semibold">{Map.get(@notification, :user_name, "Unknown")}</span>
            <span class="ml-1">{Map.get(@notification, :message, "")}</span>
          </p>
          <span class="flex-shrink-0 text-xs text-muted-foreground whitespace-nowrap">
            {@time_label}
          </span>
        </div>
        <p
          :if={Map.get(@notification, :preview)}
          class="mt-0.5 truncate text-xs text-muted-foreground"
        >
          {Map.get(@notification, :preview)}
        </p>
      </div>

      <button
        type="button"
        class={cn([
          "flex-shrink-0 mt-0.5 rounded p-1 text-muted-foreground",
          "opacity-0 transition-opacity group-hover:opacity-100",
          "hover:bg-accent hover:text-foreground"
        ])}
        phx-click={@on_dismiss}
        phx-value-id={@notification.id}
        aria-label="Dismiss notification"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
        </svg>
      </button>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # collab_inbox_list/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :notifications, :list, default: []
  attr :on_click, :string, default: "collab:notification:click"
  attr :on_dismiss, :string, default: "collab:notification:dismiss"
  attr :empty_message, :string, default: "No notifications"
  attr :class, :string, default: nil

  @doc """
  Renders a scrollable list of inbox notifications.

  Shows an empty state message when no notifications are present.

  ## Example

      <.collab_inbox_list
        id="inbox-list"
        notifications={@notifications}
      />
  """
  def collab_inbox_list(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn(["flex flex-col overflow-y-auto", @class])}
      role="feed"
      aria-label="Notifications"
    >
      <div
        :if={@notifications == []}
        class="flex flex-col items-center justify-center py-12 text-muted-foreground"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10 mb-3 opacity-40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
          <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" /><path d="M13.73 21a2 2 0 0 1-3.46 0" />
        </svg>
        <p class="text-sm">{@empty_message}</p>
      </div>

      <.collab_inbox_notification
        :for={notif <- @notifications}
        id={"#{@id}-notif-#{Map.get(notif, :id, "")}"}
        notification={notif}
        on_click={@on_click}
        on_dismiss={@on_dismiss}
      />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # collab_inbox_panel/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :notifications, :list, default: []
  attr :active_tab, :atom, default: :all, values: [:all, :mentions, :threads, :unread]
  attr :on_tab_change, :string, default: "collab:notification:tab"
  attr :on_mark_all_read, :string, default: "collab:notification:mark_all_read"
  attr :class, :string, default: nil

  @doc """
  Renders a full inbox panel with header, tab bar, mark-all-read action,
  and a filtered notification list.

  Tabs filter notifications by type: All, Mentions, Threads, Unread.

  ## Example

      <.collab_inbox_panel
        id="inbox-panel"
        notifications={@notifications}
        active_tab={:all}
      />
  """
  def collab_inbox_panel(assigns) do
    filtered = filter_notifications(assigns.notifications, assigns.active_tab)
    unread_count = Enum.count(assigns.notifications, &(!Map.get(&1, :read, false)))

    assigns =
      assigns
      |> assign(:filtered, filtered)
      |> assign(:unread_count, unread_count)

    ~H"""
    <div
      id={@id}
      class={cn([
        "flex flex-col rounded-xl border border-border bg-card shadow-lg",
        "w-full max-w-md",
        @class
      ])}
      role="region"
      aria-label="Notification inbox"
    >
      <div class="flex items-center justify-between border-b border-border px-4 py-3">
        <h2 class="text-base font-semibold text-foreground">Notifications</h2>
        <button
          :if={@unread_count > 0}
          type="button"
          class="text-xs font-medium text-primary hover:text-primary/80 transition-colors"
          phx-click={@on_mark_all_read}
        >
          Mark all as read
        </button>
      </div>

      <div class="flex border-b border-border" role="tablist" aria-label="Filter notifications">
        <button
          :for={tab <- [:all, :mentions, :threads, :unread]}
          type="button"
          role="tab"
          aria-selected={to_string(tab == @active_tab)}
          class={cn([
            "flex-1 px-3 py-2 text-xs font-medium transition-colors",
            "border-b-2 -mb-px",
            if(tab == @active_tab,
              do: "border-primary text-primary",
              else: "border-transparent text-muted-foreground hover:text-foreground"
            )
          ])}
          phx-click={@on_tab_change}
          phx-value-tab={Atom.to_string(tab)}
        >
          {tab_label(tab)}
        </button>
      </div>

      <.collab_inbox_list
        id={"#{@id}-list"}
        notifications={@filtered}
        class="max-h-96"
        empty_message={empty_message_for_tab(@active_tab)}
      />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # collab_notification_badge/1
  # ---------------------------------------------------------------------------

  attr :count, :any, default: 0
  attr :class, :string, default: nil

  @doc """
  Renders an unread count badge as a red circle with the count number.

  Hidden when count is 0 or nil.

  ## Example

      <.collab_notification_badge count={5} />
  """
  def collab_notification_badge(assigns) do
    count = assigns.count || 0
    assigns = assign(assigns, :display_count, count)

    ~H"""
    <span
      :if={@display_count > 0}
      class={cn([
        "inline-flex items-center justify-center rounded-full bg-destructive text-destructive-foreground",
        "text-xs font-bold leading-none",
        if(@display_count < 10, do: "h-5 w-5", else: "h-5 min-w-5 px-1.5"),
        @class
      ])}
      aria-label={"#{@display_count} unread notifications"}
    >
      {if @display_count > 99, do: "99+", else: @display_count}
    </span>
    """
  end

  # ---------------------------------------------------------------------------
  # collab_mention_notification/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :notification, :map, required: true
  attr :on_click, :string, default: "collab:notification:click"
  attr :class, :string, default: nil

  @doc """
  Renders a specialized mention notification.

  Shows an "@" icon with "X mentioned you in Y" message and an optional
  preview of the surrounding text.

  ## Example

      <.collab_mention_notification
        id="mention-1"
        notification={%{id: "1", user_name: "Alice", message: "mentioned you in Chapter 1", preview: "Hey @Bob", read: false, created_at: ~U[2026-03-19T10:00:00Z]}}
      />
  """
  def collab_mention_notification(assigns) do
    notif = assigns.notification
    created_at = Map.get(notif, :created_at)

    assigns =
      assigns
      |> assign(:read, Map.get(notif, :read, false))
      |> assign(:time_label, format_relative_time(created_at))

    ~H"""
    <div
      id={@id}
      class={cn([
        "flex items-start gap-3 rounded-lg px-3 py-2.5 cursor-pointer transition-colors",
        if(!@read, do: "bg-blue-50/50 dark:bg-blue-950/20", else: "hover:bg-accent/30"),
        @class
      ])}
      phx-click={@on_click}
      phx-value-id={@notification.id}
      role="article"
      aria-label={"Mention from #{Map.get(@notification, :user_name, "Unknown")}"}
    >
      <div class="flex-shrink-0 mt-0.5">
        <div class="flex h-8 w-8 items-center justify-center rounded-full bg-blue-100 text-blue-600 dark:bg-blue-900/40 dark:text-blue-400">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="4" /><path d="M16 8v5a3 3 0 0 0 6 0v-1a10 10 0 1 0-4 8" />
          </svg>
        </div>
      </div>

      <div class="flex-1 min-w-0">
        <div class="flex items-start justify-between gap-2">
          <p class={cn(["text-sm leading-snug", if(!@read, do: "font-medium text-foreground", else: "text-muted-foreground")])}>
            <span class="font-semibold">{Map.get(@notification, :user_name, "Unknown")}</span>
            <span class="ml-1">{Map.get(@notification, :message, "mentioned you")}</span>
          </p>
          <span class="flex-shrink-0 text-xs text-muted-foreground whitespace-nowrap">
            {@time_label}
          </span>
        </div>
        <p
          :if={Map.get(@notification, :preview)}
          class="mt-0.5 truncate text-xs text-muted-foreground"
        >
          {Map.get(@notification, :preview)}
        </p>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # collab_thread_notification/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :notification, :map, required: true
  attr :on_click, :string, default: "collab:notification:click"
  attr :class, :string, default: nil

  @doc """
  Renders a specialized thread reply notification.

  Shows a reply icon with "X replied to your thread" message and an optional
  preview of the reply text.

  ## Example

      <.collab_thread_notification
        id="thread-1"
        notification={%{id: "1", user_name: "Bob", message: "replied to your thread", preview: "Great point!", read: false, created_at: ~U[2026-03-19T10:00:00Z]}}
      />
  """
  def collab_thread_notification(assigns) do
    notif = assigns.notification
    created_at = Map.get(notif, :created_at)

    assigns =
      assigns
      |> assign(:read, Map.get(notif, :read, false))
      |> assign(:time_label, format_relative_time(created_at))

    ~H"""
    <div
      id={@id}
      class={cn([
        "flex items-start gap-3 rounded-lg px-3 py-2.5 cursor-pointer transition-colors",
        if(!@read, do: "bg-purple-50/50 dark:bg-purple-950/20", else: "hover:bg-accent/30"),
        @class
      ])}
      phx-click={@on_click}
      phx-value-id={@notification.id}
      role="article"
      aria-label={"Thread reply from #{Map.get(@notification, :user_name, "Unknown")}"}
    >
      <div class="flex-shrink-0 mt-0.5">
        <div class="flex h-8 w-8 items-center justify-center rounded-full bg-purple-100 text-purple-600 dark:bg-purple-900/40 dark:text-purple-400">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="9 17 4 12 9 7" /><path d="M20 18v-2a4 4 0 0 0-4-4H4" />
          </svg>
        </div>
      </div>

      <div class="flex-1 min-w-0">
        <div class="flex items-start justify-between gap-2">
          <p class={cn(["text-sm leading-snug", if(!@read, do: "font-medium text-foreground", else: "text-muted-foreground")])}>
            <span class="font-semibold">{Map.get(@notification, :user_name, "Unknown")}</span>
            <span class="ml-1">{Map.get(@notification, :message, "replied to your thread")}</span>
          </p>
          <span class="flex-shrink-0 text-xs text-muted-foreground whitespace-nowrap">
            {@time_label}
          </span>
        </div>
        <p
          :if={Map.get(@notification, :preview)}
          class="mt-0.5 truncate text-xs text-muted-foreground"
        >
          {Map.get(@notification, :preview)}
        </p>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp notification_icon_bg(:mention), do: "bg-blue-100 dark:bg-blue-900/40"
  defp notification_icon_bg(:thread_reply), do: "bg-purple-100 dark:bg-purple-900/40"
  defp notification_icon_bg(:comment), do: "bg-amber-100 dark:bg-amber-900/40"
  defp notification_icon_bg(:edit), do: "bg-green-100 dark:bg-green-900/40"
  defp notification_icon_bg(:join), do: "bg-cyan-100 dark:bg-cyan-900/40"
  defp notification_icon_bg(_), do: "bg-muted"

  defp filter_notifications(notifications, :all), do: notifications

  defp filter_notifications(notifications, :mentions) do
    Enum.filter(notifications, &(Map.get(&1, :type) == :mention))
  end

  defp filter_notifications(notifications, :threads) do
    Enum.filter(notifications, &(Map.get(&1, :type) == :thread_reply))
  end

  defp filter_notifications(notifications, :unread) do
    Enum.filter(notifications, &(!Map.get(&1, :read, false)))
  end

  defp tab_label(:all), do: "All"
  defp tab_label(:mentions), do: "Mentions"
  defp tab_label(:threads), do: "Threads"
  defp tab_label(:unread), do: "Unread"

  defp empty_message_for_tab(:all), do: "No notifications"
  defp empty_message_for_tab(:mentions), do: "No mentions"
  defp empty_message_for_tab(:threads), do: "No thread replies"
  defp empty_message_for_tab(:unread), do: "All caught up"
end
