defmodule PhiaUi.Collab.Supervisor do
  @moduledoc """
  Top-level supervisor for PhiaUI collaboration infrastructure.

  Starts the `RoomRegistry` (a `Registry` for unique room name lookups)
  and `RoomSupervisor` (a `DynamicSupervisor` for on-demand room processes).

  Add to your application supervision tree only if using collab features:

      # In MyApp.Application
      children = [
        # ... your other children ...
        PhiaUi.Collab.Supervisor
      ]

  The strategy is `:one_for_all` because the `DynamicSupervisor` depends on
  the `Registry` for name resolution — if either crashes both must restart.
  """

  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl Supervisor
  def init(_opts) do
    children = [
      {Registry, keys: :unique, name: PhiaUi.Collab.RoomRegistry},
      {DynamicSupervisor, name: PhiaUi.Collab.RoomSupervisor, strategy: :one_for_one}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
