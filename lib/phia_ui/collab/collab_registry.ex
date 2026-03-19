defmodule PhiaUi.Collab.RoomManager do
  @moduledoc """
  Manages collaboration room lifecycles via `DynamicSupervisor`.

  Provides join-or-create semantics: if a room already exists, returns
  its PID; otherwise starts a new `PhiaUi.Collab.CollabRoom` GenServer
  under the `PhiaUi.Collab.RoomSupervisor`.

  This module is stateless — it delegates to the `RoomRegistry` (a `Registry`)
  for lookups and to the `RoomSupervisor` (a `DynamicSupervisor`) for process
  management. Both are started by `PhiaUi.Collab.Supervisor`.

  ## Example

      # Ensure the room exists (idempotent)
      {:ok, pid} = PhiaUi.Collab.RoomManager.join_or_create_room("doc-123",
        callback_module: MyApp.CollabCallbacks,
        idle_timeout: :timer.minutes(15)
      )

      # Later, when user disconnects
      PhiaUi.Collab.RoomManager.leave_room("doc-123", "user-42")
  """

  require Logger

  @doc """
  Join or create a collaboration room.

  If the room exists, returns `{:ok, pid}`. Otherwise starts a new
  `CollabRoom` GenServer under the `DynamicSupervisor`.

  ## Options
    - `:callback_module` — module implementing `PhiaUi.Collab.CollabRoom` behaviour
    - `:idle_timeout` — milliseconds before an empty room shuts down (default 30 min)

  ## Returns
    - `{:ok, pid}` — the room process PID
    - `{:error, reason}` — if the room could not be started
  """
  @spec join_or_create_room(String.t(), keyword()) :: {:ok, pid()} | {:error, term()}
  def join_or_create_room(room_id, opts \\ []) do
    case Registry.lookup(PhiaUi.Collab.RoomRegistry, room_id) do
      [{pid, _}] ->
        {:ok, pid}

      [] ->
        child_spec = {
          PhiaUi.Collab.CollabRoom,
          Keyword.merge(opts, room_id: room_id)
        }

        case DynamicSupervisor.start_child(PhiaUi.Collab.RoomSupervisor, child_spec) do
          {:ok, pid} ->
            Logger.debug("Created collab room: #{room_id}")
            {:ok, pid}

          {:error, {:already_started, pid}} ->
            {:ok, pid}

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  @doc """
  Leave a room and trigger cleanup if empty.

  Safe to call even if the room is not running — returns `:ok` in all cases.
  """
  @spec leave_room(String.t(), String.t()) :: :ok
  def leave_room(room_id, user_id) do
    if PhiaUi.Collab.CollabRoom.alive?(room_id) do
      PhiaUi.Collab.CollabRoom.leave(room_id, user_id)
    end

    :ok
  end

  @doc """
  Get the PID of a running room, or `nil` if not running.
  """
  @spec get_room(String.t()) :: pid() | nil
  def get_room(room_id) do
    case Registry.lookup(PhiaUi.Collab.RoomRegistry, room_id) do
      [{pid, _}] -> pid
      [] -> nil
    end
  end

  @doc """
  List all active room IDs.

  Returns a list of room ID strings for all currently running `CollabRoom` processes.
  """
  @spec list_rooms() :: [String.t()]
  def list_rooms do
    PhiaUi.Collab.RoomRegistry
    |> Registry.select([{{:"$1", :_, :_}, [], [:"$1"]}])
  end

  @doc "Count the number of currently active rooms."
  @spec room_count() :: non_neg_integer()
  def room_count do
    length(list_rooms())
  end
end
