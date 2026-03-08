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
end
