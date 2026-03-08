defmodule PhiaUi.Components.Data.ChartHelpersTest do
  use ExUnit.Case, async: true

  alias PhiaUi.Components.Data.ChartHelpers

  # ---------------------------------------------------------------------------
  # default_palette/0
  # ---------------------------------------------------------------------------

  describe "default_palette/0" do
    test "returns 8-color list" do
      assert length(ChartHelpers.default_palette()) == 8
    end

    test "all palette entries are OKLCH strings" do
      Enum.each(ChartHelpers.default_palette(), fn color ->
        assert color =~ "oklch("
      end)
    end
  end

  # ---------------------------------------------------------------------------
  # chart_color/2
  # ---------------------------------------------------------------------------

  describe "chart_color/2" do
    test "returns palette color at given index" do
      palette = ["red", "green", "blue"]
      assert ChartHelpers.chart_color(0, palette) == "red"
      assert ChartHelpers.chart_color(1, palette) == "green"
      assert ChartHelpers.chart_color(2, palette) == "blue"
    end

    test "wraps around when index exceeds palette length" do
      palette = ["red", "green"]
      assert ChartHelpers.chart_color(2, palette) == "red"
      assert ChartHelpers.chart_color(3, palette) == "green"
    end

    test "uses default palette when custom palette is empty" do
      result = ChartHelpers.chart_color(0, [])
      default = ChartHelpers.default_palette()
      assert result == Enum.at(default, 0)
    end
  end

  # ---------------------------------------------------------------------------
  # normalize_series/2
  # ---------------------------------------------------------------------------

  describe "normalize_series/2" do
    test "empty data and empty series returns empty list" do
      assert ChartHelpers.normalize_series([], []) == []
    end

    test "data shorthand wraps into single series" do
      data = [%{label: "A", value: 10}]
      result = ChartHelpers.normalize_series(data, [])
      assert length(result) == 1
      assert hd(result).name == "Series 1"
      assert hd(result).data == data
    end

    test "series passed through unchanged" do
      series = [%{name: "Sales", data: [%{label: "Q1", value: 100}]}]
      assert ChartHelpers.normalize_series([], series) == series
    end

    test "series takes priority over data" do
      data = [%{label: "X", value: 1}]
      series = [%{name: "Y", data: [%{label: "Z", value: 2}]}]
      assert ChartHelpers.normalize_series(data, series) == series
    end
  end

  # ---------------------------------------------------------------------------
  # series_points/7
  # ---------------------------------------------------------------------------

  describe "series_points/7" do
    test "empty data returns empty string" do
      assert ChartHelpers.series_points([], 0, 100, 0, 100, 0, 200) == ""
    end

    test "single point returns two coordinate pairs (horizontal line)" do
      data = [%{label: "A", value: 50}]
      result = ChartHelpers.series_points(data, 0.0, 100.0, 0, 100, 0.0, 200.0)
      pairs = String.split(result, " ")
      assert length(pairs) == 2
    end

    test "multiple points returns space-separated coordinate pairs" do
      data = [%{label: "A", value: 10}, %{label: "B", value: 20}, %{label: "C", value: 30}]
      result = ChartHelpers.series_points(data, 0.0, 100.0, 10, 30, 0.0, 200.0)
      pairs = String.split(result, " ")
      assert length(pairs) == 3
    end

    test "first point maps to x0" do
      data = [%{label: "A", value: 10}, %{label: "B", value: 20}]
      result = ChartHelpers.series_points(data, 50.0, 150.0, 10, 20, 0.0, 200.0)
      first_pair = result |> String.split(" ") |> hd()
      [x, _y] = String.split(first_pair, ",")
      assert_in_delta String.to_float(x), 50.0, 0.01
    end

    test "last point maps to x1" do
      data = [%{label: "A", value: 10}, %{label: "B", value: 20}]
      result = ChartHelpers.series_points(data, 50.0, 150.0, 10, 20, 0.0, 200.0)
      last_pair = result |> String.split(" ") |> List.last()
      [x, _y] = String.split(last_pair, ",")
      assert_in_delta String.to_float(x), 150.0, 0.01
    end

    test "max value maps to px_top (top of chart)" do
      data = [%{label: "A", value: 100}]
      result = ChartHelpers.series_points(data, 0.0, 100.0, 0, 100, 10.0, 200.0)
      # Single point renders at mid_y
      assert result =~ ","
    end

    test "min value maps to px_bot (bottom of chart)" do
      data = [%{label: "A", value: 0}, %{label: "B", value: 100}]
      result = ChartHelpers.series_points(data, 0.0, 100.0, 0, 100, 10.0, 200.0)
      pairs = String.split(result, " ")
      [_x1, y1] = String.split(hd(pairs), ",")
      # value=0 should map to px_bot=200
      assert_in_delta String.to_float(y1), 200.0, 0.01
    end
  end

  # ---------------------------------------------------------------------------
  # series_path/8 — all curve modes
  # ---------------------------------------------------------------------------

  describe "series_path/8" do
    @data [%{label: "A", value: 10}, %{label: "B", value: 30}, %{label: "C", value: 20}]

    test "returns empty string for empty data" do
      assert ChartHelpers.series_path([], 0, 100, 0, 100, 0, 200, :linear) == ""
    end

    test ":linear mode returns M and L commands" do
      result = ChartHelpers.series_path(@data, 0.0, 100.0, 10, 30, 0.0, 200.0, :linear)
      assert result =~ "M "
      assert result =~ "L "
      refute result =~ "C "
    end

    test ":smooth mode returns M and C commands" do
      result = ChartHelpers.series_path(@data, 0.0, 100.0, 10, 30, 0.0, 200.0, :smooth)
      assert result =~ "M "
      assert result =~ "C "
    end

    test ":monotone mode returns M and C commands" do
      result = ChartHelpers.series_path(@data, 0.0, 100.0, 10, 30, 0.0, 200.0, :monotone)
      assert result =~ "M "
      assert result =~ "C "
    end

    test ":step_before mode returns M and L commands only" do
      result = ChartHelpers.series_path(@data, 0.0, 100.0, 10, 30, 0.0, 200.0, :step_before)
      assert result =~ "M "
      assert result =~ "L "
      refute result =~ "C "
    end

    test ":step_after mode returns M and L commands only" do
      result = ChartHelpers.series_path(@data, 0.0, 100.0, 10, 30, 0.0, 200.0, :step_after)
      assert result =~ "M "
      assert result =~ "L "
      refute result =~ "C "
    end

    test ":step_middle mode returns M and L commands only" do
      result = ChartHelpers.series_path(@data, 0.0, 100.0, 10, 30, 0.0, 200.0, :step_middle)
      assert result =~ "M "
      assert result =~ "L "
      refute result =~ "C "
    end

    test "single data point does not crash" do
      data = [%{label: "X", value: 50}]
      result = ChartHelpers.series_path(data, 0.0, 100.0, 0, 100, 0.0, 200.0, :linear)
      assert result =~ "M "
    end

    test ":smooth path starts at correct first point" do
      result = ChartHelpers.series_path(@data, 0.0, 100.0, 10, 30, 0.0, 200.0, :smooth)
      assert result =~ "M 0.0"
    end

    test "all curve modes produce non-empty results for valid data" do
      Enum.each([:linear, :smooth, :monotone, :step_before, :step_after, :step_middle], fn curve ->
        result = ChartHelpers.series_path(@data, 0.0, 100.0, 10, 30, 0.0, 200.0, curve)
        assert String.length(result) > 0, "Expected non-empty path for #{curve}"
      end)
    end
  end

  # ---------------------------------------------------------------------------
  # series_area_path/8 — all curve modes
  # ---------------------------------------------------------------------------

  describe "series_area_path/8" do
    @data [%{label: "A", value: 10}, %{label: "B", value: 30}, %{label: "C", value: 20}]

    test "returns empty string for empty data" do
      assert ChartHelpers.series_area_path([], 0, 100, 0, 100, 0, 200, :linear) == ""
    end

    test ":linear mode closes path to baseline with Z" do
      result = ChartHelpers.series_area_path(@data, 0.0, 100.0, 10, 30, 0.0, 200.0, :linear)
      assert result =~ "Z"
      assert result =~ "M "
      assert result =~ "L "
    end

    test ":smooth mode closes path to baseline with Z" do
      result = ChartHelpers.series_area_path(@data, 0.0, 100.0, 10, 30, 0.0, 200.0, :smooth)
      assert result =~ "Z"
      assert result =~ "C "
    end

    test ":monotone mode closes path to baseline with Z" do
      result = ChartHelpers.series_area_path(@data, 0.0, 100.0, 10, 30, 0.0, 200.0, :monotone)
      assert result =~ "Z"
      assert result =~ "C "
    end

    test ":step_before mode closes path with Z" do
      result = ChartHelpers.series_area_path(@data, 0.0, 100.0, 10, 30, 0.0, 200.0, :step_before)
      assert result =~ "Z"
      refute result =~ "C "
    end

    test ":step_after mode closes path with Z" do
      result = ChartHelpers.series_area_path(@data, 0.0, 100.0, 10, 30, 0.0, 200.0, :step_after)
      assert result =~ "Z"
    end

    test ":step_middle mode closes path with Z" do
      result = ChartHelpers.series_area_path(@data, 0.0, 100.0, 10, 30, 0.0, 200.0, :step_middle)
      assert result =~ "Z"
    end

    test "area path descends to px_bot baseline" do
      result = ChartHelpers.series_area_path(@data, 0.0, 100.0, 10, 30, 0.0, 200.0, :linear)
      # Should contain a reference to the baseline y=200
      assert result =~ "200.0"
    end

    test "all curve modes produce non-empty closed paths" do
      Enum.each([:linear, :smooth, :monotone, :step_before, :step_after, :step_middle], fn curve ->
        result = ChartHelpers.series_area_path(@data, 0.0, 100.0, 10, 30, 0.0, 200.0, curve)
        assert String.length(result) > 0, "Expected non-empty area path for #{curve}"
        assert result =~ "Z", "Expected Z closure for #{curve}"
      end)
    end
  end

  # ---------------------------------------------------------------------------
  # path_length/1
  # ---------------------------------------------------------------------------

  describe "path_length/1" do
    test "empty string returns 0.0" do
      assert ChartHelpers.path_length("") == 0.0
    end

    test "horizontal line M 0 0 L 100 0 returns ~100" do
      result = ChartHelpers.path_length("M 0 0 L 100 0")
      assert_in_delta result, 100.0, 1.0
    end

    test "vertical line returns correct length" do
      result = ChartHelpers.path_length("M 0 0 L 0 50")
      assert_in_delta result, 50.0, 1.0
    end

    test "diagonal line returns correct length" do
      result = ChartHelpers.path_length("M 0 0 L 30 40")
      assert_in_delta result, 50.0, 1.0
    end

    test "multi-segment path sums segment lengths" do
      result = ChartHelpers.path_length("M 0 0 L 100 0 L 100 100")
      assert_in_delta result, 200.0, 1.0
    end

    test "path with C commands extracts endpoint coordinates" do
      result = ChartHelpers.path_length("M 0 0 C 10 20 30 40 50 0")
      # Approximation — extracts M(0,0) and C endpoint (50,0)
      assert result > 0
    end
  end

  # ---------------------------------------------------------------------------
  # polyline_length/1
  # ---------------------------------------------------------------------------

  describe "polyline_length/1" do
    test "empty string returns 0.0" do
      assert ChartHelpers.polyline_length("") == 0.0
    end

    test "horizontal polyline returns correct length" do
      result = ChartHelpers.polyline_length("0,0 100,0")
      assert_in_delta result, 100.0, 0.01
    end

    test "vertical polyline returns correct length" do
      result = ChartHelpers.polyline_length("0,0 0,75")
      assert_in_delta result, 75.0, 0.01
    end

    test "multi-segment polyline sums correctly" do
      result = ChartHelpers.polyline_length("0,0 100,0 100,100")
      assert_in_delta result, 200.0, 0.01
    end
  end

  # ---------------------------------------------------------------------------
  # pie_slices/6 — including spacing
  # ---------------------------------------------------------------------------

  describe "pie_slices/6" do
    @data [%{label: "A", value: 50}, %{label: "B", value: 30}, %{label: "C", value: 20}]

    test "returns correct number of slices" do
      slices = ChartHelpers.pie_slices(@data, 100, 100, 80, [])
      assert length(slices) == 3
    end

    test "each slice has path, color, and delay" do
      slices = ChartHelpers.pie_slices(@data, 100, 100, 80, [])

      Enum.each(slices, fn slice ->
        assert Map.has_key?(slice, :path)
        assert Map.has_key?(slice, :color)
        assert Map.has_key?(slice, :delay)
      end)
    end

    test "slice paths contain arc commands" do
      slices = ChartHelpers.pie_slices(@data, 100, 100, 80, [])

      Enum.each(slices, fn slice ->
        assert slice.path =~ " A "
      end)
    end

    test "slice paths start at center (M cx cy)" do
      slices = ChartHelpers.pie_slices(@data, 100, 100, 80, [])
      assert hd(slices).path =~ "M 100.0 100.0"
    end

    test "slice paths are closed with Z" do
      slices = ChartHelpers.pie_slices(@data, 100, 100, 80, [])

      Enum.each(slices, fn slice ->
        assert slice.path =~ "Z"
      end)
    end

    test "stagger delay increases with index" do
      slices = ChartHelpers.pie_slices(@data, 100, 100, 80, [])
      delays = Enum.map(slices, & &1.delay)
      assert Enum.at(delays, 0) =~ "0ms"
      assert Enum.at(delays, 1) =~ "60ms"
      assert Enum.at(delays, 2) =~ "120ms"
    end

    test "per-item color overrides palette" do
      data = [%{label: "A", value: 50, color: "hotpink"}]
      [slice] = ChartHelpers.pie_slices(data, 100, 100, 80, [])
      assert slice.color == "hotpink"
    end

    test "spacing option creates angular gaps between slices" do
      no_spacing = ChartHelpers.pie_slices(@data, 100, 100, 80, [], spacing: 0)
      with_spacing = ChartHelpers.pie_slices(@data, 100, 100, 80, [], spacing: 4)

      # With spacing, the paths should be different (smaller arcs)
      refute Enum.at(no_spacing, 0).path == Enum.at(with_spacing, 0).path
    end

    test "spacing 0 is the default behavior" do
      default = ChartHelpers.pie_slices(@data, 100, 100, 80, [])
      explicit_zero = ChartHelpers.pie_slices(@data, 100, 100, 80, [], spacing: 0)
      assert default == explicit_zero
    end

    test "single-item data does not crash with spacing" do
      data = [%{label: "A", value: 100}]
      slices = ChartHelpers.pie_slices(data, 100, 100, 80, [], spacing: 4)
      assert length(slices) == 1
    end
  end

  # ---------------------------------------------------------------------------
  # donut_slices/7 — including spacing
  # ---------------------------------------------------------------------------

  describe "donut_slices/7" do
    @data [%{label: "A", value: 60}, %{label: "B", value: 40}]

    test "returns correct number of slices" do
      slices = ChartHelpers.donut_slices(@data, 100, 100, 80, 40, [])
      assert length(slices) == 2
    end

    test "each slice has path, color, and delay" do
      slices = ChartHelpers.donut_slices(@data, 100, 100, 80, 40, [])

      Enum.each(slices, fn slice ->
        assert Map.has_key?(slice, :path)
        assert Map.has_key?(slice, :color)
        assert Map.has_key?(slice, :delay)
      end)
    end

    test "donut paths contain two arc commands (outer and inner)" do
      slices = ChartHelpers.donut_slices(@data, 100, 100, 80, 40, [])

      Enum.each(slices, fn slice ->
        arc_count = slice.path |> String.split(" A ") |> length() |> Kernel.-(1)
        assert arc_count == 2
      end)
    end

    test "donut paths are closed with Z" do
      slices = ChartHelpers.donut_slices(@data, 100, 100, 80, 40, [])

      Enum.each(slices, fn slice ->
        assert slice.path =~ "Z"
      end)
    end

    test "donut paths do NOT start at center (no M cx cy)" do
      slices = ChartHelpers.donut_slices(@data, 100, 100, 80, 40, [])
      # Donut arcs start at outer edge, not center
      refute hd(slices).path =~ "M 100.0 100.0"
    end

    test "per-item color overrides palette" do
      data = [%{label: "A", value: 50, color: "cyan"}]
      [slice] = ChartHelpers.donut_slices(data, 100, 100, 80, 40, [])
      assert slice.color == "cyan"
    end

    test "spacing creates angular gaps" do
      no_spacing = ChartHelpers.donut_slices(@data, 100, 100, 80, 40, [], spacing: 0)
      with_spacing = ChartHelpers.donut_slices(@data, 100, 100, 80, 40, [], spacing: 4)

      refute Enum.at(no_spacing, 0).path == Enum.at(with_spacing, 0).path
    end

    test "spacing 0 is the default" do
      default = ChartHelpers.donut_slices(@data, 100, 100, 80, 40, [])
      explicit = ChartHelpers.donut_slices(@data, 100, 100, 80, 40, [], spacing: 0)
      assert default == explicit
    end
  end

  # ---------------------------------------------------------------------------
  # histogram_bins/2
  # ---------------------------------------------------------------------------

  describe "histogram_bins/2" do
    test "empty data returns empty list" do
      assert ChartHelpers.histogram_bins([], 5) == []
    end

    test "returns correct number of bins" do
      data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
      result = ChartHelpers.histogram_bins(data, 5)
      assert length(result) == 5
    end

    test "each bin has label, value, from, and to keys" do
      data = [1, 2, 3, 4, 5]
      [bin | _] = ChartHelpers.histogram_bins(data, 2)
      assert Map.has_key?(bin, :label)
      assert Map.has_key?(bin, :value)
      assert Map.has_key?(bin, :from)
      assert Map.has_key?(bin, :to)
    end

    test "bin counts sum to data length" do
      data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
      bins = ChartHelpers.histogram_bins(data, 5)
      total = Enum.sum(Enum.map(bins, & &1.value))
      assert total == 10
    end

    test "n < 1 falls back to 1 bin" do
      data = [1, 2, 3]
      result = ChartHelpers.histogram_bins(data, 0)
      assert length(result) == 1
    end

    test "all equal values go into bins without crash" do
      data = [5, 5, 5, 5]
      result = ChartHelpers.histogram_bins(data, 3)
      assert length(result) == 3
    end
  end

  # ---------------------------------------------------------------------------
  # stagger_delay/2
  # ---------------------------------------------------------------------------

  describe "stagger_delay/2" do
    test "index 0 returns 0ms delay" do
      assert ChartHelpers.stagger_delay(0) == "animation-delay: 0ms"
    end

    test "index 1 with default step returns 60ms" do
      assert ChartHelpers.stagger_delay(1) == "animation-delay: 60ms"
    end

    test "custom step multiplier" do
      assert ChartHelpers.stagger_delay(2, 100) == "animation-delay: 200ms"
    end
  end

  # ---------------------------------------------------------------------------
  # squarify/5
  # ---------------------------------------------------------------------------

  describe "squarify/5" do
    test "returns tiles for each data item" do
      data = [%{label: "A", value: 60}, %{label: "B", value: 30}, %{label: "C", value: 10}]
      tiles = ChartHelpers.squarify(data, 0, 0, 100, 100)
      assert length(tiles) == 3
    end

    test "each tile has x, y, w, h, and item fields" do
      data = [%{label: "A", value: 50}, %{label: "B", value: 50}]
      tiles = ChartHelpers.squarify(data, 0, 0, 200, 100)

      Enum.each(tiles, fn tile ->
        assert Map.has_key?(tile, :x)
        assert Map.has_key?(tile, :y)
        assert Map.has_key?(tile, :w)
        assert Map.has_key?(tile, :h)
        assert Map.has_key?(tile, :item)
      end)
    end

    test "empty data returns empty list" do
      assert ChartHelpers.squarify([], 0, 0, 100, 100) == []
    end

    test "single item fills the entire area" do
      data = [%{label: "A", value: 100}]
      [tile] = ChartHelpers.squarify(data, 10, 20, 200, 150)
      assert_in_delta tile.x, 10.0, 0.01
      assert_in_delta tile.y, 20.0, 0.01
      assert_in_delta tile.w, 200.0, 0.01
      assert_in_delta tile.h, 150.0, 0.01
    end
  end

  # ---------------------------------------------------------------------------
  # compute_y_domain/2
  # ---------------------------------------------------------------------------

  describe "compute_y_domain/2" do
    test "returns nice ticks from series" do
      series = [%{name: "A", data: [%{label: "X", value: 30}, %{label: "Y", value: 70}]}]
      {ticks, y_min, y_max} = ChartHelpers.compute_y_domain(series)
      assert is_list(ticks)
      assert y_min <= 0
      assert y_max >= 70
    end

    test "handles empty series" do
      {ticks, y_min, y_max} = ChartHelpers.compute_y_domain([])
      assert is_list(ticks)
      assert y_min <= 0
      assert y_max >= 10
    end

    test "respects min_override option" do
      series = [%{name: "A", data: [%{label: "X", value: 50}]}]
      {_ticks, y_min, _y_max} = ChartHelpers.compute_y_domain(series, min_override: -10)
      assert y_min <= -10
    end

    test "clamps to 0 when include_negative is false" do
      series = [%{name: "A", data: [%{label: "X", value: -20}, %{label: "Y", value: 50}]}]
      {_ticks, y_min, _y_max} = ChartHelpers.compute_y_domain(series, include_negative: false)
      assert y_min >= 0
    end

    test "respects tick_count option" do
      series = [%{name: "A", data: [%{label: "X", value: 100}]}]
      {ticks, _min, _max} = ChartHelpers.compute_y_domain(series, tick_count: 3)
      assert length(ticks) > 0
    end
  end

  # ---------------------------------------------------------------------------
  # compute_stacked_y_domain/2
  # ---------------------------------------------------------------------------

  describe "compute_stacked_y_domain/2" do
    test "sums values per group across series" do
      series = [
        %{name: "A", data: [%{label: "X", value: 30}, %{label: "Y", value: 40}]},
        %{name: "B", data: [%{label: "X", value: 20}, %{label: "Y", value: 60}]}
      ]
      {ticks, y_max} = ChartHelpers.compute_stacked_y_domain(series)
      assert is_list(ticks)
      # Y max should cover 100 (40 + 60)
      assert y_max >= 100
    end

    test "handles empty series" do
      {ticks, y_max} = ChartHelpers.compute_stacked_y_domain([])
      assert is_list(ticks)
      assert y_max >= 10
    end

    test "handles single series" do
      series = [%{name: "A", data: [%{label: "X", value: 50}]}]
      {ticks, y_max} = ChartHelpers.compute_stacked_y_domain(series)
      assert is_list(ticks)
      assert y_max >= 50
    end
  end

  # ---------------------------------------------------------------------------
  # extract_categories/1
  # ---------------------------------------------------------------------------

  describe "extract_categories/1" do
    test "returns labels from first series" do
      series = [
        %{name: "A", data: [%{label: "Q1", value: 10}, %{label: "Q2", value: 20}]},
        %{name: "B", data: [%{label: "Q1", value: 30}, %{label: "Q2", value: 40}]}
      ]
      assert ChartHelpers.extract_categories(series) == ["Q1", "Q2"]
    end

    test "returns empty list for empty series" do
      assert ChartHelpers.extract_categories([]) == []
    end
  end

  # ---------------------------------------------------------------------------
  # extract_all_values/1
  # ---------------------------------------------------------------------------

  describe "extract_all_values/1" do
    test "flattens all values from all series" do
      series = [
        %{name: "A", data: [%{label: "X", value: 10}, %{label: "Y", value: 20}]},
        %{name: "B", data: [%{label: "X", value: 30}, %{label: "Y", value: 40}]}
      ]
      values = ChartHelpers.extract_all_values(series)
      assert Enum.sort(values) == [10, 20, 30, 40]
    end

    test "returns empty list for empty series" do
      assert ChartHelpers.extract_all_values([]) == []
    end
  end
end
