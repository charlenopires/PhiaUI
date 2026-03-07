defmodule PhiaUi.Components.SlopeChartTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.SlopeChart

    def render_default(assigns) do
      ~H"""
      <.slope_chart data={[
        %{label: "Product A", from: 80, to: 95},
        %{label: "Product B", from: 60, to: 45},
        %{label: "Product C", from: 75, to: 70}
      ]} />
      """
    end

    def render_single(assigns) do
      ~H"""
      <.slope_chart data={[%{label: "Item", from: 50, to: 80}]} />
      """
    end

    def render_empty(assigns) do
      ~H"""
      <.slope_chart data={[]} />
      """
    end

    def render_with_labels(assigns) do
      ~H"""
      <.slope_chart
        data={[%{label: "X", from: 40, to: 60}]}
        left_label="Before"
        right_label="After"
      />
      """
    end

    def render_no_animate(assigns) do
      ~H"""
      <.slope_chart data={[%{label: "A", from: 50, to: 70}]} animate={false} />
      """
    end

    def render_custom_colors(assigns) do
      ~H"""
      <.slope_chart
        data={[%{label: "A", from: 50, to: 70}]}
        colors={["oklch(0.60 0.20 240)"]}
      />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.slope_chart data={[%{label: "A", from: 50, to: 60}]} class="my-slope" />
      """
    end
  end

  describe "slope_chart/1" do
    test "renders root div" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<div"
    end

    test "renders SVG" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<svg"
    end

    test "renders line elements for slopes" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<line"
    end

    test "renders dot circles at endpoints" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<circle"
    end

    test "renders item labels" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Product A"
      assert html =~ "Product B"
    end

    test "renders column headers" do
      html = render_component(&H.render_with_labels/1, %{})
      assert html =~ "Before"
      assert html =~ "After"
    end

    test "default column headers present" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Before"
      assert html =~ "After"
    end

    test "single item renders" do
      html = render_component(&H.render_single/1, %{})
      assert html =~ "<line"
    end

    test "empty data renders SVG without crash" do
      html = render_component(&H.render_empty/1, %{})
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

    test "animate true adds line-draw animation" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phia-line-draw"
    end

    test "custom color applied" do
      html = render_component(&H.render_custom_colors/1, %{})
      assert html =~ "oklch(0.60 0.20 240)"
    end

    test "custom class applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-slope"
    end
  end
end
