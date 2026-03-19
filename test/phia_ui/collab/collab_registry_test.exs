defmodule PhiaUi.Collab.RoomManagerTest do
  use ExUnit.Case, async: false

  alias PhiaUi.Collab.RoomManager
  alias PhiaUi.Collab.CollabRoom
  alias PhiaUi.Collab.Supervisor, as: CollabSupervisor

  # -------------------------------------------------------------------------
  # Test callback module
  # -------------------------------------------------------------------------

  defmodule TestCallbacks do
    @behaviour PhiaUi.Collab.CollabRoom

    @impl true
    def on_join(_room_id, _user), do: {:ok, %{}}

    @impl true
    def on_leave(_room_id, _user), do: :ok

    @impl true
    def load_room_state(_room_id), do: {:ok, %{source: "test"}}

    @impl true
    def save_room_state(_room_id, _state), do: :ok
  end

  # -------------------------------------------------------------------------
  # Setup: start the collab supervision tree
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
  # Module structure
  # -------------------------------------------------------------------------

  describe "module structure" do
    setup do
      Code.ensure_loaded!(RoomManager)
      :ok
    end

    test "module is defined" do
      assert Code.ensure_loaded?(RoomManager)
    end

    test "exports join_or_create_room/1" do
      funcs = RoomManager.__info__(:functions)
      assert {:join_or_create_room, 1} in funcs
    end

    test "exports join_or_create_room/2" do
      funcs = RoomManager.__info__(:functions)
      assert {:join_or_create_room, 2} in funcs
    end

    test "exports leave_room/2" do
      funcs = RoomManager.__info__(:functions)
      assert {:leave_room, 2} in funcs
    end

    test "exports get_room/1" do
      funcs = RoomManager.__info__(:functions)
      assert {:get_room, 1} in funcs
    end

    test "exports list_rooms/0" do
      funcs = RoomManager.__info__(:functions)
      assert {:list_rooms, 0} in funcs
    end

    test "exports room_count/0" do
      funcs = RoomManager.__info__(:functions)
      assert {:room_count, 0} in funcs
    end
  end

  # -------------------------------------------------------------------------
  # join_or_create_room/2
  # -------------------------------------------------------------------------

  describe "join_or_create_room/2" do
    test "creates a new room when it does not exist" do
      room_id = unique_room_id()
      assert {:ok, pid} = RoomManager.join_or_create_room(room_id)
      assert is_pid(pid)
      assert Process.alive?(pid)
    end

    test "returns existing room PID on second call" do
      room_id = unique_room_id()
      {:ok, pid1} = RoomManager.join_or_create_room(room_id)
      {:ok, pid2} = RoomManager.join_or_create_room(room_id)
      assert pid1 == pid2
    end

    test "passes callback_module option to CollabRoom" do
      room_id = unique_room_id()
      {:ok, _pid} = RoomManager.join_or_create_room(room_id, callback_module: TestCallbacks)
      assert {:ok, %{source: "test"}} = CollabRoom.get_state(room_id)
    end

    test "passes idle_timeout option to CollabRoom" do
      room_id = unique_room_id()
      {:ok, pid} = RoomManager.join_or_create_room(room_id, idle_timeout: 100)
      assert Process.alive?(pid)

      # Wait for idle shutdown
      :timer.sleep(300)
      refute Process.alive?(pid)
    end
  end

  # -------------------------------------------------------------------------
  # get_room/1
  # -------------------------------------------------------------------------

  describe "get_room/1" do
    test "returns pid for existing room" do
      room_id = unique_room_id()
      {:ok, pid} = RoomManager.join_or_create_room(room_id)
      assert RoomManager.get_room(room_id) == pid
    end

    test "returns nil for non-existent room" do
      assert RoomManager.get_room("no-such-room-#{System.unique_integer([:positive])}") == nil
    end
  end

  # -------------------------------------------------------------------------
  # leave_room/2
  # -------------------------------------------------------------------------

  describe "leave_room/2" do
    test "removes user from room" do
      room_id = unique_room_id()
      {:ok, _pid} = RoomManager.join_or_create_room(room_id)

      CollabRoom.join(room_id, %{id: "user-1", name: "Alice"})
      CollabRoom.join(room_id, %{id: "user-2", name: "Bob"})

      RoomManager.leave_room(room_id, "user-1")
      :timer.sleep(10)

      {:ok, users} = CollabRoom.get_users(room_id)
      assert length(users) == 1
      assert hd(users).id == "user-2"
    end

    test "returns :ok for non-existent room" do
      assert :ok = RoomManager.leave_room("nonexistent-room", "user-1")
    end
  end

  # -------------------------------------------------------------------------
  # list_rooms/0 and room_count/0
  # -------------------------------------------------------------------------

  describe "list_rooms/0" do
    test "returns empty list when no rooms exist" do
      assert RoomManager.list_rooms() == []
    end

    test "returns all active room IDs" do
      room1 = unique_room_id()
      room2 = unique_room_id()

      RoomManager.join_or_create_room(room1)
      RoomManager.join_or_create_room(room2)

      rooms = RoomManager.list_rooms() |> Enum.sort()
      assert room1 in rooms
      assert room2 in rooms
    end
  end

  describe "room_count/0" do
    test "returns 0 when no rooms exist" do
      assert RoomManager.room_count() == 0
    end

    test "returns correct count" do
      room1 = unique_room_id()
      room2 = unique_room_id()
      room3 = unique_room_id()

      RoomManager.join_or_create_room(room1)
      RoomManager.join_or_create_room(room2)
      RoomManager.join_or_create_room(room3)

      assert RoomManager.room_count() == 3
    end
  end

  # -------------------------------------------------------------------------
  # Helpers
  # -------------------------------------------------------------------------

  defp unique_room_id do
    "mgr-test-room-#{System.unique_integer([:positive])}"
  end
end
