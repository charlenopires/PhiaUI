defmodule PhiaUi.Components.Data.ChartPointTest do
  use ExUnit.Case, async: true

  alias PhiaUi.Components.Data.ChartPoint
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

  describe "from_data/3" do
    test "converts data list into enriched point maps" do
      coord = build_coord()
      points = ChartPoint.from_data(@sample_data, coord)

      assert length(points) == 3

      first = hd(points)
      assert first.label == "Q1"
      assert first.value == 100
      assert is_float(first.px)
      assert is_float(first.py)
      assert first.index == 0
      assert first.state == :normal
    end

    test "assigns sequential indices" do
      coord = build_coord()
      points = ChartPoint.from_data(@sample_data, coord)

      indices = Enum.map(points, & &1.index)
      assert indices == [0, 1, 2]
    end

    test "uses default color when none provided" do
      coord = build_coord()
      points = ChartPoint.from_data(@sample_data, coord)

      assert hd(points).color == "currentColor"
    end

    test "uses custom default color" do
      coord = build_coord()
      points = ChartPoint.from_data(@sample_data, coord, default_color: "blue")

      assert Enum.all?(points, fn p -> p.color == "blue" end)
    end

    test "uses color list" do
      coord = build_coord()
      points = ChartPoint.from_data(@sample_data, coord, colors: ["red", "green", "blue"])

      assert Enum.at(points, 0).color == "red"
      assert Enum.at(points, 1).color == "green"
      assert Enum.at(points, 2).color == "blue"
    end

    test "uses color function" do
      coord = build_coord()
      color_fn = fn idx -> "color-#{idx}" end
      points = ChartPoint.from_data(@sample_data, coord, colors: color_fn)

      assert Enum.at(points, 0).color == "color-0"
      assert Enum.at(points, 2).color == "color-2"
    end

    test "handles empty data list" do
      coord = build_coord()
      assert ChartPoint.from_data([], coord) == []
    end
  end

  describe "from_data_with_base/3" do
    test "includes base_py for stacked points" do
      coord = build_coord()
      data_with_base = [
        %{label: "Q1", value: 200, base: 100},
        %{label: "Q2", value: 300, base: 150}
      ]

      points = ChartPoint.from_data_with_base(data_with_base, coord)

      first = hd(points)
      assert Map.has_key?(first, :base_py)
      assert is_float(first.base_py)
      assert first.base_py != first.py
    end

    test "defaults base to 0 when not provided" do
      coord = build_coord()
      data = [%{label: "Q1", value: 100}]

      [point] = ChartPoint.from_data_with_base(data, coord)

      assert is_float(point.base_py)
    end
  end

  describe "update_state/2" do
    test "updates state to hover" do
      coord = build_coord()
      [point | _] = ChartPoint.from_data(@sample_data, coord)

      updated = ChartPoint.update_state(point, :hover)
      assert updated.state == :hover
      assert updated.label == point.label
    end

    test "updates state to select" do
      coord = build_coord()
      [point | _] = ChartPoint.from_data(@sample_data, coord)

      updated = ChartPoint.update_state(point, :select)
      assert updated.state == :select
    end

    test "updates state to normal" do
      coord = build_coord()
      [point | _] = ChartPoint.from_data(@sample_data, coord)
      hovered = ChartPoint.update_state(point, :hover)
      normal = ChartPoint.update_state(hovered, :normal)

      assert normal.state == :normal
    end
  end

  describe "apply_visual_map/2" do
    test "enriches points with visual mapping results" do
      coord = build_coord()
      points = ChartPoint.from_data(@sample_data, coord)

      enriched =
        ChartPoint.apply_visual_map(points, fn p ->
          %{opacity: if(p.value > 150, do: 1.0, else: 0.5)}
        end)

      assert Enum.at(enriched, 0).opacity == 0.5
      assert Enum.at(enriched, 1).opacity == 1.0
    end

    test "can override color" do
      coord = build_coord()
      points = ChartPoint.from_data(@sample_data, coord)

      enriched =
        ChartPoint.apply_visual_map(points, fn _p -> %{color: "red"} end)

      assert Enum.all?(enriched, fn p -> p.color == "red" end)
    end
  end

  describe "nearest/2" do
    test "finds nearest point to position" do
      coord = build_coord()
      points = ChartPoint.from_data(@sample_data, coord)

      first = hd(points)
      {nearest, dist} = ChartPoint.nearest(points, {first.px, first.py})

      assert nearest.label == "Q1"
      assert_in_delta dist, 0.0, 0.01
    end

    test "finds nearest when not exact match" do
      coord = build_coord()
      points = ChartPoint.from_data(@sample_data, coord)

      {nearest, _dist} = ChartPoint.nearest(points, {0, 0})
      assert nearest != nil
      assert nearest.label in ["Q1", "Q2", "Q3"]
    end

    test "returns nil for empty points" do
      assert ChartPoint.nearest([], {0, 0}) == nil
    end
  end

  describe "within_radius/3" do
    test "returns points within radius" do
      coord = build_coord()
      points = ChartPoint.from_data(@sample_data, coord)

      first = hd(points)
      nearby = ChartPoint.within_radius(points, {first.px, first.py}, 1.0)

      assert length(nearby) >= 1
      assert hd(nearby).label == "Q1"
    end

    test "returns empty list when no points within radius" do
      coord = build_coord()
      points = ChartPoint.from_data(@sample_data, coord)

      nearby = ChartPoint.within_radius(points, {-10000, -10000}, 1.0)
      assert nearby == []
    end

    test "returns all points with large radius" do
      coord = build_coord()
      points = ChartPoint.from_data(@sample_data, coord)

      nearby = ChartPoint.within_radius(points, {200, 150}, 10000.0)
      assert length(nearby) == 3
    end
  end
end
