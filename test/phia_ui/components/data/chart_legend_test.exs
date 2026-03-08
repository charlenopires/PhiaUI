defmodule PhiaUi.Components.Data.ChartLegendTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  alias PhiaUi.Components.Data.ChartLegend

  @legend_base %{
    items: [],
    position: :bottom,
    interactive: false,
    on_toggle: nil,
    visible_series: [],
    class: nil
  }

  @item_base %{
    label: "Series",
    color: "blue",
    shape: :square,
    interactive: false,
    on_toggle: nil,
    active: true,
    class: nil
  }

  describe "chart_legend/1" do
    test "renders legend items" do
      html =
        render_component(&ChartLegend.chart_legend/1, %{
          @legend_base
          | items: [
              %{label: "Revenue", color: "blue"},
              %{label: "Cost", color: "red"}
            ]
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
          @legend_base
          | items: [%{label: "A", color: "blue"}],
            position: :bottom
        })

      assert html =~ "flex-row"
    end

    test "renders vertical layout for left position" do
      html =
        render_component(&ChartLegend.chart_legend/1, %{
          @legend_base
          | items: [%{label: "A", color: "blue"}],
            position: :left
        })

      assert html =~ "flex-col"
    end

    test "renders circle shape" do
      html =
        render_component(&ChartLegend.chart_legend/1, %{
          @legend_base
          | items: [%{label: "A", color: "blue", shape: :circle}]
        })

      assert html =~ "rounded-full"
    end

    test "renders line shape" do
      html =
        render_component(&ChartLegend.chart_legend/1, %{
          @legend_base
          | items: [%{label: "A", color: "blue", shape: :line}]
        })

      assert html =~ "h-0.5"
    end

    test "interactive mode renders buttons" do
      html =
        render_component(&ChartLegend.chart_legend/1, %{
          @legend_base
          | items: [%{label: "Revenue", color: "blue"}],
            interactive: true,
            on_toggle: "toggle_series"
        })

      assert html =~ "<button"
      assert html =~ "toggle_series"
      assert html =~ "phx-click"
    end

    test "non-interactive mode renders divs" do
      html =
        render_component(&ChartLegend.chart_legend/1, %{
          @legend_base
          | items: [%{label: "Revenue", color: "blue"}]
        })

      refute html =~ "<button"
    end

    test "interactive mode shows reduced opacity for hidden series" do
      html =
        render_component(&ChartLegend.chart_legend/1, %{
          @legend_base
          | items: [
              %{label: "Revenue", color: "blue"},
              %{label: "Cost", color: "red"}
            ],
            interactive: true,
            on_toggle: "toggle",
            visible_series: ["Revenue"]
        })

      assert html =~ "opacity-30"
      assert html =~ "line-through"
    end

    test "interactive mode shows all active when visible_series is empty" do
      html =
        render_component(&ChartLegend.chart_legend/1, %{
          @legend_base
          | items: [
              %{label: "Revenue", color: "blue"},
              %{label: "Cost", color: "red"}
            ],
            interactive: true,
            on_toggle: "toggle",
            visible_series: []
        })

      refute html =~ "line-through"
    end
  end

  describe "chart_legend_item/1" do
    test "renders individual item with square swatch" do
      html =
        render_component(&ChartLegend.chart_legend_item/1, %{
          @item_base
          | label: "Series 1",
            color: "green"
        })

      assert html =~ "Series 1"
      assert html =~ "rounded-sm"
      assert html =~ ~s(background-color: green)
    end

    test "applies custom class" do
      html =
        render_component(&ChartLegend.chart_legend_item/1, %{
          @item_base
          | label: "Test",
            color: "red",
            class: "opacity-50"
        })

      assert html =~ "opacity-50"
    end

    test "interactive item renders as button" do
      html =
        render_component(&ChartLegend.chart_legend_item/1, %{
          @item_base
          | interactive: true,
            on_toggle: "toggle_series"
        })

      assert html =~ "<button"
      assert html =~ "phx-click"
    end

    test "inactive item shows reduced opacity" do
      html =
        render_component(&ChartLegend.chart_legend_item/1, %{
          @item_base
          | active: false,
            interactive: true,
            on_toggle: "toggle"
        })

      assert html =~ "opacity-30"
    end

    test "active item has no opacity reduction" do
      html =
        render_component(&ChartLegend.chart_legend_item/1, %{
          @item_base
          | active: true
        })

      refute html =~ "opacity-30"
    end
  end
end
