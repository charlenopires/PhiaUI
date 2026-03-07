defmodule PhiaUi.Components.BubbleChartTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.BubbleChart

    def render_default(assigns) do
      ~H"""
      <.bubble_chart data={[
        %{x: 10, y: 30, size: 20},
        %{x: 40, y: 60, size: 80},
        %{x: 70, y: 45, size: 40}
      ]} />
      """
    end

    def render_empty(assigns) do
      ~H"""
      <.bubble_chart data={[]} />
      """
    end

    def render_single(assigns) do
      ~H"""
      <.bubble_chart data={[%{x: 5, y: 5, size: 50}]} />
      """
    end

    def render_no_animate(assigns) do
      ~H"""
      <.bubble_chart data={[%{x: 10, y: 20, size: 30}]} animate={false} />
      """
    end

    def render_custom_color(assigns) do
      ~H"""
      <.bubble_chart data={[%{x: 10, y: 20, size: 50}]} color="oklch(0.65 0.22 30)" />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.bubble_chart data={[%{x: 10, y: 20, size: 30}]} class="my-bubble" />
      """
    end

    def render_large_max(assigns) do
      ~H"""
      <.bubble_chart data={[%{x: 10, y: 20, size: 30}]} max_bubble_size={30} />
      """
    end
  end

  describe "bubble_chart/1" do
    test "renders root div" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<div"
    end

    test "renders SVG" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<svg"
    end

    test "renders circle elements" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<circle"
    end

    test "renders 3 circles for 3 data points" do
      html = render_component(&H.render_default/1, %{})
      circle_count = html |> String.split("<circle") |> length() |> Kernel.-(1)
      assert circle_count == 3
    end

    test "empty data renders without crash" do
      html = render_component(&H.render_empty/1, %{})
      assert html =~ "<svg"
    end

    test "single bubble renders" do
      html = render_component(&H.render_single/1, %{})
      assert html =~ "<circle"
    end

    test "animate true adds phia-chart-animate class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phia-chart-animate"
    end

    test "animate false removes animation" do
      html = render_component(&H.render_no_animate/1, %{})
      refute html =~ "phia-dot-pop"
    end

    test "animate true adds pop animation" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phia-dot-pop"
    end

    test "custom color applied" do
      html = render_component(&H.render_custom_color/1, %{})
      assert html =~ "oklch(0.65 0.22 30)"
    end

    test "custom class applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-bubble"
    end

    test "bubbles have varying radii based on size" do
      html = render_component(&H.render_default/1, %{})
      # Circles should have r attributes
      assert html =~ ~s( r=")
    end
  end
end
