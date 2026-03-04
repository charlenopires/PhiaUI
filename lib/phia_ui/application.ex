defmodule PhiaUi.Application do
  @moduledoc """
  OTP Application entry-point for PhiaUi.

  ## Supervision Tree

  PhiaUi runs a minimal supervision tree with a `:one_for_one` strategy —
  meaning each worker is restarted independently if it crashes, without
  affecting siblings.

  ```
  PhiaUi.Supervisor  (strategy: :one_for_one)
  └── PhiaUi.ClassMerger.Cache  (GenServer + ETS table owner)
  ```

  ## Why a Supervision Tree for a UI Library?

  PhiaUI ships `ClassMerger.Cache`, an ETS-backed memoisation table for
  resolved Tailwind class strings. ETS tables in Erlang/OTP are owned by the
  process that created them: if the owning process exits, the table is
  garbage-collected. To keep the table alive for the lifetime of the
  application, it must be owned by a supervised, long-running process.

  `ClassMerger.Cache` is that process. It is a `GenServer` whose sole
  initialisation side-effect is creating the ETS table. The GenServer itself
  holds no meaningful state — the ETS table is the state. All reads and the
  majority of writes go directly to ETS without passing through the GenServer
  message queue, ensuring lock-free concurrent access from every LiveView
  process in the application.

  ## Why ETS?

  `cn/1` is called on every component render. In a busy LiveView application
  a single page diff may trigger hundreds of `cn/1` calls. Without caching,
  each call would re-tokenise strings, walk the prefix-rule table, and rebuild
  the output string. ETS provides:

  - **O(1) key lookup** regardless of table size.
  - **`read_concurrency: true`** — read operations use a lock-free path
    optimised for tables that are read far more than they are written.
  - **Process isolation** — no single bottleneck process; every caller reads
    directly from the shared table.
  - **Zero serialisation** — because the table is `:public`, writers also
    bypass the GenServer queue (`:ets.insert/2` is a direct NIF call).

  ## Extending the Supervision Tree

  If you eject PhiaUI components into your own application and add processes
  (e.g. a theme registry), you can add them as siblings here by modifying the
  ejected `Application` module rather than the upstream package.
  """

  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      # The ETS cache that memoises resolved Tailwind class strings.
      # Must be started before any component renders, which is guaranteed
      # because Application.start/2 completes before the endpoint accepts
      # connections.
      PhiaUi.ClassMerger.Cache
    ]

    opts = [strategy: :one_for_one, name: PhiaUi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
