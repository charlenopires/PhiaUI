defmodule PhiaUi.Components.RadarChartTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.RadarChart

    def render_default(assigns) do
      ~H"""
      <.radar_chart data={[
        %{axis: "Speed", value: 80},
        %{axis: "Power", value: 65},
        %{axis: "Endurance", value: 90},
        %{axis: "Agility", value: 75}
      ]} />
      """
    end

    def render_multi_series(assigns) do
      ~H"""
      <.radar_chart series={[
        %{name: "2023", data: [%{axis: "A", value: 80}, %{axis: "B", value: 60}, %{axis: "C", value: 70}]},
        %{name: "2024", data: [%{axis: "A", value: 90}, %{axis: "B", value: 75}, %{axis: "C", value: 85}]}
      ]} />
      """
    end

    def render_empty(assigns) do
      ~H"""
      <.radar_chart data={[]} />
      """
    end

    def render_no_grid(assigns) do
      ~H"""
      <.radar_chart data={[%{axis: "X", value: 50}]} show_grid={false} />
      """
    end

    def render_no_animate(assigns) do
      ~H"""
      <.radar_chart data={[%{axis: "A", value: 50}, %{axis: "B", value: 60}]} animate={false} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.radar_chart data={[%{axis: "A", value: 50}]} class="my-radar" />
      """
    end

    def render_custom_colors(assigns) do
      ~H"""
      <.radar_chart
        data={[%{axis: "A", value: 50}, %{axis: "B", value: 70}]}
        colors={["oklch(0.60 0.20 240)"]}
      />
      """
    end
  end

  describe "radar_chart/1" do
    test "renders root div" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<div"
    end

    test "renders SVG" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<svg"
    end

    test "renders polygon for data series" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<polygon"
    end

    test "renders axis labels" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Speed"
      assert html =~ "Power"
    end

    test "multi-series renders multiple polygons" do
      html = render_component(&H.render_multi_series/1, %{})
      poly_count = html |> String.split("<polygon") |> length() |> Kernel.-(1)
      assert poly_count >= 2
    end

    test "empty data renders SVG without crash" do
      html = render_component(&H.render_empty/1, %{})
      assert html =~ "<svg"
    end

    test "show_grid true renders grid polygons" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "text-border"
    end

    test "show_grid false hides grid" do
      html = render_component(&H.render_no_grid/1, %{})
      refute html =~ "text-border"
    end

    test "animate true adds phia-chart-animate class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phia-chart-animate"
    end

    test "animate false removes animation class" do
      html = render_component(&H.render_no_animate/1, %{})
      refute html =~ "phia-chart-animate"
    end

    test "custom class applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-radar"
    end

    test "custom color applied to polygon" do
      html = render_component(&H.render_custom_colors/1, %{})
      assert html =~ "oklch(0.60 0.20 240)"
    end

    test "viewBox present" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "viewBox"
    end
  end
end
