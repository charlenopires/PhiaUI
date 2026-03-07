defmodule PhiaUi.Components.TreemapChartTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.TreemapChart

    def render_default(assigns) do
      ~H"""
      <.treemap_chart data={[
        %{label: "React",   value: 450},
        %{label: "Vue",     value: 280},
        %{label: "Angular", value: 210},
        %{label: "Svelte",  value: 120}
      ]} />
      """
    end

    def render_two_items(assigns) do
      ~H"""
      <.treemap_chart data={[%{label: "A", value: 60}, %{label: "B", value: 40}]} />
      """
    end

    def render_single(assigns) do
      ~H"""
      <.treemap_chart data={[%{label: "Only", value: 100}]} />
      """
    end

    def render_with_colors(assigns) do
      ~H"""
      <.treemap_chart
        data={[%{label: "X", value: 70}, %{label: "Y", value: 30}]}
        colors={["oklch(0.60 0.20 240)", "oklch(0.65 0.22 30)"]}
      />
      """
    end

    def render_with_item_colors(assigns) do
      ~H"""
      <.treemap_chart data={[
        %{label: "A", value: 60, color: "oklch(0.60 0.20 240)"},
        %{label: "B", value: 40, color: "oklch(0.65 0.22 30)"}
      ]} />
      """
    end

    def render_no_animate(assigns) do
      ~H"""
      <.treemap_chart data={[%{label: "X", value: 50}]} animate={false} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.treemap_chart data={[%{label: "X", value: 100}]} class="my-treemap" />
      """
    end
  end

  describe "treemap_chart/1" do
    test "renders root div" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<div"
    end

    test "renders SVG" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<svg"
    end

    test "renders rect elements for tiles" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<rect"
    end

    test "renders 4 tiles for 4-item data" do
      html = render_component(&H.render_default/1, %{})
      rect_count = html |> String.split("<rect") |> length() |> Kernel.-(1)
      assert rect_count == 4
    end

    test "renders tile labels" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "React"
      assert html =~ "Vue"
    end

    test "two-item renders two tiles" do
      html = render_component(&H.render_two_items/1, %{})
      rect_count = html |> String.split("<rect") |> length() |> Kernel.-(1)
      assert rect_count == 2
    end

    test "single item renders one tile" do
      html = render_component(&H.render_single/1, %{})
      assert html =~ "<rect"
    end

    test "custom palette colors applied" do
      html = render_component(&H.render_with_colors/1, %{})
      assert html =~ "oklch(0.60 0.20 240)"
    end

    test "item-level colors applied" do
      html = render_component(&H.render_with_item_colors/1, %{})
      assert html =~ "oklch(0.60 0.20 240)"
    end

    test "animate true adds phia-chart-animate class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phia-chart-animate"
    end

    test "animate false removes animation" do
      html = render_component(&H.render_no_animate/1, %{})
      refute html =~ "phia-fade-in"
    end

    test "animate true adds fade-in animation" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phia-fade-in"
    end

    test "custom class applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-treemap"
    end

    test "tiles have stroke for separation" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "stroke"
    end
  end
end
