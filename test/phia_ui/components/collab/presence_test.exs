defmodule PhiaUi.Components.Collab.PresenceTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Collab.Presence

    def render_avatar_stack(assigns) do
      ~H"""
      <.collab_avatar_stack
        id={@id}
        users={@users}
        max_visible={assigns[:max_visible] || 5}
        size={assigns[:size] || :md}
        show_tooltip={assigns[:show_tooltip] != false}
        class={assigns[:class]}
      />
      """
    end

    def render_who_is_typing(assigns) do
      ~H"""
      <.who_is_typing
        id={@id}
        typing_users={@typing_users}
        class={assigns[:class]}
      />
      """
    end

    def render_status_bar(assigns) do
      ~H"""
      <.collab_status_bar
        id={@id}
        connection_status={assigns[:connection_status] || :connected}
        users={assigns[:users] || []}
        typing_users={assigns[:typing_users] || []}
        class={assigns[:class]}
      />
      """
    end

    def render_status_bar_with_extra(assigns) do
      ~H"""
      <.collab_status_bar
        id={@id}
        connection_status={:connected}
        users={[]}
        typing_users={[]}
      >
        <:extra>
          <button>Share</button>
        </:extra>
      </.collab_status_bar>
      """
    end

    def render_user_list(assigns) do
      ~H"""
      <.collab_user_list
        id={@id}
        users={@users}
        current_user_id={assigns[:current_user_id]}
        class={assigns[:class]}
      />
      """
    end
  end

  # ---------------------------------------------------------------------------
  # Test data helpers
  # ---------------------------------------------------------------------------

  defp user(overrides \\ %{}) do
    Map.merge(
      %{
        id: "user-1",
        name: "Alice Adams",
        color: "#3B82F6",
        avatar_url: "/avatars/alice.jpg",
        status: :online
      },
      overrides
    )
  end

  defp users(count) do
    Enum.map(1..count, fn i ->
      user(%{id: "user-#{i}", name: "User #{i}", color: "##{String.pad_leading("#{i}B82F6", 6, "0")}"})
    end)
  end

  # ---------------------------------------------------------------------------
  # collab_avatar_stack/1
  # ---------------------------------------------------------------------------

  describe "collab_avatar_stack/1" do
    test "renders empty group when no users" do
      html = render_component(&H.render_avatar_stack/1, %{id: "stack-empty", users: []})
      assert html =~ ~s(id="stack-empty")
      assert html =~ ~s(role="group")
      refute html =~ "+"
    end

    test "renders user avatars with initials when no avatar_url" do
      u = user(%{avatar_url: nil, name: "Bob Baker"})
      html = render_component(&H.render_avatar_stack/1, %{id: "stack-initials", users: [u]})
      assert html =~ "BB"
    end

    test "renders user avatar image when avatar_url is present" do
      u = user(%{avatar_url: "/photo.jpg"})
      html = render_component(&H.render_avatar_stack/1, %{id: "stack-img", users: [u]})
      assert html =~ "<img"
      assert html =~ ~s(src="/photo.jpg")
    end

    test "shows overflow badge when exceeding max_visible" do
      html =
        render_component(&H.render_avatar_stack/1, %{
          id: "stack-overflow",
          users: users(8),
          max_visible: 3
        })

      assert html =~ "+5"
    end

    test "no overflow badge when users within max_visible" do
      html =
        render_component(&H.render_avatar_stack/1, %{
          id: "stack-no-overflow",
          users: users(3),
          max_visible: 5
        })

      refute html =~ "+"
    end

    test "shows online status dot" do
      u = user(%{status: :online})
      html = render_component(&H.render_avatar_stack/1, %{id: "stack-online", users: [u]})
      assert html =~ "bg-green-500"
    end

    test "shows idle status dot" do
      u = user(%{status: :idle})
      html = render_component(&H.render_avatar_stack/1, %{id: "stack-idle", users: [u]})
      assert html =~ "bg-amber-500"
    end

    test "shows offline status dot" do
      u = user(%{status: :offline})
      html = render_component(&H.render_avatar_stack/1, %{id: "stack-offline", users: [u]})
      assert html =~ "bg-gray-400"
    end

    test "renders tooltip with user name" do
      u = user(%{name: "Charlie Chen"})
      html = render_component(&H.render_avatar_stack/1, %{id: "stack-tooltip", users: [u]})
      assert html =~ "Charlie Chen"
      assert html =~ ~s(role="tooltip")
    end

    test "size sm applies h-6 w-6" do
      u = user()
      html = render_component(&H.render_avatar_stack/1, %{id: "stack-sm", users: [u], size: :sm})
      assert html =~ "h-6"
      assert html =~ "w-6"
    end

    test "size md applies h-8 w-8" do
      u = user()
      html = render_component(&H.render_avatar_stack/1, %{id: "stack-md", users: [u], size: :md})
      assert html =~ "h-8"
      assert html =~ "w-8"
    end

    test "size lg applies h-10 w-10" do
      u = user()
      html = render_component(&H.render_avatar_stack/1, %{id: "stack-lg", users: [u], size: :lg})
      assert html =~ "h-10"
      assert html =~ "w-10"
    end

    test "applies custom class" do
      html =
        render_component(&H.render_avatar_stack/1, %{
          id: "stack-class",
          users: [],
          class: "my-custom-class"
        })

      assert html =~ "my-custom-class"
    end

    test "has aria-label for accessibility" do
      html = render_component(&H.render_avatar_stack/1, %{id: "stack-aria", users: []})
      assert html =~ ~s(aria-label="Online users")
    end

    test "applies background color from user color" do
      u = user(%{avatar_url: nil, color: "#EF4444"})
      html = render_component(&H.render_avatar_stack/1, %{id: "stack-color", users: [u]})
      assert html =~ "background-color: #EF4444"
    end

    test "overflow badge has bg-muted class" do
      html =
        render_component(&H.render_avatar_stack/1, %{
          id: "stack-muted",
          users: users(6),
          max_visible: 2
        })

      assert html =~ "bg-muted"
    end
  end

  # ---------------------------------------------------------------------------
  # who_is_typing/1
  # ---------------------------------------------------------------------------

  describe "who_is_typing/1" do
    test "renders empty when no one typing" do
      html = render_component(&H.render_who_is_typing/1, %{id: "wt-empty", typing_users: []})
      assert html =~ ~s(id="wt-empty")
      refute html =~ "is typing"
    end

    test "renders single user typing" do
      html =
        render_component(&H.render_who_is_typing/1, %{
          id: "typing-one",
          typing_users: [%{name: "Alice"}]
        })

      assert html =~ "Alice is typing..."
    end

    test "renders two users typing" do
      html =
        render_component(&H.render_who_is_typing/1, %{
          id: "typing-two",
          typing_users: [%{name: "Alice"}, %{name: "Bob"}]
        })

      assert html =~ "Alice, Bob are typing..."
    end

    test "renders several people typing for 3+" do
      html =
        render_component(&H.render_who_is_typing/1, %{
          id: "typing-many",
          typing_users: [%{name: "Alice"}, %{name: "Bob"}, %{name: "Carol"}]
        })

      assert html =~ "Several people are typing..."
    end

    test "shows animated dots when someone is typing" do
      html =
        render_component(&H.render_who_is_typing/1, %{
          id: "typing-dots",
          typing_users: [%{name: "Alice"}]
        })

      assert html =~ "animate-bounce"
    end

    test "has aria-live for accessibility" do
      html = render_component(&H.render_who_is_typing/1, %{id: "typing-aria", typing_users: []})
      assert html =~ ~s(aria-live="polite")
    end

    test "has role=status" do
      html = render_component(&H.render_who_is_typing/1, %{id: "typing-role", typing_users: []})
      assert html =~ ~s(role="status")
    end
  end

  # ---------------------------------------------------------------------------
  # collab_status_bar/1
  # ---------------------------------------------------------------------------

  describe "collab_status_bar/1" do
    test "renders all sections" do
      html =
        render_component(&H.render_status_bar/1, %{
          id: "bar-full",
          connection_status: :connected,
          users: [user()],
          typing_users: [%{name: "Alice"}]
        })

      assert html =~ ~s(id="bar-full")
      assert html =~ "Connected"
      assert html =~ "Alice is typing..."
    end

    test "shows connected status" do
      html = render_component(&H.render_status_bar/1, %{id: "bar-connected"})
      assert html =~ "Connected"
      assert html =~ "bg-green-500"
    end

    test "shows reconnecting status" do
      html =
        render_component(&H.render_status_bar/1, %{
          id: "bar-reconnecting",
          connection_status: :reconnecting
        })

      assert html =~ "Reconnecting..."
      assert html =~ "bg-amber-500"
    end

    test "shows offline status" do
      html =
        render_component(&H.render_status_bar/1, %{
          id: "bar-offline",
          connection_status: :offline
        })

      assert html =~ "Offline"
      assert html =~ "bg-destructive"
    end

    test "renders extra slot" do
      html = render_component(&H.render_status_bar_with_extra/1, %{id: "bar-extra"})
      assert html =~ "Share"
      assert html =~ "<button>"
    end

    test "has role=toolbar for accessibility" do
      html = render_component(&H.render_status_bar/1, %{id: "bar-toolbar"})
      assert html =~ ~s(role="toolbar")
    end

    test "includes separator between sections" do
      html = render_component(&H.render_status_bar/1, %{id: "bar-sep"})
      assert html =~ ~s(role="separator")
    end
  end

  # ---------------------------------------------------------------------------
  # collab_user_list/1
  # ---------------------------------------------------------------------------

  describe "collab_user_list/1" do
    test "renders user list" do
      u = user(%{name: "Alice Adams", role: "Editor"})
      html = render_component(&H.render_user_list/1, %{id: "list-basic", users: [u]})
      assert html =~ "Alice Adams"
      assert html =~ "Editor"
    end

    test "highlights current user with (You)" do
      u = user(%{id: "user-1", name: "Alice Adams"})

      html =
        render_component(&H.render_user_list/1, %{
          id: "list-you",
          users: [u],
          current_user_id: "user-1"
        })

      assert html =~ "(You)"
    end

    test "does not show (You) for other users" do
      u = user(%{id: "user-1", name: "Alice Adams"})

      html =
        render_component(&H.render_user_list/1, %{
          id: "list-other",
          users: [u],
          current_user_id: "user-2"
        })

      refute html =~ "(You)"
    end

    test "shows user avatar image" do
      u = user(%{avatar_url: "/photo.jpg"})
      html = render_component(&H.render_user_list/1, %{id: "list-img", users: [u]})
      assert html =~ "<img"
      assert html =~ ~s(src="/photo.jpg")
    end

    test "shows initials when no avatar_url" do
      u = user(%{avatar_url: nil, name: "Bob Baker"})
      html = render_component(&H.render_user_list/1, %{id: "list-initials", users: [u]})
      assert html =~ "BB"
    end

    test "shows status badge" do
      u = user(%{status: :online})
      html = render_component(&H.render_user_list/1, %{id: "list-status", users: [u]})
      assert html =~ "Online"
    end

    test "renders multiple users" do
      u1 = user(%{id: "user-1", name: "Alice"})
      u2 = user(%{id: "user-2", name: "Bob"})
      html = render_component(&H.render_user_list/1, %{id: "list-multi", users: [u1, u2]})
      assert html =~ "Alice"
      assert html =~ "Bob"
    end

    test "has role=list for accessibility" do
      html = render_component(&H.render_user_list/1, %{id: "list-role", users: []})
      assert html =~ ~s(role="list")
    end

    test "has aria-label" do
      html = render_component(&H.render_user_list/1, %{id: "list-aria", users: []})
      assert html =~ ~s(aria-label="Collaborators")
    end

    test "renders empty list without errors" do
      html = render_component(&H.render_user_list/1, %{id: "list-empty", users: []})
      assert html =~ ~s(id="list-empty")
    end

    test "applies custom class" do
      html =
        render_component(&H.render_user_list/1, %{
          id: "list-class",
          users: [],
          class: "my-list-class"
        })

      assert html =~ "my-list-class"
    end
  end
end
