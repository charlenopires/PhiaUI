defmodule PhiaUi.Components.Display.PresenceAvatars do
  @moduledoc """
  Overlapping avatar stack showing online collaborators (Google Docs-style).

  Each avatar shows the user's photo (if available) or initials on a colored background.
  Includes a status indicator dot (green for online, amber for idle).
  When more than `max_visible` users are present, shows a "+N" overflow badge.

  ## Examples

      <.presence_avatars
        id="editor-presence"
        users={[
          %{id: "1", name: "Maria Silva", avatar_url: nil, color: "#E53E3E", status: "online", role: "advisor"},
          %{id: "2", name: "João Santos", avatar_url: nil, color: "#3182CE", status: "idle", role: "author"}
        ]}
        max_visible={3}
        size={:sm}
      />
  """

  use Phoenix.Component

  @doc """
  Renders an overlapping avatar stack of online collaborators.

  ## Attributes

  * `id` — required unique DOM id
  * `users` — list of maps with keys: `id`, `name`, `avatar_url`, `color`, `status`, `role`
  * `max_visible` — max avatars to show before overflow (default 3)
  * `size` — `:sm` (24px) or `:md` (28px), default `:md`
  * `class` — optional extra CSS classes
  """
  attr :id, :string, required: true
  attr :users, :list, default: []
  attr :max_visible, :integer, default: 3
  attr :size, :atom, default: :md, values: [:sm, :md]
  attr :class, :string, default: nil

  def presence_avatars(assigns) do
    visible = Enum.take(assigns.users, assigns.max_visible)
    overflow = max(0, length(assigns.users) - assigns.max_visible)

    assigns =
      assigns
      |> assign(:visible, visible)
      |> assign(:overflow, overflow)

    ~H"""
    <div id={@id} class={["flex items-center -space-x-2", @class]}>
      <div
        :for={user <- @visible}
        class="relative"
        title={"#{user_display_name(user)} (#{role_label(user)})"}
      >
        <%!-- Avatar circle --%>
        <div class={[
          "relative flex items-center justify-center rounded-full ring-2 ring-white font-medium text-white select-none",
          size_class(@size)
        ]}
          style={"background-color: #{user.color}"}
        >
          <%= if user_avatar(user) do %>
            <img
              src={user_avatar(user)}
              alt={user_display_name(user)}
              class={["rounded-full object-cover", size_class(@size)]}
            />
          <% else %>
            <span class={text_size_class(@size)}>
              {user_initial(user)}
            </span>
          <% end %>
        </div>
        <%!-- Status dot --%>
        <span class={[
          "absolute bottom-0 right-0 block rounded-full ring-1 ring-white",
          dot_size_class(@size),
          status_color(user)
        ]} />
      </div>

      <%!-- Overflow badge --%>
      <div
        :if={@overflow > 0}
        class={[
          "flex items-center justify-center rounded-full bg-gray-200 ring-2 ring-white font-medium text-gray-600 select-none",
          size_class(@size),
          text_size_class(@size)
        ]}
        title={"#{@overflow} more collaborator#{if @overflow > 1, do: "s", else: ""}"}
      >
        +{@overflow}
      </div>
    </div>
    """
  end

  defp user_display_name(%{name: name}) when is_binary(name) and name != "", do: name
  defp user_display_name(%{email: email}) when is_binary(email), do: email
  defp user_display_name(_), do: "Unknown"

  defp user_initial(user) do
    user
    |> user_display_name()
    |> String.first()
    |> String.upcase()
  end

  defp user_avatar(%{avatar_url: url}) when is_binary(url) and url != "", do: url
  defp user_avatar(_), do: nil

  defp role_label(%{role: role}) when is_binary(role) do
    role
    |> String.replace("_", " ")
    |> String.split()
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp role_label(_), do: ""

  defp status_color(%{status: "idle"}), do: "bg-amber-400"
  defp status_color(_), do: "bg-green-500"

  defp size_class(:sm), do: "h-6 w-6"
  defp size_class(:md), do: "h-7 w-7"

  defp text_size_class(:sm), do: "text-[10px]"
  defp text_size_class(:md), do: "text-xs"

  defp dot_size_class(:sm), do: "h-1.5 w-1.5"
  defp dot_size_class(:md), do: "h-2 w-2"
end
