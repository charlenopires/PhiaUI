defmodule PhiaUi.Components.Data.ChartSeriesRegistry do
  @moduledoc false
  # Extensible series type dispatch for chart rendering.
  # Replaces hardcoded build_elements in xy_chart.ex with pattern-matched renderers.
  # Inspired by eCharts registerChartView/SeriesModel registry.
  # Not registered in ComponentRegistry — internal only.

  alias PhiaUi.Components.Data.ChartHelpers

  @supported_types [:bar, :line, :area, :scatter]

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

    data
    |> Enum.with_index()
    |> Enum.map(fn {item, i} ->
      {px, py} = coord.data_to_point.(item.label, item.value)

      %{
        type: :scatter,
        cx: Float.round(px * 1.0, 2),
        cy: Float.round(py * 1.0, 2),
        r: symbol_size,
        color: color,
        anim_style: if(animate, do: "animation: phia-dot-pop #{dur}ms ease-out #{i * 60}ms both", else: "")
      }
    end)
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
end
