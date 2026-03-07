defmodule PhiaUi.Components.HeatmapChartTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.HeatmapChart

    def render_default(assigns) do
      ~H"""
      <.heatmap_chart
        data={[[10, 20, 5], [30, 15, 25], [8, 40, 12]]}
        row_labels={["Mon", "Tue", "Wed"]}
        col_labels={["AM", "PM", "Night"]}
      />
      """
    end

    def render_empty(assigns) do
      ~H"""
      <.heatmap_chart data={[]} />
      """
    end

    def render_single_cell(assigns) do
      ~H"""
      <.heatmap_chart data={[[42]]} row_labels={["Row1"]} col_labels={["Col1"]} />
      """
    end

    def render_all_zero(assigns) do
      ~H"""
      <.heatmap_chart data={[[0, 0], [0, 0]]} />
      """
    end

    def render_no_animate(assigns) do
      ~H"""
      <.heatmap_chart data={[[1, 2], [3, 4]]} animate={false} />
      """
    end

    def render_custom_colors(assigns) do
      ~H"""
      <.heatmap_chart
        data={[[1, 5], [3, 8]]}
        color_scale={["oklch(0.95 0.05 30)", "oklch(0.55 0.22 30)"]}
      />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.heatmap_chart data={[[1, 2]]} class="my-heatmap" />
      """
    end
  end

  describe "heatmap_chart/1" do
    test "renders root div" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<div"
    end

    test "renders SVG" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<svg"
    end

    test "renders rect elements for cells" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<rect"
    end

    test "renders 9 cells for 3x3 grid" do
      html = render_component(&H.render_default/1, %{})
      rect_count = html |> String.split("<rect") |> length() |> Kernel.-(1)
      assert rect_count == 9
    end

    test "renders row labels" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Mon"
      assert html =~ "Tue"
      assert html =~ "Wed"
    end

    test "renders column labels" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "AM"
      assert html =~ "PM"
      assert html =~ "Night"
    end

    test "empty data renders SVG without crash" do
      html = render_component(&H.render_empty/1, %{})
      assert html =~ "<svg"
    end

    test "single cell renders" do
      html = render_component(&H.render_single_cell/1, %{})
      assert html =~ "<rect"
    end

    test "all-zero data renders without crash" do
      html = render_component(&H.render_all_zero/1, %{})
      assert html =~ "<rect"
    end

    test "animate true adds phia-chart-animate class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phia-chart-animate"
    end

    test "animate false removes animation" do
      html = render_component(&H.render_no_animate/1, %{})
      refute html =~ "phia-fade-in"
    end

    test "animate true adds fade-in animation" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phia-fade-in"
    end

    test "custom color scale applied to cells" do
      html = render_component(&H.render_custom_colors/1, %{})
      assert html =~ "oklch(0.95 0.05 30)"
    end

    test "custom class applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-heatmap"
    end

    test "cells have fill-opacity" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "fill-opacity"
    end
  end
end
