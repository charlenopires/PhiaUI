defmodule PhiaUi.Components.AreaChartTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.AreaChart

    def render_default(assigns) do
      ~H"""
      <.area_chart data={[%{label: "Jan", value: 80}, %{label: "Feb", value: 140}, %{label: "Mar", value: 110}]} />
      """
    end

    def render_empty(assigns) do
      ~H"""
      <.area_chart data={[]} />
      """
    end

    def render_stacked(assigns) do
      ~H"""
      <.area_chart
        series={[
          %{name: "A", data: [%{label: "Q1", value: 100}, %{label: "Q2", value: 150}]},
          %{name: "B", data: [%{label: "Q1", value: 50},  %{label: "Q2", value: 80}]}
        ]}
        variant={:stacked}
      />
      """
    end

    def render_no_animate(assigns) do
      ~H"""
      <.area_chart data={[%{label: "A", value: 10}, %{label: "B", value: 20}]} animate={false} />
      """
    end

    def render_custom_opacity(assigns) do
      ~H"""
      <.area_chart data={[%{label: "A", value: 10}, %{label: "B", value: 20}]} fill_opacity={0.5} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.area_chart data={[%{label: "X", value: 10}]} class="my-area-chart" />
      """
    end
  end

  describe "area_chart/1" do
    test "renders root div" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<div"
    end

    test "renders SVG" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<svg"
    end

    test "renders area path fill" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<path"
    end

    test "renders polyline (line stroke)" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<polyline"
    end

    test "area path has fill attribute" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(fill=")
    end

    test "fill-opacity applied to area" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "fill-opacity"
    end

    test "custom fill opacity value used" do
      html = render_component(&H.render_custom_opacity/1, %{})
      assert html =~ "0.5"
    end

    test "empty data renders SVG without crash" do
      html = render_component(&H.render_empty/1, %{})
      assert html =~ "<svg"
    end

    test "stacked variant renders" do
      html = render_component(&H.render_stacked/1, %{})
      assert html =~ "<svg"
    end

    test "animate true adds phia-chart-animate class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phia-chart-animate"
    end

    test "animate false removes animation" do
      html = render_component(&H.render_no_animate/1, %{})
      refute html =~ "phia-line-draw"
    end

    test "animate true includes line-draw animation" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phia-line-draw"
    end

    test "custom class applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-area-chart"
    end
  end
end
