defmodule PhiaUi.Components.Data.ChartHelpers do
  @moduledoc false
  # Shared pure-Elixir helpers used by the SVG chart components.
  # Not registered in ComponentRegistry — internal only.

  alias PhiaUi.Components.Data.ChartAxisHelpers

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
  Converts a data series to an SVG `<path d="...">` string using the specified curve mode.

  Curve modes:
  - `:linear` — straight line segments (same as `series_points/7` but as path)
  - `:smooth` — Catmull-Rom spline (smooth curves)
  - `:monotone` — monotone cubic interpolation (no overshoot)
  - `:step_before` / `:step_after` / `:step_middle` — stepped lines
  """
  def series_path([], _x0, _x1, _y_min, _y_max, _px_top, _px_bot, _curve), do: ""

  def series_path(data, x0, x1, y_min, y_max, px_top, px_bot, curve) do
    alias PhiaUi.Components.Data.ChartMathHelpers

    count = length(data)
    y_range = max(y_max - y_min, 1)
    px_range = px_bot - px_top

    points =
      data
      |> Enum.with_index()
      |> Enum.map(fn {item, i} ->
        px_x = x0 + i / max(count - 1, 1) * (x1 - x0)
        px_y = px_bot - (item.value - y_min) / y_range * px_range
        %{x: Float.round(px_x, 2), y: Float.round(px_y, 2)}
      end)

    case curve do
      :linear ->
        [first | rest] = points
        move = "M #{f(first.x)} #{f(first.y)}"
        lines = Enum.map_join(rest, " ", fn pt -> "L #{f(pt.x)} #{f(pt.y)}" end)
        "#{move} #{lines}"

      :smooth ->
        ChartMathHelpers.smooth_path(points, :smooth)

      :monotone ->
        ChartMathHelpers.smooth_path(points, :monotone)

      :step_before ->
        ChartMathHelpers.stepped_path(points, :before)

      :step_after ->
        ChartMathHelpers.stepped_path(points, :after)

      :step_middle ->
        ChartMathHelpers.stepped_path(points, :middle)
    end
  end

  @doc """
  Builds a closed area path for a data series with the specified curve mode.
  Closes the path down to `px_bot` (the x-axis baseline).
  """
  def series_area_path([], _x0, _x1, _y_min, _y_max, _px_top, _px_bot, _curve), do: ""

  def series_area_path(data, x0, x1, y_min, y_max, px_top, px_bot, curve) do
    alias PhiaUi.Components.Data.ChartMathHelpers

    count = length(data)
    y_range = max(y_max - y_min, 1)
    px_range = px_bot - px_top

    points =
      data
      |> Enum.with_index()
      |> Enum.map(fn {item, i} ->
        px_x = x0 + i / max(count - 1, 1) * (x1 - x0)
        px_y = px_bot - (item.value - y_min) / y_range * px_range
        %{x: Float.round(px_x, 2), y: Float.round(px_y, 2)}
      end)

    case curve do
      :linear ->
        line_part = Enum.map_join(points, " L ", fn pt -> "#{f(pt.x)} #{f(pt.y)}" end)
        first = List.first(points)
        last = List.last(points)
        "M #{f(first.x)} #{f(px_bot)} L #{line_part} L #{f(last.x)} #{f(px_bot)} Z"

      mode when mode in [:smooth, :monotone] ->
        ChartMathHelpers.smooth_area_path(points, mode, px_bot)

      step when step in [:step_before, :step_after, :step_middle] ->
        step_mode = step |> Atom.to_string() |> String.replace("step_", "") |> String.to_atom()
        ChartMathHelpers.stepped_area_path(points, step_mode, px_bot)
    end
  end

  @doc """
  Estimates the path length for a curved path (for stroke-dashoffset animation).
  For smooth curves, approximates by sampling the Bezier at intervals.
  For linear paths, falls back to polyline_length.
  """
  def path_length(""), do: 0.0

  def path_length(path_d) do
    # Extract all coordinate pairs from the path data
    coords =
      Regex.scan(~r/[MLCZ]\s*([\d.-]+)\s+([\d.-]+)/, path_d)
      |> Enum.map(fn [_, x, y] -> {parse_float(x), parse_float(y)} end)

    coords
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.reduce(0.0, fn [{x1, y1}, {x2, y2}], acc ->
      acc + :math.sqrt(:math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2))
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

  Options:
  - `spacing` — gap in pixels between slices (default 0). Implemented as angular
    offset proportional to radius, matching Chart.js ArcElement spacing pattern.
  """
  def pie_slices(data, cx, cy, r, colors, opts \\ []) when is_list(data) do
    spacing = Keyword.get(opts, :spacing, 0)
    total = data |> Enum.map(& &1.value) |> Enum.sum() |> max(1)
    start = -:math.pi() / 2

    # Angular gap per slice (spacing in pixels → radians at given radius)
    angle_gap = if spacing > 0 and r > 0, do: spacing / r, else: 0.0

    {slices, _} =
      data
      |> Enum.with_index()
      |> Enum.map_reduce(start, fn {item, i}, acc_angle ->
        ratio = item.value / total
        sweep = ratio * 2 * :math.pi()
        end_angle = acc_angle + sweep

        # Apply spacing: shrink each slice by half-gap on each side
        a = acc_angle + angle_gap / 2
        b = end_angle - angle_gap / 2

        path = if b > a, do: arc_path(cx, cy, r, a, b), else: arc_path(cx, cy, r, a, a + 0.001)
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

  Same as `pie_slices/6` but with inner radius for the ring.

  Options:
  - `spacing` — gap in pixels between slices (default 0).
  """
  def donut_slices(data, cx, cy, r_outer, r_inner, colors, opts \\ []) when is_list(data) do
    spacing = Keyword.get(opts, :spacing, 0)
    total = data |> Enum.map(& &1.value) |> Enum.sum() |> max(1)
    start = -:math.pi() / 2

    # Angular gap using mean radius for consistent visual spacing
    mean_r = (r_outer + r_inner) / 2
    angle_gap = if spacing > 0 and mean_r > 0, do: spacing / mean_r, else: 0.0

    {slices, _} =
      data
      |> Enum.with_index()
      |> Enum.map_reduce(start, fn {item, i}, acc_angle ->
        ratio = item.value / total
        sweep = ratio * 2 * :math.pi()
        end_angle = acc_angle + sweep

        a = acc_angle + angle_gap / 2
        b = end_angle - angle_gap / 2

        path =
          if b > a,
            do: donut_arc_path(cx, cy, r_outer, r_inner, a, b),
            else: donut_arc_path(cx, cy, r_outer, r_inner, a, a + 0.001)

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

  @doc """
  Computes a nice Y-domain (ticks + min/max) from a list of series.

  Returns `{y_ticks, y_min_nice, y_max_nice}`.

  Options:
  - `:min_override` — force a minimum value (default: 0)
  - `:tick_count` — target number of ticks (default: 5)
  - `:include_negative` — if false, clamp min to 0 (default: true)
  """
  def compute_y_domain(series, opts \\ []) do
    min_override = Keyword.get(opts, :min_override, nil)
    tick_count = Keyword.get(opts, :tick_count, 5)
    include_negative = Keyword.get(opts, :include_negative, true)

    all_values = Enum.flat_map(series, fn s -> Enum.map(s.data, & &1.value) end)

    y_max = if all_values == [], do: 10, else: Enum.max(all_values)

    y_min =
      cond do
        min_override != nil -> min_override
        !include_negative -> 0
        all_values == [] -> 0
        true -> min(0, Enum.min(all_values))
      end

    ticks = ChartAxisHelpers.nice_ticks(y_min, max(y_max, 1), tick_count)
    {ticks, Enum.min(ticks), Enum.max(ticks)}
  end

  @doc """
  Computes Y-domain for stacked bar/area charts by summing per-group.

  Returns `{y_ticks, y_max_nice}`.
  """
  def compute_stacked_y_domain(series, opts \\ []) do
    tick_count = Keyword.get(opts, :tick_count, 5)
    n_groups = series |> List.first(%{data: []}) |> Map.get(:data, []) |> length()

    sums =
      if n_groups == 0 do
        []
      else
        Enum.map(0..(n_groups - 1), fn g ->
          Enum.reduce(series, 0, fn s, acc ->
            v = s.data |> Enum.at(g) |> then(&if(&1, do: &1.value, else: 0))
            acc + v
          end)
        end)
      end

    y_max = if sums == [], do: 10, else: Enum.max(sums)
    ticks = ChartAxisHelpers.nice_ticks(0, max(y_max, 1), tick_count)
    {ticks, Enum.max(ticks)}
  end

  @doc """
  Extracts unique category labels from a series list.

  Returns a list of label strings from the first series.
  """
  def extract_categories(series) do
    series
    |> List.first(%{data: []})
    |> Map.get(:data, [])
    |> Enum.map(& &1.label)
  end

  @doc """
  Extracts all numeric values from all series into a flat list.
  """
  def extract_all_values(series) do
    Enum.flat_map(series, fn s -> Enum.map(s.data, & &1.value) end)
  end

  @doc """
  Computes descriptive statistics for each series.

  Delegates to `ChartPipeline.series_stats/1`.

  Returns `[%{name: string, stats: %{min, max, mean, median, sum, count, std_dev}}]`.
  """
  def series_stats(series) do
    alias PhiaUi.Components.Data.ChartPipeline
    ChartPipeline.series_stats(series)
  end

  @doc """
  Builds an SVG path with per-segment styling.
  Each segment is `%{start: idx, end: idx, color: string, dash: string | nil}`.
  Returns a list of `%{path_d, color, dash}` for rendering as separate `<path>` elements.
  """
  def segment_path(data, segments, {x0, x1, y_min, y_max, px_top, px_bot}) do
    count = length(data)
    y_range = max(y_max - y_min, 1)
    px_range = px_bot - px_top

    points =
      data
      |> Enum.with_index()
      |> Enum.map(fn {item, i} ->
        px_x = x0 + i / max(count - 1, 1) * (x1 - x0)
        px_y = px_bot - (item.value - y_min) / y_range * px_range
        %{x: Float.round(px_x, 2), y: Float.round(px_y, 2)}
      end)

    Enum.map(segments, fn seg ->
      slice = Enum.slice(points, seg.start..min(seg.end, length(points) - 1))

      path_d =
        case slice do
          [] -> ""
          [single] -> "M #{f(single.x)} #{f(single.y)}"
          [first | rest] ->
            move = "M #{f(first.x)} #{f(first.y)}"
            lines = Enum.map_join(rest, " ", fn pt -> "L #{f(pt.x)} #{f(pt.y)}" end)
            "#{move} #{lines}"
        end

      %{path_d: path_d, color: Map.get(seg, :color, "currentColor"), dash: Map.get(seg, :dash)}
    end)
  end

  @doc """
  Sorts data descending by value and computes cumulative percentages.
  Returns `{sorted_data, cumulative_percentages}` where percentages are 0-100.
  """
  def pareto_cumulative(data) when is_list(data) do
    sorted = Enum.sort_by(data, & &1.value, :desc)
    total = sorted |> Enum.map(& &1.value) |> Enum.sum() |> max(1)

    {pcts, _} =
      Enum.map_reduce(sorted, 0.0, fn item, acc ->
        new_acc = acc + item.value
        {Float.round(new_acc / total * 100.0, 2), new_acc}
      end)

    {sorted, pcts}
  end

  @doc "Returns a 10-color perceptually distinct OKLCH categorical palette."
  def categorical_10 do
    [
      "oklch(0.60 0.20 240)",   # blue
      "oklch(0.70 0.18 145)",   # green
      "oklch(0.65 0.22 30)",    # orange
      "oklch(0.60 0.25 0)",     # red
      "oklch(0.65 0.20 300)",   # purple
      "oklch(0.75 0.15 200)",   # teal
      "oklch(0.70 0.18 90)",    # yellow-green
      "oklch(0.65 0.20 340)",   # pink
      "oklch(0.55 0.22 270)",   # indigo
      "oklch(0.72 0.16 60)"    # amber
    ]
  end

  @doc """
  Generates a sequential color palette (single hue gradient) with `n` steps.
  `hue` is the OKLCH hue angle (0-360).
  """
  def sequential(hue, n) when n > 0 do
    Enum.map(0..(n - 1), fn i ->
      lightness = 0.35 + i / max(n - 1, 1) * 0.50
      chroma = 0.20 - i / max(n - 1, 1) * 0.10
      "oklch(#{Float.round(lightness, 2)} #{Float.round(chroma, 2)} #{hue})"
    end)
  end

  @doc """
  Generates a diverging color palette with neutral midpoint.
  `hue_low` and `hue_high` are OKLCH hue angles, `n` is total steps (should be odd).
  """
  def diverging(hue_low, hue_high, n) when n > 0 do
    mid = div(n, 2)

    Enum.map(0..(n - 1), fn i ->
      if i == mid do
        "oklch(0.90 0.02 0)"
      else
        if i < mid do
          t = i / max(mid, 1)
          lightness = 0.45 + t * 0.40
          chroma = 0.22 - t * 0.18
          "oklch(#{Float.round(lightness, 2)} #{Float.round(chroma, 2)} #{hue_low})"
        else
          t = (i - mid) / max(n - 1 - mid, 1)
          lightness = 0.85 - t * 0.40
          chroma = 0.04 + t * 0.18
          "oklch(#{Float.round(lightness, 2)} #{Float.round(chroma, 2)} #{hue_high})"
        end
      end
    end)
  end

  @doc """
  Recomputes a pie arc path with a larger radius for hover/active state.

  Given original pie parameters, returns a new SVG path with radius expanded
  by `expand` pixels. Used by `chart_active_shape` for sector hover effects.
  """
  def expand_arc_path(cx, cy, r, a, b, expand) do
    r_expanded = r + expand
    arc_path_public(cx, cy, r_expanded, a, b)
  end

  @doc """
  Recomputes a donut arc path with outer radius expanded for hover state.
  """
  def expand_donut_arc_path(cx, cy, r_out, r_in, a, b, expand) do
    donut_arc_path_public(cx, cy, r_out + expand, r_in, a, b)
  end

  # Public wrappers for arc path generation (used by expand functions)
  defp arc_path_public(cx, cy, r, a, b) do
    x1 = cx + r * :math.cos(a)
    y1 = cy + r * :math.sin(a)
    x2 = cx + r * :math.cos(b)
    y2 = cy + r * :math.sin(b)
    large = if b - a > :math.pi(), do: 1, else: 0

    [
      "M #{f(cx)} #{f(cy)}",
      "L #{f(x1)} #{f(y1)}",
      "A #{r + 0.0} #{r + 0.0} 0 #{large} 1 #{f(x2)} #{f(y2)}",
      "Z"
    ]
    |> Enum.join(" ")
  end

  defp donut_arc_path_public(cx, cy, r_out, r_in, a, b) do
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
      "A #{r_out + 0.0} #{r_out + 0.0} 0 #{large} 1 #{f(ox2)} #{f(oy2)}",
      "L #{f(ix1)} #{f(iy1)}",
      "A #{r_in + 0.0} #{r_in + 0.0} 0 #{large} 0 #{f(ix2)} #{f(iy2)}",
      "Z"
    ]
    |> Enum.join(" ")
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
