defmodule PhiaUi.Components.Data.ChartAnnotationTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  alias PhiaUi.Components.Data.ChartAnnotation
  alias PhiaUi.Components.Data.ChartScales

  describe "chart_annotation_line/1" do
    test "renders horizontal reference line" do
      scale = ChartScales.linear_scale(0, 100, 260, 16)

      html =
        render_component(&ChartAnnotation.chart_annotation_line/1, %{
          value: 75,
          axis: :y,
          scale: scale,
          x: 44,
          y: 0,
          width: 340,
          height: 0,
          label: "Target",
          color: "oklch(0.65 0.22 30)",
          dash_array: "4 3",
          class: nil
        })

      assert html =~ "phia-annotation-line"
      assert html =~ "Target"
      assert html =~ "line"
      assert html =~ ~s(stroke-dasharray="4 3")
    end

    test "renders vertical reference line" do
      scale = ChartScales.linear_scale(0, 100, 44, 384)

      html =
        render_component(&ChartAnnotation.chart_annotation_line/1, %{
          value: 50,
          axis: :x,
          scale: scale,
          x: 0,
          y: 16,
          width: 0,
          height: 244,
          label: nil,
          color: "red",
          dash_array: "4 3",
          class: nil
        })

      assert html =~ "line"
      refute html =~ "<text"
    end

    test "renders without label" do
      scale = ChartScales.linear_scale(0, 100, 260, 16)

      html =
        render_component(&ChartAnnotation.chart_annotation_line/1, %{
          value: 50,
          axis: :y,
          scale: scale,
          x: 44,
          y: 0,
          width: 340,
          height: 0,
          label: nil,
          color: "blue",
          dash_array: "4 3",
          class: nil
        })

      assert html =~ "line"
      refute html =~ ">Target<"
    end
  end

  describe "chart_annotation_band/1" do
    test "renders horizontal band" do
      scale = ChartScales.linear_scale(0, 100, 260, 16)

      html =
        render_component(&ChartAnnotation.chart_annotation_band/1, %{
          from: 40,
          to: 60,
          axis: :y,
          scale: scale,
          x: 44,
          y: 0,
          width: 340,
          height: 0,
          label: "Normal range",
          color: "oklch(0.60 0.20 240 / 0.1)",
          class: nil
        })

      assert html =~ "phia-annotation-band"
      assert html =~ "rect"
      assert html =~ "Normal range"
    end

    test "renders vertical band" do
      scale = ChartScales.linear_scale(0, 100, 44, 384)

      html =
        render_component(&ChartAnnotation.chart_annotation_band/1, %{
          from: 20,
          to: 80,
          axis: :x,
          scale: scale,
          x: 0,
          y: 16,
          width: 0,
          height: 244,
          label: nil,
          color: "rgba(0,0,255,0.1)",
          class: nil
        })

      assert html =~ "rect"
    end

    test "renders without label" do
      scale = ChartScales.linear_scale(0, 100, 260, 16)

      html =
        render_component(&ChartAnnotation.chart_annotation_band/1, %{
          from: 30,
          to: 70,
          axis: :y,
          scale: scale,
          x: 44,
          y: 0,
          width: 340,
          height: 0,
          label: nil,
          color: "blue",
          class: nil
        })

      assert html =~ "rect"
      refute html =~ ">Normal<"
    end
  end

  describe "chart_annotation_point/1" do
    test "renders point marker with label" do
      x_scale = ChartScales.linear_scale(0, 100, 44, 384)
      y_scale = ChartScales.linear_scale(0, 100, 260, 16)

      html =
        render_component(&ChartAnnotation.chart_annotation_point/1, %{
          x_value: 50,
          y_value: 75,
          x_scale: x_scale,
          y_scale: y_scale,
          label: "Peak",
          color: "red",
          radius: 4,
          class: nil
        })

      assert html =~ "phia-annotation-point"
      assert html =~ "circle"
      assert html =~ "Peak"
      assert html =~ ~s(fill="red")
    end

    test "renders without label" do
      x_scale = ChartScales.linear_scale(0, 100, 44, 384)
      y_scale = ChartScales.linear_scale(0, 100, 260, 16)

      html =
        render_component(&ChartAnnotation.chart_annotation_point/1, %{
          x_value: 50,
          y_value: 50,
          x_scale: x_scale,
          y_scale: y_scale,
          label: nil,
          color: "blue",
          radius: 6,
          class: nil
        })

      assert html =~ "circle"
      assert html =~ ~s(r="6")
    end
  end
end
