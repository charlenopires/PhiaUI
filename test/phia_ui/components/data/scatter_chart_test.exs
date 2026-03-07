defmodule PhiaUi.Components.ScatterChartTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ScatterChart

    def render_default(assigns) do
      ~H"""
      <.scatter_chart data={[
        %{x: 10, y: 30},
        %{x: 25, y: 80},
        %{x: 60, y: 50}
      ]} />
      """
    end

    def render_with_labels(assigns) do
      ~H"""
      <.scatter_chart data={[%{x: 10, y: 30, label: "A"}, %{x: 50, y: 60, label: "B"}]} />
      """
    end

    def render_empty(assigns) do
      ~H"""
      <.scatter_chart data={[]} />
      """
    end

    def render_single(assigns) do
      ~H"""
      <.scatter_chart data={[%{x: 5, y: 5}]} />
      """
    end

    def render_no_grid(assigns) do
      ~H"""
      <.scatter_chart data={[%{x: 10, y: 20}]} show_grid={false} />
      """
    end

    def render_no_animate(assigns) do
      ~H"""
      <.scatter_chart data={[%{x: 10, y: 20}, %{x: 30, y: 40}]} animate={false} />
      """
    end

    def render_custom_color(assigns) do
      ~H"""
      <.scatter_chart data={[%{x: 10, y: 20}]} color="oklch(0.65 0.22 30)" />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.scatter_chart data={[%{x: 10, y: 20}]} class="my-scatter" />
      """
    end

    def render_large_dot(assigns) do
      ~H"""
      <.scatter_chart data={[%{x: 10, y: 20}]} dot_size={8} />
      """
    end
  end

  describe "scatter_chart/1" do
    test "renders root div" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<div"
    end

    test "renders SVG" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<svg"
    end

    test "renders circle elements for data points" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<circle"
    end

    test "renders 3 circles for 3 data points" do
      html = render_component(&H.render_default/1, %{})
      circle_count = html |> String.split("<circle") |> length() |> Kernel.-(1)
      assert circle_count == 3
    end

    test "empty data renders SVG without crash" do
      html = render_component(&H.render_empty/1, %{})
      assert html =~ "<svg"
    end

    test "empty data renders no circles" do
      html = render_component(&H.render_empty/1, %{})
      refute html =~ "<circle"
    end

    test "single data point renders one circle" do
      html = render_component(&H.render_single/1, %{})
      circle_count = html |> String.split("<circle") |> length() |> Kernel.-(1)
      assert circle_count == 1
    end

    test "show_grid false removes grid lines" do
      html = render_component(&H.render_no_grid/1, %{})
      refute html =~ "text-border"
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

    test "custom color applied to circles" do
      html = render_component(&H.render_custom_color/1, %{})
      assert html =~ "oklch(0.65 0.22 30)"
    end

    test "custom class applied to root" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-scatter"
    end

    test "custom dot_size applied to circles" do
      html = render_component(&H.render_large_dot/1, %{})
      assert html =~ ~s(r="8")
    end
  end
end
