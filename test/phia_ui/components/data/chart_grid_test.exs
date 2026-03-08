defmodule PhiaUi.Components.Data.ChartGridTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  alias PhiaUi.Components.Data.ChartGrid
  alias PhiaUi.Components.Data.ChartScales

  describe "x_grid/1" do
    test "renders vertical grid lines" do
      scale = ChartScales.linear_scale(0, 100, 44, 384)

      html =
        render_component(&ChartGrid.x_grid/1, %{
          ticks: [0, 25, 50, 75, 100],
          scale: scale,
          y: 16,
          height: 244,
          dash_array: nil,
          class: nil
        })

      assert html =~ "phia-x-grid"
      assert html =~ "line"
      # 5 ticks = 5 lines
      assert length(Regex.scan(~r/<line/, html)) == 5
    end

    test "renders with dash array" do
      scale = ChartScales.linear_scale(0, 100, 44, 384)

      html =
        render_component(&ChartGrid.x_grid/1, %{
          ticks: [50],
          scale: scale,
          y: 16,
          height: 244,
          dash_array: "4 2",
          class: nil
        })

      assert html =~ ~s(stroke-dasharray="4 2")
    end
  end

  describe "y_grid/1" do
    test "renders horizontal grid lines" do
      scale = ChartScales.linear_scale(0, 100, 260, 16)

      html =
        render_component(&ChartGrid.y_grid/1, %{
          ticks: [0, 50, 100],
          scale: scale,
          x: 44,
          width: 340,
          dash_array: nil,
          class: nil
        })

      assert html =~ "phia-y-grid"
      assert length(Regex.scan(~r/<line/, html)) == 3
    end

    test "applies custom class" do
      scale = ChartScales.linear_scale(0, 100, 260, 16)

      html =
        render_component(&ChartGrid.y_grid/1, %{
          ticks: [50],
          scale: scale,
          x: 44,
          width: 340,
          dash_array: nil,
          class: "opacity-50"
        })

      assert html =~ "opacity-50"
    end
  end

  describe "polar_grid/1" do
    test "renders concentric circles" do
      html =
        render_component(&ChartGrid.polar_grid/1, %{
          rings: [30, 60, 90, 120],
          spokes: 0,
          cx: 200,
          cy: 150,
          dash_array: nil,
          class: nil
        })

      assert html =~ "phia-polar-grid"
      assert length(Regex.scan(~r/<circle/, html)) == 4
    end

    test "renders spokes" do
      html =
        render_component(&ChartGrid.polar_grid/1, %{
          rings: [100],
          spokes: 8,
          cx: 200,
          cy: 150,
          dash_array: nil,
          class: nil
        })

      # 1 circle + 8 spoke lines
      assert length(Regex.scan(~r/<circle/, html)) == 1
      assert length(Regex.scan(~r/<line/, html)) == 8
    end

    test "handles empty rings" do
      html =
        render_component(&ChartGrid.polar_grid/1, %{
          rings: [],
          spokes: 0,
          cx: 200,
          cy: 150,
          dash_array: nil,
          class: nil
        })

      assert html =~ "phia-polar-grid"
    end
  end
end
