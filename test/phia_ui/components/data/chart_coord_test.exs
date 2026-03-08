defmodule PhiaUi.Components.Data.ChartCoordTest do
  use ExUnit.Case, async: true

  alias PhiaUi.Components.Data.ChartCoord
  alias PhiaUi.Components.Data.ChartScales
  alias PhiaUi.Components.Data.ChartViewport

  describe "cartesian2d/3" do
    test "creates a cartesian coordinate system" do
      vp = ChartViewport.build([])
      x_scale = ChartScales.linear_scale(0, 100, vp.pl, vp.pl + vp.cw)
      y_scale = ChartScales.linear_scale(0, 100, vp.pt + vp.ch, vp.pt)

      coord = ChartCoord.cartesian2d(vp, x_scale, y_scale)

      assert coord.type == :cartesian2d
      assert is_function(coord.data_to_point, 2)
      assert is_function(coord.point_to_data, 2)
      assert is_function(coord.contain_point, 2)
      assert is_map(coord.area)
    end

    test "data_to_point maps data values to pixel positions" do
      vp = ChartViewport.build([])
      x_scale = ChartScales.linear_scale(0, 100, vp.pl, vp.pl + vp.cw)
      y_scale = ChartScales.linear_scale(0, 100, vp.pt + vp.ch, vp.pt)

      coord = ChartCoord.cartesian2d(vp, x_scale, y_scale)
      {px, py} = coord.data_to_point.(0, 0)

      assert_in_delta px, vp.pl, 0.1
      assert_in_delta py, vp.pt + vp.ch, 0.1
    end

    test "data_to_point maps max values to far edges" do
      vp = ChartViewport.build([])
      x_scale = ChartScales.linear_scale(0, 100, vp.pl, vp.pl + vp.cw)
      y_scale = ChartScales.linear_scale(0, 100, vp.pt + vp.ch, vp.pt)

      coord = ChartCoord.cartesian2d(vp, x_scale, y_scale)
      {px, py} = coord.data_to_point.(100, 100)

      assert_in_delta px, vp.pl + vp.cw, 0.1
      assert_in_delta py, vp.pt, 0.1
    end

    test "contain_point returns true for points inside chart area" do
      vp = ChartViewport.build([])
      x_scale = ChartScales.linear_scale(0, 100, vp.pl, vp.pl + vp.cw)
      y_scale = ChartScales.linear_scale(0, 100, vp.pt + vp.ch, vp.pt)

      coord = ChartCoord.cartesian2d(vp, x_scale, y_scale)

      assert coord.contain_point.(vp.pl + 10, vp.pt + 10) == true
    end

    test "contain_point returns false for points outside chart area" do
      vp = ChartViewport.build([])
      x_scale = ChartScales.linear_scale(0, 100, vp.pl, vp.pl + vp.cw)
      y_scale = ChartScales.linear_scale(0, 100, vp.pt + vp.ch, vp.pt)

      coord = ChartCoord.cartesian2d(vp, x_scale, y_scale)

      assert coord.contain_point.(0, 0) == false
    end

    test "area returns chart dimensions" do
      vp = ChartViewport.build([])
      x_scale = ChartScales.linear_scale(0, 100, vp.pl, vp.pl + vp.cw)
      y_scale = ChartScales.linear_scale(0, 100, vp.pt + vp.ch, vp.pt)

      coord = ChartCoord.cartesian2d(vp, x_scale, y_scale)

      assert coord.area.x == vp.pl
      assert coord.area.y == vp.pt
      assert coord.area.width == vp.cw
      assert coord.area.height == vp.ch
    end
  end

  describe "polar/3" do
    test "creates a polar coordinate system" do
      vp = ChartViewport.default_polar()
      r_scale = ChartScales.linear_scale(0, 100, 0, vp.r)

      coord = ChartCoord.polar(vp, r_scale)

      assert coord.type == :polar
      assert is_function(coord.data_to_point, 2)
      assert is_function(coord.point_to_data, 2)
      assert is_function(coord.contain_point, 2)
      assert coord.center == {vp.cx, vp.cy}
      assert coord.max_radius == vp.r
    end

    test "data_to_point maps angle and radius to pixels" do
      vp = ChartViewport.default_polar()
      r_scale = ChartScales.linear_scale(0, 100, 0, vp.r)

      coord = ChartCoord.polar(vp, r_scale)
      # At angle 0 (right), full radius
      {px, py} = coord.data_to_point.(0, 100)

      assert_in_delta px, vp.cx + vp.r, 0.1
      assert_in_delta py, vp.cy, 0.1
    end

    test "data_to_point at center has zero radius" do
      vp = ChartViewport.default_polar()
      r_scale = ChartScales.linear_scale(0, 100, 0, vp.r)

      coord = ChartCoord.polar(vp, r_scale)
      {px, py} = coord.data_to_point.(0, 0)

      assert_in_delta px, vp.cx, 0.1
      assert_in_delta py, vp.cy, 0.1
    end

    test "contain_point returns true inside circle" do
      vp = ChartViewport.default_polar()
      r_scale = ChartScales.linear_scale(0, 100, 0, vp.r)

      coord = ChartCoord.polar(vp, r_scale)

      assert coord.contain_point.(vp.cx, vp.cy) == true
      assert coord.contain_point.(vp.cx + vp.r - 1, vp.cy) == true
    end

    test "contain_point returns false outside circle" do
      vp = ChartViewport.default_polar()
      r_scale = ChartScales.linear_scale(0, 100, 0, vp.r)

      coord = ChartCoord.polar(vp, r_scale)

      assert coord.contain_point.(vp.cx + vp.r + 10, vp.cy) == false
    end

    test "point_to_data inverts polar coordinates" do
      vp = ChartViewport.default_polar()
      r_scale = ChartScales.linear_scale(0, 100, 0, vp.r)

      coord = ChartCoord.polar(vp, r_scale)
      {angle, radius} = coord.point_to_data.(vp.cx + vp.r, vp.cy)

      assert_in_delta angle, 0.0, 0.01
      assert_in_delta radius, vp.r, 0.1
    end
  end

  describe "auto_cartesian/2" do
    test "creates coord from series data" do
      series = [
        %{name: "Revenue", data: [%{label: "Q1", value: 100}, %{label: "Q2", value: 200}]}
      ]

      {coord, categories, y_ticks, {y_min, y_max}} = ChartCoord.auto_cartesian(series)

      assert coord.type == :cartesian2d
      assert categories == ["Q1", "Q2"]
      assert is_list(y_ticks)
      assert length(y_ticks) > 0
      assert y_min <= 0
      assert y_max >= 200
    end

    test "returns bandwidth for bar layout" do
      series = [
        %{name: "S1", data: [%{label: "A", value: 50}, %{label: "B", value: 80}]}
      ]

      {coord, _cats, _ticks, _range} = ChartCoord.auto_cartesian(series)

      assert Map.has_key?(coord, :bandwidth)
      assert coord.bandwidth > 0
    end

    test "custom viewport override" do
      series = [%{name: "S1", data: [%{label: "A", value: 10}]}]
      vp = ChartViewport.build(vw: 600, vh: 400)

      {coord, _cats, _ticks, _range} = ChartCoord.auto_cartesian(series, viewport: vp)

      assert coord.area.width == vp.cw
    end

    test "handles empty series" do
      {coord, categories, y_ticks, _range} = ChartCoord.auto_cartesian([])

      assert coord.type == :cartesian2d
      assert categories == []
      assert is_list(y_ticks)
    end

    test "linear x_type option" do
      series = [
        %{name: "S1", data: [%{label: "A", value: 10}, %{label: "B", value: 20}]}
      ]

      {coord, _cats, _ticks, _range} = ChartCoord.auto_cartesian(series, x_type: :linear)
      assert coord.type == :cartesian2d
    end
  end

  describe "auto_polar/2" do
    test "creates polar coord from values" do
      values = [10, 20, 30, 40, 50]

      {coord, ticks} = ChartCoord.auto_polar(values)

      assert coord.type == :polar
      assert is_list(ticks)
      assert Enum.max(ticks) >= 50
    end

    test "handles empty values" do
      {coord, ticks} = ChartCoord.auto_polar([])

      assert coord.type == :polar
      assert is_list(ticks)
    end

    test "custom viewport" do
      values = [100, 200]
      vp = ChartViewport.default_polar(r: 120)

      {coord, _ticks} = ChartCoord.auto_polar(values, viewport: vp)

      assert coord.max_radius == 120
    end
  end
end
