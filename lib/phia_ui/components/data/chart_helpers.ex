defmodule PhiaUi.Components.Data.ChartHelpers do
  @moduledoc false
  # Shared pure-Elixir helpers used by the SVG chart components.
  # Not registered in ComponentRegistry — internal only.

  @palette [
    "oklch(0.60 0.20 240)",
    "oklch(0.70 0.18 145)",
    "oklch(0.65 0.22 30)",
    "oklch(0.60 0.25 0)",
    "oklch(0.65 0.20 300)",
    "oklch(0.75 0.15 200)",
    "oklch(0.70 0.18 90)",
    "oklch(0.65 0.20 340)"
  ]

  @doc "Returns the default 8-color OKLCH categorical palette."
  def default_palette, do: @palette

  @doc "Returns the color at `idx` from `palette`, wrapping if needed. Falls back to built-in palette when empty."
  def chart_color(idx, []), do: Enum.at(@palette, rem(idx, 8))
  def chart_color(idx, pal), do: Enum.at(pal, rem(idx, max(length(pal), 1)))

  @doc """
  Normalizes the dual data/series API into a canonical series list.

  Single-series shorthand: `data: [%{label, value}]` → `[%{name: "Series 1", data: [...]}]`
  Multi-series: `series: [%{name, data: [...]}]` passed through unchanged.
  """
  def normalize_series([], []), do: []
  def normalize_series(data, []) when data != [], do: [%{name: "Series 1", data: data}]
  def normalize_series([], series), do: series
  def normalize_series(_data, series), do: series

  @doc """
  Converts a data series to an SVG polyline `points` string.

  - `data`   — list of `%{label, value}` maps
  - `x0,x1`  — pixel x range (left edge to right edge)
  - `y_min,y_max` — value range for the series
  - `px_top, px_bot` — pixel y range (top to bottom, bot > top in SVG)
  """
  def series_points([], _x0, _x1, _y_min, _y_max, _px_top, _px_bot), do: ""

  def series_points([_single], x0, x1, _y_min, _y_max, px_top, px_bot) do
    mid_x = (x0 + x1) / 2
    mid_y = (px_top + px_bot) / 2
    "#{Float.round(x0, 2)},#{Float.round(mid_y, 2)} #{Float.round(x1, 2)},#{Float.round(mid_y, 2)}"
    |> tap(fn _ -> _ = mid_x end)
  end

  def series_points(data, x0, x1, y_min, y_max, px_top, px_bot) do
    count = length(data)
    y_range = max(y_max - y_min, 1)
    px_range = px_bot - px_top

    data
    |> Enum.with_index()
    |> Enum.map_join(" ", fn {item, i} ->
      px_x = x0 + i / (count - 1) * (x1 - x0)
      px_y = px_bot - (item.value - y_min) / y_range * px_range
      "#{Float.round(px_x, 2)},#{Float.round(px_y, 2)}"
    end)
  end

  @doc """
  Computes the total arc length of a polyline points string.
  Returns 0.0 for empty or single-point strings.
  """
  def polyline_length(""), do: 0.0

  def polyline_length(points_str) do
    pts =
      points_str
      |> String.split(" ")
      |> Enum.map(fn pair ->
        [xs, ys] = String.split(pair, ",")
        {parse_float(xs), parse_float(ys)}
      end)

    pts
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.reduce(0.0, fn [{x1, y1}, {x2, y2}], acc ->
      acc + :math.sqrt(:math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2))
    end)
  end

  @doc """
  Computes SVG arc path slices for a pie chart.

  Returns a list of `%{path: string, color: string, delay: string}` maps.
  Starting angle: -pi/2 (top of circle).
  """
  def pie_slices(data, cx, cy, r, colors) when is_list(data) do
    total = data |> Enum.map(& &1.value) |> Enum.sum() |> max(1)
    start = -:math.pi() / 2

    {slices, _} =
      data
      |> Enum.with_index()
      |> Enum.map_reduce(start, fn {item, i}, acc_angle ->
        ratio = item.value / total
        sweep = ratio * 2 * :math.pi()
        end_angle = acc_angle + sweep

        path = arc_path(cx, cy, r, acc_angle, end_angle)
        color = Map.get(item, :color) || chart_color(i, colors)

        slice = %{
          path: path,
          color: color,
          delay: stagger_delay(i)
        }

        {slice, end_angle}
      end)

    slices
  end

  @doc """
  Computes SVG donut arc path slices.

  Same as `pie_slices/5` but with inner radius for the ring.
  """
  def donut_slices(data, cx, cy, r_outer, r_inner, colors) when is_list(data) do
    total = data |> Enum.map(& &1.value) |> Enum.sum() |> max(1)
    start = -:math.pi() / 2

    {slices, _} =
      data
      |> Enum.with_index()
      |> Enum.map_reduce(start, fn {item, i}, acc_angle ->
        ratio = item.value / total
        sweep = ratio * 2 * :math.pi()
        end_angle = acc_angle + sweep

        path = donut_arc_path(cx, cy, r_outer, r_inner, acc_angle, end_angle)
        color = Map.get(item, :color) || chart_color(i, colors)

        slice = %{
          path: path,
          color: color,
          delay: stagger_delay(i)
        }

        {slice, end_angle}
      end)

    slices
  end

  @doc """
  Bins a list of numeric values into `n` equal-width buckets.
  Returns `[%{label, value, from, to}]`.
  """
  def histogram_bins([], _n), do: []
  def histogram_bins(data, n) when n < 1, do: histogram_bins(data, 1)

  def histogram_bins(data, n) do
    min_v = Enum.min(data)
    max_v = Enum.max(data)
    range = if max_v == min_v, do: 1.0, else: (max_v - min_v) * 1.0
    bin_w = range / n

    Enum.map(0..(n - 1), fn i ->
      from = min_v + i * bin_w
      to = from + bin_w
      last? = i == n - 1
      count = Enum.count(data, fn v -> v >= from && (v < to || (last? && v <= to)) end)

      %{
        label: "#{Float.round(from * 1.0, 1)}-#{Float.round(to * 1.0, 1)}",
        value: count,
        from: from,
        to: to
      }
    end)
  end

  @doc "Returns an inline style string for staggered animation delay."
  def stagger_delay(idx, step_ms \\ 60) do
    "animation-delay: #{idx * step_ms}ms"
  end

  @doc "Squarify algorithm for treemap tile layout. Returns `[%{x, y, w, h, item}]`."
  def squarify(data, x, y, w, h) when is_list(data) do
    total = data |> Enum.map(& &1.value) |> Enum.sum() |> max(1)

    items =
      data
      |> Enum.sort_by(& &1.value, :desc)
      |> Enum.map(fn item ->
        Map.put(item, :ratio, item.value / total)
      end)

    do_squarify(items, x, y, w, h, [])
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp arc_path(cx, cy, r, a, b) do
    x1 = cx + r * :math.cos(a)
    y1 = cy + r * :math.sin(a)
    x2 = cx + r * :math.cos(b)
    y2 = cy + r * :math.sin(b)
    large = if b - a > :math.pi(), do: 1, else: 0

    [
      "M #{f(cx)} #{f(cy)}",
      "L #{f(x1)} #{f(y1)}",
      "A #{r} #{r} 0 #{large} 1 #{f(x2)} #{f(y2)}",
      "Z"
    ]
    |> Enum.join(" ")
  end

  defp donut_arc_path(cx, cy, r_out, r_in, a, b) do
    ox1 = cx + r_out * :math.cos(a)
    oy1 = cy + r_out * :math.sin(a)
    ox2 = cx + r_out * :math.cos(b)
    oy2 = cy + r_out * :math.sin(b)
    ix1 = cx + r_in * :math.cos(b)
    iy1 = cy + r_in * :math.sin(b)
    ix2 = cx + r_in * :math.cos(a)
    iy2 = cy + r_in * :math.sin(a)
    large = if b - a > :math.pi(), do: 1, else: 0

    [
      "M #{f(ox1)} #{f(oy1)}",
      "A #{r_out} #{r_out} 0 #{large} 1 #{f(ox2)} #{f(oy2)}",
      "L #{f(ix1)} #{f(iy1)}",
      "A #{r_in} #{r_in} 0 #{large} 0 #{f(ix2)} #{f(iy2)}",
      "Z"
    ]
    |> Enum.join(" ")
  end

  # Simple greedy squarify (not perfect squarify, but close enough for this use)
  defp do_squarify([], _x, _y, _w, _h, acc), do: Enum.reverse(acc)

  defp do_squarify(items, x, y, w, h, acc) do
    total_ratio = Enum.sum(Enum.map(items, & &1.ratio))

    if w >= h do
      # Lay out a column on the left
      col_w = w * total_ratio
      col_items = items
      tiles = layout_strip(col_items, x, y, col_w, h, :vertical)
      do_squarify([], x + col_w, y, w - col_w, h, Enum.reverse(tiles) ++ acc)
    else
      # Lay out a row on the top
      row_h = h * total_ratio
      row_items = items
      tiles = layout_strip(row_items, x, y, w, row_h, :horizontal)
      do_squarify([], x, y + row_h, w, h - row_h, Enum.reverse(tiles) ++ acc)
    end
  end

  defp layout_strip(items, x, y, w, h, :vertical) do
    total = items |> Enum.map(& &1.ratio) |> Enum.sum() |> max(0.001)

    {tiles, _} =
      Enum.map_reduce(items, y, fn item, cy ->
        tile_h = item.ratio / total * h
        tile = %{x: f(x), y: f(cy), w: f(w), h: f(tile_h), item: item}
        {tile, cy + tile_h}
      end)

    tiles
  end

  defp layout_strip(items, x, y, w, h, :horizontal) do
    total = items |> Enum.map(& &1.ratio) |> Enum.sum() |> max(0.001)

    {tiles, _} =
      Enum.map_reduce(items, x, fn item, cx ->
        tile_w = item.ratio / total * w
        tile = %{x: f(cx), y: f(y), w: f(tile_w), h: f(h), item: item}
        {tile, cx + tile_w}
      end)

    tiles
  end

  defp f(v), do: Float.round(v * 1.0, 2)

  defp parse_float(s) do
    case Float.parse(s) do
      {v, _} -> v
      :error -> 0.0
    end
  end
end
