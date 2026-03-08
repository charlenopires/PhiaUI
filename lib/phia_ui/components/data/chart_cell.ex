defmodule PhiaUi.Components.Data.ChartCell do
  @moduledoc false
  # Per-element style overrides inspired by Recharts `<Cell>`.
  # Merges index-based overrides (color, opacity, class) into element maps.
  # Not registered in ComponentRegistry — internal only.

  @doc """
  Merges per-index overrides into a list of element maps.

  ## Parameters
  - `elements` — list of element maps (e.g. `[%{type: :bar, color: "red", ...}]`)
  - `cells` — list of override maps, matched by index (e.g. `[%{color: "blue"}, %{}, ...]`)

  Only non-nil keys in each cell are merged. Supported keys: `:color`, `:opacity`, `:class`.
  """
  def apply_cells(elements, []), do: elements
  def apply_cells(elements, nil), do: elements

  def apply_cells(elements, cells) when is_list(cells) do
    elements
    |> Enum.with_index()
    |> Enum.map(fn {elem, i} ->
      case Enum.at(cells, i) do
        nil -> elem
        cell when is_map(cell) -> merge_cell(elem, cell)
      end
    end)
  end

  @doc """
  Generates a cell list from data using a mapper function.

  ## Parameters
  - `data` — list of data items
  - `mapper_fn` — function `(item, index) -> %{color: ..., opacity: ...}` or `%{}`
  """
  def cells_from(data, mapper_fn) when is_function(mapper_fn, 2) do
    data
    |> Enum.with_index()
    |> Enum.map(fn {item, i} -> mapper_fn.(item, i) end)
  end

  def cells_from(data, mapper_fn) when is_function(mapper_fn, 1) do
    Enum.map(data, fn item -> mapper_fn.(item) end)
  end

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------

  @supported_keys [:color, :opacity, :class]

  defp merge_cell(elem, cell) do
    Enum.reduce(@supported_keys, elem, fn key, acc ->
      case Map.get(cell, key) do
        nil -> acc
        value -> Map.put(acc, key, value)
      end
    end)
  end
end
