defmodule PhiaUi.Components.Collab.Presence do
  @moduledoc """
  Collaborative presence components for real-time multi-user interfaces.

  Provides avatar stacks, typing indicators, status bars, and user lists
  designed for collaborative editing, whiteboarding, and shared workspace
  applications. All components are pure function components with no JS hooks
  required — state is managed server-side via Phoenix Presence or similar.

  ## Components

  | Component              | Purpose                                               |
  |------------------------|-------------------------------------------------------|
  | `collab_avatar_stack/1`| Overlapping avatar circles with status dots + tooltips |
  | `who_is_typing/1`      | Animated "X is typing..." indicator                   |
  | `collab_status_bar/1`  | Combined bar: connection + avatars + typing + extras   |
  | `collab_user_list/1`   | Full vertical user panel with roles and status         |

  ## User map shape

  Components that accept a `:users` list expect maps with these keys:

      %{
        id: "user-1",
        name: "Alice Adams",
        color: "#3B82F6",
        avatar_url: "/avatars/alice.jpg",  # optional
        status: :online,                    # :online | :idle | :offline
        role: "Editor",                     # optional, for collab_user_list
        idle_since: ~U[2026-03-19 10:00:00Z] # optional
      }
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # collab_avatar_stack/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :users, :list, default: []
  attr :max_visible, :integer, default: 5
  attr :size, :atom, default: :md, values: [:sm, :md, :lg]
  attr :show_tooltip, :boolean, default: true
  attr :class, :string, default: nil
  attr :rest, :global

  @doc """
  Renders an overlapping stack of user avatars with status dots and tooltips.

  Users beyond `max_visible` are collapsed into a "+N more" overflow badge.
  Each avatar shows a colored status dot (green = online, amber = idle,
  gray = offline).

  ## Example

      <.collab_avatar_stack
        id="editor-presence"
        users={@online_users}
        max_visible={4}
        size={:md}
      />
  """
  def collab_avatar_stack(assigns) do
    visible = Enum.take(assigns.users, assigns.max_visible)
    overflow = max(length(assigns.users) - assigns.max_visible, 0)

    assigns =
      assigns
      |> assign(:visible, visible)
      |> assign(:overflow, overflow)

    ~H"""
    <div
      id={@id}
      role="group"
      aria-label="Online users"
      class={cn(["flex items-center -space-x-2", @class])}
      {@rest}
    >
      <div
        :for={user <- @visible}
        class="relative group"
      >
        <div class={cn([
          "relative flex shrink-0 items-center justify-center rounded-full",
          "ring-2 ring-background transition-transform duration-150",
          "hover:z-10 hover:scale-110",
          avatar_size_class(@size)
        ])}>
          <img
            :if={Map.get(user, :avatar_url)}
            src={Map.get(user, :avatar_url)}
            alt={Map.get(user, :name, "")}
            class="h-full w-full rounded-full object-cover"
          />
          <span
            :if={!Map.get(user, :avatar_url)}
            class="flex h-full w-full items-center justify-center rounded-full font-medium text-white"
            style={"background-color: #{Map.get(user, :color, "#6B7280")}"}
          >
            {initials(Map.get(user, :name, ""))}
          </span>
          <span class={cn([
            "absolute bottom-0 right-0 block rounded-full ring-2 ring-background",
            status_dot_size(@size),
            status_dot_color(Map.get(user, :status, :offline))
          ])} />
        </div>
        <div
          :if={@show_tooltip}
          role="tooltip"
          class={cn([
            "pointer-events-none absolute left-1/2 -translate-x-1/2 -top-8",
            "whitespace-nowrap rounded bg-popover px-2 py-1 text-xs text-popover-foreground",
            "shadow-md opacity-0 transition-opacity duration-150",
            "group-hover:opacity-100 z-20"
          ])}
        >
          {Map.get(user, :name, "Unknown")}
          <span class="ml-1 text-muted-foreground">
            ({status_label(Map.get(user, :status, :offline))})
          </span>
        </div>
      </div>

      <div
        :if={@overflow > 0}
        class={cn([
          "relative flex shrink-0 items-center justify-center rounded-full",
          "ring-2 ring-background bg-muted text-muted-foreground font-medium",
          avatar_size_class(@size),
          overflow_text_size(@size)
        ])}
      >
        +{@overflow}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # who_is_typing/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :typing_users, :list, default: []
  attr :class, :string, default: nil

  @doc """
  Renders an animated "X is typing..." indicator.

  Shows the appropriate message based on number of typing users:
  - 0 users: renders an empty hidden div
  - 1 user: "Alice is typing..."
  - 2 users: "Alice, Bob are typing..."
  - 3+ users: "Several people are typing..."

  ## Example

      <.who_is_typing id="typing-indicator" typing_users={@typing_users} />
  """
  def who_is_typing(assigns) do
    message = typing_message(assigns.typing_users)
    assigns = assign(assigns, :message, message)

    ~H"""
    <div
      id={@id}
      class={cn(["flex items-center gap-1.5 text-sm text-muted-foreground", @class])}
      aria-live="polite"
      aria-atomic="true"
      role="status"
    >
      <span :if={@message}>
        <span class="inline-flex gap-0.5" aria-hidden="true">
          <span class="h-1 w-1 rounded-full bg-muted-foreground animate-bounce [animation-delay:0ms]" />
          <span class="h-1 w-1 rounded-full bg-muted-foreground animate-bounce [animation-delay:150ms]" />
          <span class="h-1 w-1 rounded-full bg-muted-foreground animate-bounce [animation-delay:300ms]" />
        </span>
        <span class="ml-1">{@message}</span>
      </span>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # collab_status_bar/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :connection_status, :atom, default: :connected, values: [:connected, :reconnecting, :offline]
  attr :users, :list, default: []
  attr :typing_users, :list, default: []
  attr :class, :string, default: nil
  slot :extra, doc: "Custom toolbar items rendered at the end of the status bar."

  @doc """
  Renders a combined status bar with connection indicator, avatar stack,
  typing indicator, and optional extra content.

  ## Example

      <.collab_status_bar
        id="collab-bar"
        connection_status={@conn_status}
        users={@users}
        typing_users={@typing}
      >
        <:extra>
          <button>Share</button>
        </:extra>
      </.collab_status_bar>
  """
  def collab_status_bar(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn([
        "flex items-center gap-3 rounded-lg border border-border bg-card px-3 py-2",
        @class
      ])}
      role="toolbar"
      aria-label="Collaboration status"
    >
      <div class="flex items-center gap-1.5">
        <span class={cn([
          "h-2 w-2 rounded-full",
          connection_dot_color(@connection_status)
        ])} />
        <span class="text-xs text-muted-foreground">
          {connection_label(@connection_status)}
        </span>
      </div>

      <div class="h-4 w-px bg-border" role="separator" />

      <.collab_avatar_stack
        id={"#{@id}-avatars"}
        users={@users}
        max_visible={4}
        size={:sm}
        show_tooltip
      />

      <.who_is_typing
        id={"#{@id}-typing"}
        typing_users={@typing_users}
      />

      <div :if={@extra != []} class="ml-auto flex items-center gap-2">
        {render_slot(@extra)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # collab_user_list/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :users, :list, default: []
  attr :current_user_id, :string, default: nil
  attr :class, :string, default: nil

  @doc """
  Renders a vertical user list panel showing each user with avatar, name,
  role badge, and status indicator. The current user is annotated with "(You)".

  ## Example

      <.collab_user_list
        id="user-panel"
        users={@users}
        current_user_id={@current_user.id}
      />
  """
  def collab_user_list(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn(["flex flex-col gap-1", @class])}
      role="list"
      aria-label="Collaborators"
    >
      <div
        :for={user <- @users}
        class="flex items-center gap-3 rounded-md px-3 py-2 hover:bg-accent/50 transition-colors"
        role="listitem"
      >
        <div class="relative flex-shrink-0">
          <div class="flex h-8 w-8 items-center justify-center rounded-full">
            <img
              :if={Map.get(user, :avatar_url)}
              src={Map.get(user, :avatar_url)}
              alt={Map.get(user, :name, "")}
              class="h-8 w-8 rounded-full object-cover"
            />
            <span
              :if={!Map.get(user, :avatar_url)}
              class="flex h-8 w-8 items-center justify-center rounded-full text-xs font-medium text-white"
              style={"background-color: #{Map.get(user, :color, "#6B7280")}"}
            >
              {initials(Map.get(user, :name, ""))}
            </span>
          </div>
          <span class={cn([
            "absolute -bottom-0.5 -right-0.5 block h-2.5 w-2.5 rounded-full ring-2 ring-background",
            status_dot_color(Map.get(user, :status, :offline))
          ])} />
        </div>

        <div class="flex flex-col min-w-0">
          <span class="truncate text-sm font-medium text-foreground">
            {Map.get(user, :name, "Unknown")}
            <span
              :if={to_string(Map.get(user, :id)) == to_string(@current_user_id) and @current_user_id != nil}
              class="ml-1 text-xs text-muted-foreground"
            >
              (You)
            </span>
          </span>
          <span
            :if={Map.get(user, :role)}
            class="truncate text-xs text-muted-foreground"
          >
            {Map.get(user, :role)}
          </span>
        </div>

        <span class={cn([
          "ml-auto inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium",
          status_badge_class(Map.get(user, :status, :offline))
        ])}>
          {status_label(Map.get(user, :status, :offline))}
        </span>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp initials(name) when is_binary(name) do
    name
    |> String.split(~r/\s+/, trim: true)
    |> Enum.take(2)
    |> Enum.map(&String.first/1)
    |> Enum.join()
    |> String.upcase()
  end

  defp initials(_), do: "?"

  defp avatar_size_class(:sm), do: "h-6 w-6 text-xs"
  defp avatar_size_class(:md), do: "h-8 w-8 text-sm"
  defp avatar_size_class(:lg), do: "h-10 w-10 text-sm"

  defp status_dot_size(:sm), do: "h-1.5 w-1.5"
  defp status_dot_size(:md), do: "h-2 w-2"
  defp status_dot_size(:lg), do: "h-2.5 w-2.5"

  defp status_dot_color(:online), do: "bg-green-500"
  defp status_dot_color(:idle), do: "bg-amber-500"
  defp status_dot_color(:offline), do: "bg-gray-400"
  defp status_dot_color(_), do: "bg-gray-400"

  defp status_label(:online), do: "Online"
  defp status_label(:idle), do: "Idle"
  defp status_label(:offline), do: "Offline"
  defp status_label(_), do: "Offline"

  defp status_badge_class(:online), do: "bg-green-500/10 text-green-600"
  defp status_badge_class(:idle), do: "bg-amber-500/10 text-amber-600"
  defp status_badge_class(:offline), do: "bg-gray-500/10 text-gray-500"
  defp status_badge_class(_), do: "bg-gray-500/10 text-gray-500"

  defp overflow_text_size(:sm), do: "text-xs"
  defp overflow_text_size(:md), do: "text-xs"
  defp overflow_text_size(:lg), do: "text-sm"

  defp connection_dot_color(:connected), do: "bg-green-500"
  defp connection_dot_color(:reconnecting), do: "bg-amber-500 animate-pulse"
  defp connection_dot_color(:offline), do: "bg-destructive"

  defp connection_label(:connected), do: "Connected"
  defp connection_label(:reconnecting), do: "Reconnecting..."
  defp connection_label(:offline), do: "Offline"

  defp typing_message([]), do: nil

  defp typing_message([%{name: name}]) do
    "#{name} is typing..."
  end

  defp typing_message([%{name: n1}, %{name: n2}]) do
    "#{n1}, #{n2} are typing..."
  end

  defp typing_message(users) when length(users) >= 3 do
    "Several people are typing..."
  end

  defp typing_message(_), do: nil
end
