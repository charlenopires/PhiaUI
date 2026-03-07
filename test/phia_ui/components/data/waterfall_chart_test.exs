defmodule PhiaUi.Components.WaterfallChartTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.WaterfallChart

    def render_default(assigns) do
      ~H"""
      <.waterfall_chart data={[
        %{label: "Revenue", value: 500},
        %{label: "COGS",    value: -200},
        %{label: "OpEx",    value: -100}
      ]} />
      """
    end

    def render_with_total(assigns) do
      ~H"""
      <.waterfall_chart data={[
        %{label: "Revenue", value: 500},
        %{label: "COGS",    value: -200},
        %{label: "Net",     value: 0, total: true}
      ]} />
      """
    end

    def render_all_positive(assigns) do
      ~H"""
      <.waterfall_chart data={[%{label: "A", value: 100}, %{label: "B", value: 50}]} />
      """
    end

    def render_all_negative(assigns) do
      ~H"""
      <.waterfall_chart data={[%{label: "Loss1", value: -80}, %{label: "Loss2", value: -40}]} />
      """
    end

    def render_no_animate(assigns) do
      ~H"""
      <.waterfall_chart data={[%{label: "A", value: 100}, %{label: "B", value: -50}]} animate={false} />
      """
    end

    def render_custom_colors(assigns) do
      ~H"""
      <.waterfall_chart
        data={[%{label: "A", value: 100}, %{label: "B", value: -50}]}
        positive_color="oklch(0.60 0.20 240)"
        negative_color="oklch(0.60 0.25 0)"
      />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.waterfall_chart data={[%{label: "X", value: 100}]} class="my-waterfall" />
      """
    end
  end

  describe "waterfall_chart/1" do
    test "renders root div" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<div"
    end

    test "renders SVG" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<svg"
    end

    test "renders rect elements" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<rect"
    end

    test "renders x-axis labels" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Revenue"
      assert html =~ "COGS"
    end

    test "total bar renders" do
      html = render_component(&H.render_with_total/1, %{})
      assert html =~ "Net"
    end

    test "all-positive data renders without crash" do
      html = render_component(&H.render_all_positive/1, %{})
      assert html =~ "<rect"
    end

    test "all-negative data renders without crash" do
      html = render_component(&H.render_all_negative/1, %{})
      assert html =~ "<rect"
    end

    test "positive color applied to positive bars" do
      html = render_component(&H.render_custom_colors/1, %{})
      assert html =~ "oklch(0.60 0.20 240)"
    end

    test "negative color applied to negative bars" do
      html = render_component(&H.render_custom_colors/1, %{})
      assert html =~ "oklch(0.60 0.25 0)"
    end

    test "animate true adds phia-chart-animate class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phia-chart-animate"
    end

    test "animate false removes animation" do
      html = render_component(&H.render_no_animate/1, %{})
      refute html =~ "phia-bar-grow"
    end

    test "custom class applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-waterfall"
    end

    test "zero line rendered" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "text-muted-foreground"
    end
  end
end
