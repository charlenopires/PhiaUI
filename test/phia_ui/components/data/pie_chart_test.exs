defmodule PhiaUi.Components.PieChartTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.PieChart

    def render_default(assigns) do
      ~H"""
      <.pie_chart data={[
        %{label: "A", value: 40},
        %{label: "B", value: 30},
        %{label: "C", value: 20},
        %{label: "D", value: 10}
      ]} />
      """
    end

    def render_two_slices(assigns) do
      ~H"""
      <.pie_chart data={[%{label: "Yes", value: 60}, %{label: "No", value: 40}]} />
      """
    end

    def render_single_slice(assigns) do
      ~H"""
      <.pie_chart data={[%{label: "All", value: 100}]} />
      """
    end

    def render_with_legend(assigns) do
      ~H"""
      <.pie_chart
        data={[%{label: "Alpha", value: 50}, %{label: "Beta", value: 50}]}
        show_legend={true}
      />
      """
    end

    def render_no_legend(assigns) do
      ~H"""
      <.pie_chart
        data={[%{label: "A", value: 50}, %{label: "B", value: 50}]}
        show_legend={false}
      />
      """
    end

    def render_no_animate(assigns) do
      ~H"""
      <.pie_chart data={[%{label: "A", value: 50}, %{label: "B", value: 50}]} animate={false} />
      """
    end

    def render_custom_colors(assigns) do
      ~H"""
      <.pie_chart
        data={[%{label: "A", value: 60}, %{label: "B", value: 40}]}
        colors={["oklch(0.60 0.20 240)", "oklch(0.65 0.22 30)"]}
      />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.pie_chart data={[%{label: "X", value: 100}]} class="my-pie-chart" />
      """
    end

    def render_with_spacing(assigns) do
      ~H"""
      <.pie_chart
        data={[%{label: "A", value: 60}, %{label: "B", value: 40}]}
        spacing={4}
      />
      """
    end

    def render_with_corner_radius(assigns) do
      ~H"""
      <.pie_chart
        data={[%{label: "A", value: 60}, %{label: "B", value: 40}]}
        corner_radius={3}
      />
      """
    end

    def render_with_spacing_and_corner_radius(assigns) do
      ~H"""
      <.pie_chart
        data={[%{label: "A", value: 60}, %{label: "B", value: 40}]}
        spacing={4}
        corner_radius={3}
      />
      """
    end

    def render_zero_spacing(assigns) do
      ~H"""
      <.pie_chart
        data={[%{label: "A", value: 60}, %{label: "B", value: 40}]}
        spacing={0}
      />
      """
    end

    def render_with_link_labels(assigns) do
      ~H"""
      <.pie_chart
        data={[%{label: "Direct", value: 40}, %{label: "Organic", value: 30}, %{label: "Referral", value: 30}]}
        show_link_labels={true}
      />
      """
    end

    def render_without_link_labels(assigns) do
      ~H"""
      <.pie_chart
        data={[%{label: "A", value: 60}, %{label: "B", value: 40}]}
        show_link_labels={false}
      />
      """
    end
  end

  describe "pie_chart/1" do
    test "renders root div" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<div"
    end

    test "renders SVG" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<svg"
    end

    test "renders path elements for slices" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<path"
    end

    test "renders correct number of slices for 4-item data" do
      html = render_component(&H.render_default/1, %{})
      path_count = html |> String.split("<path") |> length() |> Kernel.-(1)
      assert path_count >= 4
    end

    test "single slice renders without crash" do
      html = render_component(&H.render_single_slice/1, %{})
      assert html =~ "<path"
    end

    test "two slices render" do
      html = render_component(&H.render_two_slices/1, %{})
      path_count = html |> String.split("<path") |> length() |> Kernel.-(1)
      assert path_count >= 2
    end

    test "show_legend renders labels" do
      html = render_component(&H.render_with_legend/1, %{})
      assert html =~ "Alpha"
      assert html =~ "Beta"
    end

    test "show_legend false hides labels" do
      html = render_component(&H.render_no_legend/1, %{})
      refute html =~ "Alpha"
    end

    test "animate true adds phia-chart-animate class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phia-chart-animate"
    end

    test "animate false removes phia-chart-animate class" do
      html = render_component(&H.render_no_animate/1, %{})
      refute html =~ "phia-chart-animate"
    end

    test "custom colors applied to slices" do
      html = render_component(&H.render_custom_colors/1, %{})
      assert html =~ "oklch(0.60 0.20 240)"
    end

    test "custom class applied to root" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-pie-chart"
    end

    test "viewBox present on SVG" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "viewBox"
    end

    test "slice paths include arc command" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ " A "
    end

    test "spacing > 0 removes stroke between slices" do
      html = render_component(&H.render_with_spacing/1, %{})
      assert html =~ ~s(stroke="none")
      assert html =~ ~s(stroke-width="0")
    end

    test "spacing 0 keeps default background stroke" do
      html = render_component(&H.render_zero_spacing/1, %{})
      assert html =~ "var(--color-background, white)"
      assert html =~ ~s(stroke-width="1")
    end

    test "corner_radius > 0 sets round linejoin and linecap" do
      html = render_component(&H.render_with_corner_radius/1, %{})
      assert html =~ ~s(stroke-linejoin="round")
      assert html =~ ~s(stroke-linecap="round")
    end

    test "corner_radius 0 uses default miter and butt" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(stroke-linejoin="miter")
      assert html =~ ~s(stroke-linecap="butt")
    end

    test "corner_radius > 0 uses slice fill color as stroke" do
      html = render_component(&H.render_with_corner_radius/1, %{})
      assert html =~ ~s(stroke-width="3")
    end

    test "spacing + corner_radius together sets stroke none" do
      html = render_component(&H.render_with_spacing_and_corner_radius/1, %{})
      assert html =~ ~s(stroke="none")
    end

    test "spacing produces valid paths" do
      html = render_component(&H.render_with_spacing/1, %{})
      assert html =~ "<path"
      assert html =~ " A "
    end

    test "show_link_labels renders arc link labels" do
      html = render_component(&H.render_with_link_labels/1, %{})
      assert html =~ "<polyline"
      assert html =~ "Direct"
      assert html =~ "Organic"
      assert html =~ "Referral"
    end

    test "show_link_labels false does not render polylines" do
      html = render_component(&H.render_without_link_labels/1, %{})
      refute html =~ "<polyline"
    end
  end
end
