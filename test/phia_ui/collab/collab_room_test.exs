defmodule PhiaUi.Collab.CollabRoomTest do
  use ExUnit.Case, async: false

  alias PhiaUi.Collab.CollabRoom
  alias PhiaUi.Collab.Supervisor, as: CollabSupervisor

  # -------------------------------------------------------------------------
  # Test callback module
  # -------------------------------------------------------------------------

  defmodule TestCallbacks do
    @behaviour PhiaUi.Collab.CollabRoom

    @impl true
    def on_join(_room_id, _user), do: {:ok, %{role: "editor"}}

    @impl true
    def on_leave(_room_id, _user), do: :ok

    @impl true
    def load_room_state(_room_id), do: {:ok, %{counter: 0}}

    @impl true
    def save_room_state(_room_id, _state), do: :ok
  end

  defmodule RejectingCallbacks do
    @behaviour PhiaUi.Collab.CollabRoom

    @impl true
    def on_join(_room_id, _user), do: {:error, :room_full}

    @impl true
    def on_leave(_room_id, _user), do: :ok

    @impl true
    def load_room_state(_room_id), do: {:error, :not_found}

    @impl true
    def save_room_state(_room_id, _state), do: :ok
  end

  # -------------------------------------------------------------------------
  # Setup: start a fresh supervision tree per test
  # -------------------------------------------------------------------------

  setup do
    # Stop the supervisor if already running from a previous test
    case Process.whereis(CollabSupervisor) do
      nil -> :ok
      _pid -> Supervisor.stop(CollabSupervisor)
    end

    start_supervised!(CollabSupervisor)
    :ok
  end

  # -------------------------------------------------------------------------
  # Start / stop
  # -------------------------------------------------------------------------

  describe "start_link/1" do
    test "starts a room process" do
      room_id = unique_room_id()
      {:ok, pid} = CollabRoom.start_link(room_id: room_id)
      assert is_pid(pid)
      assert Process.alive?(pid)
    end

    test "registers in RoomRegistry" do
      room_id = unique_room_id()
      {:ok, _pid} = CollabRoom.start_link(room_id: room_id)
      assert CollabRoom.alive?(room_id)
    end

    test "loads custom state via callback module" do
      room_id = unique_room_id()
      {:ok, _pid} = CollabRoom.start_link(room_id: room_id, callback_module: TestCallbacks)
      assert {:ok, %{counter: 0}} = CollabRoom.get_state(room_id)
    end

    test "defaults to empty state when callback load fails" do
      room_id = unique_room_id()
      {:ok, _pid} = CollabRoom.start_link(room_id: room_id, callback_module: RejectingCallbacks)
      assert {:ok, %{}} = CollabRoom.get_state(room_id)
    end

    test "defaults to empty state without callback module" do
      room_id = unique_room_id()
      {:ok, _pid} = CollabRoom.start_link(room_id: room_id)
      assert {:ok, %{}} = CollabRoom.get_state(room_id)
    end
  end

  # -------------------------------------------------------------------------
  # Join / leave
  # -------------------------------------------------------------------------

  describe "join/2" do
    test "adds a user to the room" do
      room_id = unique_room_id()
      {:ok, _pid} = CollabRoom.start_link(room_id: room_id)

      user = %{id: "user-1", name: "Alice"}
      assert {:ok, entry} = CollabRoom.join(room_id, user)
      assert entry.id == "user-1"
      assert entry.name == "Alice"
      assert %DateTime{} = entry.joined_at
    end

    test "adds metadata from callback on_join" do
      room_id = unique_room_id()
      {:ok, _pid} = CollabRoom.start_link(room_id: room_id, callback_module: TestCallbacks)

      user = %{id: "user-1", name: "Alice"}
      assert {:ok, entry} = CollabRoom.join(room_id, user)
      assert entry.meta == %{role: "editor"}
    end

    test "returns error when callback rejects join" do
      room_id = unique_room_id()
      {:ok, _pid} = CollabRoom.start_link(room_id: room_id, callback_module: RejectingCallbacks)

      user = %{id: "user-1", name: "Alice"}
      assert {:error, :room_full} = CollabRoom.join(room_id, user)
    end

    test "multiple users can join" do
      room_id = unique_room_id()
      {:ok, _pid} = CollabRoom.start_link(room_id: room_id)

      CollabRoom.join(room_id, %{id: "u1", name: "Alice"})
      CollabRoom.join(room_id, %{id: "u2", name: "Bob"})

      {:ok, users} = CollabRoom.get_users(room_id)
      assert length(users) == 2
      ids = Enum.map(users, & &1.id) |> Enum.sort()
      assert ids == ["u1", "u2"]
    end
  end

  describe "leave/2" do
    test "removes a user from the room" do
      room_id = unique_room_id()
      {:ok, _pid} = CollabRoom.start_link(room_id: room_id)

      CollabRoom.join(room_id, %{id: "user-1", name: "Alice"})
      CollabRoom.join(room_id, %{id: "user-2", name: "Bob"})

      CollabRoom.leave(room_id, "user-1")
      # leave is a cast, give it a moment to process
      :timer.sleep(10)

      {:ok, users} = CollabRoom.get_users(room_id)
      assert length(users) == 1
      assert hd(users).id == "user-2"
    end

    test "handles leaving non-existent user gracefully" do
      room_id = unique_room_id()
      {:ok, _pid} = CollabRoom.start_link(room_id: room_id)

      # Should not crash
      CollabRoom.leave(room_id, "ghost-user")
      :timer.sleep(10)

      {:ok, users} = CollabRoom.get_users(room_id)
      assert users == []
    end
  end

  # -------------------------------------------------------------------------
  # State management
  # -------------------------------------------------------------------------

  describe "update_state/2" do
    test "applies the update function to custom state" do
      room_id = unique_room_id()
      {:ok, _pid} = CollabRoom.start_link(room_id: room_id, callback_module: TestCallbacks)

      assert :ok =
               CollabRoom.update_state(room_id, fn state ->
                 Map.update!(state, :counter, &(&1 + 1))
               end)

      assert {:ok, %{counter: 1}} = CollabRoom.get_state(room_id)
    end

    test "works without callback module" do
      room_id = unique_room_id()
      {:ok, _pid} = CollabRoom.start_link(room_id: room_id)

      assert :ok =
               CollabRoom.update_state(room_id, fn state ->
                 Map.put(state, :key, "value")
               end)

      assert {:ok, %{key: "value"}} = CollabRoom.get_state(room_id)
    end
  end

  # -------------------------------------------------------------------------
  # Idle shutdown
  # -------------------------------------------------------------------------

  describe "idle shutdown" do
    test "shuts down after idle timeout when empty" do
      room_id = unique_room_id()
      # Very short timeout for test
      {:ok, pid} = CollabRoom.start_link(room_id: room_id, idle_timeout: 50)

      assert Process.alive?(pid)

      # Wait for idle check to fire and shut down the process
      :timer.sleep(200)

      refute Process.alive?(pid)
      refute CollabRoom.alive?(room_id)
    end

    test "does not shut down while users are present" do
      room_id = unique_room_id()
      {:ok, pid} = CollabRoom.start_link(room_id: room_id, idle_timeout: 50)

      CollabRoom.join(room_id, %{id: "user-1", name: "Alice"})

      :timer.sleep(200)

      assert Process.alive?(pid)
      assert CollabRoom.alive?(room_id)
    end
  end

  # -------------------------------------------------------------------------
  # Touch
  # -------------------------------------------------------------------------

  describe "touch/1" do
    test "refreshes the last activity timestamp" do
      room_id = unique_room_id()
      {:ok, _pid} = CollabRoom.start_link(room_id: room_id, idle_timeout: 150)

      # Touch periodically to keep it alive
      :timer.sleep(50)
      CollabRoom.touch(room_id)
      :timer.sleep(50)
      CollabRoom.touch(room_id)
      :timer.sleep(50)

      assert CollabRoom.alive?(room_id)
    end
  end

  # -------------------------------------------------------------------------
  # alive?/1
  # -------------------------------------------------------------------------

  describe "alive?/1" do
    test "returns false for non-existent room" do
      refute CollabRoom.alive?("nonexistent-#{System.unique_integer([:positive])}")
    end

    test "returns true for running room" do
      room_id = unique_room_id()
      {:ok, _pid} = CollabRoom.start_link(room_id: room_id)
      assert CollabRoom.alive?(room_id)
    end
  end

  # -------------------------------------------------------------------------
  # Struct
  # -------------------------------------------------------------------------

  describe "struct" do
    test "has expected default fields" do
      state = %CollabRoom{}
      assert state.room_id == nil
      assert state.callback_module == nil
      assert state.users == %{}
      assert state.custom_state == %{}
      assert state.created_at == nil
      assert state.last_activity_at == nil
      assert is_integer(state.idle_timeout)
    end
  end

  # -------------------------------------------------------------------------
  # Helpers
  # -------------------------------------------------------------------------

  defp unique_room_id do
    "test-room-#{System.unique_integer([:positive])}"
  end
end
