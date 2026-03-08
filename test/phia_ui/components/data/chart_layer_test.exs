defmodule PhiaUi.Components.Data.ChartLayerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  alias PhiaUi.Components.Data.ChartLayer

  describe "chart_layer/1" do
    test "renders a g element" do
      html =
        render_component(&ChartLayer.chart_layer/1, %{
          z: 0,
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "layer content" end}]
        })

      assert html =~ "<g"
      assert html =~ "</g>"
    end

    test "includes data-z attribute" do
      html =
        render_component(&ChartLayer.chart_layer/1, %{
          z: 400,
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "content" end}]
        })

      assert html =~ ~s[data-z="400"]
    end

    test "standard z values for grid layer" do
      html =
        render_component(&ChartLayer.chart_layer/1, %{
          z: -100,
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "grid" end}]
        })

      assert html =~ ~s[data-z="-100"]
    end

    test "applies custom class" do
      html =
        render_component(&ChartLayer.chart_layer/1, %{
          z: 0,
          class: "my-layer",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "content" end}]
        })

      assert html =~ "my-layer"
    end

    test "renders slot content" do
      html =
        render_component(&ChartLayer.chart_layer/1, %{
          z: 300,
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "bar series here" end}]
        })

      assert html =~ "bar series here"
    end
  end
end
