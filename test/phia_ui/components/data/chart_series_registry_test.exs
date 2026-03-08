defmodule PhiaUi.Components.Data.ChartSeriesRegistryTest do
  use ExUnit.Case, async: true

  alias PhiaUi.Components.Data.ChartSeriesRegistry
  alias PhiaUi.Components.Data.ChartCoord
  alias PhiaUi.Components.Data.ChartViewport
  alias PhiaUi.Components.Data.ChartScales

  @sample_data [
    %{label: "Q1", value: 100},
    %{label: "Q2", value: 200},
    %{label: "Q3", value: 150}
  ]

  defp build_coord do
    vp = ChartViewport.build([])
    categories = ["Q1", "Q2", "Q3"]
    x_result = ChartScales.band_scale(categories, vp.pl, vp.pl + vp.cw)
    y_scale = ChartScales.linear_scale(0, 250, vp.pt + vp.ch, vp.pt)
    coord = ChartCoord.cartesian2d(vp, x_result.scale, y_scale)
    Map.put(coord, :bandwidth, x_result.bandwidth)
  end

  describe "types/0" do
    test "returns supported types" do
      types = ChartSeriesRegistry.types()
      assert :bar in types
      assert :line in types
      assert :area in types
      assert :scatter in types
    end
  end

  describe "supported?/1" do
    test "returns true for supported types" do
      assert ChartSeriesRegistry.supported?(:bar)
      assert ChartSeriesRegistry.supported?(:line)
      assert ChartSeriesRegistry.supported?(:area)
      assert ChartSeriesRegistry.supported?(:scatter)
    end

    test "returns false for unsupported types" do
      refute ChartSeriesRegistry.supported?(:candlestick)
      refute ChartSeriesRegistry.supported?(:treemap)
    end
  end

  describe "render(:bar, ...)" do
    test "returns bar element maps" do
      coord = build_coord()
      elements = ChartSeriesRegistry.render(:bar, @sample_data, coord, color: "red")

      assert length(elements) == 3
      assert Enum.all?(elements, fn e -> e.type == :bar end)
    end

    test "bar elements have required fields" do
      coord = build_coord()
      [first | _] = ChartSeriesRegistry.render(:bar, @sample_data, coord, color: "blue")

      assert is_float(first.x)
      assert is_float(first.y)
      assert is_float(first.w)
      assert is_float(first.h)
      assert first.color == "blue"
      assert is_binary(first.anim_style)
    end

    test "grouped bars offset by bar_index" do
      coord = build_coord()
      bars_0 = ChartSeriesRegistry.render(:bar, @sample_data, coord, color: "red", bar_index: 0, n_bar_series: 2)
      bars_1 = ChartSeriesRegistry.render(:bar, @sample_data, coord, color: "blue", bar_index: 1, n_bar_series: 2)

      first_0 = hd(bars_0)
      first_1 = hd(bars_1)

      assert first_0.x != first_1.x
      assert first_0.w == first_1.w
    end

    test "no animation when animate is false" do
      coord = build_coord()
      [first | _] = ChartSeriesRegistry.render(:bar, @sample_data, coord, color: "red", animate: false)
      assert first.anim_style == ""
    end

    test "custom bar_radius" do
      coord = build_coord()
      [first | _] = ChartSeriesRegistry.render(:bar, @sample_data, coord, color: "red", bar_radius: 4)
      assert first.rx == 4
    end
  end

  describe "render(:line, ...)" do
    test "returns single line element" do
      coord = build_coord()
      elements = ChartSeriesRegistry.render(:line, @sample_data, coord, color: "green")

      assert length(elements) == 1
      assert hd(elements).type == :line
    end

    test "line element has points string" do
      coord = build_coord()
      [line] = ChartSeriesRegistry.render(:line, @sample_data, coord, color: "green")

      assert is_binary(line.points)
      assert line.points =~ ","
    end

    test "line element has color and stroke_width" do
      coord = build_coord()
      [line] = ChartSeriesRegistry.render(:line, @sample_data, coord, color: "green", stroke_width: 3)

      assert line.color == "green"
      assert line.stroke_width == 3
    end

    test "no animation when animate is false" do
      coord = build_coord()
      [line] = ChartSeriesRegistry.render(:line, @sample_data, coord, color: "green", animate: false)
      assert line.anim_style == ""
    end
  end

  describe "render(:area, ...)" do
    test "returns single area element" do
      coord = build_coord()
      elements = ChartSeriesRegistry.render(:area, @sample_data, coord, color: "blue")

      assert length(elements) == 1
      assert hd(elements).type == :area
    end

    test "area element has path_d" do
      coord = build_coord()
      [area] = ChartSeriesRegistry.render(:area, @sample_data, coord, color: "blue")

      assert is_binary(area.path_d)
      assert area.path_d =~ "M"
      assert area.path_d =~ "Z"
    end

    test "area element has color" do
      coord = build_coord()
      [area] = ChartSeriesRegistry.render(:area, @sample_data, coord, color: "blue")
      assert area.color == "blue"
    end

    test "no animation when animate is false" do
      coord = build_coord()
      [area] = ChartSeriesRegistry.render(:area, @sample_data, coord, color: "blue", animate: false)
      assert area.anim_style == ""
    end
  end

  describe "render(:scatter, ...)" do
    test "returns scatter element per data point" do
      coord = build_coord()
      elements = ChartSeriesRegistry.render(:scatter, @sample_data, coord, color: "orange")

      assert length(elements) == 3
      assert Enum.all?(elements, fn e -> e.type == :scatter end)
    end

    test "scatter elements have cx, cy, r" do
      coord = build_coord()
      [first | _] = ChartSeriesRegistry.render(:scatter, @sample_data, coord, color: "orange")

      assert is_float(first.cx)
      assert is_float(first.cy)
      assert first.r == 5
    end

    test "custom symbol_size" do
      coord = build_coord()
      [first | _] = ChartSeriesRegistry.render(:scatter, @sample_data, coord, color: "orange", symbol_size: 8)
      assert first.r == 8
    end

    test "no animation when animate is false" do
      coord = build_coord()
      [first | _] = ChartSeriesRegistry.render(:scatter, @sample_data, coord, color: "orange", animate: false)
      assert first.anim_style == ""
    end
  end
end
