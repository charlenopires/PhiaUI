defmodule PhiaUiDesign.Catalog.CatalogServer do
  @moduledoc """
  GenServer that caches introspected component data in ETS for fast access.
  Refreshes on demand.
  """

  use GenServer

  alias PhiaUiDesign.Catalog.{Introspector, FamilyResolver}

  @table :phiaui_design_catalog

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc "Get all components (cached)"
  def all do
    ensure_loaded()

    case :ets.lookup(@table, :all_components) do
      [{:all_components, components}] -> components
      _ -> []
    end
  end

  @doc "Get components grouped by tier"
  def by_tier do
    all()
    |> Enum.group_by(& &1.tier)
    |> Enum.sort_by(fn {tier, _} -> tier_order(tier) end)
  end

  @doc "Get a single component info"
  def get(key) when is_atom(key) do
    ensure_loaded()

    case :ets.lookup(@table, {:component, key}) do
      [{_, info}] -> info
      _ -> nil
    end
  end

  @doc "Get all families"
  def families do
    ensure_loaded()

    case :ets.lookup(@table, :families) do
      [{:families, fams}] -> fams
      _ -> []
    end
  end

  @doc "Force refresh the cache"
  def refresh do
    GenServer.call(__MODULE__, :refresh, 30_000)
  end

  @doc "Search components by name (fuzzy)"
  def search(query) when is_binary(query) do
    query_down = String.downcase(query)

    all()
    |> Enum.filter(fn comp ->
      String.contains?(String.downcase(comp.name), query_down)
    end)
  end

  # Server callbacks

  @impl true
  def init(_opts) do
    table = :ets.new(@table, [:set, :public, :named_table, read_concurrency: true])
    {:ok, %{table: table, loaded: false}}
  end

  @impl true
  def handle_call(:refresh, _from, state) do
    load_catalog()
    {:reply, :ok, %{state | loaded: true}}
  end

  @impl true
  def handle_call(:ensure_loaded, _from, %{loaded: true} = state) do
    {:reply, :ok, state}
  end

  def handle_call(:ensure_loaded, _from, state) do
    load_catalog()
    {:reply, :ok, %{state | loaded: true}}
  end

  # Private

  defp ensure_loaded do
    if :ets.whereis(@table) == :undefined do
      :ok
    else
      case :ets.lookup(@table, :loaded) do
        [{:loaded, true}] -> :ok
        _ -> GenServer.call(__MODULE__, :ensure_loaded, 30_000)
      end
    end
  end

  defp load_catalog do
    components = Introspector.introspect_all()
    families = FamilyResolver.resolve_families()

    :ets.insert(@table, {:all_components, components})
    :ets.insert(@table, {:families, families})
    :ets.insert(@table, {:loaded, true})

    # Index each component by key for fast lookup
    for comp <- components do
      :ets.insert(@table, {{:component, comp.key}, comp})
    end

    :ok
  end

  defp tier_order(:primitive), do: 0
  defp tier_order(:interactive), do: 1
  defp tier_order(:form), do: 2
  defp tier_order(:navigation), do: 3
  defp tier_order(:shell), do: 4
  defp tier_order(:widget), do: 5
  defp tier_order(:layout), do: 6
  defp tier_order(:surface), do: 7
  defp tier_order(:animation), do: 8
  defp tier_order(_), do: 9
end
