defmodule PhiaUi.Components.Data.ChartCrosshairTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  alias PhiaUi.Components.Data.ChartCrosshair

  @base_attrs %{
    id: "test-crosshair",
    type: :x,
    snap: true,
    chart_area: %{x: 44, y: 16, width: 340, height: 244},
    points_json: "[]",
    color: "currentColor",
    show_label: false,
    class: nil
  }

  describe "chart_crosshair/1" do
    test "renders crosshair group with hook" do
      html = render_component(&ChartCrosshair.chart_crosshair/1, @base_attrs)

      assert html =~ "phx-hook"
      assert html =~ "PhiaChartCrosshair"
      assert html =~ ~s(id="test-crosshair")
    end

    test "renders vertical crosshair line for :x type" do
      html = render_component(&ChartCrosshair.chart_crosshair/1, @base_attrs)

      assert html =~ ~s(data-role="crosshair-x")
    end

    test "renders horizontal crosshair line for :y type" do
      attrs = Map.put(@base_attrs, :type, :y)
      html = render_component(&ChartCrosshair.chart_crosshair/1, attrs)

      assert html =~ ~s(data-role="crosshair-y")
      refute html =~ ~s(data-role="crosshair-x")
    end

    test "renders both lines for :both type" do
      attrs = Map.put(@base_attrs, :type, :both)
      html = render_component(&ChartCrosshair.chart_crosshair/1, attrs)

      assert html =~ ~s(data-role="crosshair-x")
      assert html =~ ~s(data-role="crosshair-y")
    end

    test "renders snap dot when snap is true" do
      html = render_component(&ChartCrosshair.chart_crosshair/1, @base_attrs)

      assert html =~ ~s(data-role="crosshair-dot")
    end

    test "hides snap dot when snap is false" do
      attrs = Map.put(@base_attrs, :snap, false)
      html = render_component(&ChartCrosshair.chart_crosshair/1, attrs)

      refute html =~ ~s(data-role="crosshair-dot")
    end

    test "renders overlay rect for pointer capture" do
      html = render_component(&ChartCrosshair.chart_crosshair/1, @base_attrs)

      assert html =~ ~s(data-role="crosshair-overlay")
      assert html =~ "crosshair"
    end

    test "passes chart area as data attributes" do
      html = render_component(&ChartCrosshair.chart_crosshair/1, @base_attrs)

      assert html =~ ~s(data-area-x="44")
      assert html =~ ~s(data-area-y="16")
      assert html =~ ~s(data-area-w="340")
      assert html =~ ~s(data-area-h="244")
    end

    test "passes points JSON as data attribute" do
      points = Jason.encode!([%{px: 100, py: 50, label: "Q1", value: 200}])
      attrs = Map.put(@base_attrs, :points_json, points)
      html = render_component(&ChartCrosshair.chart_crosshair/1, attrs)

      assert html =~ "data-points"
    end

    test "uses custom color" do
      attrs = Map.put(@base_attrs, :color, "red")
      html = render_component(&ChartCrosshair.chart_crosshair/1, attrs)

      assert html =~ ~s(stroke="red")
    end
  end
end
