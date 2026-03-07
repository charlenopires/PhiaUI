defmodule PhiaUi.Components.RadialBarChartTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.RadialBarChart

    def render_default(assigns) do
      ~H"""
      <.radial_bar_chart data={[
        %{label: "CPU",    value: 72, max: 100},
        %{label: "Memory", value: 45, max: 100},
        %{label: "Disk",   value: 88, max: 100}
      ]} />
      """
    end

    def render_single(assigns) do
      ~H"""
      <.radial_bar_chart data={[%{label: "Load", value: 60, max: 100}]} />
      """
    end

    def render_with_colors(assigns) do
      ~H"""
      <.radial_bar_chart data={[
        %{label: "A", value: 50, max: 100, color: "oklch(0.60 0.20 240)"},
        %{label: "B", value: 75, max: 100, color: "oklch(0.65 0.22 30)"}
      ]} />
      """
    end

    def render_no_animate(assigns) do
      ~H"""
      <.radial_bar_chart data={[%{label: "X", value: 50, max: 100}]} animate={false} />
      """
    end

    def render_sm(assigns) do
      ~H"""
      <.radial_bar_chart data={[%{label: "X", value: 50, max: 100}]} size={:sm} />
      """
    end

    def render_lg(assigns) do
      ~H"""
      <.radial_bar_chart data={[%{label: "X", value: 50, max: 100}]} size={:lg} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.radial_bar_chart data={[%{label: "X", value: 50, max: 100}]} class="my-radial" />
      """
    end

    def render_zero_value(assigns) do
      ~H"""
      <.radial_bar_chart data={[%{label: "Empty", value: 0, max: 100}]} />
      """
    end

    def render_max_value(assigns) do
      ~H"""
      <.radial_bar_chart data={[%{label: "Full", value: 100, max: 100}]} />
      """
    end
  end

  describe "radial_bar_chart/1" do
    test "renders root div" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<div"
    end

    test "renders SVG" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<svg"
    end

    test "renders circle elements for rings" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<circle"
    end

    test "renders track (muted) and value rings" do
      html = render_component(&H.render_default/1, %{})
      # 3 items = 3 track + 3 value circles = 6 total
      circle_count = html |> String.split("<circle") |> length() |> Kernel.-(1)
      assert circle_count >= 6
    end

    test "single ring renders" do
      html = render_component(&H.render_single/1, %{})
      assert html =~ "<circle"
    end

    test "renders labels for each ring" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "CPU"
      assert html =~ "Memory"
      assert html =~ "Disk"
    end

    test "custom colors in data applied" do
      html = render_component(&H.render_with_colors/1, %{})
      assert html =~ "oklch(0.60 0.20 240)"
    end

    test "animate true adds phia-chart-animate class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phia-chart-animate"
    end

    test "animate false removes animation class" do
      html = render_component(&H.render_no_animate/1, %{})
      refute html =~ "phia-chart-animate"
    end

    test "size :sm applies h-36 class" do
      html = render_component(&H.render_sm/1, %{})
      assert html =~ "h-36"
    end

    test "size :lg applies h-64 class" do
      html = render_component(&H.render_lg/1, %{})
      assert html =~ "h-64"
    end

    test "custom class applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-radial"
    end

    test "zero value renders without crash" do
      html = render_component(&H.render_zero_value/1, %{})
      assert html =~ "<circle"
    end

    test "max value renders without crash" do
      html = render_component(&H.render_max_value/1, %{})
      assert html =~ "<circle"
    end

    test "uses stroke-dasharray for arc animation" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "stroke-dasharray"
    end
  end
end
