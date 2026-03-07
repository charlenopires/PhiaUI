defmodule PhiaUi.Components.LineChartTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.LineChart

    def render_default(assigns) do
      ~H"""
      <.line_chart data={[%{label: "Jan", value: 100}, %{label: "Feb", value: 150}, %{label: "Mar", value: 120}]} />
      """
    end

    def render_empty(assigns) do
      ~H"""
      <.line_chart data={[]} />
      """
    end

    def render_single(assigns) do
      ~H"""
      <.line_chart data={[%{label: "A", value: 50}]} />
      """
    end

    def render_multi_series(assigns) do
      ~H"""
      <.line_chart series={[
        %{name: "A", data: [%{label: "Q1", value: 100}, %{label: "Q2", value: 200}]},
        %{name: "B", data: [%{label: "Q1", value: 80},  %{label: "Q2", value: 160}]}
      ]} />
      """
    end

    def render_with_dots(assigns) do
      ~H"""
      <.line_chart
        data={[%{label: "Jan", value: 100}, %{label: "Feb", value: 150}]}
        show_dots={true}
      />
      """
    end

    def render_no_animate(assigns) do
      ~H"""
      <.line_chart data={[%{label: "X", value: 10}, %{label: "Y", value: 20}]} animate={false} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.line_chart data={[%{label: "X", value: 10}]} class="my-line-chart" />
      """
    end

    def render_custom_colors(assigns) do
      ~H"""
      <.line_chart
        data={[%{label: "A", value: 10}, %{label: "B", value: 20}]}
        colors={["oklch(0.65 0.22 30)"]}
      />
      """
    end
  end

  describe "line_chart/1" do
    test "renders root div" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<div"
    end

    test "renders SVG element" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<svg"
    end

    test "renders polyline for data points" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<polyline"
    end

    test "polyline has points attribute" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(points=")
    end

    test "renders x-axis labels" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Jan"
    end

    test "empty data renders SVG without crash" do
      html = render_component(&H.render_empty/1, %{})
      assert html =~ "<svg"
    end

    test "single point renders without crash" do
      html = render_component(&H.render_single/1, %{})
      assert html =~ "<svg"
    end

    test "multi-series renders multiple polylines" do
      html = render_component(&H.render_multi_series/1, %{})
      polyline_count = html |> String.split("<polyline") |> length() |> Kernel.-(1)
      assert polyline_count >= 2
    end

    test "show_dots renders circle elements" do
      html = render_component(&H.render_with_dots/1, %{})
      assert html =~ "<circle"
    end

    test "animate true adds phia-chart-animate class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phia-chart-animate"
    end

    test "animate false removes animation styles" do
      html = render_component(&H.render_no_animate/1, %{})
      refute html =~ "phia-line-draw"
    end

    test "animate true adds line-draw animation" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phia-line-draw"
    end

    test "custom class applied to root" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-line-chart"
    end

    test "custom color applied to polyline stroke" do
      html = render_component(&H.render_custom_colors/1, %{})
      assert html =~ "oklch(0.65 0.22 30)"
    end

    test "stroke-dasharray set for animation" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "stroke-dasharray"
    end
  end
end
