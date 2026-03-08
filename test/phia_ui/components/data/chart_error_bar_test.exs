defmodule PhiaUi.Components.Data.ChartErrorBarTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  alias PhiaUi.Components.Data.ChartErrorBar

  @sample_data [
    %{px: 100, py_low: 200, py_high: 100},
    %{px: 200, py_low: 180, py_high: 80},
    %{px: 300, py_low: 220, py_high: 120}
  ]

  @base_attrs %{
    data: [],
    cap_width: 8,
    color: "currentColor",
    stroke_width: 1.5,
    animate: false,
    animation_duration: 600,
    class: nil
  }

  describe "chart_error_bar/1" do
    test "renders error bar group" do
      attrs = Map.put(@base_attrs, :data, @sample_data)
      html = render_component(&ChartErrorBar.chart_error_bar/1, attrs)

      assert html =~ "phia-error-bars"
      assert html =~ "<line"
    end

    test "renders vertical line for each data point" do
      attrs = Map.put(@base_attrs, :data, @sample_data)
      html = render_component(&ChartErrorBar.chart_error_bar/1, attrs)

      # Each error bar has 3 lines: vertical + 2 caps = 9 total
      line_count = html |> String.split("<line") |> length() |> Kernel.-(1)
      assert line_count == 9
    end

    test "renders with custom color" do
      attrs = @base_attrs |> Map.put(:data, @sample_data) |> Map.put(:color, "red")
      html = render_component(&ChartErrorBar.chart_error_bar/1, attrs)

      assert html =~ ~s(stroke="red")
    end

    test "renders with custom stroke width" do
      attrs = @base_attrs |> Map.put(:data, @sample_data) |> Map.put(:stroke_width, 2)
      html = render_component(&ChartErrorBar.chart_error_bar/1, attrs)

      assert html =~ ~s(stroke-width="2")
    end

    test "renders animation when enabled" do
      attrs = @base_attrs |> Map.put(:data, @sample_data) |> Map.put(:animate, true)
      html = render_component(&ChartErrorBar.chart_error_bar/1, attrs)

      assert html =~ "phia-error-bar-pop"
    end

    test "no animation when disabled" do
      attrs = @base_attrs |> Map.put(:data, @sample_data) |> Map.put(:animate, false)
      html = render_component(&ChartErrorBar.chart_error_bar/1, attrs)

      refute html =~ "phia-error-bar-pop"
    end

    test "handles empty data" do
      html = render_component(&ChartErrorBar.chart_error_bar/1, @base_attrs)

      assert html =~ "phia-error-bars"
      # No lines rendered
      refute html =~ "<line"
    end

    test "cap width affects horizontal line positions" do
      data = [%{px: 100, py_low: 200, py_high: 100}]
      attrs = @base_attrs |> Map.put(:data, data) |> Map.put(:cap_width, 16)
      html = render_component(&ChartErrorBar.chart_error_bar/1, attrs)

      # Cap should extend 8px on each side (half of 16)
      assert html =~ "92"  # 100 - 8
      assert html =~ "108" # 100 + 8
    end

    test "applies custom class" do
      attrs = @base_attrs |> Map.put(:data, @sample_data) |> Map.put(:class, "custom")
      html = render_component(&ChartErrorBar.chart_error_bar/1, attrs)

      assert html =~ "custom"
    end
  end
end
