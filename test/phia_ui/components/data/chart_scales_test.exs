defmodule PhiaUi.Components.Data.ChartScalesTest do
  use ExUnit.Case, async: true

  alias PhiaUi.Components.Data.ChartScales

  describe "linear_scale/4" do
    test "maps domain to range proportionally" do
      scale = ChartScales.linear_scale(0, 100, 0, 400)
      assert scale.(0) == 0.0
      assert scale.(50) == 200.0
      assert scale.(100) == 400.0
    end

    test "handles inverted range" do
      scale = ChartScales.linear_scale(0, 100, 400, 0)
      assert scale.(0) == 400.0
      assert scale.(100) == 0.0
    end

    test "handles zero-width domain" do
      scale = ChartScales.linear_scale(50, 50, 0, 400)
      assert scale.(50) == 200.0
    end

    test "handles negative values" do
      scale = ChartScales.linear_scale(-100, 100, 0, 200)
      assert scale.(0) == 100.0
    end
  end

  describe "band_scale/4" do
    test "distributes categories evenly" do
      result = ChartScales.band_scale(["A", "B", "C"], 0, 300)
      assert is_map(result.positions)
      assert is_float(result.bandwidth)
      assert result.bandwidth > 0
      assert map_size(result.positions) == 3
    end

    test "returns scale function" do
      result = ChartScales.band_scale(["A", "B"], 0, 200)
      assert is_function(result.scale, 1)
      a_pos = result.scale.("A")
      b_pos = result.scale.("B")
      assert a_pos < b_pos
    end

    test "handles empty categories" do
      result = ChartScales.band_scale([], 0, 300)
      assert result.positions == %{}
      assert result.bandwidth == 0.0
    end

    test "handles single category" do
      result = ChartScales.band_scale(["Only"], 0, 300)
      assert map_size(result.positions) == 1
      assert result.bandwidth > 0
    end
  end

  describe "log_scale/5" do
    test "maps logarithmically" do
      scale = ChartScales.log_scale(1, 1000, 0, 300)
      p1 = scale.(1)
      p10 = scale.(10)
      p100 = scale.(100)
      p1000 = scale.(1000)

      assert_in_delta p1, 0.0, 0.1
      assert_in_delta p10, 100.0, 0.1
      assert_in_delta p100, 200.0, 0.1
      assert_in_delta p1000, 300.0, 0.1
    end

    test "handles custom base" do
      scale = ChartScales.log_scale(1, 8, 0, 300, 2)
      p1 = scale.(1)
      p8 = scale.(8)
      assert_in_delta p1, 0.0, 0.1
      assert_in_delta p8, 300.0, 0.1
    end
  end

  describe "ordinal_scale/2" do
    test "maps categories to colors" do
      scale = ChartScales.ordinal_scale(["A", "B"], ["red", "blue"])
      assert scale.("A") == "red"
      assert scale.("B") == "blue"
    end

    test "wraps colors for excess categories" do
      scale = ChartScales.ordinal_scale(["A", "B", "C"], ["red", "blue"])
      assert scale.("A") == "red"
      assert scale.("B") == "blue"
      assert scale.("C") == "red"
    end

    test "returns default for unknown category" do
      scale = ChartScales.ordinal_scale(["A"], ["red"])
      assert scale.("unknown") == "currentColor"
    end
  end

  describe "time_scale/4" do
    test "maps datetimes to pixels" do
      d1 = ~N[2024-01-01 00:00:00]
      d2 = ~N[2024-12-31 00:00:00]
      scale = ChartScales.time_scale(d1, d2, 0, 365)
      p1 = scale.(d1)
      p2 = scale.(d2)
      assert_in_delta p1, 0.0, 0.1
      assert_in_delta p2, 365.0, 0.1
    end

    test "handles same dates" do
      d = ~N[2024-06-15 00:00:00]
      scale = ChartScales.time_scale(d, d, 0, 400)
      assert scale.(d) == 200.0
    end
  end

  describe "invert_linear/5" do
    test "inverts pixel to value" do
      assert ChartScales.invert_linear(0, 100, 0, 400, 200.0) == 50.0
    end

    test "handles edge positions" do
      assert ChartScales.invert_linear(0, 100, 0, 400, 0.0) == 0.0
      assert ChartScales.invert_linear(0, 100, 0, 400, 400.0) == 100.0
    end

    test "handles zero-width pixel range" do
      assert ChartScales.invert_linear(0, 100, 200, 200, 200.0) == 50.0
    end
  end

  describe "nice_domain/3" do
    test "rounds to nice boundaries" do
      {nice_min, nice_max} = ChartScales.nice_domain(3.2, 97.8)
      assert nice_min <= 3.2
      assert nice_max >= 97.8
    end

    test "handles zero range" do
      {nice_min, nice_max} = ChartScales.nice_domain(50, 50)
      assert nice_min == 50
      assert nice_max == 50
    end
  end
end
