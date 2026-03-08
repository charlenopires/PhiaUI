defmodule PhiaUi.Components.Data.ChartCategoryColors do
  @moduledoc false
  # Automatic cyclic category → color mapping.
  # Inspired by Tremor's constructCategoryColors utility.
  # Not registered in ComponentRegistry — internal only.

  alias PhiaUi.Components.Data.ChartHelpers

  @doc """
  Maps a list of category names to colors from a palette.

  Returns a map of `%{category_name => color_string}`.

  Uses the default OKLCH palette when no custom palette is provided.

  ## Examples

      iex> ChartCategoryColors.build(["Revenue", "Cost"])
      %{"Revenue" => "oklch(0.60 0.20 240)", "Cost" => "oklch(0.70 0.18 145)"}

      iex> ChartCategoryColors.build(["A", "B", "C"], ["red", "blue", "green"])
      %{"A" => "red", "B" => "blue", "C" => "green"}
  """
  def build(categories, palette \\ [])

  def build([], _palette), do: %{}

  def build(categories, []) do
    build(categories, ChartHelpers.default_palette())
  end

  def build(categories, palette) when is_list(categories) and is_list(palette) do
    len = max(length(palette), 1)

    categories
    |> Enum.with_index()
    |> Map.new(fn {cat, idx} -> {cat, Enum.at(palette, rem(idx, len))} end)
  end

  @doc """
  Returns the color for a single category from an existing color map.

  Falls back to a default gray when the category isn't found.
  """
  def get_color(color_map, category, fallback \\ "oklch(0.55 0.00 0)") do
    Map.get(color_map, category, fallback)
  end

  @doc """
  Builds category colors from a list of series maps.

  Each series map must have a `:name` key.

  ## Examples

      iex> ChartCategoryColors.from_series([%{name: "Revenue"}, %{name: "Cost"}])
      %{"Revenue" => "oklch(0.60 0.20 240)", "Cost" => "oklch(0.70 0.18 145)"}
  """
  def from_series(series, palette \\ []) when is_list(series) do
    categories = Enum.map(series, & &1.name)
    build(categories, palette)
  end
end
