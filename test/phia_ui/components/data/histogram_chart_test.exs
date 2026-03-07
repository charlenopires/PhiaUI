defmodule PhiaUi.Components.HistogramChartTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.HistogramChart

    def render_default(assigns) do
      ~H"""
      <.histogram_chart data={[2, 5, 7, 3, 9, 1, 4, 8, 6, 3, 5, 7, 2, 6, 8]} />
      """
    end

    def render_empty(assigns) do
      ~H"""
      <.histogram_chart data={[]} />
      """
    end

    def render_single_value(assigns) do
      ~H"""
      <.histogram_chart data={[5]} />
      """
    end

    def render_all_same(assigns) do
      ~H"""
      <.histogram_chart data={[5, 5, 5, 5, 5]} />
      """
    end

    def render_custom_bins(assigns) do
      ~H"""
      <.histogram_chart data={[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]} bins={5} />
      """
    end

    def render_custom_color(assigns) do
      ~H"""
      <.histogram_chart data={[1, 2, 3, 4, 5]} color="oklch(0.65 0.22 30)" />
      """
    end

    def render_no_animate(assigns) do
      ~H"""
      <.histogram_chart data={[1, 2, 3, 4, 5, 6, 7, 8]} animate={false} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.histogram_chart data={[1, 2, 3]} class="my-histogram" />
      """
    end
  end

  describe "histogram_chart/1" do
    test "renders root div" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<div"
    end

    test "renders SVG" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<svg"
    end

    test "renders rect elements for bins" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<rect"
    end

    test "empty data renders SVG without crash" do
      html = render_component(&H.render_empty/1, %{})
      assert html =~ "<svg"
    end

    test "empty data renders no rects" do
      html = render_component(&H.render_empty/1, %{})
      refute html =~ "<rect"
    end

    test "single value renders" do
      html = render_component(&H.render_single_value/1, %{})
      assert html =~ "<svg"
    end

    test "all-same values render without crash" do
      html = render_component(&H.render_all_same/1, %{})
      assert html =~ "<svg"
    end

    test "custom bins count used" do
      html = render_component(&H.render_custom_bins/1, %{})
      rect_count = html |> String.split("<rect") |> length() |> Kernel.-(1)
      assert rect_count == 5
    end

    test "custom color applied" do
      html = render_component(&H.render_custom_color/1, %{})
      assert html =~ "oklch(0.65 0.22 30)"
    end

    test "animate true adds phia-chart-animate class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phia-chart-animate"
    end

    test "animate false removes animation" do
      html = render_component(&H.render_no_animate/1, %{})
      refute html =~ "phia-bar-grow"
    end

    test "animate true adds bar-grow animation" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phia-bar-grow"
    end

    test "custom class applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-histogram"
    end
  end
end
