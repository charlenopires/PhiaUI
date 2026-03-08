defmodule PhiaUi.Components.Data.ChartVisualMapTest do
  use ExUnit.Case, async: true

  alias PhiaUi.Components.Data.ChartVisualMap

  describe "continuous/2" do
    test "maps minimum value to first color" do
      mapper = ChartVisualMap.continuous({0, 100}, ["oklch(0.95 0.05 30)", "oklch(0.55 0.22 30)"])
      result = mapper.(0)
      assert result =~ "oklch("
      assert result =~ "0.95"
    end

    test "maps maximum value to last color" do
      mapper = ChartVisualMap.continuous({0, 100}, ["oklch(0.95 0.05 30)", "oklch(0.55 0.22 30)"])
      result = mapper.(100)
      assert result =~ "oklch("
      assert result =~ "0.55"
    end

    test "maps midpoint to interpolated color" do
      mapper = ChartVisualMap.continuous({0, 100}, ["oklch(0.95 0.05 30)", "oklch(0.55 0.22 30)"])
      result = mapper.(50)
      assert result =~ "oklch("
      # L should be ~0.75 (midpoint of 0.95 and 0.55)
      assert result =~ "0.75"
    end

    test "clamps values below domain to first color" do
      mapper = ChartVisualMap.continuous({0, 100}, ["oklch(0.95 0.05 30)", "oklch(0.55 0.22 30)"])
      result = mapper.(-10)
      assert result =~ "0.95"
    end

    test "clamps values above domain to last color" do
      mapper = ChartVisualMap.continuous({0, 100}, ["oklch(0.95 0.05 30)", "oklch(0.55 0.22 30)"])
      result = mapper.(200)
      assert result =~ "0.55"
    end

    test "supports multi-stop gradients" do
      mapper = ChartVisualMap.continuous(
        {0, 100},
        ["oklch(0.90 0.05 120)", "oklch(0.70 0.15 60)", "oklch(0.50 0.25 0)"]
      )

      result_0 = mapper.(0)
      result_50 = mapper.(50)
      result_100 = mapper.(100)

      assert result_0 =~ "0.9"
      assert result_50 =~ "0.7"
      assert result_100 =~ "0.5"
    end
  end

  describe "piecewise/1" do
    test "maps value to correct threshold color" do
      mapper = ChartVisualMap.piecewise([{25, "green"}, {50, "yellow"}, {75, "orange"}, {100, "red"}])

      assert mapper.(10) == "green"
      assert mapper.(25) == "green"
      assert mapper.(30) == "yellow"
      assert mapper.(60) == "orange"
      assert mapper.(90) == "red"
    end

    test "values above max threshold return last color" do
      mapper = ChartVisualMap.piecewise([{50, "low"}, {100, "high"}])
      assert mapper.(150) == "high"
    end

    test "handles single threshold" do
      mapper = ChartVisualMap.piecewise([{100, "only"}])
      assert mapper.(50) == "only"
    end
  end

  describe "category/1" do
    test "maps categories to colors" do
      mapper = ChartVisualMap.category(%{"high" => "red", "medium" => "yellow", "low" => "green"})

      assert mapper.("high") == "red"
      assert mapper.("medium") == "yellow"
      assert mapper.("low") == "green"
    end

    test "returns default for unknown category" do
      mapper = ChartVisualMap.category(%{"a" => "red"})
      assert mapper.("unknown") == "currentColor"
    end
  end

  describe "size_map/2" do
    test "maps domain to size range" do
      mapper = ChartVisualMap.size_map({0, 100}, {4, 20})

      assert_in_delta mapper.(0), 4.0, 0.01
      assert_in_delta mapper.(50), 12.0, 0.01
      assert_in_delta mapper.(100), 20.0, 0.01
    end

    test "clamps values outside domain" do
      mapper = ChartVisualMap.size_map({0, 100}, {4, 20})

      assert_in_delta mapper.(-10), 4.0, 0.01
      assert_in_delta mapper.(200), 20.0, 0.01
    end
  end

  describe "opacity_map/2" do
    test "maps domain to opacity range" do
      mapper = ChartVisualMap.opacity_map({0, 100}, {0.1, 1.0})

      assert_in_delta mapper.(0), 0.1, 0.01
      assert_in_delta mapper.(50), 0.55, 0.01
      assert_in_delta mapper.(100), 1.0, 0.01
    end

    test "clamps values outside domain" do
      mapper = ChartVisualMap.opacity_map({0, 100}, {0.2, 0.8})

      assert_in_delta mapper.(-50), 0.2, 0.01
      assert_in_delta mapper.(500), 0.8, 0.01
    end
  end

  describe "compute_domain/1" do
    test "returns min and max of values" do
      assert ChartVisualMap.compute_domain([10, 20, 5, 30, 15]) == {5, 30}
    end

    test "handles single value" do
      assert ChartVisualMap.compute_domain([42]) == {42, 42}
    end

    test "handles empty list" do
      assert ChartVisualMap.compute_domain([]) == {0, 1}
    end
  end

  describe "interpolate_oklch/3" do
    test "interpolates between two OKLCH colors" do
      result = ChartVisualMap.interpolate_oklch(
        "oklch(0.90 0.10 120)",
        "oklch(0.50 0.20 240)",
        0.5
      )

      assert result =~ "oklch("
      assert result =~ "0.7"  # L midpoint
      assert result =~ "0.15" # C midpoint
    end

    test "t=0 returns first color" do
      result = ChartVisualMap.interpolate_oklch(
        "oklch(0.90 0.10 120)",
        "oklch(0.50 0.20 240)",
        0.0
      )

      assert result =~ "0.9"
    end

    test "t=1 returns second color" do
      result = ChartVisualMap.interpolate_oklch(
        "oklch(0.90 0.10 120)",
        "oklch(0.50 0.20 240)",
        1.0
      )

      assert result =~ "0.5"
    end

    test "accepts tuple format" do
      result = ChartVisualMap.interpolate_oklch({0.9, 0.1, 120}, {0.5, 0.2, 240}, 0.5)
      assert result =~ "oklch("
    end

    test "handles hue wrapping (shortest path)" do
      # 350 → 10 should go through 0, not the long way around
      result = ChartVisualMap.interpolate_oklch({0.5, 0.1, 350}, {0.5, 0.1, 10}, 0.5)
      assert result =~ "oklch("
      # Midpoint should be near 0/360, not near 180
    end
  end
end
