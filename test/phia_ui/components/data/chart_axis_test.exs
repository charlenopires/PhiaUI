defmodule PhiaUi.Components.Data.ChartAxisTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  alias PhiaUi.Components.Data.ChartAxis
  alias PhiaUi.Components.Data.ChartScales

  describe "x_axis/1" do
    test "renders ticks and labels" do
      scale = ChartScales.linear_scale(0, 100, 44, 384)

      html =
        render_component(&ChartAxis.x_axis/1, %{
          ticks: [0, 25, 50, 75, 100],
          scale: scale,
          y: 260,
          width: 340,
          x_offset: 0,
          tick_size: 5,
          label_format: nil,
          title: nil,
          position: :bottom,
          class: nil
        })

      assert html =~ "phia-x-axis"
      assert html =~ "line"
      assert html =~ "text"
      # Should have formatted tick labels
      assert html =~ "50"
    end

    test "renders with title" do
      scale = ChartScales.linear_scale(0, 100, 44, 384)

      html =
        render_component(&ChartAxis.x_axis/1, %{
          ticks: [0, 50, 100],
          scale: scale,
          y: 260,
          width: 340,
          x_offset: 0,
          tick_size: 5,
          label_format: nil,
          title: "Time",
          position: :bottom,
          class: nil
        })

      assert html =~ "Time"
    end

    test "uses custom label format" do
      scale = ChartScales.linear_scale(0, 100, 44, 384)

      html =
        render_component(&ChartAxis.x_axis/1, %{
          ticks: [50],
          scale: scale,
          y: 260,
          width: 340,
          x_offset: 0,
          tick_size: 5,
          label_format: fn v -> "#{trunc(v)}%" end,
          title: nil,
          position: :bottom,
          class: nil
        })

      assert html =~ "50%"
    end

    test "renders top position" do
      scale = ChartScales.linear_scale(0, 100, 44, 384)

      html =
        render_component(&ChartAxis.x_axis/1, %{
          ticks: [0, 100],
          scale: scale,
          y: 16,
          width: 340,
          x_offset: 0,
          tick_size: 5,
          label_format: nil,
          title: nil,
          position: :top,
          class: nil
        })

      assert html =~ "phia-x-axis"
    end
  end

  describe "y_axis/1" do
    test "renders ticks and labels" do
      scale = ChartScales.linear_scale(0, 100, 260, 16)

      html =
        render_component(&ChartAxis.y_axis/1, %{
          ticks: [0, 50, 100],
          scale: scale,
          x: 44,
          height: 244,
          y_offset: 0,
          tick_size: 5,
          label_format: nil,
          title: nil,
          position: :left,
          class: nil
        })

      assert html =~ "phia-y-axis"
      assert html =~ "50"
    end

    test "renders with title" do
      scale = ChartScales.linear_scale(0, 100, 260, 16)

      html =
        render_component(&ChartAxis.y_axis/1, %{
          ticks: [0, 100],
          scale: scale,
          x: 44,
          height: 244,
          y_offset: 0,
          tick_size: 5,
          label_format: nil,
          title: "Revenue",
          position: :left,
          class: nil
        })

      assert html =~ "Revenue"
      assert html =~ "rotate"
    end

    test "renders right position" do
      scale = ChartScales.linear_scale(0, 100, 260, 16)

      html =
        render_component(&ChartAxis.y_axis/1, %{
          ticks: [0, 100],
          scale: scale,
          x: 384,
          height: 244,
          y_offset: 0,
          tick_size: 5,
          label_format: nil,
          title: nil,
          position: :right,
          class: nil
        })

      assert html =~ "phia-y-axis"
    end
  end

  describe "radial_axis/1" do
    test "renders labels around circle" do
      html =
        render_component(&ChartAxis.radial_axis/1, %{
          labels: ["N", "E", "S", "W"],
          cx: 200,
          cy: 150,
          radius: 100,
          class: nil
        })

      assert html =~ "phia-radial-axis"
      assert html =~ "N"
      assert html =~ "E"
      assert html =~ "S"
      assert html =~ "W"
    end

    test "handles empty labels" do
      html =
        render_component(&ChartAxis.radial_axis/1, %{
          labels: [],
          cx: 200,
          cy: 150,
          radius: 100,
          class: nil
        })

      assert html =~ "phia-radial-axis"
    end
  end

  describe "angle_axis/1" do
    test "renders concentric rings" do
      scale = ChartScales.linear_scale(0, 100, 0, 120)

      html =
        render_component(&ChartAxis.angle_axis/1, %{
          ticks: [0, 25, 50, 75, 100],
          scale: scale,
          cx: 200,
          cy: 150,
          label_format: nil,
          class: nil
        })

      assert html =~ "phia-angle-axis"
      assert html =~ "circle"
      assert html =~ "50"
    end
  end
end
