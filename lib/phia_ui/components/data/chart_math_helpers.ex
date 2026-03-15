defmodule PhiaUi.Components.Data.ChartMathHelpers do
  @moduledoc false
  # Mathematical helpers ported from Chart.js for advanced SVG chart rendering.
  # Provides: Bezier curves, monotone interpolation, stepped lines,
  # polar-to-cartesian conversion, LTTB decimation, and stacking utilities.
  # Not registered in ComponentRegistry — internal only.

  # ---------------------------------------------------------------------------
  # Bezier / Spline Interpolation
  # ---------------------------------------------------------------------------

  @doc """
  Computes Catmull-Rom cubic Bezier control points for a smooth curve through
  a list of `{x, y}` coordinate pairs.

  Returns a list of `%{x, y, cp1x, cp1y, cp2x, cp2y}` maps suitable for
  building SVG `C` (cubic Bezier) path commands.

  `tension` controls curve smoothness: 0.0 = straight lines, 0.4 = default smooth.
  """
  def bezier_control_points(points, tension \\ 0.4)
  def bezier_control_points([], _tension), do: []
  def bezier_control_points([single], _tension), do: [Map.merge(single, %{cp1x: single.x, cp1y: single.y, cp2x: single.x, cp2y: single.y})]

  def bezier_control_points(points, tension) when is_list(points) do
    n = length(points)
    indexed = Enum.with_index(points)

    Enum.map(indexed, fn {pt, i} ->
      prev = if i > 0, do: Enum.at(points, i - 1), else: pt
      next = if i < n - 1, do: Enum.at(points, i + 1), else: pt

      # Distance-weighted Catmull-Rom tangent
      d01 = distance(prev, pt)
      d12 = distance(pt, next)
      total_d = d01 + d12

      s01 = if total_d > 0, do: d01 / total_d, else: 0.5
      s12 = if total_d > 0, do: d12 / total_d, else: 0.5

      dx = next.x - prev.x
      dy = next.y - prev.y

      %{
        x: pt.x,
        y: pt.y,
        cp1x: pt.x - dx * tension * s01,
        cp1y: pt.y - dy * tension * s01,
        cp2x: pt.x + dx * tension * s12,
        cp2y: pt.y + dy * tension * s12
      }
    end)
  end

  @doc """
  Computes monotone cubic control points that prevent overshoot.

  Based on Chart.js `splineCurveMonotone()` — ensures the interpolated curve
  respects the monotonicity of the data (no local extrema between data points).

  Input: list of `%{x, y}` maps. Returns list with added `cp1x/cp1y/cp2x/cp2y`.
  """
  def monotone_control_points([]), do: []
  def monotone_control_points([single]), do: [Map.merge(single, %{cp1x: single.x, cp1y: single.y, cp2x: single.x, cp2y: single.y})]

  def monotone_control_points(points) when is_list(points) do
    n = length(points)
    if n < 2, do: points

    # Step 1: compute slopes (delta_k) between consecutive points
    deltas =
      points
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [p1, p2] ->
        dx = p2.x - p1.x
        if dx != 0, do: (p2.y - p1.y) / dx, else: 0.0
      end)

    # Step 2: compute tangents (m_k) — average of adjacent slopes
    tangents =
      Enum.map(0..(n - 1), fn i ->
        cond do
          i == 0 -> Enum.at(deltas, 0, 0.0)
          i == n - 1 -> Enum.at(deltas, i - 1, 0.0)
          true ->
            d_prev = Enum.at(deltas, i - 1, 0.0)
            d_curr = Enum.at(deltas, i, 0.0)
            # If signs differ, tangent is 0 (prevents overshoot)
            if d_prev * d_curr <= 0, do: 0.0, else: (d_prev + d_curr) / 2
        end
      end)

    # Step 3: adjust tangents to ensure monotonicity (Fritsch-Carlson method)
    adjusted =
      Enum.reduce(0..(length(deltas) - 1), tangents, fn i, acc ->
        dk = Enum.at(deltas, i, 0.0)

        if dk == 0 do
          acc
          |> List.replace_at(i, 0.0)
          |> List.replace_at(i + 1, 0.0)
        else
          mk = Enum.at(acc, i, 0.0)
          mk1 = Enum.at(acc, i + 1, 0.0)
          alpha = mk / dk
          beta = mk1 / dk

          # Clamp to maintain monotonicity
          s = alpha * alpha + beta * beta

          if s > 9.0 do
            t = 3.0 / :math.sqrt(s)

            acc
            |> List.replace_at(i, t * alpha * dk)
            |> List.replace_at(i + 1, t * beta * dk)
          else
            acc
          end
        end
      end)

    # Step 4: compute control points from tangents
    points
    |> Enum.with_index()
    |> Enum.map(fn {pt, i} ->
      m = Enum.at(adjusted, i, 0.0)

      # Distance to neighbors for control point placement
      dx_prev = if i > 0, do: (pt.x - Enum.at(points, i - 1).x) / 3, else: 0.0
      dx_next = if i < n - 1, do: (Enum.at(points, i + 1).x - pt.x) / 3, else: 0.0

      %{
        x: pt.x,
        y: pt.y,
        cp1x: pt.x - dx_prev,
        cp1y: pt.y - m * dx_prev,
        cp2x: pt.x + dx_next,
        cp2y: pt.y + m * dx_next
      }
    end)
  end

  # ---------------------------------------------------------------------------
  # SVG Path Builders
  # ---------------------------------------------------------------------------

  @doc """
  Builds an SVG `d` attribute string for a smooth curve through points.

  `mode` is `:smooth` (Catmull-Rom) or `:monotone` (monotone cubic).
  Points is a list of `%{x, y}`.

  Returns a string like `"M 10 20 C 12 18 14 22 16 24 C ..."`.
  """
  def smooth_path([], _mode), do: ""
  def smooth_path([%{x: x, y: y}], _mode), do: "M #{f(x)} #{f(y)}"

  def smooth_path(points, mode) when mode in [:smooth, :monotone] do
    ctrl =
      case mode do
        :smooth -> bezier_control_points(points, 0.4)
        :monotone -> monotone_control_points(points)
      end

    [first | rest] = ctrl

    move = "M #{f(first.x)} #{f(first.y)}"

    curves =
      rest
      |> Enum.with_index(1)
      |> Enum.map_join(" ", fn {pt, i} ->
        prev = Enum.at(ctrl, i - 1)
        "C #{f(prev.cp2x)} #{f(prev.cp2y)} #{f(pt.cp1x)} #{f(pt.cp1y)} #{f(pt.x)} #{f(pt.y)}"
      end)

    "#{move} #{curves}"
  end

  @doc """
  Builds an SVG `d` attribute string for a stepped line.

  `step` is `:before`, `:middle`, or `:after`:
  - `:before` — vertical first, then horizontal (value changes at start)
  - `:after` — horizontal first, then vertical (value changes at end)
  - `:middle` — horizontal to midpoint, vertical, then horizontal to end
  """
  def stepped_path([], _step), do: ""
  def stepped_path([%{x: x, y: y}], _step), do: "M #{f(x)} #{f(y)}"

  def stepped_path(points, step) when step in [:before, :middle, :after] do
    [first | rest] = points
    move = "M #{f(first.x)} #{f(first.y)}"

    segments =
      rest
      |> Enum.with_index(1)
      |> Enum.map_join(" ", fn {pt, i} ->
        prev = Enum.at(points, i - 1)

        case step do
          :before ->
            "L #{f(prev.x)} #{f(pt.y)} L #{f(pt.x)} #{f(pt.y)}"

          :after ->
            "L #{f(pt.x)} #{f(prev.y)} L #{f(pt.x)} #{f(pt.y)}"

          :middle ->
            mid_x = (prev.x + pt.x) / 2
            "L #{f(mid_x)} #{f(prev.y)} L #{f(mid_x)} #{f(pt.y)} L #{f(pt.x)} #{f(pt.y)}"
        end
      end)

    "#{move} #{segments}"
  end

  @doc """
  Builds an SVG `d` attribute string for a closed area under a smooth curve.

  Like `smooth_path/2` but closes the path to the baseline for area fills.
  `baseline_y` is the Y pixel position of the x-axis (bottom of chart).
  """
  def smooth_area_path([], _mode, _baseline_y), do: ""

  def smooth_area_path(points, mode, baseline_y) do
    curve_d = smooth_path(points, mode)
    first = List.first(points)
    last = List.last(points)

    "#{curve_d} L #{f(last.x)} #{f(baseline_y)} L #{f(first.x)} #{f(baseline_y)} Z"
  end

  @doc """
  Builds a closed area path for a stepped line.
  """
  def stepped_area_path([], _step, _baseline_y), do: ""

  def stepped_area_path(points, step, baseline_y) do
    line_d = stepped_path(points, step)
    first = List.first(points)
    last = List.last(points)

    "#{line_d} L #{f(last.x)} #{f(baseline_y)} L #{f(first.x)} #{f(baseline_y)} Z"
  end

  # ---------------------------------------------------------------------------
  # Polar / Trigonometric Utilities
  # ---------------------------------------------------------------------------

  @doc """
  Converts polar coordinates (radius, angle) to cartesian (x, y) centered at (cx, cy).
  Angle is in radians. 0 = right, π/2 = down (SVG coordinate system).
  """
  def polar_to_cartesian(r, angle, cx, cy) do
    {cx + r * :math.cos(angle), cy + r * :math.sin(angle)}
  end

  @doc """
  Returns the angle in radians between the positive x-axis and the line from
  (cx, cy) to (px, py). Result is in range [-π, π].
  """
  def angle_from_point(cx, cy, px, py), do: :math.atan2(py - cy, px - cx)

  @doc """
  Checks if `angle` falls between `start_angle` and `end_angle` (radians).
  All angles are normalized to [0, 2π] before comparison.
  """
  def angle_between?(angle, start_angle, end_angle) do
    a = normalize_angle(angle)
    s = normalize_angle(start_angle)
    e = normalize_angle(end_angle)

    if s <= e do
      a >= s and a <= e
    else
      a >= s or a <= e
    end
  end

  @doc """
  Normalizes an angle to [0, 2π).
  """
  def normalize_angle(angle) do
    tau = 2 * :math.pi()
    a = :math.fmod(angle, tau)
    if a < 0, do: a + tau, else: a
  end

  # ---------------------------------------------------------------------------
  # Data Decimation — LTTB (Largest Triangle Three Buckets)
  # ---------------------------------------------------------------------------

  @doc """
  Reduces a list of `%{x, y}` (or `%{label, value}`) data points to `target`
  points using the Largest Triangle Three Buckets algorithm.

  Preserves the visual shape of the data better than uniform sampling.
  First and last points are always kept.

  Returns the decimated list.
  """
  def decimate_lttb(data, target) when length(data) <= target, do: data
  def decimate_lttb([], _target), do: []
  def decimate_lttb(data, target) when target < 3, do: [List.first(data), List.last(data)]

  def decimate_lttb(data, target) do
    n = length(data)
    # Normalize data to {x, y} tuples
    indexed = Enum.map(data, &to_xy/1)

    # Always keep first and last
    first = hd(indexed)
    last = List.last(indexed)

    # Bucket size for middle points
    bucket_size = (n - 2) / (target - 2)

    {selected, _prev} =
      Enum.reduce(1..(target - 2), {[first], first}, fn i, {acc, prev_selected} ->
        # Current bucket range
        bucket_start = round(1 + (i - 1) * bucket_size)
        bucket_end = min(round(1 + i * bucket_size), n - 1) - 1

        # Next bucket average (for triangle area calculation)
        next_start = min(round(1 + i * bucket_size), n - 1)
        next_end = min(round(1 + (i + 1) * bucket_size), n) - 1

        next_avg = bucket_average(indexed, next_start, next_end)

        # Find point in current bucket with largest triangle area
        best =
          bucket_start..bucket_end
          |> Enum.map(fn j ->
            pt = Enum.at(indexed, j)
            area = triangle_area(prev_selected, pt, next_avg)
            {area, pt, j}
          end)
          |> Enum.max_by(fn {area, _pt, _j} -> area end)

        {_area, selected_pt, _j} = best
        {acc ++ [selected_pt], selected_pt}
      end)

    result = selected ++ [last]

    # Map back to original format if needed
    if match?(%{label: _, value: _}, hd(data)) do
      Enum.map(result, fn %{x: x, y: y} -> %{label: x, value: y} end)
    else
      Enum.map(result, fn %{x: x, y: y} -> %{x: x, y: y} end)
    end
  end

  # ---------------------------------------------------------------------------
  # Stacking Utilities
  # ---------------------------------------------------------------------------

  @doc """
  Computes cumulative stacking for a list of series.

  Input: `[%{name, data: [%{label, value}]}]`
  Returns: `[%{name, data: [%{label, value, base}]}]`

  Each data point gets a `:base` field representing the cumulative sum of
  all previous series at that index. Useful for stacked area/bar charts.
  """
  def stack_series([]), do: []

  def stack_series(series) do
    n = series |> List.first() |> Map.get(:data, []) |> length()
    initial_base = List.duplicate(0.0, n)

    {stacked, _} =
      Enum.map_reduce(series, initial_base, fn s, cumulative ->
        data_with_base =
          s.data
          |> Enum.with_index()
          |> Enum.map(fn {item, i} ->
            base = Enum.at(cumulative, i, 0.0)
            Map.put(item, :base, base)
          end)

        new_cumulative =
          Enum.with_index(s.data)
          |> Enum.map(fn {item, i} ->
            Enum.at(cumulative, i, 0.0) + (item.value || 0)
          end)

        {%{s | data: data_with_base}, new_cumulative}
      end)

    stacked
  end

  # ---------------------------------------------------------------------------
  # Logarithmic Scale
  # ---------------------------------------------------------------------------

  @doc """
  Generates logarithmic tick values for a range [min, max].

  Returns ticks at powers of 10 and optional intermediate values (2, 5).
  `min` must be > 0 (log scale doesn't support zero or negative values).
  """
  def log_ticks(min, max, _opts \\ []) when min > 0 and max > min do
    start_exp = Float.floor(:math.log10(min))
    end_exp = Float.ceil(:math.log10(max))

    # Generate ticks at 1, 2, 5 × 10^n pattern
    exp_range = trunc(start_exp)..trunc(end_exp)

    ticks =
      Enum.flat_map(exp_range, fn exp ->
        base = :math.pow(10, exp)
        [1.0, 2.0, 5.0]
        |> Enum.map(fn mult -> Float.round(mult * base, 10) end)
        |> Enum.filter(fn v -> v >= min and v <= max end)
      end)

    # Ensure min and max are included
    ticks = if hd(ticks) != min, do: [min | ticks], else: ticks
    ticks = if List.last(ticks) != max, do: ticks ++ [max], else: ticks

    Enum.uniq(ticks)
  end

  @doc """
  Maps a value to a pixel position on a logarithmic scale.

  Returns a value in the range [px_start, px_end].
  """
  def log_pixel(value, data_min, data_max, px_start, px_end) when value > 0 and data_min > 0 do
    log_min = :math.log10(data_min)
    log_max = :math.log10(data_max)
    log_val = :math.log10(value)
    ratio = (log_val - log_min) / max(log_max - log_min, 1.0e-10)
    px_start + ratio * (px_end - px_start)
  end

  # ---------------------------------------------------------------------------
  # Easing Functions (subset from Chart.js for JS hook animations)
  # ---------------------------------------------------------------------------

  @doc "Ease-out cubic: decelerating to zero velocity."
  def ease_out_cubic(t), do: 1 - :math.pow(1 - t, 3)

  @doc "Ease-in-out cubic: acceleration until halfway, then deceleration."
  def ease_in_out_cubic(t) do
    if t < 0.5, do: 4 * t * t * t, else: 1 - :math.pow(-2 * t + 2, 3) / 2
  end

  @doc "Ease-out elastic: exponentially decaying sine wave."
  def ease_out_elastic(t) when t == 0.0, do: 0.0
  def ease_out_elastic(t) when t == 1.0, do: 1.0

  def ease_out_elastic(t) do
    c4 = 2 * :math.pi() / 3
    :math.pow(2, -10 * t) * :math.sin((t * 10 - 0.75) * c4) + 1
  end

  # ---------------------------------------------------------------------------
  # Quartiles / Box-Plot Statistics
  # ---------------------------------------------------------------------------

  @doc """
  Computes quartile statistics from a list of numeric values.
  Returns `%{q1, median, q3, iqr, whisker_low, whisker_high, outliers}`.
  """
  def quartiles([]), do: %{q1: 0, median: 0, q3: 0, iqr: 0, whisker_low: 0, whisker_high: 0, outliers: []}

  def quartiles(values) when is_list(values) do
    sorted = Enum.sort(values)
    n = length(sorted)
    median = percentile(sorted, n, 0.5)
    q1 = percentile(sorted, n, 0.25)
    q3 = percentile(sorted, n, 0.75)
    iqr = q3 - q1
    fence_low = q1 - 1.5 * iqr
    fence_high = q3 + 1.5 * iqr
    whisker_low = sorted |> Enum.filter(&(&1 >= fence_low)) |> List.first(q1)
    whisker_high = sorted |> Enum.filter(&(&1 <= fence_high)) |> List.last(q3)
    outliers = Enum.filter(sorted, fn v -> v < fence_low or v > fence_high end)

    %{
      q1: q1 * 1.0,
      median: median * 1.0,
      q3: q3 * 1.0,
      iqr: iqr * 1.0,
      whisker_low: whisker_low * 1.0,
      whisker_high: whisker_high * 1.0,
      outliers: outliers
    }
  end

  # ---------------------------------------------------------------------------
  # Kernel Density Estimation (Gaussian KDE)
  # ---------------------------------------------------------------------------

  @doc """
  Computes a Gaussian kernel density estimate over `n_points` points.
  Uses Silverman's rule of thumb for bandwidth when `bandwidth` is nil.
  Returns `[%{x: float, y: float}]`.
  """
  def kernel_density(values, n_points \\ 100, bandwidth \\ nil)
  def kernel_density([], _n_points, _bandwidth), do: []

  def kernel_density(values, n_points, bandwidth) when is_list(values) do
    sorted = Enum.sort(values)
    n = length(sorted)
    min_v = hd(sorted)
    max_v = List.last(sorted)
    range = max(max_v - min_v, 1.0e-10)

    # Silverman's rule of thumb
    h = bandwidth || silverman_bandwidth(sorted, n)
    h = max(h, 1.0e-10)

    # Generate evaluation points with some padding
    pad = range * 0.1
    step = (range + 2 * pad) / max(n_points - 1, 1)

    Enum.map(0..(n_points - 1), fn i ->
      x = (min_v - pad) + i * step
      density = Enum.reduce(sorted, 0.0, fn xi, acc ->
        u = (x - xi) / h
        acc + :math.exp(-0.5 * u * u) / :math.sqrt(2 * :math.pi())
      end) / (n * h)

      %{x: Float.round(x, 4), y: Float.round(density, 6)}
    end)
  end

  # ---------------------------------------------------------------------------
  # Sunburst Chart Layout
  # ---------------------------------------------------------------------------

  @doc """
  Recursively allocates angular arcs for a sunburst chart.
  Input: hierarchical data `[%{label, value, children: [...]}]`.
  Returns flat list of `%{label, value, depth, start_angle, end_angle, inner_r, outer_r}`.
  """
  def sunburst_arcs(data, opts \\ [])
  def sunburst_arcs([], _opts), do: []

  def sunburst_arcs(data, opts) when is_list(data) do
    ring_width = Keyword.get(opts, :ring_width, 30)
    inner_radius = Keyword.get(opts, :inner_radius, 40)
    total = sum_values(data)
    start = -:math.pi() / 2

    do_sunburst_arcs(data, 0, start, start + 2 * :math.pi(), total, ring_width, inner_radius, [])
    |> Enum.reverse()
  end

  # ---------------------------------------------------------------------------
  # Sankey Diagram Layout
  # ---------------------------------------------------------------------------

  @doc """
  Computes a simplified Sankey diagram layout.
  Input: `%{nodes: [%{id, label}], links: [%{source, target, value}]}`, width, height.
  Returns `%{nodes: [%{id, label, x, y, width, height}], links: [%{path, color, width}]}`.
  """
  def sankey_layout(graph, width, height) do
    nodes = graph.nodes
    links = graph.links
    node_width = 16
    node_padding = 8

    # Assign columns via BFS from sources
    source_ids = MapSet.new(Enum.map(links, & &1.source))
    target_ids = MapSet.new(Enum.map(links, & &1.target))
    pure_sources = MapSet.difference(source_ids, target_ids)

    columns = assign_columns(nodes, links, pure_sources)
    max_col = columns |> Map.values() |> Enum.max(fn -> 0 end)

    # Position nodes within columns
    col_x = fn col -> col / max(max_col, 1) * (width - node_width) end

    # Group nodes by column
    by_column = Enum.group_by(nodes, fn n -> Map.get(columns, n.id, 0) end)

    # Compute node values (sum of incoming or outgoing links, whichever is larger)
    node_values = compute_node_values(nodes, links)

    positioned_nodes =
      Enum.flat_map(by_column, fn {col, col_nodes} ->
        total_value = col_nodes |> Enum.map(fn n -> Map.get(node_values, n.id, 1) end) |> Enum.sum()
        usable_height = height - (length(col_nodes) - 1) * node_padding
        y_offset = 0.0

        {result, _} =
          Enum.map_reduce(col_nodes, y_offset, fn n, y_acc ->
            v = Map.get(node_values, n.id, 1)
            h = max(v / max(total_value, 1) * usable_height, 4.0)
            node = Map.merge(n, %{x: Float.round(col_x.(col), 2), y: Float.round(y_acc, 2), width: node_width, height: Float.round(h, 2)})
            {node, y_acc + h + node_padding}
          end)

        result
      end)

    node_map = Map.new(positioned_nodes, fn n -> {n.id, n} end)

    # Build cubic bezier link paths
    positioned_links =
      links
      |> compute_link_offsets(node_map)
      |> Enum.map(fn link ->
        source = Map.get(node_map, link.source)
        target = Map.get(node_map, link.target)
        link_value = link.value
        total_source = Map.get(node_values, link.source, 1)
        total_target = Map.get(node_values, link.target, 1)
        source_h = source.height * link_value / max(total_source, 1)
        target_h = target.height * link_value / max(total_target, 1)
        sy = source.y + Map.get(link, :source_offset, 0.0)
        ty = target.y + Map.get(link, :target_offset, 0.0)
        sx = source.x + node_width
        tx = target.x
        mid_x = (sx + tx) / 2

        path = "M #{f(sx)} #{f(sy)} C #{f(mid_x)} #{f(sy)} #{f(mid_x)} #{f(ty)} #{f(tx)} #{f(ty)} " <>
               "L #{f(tx)} #{f(ty + target_h)} C #{f(mid_x)} #{f(ty + target_h)} #{f(mid_x)} #{f(sy + source_h)} #{f(sx)} #{f(sy + source_h)} Z"

        %{path: path, value: link_value, width: Float.round((source_h + target_h) / 2, 2), source: link.source, target: link.target}
      end)

    %{nodes: positioned_nodes, links: positioned_links}
  end

  # ---------------------------------------------------------------------------
  # Circle Packing
  # ---------------------------------------------------------------------------

  @doc """
  Packs circles within a bounding circle using a simple packing algorithm.
  Input: `[%{label, value}]`, radius of bounding circle.
  Returns `[%{label, value, cx, cy, r}]`.
  """
  def pack_circles(data, bounding_radius) when is_list(data) do
    total = data |> Enum.map(& &1.value) |> Enum.sum() |> max(1)
    area = :math.pi() * bounding_radius * bounding_radius

    items =
      data
      |> Enum.sort_by(& &1.value, :desc)
      |> Enum.map(fn item ->
        r = :math.sqrt(item.value / total * area / :math.pi()) * 0.85
        Map.put(item, :r, Float.round(r, 2))
      end)

    # Place circles using spiral placement
    place_circles_spiral(items, bounding_radius)
  end

  # ---------------------------------------------------------------------------
  # Chord Diagram Layout
  # ---------------------------------------------------------------------------

  @doc """
  Computes chord diagram layout from an adjacency matrix.
  Input: `matrix` (list of lists), `labels` (list of strings).
  Returns `%{arcs: [%{label, start_angle, end_angle, value}], ribbons: [%{source_arc, target_arc, value}]}`.
  """
  def chord_layout(matrix, labels) when is_list(matrix) and is_list(labels) do
    n = length(labels)
    row_sums = Enum.map(matrix, &Enum.sum/1)
    total = Enum.sum(row_sums) |> max(1)
    gap = :math.pi() * 2 * 0.02
    available = :math.pi() * 2 - n * gap
    start = -:math.pi() / 2

    {arcs, _} =
      Enum.map_reduce(Enum.zip(labels, row_sums) |> Enum.with_index(), start, fn {{label, sum}, _i}, angle ->
        sweep = sum / total * available
        arc = %{label: label, start_angle: angle, end_angle: angle + sweep, value: sum}
        {arc, angle + sweep + gap}
      end)

    # Build ribbons from matrix cells
    ribbons =
      for {row, i} <- Enum.with_index(matrix),
          {val, j} <- Enum.with_index(row),
          val > 0 and i <= j do
        %{
          source: Enum.at(labels, i),
          target: Enum.at(labels, j),
          value: val,
          source_arc: Enum.at(arcs, i),
          target_arc: Enum.at(arcs, j)
        }
      end

    %{arcs: arcs, ribbons: ribbons}
  end

  # ---------------------------------------------------------------------------
  # Stream Graph / Wiggle Baseline
  # ---------------------------------------------------------------------------

  @doc """
  Computes wiggle baseline offsets for a stream graph.
  Minimizes weighted change in slope (Lee Byron's streamgraph algorithm).
  Input: stacked series `[%{name, data: [%{label, value}]}]`.
  Returns: list of baseline offsets per data point.
  """
  def wiggle_baseline(series) when is_list(series) do
    n_points = series |> List.first(%{data: []}) |> Map.get(:data, []) |> length()
    n_series = length(series)

    if n_points == 0 or n_series == 0 do
      []
    else
      # Sum all values at each point
      totals = Enum.map(0..(n_points - 1), fn i ->
        Enum.reduce(series, 0.0, fn s, acc ->
          acc + (Enum.at(s.data, i) || %{value: 0}).value
        end)
      end)

      # Wiggle offset: center the stack
      Enum.map(totals, fn t -> -t / 2.0 end)
    end
  end

  # ---------------------------------------------------------------------------
  # Word Cloud Layout
  # ---------------------------------------------------------------------------

  @doc """
  Lays out words using Archimedean spiral placement with simple collision detection.
  Input: `[%{text, value}]`, `%{width, height}`.
  Returns: `[%{text, value, x, y, font_size, rotation}]`.
  """
  def word_cloud_layout(words, dims) when is_list(words) do
    max_value = words |> Enum.map(& &1.value) |> Enum.max(fn -> 1 end)
    min_value = words |> Enum.map(& &1.value) |> Enum.min(fn -> 1 end)
    value_range = max(max_value - min_value, 1)

    sorted = Enum.sort_by(words, & &1.value, :desc)
    cx = dims.width / 2
    cy = dims.height / 2

    {placed, _} =
      Enum.map_reduce(sorted, [], fn word, placed_acc ->
        font_size = 12 + (word.value - min_value) / value_range * 36
        rotation = if :rand.uniform() > 0.7, do: -90, else: 0
        # Estimate text bounding box
        char_width = font_size * 0.6
        text_w = String.length(word.text) * char_width
        text_h = font_size * 1.2

        # Archimedean spiral search
        {x, y} = spiral_place(cx, cy, text_w, text_h, placed_acc, dims)

        entry = %{
          text: word.text,
          value: word.value,
          x: Float.round(x, 2),
          y: Float.round(y, 2),
          font_size: Float.round(font_size, 1),
          rotation: rotation,
          width: text_w,
          height: text_h
        }

        {entry, [entry | placed_acc]}
      end)

    placed
  end

  # ---------------------------------------------------------------------------
  # Easing Functions (complete set from D3/CSS)
  # ---------------------------------------------------------------------------

  @doc "Ease-in quadratic."
  def ease_in_quad(t), do: t * t

  @doc "Ease-out quadratic."
  def ease_out_quad(t), do: t * (2 - t)

  @doc "Ease-in-out quadratic."
  def ease_in_out_quad(t), do: if(t < 0.5, do: 2 * t * t, else: -1 + (4 - 2 * t) * t)

  @doc "Ease-in cubic."
  def ease_in_cubic(t), do: t * t * t

  @doc "Ease-in quartic."
  def ease_in_quart(t), do: t * t * t * t

  @doc "Ease-out quartic."
  def ease_out_quart(t), do: 1 - :math.pow(1 - t, 4)

  @doc "Ease-in-out quartic."
  def ease_in_out_quart(t), do: if(t < 0.5, do: 8 * t * t * t * t, else: 1 - :math.pow(-2 * t + 2, 4) / 2)

  @doc "Ease-in sine."
  def ease_in_sine(t), do: 1 - :math.cos(t * :math.pi() / 2)

  @doc "Ease-out sine."
  def ease_out_sine(t), do: :math.sin(t * :math.pi() / 2)

  @doc "Ease-in-out sine."
  def ease_in_out_sine(t), do: -((:math.cos(:math.pi() * t) - 1) / 2)

  @doc "Ease-in exponential."
  def ease_in_expo(t) when t == 0.0, do: 0.0
  def ease_in_expo(t), do: :math.pow(2, 10 * t - 10)

  @doc "Ease-out exponential."
  def ease_out_expo(t) when t == 1.0, do: 1.0
  def ease_out_expo(t), do: 1 - :math.pow(2, -10 * t)

  @doc "Ease-in-out exponential."
  def ease_in_out_expo(t) when t == 0.0, do: 0.0
  def ease_in_out_expo(t) when t == 1.0, do: 1.0
  def ease_in_out_expo(t) do
    if t < 0.5, do: :math.pow(2, 20 * t - 10) / 2, else: (2 - :math.pow(2, -20 * t + 10)) / 2
  end

  @doc "Ease-in circular."
  def ease_in_circ(t), do: 1 - :math.sqrt(1 - t * t)

  @doc "Ease-out circular."
  def ease_out_circ(t), do: :math.sqrt(1 - :math.pow(t - 1, 2))

  @doc "Ease-in-out circular."
  def ease_in_out_circ(t) do
    if t < 0.5, do: (1 - :math.sqrt(1 - :math.pow(2 * t, 2))) / 2, else: (:math.sqrt(1 - :math.pow(-2 * t + 2, 2)) + 1) / 2
  end

  @doc "Ease-in back (overshoot)."
  def ease_in_back(t) do
    c1 = 1.70158
    c3 = c1 + 1
    c3 * t * t * t - c1 * t * t
  end

  @doc "Ease-out back (overshoot)."
  def ease_out_back(t) do
    c1 = 1.70158
    c3 = c1 + 1
    1 + c3 * :math.pow(t - 1, 3) + c1 * :math.pow(t - 1, 2)
  end

  @doc "Ease-in-out back."
  def ease_in_out_back(t) do
    c1 = 1.70158
    c2 = c1 * 1.525
    if t < 0.5 do
      :math.pow(2 * t, 2) * ((c2 + 1) * 2 * t - c2) / 2
    else
      (:math.pow(2 * t - 2, 2) * ((c2 + 1) * (t * 2 - 2) + c2) + 2) / 2
    end
  end

  @doc "Ease-out bounce."
  def ease_out_bounce(t) do
    n1 = 7.5625
    d1 = 2.75
    cond do
      t < 1 / d1 -> n1 * t * t
      t < 2 / d1 ->
        t2 = t - 1.5 / d1
        n1 * t2 * t2 + 0.75
      t < 2.5 / d1 ->
        t2 = t - 2.25 / d1
        n1 * t2 * t2 + 0.9375
      true ->
        t2 = t - 2.625 / d1
        n1 * t2 * t2 + 0.984375
    end
  end

  @doc "Ease-in bounce."
  def ease_in_bounce(t), do: 1 - ease_out_bounce(1 - t)

  @doc "Ease-in-out bounce."
  def ease_in_out_bounce(t) do
    if t < 0.5, do: (1 - ease_out_bounce(1 - 2 * t)) / 2, else: (1 + ease_out_bounce(2 * t - 1)) / 2
  end

  # ---------------------------------------------------------------------------
  # Private Helpers
  # ---------------------------------------------------------------------------

  defp distance(%{x: x1, y: y1}, %{x: x2, y: y2}) do
    :math.sqrt(:math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2))
  end

  defp f(v), do: Float.round(v * 1.0, 2)

  defp to_xy(%{x: x, y: y}), do: %{x: x, y: y}
  defp to_xy(%{label: l, value: v}), do: %{x: l, y: v}

  defp triangle_area(%{x: ax, y: ay}, %{x: bx, y: by}, %{x: cx, y: cy}) do
    # Absolute area of triangle formed by three points
    abs((ax * (by - cy) + bx * (cy - ay) + cx * (ay - by)) / 2.0)
  end

  defp bucket_average(data, from, to) when from > to do
    Enum.at(data, from, %{x: 0, y: 0})
  end

  defp bucket_average(data, from, to) do
    slice = Enum.slice(data, from..to)
    n = length(slice)
    if n == 0 do
      %{x: 0, y: 0}
    else
      sum_x = Enum.sum(Enum.map(slice, & &1.x))
      sum_y = Enum.sum(Enum.map(slice, & &1.y))
      %{x: sum_x / n, y: sum_y / n}
    end
  end

  defp percentile(sorted, n, p) do
    k = (n - 1) * p
    f_k = :math.floor(k) |> trunc()
    c_k = :math.ceil(k) |> trunc()
    if f_k == c_k do
      Enum.at(sorted, f_k) * 1.0
    else
      v0 = Enum.at(sorted, f_k)
      v1 = Enum.at(sorted, c_k)
      v0 + (v1 - v0) * (k - f_k)
    end
  end

  defp silverman_bandwidth(sorted, n) do
    mean = Enum.sum(sorted) / n
    variance = Enum.reduce(sorted, 0.0, fn v, acc -> acc + (v - mean) * (v - mean) end) / n
    std_dev = :math.sqrt(variance)
    iqr_data = quartiles(sorted)
    h = min(std_dev, iqr_data.iqr / 1.34)
    0.9 * h * :math.pow(n * 1.0, -0.2)
  end

  defp sum_values(data) do
    Enum.reduce(data, 0, fn item, acc ->
      children_sum = if Map.has_key?(item, :children) and is_list(item.children), do: sum_values(item.children), else: 0
      acc + max(Map.get(item, :value, 0), children_sum)
    end)
  end

  defp do_sunburst_arcs([], _depth, _start, _end_angle, _total, _ring_w, _inner_r, acc), do: acc

  defp do_sunburst_arcs(items, depth, start_angle, end_angle, total, ring_w, inner_r, acc) do
    available = end_angle - start_angle
    inner = inner_r + depth * ring_w
    outer = inner + ring_w

    {new_acc, _} =
      Enum.reduce(items, {acc, start_angle}, fn item, {arc_acc, angle} ->
        item_value = max(Map.get(item, :value, 0), if(Map.has_key?(item, :children), do: sum_values(item.children), else: 0))
        sweep = item_value / max(total, 1) * available
        end_a = angle + sweep

        arc = %{
          label: item.label,
          value: item_value,
          depth: depth,
          start_angle: Float.round(angle, 6),
          end_angle: Float.round(end_a, 6),
          inner_r: Float.round(inner * 1.0, 2),
          outer_r: Float.round(outer * 1.0, 2)
        }

        children = Map.get(item, :children, [])
        child_acc =
          if children != [] do
            do_sunburst_arcs(children, depth + 1, angle, end_a, item_value, ring_w, inner_r, [arc | arc_acc])
          else
            [arc | arc_acc]
          end

        {child_acc, end_a}
      end)

    new_acc
  end

  defp assign_columns(nodes, links, sources) do
    initial = Map.new(nodes, fn n ->
      if MapSet.member?(sources, n.id), do: {n.id, 0}, else: {n.id, nil}
    end)

    target_map = Enum.group_by(links, & &1.source, & &1.target)

    # BFS
    queue = MapSet.to_list(sources)
    bfs_assign(queue, initial, target_map, nodes)
  end

  defp bfs_assign([], columns, _target_map, _nodes), do: columns

  defp bfs_assign([current | rest], columns, target_map, nodes) do
    current_col = Map.get(columns, current, 0)
    targets = Map.get(target_map, current, [])

    {new_columns, new_queue} =
      Enum.reduce(targets, {columns, rest}, fn target, {cols, q} ->
        existing = Map.get(cols, target)
        new_col = current_col + 1

        if existing == nil or new_col > existing do
          {Map.put(cols, target, new_col), q ++ [target]}
        else
          {cols, q}
        end
      end)

    bfs_assign(new_queue, new_columns, target_map, nodes)
  end

  defp compute_node_values(nodes, links) do
    outgoing = Enum.group_by(links, & &1.source)
    incoming = Enum.group_by(links, & &1.target)

    Map.new(nodes, fn n ->
      out_sum = outgoing |> Map.get(n.id, []) |> Enum.map(& &1.value) |> Enum.sum()
      in_sum = incoming |> Map.get(n.id, []) |> Enum.map(& &1.value) |> Enum.sum()
      {n.id, max(out_sum, in_sum) |> max(1)}
    end)
  end

  defp compute_link_offsets(links, node_map) do
    # Group links by source and target to compute offsets
    by_source = Enum.group_by(links, & &1.source)
    by_target = Enum.group_by(links, & &1.target)

    source_offsets =
      Enum.flat_map(by_source, fn {source_id, source_links} ->
        node = Map.get(node_map, source_id)
        node_value = node.height
        {result, _} =
          Enum.map_reduce(source_links, 0.0, fn link, offset ->
            total_out = source_links |> Enum.map(& &1.value) |> Enum.sum() |> max(1)
            h = node_value * link.value / total_out
            {{link.source, link.target, :source, offset}, offset + h}
          end)
        result
      end)

    target_offsets =
      Enum.flat_map(by_target, fn {target_id, target_links} ->
        node = Map.get(node_map, target_id)
        node_value = node.height
        {result, _} =
          Enum.map_reduce(target_links, 0.0, fn link, offset ->
            total_in = target_links |> Enum.map(& &1.value) |> Enum.sum() |> max(1)
            h = node_value * link.value / total_in
            {{link.source, link.target, :target, offset}, offset + h}
          end)
        result
      end)

    so_map = Map.new(source_offsets, fn {s, t, :source, o} -> {{s, t}, o} end)
    to_map = Map.new(target_offsets, fn {s, t, :target, o} -> {{s, t}, o} end)

    Enum.map(links, fn link ->
      link
      |> Map.put(:source_offset, Map.get(so_map, {link.source, link.target}, 0.0))
      |> Map.put(:target_offset, Map.get(to_map, {link.source, link.target}, 0.0))
    end)
  end

  defp place_circles_spiral(items, bounding_r) do
    {placed, _} =
      Enum.map_reduce(items, [], fn item, placed_acc ->
        r = item.r
        # Spiral search for non-overlapping position
        {cx, cy} = find_spiral_position(r, placed_acc, bounding_r)
        entry = %{label: item.label, value: item.value, cx: Float.round(cx, 2), cy: Float.round(cy, 2), r: r}
        {entry, [entry | placed_acc]}
      end)

    placed
  end

  defp find_spiral_position(r, placed, bounding_r) do
    # Archimedean spiral: (a + b*theta) at angle theta
    Enum.reduce_while(0..500, {0.0, 0.0}, fn i, _acc ->
      theta = i * 0.2
      spiral_r = theta * 2.0
      x = spiral_r * :math.cos(theta)
      y = spiral_r * :math.sin(theta)

      # Check bounds
      if :math.sqrt(x * x + y * y) + r > bounding_r do
        {:cont, {x, y}}
      else
        # Check collision with placed circles
        collides = Enum.any?(placed, fn p ->
          dist = :math.sqrt(:math.pow(x - p.cx, 2) + :math.pow(y - p.cy, 2))
          dist < r + p.r + 2
        end)

        if collides, do: {:cont, {x, y}}, else: {:halt, {x, y}}
      end
    end)
  end

  defp spiral_place(cx, cy, _text_w, _text_h, [], _dims), do: {cx, cy}

  defp spiral_place(cx, cy, text_w, text_h, placed, dims) do
    Enum.reduce_while(0..300, {cx, cy}, fn i, _acc ->
      theta = i * 0.3
      spiral_r = theta * 3.0
      x = cx + spiral_r * :math.cos(theta)
      y = cy + spiral_r * :math.sin(theta)

      # Check bounds
      in_bounds = x - text_w / 2 >= 0 and x + text_w / 2 <= dims.width and
                  y - text_h / 2 >= 0 and y + text_h / 2 <= dims.height

      if not in_bounds do
        {:cont, {x, y}}
      else
        collides = Enum.any?(placed, fn p ->
          not (x + text_w / 2 < p.x - p.width / 2 or
               x - text_w / 2 > p.x + p.width / 2 or
               y + text_h / 2 < p.y - p.height / 2 or
               y - text_h / 2 > p.y + p.height / 2)
        end)

        if collides, do: {:cont, {x, y}}, else: {:halt, {x, y}}
      end
    end)
  end
end
