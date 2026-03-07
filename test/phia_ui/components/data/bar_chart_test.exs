defmodule PhiaUi.Components.BarChartTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.BarChart

    def render_default(assigns) do
      ~H"""
      <.bar_chart data={[%{label: "Jan", value: 100}, %{label: "Feb", value: 80}, %{label: "Mar", value: 120}]} />
      """
    end

    def render_empty(assigns) do
      ~H"""
      <.bar_chart data={[]} />
      """
    end

    def render_single(assigns) do
      ~H"""
      <.bar_chart data={[%{label: "Only", value: 50}]} />
      """
    end

    def render_all_zero(assigns) do
      ~H"""
      <.bar_chart data={[%{label: "A", value: 0}, %{label: "B", value: 0}]} />
      """
    end

    def render_multi_series(assigns) do
      ~H"""
      <.bar_chart series={[
        %{name: "Revenue", data: [%{label: "Q1", value: 200}, %{label: "Q2", value: 280}]},
        %{name: "Cost",    data: [%{label: "Q1", value: 100}, %{label: "Q2", value: 130}]}
      ]} />
      """
    end

    def render_stacked(assigns) do
      ~H"""
      <.bar_chart
        data={[%{label: "Jan", value: 100}, %{label: "Feb", value: 80}]}
        variant={:stacked}
      />
      """
    end

    def render_horizontal(assigns) do
      ~H"""
      <.bar_chart
        data={[%{label: "A", value: 60}, %{label: "B", value: 40}]}
        variant={:horizontal}
      />
      """
    end

    def render_no_animate(assigns) do
      ~H"""
      <.bar_chart data={[%{label: "X", value: 10}]} animate={false} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.bar_chart data={[%{label: "X", value: 10}]} class="my-bar-chart" />
      """
    end

    def render_custom_colors(assigns) do
      ~H"""
      <.bar_chart
        data={[%{label: "X", value: 10}]}
        colors={["oklch(0.60 0.20 240)"]}
      />
      """
    end
  end

  describe "bar_chart/1" do
    test "renders root div" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<div"
    end

    test "renders SVG element" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<svg"
    end

    test "renders rect elements for bars" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<rect"
    end

    test "renders x-axis labels" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Jan"
      assert html =~ "Feb"
      assert html =~ "Mar"
    end

    test "renders viewBox attribute" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "viewBox"
    end

    test "empty data renders SVG without crash" do
      html = render_component(&H.render_empty/1, %{})
      assert html =~ "<svg"
    end

    test "single data point renders without crash" do
      html = render_component(&H.render_single/1, %{})
      assert html =~ "<svg"
    end

    test "all-zero values render without crash" do
      html = render_component(&H.render_all_zero/1, %{})
      assert html =~ "<svg"
    end

    test "multi-series renders multiple series colors" do
      html = render_component(&H.render_multi_series/1, %{})
      assert html =~ "<rect"
    end

    test "stacked variant renders" do
      html = render_component(&H.render_stacked/1, %{})
      assert html =~ "<rect"
    end

    test "horizontal variant renders" do
      html = render_component(&H.render_horizontal/1, %{})
      assert html =~ "<rect"
    end

    test "animate true adds phia-chart-animate class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phia-chart-animate"
    end

    test "animate false removes phia-chart-animate class" do
      html = render_component(&H.render_no_animate/1, %{})
      refute html =~ "phia-chart-animate"
    end

    test "animate false removes bar animation style" do
      html = render_component(&H.render_no_animate/1, %{})
      refute html =~ "phia-bar-grow"
    end

    test "animate true adds bar grow animation" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phia-bar-grow"
    end

    test "custom class applied to root element" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-bar-chart"
    end

    test "custom color applied to bar fill" do
      html = render_component(&H.render_custom_colors/1, %{})
      assert html =~ "oklch(0.60 0.20 240)"
    end
  end
end
