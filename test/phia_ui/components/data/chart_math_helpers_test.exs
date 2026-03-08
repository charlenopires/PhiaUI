defmodule PhiaUi.Components.Data.ChartMathHelpersTest do
  use ExUnit.Case, async: true

  alias PhiaUi.Components.Data.ChartMathHelpers

  # ---------------------------------------------------------------------------
  # bezier_control_points/2
  # ---------------------------------------------------------------------------

  describe "bezier_control_points/2" do
    test "returns empty list for empty input" do
      assert ChartMathHelpers.bezier_control_points([], 0.4) == []
    end

    test "single point returns identity control points" do
      pt = %{x: 10.0, y: 20.0}
      result = ChartMathHelpers.bezier_control_points([pt], 0.4)
      assert length(result) == 1
      [cp] = result
      assert cp.x == 10.0
      assert cp.y == 20.0
      assert cp.cp1x == 10.0
      assert cp.cp1y == 20.0
      assert cp.cp2x == 10.0
      assert cp.cp2y == 20.0
    end

    test "two points produce two control-point maps" do
      points = [%{x: 0.0, y: 0.0}, %{x: 10.0, y: 10.0}]
      result = ChartMathHelpers.bezier_control_points(points, 0.4)
      assert length(result) == 2
      Enum.each(result, fn cp ->
        assert Map.has_key?(cp, :cp1x)
        assert Map.has_key?(cp, :cp1y)
        assert Map.has_key?(cp, :cp2x)
        assert Map.has_key?(cp, :cp2y)
      end)
    end

    test "preserves original x,y coordinates" do
      points = [%{x: 5.0, y: 15.0}, %{x: 10.0, y: 25.0}, %{x: 20.0, y: 5.0}]
      result = ChartMathHelpers.bezier_control_points(points, 0.4)
      assert Enum.at(result, 0).x == 5.0
      assert Enum.at(result, 0).y == 15.0
      assert Enum.at(result, 1).x == 10.0
      assert Enum.at(result, 1).y == 25.0
      assert Enum.at(result, 2).x == 20.0
      assert Enum.at(result, 2).y == 5.0
    end

    test "tension 0.0 produces control points equal to data points" do
      points = [%{x: 0.0, y: 0.0}, %{x: 10.0, y: 10.0}, %{x: 20.0, y: 0.0}]
      result = ChartMathHelpers.bezier_control_points(points, 0.0)
      Enum.each(result, fn cp ->
        assert cp.cp1x == cp.x
        assert cp.cp1y == cp.y
        assert cp.cp2x == cp.x
        assert cp.cp2y == cp.y
      end)
    end

    test "higher tension produces wider control point spread" do
      points = [%{x: 0.0, y: 0.0}, %{x: 10.0, y: 10.0}, %{x: 20.0, y: 0.0}]
      low = ChartMathHelpers.bezier_control_points(points, 0.1)
      high = ChartMathHelpers.bezier_control_points(points, 0.8)

      # Middle point should have wider spread with higher tension
      low_mid = Enum.at(low, 1)
      high_mid = Enum.at(high, 1)
      low_spread = abs(low_mid.cp2x - low_mid.cp1x)
      high_spread = abs(high_mid.cp2x - high_mid.cp1x)
      assert high_spread > low_spread
    end

    test "multiple points returns correct count" do
      points = Enum.map(0..9, fn i -> %{x: i * 10.0, y: :math.sin(i) * 50 + 50} end)
      result = ChartMathHelpers.bezier_control_points(points, 0.4)
      assert length(result) == 10
    end

    test "default tension is 0.4 when omitted" do
      points = [%{x: 0.0, y: 0.0}, %{x: 10.0, y: 10.0}, %{x: 20.0, y: 0.0}]
      with_default = ChartMathHelpers.bezier_control_points(points)
      with_explicit = ChartMathHelpers.bezier_control_points(points, 0.4)
      assert with_default == with_explicit
    end
  end

  # ---------------------------------------------------------------------------
  # monotone_control_points/1
  # ---------------------------------------------------------------------------

  describe "monotone_control_points/1" do
    test "returns empty list for empty input" do
      assert ChartMathHelpers.monotone_control_points([]) == []
    end

    test "single point returns identity control points" do
      pt = %{x: 5.0, y: 10.0}
      [result] = ChartMathHelpers.monotone_control_points([pt])
      assert result.x == 5.0
      assert result.y == 10.0
      assert result.cp1x == 5.0
      assert result.cp1y == 10.0
      assert result.cp2x == 5.0
      assert result.cp2y == 10.0
    end

    test "two points return control-point maps" do
      points = [%{x: 0.0, y: 0.0}, %{x: 10.0, y: 10.0}]
      result = ChartMathHelpers.monotone_control_points(points)
      assert length(result) == 2
      Enum.each(result, fn cp ->
        assert Map.has_key?(cp, :cp1x)
        assert Map.has_key?(cp, :cp2y)
      end)
    end

    test "preserves original x,y values" do
      points = [%{x: 0.0, y: 0.0}, %{x: 5.0, y: 20.0}, %{x: 10.0, y: 5.0}]
      result = ChartMathHelpers.monotone_control_points(points)
      assert Enum.at(result, 0).x == 0.0
      assert Enum.at(result, 1).x == 5.0
      assert Enum.at(result, 2).x == 10.0
    end

    test "monotone data produces no overshoot" do
      # Strictly increasing data
      points = [%{x: 0.0, y: 0.0}, %{x: 10.0, y: 5.0}, %{x: 20.0, y: 15.0}, %{x: 30.0, y: 30.0}]
      result = ChartMathHelpers.monotone_control_points(points)

      # Control points should not go below any neighbor's y
      Enum.each(Enum.with_index(result), fn {cp, i} ->
        if i > 0 do
          prev = Enum.at(result, i - 1)
          # cp1y should be between prev.y and current.y (no overshoot below)
          assert cp.cp1y >= min(prev.y, cp.y) - 1.0e-10
        end
      end)
    end

    test "flat segment produces zero tangent (no wiggle)" do
      points = [%{x: 0.0, y: 10.0}, %{x: 5.0, y: 10.0}, %{x: 10.0, y: 10.0}]
      result = ChartMathHelpers.monotone_control_points(points)

      # Middle point should have flat control points
      mid = Enum.at(result, 1)
      assert_in_delta mid.cp1y, 10.0, 1.0e-10
      assert_in_delta mid.cp2y, 10.0, 1.0e-10
    end

    test "sign change between adjacent slopes zeroes tangent" do
      # Increasing then decreasing — peak should have zero tangent
      points = [%{x: 0.0, y: 0.0}, %{x: 5.0, y: 10.0}, %{x: 10.0, y: 0.0}]
      result = ChartMathHelpers.monotone_control_points(points)
      mid = Enum.at(result, 1)

      # cp1y and cp2y should equal y at the peak (tangent is 0)
      assert_in_delta mid.cp1y, mid.y, 1.0e-10
      assert_in_delta mid.cp2y, mid.y, 1.0e-10
    end

    test "returns correct count for many points" do
      points = Enum.map(0..19, fn i -> %{x: i * 5.0, y: :math.sin(i / 3.0) * 50 + 50} end)
      result = ChartMathHelpers.monotone_control_points(points)
      assert length(result) == 20
    end
  end

  # ---------------------------------------------------------------------------
  # smooth_path/2
  # ---------------------------------------------------------------------------

  describe "smooth_path/2" do
    test "returns empty string for empty list" do
      assert ChartMathHelpers.smooth_path([], :smooth) == ""
      assert ChartMathHelpers.smooth_path([], :monotone) == ""
    end

    test "single point returns M command only" do
      result = ChartMathHelpers.smooth_path([%{x: 10.0, y: 20.0}], :smooth)
      assert result == "M 10.0 20.0"
    end

    test "smooth mode starts with M and contains C commands" do
      points = [%{x: 0.0, y: 0.0}, %{x: 10.0, y: 10.0}, %{x: 20.0, y: 5.0}]
      result = ChartMathHelpers.smooth_path(points, :smooth)
      assert result =~ "M "
      assert result =~ "C "
    end

    test "monotone mode starts with M and contains C commands" do
      points = [%{x: 0.0, y: 0.0}, %{x: 10.0, y: 10.0}, %{x: 20.0, y: 5.0}]
      result = ChartMathHelpers.smooth_path(points, :monotone)
      assert result =~ "M "
      assert result =~ "C "
    end

    test "two points produce one C command" do
      points = [%{x: 0.0, y: 0.0}, %{x: 10.0, y: 10.0}]
      result = ChartMathHelpers.smooth_path(points, :smooth)
      assert result =~ "M "
      assert result =~ "C "
      # Exactly one C command
      c_count = result |> String.split("C ") |> length() |> Kernel.-(1)
      assert c_count == 1
    end

    test "n points produce n-1 C commands" do
      points = Enum.map(0..4, fn i -> %{x: i * 10.0, y: i * 5.0} end)
      result = ChartMathHelpers.smooth_path(points, :smooth)
      c_count = result |> String.split("C ") |> length() |> Kernel.-(1)
      assert c_count == 4
    end

    test "path contains numeric coordinates" do
      points = [%{x: 5.0, y: 15.0}, %{x: 25.0, y: 35.0}]
      result = ChartMathHelpers.smooth_path(points, :smooth)
      assert result =~ "5.0"
      assert result =~ "15.0"
    end
  end

  # ---------------------------------------------------------------------------
  # stepped_path/2
  # ---------------------------------------------------------------------------

  describe "stepped_path/2" do
    test "returns empty string for empty list" do
      assert ChartMathHelpers.stepped_path([], :before) == ""
      assert ChartMathHelpers.stepped_path([], :after) == ""
      assert ChartMathHelpers.stepped_path([], :middle) == ""
    end

    test "single point returns M command only" do
      result = ChartMathHelpers.stepped_path([%{x: 10.0, y: 20.0}], :before)
      assert result == "M 10.0 20.0"
    end

    test ":before step moves vertical first then horizontal" do
      points = [%{x: 0.0, y: 10.0}, %{x: 20.0, y: 30.0}]
      result = ChartMathHelpers.stepped_path(points, :before)
      assert result =~ "M 0.0 10.0"
      # :before — L prev.x pt.y, then L pt.x pt.y
      assert result =~ "L 0.0 30.0"
      assert result =~ "L 20.0 30.0"
    end

    test ":after step moves horizontal first then vertical" do
      points = [%{x: 0.0, y: 10.0}, %{x: 20.0, y: 30.0}]
      result = ChartMathHelpers.stepped_path(points, :after)
      assert result =~ "M 0.0 10.0"
      # :after — L pt.x prev.y, then L pt.x pt.y
      assert result =~ "L 20.0 10.0"
      assert result =~ "L 20.0 30.0"
    end

    test ":middle step goes horizontal to midpoint, vertical, then horizontal to end" do
      points = [%{x: 0.0, y: 10.0}, %{x: 20.0, y: 30.0}]
      result = ChartMathHelpers.stepped_path(points, :middle)
      assert result =~ "M 0.0 10.0"
      # midpoint x = (0+20)/2 = 10
      assert result =~ "L 10.0 10.0"
      assert result =~ "L 10.0 30.0"
      assert result =~ "L 20.0 30.0"
    end

    test "path only contains M and L commands, no C commands" do
      points = [%{x: 0.0, y: 0.0}, %{x: 10.0, y: 10.0}, %{x: 20.0, y: 5.0}]
      result = ChartMathHelpers.stepped_path(points, :before)
      refute result =~ "C "
      assert result =~ "M "
      assert result =~ "L "
    end

    test "multiple points produce correct number of step segments" do
      points = [%{x: 0.0, y: 0.0}, %{x: 10.0, y: 5.0}, %{x: 20.0, y: 15.0}]
      result = ChartMathHelpers.stepped_path(points, :after)
      # 2 segments, each with 2 L commands = 4 L total
      l_count = result |> String.split("L ") |> length() |> Kernel.-(1)
      assert l_count == 4
    end
  end

  # ---------------------------------------------------------------------------
  # smooth_area_path/3
  # ---------------------------------------------------------------------------

  describe "smooth_area_path/3" do
    test "returns empty string for empty list" do
      assert ChartMathHelpers.smooth_area_path([], :smooth, 200.0) == ""
    end

    test "closes path to baseline with L and Z" do
      points = [%{x: 0.0, y: 50.0}, %{x: 100.0, y: 30.0}]
      result = ChartMathHelpers.smooth_area_path(points, :smooth, 200.0)
      # Should close down to baseline and back
      assert result =~ "L 100.0 200.0"
      assert result =~ "L 0.0 200.0"
      assert result =~ "Z"
    end

    test "starts with smooth curve part" do
      points = [%{x: 0.0, y: 50.0}, %{x: 50.0, y: 20.0}, %{x: 100.0, y: 40.0}]
      result = ChartMathHelpers.smooth_area_path(points, :smooth, 200.0)
      assert result =~ "M "
      assert result =~ "C "
    end

    test "monotone mode also closes to baseline" do
      points = [%{x: 0.0, y: 50.0}, %{x: 50.0, y: 20.0}, %{x: 100.0, y: 40.0}]
      result = ChartMathHelpers.smooth_area_path(points, :monotone, 200.0)
      assert result =~ "Z"
      assert result =~ "L 100.0 200.0"
      assert result =~ "L 0.0 200.0"
    end
  end

  # ---------------------------------------------------------------------------
  # stepped_area_path/3
  # ---------------------------------------------------------------------------

  describe "stepped_area_path/3" do
    test "returns empty string for empty list" do
      assert ChartMathHelpers.stepped_area_path([], :before, 200.0) == ""
    end

    test "closes stepped path to baseline" do
      points = [%{x: 0.0, y: 50.0}, %{x: 100.0, y: 30.0}]
      result = ChartMathHelpers.stepped_area_path(points, :after, 200.0)
      assert result =~ "L 100.0 200.0"
      assert result =~ "L 0.0 200.0"
      assert result =~ "Z"
    end

    test "contains only M and L commands with Z closure" do
      points = [%{x: 0.0, y: 10.0}, %{x: 50.0, y: 30.0}, %{x: 100.0, y: 20.0}]
      result = ChartMathHelpers.stepped_area_path(points, :middle, 200.0)
      refute result =~ "C "
      assert result =~ "M "
      assert result =~ "L "
      assert result =~ "Z"
    end
  end

  # ---------------------------------------------------------------------------
  # polar_to_cartesian/4
  # ---------------------------------------------------------------------------

  describe "polar_to_cartesian/4" do
    test "angle 0 returns point to the right of center" do
      {x, y} = ChartMathHelpers.polar_to_cartesian(10.0, 0.0, 50.0, 50.0)
      assert_in_delta x, 60.0, 1.0e-10
      assert_in_delta y, 50.0, 1.0e-10
    end

    test "angle pi/2 returns point below center (SVG y-down)" do
      {x, y} = ChartMathHelpers.polar_to_cartesian(10.0, :math.pi() / 2, 50.0, 50.0)
      assert_in_delta x, 50.0, 1.0e-10
      assert_in_delta y, 60.0, 1.0e-10
    end

    test "angle pi returns point to the left of center" do
      {x, y} = ChartMathHelpers.polar_to_cartesian(10.0, :math.pi(), 50.0, 50.0)
      assert_in_delta x, 40.0, 1.0e-10
      assert_in_delta y, 50.0, 1.0e-10
    end

    test "angle 3*pi/2 returns point above center" do
      {x, y} = ChartMathHelpers.polar_to_cartesian(10.0, 3 * :math.pi() / 2, 50.0, 50.0)
      assert_in_delta x, 50.0, 1.0e-10
      assert_in_delta y, 40.0, 1.0e-10
    end

    test "radius 0 returns center point" do
      {x, y} = ChartMathHelpers.polar_to_cartesian(0.0, :math.pi() / 4, 100.0, 100.0)
      assert_in_delta x, 100.0, 1.0e-10
      assert_in_delta y, 100.0, 1.0e-10
    end

    test "non-origin center is respected" do
      {x, y} = ChartMathHelpers.polar_to_cartesian(5.0, 0.0, 200.0, 300.0)
      assert_in_delta x, 205.0, 1.0e-10
      assert_in_delta y, 300.0, 1.0e-10
    end
  end

  # ---------------------------------------------------------------------------
  # angle_from_point/4
  # ---------------------------------------------------------------------------

  describe "angle_from_point/4" do
    test "point to the right returns 0" do
      result = ChartMathHelpers.angle_from_point(0.0, 0.0, 1.0, 0.0)
      assert_in_delta result, 0.0, 1.0e-10
    end

    test "point below returns pi/2" do
      result = ChartMathHelpers.angle_from_point(0.0, 0.0, 0.0, 1.0)
      assert_in_delta result, :math.pi() / 2, 1.0e-10
    end

    test "point to the left returns pi" do
      result = ChartMathHelpers.angle_from_point(0.0, 0.0, -1.0, 0.0)
      assert_in_delta result, :math.pi(), 1.0e-10
    end

    test "point above returns -pi/2" do
      result = ChartMathHelpers.angle_from_point(0.0, 0.0, 0.0, -1.0)
      assert_in_delta result, -:math.pi() / 2, 1.0e-10
    end
  end

  # ---------------------------------------------------------------------------
  # angle_between?/3
  # ---------------------------------------------------------------------------

  describe "angle_between?/3" do
    test "angle within a simple range" do
      assert ChartMathHelpers.angle_between?(1.0, 0.5, 1.5)
    end

    test "angle outside a simple range" do
      refute ChartMathHelpers.angle_between?(2.0, 0.5, 1.5)
    end

    test "angle at start boundary is included" do
      assert ChartMathHelpers.angle_between?(0.5, 0.5, 1.5)
    end

    test "angle at end boundary is included" do
      assert ChartMathHelpers.angle_between?(1.5, 0.5, 1.5)
    end

    test "wrapping range (end < start after normalization)" do
      # Range from 5.0 to 1.0 radians wraps around 2*pi
      assert ChartMathHelpers.angle_between?(6.0, 5.0, 1.0)
      assert ChartMathHelpers.angle_between?(0.5, 5.0, 1.0)
    end

    test "negative angles are normalized" do
      assert ChartMathHelpers.angle_between?(-0.5, -1.0, 0.0)
    end
  end

  # ---------------------------------------------------------------------------
  # normalize_angle/1
  # ---------------------------------------------------------------------------

  describe "normalize_angle/1" do
    test "zero stays zero" do
      assert_in_delta ChartMathHelpers.normalize_angle(0.0), 0.0, 1.0e-10
    end

    test "positive angle within range stays unchanged" do
      assert_in_delta ChartMathHelpers.normalize_angle(1.0), 1.0, 1.0e-10
    end

    test "angle of 2*pi normalizes to 0" do
      assert_in_delta ChartMathHelpers.normalize_angle(2 * :math.pi()), 0.0, 1.0e-10
    end

    test "negative angle wraps to positive" do
      result = ChartMathHelpers.normalize_angle(-:math.pi() / 2)
      expected = 3 * :math.pi() / 2
      assert_in_delta result, expected, 1.0e-10
    end

    test "angle greater than 2*pi wraps correctly" do
      result = ChartMathHelpers.normalize_angle(3 * :math.pi())
      expected = :math.pi()
      assert_in_delta result, expected, 1.0e-10
    end

    test "large negative angle wraps correctly" do
      result = ChartMathHelpers.normalize_angle(-3 * :math.pi())
      expected = :math.pi()
      assert_in_delta result, expected, 1.0e-10
    end
  end

  # ---------------------------------------------------------------------------
  # decimate_lttb/2
  # ---------------------------------------------------------------------------

  describe "decimate_lttb/2" do
    test "returns empty list for empty input" do
      assert ChartMathHelpers.decimate_lttb([], 5) == []
    end

    test "returns data unchanged when data length <= target" do
      data = [%{x: 0, y: 1}, %{x: 1, y: 2}, %{x: 2, y: 3}]
      assert ChartMathHelpers.decimate_lttb(data, 5) == data
    end

    test "returns data unchanged when data length equals target" do
      data = [%{x: 0, y: 1}, %{x: 1, y: 2}, %{x: 2, y: 3}]
      assert ChartMathHelpers.decimate_lttb(data, 3) == data
    end

    test "target < 3 returns first and last" do
      data = [%{x: 0, y: 0}, %{x: 1, y: 10}, %{x: 2, y: 5}, %{x: 3, y: 8}]
      result = ChartMathHelpers.decimate_lttb(data, 2)
      assert length(result) == 2
      assert List.first(result).x == 0
      assert List.last(result).x == 3
    end

    test "always preserves first and last points" do
      data = Enum.map(0..99, fn i -> %{x: i, y: :rand.uniform() * 100} end)
      result = ChartMathHelpers.decimate_lttb(data, 10)
      assert List.first(result).x == 0
      assert List.last(result).x == 99
    end

    test "returns target number of points" do
      data = Enum.map(0..99, fn i -> %{x: i, y: :math.sin(i / 10.0) * 50} end)
      result = ChartMathHelpers.decimate_lttb(data, 20)
      assert length(result) == 20
    end

    test "works with label/value format" do
      data = Enum.map(0..19, fn i -> %{label: i, value: i * 2} end)
      result = ChartMathHelpers.decimate_lttb(data, 5)
      assert length(result) == 5
      # Should return label/value maps
      assert Map.has_key?(List.first(result), :label)
      assert Map.has_key?(List.first(result), :value)
    end

    test "preserves visual shape — selects peak over flat points" do
      # Flat data with one big spike
      data = [
        %{x: 0, y: 0},
        %{x: 1, y: 0},
        %{x: 2, y: 0},
        %{x: 3, y: 100},
        %{x: 4, y: 0},
        %{x: 5, y: 0},
        %{x: 6, y: 0}
      ]

      result = ChartMathHelpers.decimate_lttb(data, 4)
      # The spike point (y=100) should be selected since it maximizes triangle area
      values = Enum.map(result, & &1.y)
      assert 100 in values
    end
  end

  # ---------------------------------------------------------------------------
  # stack_series/1
  # ---------------------------------------------------------------------------

  describe "stack_series/1" do
    test "returns empty list for empty input" do
      assert ChartMathHelpers.stack_series([]) == []
    end

    test "single series has base 0 for all data points" do
      series = [
        %{name: "A", data: [%{label: "Jan", value: 10}, %{label: "Feb", value: 20}]}
      ]

      [result] = ChartMathHelpers.stack_series(series)
      assert Enum.all?(result.data, fn d -> d.base == 0.0 end)
    end

    test "second series bases equal first series values" do
      series = [
        %{name: "A", data: [%{label: "Jan", value: 10}, %{label: "Feb", value: 20}]},
        %{name: "B", data: [%{label: "Jan", value: 5}, %{label: "Feb", value: 8}]}
      ]

      [first, second] = ChartMathHelpers.stack_series(series)

      assert Enum.at(first.data, 0).base == 0.0
      assert Enum.at(first.data, 1).base == 0.0

      assert Enum.at(second.data, 0).base == 10.0
      assert Enum.at(second.data, 1).base == 20.0
    end

    test "three series stack cumulatively" do
      series = [
        %{name: "A", data: [%{label: "X", value: 10}]},
        %{name: "B", data: [%{label: "X", value: 20}]},
        %{name: "C", data: [%{label: "X", value: 30}]}
      ]

      [a, b, c] = ChartMathHelpers.stack_series(series)
      assert Enum.at(a.data, 0).base == 0.0
      assert Enum.at(b.data, 0).base == 10.0
      assert Enum.at(c.data, 0).base == 30.0
    end

    test "preserves series names" do
      series = [
        %{name: "Revenue", data: [%{label: "Q1", value: 100}]},
        %{name: "Cost", data: [%{label: "Q1", value: 50}]}
      ]

      result = ChartMathHelpers.stack_series(series)
      assert Enum.at(result, 0).name == "Revenue"
      assert Enum.at(result, 1).name == "Cost"
    end

    test "preserves original values alongside base" do
      series = [
        %{name: "A", data: [%{label: "X", value: 42}]}
      ]

      [result] = ChartMathHelpers.stack_series(series)
      assert Enum.at(result.data, 0).value == 42
    end
  end

  # ---------------------------------------------------------------------------
  # log_ticks/2
  # ---------------------------------------------------------------------------

  describe "log_ticks/2" do
    test "returns ticks for simple range" do
      ticks = ChartMathHelpers.log_ticks(1, 100)
      assert is_list(ticks)
      assert length(ticks) > 0
    end

    test "includes min and max in ticks" do
      ticks = ChartMathHelpers.log_ticks(1, 1000)
      assert 1 in ticks or 1.0 in ticks
      assert 1000 in ticks or 1000.0 in ticks
    end

    test "generates ticks at powers of 10" do
      ticks = ChartMathHelpers.log_ticks(1, 10000)
      assert 10.0 in ticks
      assert 100.0 in ticks
      assert 1000.0 in ticks
    end

    test "generates intermediate ticks at 2 and 5 multipliers" do
      ticks = ChartMathHelpers.log_ticks(1, 100)
      assert 2.0 in ticks
      assert 5.0 in ticks
      assert 20.0 in ticks
      assert 50.0 in ticks
    end

    test "ticks are in ascending order" do
      ticks = ChartMathHelpers.log_ticks(1, 10000)
      assert ticks == Enum.sort(ticks)
    end

    test "no duplicates in ticks" do
      ticks = ChartMathHelpers.log_ticks(1, 1000)
      assert ticks == Enum.uniq(ticks)
    end

    test "works with fractional min" do
      ticks = ChartMathHelpers.log_ticks(0.1, 100)
      assert is_list(ticks)
      assert length(ticks) > 0
      assert List.first(ticks) <= 0.1
    end
  end

  # ---------------------------------------------------------------------------
  # log_pixel/5
  # ---------------------------------------------------------------------------

  describe "log_pixel/5" do
    test "value at min maps to px_start" do
      result = ChartMathHelpers.log_pixel(1.0, 1.0, 1000.0, 0.0, 300.0)
      assert_in_delta result, 0.0, 1.0e-10
    end

    test "value at max maps to px_end" do
      result = ChartMathHelpers.log_pixel(1000.0, 1.0, 1000.0, 0.0, 300.0)
      assert_in_delta result, 300.0, 1.0e-10
    end

    test "value in middle maps proportionally in log space" do
      # log10(10) - log10(1) = 1, log10(100) - log10(1) = 2, ratio = 0.5
      result = ChartMathHelpers.log_pixel(10.0, 1.0, 100.0, 0.0, 200.0)
      assert_in_delta result, 100.0, 1.0e-10
    end

    test "respects px_start offset" do
      result = ChartMathHelpers.log_pixel(1.0, 1.0, 1000.0, 50.0, 350.0)
      assert_in_delta result, 50.0, 1.0e-10
    end

    test "result is between px_start and px_end for value in range" do
      result = ChartMathHelpers.log_pixel(50.0, 1.0, 1000.0, 0.0, 300.0)
      assert result >= 0.0
      assert result <= 300.0
    end
  end

  # ---------------------------------------------------------------------------
  # Easing Functions
  # ---------------------------------------------------------------------------

  describe "ease_out_cubic/1" do
    test "returns 0 at t=0" do
      assert_in_delta ChartMathHelpers.ease_out_cubic(0.0), 0.0, 1.0e-10
    end

    test "returns 1 at t=1" do
      assert_in_delta ChartMathHelpers.ease_out_cubic(1.0), 1.0, 1.0e-10
    end

    test "monotonically increases" do
      values = Enum.map(0..10, fn i -> ChartMathHelpers.ease_out_cubic(i / 10) end)
      pairs = Enum.chunk_every(values, 2, 1, :discard)
      assert Enum.all?(pairs, fn [a, b] -> b >= a end)
    end

    test "decelerates — second half increments are smaller" do
      v1 = ChartMathHelpers.ease_out_cubic(0.5) - ChartMathHelpers.ease_out_cubic(0.0)
      v2 = ChartMathHelpers.ease_out_cubic(1.0) - ChartMathHelpers.ease_out_cubic(0.5)
      assert v1 > v2
    end
  end

  describe "ease_in_out_cubic/1" do
    test "returns 0 at t=0" do
      assert_in_delta ChartMathHelpers.ease_in_out_cubic(0.0), 0.0, 1.0e-10
    end

    test "returns 1 at t=1" do
      assert_in_delta ChartMathHelpers.ease_in_out_cubic(1.0), 1.0, 1.0e-10
    end

    test "returns 0.5 at t=0.5" do
      assert_in_delta ChartMathHelpers.ease_in_out_cubic(0.5), 0.5, 1.0e-10
    end

    test "monotonically increases" do
      values = Enum.map(0..10, fn i -> ChartMathHelpers.ease_in_out_cubic(i / 10) end)
      pairs = Enum.chunk_every(values, 2, 1, :discard)
      assert Enum.all?(pairs, fn [a, b] -> b >= a end)
    end
  end

  describe "ease_out_elastic/1" do
    test "returns 0 at t=0" do
      assert_in_delta ChartMathHelpers.ease_out_elastic(0.0), 0.0, 1.0e-10
    end

    test "returns 1 at t=1" do
      assert_in_delta ChartMathHelpers.ease_out_elastic(1.0), 1.0, 1.0e-10
    end

    test "overshoots 1.0 during bounce" do
      # Elastic easing oscillates — some values should exceed 1.0
      values = Enum.map(1..9, fn i -> ChartMathHelpers.ease_out_elastic(i / 10) end)
      assert Enum.any?(values, fn v -> v > 1.0 end)
    end
  end
end
