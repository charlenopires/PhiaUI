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

    def render_curve_linear(assigns) do
      ~H"""
      <.line_chart
        data={[%{label: "Jan", value: 100}, %{label: "Feb", value: 150}, %{label: "Mar", value: 120}]}
        curve={:linear}
      />
      """
    end

    def render_curve_smooth(assigns) do
      ~H"""
      <.line_chart
        data={[%{label: "Jan", value: 100}, %{label: "Feb", value: 150}, %{label: "Mar", value: 120}]}
        curve={:smooth}
      />
      """
    end

    def render_curve_monotone(assigns) do
      ~H"""
      <.line_chart
        data={[%{label: "Jan", value: 100}, %{label: "Feb", value: 150}, %{label: "Mar", value: 120}]}
        curve={:monotone}
      />
      """
    end

    def render_curve_step_before(assigns) do
      ~H"""
      <.line_chart
        data={[%{label: "Jan", value: 100}, %{label: "Feb", value: 150}, %{label: "Mar", value: 120}]}
        curve={:step_before}
      />
      """
    end

    def render_curve_step_after(assigns) do
      ~H"""
      <.line_chart
        data={[%{label: "Jan", value: 100}, %{label: "Feb", value: 150}, %{label: "Mar", value: 120}]}
        curve={:step_after}
      />
      """
    end

    def render_curve_step_middle(assigns) do
      ~H"""
      <.line_chart
        data={[%{label: "Jan", value: 100}, %{label: "Feb", value: 150}, %{label: "Mar", value: 120}]}
        curve={:step_middle}
      />
      """
    end

    def render_curve_smooth_with_dots(assigns) do
      ~H"""
      <.line_chart
        data={[%{label: "Jan", value: 100}, %{label: "Feb", value: 150}, %{label: "Mar", value: 120}]}
        curve={:smooth}
        show_dots={true}
      />
      """
    end

    def render_curve_smooth_no_animate(assigns) do
      ~H"""
      <.line_chart
        data={[%{label: "Jan", value: 100}, %{label: "Feb", value: 150}, %{label: "Mar", value: 120}]}
        curve={:smooth}
        animate={false}
      />
      """
    end

    def render_curve_smooth_multi_series(assigns) do
      ~H"""
      <.line_chart
        series={[
          %{name: "A", data: [%{label: "Q1", value: 100}, %{label: "Q2", value: 200}]},
          %{name: "B", data: [%{label: "Q1", value: 80},  %{label: "Q2", value: 160}]}
        ]}
        curve={:monotone}
      />
      """
    end

    def render_curve_smooth_empty(assigns) do
      ~H"""
      <.line_chart data={[]} curve={:smooth} />
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

  describe "line_chart/1 curve attribute" do
    test "default curve renders polyline (backward compatible)" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<polyline"
      refute html =~ ~s(<path)
    end

    test "explicit linear curve renders polyline" do
      html = render_component(&H.render_curve_linear/1, %{})
      assert html =~ "<polyline"
      refute html =~ ~s( d=")
    end

    test "smooth curve renders path element" do
      html = render_component(&H.render_curve_smooth/1, %{})
      assert html =~ "<path"
      assert html =~ ~s( d=")
      refute html =~ "<polyline"
    end

    test "smooth curve path contains cubic bezier commands" do
      html = render_component(&H.render_curve_smooth/1, %{})
      assert html =~ "C "
    end

    test "monotone curve renders path element" do
      html = render_component(&H.render_curve_monotone/1, %{})
      assert html =~ "<path"
      assert html =~ ~s( d=")
      refute html =~ "<polyline"
    end

    test "monotone curve path contains cubic bezier commands" do
      html = render_component(&H.render_curve_monotone/1, %{})
      assert html =~ "C "
    end

    test "step_before curve renders path element" do
      html = render_component(&H.render_curve_step_before/1, %{})
      assert html =~ "<path"
      assert html =~ ~s( d=")
      refute html =~ "<polyline"
    end

    test "step_before curve path contains line commands" do
      html = render_component(&H.render_curve_step_before/1, %{})
      assert html =~ "L "
    end

    test "step_after curve renders path element" do
      html = render_component(&H.render_curve_step_after/1, %{})
      assert html =~ "<path"
      assert html =~ ~s( d=")
    end

    test "step_middle curve renders path element" do
      html = render_component(&H.render_curve_step_middle/1, %{})
      assert html =~ "<path"
      assert html =~ ~s( d=")
    end

    test "curved line has stroke-dasharray for animation" do
      html = render_component(&H.render_curve_smooth/1, %{})
      assert html =~ "stroke-dasharray"
      assert html =~ "phia-line-draw"
    end

    test "curved line without animate skips animation styles" do
      html = render_component(&H.render_curve_smooth_no_animate/1, %{})
      refute html =~ "phia-line-draw"
      refute html =~ "stroke-dasharray"
    end

    test "curved line preserves fill none and stroke attributes" do
      html = render_component(&H.render_curve_smooth/1, %{})
      assert html =~ ~s(fill="none")
      assert html =~ ~s(stroke-linecap="round")
      assert html =~ ~s(stroke-linejoin="round")
    end

    test "dots still render with curved lines" do
      html = render_component(&H.render_curve_smooth_with_dots/1, %{})
      assert html =~ "<circle"
      assert html =~ "<path"
    end

    test "multi-series with curve renders multiple path elements" do
      html = render_component(&H.render_curve_smooth_multi_series/1, %{})
      path_count = html |> String.split("<path") |> length() |> Kernel.-(1)
      assert path_count >= 2
    end

    test "empty data with curve renders without crash" do
      html = render_component(&H.render_curve_smooth_empty/1, %{})
      assert html =~ "<svg"
    end

    test "all curve path elements have d attribute starting with M" do
      html = render_component(&H.render_curve_smooth/1, %{})
      assert html =~ ~s(d="M )
    end
  end
end
