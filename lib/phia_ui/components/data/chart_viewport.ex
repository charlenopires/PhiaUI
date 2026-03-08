defmodule PhiaUi.Components.Data.ChartViewport do
  @moduledoc false
  # Shared viewport configuration for chart components.
  # Replaces duplicated @vw/@vh/@pl/@pr/@pt/@pb module attributes.
  # Not registered in ComponentRegistry — internal only.

  @doc """
  Returns the default XY chart viewport.
  Used by: bar_chart, line_chart, area_chart, scatter_chart, bubble_chart, histogram_chart, waterfall_chart.
  """
  def default_xy do
    %{vw: 400, vh: 300, pl: 44, pr: 16, pt: 16, pb: 40, cw: 340, ch: 244}
  end

  @doc """
  Returns the default polar chart viewport.
  Used by: pie_chart, donut_chart, polar_area_chart.
  """
  def default_polar(opts \\ []) do
    vw = Keyword.get(opts, :vw, 300)
    vh = Keyword.get(opts, :vh, 220)
    cx = Keyword.get(opts, :cx, 110)
    cy = Keyword.get(opts, :cy, 110)
    r = Keyword.get(opts, :r, 90)
    %{vw: vw, vh: vh, cx: cx, cy: cy, r: r}
  end

  @doc """
  Builds a viewport map by merging overrides onto the default XY viewport.
  Automatically recomputes :cw and :ch from the updated dimensions.

  ## Examples

      iex> ChartViewport.build([])
      %{vw: 400, vh: 300, pl: 44, pr: 16, pt: 16, pb: 40, cw: 340, ch: 244}

      iex> ChartViewport.build(vw: 420, pl: 48)
      %{vw: 420, vh: 300, pl: 48, pr: 16, pt: 16, pb: 40, cw: 356, ch: 244}
  """
  def build(opts \\ []) do
    base = default_xy()
    merged = Enum.reduce(opts, base, fn {k, v}, acc -> Map.put(acc, k, v) end)
    # Recompute derived dimensions
    cw = merged.vw - merged.pl - merged.pr
    ch = merged.vh - merged.pt - merged.pb
    %{merged | cw: cw, ch: ch}
  end

  @doc """
  Returns the SVG viewBox string for a viewport map.
  """
  def viewbox(%{vw: vw, vh: vh}), do: "0 0 #{vw} #{vh}"
end
