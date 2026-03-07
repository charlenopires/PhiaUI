defmodule PhiaUi.Components.BulletChartTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.BulletChart

    def render_default(assigns) do
      ~H"""
      <.bullet_chart value={72} target={85} />
      """
    end

    def render_with_ranges(assigns) do
      ~H"""
      <.bullet_chart
        value={72}
        target={85}
        ranges={[
          %{to: 50, color: "oklch(0.80 0.05 0)"},
          %{to: 75, color: "oklch(0.88 0.03 0)"},
          %{to: 100, color: "oklch(0.94 0.02 0)"}
        ]}
        label="Revenue"
      />
      """
    end

    def render_with_label(assigns) do
      ~H"""
      <.bullet_chart value={50} target={80} label="Performance" />
      """
    end

    def render_zero_value(assigns) do
      ~H"""
      <.bullet_chart value={0} target={100} />
      """
    end

    def render_value_at_target(assigns) do
      ~H"""
      <.bullet_chart value={85} target={85} />
      """
    end

    def render_no_animate(assigns) do
      ~H"""
      <.bullet_chart value={60} target={90} animate={false} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.bullet_chart value={50} target={80} class="my-bullet" />
      """
    end

    def render_custom_max(assigns) do
      ~H"""
      <.bullet_chart value={50} target={80} max={200} />
      """
    end
  end

  describe "bullet_chart/1" do
    test "renders root div" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<div"
    end

    test "renders SVG" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<svg"
    end

    test "renders rect for value bar" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<rect"
    end

    test "renders target line marker" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<line"
    end

    test "renders range background rects" do
      html = render_component(&H.render_with_ranges/1, %{})
      rect_count = html |> String.split("<rect") |> length() |> Kernel.-(1)
      # 3 range rects + 1 value bar
      assert rect_count >= 4
    end

    test "renders label text" do
      html = render_component(&H.render_with_label/1, %{})
      assert html =~ "Performance"
    end

    test "no label when not provided" do
      html = render_component(&H.render_default/1, %{})
      refute html =~ ">Revenue<"
    end

    test "zero value renders without crash" do
      html = render_component(&H.render_zero_value/1, %{})
      assert html =~ "<rect"
    end

    test "value at target renders without crash" do
      html = render_component(&H.render_value_at_target/1, %{})
      assert html =~ "<rect"
    end

    test "animate true adds phia-chart-animate class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phia-chart-animate"
    end

    test "animate false removes animation" do
      html = render_component(&H.render_no_animate/1, %{})
      refute html =~ "phia-bar-grow-x"
    end

    test "animate true adds grow-x animation" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "phia-bar-grow-x"
    end

    test "custom class applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-bullet"
    end

    test "custom max overrides default" do
      html = render_component(&H.render_custom_max/1, %{})
      assert html =~ "<svg"
    end
  end
end
