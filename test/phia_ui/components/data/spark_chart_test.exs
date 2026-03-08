defmodule PhiaUi.Components.Data.SparkChartTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Data.SparkChart

    def render_spark_line(assigns) do
      ~H"""
      <.spark_line_chart data={[4, 7, 5, 10, 3, 8]} />
      """
    end

    def render_spark_line_empty(assigns) do
      ~H"""
      <.spark_line_chart data={[]} />
      """
    end

    def render_spark_line_custom(assigns) do
      ~H"""
      <.spark_line_chart data={[1, 2, 3]} color="red" curve={:smooth} class="w-40 h-16" />
      """
    end

    def render_spark_area(assigns) do
      ~H"""
      <.spark_area_chart data={[4, 7, 5, 10, 3, 8]} />
      """
    end

    def render_spark_area_no_gradient(assigns) do
      ~H"""
      <.spark_area_chart data={[4, 7, 5, 10, 3, 8]} show_gradient={false} />
      """
    end

    def render_spark_bar(assigns) do
      ~H"""
      <.spark_bar_chart data={[4, 7, 5, 10, 3, 8]} />
      """
    end

    def render_spark_bar_animated(assigns) do
      ~H"""
      <.spark_bar_chart data={[4, 7, 5, 10, 3, 8]} show_animation />
      """
    end
  end

  describe "spark_line_chart/1" do
    test "renders SVG with path" do
      html = render_component(&H.render_spark_line/1, %{})
      assert html =~ "<svg"
      assert html =~ "<path"
      assert html =~ ~s(viewBox="0 0 112 48")
    end

    test "renders empty div for empty data" do
      html = render_component(&H.render_spark_line_empty/1, %{})
      assert html =~ "w-28"
      refute html =~ "<svg"
    end

    test "applies custom color and class" do
      html = render_component(&H.render_spark_line_custom/1, %{})
      assert html =~ ~s(stroke="red")
      assert html =~ "w-40"
      assert html =~ "h-16"
    end

    test "uses default stroke color" do
      html = render_component(&H.render_spark_line/1, %{})
      assert html =~ "oklch(0.60 0.20 240)"
    end
  end

  describe "spark_area_chart/1" do
    test "renders SVG with gradient and paths" do
      html = render_component(&H.render_spark_area/1, %{})
      assert html =~ "<svg"
      assert html =~ "linearGradient"
      assert html =~ "<path"
    end

    test "renders gradient with opacity stops" do
      html = render_component(&H.render_spark_area/1, %{})
      assert html =~ ~s(stop-opacity="0.4")
      assert html =~ ~s(stop-opacity="0")
    end

    test "renders flat fill without gradient" do
      html = render_component(&H.render_spark_area_no_gradient/1, %{})
      assert html =~ ~s(stop-opacity="0.3")
    end
  end

  describe "spark_bar_chart/1" do
    test "renders SVG with rect elements" do
      html = render_component(&H.render_spark_bar/1, %{})
      assert html =~ "<svg"
      assert html =~ "<rect"
    end

    test "renders bars with correct fill color" do
      html = render_component(&H.render_spark_bar/1, %{})
      assert html =~ "oklch(0.60 0.20 240)"
    end

    test "renders bars with animation" do
      html = render_component(&H.render_spark_bar_animated/1, %{})
      assert html =~ "phia-bar-grow"
    end
  end
end
