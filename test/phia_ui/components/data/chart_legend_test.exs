defmodule PhiaUi.Components.Data.ChartLegendTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  alias PhiaUi.Components.Data.ChartLegend

  describe "chart_legend/1" do
    test "renders legend items" do
      html =
        render_component(&ChartLegend.chart_legend/1, %{
          items: [
            %{label: "Revenue", color: "blue"},
            %{label: "Cost", color: "red"}
          ],
          position: :bottom,
          class: nil
        })

      assert html =~ "Chart legend"
      assert html =~ "Revenue"
      assert html =~ "Cost"
      assert html =~ ~s(background-color: blue)
      assert html =~ ~s(background-color: red)
    end

    test "renders horizontal layout for bottom position" do
      html =
        render_component(&ChartLegend.chart_legend/1, %{
          items: [%{label: "A", color: "blue"}],
          position: :bottom,
          class: nil
        })

      assert html =~ "flex-row"
    end

    test "renders vertical layout for left position" do
      html =
        render_component(&ChartLegend.chart_legend/1, %{
          items: [%{label: "A", color: "blue"}],
          position: :left,
          class: nil
        })

      assert html =~ "flex-col"
    end

    test "renders circle shape" do
      html =
        render_component(&ChartLegend.chart_legend/1, %{
          items: [%{label: "A", color: "blue", shape: :circle}],
          position: :bottom,
          class: nil
        })

      assert html =~ "rounded-full"
    end

    test "renders line shape" do
      html =
        render_component(&ChartLegend.chart_legend/1, %{
          items: [%{label: "A", color: "blue", shape: :line}],
          position: :bottom,
          class: nil
        })

      assert html =~ "h-0.5"
    end
  end

  describe "chart_legend_item/1" do
    test "renders individual item with square swatch" do
      html =
        render_component(&ChartLegend.chart_legend_item/1, %{
          label: "Series 1",
          color: "green",
          shape: :square,
          class: nil
        })

      assert html =~ "Series 1"
      assert html =~ "rounded-sm"
      assert html =~ ~s(background-color: green)
    end

    test "applies custom class" do
      html =
        render_component(&ChartLegend.chart_legend_item/1, %{
          label: "Test",
          color: "red",
          shape: :square,
          class: "opacity-50"
        })

      assert html =~ "opacity-50"
    end
  end
end
