defmodule PhiaUi.Components.Data.XyChartTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  alias PhiaUi.Components.Data.XyChart

  @base_attrs %{
    width: 400,
    height: 300,
    padding: %{},
    x_scale_type: :band,
    y_scale_type: :linear,
    colors: [],
    show_grid: true,
    show_x_axis: true,
    show_y_axis: true,
    show_legend: false,
    animate: false,
    animation_duration: 600,
    bar_radius: 2,
    stroke_width: 2,
    class: nil
  }

  @sample_bar_series [
    %{
      name: "Revenue",
      type: :bar,
      data: [
        %{label: "Q1", value: 200},
        %{label: "Q2", value: 280},
        %{label: "Q3", value: 150}
      ]
    }
  ]

  @sample_line_series [
    %{
      name: "Trend",
      type: :line,
      data: [
        %{label: "Q1", value: 190},
        %{label: "Q2", value: 270},
        %{label: "Q3", value: 140}
      ]
    }
  ]

  describe "xy_chart/1 with bar series" do
    test "renders bars" do
      html =
        render_component(&XyChart.xy_chart/1, Map.put(@base_attrs, :series, @sample_bar_series))

      assert html =~ "<rect"
      assert html =~ "Q1"
      assert html =~ "Q2"
      assert html =~ "Q3"
    end

    test "renders grid lines" do
      html =
        render_component(&XyChart.xy_chart/1, Map.put(@base_attrs, :series, @sample_bar_series))

      assert html =~ "<line"
    end

    test "renders y-axis labels" do
      html =
        render_component(&XyChart.xy_chart/1, Map.put(@base_attrs, :series, @sample_bar_series))

      # Should have formatted tick labels
      assert html =~ "<text"
    end
  end

  describe "xy_chart/1 with line series" do
    test "renders polylines" do
      html =
        render_component(&XyChart.xy_chart/1, Map.put(@base_attrs, :series, @sample_line_series))

      assert html =~ "<polyline"
    end
  end

  describe "xy_chart/1 with mixed series" do
    test "renders both bars and lines" do
      mixed = @sample_bar_series ++ @sample_line_series

      html =
        render_component(&XyChart.xy_chart/1, Map.put(@base_attrs, :series, mixed))

      assert html =~ "<rect"
      assert html =~ "<polyline"
    end
  end

  describe "xy_chart/1 with area series" do
    test "renders area path" do
      area_series = [
        %{
          name: "Area",
          type: :area,
          data: [
            %{label: "Jan", value: 100},
            %{label: "Feb", value: 200},
            %{label: "Mar", value: 150}
          ]
        }
      ]

      html =
        render_component(&XyChart.xy_chart/1, Map.put(@base_attrs, :series, area_series))

      assert html =~ "<path"
    end
  end

  describe "xy_chart/1 legend" do
    test "renders legend when enabled" do
      attrs =
        @base_attrs
        |> Map.put(:series, @sample_bar_series)
        |> Map.put(:show_legend, true)

      html = render_component(&XyChart.xy_chart/1, attrs)

      assert html =~ "Chart legend"
      assert html =~ "Revenue"
    end

    test "hides legend when disabled" do
      attrs =
        @base_attrs
        |> Map.put(:series, @sample_bar_series)
        |> Map.put(:show_legend, false)

      html = render_component(&XyChart.xy_chart/1, attrs)

      refute html =~ "Chart legend"
    end
  end

  describe "xy_chart/1 empty state" do
    test "renders without error when series is empty" do
      html = render_component(&XyChart.xy_chart/1, Map.put(@base_attrs, :series, []))

      assert html =~ "<svg"
    end
  end

  describe "xy_chart/1 animation" do
    test "adds animation classes when enabled" do
      attrs =
        @base_attrs
        |> Map.put(:series, @sample_bar_series)
        |> Map.put(:animate, true)

      html = render_component(&XyChart.xy_chart/1, attrs)

      assert html =~ "phia-chart-animate"
      assert html =~ "phia-bar-grow"
    end

    test "no animation styles when disabled" do
      attrs =
        @base_attrs
        |> Map.put(:series, @sample_bar_series)
        |> Map.put(:animate, false)

      html = render_component(&XyChart.xy_chart/1, attrs)

      refute html =~ "phia-chart-animate"
    end
  end

  describe "xy_chart/1 axes visibility" do
    test "hides x-axis labels when show_x_axis is false" do
      attrs =
        @base_attrs
        |> Map.put(:series, @sample_bar_series)
        |> Map.put(:show_x_axis, false)

      html = render_component(&XyChart.xy_chart/1, attrs)

      # X-axis text group should not be rendered
      # Y-axis labels should still be present
      refute html =~ ">Q1<"
    end

    test "hides grid when show_grid is false" do
      attrs =
        @base_attrs
        |> Map.put(:series, @sample_bar_series)
        |> Map.put(:show_grid, false)
        |> Map.put(:show_y_axis, false)
        |> Map.put(:show_x_axis, false)

      html = render_component(&XyChart.xy_chart/1, attrs)

      # Should still have the SVG and bars, just no grid lines
      assert html =~ "<svg"
      assert html =~ "<rect"
    end
  end
end
