defmodule PhiaUi.Components.Data.ChartSeriesRegistry do
  @moduledoc false
  # Extensible series type dispatch for chart rendering.
  # Replaces hardcoded build_elements in xy_chart.ex with pattern-matched renderers.
  # Inspired by eCharts registerChartView/SeriesModel registry.
  # Not registered in ComponentRegistry — internal only.

  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartMathHelpers
  alias PhiaUi.Components.Data.ChartCell
  alias PhiaUi.Components.Data.ChartSymbols

  @supported_types [:bar, :line, :area, :scatter, :error_bar, :range_area, :column_range, :spline, :candlestick, :box, :violin, :lollipop, :dumbbell]

  @doc """
  Returns the list of supported series types.
  """
  def types, do: @supported_types

  @doc """
  Returns true if the given series type is supported.
  """
  def supported?(type), do: type in @supported_types

  @doc """
  Renders a series into visual element maps ready for SVG template consumption.

  ## Parameters
  - `type` — series type atom (:bar, :line, :area, :scatter)
  - `series_data` — list of `%{label, value}` maps
  - `coord` — coordinate system from `ChartCoord.cartesian2d/3` or `auto_cartesian/2`
  - `opts` — rendering options

  ## Options
  - `:color` — series color string (required)
  - `:series_index` — index of this series (for animation delay)
  - `:bar_index` — index among bar series (for grouped bars)
  - `:n_bar_series` — total number of bar series (for bar width)
  - `:animate` — boolean, enable animations (default true)
  - `:animation_duration` — ms (default 600)
  - `:bar_radius` — corner radius for bars (default 2)
  - `:stroke_width` — line stroke width (default 2)
  - `:symbol_size` — scatter symbol size (default 5)

  Returns a list of element maps. Each map has a `:type` key and render-specific fields.
  """
  def render(:bar, data, coord, opts) do
    color = Keyword.fetch!(opts, :color)
    bar_idx = Keyword.get(opts, :bar_index, 0)
    n_bar = Keyword.get(opts, :n_bar_series, 1)
    animate = Keyword.get(opts, :animate, true)
    dur = Keyword.get(opts, :animation_duration, 600)
    bar_radius = Keyword.get(opts, :bar_radius, 2)

    bw = Map.get(coord, :bandwidth, 20)
    bar_w = bw / max(n_bar, 1)

    data
    |> Enum.with_index()
    |> Enum.map(fn {item, gi} ->
      {cx, _} = coord.data_to_point.(item.label, 0)
      {_, y_top} = coord.data_to_point.(item.label, item.value)
      {_, y_base} = coord.data_to_point.(item.label, 0)
      x = cx - bw / 2 + bar_idx * bar_w
      h = abs(y_base - y_top)

      %{
        type: :bar,
        x: Float.round(x, 2),
        y: Float.round(min(y_top, y_base), 2),
        w: Float.round(bar_w, 2),
        h: Float.round(max(h, 1.0), 2),
        rx: bar_radius,
        color: color,
        anim_style: bar_anim(animate, dur, gi * 60)
      }
    end)
    |> maybe_apply_cells(opts)
  end

  def render(:line, data, coord, opts) do
    color = Keyword.fetch!(opts, :color)
    si = Keyword.get(opts, :series_index, 0)
    animate = Keyword.get(opts, :animate, true)
    dur = Keyword.get(opts, :animation_duration, 600)
    stroke_width = Keyword.get(opts, :stroke_width, 2)

    points =
      data
      |> Enum.map(fn item ->
        {px, py} = coord.data_to_point.(item.label, item.value)
        "#{Float.round(px * 1.0, 2)},#{Float.round(py * 1.0, 2)}"
      end)
      |> Enum.join(" ")

    line_length = ChartHelpers.polyline_length(points)

    [%{
      type: :line,
      points: points,
      color: color,
      stroke_width: stroke_width,
      anim_style: line_anim(animate, dur, si * 100, line_length)
    }]
  end

  def render(:area, data, coord, opts) do
    color = Keyword.fetch!(opts, :color)
    si = Keyword.get(opts, :series_index, 0)
    animate = Keyword.get(opts, :animate, true)
    dur = Keyword.get(opts, :animation_duration, 600)

    coords =
      Enum.map(data, fn item ->
        {px, py} = coord.data_to_point.(item.label, item.value)
        {Float.round(px * 1.0, 2), Float.round(py * 1.0, 2)}
      end)

    {_, baseline} = coord.data_to_point.("", 0)
    baseline = Float.round(baseline * 1.0, 2)

    path_d =
      if coords == [] do
        ""
      else
        {first_x, _} = hd(coords)
        {last_x, _} = List.last(coords)
        line = Enum.map_join(coords, " L ", fn {x, y} -> "#{x} #{y}" end)
        "M #{first_x} #{baseline} L #{line} L #{last_x} #{baseline} Z"
      end

    [%{
      type: :area,
      path_d: path_d,
      color: color,
      anim_style: if(animate, do: "animation: phia-fade-in #{dur}ms ease-out #{si * 100}ms both", else: "")
    }]
  end

  def render(:scatter, data, coord, opts) do
    color = Keyword.fetch!(opts, :color)
    animate = Keyword.get(opts, :animate, true)
    dur = Keyword.get(opts, :animation_duration, 600)
    symbol_size = Keyword.get(opts, :symbol_size, 5)
    symbol_type = Keyword.get(opts, :symbol_type, :circle)

    data
    |> Enum.with_index()
    |> Enum.map(fn {item, i} ->
      {px, py} = coord.data_to_point.(item.label, item.value)
      anim = if(animate, do: "animation: phia-dot-pop #{dur}ms ease-out #{i * 60}ms both", else: "")

      base = %{
        cx: Float.round(px * 1.0, 2),
        cy: Float.round(py * 1.0, 2),
        r: symbol_size,
        color: color,
        anim_style: anim
      }

      if symbol_type != :circle and ChartSymbols.supported?(symbol_type) do
        Map.merge(base, %{
          type: :scatter_symbol,
          path_d: ChartSymbols.path(symbol_type, symbol_size),
          symbol_type: symbol_type
        })
      else
        Map.put(base, :type, :scatter)
      end
    end)
    |> maybe_apply_cells(opts)
  end

  def render(:error_bar, data, coord, opts) do
    color = Keyword.get(opts, :color, "currentColor")
    cap_width = Keyword.get(opts, :cap_width, 8)
    stroke_width = Keyword.get(opts, :stroke_width, 1.5)
    animate = Keyword.get(opts, :animate, true)
    dur = Keyword.get(opts, :animation_duration, 600)

    data
    |> Enum.with_index()
    |> Enum.map(fn {item, i} ->
      {px, _} = coord.data_to_point.(item.label, item.value)
      error_low = Map.get(item, :error_low, item.value)
      error_high = Map.get(item, :error_high, item.value)
      {_, py_low} = coord.data_to_point.(item.label, error_low)
      {_, py_high} = coord.data_to_point.(item.label, error_high)

      %{
        type: :error_bar,
        px: Float.round(px * 1.0, 2),
        py_low: Float.round(py_low * 1.0, 2),
        py_high: Float.round(py_high * 1.0, 2),
        cap_width: cap_width,
        color: color,
        stroke_width: stroke_width,
        anim_style: if(animate, do: "transform-origin: center; animation: phia-error-bar-pop #{dur}ms ease-out #{i * 60}ms both", else: "")
      }
    end)
  end

  def render(:range_area, data, coord, opts) do
    color = Keyword.fetch!(opts, :color)
    si = Keyword.get(opts, :series_index, 0)
    animate = Keyword.get(opts, :animate, true)
    dur = Keyword.get(opts, :animation_duration, 600)

    upper_coords =
      Enum.map(data, fn item ->
        {px, py} = coord.data_to_point.(item.label, Map.get(item, :high, item.value))
        {Float.round(px * 1.0, 2), Float.round(py * 1.0, 2)}
      end)

    lower_coords =
      data
      |> Enum.map(fn item ->
        {px, py} = coord.data_to_point.(item.label, Map.get(item, :low, 0))
        {Float.round(px * 1.0, 2), Float.round(py * 1.0, 2)}
      end)
      |> Enum.reverse()

    path_d =
      if upper_coords == [] do
        ""
      else
        upper_line = Enum.map_join(upper_coords, " L ", fn {x, y} -> "#{x} #{y}" end)
        lower_line = Enum.map_join(lower_coords, " L ", fn {x, y} -> "#{x} #{y}" end)
        "M #{upper_line} L #{lower_line} Z"
      end

    [%{
      type: :range_area,
      path_d: path_d,
      color: color,
      anim_style: if(animate, do: "animation: phia-fade-in #{dur}ms ease-out #{si * 100}ms both", else: "")
    }]
  end

  def render(:column_range, data, coord, opts) do
    color = Keyword.fetch!(opts, :color)
    bar_idx = Keyword.get(opts, :bar_index, 0)
    n_bar = Keyword.get(opts, :n_bar_series, 1)
    animate = Keyword.get(opts, :animate, true)
    dur = Keyword.get(opts, :animation_duration, 600)
    bar_radius = Keyword.get(opts, :bar_radius, 2)

    bw = Map.get(coord, :bandwidth, 20)
    bar_w = bw / max(n_bar, 1)

    data
    |> Enum.with_index()
    |> Enum.map(fn {item, gi} ->
      low_val = Map.get(item, :low, 0)
      high_val = Map.get(item, :high, item.value)
      {cx, _} = coord.data_to_point.(item.label, 0)
      {_, y_high} = coord.data_to_point.(item.label, high_val)
      {_, y_low} = coord.data_to_point.(item.label, low_val)
      x = cx - bw / 2 + bar_idx * bar_w
      h = abs(y_low - y_high)

      %{
        type: :column_range,
        x: Float.round(x, 2),
        y: Float.round(min(y_high, y_low), 2),
        w: Float.round(bar_w, 2),
        h: Float.round(max(h, 1.0), 2),
        rx: bar_radius,
        color: color,
        anim_style: bar_anim(animate, dur, gi * 60)
      }
    end)
  end

  def render(:spline, data, coord, opts) do
    color = Keyword.fetch!(opts, :color)
    si = Keyword.get(opts, :series_index, 0)
    animate = Keyword.get(opts, :animate, true)
    dur = Keyword.get(opts, :animation_duration, 600)
    stroke_width = Keyword.get(opts, :stroke_width, 2)

    points =
      Enum.map(data, fn item ->
        {px, py} = coord.data_to_point.(item.label, item.value)
        %{x: px * 1.0, y: py * 1.0}
      end)

    path_d = ChartMathHelpers.smooth_path(points, :smooth)

    # Approximate path length for animation
    polyline_points =
      Enum.map_join(points, " ", fn p -> "#{Float.round(p.x, 2)},#{Float.round(p.y, 2)}" end)
    path_length = ChartHelpers.polyline_length(polyline_points)

    [%{
      type: :spline,
      path_d: path_d,
      color: color,
      stroke_width: stroke_width,
      anim_style: spline_anim(animate, dur, si * 100, path_length)
    }]
  end

  def render(:candlestick, data, coord, opts) do
    bullish_color = Keyword.get(opts, :bullish_color, "oklch(0.70 0.18 145)")
    bearish_color = Keyword.get(opts, :bearish_color, "oklch(0.60 0.25 0)")
    animate = Keyword.get(opts, :animate, true)
    dur = Keyword.get(opts, :animation_duration, 600)
    body_width = Keyword.get(opts, :body_width, nil)

    bw = Map.get(coord, :bandwidth, 20)
    w = body_width || bw * 0.6

    data
    |> Enum.with_index()
    |> Enum.flat_map(fn {item, gi} ->
      {cx, _} = coord.data_to_point.(item.label, 0)
      open = Map.get(item, :open, 0)
      high = Map.get(item, :high, 0)
      low = Map.get(item, :low, 0)
      close = Map.get(item, :close, 0)
      bullish = close >= open
      color = if bullish, do: bullish_color, else: bearish_color

      {_, y_high} = coord.data_to_point.(item.label, high)
      {_, y_low} = coord.data_to_point.(item.label, low)
      {_, y_open} = coord.data_to_point.(item.label, open)
      {_, y_close} = coord.data_to_point.(item.label, close)

      body_top = min(y_open, y_close)
      body_h = max(abs(y_open - y_close), 1.0)

      wick = %{
        type: :candlestick_wick,
        x1: Float.round(cx * 1.0, 2),
        y1: Float.round(y_high * 1.0, 2),
        x2: Float.round(cx * 1.0, 2),
        y2: Float.round(y_low * 1.0, 2),
        color: color,
        anim_style: if(animate, do: "transform-box: fill-box; transform-origin: center; animation: phia-candle-grow #{dur}ms ease-out #{gi * 60}ms both", else: "")
      }

      body = %{
        type: :candlestick_body,
        x: Float.round(cx - w / 2, 2),
        y: Float.round(body_top * 1.0, 2),
        w: Float.round(w, 2),
        h: Float.round(body_h, 2),
        color: color,
        filled: not bullish,
        anim_style: if(animate, do: "transform-box: fill-box; transform-origin: center; animation: phia-candle-grow #{dur}ms ease-out #{gi * 60}ms both", else: "")
      }

      [wick, body]
    end)
  end

  def render(:box, data, coord, opts) do
    alias PhiaUi.Components.Data.ChartMathHelpers
    color = Keyword.fetch!(opts, :color)
    animate = Keyword.get(opts, :animate, true)
    dur = Keyword.get(opts, :animation_duration, 600)

    bw = Map.get(coord, :bandwidth, 20)
    box_w = bw * 0.6

    data
    |> Enum.with_index()
    |> Enum.flat_map(fn {item, gi} ->
      {cx, _} = coord.data_to_point.(item.label, 0)
      stats = if Map.has_key?(item, :q1) do
        item
      else
        ChartMathHelpers.quartiles(Map.get(item, :values, []))
      end

      {_, y_q1} = coord.data_to_point.(item.label, stats.q1)
      {_, y_q3} = coord.data_to_point.(item.label, stats.q3)
      {_, y_med} = coord.data_to_point.(item.label, stats.median)
      {_, y_wl} = coord.data_to_point.(item.label, stats.whisker_low)
      {_, y_wh} = coord.data_to_point.(item.label, stats.whisker_high)

      anim = if(animate, do: "transform-box: fill-box; transform-origin: center; animation: phia-box-pop #{dur}ms ease-out #{gi * 80}ms both", else: "")
      x_left = cx - box_w / 2

      box_elements = [
        %{type: :box_whisker, x1: Float.round(cx * 1.0, 2), y1: Float.round(y_wl * 1.0, 2), x2: Float.round(cx * 1.0, 2), y2: Float.round(y_q1 * 1.0, 2), color: color, anim_style: anim},
        %{type: :box_whisker, x1: Float.round(cx * 1.0, 2), y1: Float.round(y_q3 * 1.0, 2), x2: Float.round(cx * 1.0, 2), y2: Float.round(y_wh * 1.0, 2), color: color, anim_style: anim},
        %{type: :box_cap, x1: Float.round(x_left, 2), y1: Float.round(y_wl * 1.0, 2), x2: Float.round(x_left + box_w, 2), y2: Float.round(y_wl * 1.0, 2), color: color, anim_style: anim},
        %{type: :box_cap, x1: Float.round(x_left, 2), y1: Float.round(y_wh * 1.0, 2), x2: Float.round(x_left + box_w, 2), y2: Float.round(y_wh * 1.0, 2), color: color, anim_style: anim},
        %{type: :box_rect, x: Float.round(x_left, 2), y: Float.round(min(y_q1, y_q3) * 1.0, 2), w: Float.round(box_w, 2), h: Float.round(abs(y_q1 - y_q3), 2), color: color, anim_style: anim},
        %{type: :box_median, x1: Float.round(x_left, 2), y1: Float.round(y_med * 1.0, 2), x2: Float.round(x_left + box_w, 2), y2: Float.round(y_med * 1.0, 2), color: color, anim_style: anim}
      ]

      outliers = Map.get(stats, :outliers, [])
      outlier_elements = Enum.map(outliers, fn val ->
        {_, y_out} = coord.data_to_point.(item.label, val)
        %{type: :box_outlier, cx: Float.round(cx * 1.0, 2), cy: Float.round(y_out * 1.0, 2), r: 3, color: color, anim_style: anim}
      end)

      box_elements ++ outlier_elements
    end)
  end

  def render(:lollipop, data, coord, opts) do
    color = Keyword.fetch!(opts, :color)
    animate = Keyword.get(opts, :animate, true)
    dur = Keyword.get(opts, :animation_duration, 600)
    dot_r = Keyword.get(opts, :dot_radius, 5)

    data
    |> Enum.with_index()
    |> Enum.flat_map(fn {item, gi} ->
      {cx, _} = coord.data_to_point.(item.label, 0)
      {_, y_val} = coord.data_to_point.(item.label, item.value)
      {_, y_base} = coord.data_to_point.(item.label, 0)
      anim = if(animate, do: "animation: phia-dot-pop #{dur}ms ease-out #{gi * 60}ms both", else: "")

      [
        %{type: :lollipop_stem, x1: Float.round(cx * 1.0, 2), y1: Float.round(y_base * 1.0, 2), x2: Float.round(cx * 1.0, 2), y2: Float.round(y_val * 1.0, 2), color: color, anim_style: anim},
        %{type: :lollipop_dot, cx: Float.round(cx * 1.0, 2), cy: Float.round(y_val * 1.0, 2), r: dot_r, color: color, anim_style: anim}
      ]
    end)
  end

  def render(:dumbbell, data, coord, opts) do
    color = Keyword.fetch!(opts, :color)
    animate = Keyword.get(opts, :animate, true)
    dur = Keyword.get(opts, :animation_duration, 600)
    dot_r = Keyword.get(opts, :dot_radius, 5)
    end_color = Keyword.get(opts, :end_color, color)

    data
    |> Enum.with_index()
    |> Enum.flat_map(fn {item, gi} ->
      {cx, _} = coord.data_to_point.(item.label, 0)
      start_val = Map.get(item, :start_value, Map.get(item, :value, 0))
      end_val = Map.get(item, :end_value, Map.get(item, :value, 0))
      {_, y_start} = coord.data_to_point.(item.label, start_val)
      {_, y_end} = coord.data_to_point.(item.label, end_val)
      anim = if(animate, do: "animation: phia-dot-pop #{dur}ms ease-out #{gi * 60}ms both", else: "")

      [
        %{type: :dumbbell_bar, x1: Float.round(cx * 1.0, 2), y1: Float.round(y_start * 1.0, 2), x2: Float.round(cx * 1.0, 2), y2: Float.round(y_end * 1.0, 2), color: color, anim_style: anim},
        %{type: :dumbbell_dot, cx: Float.round(cx * 1.0, 2), cy: Float.round(y_start * 1.0, 2), r: dot_r, color: color, anim_style: anim},
        %{type: :dumbbell_dot, cx: Float.round(cx * 1.0, 2), cy: Float.round(y_end * 1.0, 2), r: dot_r, color: end_color, anim_style: anim}
      ]
    end)
  end

  def render(:violin, _data, _coord, _opts) do
    # Violin plot rendering is handled directly in violin_plot.ex
    # This stub exists for xy_chart integration
    []
  end

  # ---------------------------------------------------------------------------
  # Private — cell overrides
  # ---------------------------------------------------------------------------

  defp maybe_apply_cells(elements, opts) do
    case Keyword.get(opts, :cells) do
      nil -> elements
      cells -> ChartCell.apply_cells(elements, cells)
    end
  end

  # ---------------------------------------------------------------------------
  # Private — animation helpers
  # ---------------------------------------------------------------------------

  defp bar_anim(false, _dur, _delay), do: ""

  defp bar_anim(true, dur, delay),
    do: "transform-box: fill-box; transform-origin: bottom; animation: phia-bar-grow #{dur}ms ease-out #{delay}ms both"

  defp line_anim(false, _dur, _delay, _len), do: ""

  defp line_anim(true, dur, delay, len),
    do: "stroke-dasharray: #{len}; stroke-dashoffset: #{len}; animation: phia-line-draw #{dur}ms ease-out #{delay}ms forwards"

  defp spline_anim(false, _dur, _delay, _len), do: ""

  defp spline_anim(true, dur, delay, len),
    do: "stroke-dasharray: #{len}; stroke-dashoffset: #{len}; animation: phia-line-draw #{dur}ms ease-out #{delay}ms forwards"
end
