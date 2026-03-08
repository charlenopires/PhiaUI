defmodule PhiaUi.Components.Data.ChartSvgDefsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  alias PhiaUi.Components.Data.ChartSvgDefs

  describe "chart_linear_gradient/1" do
    test "renders linearGradient with stops" do
      html =
        render_component(&ChartSvgDefs.chart_linear_gradient/1, %{
          id: "grad1",
          stops: [
            %{offset: "0%", color: "red"},
            %{offset: "100%", color: "blue"}
          ],
          x1: "0%",
          y1: "0%",
          x2: "0%",
          y2: "100%"
        })

      assert html =~ "linearGradient"
      assert html =~ ~s(id="grad1")
      assert html =~ ~s(stop-color="red")
      assert html =~ ~s(stop-color="blue")
      assert html =~ ~s(offset="0%")
      assert html =~ ~s(offset="100%")
    end

    test "renders custom direction" do
      html =
        render_component(&ChartSvgDefs.chart_linear_gradient/1, %{
          id: "horiz",
          stops: [%{offset: "0%", color: "red"}],
          x1: "0%",
          y1: "0%",
          x2: "100%",
          y2: "0%"
        })

      assert html =~ ~s(x2="100%")
    end

    test "renders stop opacity" do
      html =
        render_component(&ChartSvgDefs.chart_linear_gradient/1, %{
          id: "opaque",
          stops: [%{offset: "0%", color: "red", opacity: "0.5"}],
          x1: "0%",
          y1: "0%",
          x2: "0%",
          y2: "100%"
        })

      assert html =~ ~s(stop-opacity="0.5")
    end
  end

  describe "chart_radial_gradient/1" do
    test "renders radialGradient" do
      html =
        render_component(&ChartSvgDefs.chart_radial_gradient/1, %{
          id: "radial1",
          stops: [
            %{offset: "0%", color: "white"},
            %{offset: "100%", color: "black"}
          ],
          cx: "50%",
          cy: "50%",
          r: "50%"
        })

      assert html =~ "radialGradient"
      assert html =~ ~s(id="radial1")
      assert html =~ ~s(stop-color="white")
      assert html =~ ~s(stop-color="black")
    end

    test "renders custom center and radius" do
      html =
        render_component(&ChartSvgDefs.chart_radial_gradient/1, %{
          id: "custom",
          stops: [%{offset: "0%", color: "red"}],
          cx: "30%",
          cy: "70%",
          r: "40%"
        })

      assert html =~ ~s(cx="30%")
      assert html =~ ~s(cy="70%")
      assert html =~ ~s(r="40%")
    end
  end

  describe "chart_pattern/1" do
    test "renders dots pattern" do
      html =
        render_component(&ChartSvgDefs.chart_pattern/1, %{
          id: "dots1",
          type: :dots,
          size: 8,
          color: "currentColor",
          opacity: "0.2"
        })

      assert html =~ "pattern"
      assert html =~ ~s(id="dots1")
      assert html =~ "circle"
    end

    test "renders lines pattern" do
      html =
        render_component(&ChartSvgDefs.chart_pattern/1, %{
          id: "lines1",
          type: :lines,
          size: 8,
          color: "gray",
          opacity: "0.3"
        })

      assert html =~ "pattern"
      assert html =~ "line"
    end

    test "renders crosshatch pattern" do
      html =
        render_component(&ChartSvgDefs.chart_pattern/1, %{
          id: "cross1",
          type: :crosshatch,
          size: 10,
          color: "black",
          opacity: "0.2"
        })

      assert html =~ "pattern"
      # Crosshatch has two lines
      assert length(Regex.scan(~r/<line/, html)) >= 2
    end

    test "renders diagonal pattern" do
      html =
        render_component(&ChartSvgDefs.chart_pattern/1, %{
          id: "diag1",
          type: :diagonal,
          size: 8,
          color: "blue",
          opacity: "0.2"
        })

      assert html =~ "pattern"
      assert html =~ "line"
    end
  end

  describe "chart_clip_path/1" do
    test "renders clipPath with rect" do
      html =
        render_component(&ChartSvgDefs.chart_clip_path/1, %{
          id: "clip1",
          x: 10,
          y: 20,
          width: 300,
          height: 200
        })

      assert html =~ "clipPath"
      assert html =~ ~s(id="clip1")
      assert html =~ "rect"
      assert html =~ ~s(width="300")
      assert html =~ ~s(height="200")
    end
  end
end
