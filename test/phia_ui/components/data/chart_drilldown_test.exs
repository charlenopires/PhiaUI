defmodule PhiaUi.Components.Data.ChartDrilldownTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  alias PhiaUi.Components.Data.ChartDrilldown

  describe "chart_drilldown/1" do
    test "renders inner block content" do
      html =
        render_component(&ChartDrilldown.chart_drilldown/1, %{
          levels: ["Region", "Country"],
          current_level: 0,
          breadcrumb_items: [],
          on_drill: "drill",
          on_up: "up",
          animate: true,
          class: nil,
          inner_block: [
            %{
              __slot__: :inner_block,
              inner_block: fn _a, _c -> "CHART_CONTENT" end
            }
          ]
        })

      assert html =~ "CHART_CONTENT"
    end

    test "shows no breadcrumb at root level" do
      html =
        render_component(&ChartDrilldown.chart_drilldown/1, %{
          levels: ["Region", "Country"],
          current_level: 0,
          breadcrumb_items: [],
          on_drill: nil,
          on_up: nil,
          animate: false,
          class: nil,
          inner_block: [
            %{
              __slot__: :inner_block,
              inner_block: fn _a, _c -> "chart" end
            }
          ]
        })

      refute html =~ "drill navigation"
    end

    test "shows breadcrumb when drilled down" do
      html =
        render_component(&ChartDrilldown.chart_drilldown/1, %{
          levels: ["Region", "Country"],
          current_level: 1,
          breadcrumb_items: ["All Regions", "USA"],
          on_drill: nil,
          on_up: "drill_up",
          animate: false,
          class: nil,
          inner_block: [
            %{
              __slot__: :inner_block,
              inner_block: fn _a, _c -> "chart" end
            }
          ]
        })

      assert html =~ "drill navigation"
      assert html =~ "All Regions"
      assert html =~ "USA"
    end

    test "adds drill animation class when animate is true" do
      html =
        render_component(&ChartDrilldown.chart_drilldown/1, %{
          levels: ["A", "B"],
          current_level: 1,
          breadcrumb_items: ["Root", "Child"],
          on_drill: nil,
          on_up: nil,
          animate: true,
          class: nil,
          inner_block: [
            %{
              __slot__: :inner_block,
              inner_block: fn _a, _c -> "chart" end
            }
          ]
        })

      assert html =~ "phia-drilldown-enter"
    end

    test "applies custom class" do
      html =
        render_component(&ChartDrilldown.chart_drilldown/1, %{
          levels: [],
          current_level: 0,
          breadcrumb_items: [],
          on_drill: nil,
          on_up: nil,
          animate: false,
          class: "my-class",
          inner_block: [
            %{
              __slot__: :inner_block,
              inner_block: fn _a, _c -> "" end
            }
          ]
        })

      assert html =~ "my-class"
    end
  end

  describe "chart_drilldown_breadcrumb/1" do
    test "renders breadcrumb items" do
      html =
        render_component(&ChartDrilldown.chart_drilldown_breadcrumb/1, %{
          items: ["Root", "Level 1", "Current"],
          on_up: "drill_up",
          class: nil
        })

      assert html =~ "Root"
      assert html =~ "Level 1"
      assert html =~ "Current"
      assert html =~ "drill navigation"
    end

    test "last item has font-medium class" do
      html =
        render_component(&ChartDrilldown.chart_drilldown_breadcrumb/1, %{
          items: ["Root", "Current"],
          on_up: "drill_up",
          class: nil
        })

      assert html =~ "font-medium"
    end

    test "items have phx-click for drill up" do
      html =
        render_component(&ChartDrilldown.chart_drilldown_breadcrumb/1, %{
          items: ["Root", "Current"],
          on_up: "drill_up",
          class: nil
        })

      assert html =~ "phx-click"
      assert html =~ "drill_up"
    end
  end
end
