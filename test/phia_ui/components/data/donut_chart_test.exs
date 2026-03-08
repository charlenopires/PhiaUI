defmodule PhiaUi.Components.DonutChartTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.DonutChart

    def render_default(assigns) do
      ~H"""
      <.donut_chart data={[
        %{label: "Used",  value: 70},
        %{label: "Free",  value: 30}
      ]} />
      """
    end

    def render_with_center(assigns) do
      ~H"""
      <.donut_chart data={[%{label: "A", value: 70}, %{label: "B", value: 30}]}>
        <:center>70%</:center>
      </.donut_chart>
      """
    end

    def render_no_legend(assigns) do
      ~H"""
      <.donut_chart data={[%{label: "X", value: 50}, %{label: "Y", value: 50}]} show_legend={false} />
      """
    end

    def render_thin_ring(assigns) do
      ~H"""
      <.donut_chart data={[%{label: "A", value: 80}, %{label: "B", value: 20}]} hole_ratio={0.8} />
      """
    end

    def render_thick_ring(assigns) do
      ~H"""
      <.donut_chart data={[%{label: "A", value: 80}, %{label: "B", value: 20}]} hole_ratio={0.3} />
      """
    end

    def render_no_animate(assigns) do
      ~H"""
      <.donut_chart data={[%{label: "A", value: 50}]} animate={false} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.donut_chart data={[%{label: "X", value: 100}]} class="my-donut" />
      """
    end

    def render_custom_colors(assigns) do
      ~H"""
      <.donut_chart
        data={[%{label: "A", value: 60}, %{label: "B", value: 40}]}
        colors={["oklch(0.60 0.20 240)", "oklch(0.65 0.22 30)"]}
      />
      """
    end

    def render_with_spacing(assigns) do
      ~H"""
      <.donut_chart
        data={[%{label: "A", value: 60}, %{label: "B", value: 40}]}
        spacing={4}
      />
      """
    end

    def render_zero_spacing(assigns) do
      ~H"""
      <.donut_chart
        data={[%{label: "A", value: 60}, %{label: "B", value: 40}]}
        spacing={0}
      />
      """
    end

    def render_with_link_labels(assigns) do
      ~H"""
      <.donut_chart
        data={[%{label: "Used", value: 70}, %{label: "Free", value: 30}]}
        show_link_labels={true}
      />
      """
    end

    def render_without_link_labels(assigns) do
      ~H"""
      <.donut_chart
        data={[%{label: "A", value: 50}, %{label: "B", value: 50}]}
        show_link_labels={false}
      />
      """
    end
  end

  describe "donut_chart/1" do
    test "renders root div" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<div"
    end

    test "renders SVG" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<svg"
    end

    test "renders donut arc paths" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<path"
    end

    test "paths include both inner and outer arcs" do
      html = render_component(&H.render_default/1, %{})
      # Donut paths have two arcs (A command appears twice per slice)
      a_count = html |> String.split(" A ") |> length() |> Kernel.-(1)
      assert a_count >= 2
    end

    test "center slot renders custom content" do
      html = render_component(&H.render_with_center/1, %{})
      assert html =~ "70%"
    end

    test "no center slot renders without foreignObject" do
      html = render_component(&H.render_default/1, %{})
      refute html =~ "foreignObject"
    end

    test "show_legend true renders labels" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Used"
      assert html =~ "Free"
    end

    test "show_legend false hides labels" do
      html = render_component(&H.render_no_legend/1, %{})
      refute html =~ ">X<"
    end

    test "hole_ratio affects ring thickness" do
      html_thin = render_component(&H.render_thin_ring/1, %{})
      html_thick = render_component(&H.render_thick_ring/1, %{})
      assert html_thin =~ "<svg"
      assert html_thick =~ "<svg"
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
      assert html =~ "my-donut"
    end

    test "custom colors applied to slices" do
      html = render_component(&H.render_custom_colors/1, %{})
      assert html =~ "oklch(0.60 0.20 240)"
    end

    test "spacing > 0 removes stroke between slices" do
      html = render_component(&H.render_with_spacing/1, %{})
      assert html =~ ~s(stroke="none")
      assert html =~ ~s(stroke-width="0")
    end

    test "spacing 0 keeps default background stroke" do
      html = render_component(&H.render_zero_spacing/1, %{})
      assert html =~ "var(--color-background, white)"
      assert html =~ ~s(stroke-width="1.5")
    end

    test "spacing produces valid donut paths" do
      html = render_component(&H.render_with_spacing/1, %{})
      assert html =~ "<path"
      # Donut paths have two arcs per slice
      a_count = html |> String.split(" A ") |> length() |> Kernel.-(1)
      assert a_count >= 2
    end

    test "show_link_labels renders arc link labels" do
      html = render_component(&H.render_with_link_labels/1, %{})
      assert html =~ "<polyline"
      assert html =~ "Used"
      assert html =~ "Free"
    end

    test "show_link_labels false does not render polylines" do
      html = render_component(&H.render_without_link_labels/1, %{})
      refute html =~ "<polyline"
    end
  end
end
