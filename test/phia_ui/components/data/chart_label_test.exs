defmodule PhiaUi.Components.Data.ChartLabelTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  alias PhiaUi.Components.Data.ChartLabel

  describe "chart_label/1" do
    test "renders SVG text element" do
      html =
        render_component(&ChartLabel.chart_label/1, %{
          value: "42",
          position: :top,
          x: 100,
          y: 50,
          width: 80,
          height: 30,
          offset: 5,
          font_size: "9",
          color: nil,
          class: nil
        })

      assert html =~ "<text"
      assert html =~ "42"
      assert html =~ "text-anchor"
      assert html =~ "dominant-baseline"
    end

    test "positions label at top" do
      html =
        render_component(&ChartLabel.chart_label/1, %{
          value: "Top",
          position: :top,
          x: 0,
          y: 50,
          width: 100,
          height: 40,
          offset: 5,
          font_size: "9",
          color: nil,
          class: nil
        })

      assert html =~ "Top"
      assert html =~ ~s[text-anchor="middle"]
      assert html =~ ~s[y="45.0"]
    end

    test "positions label at bottom" do
      html =
        render_component(&ChartLabel.chart_label/1, %{
          value: "Bottom",
          position: :bottom,
          x: 0,
          y: 0,
          width: 100,
          height: 40,
          offset: 5,
          font_size: "9",
          color: nil,
          class: nil
        })

      assert html =~ "Bottom"
      assert html =~ ~s[text-anchor="middle"]
      assert html =~ ~s[dominant-baseline="hanging"]
    end

    test "positions label at center" do
      html =
        render_component(&ChartLabel.chart_label/1, %{
          value: "Center",
          position: :center,
          x: 0,
          y: 0,
          width: 100,
          height: 100,
          offset: 5,
          font_size: "9",
          color: nil,
          class: nil
        })

      assert html =~ "Center"
      assert html =~ ~s[x="50.0"]
      assert html =~ ~s[y="50.0"]
    end

    test "positions label at inside_top_right" do
      html =
        render_component(&ChartLabel.chart_label/1, %{
          value: "TR",
          position: :inside_top_right,
          x: 0,
          y: 0,
          width: 200,
          height: 100,
          offset: 10,
          font_size: "9",
          color: nil,
          class: nil
        })

      assert html =~ "TR"
      assert html =~ ~s[x="190.0"]
      assert html =~ ~s[y="10.0"]
      assert html =~ ~s[text-anchor="end"]
    end

    test "applies custom color" do
      html =
        render_component(&ChartLabel.chart_label/1, %{
          value: "Colored",
          position: :top,
          x: 0,
          y: 50,
          width: 100,
          height: 40,
          offset: 5,
          font_size: "12",
          color: "red",
          class: nil
        })

      assert html =~ ~s[fill="red"]
    end

    test "applies custom font_size" do
      html =
        render_component(&ChartLabel.chart_label/1, %{
          value: "Big",
          position: :center,
          x: 0,
          y: 0,
          width: 100,
          height: 100,
          offset: 5,
          font_size: "14",
          color: nil,
          class: nil
        })

      assert html =~ ~s[font-size="14"]
    end

    test "positions label at left" do
      html =
        render_component(&ChartLabel.chart_label/1, %{
          value: "Left",
          position: :left,
          x: 50,
          y: 0,
          width: 100,
          height: 80,
          offset: 5,
          font_size: "9",
          color: nil,
          class: nil
        })

      assert html =~ "Left"
      assert html =~ ~s[text-anchor="end"]
      assert html =~ ~s[x="45.0"]
    end

    test "positions label at right" do
      html =
        render_component(&ChartLabel.chart_label/1, %{
          value: "Right",
          position: :right,
          x: 0,
          y: 0,
          width: 100,
          height: 80,
          offset: 5,
          font_size: "9",
          color: nil,
          class: nil
        })

      assert html =~ "Right"
      assert html =~ ~s[text-anchor="start"]
      assert html =~ ~s[x="105.0"]
    end
  end
end
