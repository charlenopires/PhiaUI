defmodule PhiaUi.Components.Data.ChartPoint do
  @moduledoc false
  # Point model helper for chart components.
  # Maps to Highcharts' Point class — enriches raw data into renderable point maps
  # with pixel coordinates, state, and visual encoding.
  # Not registered in ComponentRegistry — internal only.

  @doc """
  Converts raw data list into enriched point maps with pixel coordinates.

  Each point gets: label, value, px, py, index, color, state.

  ## Parameters
  - `data_list` — `[%{label, value}]`
  - `coord` — coordinate system from ChartCoord
  - `opts` — keyword list with `:colors` (list or function), `:default_color`
  """
  def from_data(data_list, coord, opts \\ []) do
    default_color = Keyword.get(opts, :default_color, "currentColor")
    colors = Keyword.get(opts, :colors, nil)

    data_list
    |> Enum.with_index()
    |> Enum.map(fn {item, index} ->
      {px, py} = coord.data_to_point.(item.label, item.value)

      %{
        label: item.label,
        value: item.value,
        px: Float.round(px * 1.0, 2),
        py: Float.round(py * 1.0, 2),
        index: index,
        color: resolve_color(colors, index, default_color),
        state: :normal
      }
    end)
  end

  @doc """
  Converts raw data into enriched points with base_py for stacked series.

  Same as `from_data/3` but adds `:base_py` computed from base value (0 or stacked base).

  ## Parameters
  - `data_list` — `[%{label, value, base}]` where base is the stacking baseline
  - `coord` — coordinate system from ChartCoord
  - `opts` — same as `from_data/3`
  """
  def from_data_with_base(data_list, coord, opts \\ []) do
    default_color = Keyword.get(opts, :default_color, "currentColor")
    colors = Keyword.get(opts, :colors, nil)

    data_list
    |> Enum.with_index()
    |> Enum.map(fn {item, index} ->
      base_val = Map.get(item, :base, 0)
      {px, py} = coord.data_to_point.(item.label, item.value)
      {_, base_py} = coord.data_to_point.(item.label, base_val)

      %{
        label: item.label,
        value: item.value,
        px: Float.round(px * 1.0, 2),
        py: Float.round(py * 1.0, 2),
        base_py: Float.round(base_py * 1.0, 2),
        index: index,
        color: resolve_color(colors, index, default_color),
        state: :normal
      }
    end)
  end

  @doc """
  Returns a new point with updated state.

  ## States
  - `:normal` — default appearance
  - `:hover` — highlighted on hover
  - `:select` — selected/clicked
  """
  def update_state(point, state) when state in [:normal, :hover, :select] do
    %{point | state: state}
  end

  @doc """
  Applies a visual mapping function to enrich points with computed visual properties.

  The `visual_map_fn` receives a point and returns a map of visual overrides
  (e.g., `%{color: "red", opacity: 0.5, size: 8}`). These are merged into each point.
  """
  def apply_visual_map(points, visual_map_fn) when is_function(visual_map_fn, 1) do
    Enum.map(points, fn point ->
      overrides = visual_map_fn.(point)
      Map.merge(point, overrides)
    end)
  end

  @doc """
  Finds the nearest point to the given pixel position.

  Returns `{point, distance}` or `nil` if points is empty.
  """
  def nearest([], _pos), do: nil

  def nearest(points, {target_px, target_py}) do
    points
    |> Enum.map(fn point ->
      dist = distance(point.px, point.py, target_px, target_py)
      {point, dist}
    end)
    |> Enum.min_by(fn {_point, dist} -> dist end)
  end

  @doc """
  Returns all points within the given pixel radius of the target position.
  """
  def within_radius(points, {target_px, target_py}, radius) do
    Enum.filter(points, fn point ->
      distance(point.px, point.py, target_px, target_py) <= radius
    end)
  end

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------

  defp distance(x1, y1, x2, y2) do
    dx = x2 - x1
    dy = y2 - y1
    :math.sqrt(dx * dx + dy * dy)
  end

  defp resolve_color(nil, _index, default), do: default
  defp resolve_color(colors, index, _default) when is_list(colors) do
    Enum.at(colors, rem(index, max(length(colors), 1)), "currentColor")
  end
  defp resolve_color(color_fn, index, _default) when is_function(color_fn, 1) do
    color_fn.(index)
  end
end
