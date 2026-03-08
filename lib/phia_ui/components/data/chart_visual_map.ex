defmodule PhiaUi.Components.Data.ChartVisualMap do
  @moduledoc false
  # Visual property encoding for chart components.
  # Maps data values to visual properties (color, size, opacity).
  # Inspired by eCharts VisualMapping (continuous, piecewise, category).
  # Not registered in ComponentRegistry — internal only.

  @doc """
  Creates a continuous color mapping function.

  Interpolates between colors in OKLCH space based on value position within domain.

  Returns `fn(value) -> "oklch(L C H)"`.

  ## Examples

      mapper = continuous({0, 100}, ["oklch(0.95 0.05 30)", "oklch(0.55 0.22 30)"])
      mapper.(50) #=> "oklch(0.75 0.135 30.0)"
  """
  def continuous({d_min, d_max}, colors) when is_list(colors) and length(colors) >= 2 do
    parsed = Enum.map(colors, &parse_oklch/1)

    fn value ->
      t = clamp((value - d_min) / max(d_max - d_min, 1.0e-10), 0.0, 1.0)
      # Multi-stop: find which segment we're in
      n = length(parsed) - 1
      segment = min(floor(t * n), n - 1)
      local_t = t * n - segment
      c1 = Enum.at(parsed, segment)
      c2 = Enum.at(parsed, segment + 1)
      interpolate_oklch(c1, c2, local_t)
    end
  end

  @doc """
  Creates a piecewise (threshold-based) color mapping function.

  Each threshold entry is `{threshold_value, color_string}`.
  Returns the color of the first threshold >= value, or the last color.

  Returns `fn(value) -> color_string`.

  ## Examples

      mapper = piecewise([{25, "green"}, {50, "yellow"}, {75, "orange"}, {100, "red"}])
      mapper.(30) #=> "yellow"
  """
  def piecewise(thresholds) when is_list(thresholds) do
    sorted = Enum.sort_by(thresholds, fn {t, _c} -> t end)

    fn value ->
      case Enum.find(sorted, fn {t, _c} -> value <= t end) do
        {_t, color} -> color
        nil -> sorted |> List.last() |> elem(1)
      end
    end
  end

  @doc """
  Creates a category-based color mapping function.

  Maps category keys to specific colors.

  Returns `fn(category) -> color_string`.

  ## Examples

      mapper = category(%{"high" => "red", "medium" => "yellow", "low" => "green"})
      mapper.("high") #=> "red"
  """
  def category(mapping) when is_map(mapping) do
    fn cat -> Map.get(mapping, cat, "currentColor") end
  end

  @doc """
  Creates a value→size mapping function.

  Linearly maps values in `{d_min, d_max}` to sizes in `{size_min, size_max}`.

  Returns `fn(value) -> float`.

  ## Examples

      mapper = size_map({0, 100}, {4, 20})
      mapper.(50) #=> 12.0
  """
  def size_map({d_min, d_max}, {s_min, s_max}) do
    d_range = max(d_max - d_min, 1.0e-10)
    s_range = s_max - s_min

    fn value ->
      t = clamp((value - d_min) / d_range, 0.0, 1.0)
      s_min + t * s_range
    end
  end

  @doc """
  Creates a value→opacity mapping function.

  Linearly maps values in `{d_min, d_max}` to opacity in `{op_min, op_max}`.

  Returns `fn(value) -> float`.

  ## Examples

      mapper = opacity_map({0, 100}, {0.1, 1.0})
      mapper.(50) #=> 0.55
  """
  def opacity_map({d_min, d_max}, {op_min, op_max}) do
    d_range = max(d_max - d_min, 1.0e-10)
    op_range = op_max - op_min

    fn value ->
      t = clamp((value - d_min) / d_range, 0.0, 1.0)
      op_min + t * op_range
    end
  end

  @doc """
  Computes the domain (min, max) from a list of numeric values.

  Returns `{min, max}`. Returns `{0, 1}` for empty lists.
  """
  def compute_domain([]), do: {0, 1}

  def compute_domain(values) when is_list(values) do
    {Enum.min(values), Enum.max(values)}
  end

  @doc """
  Interpolates between two OKLCH colors.

  ## Parameters
  - `color_a` — `{l, c, h}` tuple or OKLCH string
  - `color_b` — `{l, c, h}` tuple or OKLCH string
  - `t` — interpolation factor 0.0–1.0

  Returns `"oklch(L C H)"` string.
  """
  def interpolate_oklch({l1, c1, h1}, {l2, c2, h2}, t) do
    l = l1 + (l2 - l1) * t
    c = c1 + (c2 - c1) * t
    h = interpolate_hue(h1, h2, t)
    "oklch(#{Float.round(l, 3)} #{Float.round(c, 3)} #{Float.round(h, 1)})"
  end

  def interpolate_oklch(color_a, color_b, t) when is_binary(color_a) and is_binary(color_b) do
    interpolate_oklch(parse_oklch(color_a), parse_oklch(color_b), t)
  end

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------

  defp parse_oklch(color) when is_binary(color) do
    case Regex.run(~r/oklch\(\s*([\d.]+)\s+([\d.]+)\s+([\d.]+)\s*\)/, color) do
      [_, l, c, h] ->
        {parse_float(l), parse_float(c), parse_float(h)}

      nil ->
        {0.5, 0.0, 0}
    end
  end

  defp parse_oklch({l, c, h}), do: {l, c, h}

  defp interpolate_hue(h1, h2, t) do
    # Shortest path interpolation on hue circle (0-360)
    diff = h2 - h1

    diff =
      cond do
        diff > 180 -> diff - 360
        diff < -180 -> diff + 360
        true -> diff
      end

    result = h1 + diff * t

    cond do
      result < 0 -> result + 360
      result >= 360 -> result - 360
      true -> result
    end
  end

  defp clamp(v, lo, hi), do: max(lo, min(hi, v))

  defp parse_float(s) do
    case Float.parse(s) do
      {v, _} -> v
      :error -> 0.0
    end
  end
end
