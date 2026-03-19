defmodule PhiaUi.Collab.CollabPresence do
  @moduledoc """
  Phoenix.Presence wrapper for collaborative editing sessions.

  Provides standardized user presence tracking with cursor positions,
  typing indicators, and idle detection. Compatible with the
  `presence_avatars` and `connection_status` PhiaUI components.

  ## Setup

  Configure the PubSub name in your config:

      config :phia_ui, :collab_pubsub, MyApp.PubSub

  Add `PhiaUi.Collab.Supervisor` to your supervision tree — it starts
  the required `Registry` and `DynamicSupervisor`. This Presence module
  must also be started in your supervision tree (it runs its own tracker):

      children = [
        PhiaUi.Collab.Supervisor,
        PhiaUi.Collab.CollabPresence
      ]

  ## Topic Convention

  Use `"collab:room:<room_id>"` as the presence topic to match the
  channel topic convention used by `PhiaUi.Editor.CollabChannel`.

  ## User Metadata

  Each tracked user carries standardized metadata:

    - `:name` — display name (default `"Anonymous"`)
    - `:color` — hex color for cursor/avatar (default `"#6366F1"`)
    - `:avatar_url` — optional avatar image URL
    - `:cursor` — `%{x: number, y: number}` or nil
    - `:typing` — boolean typing indicator
    - `:idle_since` — UTC datetime when user became idle, or nil
    - `:joined_at` — UTC datetime when user was first tracked
  """

  use Phoenix.Presence,
    otp_app: :phia_ui,
    pubsub_server: Application.compile_env(:phia_ui, :collab_pubsub, PhiaUi.PubSub)

  @type user_meta :: %{
          name: String.t(),
          color: String.t(),
          avatar_url: String.t() | nil,
          cursor: map() | nil,
          typing: boolean(),
          idle_since: DateTime.t() | nil,
          joined_at: DateTime.t()
        }

  @doc """
  Track a user in a collaboration room.

  Normalizes the provided metadata into the standard presence schema.
  Missing fields receive sensible defaults.

  ## Parameters
    - `topic` — the presence topic (e.g., `"collab:room:doc-123"`)
    - `user_id` — unique user identifier (string)
    - `meta` — user metadata map; recognized keys: `:name`, `:color`, `:avatar_url`

  ## Examples

      iex> CollabPresence.track_user("collab:room:doc-1", "user-42", %{name: "Alice", color: "#EF4444"})
      {:ok, _ref}
  """
  @spec track_user(String.t(), String.t(), map()) :: {:ok, binary()} | {:error, term()}
  def track_user(topic, user_id, meta) do
    standardized = %{
      name: Map.get(meta, :name, "Anonymous"),
      color: Map.get(meta, :color, "#6366F1"),
      avatar_url: Map.get(meta, :avatar_url),
      cursor: nil,
      typing: false,
      idle_since: nil,
      joined_at: DateTime.utc_now()
    }

    track(self(), topic, user_id, standardized)
  end

  @doc """
  Update the cursor position for a tracked user.

  Also clears the idle state, since cursor movement implies activity.

  ## Parameters
    - `topic` — the presence topic
    - `user_id` — the user whose cursor moved
    - `cursor` — a map with position data (e.g., `%{x: 120, y: 340}`)
  """
  @spec update_cursor(String.t(), String.t(), map()) :: {:ok, binary()} | {:error, term()}
  def update_cursor(topic, user_id, cursor) do
    update(self(), topic, user_id, fn meta ->
      %{meta | cursor: cursor, idle_since: nil}
    end)
  end

  @doc """
  Set or clear the typing indicator for a user.

  ## Parameters
    - `topic` — the presence topic
    - `user_id` — the user who started or stopped typing
    - `typing?` — `true` when typing, `false` when stopped
  """
  @spec update_typing(String.t(), String.t(), boolean()) :: {:ok, binary()} | {:error, term()}
  def update_typing(topic, user_id, typing?) do
    update(self(), topic, user_id, fn meta ->
      %{meta | typing: typing?}
    end)
  end

  @doc """
  Mark a user as idle.

  Sets `idle_since` to the current UTC time and clears the typing flag.
  """
  @spec mark_idle(String.t(), String.t()) :: {:ok, binary()} | {:error, term()}
  def mark_idle(topic, user_id) do
    update(self(), topic, user_id, fn meta ->
      %{meta | idle_since: DateTime.utc_now(), typing: false}
    end)
  end

  @doc """
  Returns a formatted list of online users compatible with the `presence_avatars` component.

  Each user map contains: `:id`, `:name`, `:color`, `:avatar_url`, `:status`, `:cursor`, `:typing`.
  The `:status` field is `"online"` or `"idle"` based on the `idle_since` metadata.
  """
  @spec online_users(String.t()) :: [map()]
  def online_users(topic) do
    topic
    |> list()
    |> Enum.map(fn {user_id, %{metas: [meta | _]}} ->
      %{
        id: user_id,
        name: meta.name,
        color: meta.color,
        avatar_url: meta.avatar_url,
        status: if(meta.idle_since, do: "idle", else: "online"),
        cursor: meta.cursor,
        typing: meta.typing
      }
    end)
  end

  @doc "Returns only users who are currently typing."
  @spec typing_users(String.t()) :: [map()]
  def typing_users(topic) do
    topic
    |> online_users()
    |> Enum.filter(& &1.typing)
  end

  @doc "Returns the count of distinct online users in the topic."
  @spec user_count(String.t()) :: non_neg_integer()
  def user_count(topic) do
    topic |> list() |> map_size()
  end
end
