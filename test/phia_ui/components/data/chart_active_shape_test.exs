defmodule PhiaUi.Components.Data.ChartActiveShapeTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  alias PhiaUi.Components.Data.ChartActiveShape

  describe "chart_active_shape/1 with :dot type" do
    test "renders two circles (normal + active)" do
      html =
        render_component(&ChartActiveShape.chart_active_shape/1, %{
          type: :dot,
          cx: 100,
          cy: 50,
          r: 4,
          active_r: 8,
          x: 0,
          y: 0,
          width: 0,
          height: 0,
          path: nil,
          active_path: nil,
          color: "blue",
          active_color: nil,
          opacity: 1,
          active_opacity: 1,
          class: nil
        })

      assert html =~ "<g"
      assert html =~ "<circle"
      assert html =~ "group/active-shape"
      # Should have hit area + normal + active circles
      circle_count = html |> String.split("<circle") |> length()
      assert circle_count >= 4
    end

    test "uses active_color when provided" do
      html =
        render_component(&ChartActiveShape.chart_active_shape/1, %{
          type: :dot,
          cx: 100,
          cy: 50,
          r: 4,
          active_r: 8,
          x: 0,
          y: 0,
          width: 0,
          height: 0,
          path: nil,
          active_path: nil,
          color: "blue",
          active_color: "red",
          opacity: 1,
          active_opacity: 1,
          class: nil
        })

      assert html =~ ~s[fill="red"]
    end
  end

  describe "chart_active_shape/1 with :bar type" do
    test "renders a rect element" do
      html =
        render_component(&ChartActiveShape.chart_active_shape/1, %{
          type: :bar,
          cx: 0,
          cy: 0,
          r: 4,
          active_r: 8,
          x: 10,
          y: 20,
          width: 30,
          height: 60,
          path: nil,
          active_path: nil,
          color: "green",
          active_color: nil,
          opacity: 1,
          active_opacity: 1,
          class: nil
        })

      assert html =~ "<rect"
      assert html =~ ~s[fill="green"]
      assert html =~ "group/active-shape"
    end
  end

  describe "chart_active_shape/1 with :sector type" do
    test "renders two path elements (normal + active)" do
      html =
        render_component(&ChartActiveShape.chart_active_shape/1, %{
          type: :sector,
          cx: 0,
          cy: 0,
          r: 4,
          active_r: 8,
          x: 0,
          y: 0,
          width: 0,
          height: 0,
          path: "M 0 0 L 10 0 A 10 10 0 0 1 0 10 Z",
          active_path: "M 0 0 L 12 0 A 12 12 0 0 1 0 12 Z",
          color: "orange",
          active_color: nil,
          opacity: 1,
          active_opacity: 1,
          class: nil
        })

      assert html =~ "<path"
      assert html =~ ~s[fill="orange"]
      path_count = html |> String.split("<path") |> length()
      assert path_count >= 3
    end

    test "uses path as fallback when active_path is nil" do
      html =
        render_component(&ChartActiveShape.chart_active_shape/1, %{
          type: :sector,
          cx: 0,
          cy: 0,
          r: 4,
          active_r: 8,
          x: 0,
          y: 0,
          width: 0,
          height: 0,
          path: "M 0 0 L 10 0 Z",
          active_path: nil,
          color: "purple",
          active_color: nil,
          opacity: 1,
          active_opacity: 1,
          class: nil
        })

      assert html =~ "M 0 0 L 10 0 Z"
    end
  end
end
