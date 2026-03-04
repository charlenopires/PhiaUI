defmodule PhiaUi.ClassMerger.Cache do
  @moduledoc """
  ETS-backed cache for memoising resolved Tailwind class strings.

  Stores `{input_key, resolved_string}` pairs so that identical lists of class
  tokens are merged only once per application lifetime. This is the performance
  backbone of `PhiaUi.ClassMerger.cn/1`: the first call for a given input list
  runs the full resolution pipeline; every subsequent call with the same input
  is a direct ETS read.

  ## Why GenServer as Table Owner?

  ETS tables are owned by the Erlang process that created them. If the owning
  process exits, the table is garbage-collected and all cached data is lost.
  Without a long-lived owner, every application restart (or crash) would
  destroy the cache.

  `PhiaUi.ClassMerger.Cache` is a `GenServer` whose sole initialisation
  side-effect is creating the ETS table. It holds no other meaningful state
  (the GenServer state is an empty list `[]`). The GenServer is supervised by
  `PhiaUi.Supervisor`, so it is restarted automatically on failure, and the
  ETS table is recreated on restart.

  ## Why `:public` + Direct ETS Calls for Reads and Writes?

  Routing all reads and writes through the GenServer's `handle_call/3` would
  create a sequential bottleneck: every LiveView process would have to queue
  behind one another waiting for the GenServer to process their request.

  Instead the table is created as `:public`, which allows any process to call
  `:ets.lookup/2` and `:ets.insert/2` directly — bypassing the GenServer
  message queue entirely. The GenServer only needs to be involved at
  initialisation time to create the table. After that it exists purely to keep
  the table alive.

  ## Why `read_concurrency: true`?

  `cn/1` is called far more often than it writes (the cache is warm after the
  first few renders). The `:read_concurrency` option switches ETS to an
  internal implementation that uses a lock-free read path optimised for this
  workload. Multiple LiveView processes can read the same key simultaneously
  without any serialisation.

  ## Table Configuration

  | Option              | Value       | Reason                                        |
  |---------------------|-------------|-----------------------------------------------|
  | `:named_table`      | (flag)      | Allows lookup by module name without a table  |
  |                     |             | reference — any process can call the module   |
  |                     |             | name as if it were an ETS table identifier.   |
  | `:public`           | (flag)      | Any process may read and write without going  |
  |                     |             | through the owning GenServer.                 |
  | `read_concurrency`  | `true`      | Lock-free read path for high read / low write |
  |                     |             | workloads.                                    |

  The default ETS table type (`:set`) is used, giving O(1) key lookup via
  hashing. Each `{key, value}` pair is unique by key.

  ## Examples

      iex> PhiaUi.ClassMerger.Cache.get(["px-4", "px-2"])
      nil

      iex> PhiaUi.ClassMerger.Cache.put(["px-4", "px-2"], "px-2")
      "px-2"

      iex> PhiaUi.ClassMerger.Cache.get(["px-4", "px-2"])
      "px-2"
  """

  use GenServer

  # The module name doubles as the ETS table name (:named_table option).
  # Using the module name avoids storing a table reference anywhere — any
  # process can access the table by name after it has been created.
  @table __MODULE__

  # --- Public API -----------------------------------------------------------

  @doc """
  Starts the cache GenServer and registers it under its module name.

  The GenServer's `init/1` callback creates the ETS table immediately, so the
  table is available as soon as `start_link/1` returns. Called by
  `PhiaUi.Supervisor` during application startup.
  """
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Returns the cached merged class string for `key`, or `nil` if absent.

  Reads directly from ETS — no GenServer message is sent. Safe to call from
  any process concurrently.

  ## Examples

      iex> PhiaUi.ClassMerger.Cache.get(["bg-red-500", "bg-blue-500"])
      nil  # cache miss on first call
  """
  @spec get(term()) :: String.t() | nil
  def get(key), do: lookup(key)

  @doc """
  Stores `value` under `key` and returns `value`.

  Writes directly to ETS via `:ets.insert/2` — no GenServer message is sent.
  Because the table is `:public`, any process can write without serialising
  through the GenServer. In the rare case of two processes computing the same
  key concurrently, the last writer wins — both will produce the same string,
  so this is safe.

  ## Examples

      iex> PhiaUi.ClassMerger.Cache.put(["text-sm", "text-lg"], "text-lg")
      "text-lg"
  """
  @spec put(term(), String.t()) :: String.t()
  def put(key, value) do
    :ets.insert(@table, {key, value})
    value
  end

  # --- GenServer callbacks ---------------------------------------------------

  @impl GenServer
  def init(_) do
    # Create the ETS table on startup. This is the only reason this GenServer
    # exists: to own the table and prevent it from being garbage-collected.
    # After this point the GenServer receives no messages during normal
    # operation — all reads and writes go directly to ETS.
    :ets.new(@table, [:named_table, :public, read_concurrency: true])
    {:ok, []}
  end

  # --- Private helpers -------------------------------------------------------

  # Direct ETS lookup. Returns the value for `key` or nil for a miss.
  # Pattern-matching on `{^key, value}` ensures we only return the value
  # when the stored key is exactly the one we looked up (ETS guarantees this
  # for :set tables, but the pin makes the intent explicit).
  defp lookup(key) do
    case :ets.lookup(@table, key) do
      [{^key, value}] -> value
      [] -> nil
    end
  end
end
