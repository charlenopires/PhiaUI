defmodule PhiaUi.Components.Data.ChartCoord do
  @moduledoc false
  # Coordinate system abstraction for chart components.
  # Maps to eCharts CoordinateSystem interface (dataToPoint, pointToData, containPoint).
  # Returns closure-based mappers for coordinate transformations.
  # Not registered in ComponentRegistry — internal only.

  alias PhiaUi.Components.Data.ChartScales
  alias PhiaUi.Components.Data.ChartViewport
  alias PhiaUi.Components.Data.ChartAxisHelpers
  alias PhiaUi.Components.Data.ChartHelpers

  @doc """
  Creates a Cartesian 2D coordinate system.

  Returns a map with closures for coordinate transformations:
  - `type` — `:cartesian2d`
  - `data_to_point` — `fn(x_val, y_val) -> {px, py}`
  - `point_to_data` — `fn(px, py) -> {x_val, y_val}`
  - `contain_point` — `fn(px, py) -> boolean` (is point within chart area)
  - `area` — `%{x, y, width, height}` chart area bounds
  - `x_scale` — the x scale closure
  - `y_scale` — the y scale closure

  ## Parameters
  - `viewport` — viewport map from `ChartViewport.build/1`
  - `x_scale` — x scale closure (from ChartScales)
  - `y_scale` — y scale closure (from ChartScales)
  """
  def cartesian2d(viewport, x_scale, y_scale) do
    %{pl: pl, pt: pt, cw: cw, ch: ch} = viewport

    %{
      type: :cartesian2d,
      data_to_point: fn x_val, y_val ->
        px = x_scale.(x_val)
        py = y_scale.(y_val)
        {px, py}
      end,
      point_to_data: fn px, py ->
        # Invert scales — for linear scales this is straightforward
        # For band scales, return closest category (approximate)
        {px, py}
      end,
      contain_point: fn px, py ->
        px >= pl and px <= pl + cw and py >= pt and py <= pt + ch
      end,
      area: %{x: pl, y: pt, width: cw, height: ch},
      x_scale: x_scale,
      y_scale: y_scale
    }
  end

  @doc """
  Creates a polar coordinate system.

  Returns a map with closures for coordinate transformations:
  - `type` — `:polar`
  - `data_to_point` — `fn(angle, radius) -> {px, py}`
  - `point_to_data` — `fn(px, py) -> {angle, radius}`
  - `contain_point` — `fn(px, py) -> boolean`
  - `center` — `{cx, cy}` center coordinates
  - `max_radius` — maximum radius in pixels

  ## Parameters
  - `viewport` — polar viewport map (needs :cx, :cy, :r keys)
  - `radius_scale` — scale for radius values (from ChartScales)
  - `angle_range` — `{start_angle, end_angle}` in radians (default full circle from top)
  """
  def polar(viewport, radius_scale, angle_range \\ {-:math.pi() / 2, 3 * :math.pi() / 2}) do
    %{cx: cx, cy: cy, r: max_r} = viewport
    {angle_start, angle_end} = angle_range

    %{
      type: :polar,
      data_to_point: fn angle, radius_val ->
        r = radius_scale.(radius_val)
        px = cx + r * :math.cos(angle)
        py = cy + r * :math.sin(angle)
        {px, py}
      end,
      point_to_data: fn px, py ->
        dx = px - cx
        dy = py - cy
        r = :math.sqrt(dx * dx + dy * dy)
        angle = :math.atan2(dy, dx)
        {angle, r}
      end,
      contain_point: fn px, py ->
        dx = px - cx
        dy = py - cy
        :math.sqrt(dx * dx + dy * dy) <= max_r
      end,
      center: {cx, cy},
      max_radius: max_r,
      angle_range: {angle_start, angle_end},
      radius_scale: radius_scale
    }
  end

  @doc """
  Auto-creates a Cartesian coordinate system from series data.

  Automatically computes categories, Y domain, scales, and ticks.

  Returns `{coord, x_ticks_or_categories, y_ticks, y_range}` where:
  - `coord` — coordinate system map from `cartesian2d/3`
  - `x_ticks_or_categories` — list of category labels
  - `y_ticks` — computed Y-axis tick values
  - `y_range` — `{y_min, y_max}` nice domain bounds

  ## Options
  - `:viewport` — override viewport (default: `ChartViewport.build([])`)
  - `:x_type` — `:band` | `:linear` (default `:band`)
  - `:y_type` — `:linear` | `:log` (default `:linear`)
  - `:tick_count` — target number of Y ticks (default 5)
  """
  def auto_cartesian(series, opts \\ []) do
    vp = Keyword.get(opts, :viewport, ChartViewport.build([]))
    x_type = Keyword.get(opts, :x_type, :band)
    y_type = Keyword.get(opts, :y_type, :linear)
    tick_count = Keyword.get(opts, :tick_count, 5)

    categories = ChartHelpers.extract_categories(series)
    {y_ticks, y_min, y_max} = ChartHelpers.compute_y_domain(series, tick_count: tick_count)

    x_range_min = vp.pl
    x_range_max = vp.pl + vp.cw

    x_scale_result =
      case x_type do
        :band ->
          ChartScales.band_scale(categories, x_range_min, x_range_max)

        :linear ->
          n = length(categories)
          scale = ChartScales.linear_scale(0, max(n - 1, 1), x_range_min, x_range_max)
          positions = categories |> Enum.with_index() |> Enum.map(fn {c, i} -> {c, scale.(i)} end) |> Map.new()
          bw = (x_range_max - x_range_min) / max(n, 1) * 0.8
          %{positions: positions, bandwidth: bw, scale: fn cat -> Map.get(positions, cat, (x_range_min + x_range_max) / 2) end}
      end

    y_scale =
      case y_type do
        :log -> ChartScales.log_scale(max(y_min, 0.1), y_max, vp.pt + vp.ch, vp.pt)
        _ -> ChartScales.linear_scale(y_min, y_max, vp.pt + vp.ch, vp.pt)
      end

    coord = cartesian2d(vp, x_scale_result.scale, y_scale)
    coord_with_band = Map.put(coord, :bandwidth, Map.get(x_scale_result, :bandwidth, 0))

    {coord_with_band, categories, y_ticks, {y_min, y_max}}
  end

  @doc """
  Creates a multi-axis Cartesian coordinate system.

  Maps to Highcharts' multiple Y-axes per chart (e.g., revenue left, % right).
  Each axis gets its own scale, ticks, and domain.

  ## Parameters
  - `viewport` — viewport from `ChartViewport.build/1`
  - `axes_config` — list of axis configs: `[%{id, domain: {min, max}, position: :left | :right}]`

  Returns a coord map with:
  - `data_to_point` — `fn(x_val, y_val, axis_id) -> {px, py}`
  - `y_scales` — `%{axis_id => scale_fn}`
  - `y_ticks_map` — `%{axis_id => [ticks]}`
  - `y_ranges_map` — `%{axis_id => {y_min, y_max}}`
  """
  def multi_cartesian(viewport, x_scale, axes_config) do
    %{pl: pl, pt: pt, cw: cw, ch: ch} = viewport

    y_scales =
      axes_config
      |> Enum.map(fn axis ->
        {y_min, y_max} = axis.domain
        scale = ChartScales.linear_scale(y_min, y_max, pt + ch, pt)
        {axis.id, scale}
      end)
      |> Map.new()

    y_ticks_map =
      axes_config
      |> Enum.map(fn axis ->
        {y_min, y_max} = axis.domain
        tick_count = Map.get(axis, :tick_count, 5)
        ticks = ChartAxisHelpers.nice_ticks(y_min, y_max, tick_count)
        {axis.id, ticks}
      end)
      |> Map.new()

    y_ranges_map =
      axes_config
      |> Enum.map(fn axis ->
        ticks = Map.get(y_ticks_map, axis.id, [0])
        {axis.id, {Enum.min(ticks), Enum.max(ticks)}}
      end)
      |> Map.new()

    default_axis_id =
      case axes_config do
        [first | _] -> first.id
        _ -> nil
      end

    %{
      type: :cartesian2d,
      multi_axis: true,
      data_to_point: fn x_val, y_val ->
        px = x_scale.(x_val)
        default_scale = Map.get(y_scales, default_axis_id, fn v -> v end)
        py = default_scale.(y_val)
        {px, py}
      end,
      data_to_point_axis: fn x_val, y_val, axis_id ->
        px = x_scale.(x_val)
        scale = Map.get(y_scales, axis_id, Map.get(y_scales, default_axis_id, fn v -> v end))
        py = scale.(y_val)
        {px, py}
      end,
      point_to_data: fn px, py -> {px, py} end,
      contain_point: fn px, py ->
        px >= pl and px <= pl + cw and py >= pt and py <= pt + ch
      end,
      area: %{x: pl, y: pt, width: cw, height: ch},
      x_scale: x_scale,
      y_scale: Map.get(y_scales, default_axis_id, fn v -> v end),
      y_scales: y_scales,
      y_ticks_map: y_ticks_map,
      y_ranges_map: y_ranges_map,
      axes_config: axes_config
    }
  end

  @doc """
  Auto-creates a multi-axis Cartesian coordinate system from series data.

  Series with `:y_axis_index` (0-based) are grouped by axis. Each axis gets
  its own domain, scale, and ticks.

  Returns `{coord, categories, y_ticks_map, y_ranges_map}`.
  """
  def auto_multi_cartesian(series, opts \\ []) do
    vp = Keyword.get(opts, :viewport, ChartViewport.build([]))
    x_type = Keyword.get(opts, :x_type, :band)
    tick_count = Keyword.get(opts, :tick_count, 5)

    categories = ChartHelpers.extract_categories(series)

    x_range_min = vp.pl
    x_range_max = vp.pl + vp.cw

    x_scale_result =
      case x_type do
        :band ->
          ChartScales.band_scale(categories, x_range_min, x_range_max)

        :linear ->
          n = length(categories)
          scale = ChartScales.linear_scale(0, max(n - 1, 1), x_range_min, x_range_max)
          positions = categories |> Enum.with_index() |> Enum.map(fn {c, i} -> {c, scale.(i)} end) |> Map.new()
          bw = (x_range_max - x_range_min) / max(n, 1) * 0.8
          %{positions: positions, bandwidth: bw, scale: fn cat -> Map.get(positions, cat, (x_range_min + x_range_max) / 2) end}
      end

    # Group series by y_axis_index
    grouped =
      series
      |> Enum.group_by(fn s -> Map.get(s, :y_axis_index, 0) end)

    axes_config =
      grouped
      |> Enum.sort_by(fn {idx, _} -> idx end)
      |> Enum.map(fn {idx, group_series} ->
        all_values = Enum.flat_map(group_series, fn s -> Enum.map(s.data, & &1.value) end)
        {ticks, y_min, y_max} =
          if all_values == [] do
            {[0], 0, 10}
          else
            ChartHelpers.compute_y_domain(group_series, tick_count: tick_count)
          end

        position = if idx == 0, do: :left, else: :right

        %{
          id: idx,
          domain: {Enum.min(ticks), Enum.max(ticks)},
          position: position,
          tick_count: tick_count,
          ticks: ticks,
          y_min: y_min,
          y_max: y_max
        }
      end)

    coord = multi_cartesian(vp, x_scale_result.scale, axes_config)
    coord_with_band = Map.put(coord, :bandwidth, Map.get(x_scale_result, :bandwidth, 0))

    {coord_with_band, categories, coord.y_ticks_map, coord.y_ranges_map}
  end

  @doc """
  Auto-creates a polar coordinate system from data values.

  Returns `{coord, radius_ticks}`.

  ## Options
  - `:viewport` — override polar viewport (default: `ChartViewport.default_polar()`)
  - `:tick_count` — target number of radius ticks (default 4)
  """
  def auto_polar(values, opts \\ []) do
    vp = Keyword.get(opts, :viewport, ChartViewport.default_polar())
    tick_count = Keyword.get(opts, :tick_count, 4)

    max_val = if values == [], do: 10, else: Enum.max(values)
    ticks = ChartAxisHelpers.nice_ticks(0, max(max_val, 1), tick_count)
    r_max = Enum.max(ticks)

    radius_scale = ChartScales.linear_scale(0, r_max, 0, vp.r)
    coord = polar(vp, radius_scale)

    {coord, ticks}
  end
end
