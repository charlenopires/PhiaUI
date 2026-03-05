defmodule PhiaUi.Components.SparklineCardTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.SparklineCard

    def render_basic(assigns) do
      ~H"""
      <.sparkline_card title="Revenue" value="$1,240" data={[10, 20, 15, 30, 25, 40]} />
      """
    end

    def render_with_delta_up(assigns) do
      ~H"""
      <.sparkline_card title="Sessions" value="8,200" data={[5, 10, 8, 12, 15]} delta="+12.4%" trend={:up} />
      """
    end

    def render_with_delta_down(assigns) do
      ~H"""
      <.sparkline_card title="Bounce Rate" value="45%" data={[50, 48, 46, 45]} delta="-5.2%" trend={:down} />
      """
    end

    def render_neutral(assigns) do
      ~H"""
      <.sparkline_card title="Uptime" value="99.9%" data={[100, 100, 99, 100]} trend={:neutral} />
      """
    end

    def render_custom_size(assigns) do
      ~H"""
      <.sparkline_card title="Sales" value="200" data={[1, 2, 3]} width={200} height={60} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.sparkline_card title="T" value="V" data={[1, 2]} class="my-sparkline-class" />
      """
    end

    def render_flat_line(assigns) do
      ~H"""
      <.sparkline_card title="Flat" value="0" data={[5, 5, 5, 5]} />
      """
    end

    def render_single_point(assigns) do
      ~H"""
      <.sparkline_card title="One" value="1" data={[42]} />
      """
    end

    def render_empty_data(assigns) do
      ~H"""
      <.sparkline_card title="Empty" value="0" data={[]} />
      """
    end
  end

  describe "sparkline_card/1" do
    test "renders a root element" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<div"
    end

    test "renders title text" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "Revenue"
    end

    test "renders value text" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "$1,240"
    end

    test "renders an SVG element" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<svg"
    end

    test "renders a polyline inside SVG" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<polyline"
    end

    test "polyline has points attribute" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(points=")
    end

    test "renders delta text when provided" do
      html = render_component(&H.render_with_delta_up/1, %{})
      assert html =~ "+12.4%"
    end

    test "no delta rendered when not provided" do
      html = render_component(&H.render_basic/1, %{})
      refute html =~ "%"
    end

    test "trend :up uses green color on polyline" do
      html = render_component(&H.render_with_delta_up/1, %{})
      assert html =~ "green"
    end

    test "trend :down uses red color on polyline" do
      html = render_component(&H.render_with_delta_down/1, %{})
      assert html =~ "red"
    end

    test "trend :neutral uses muted color" do
      html = render_component(&H.render_neutral/1, %{})
      assert html =~ "muted"
    end

    test "custom width applied to SVG" do
      html = render_component(&H.render_custom_size/1, %{})
      assert html =~ ~s(width="200")
    end

    test "custom height applied to SVG" do
      html = render_component(&H.render_custom_size/1, %{})
      assert html =~ ~s(height="60")
    end

    test "custom class applied to root element" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-sparkline-class"
    end

    test "flat line data renders without error" do
      html = render_component(&H.render_flat_line/1, %{})
      assert html =~ "<polyline"
    end

    test "single data point renders without error" do
      html = render_component(&H.render_single_point/1, %{})
      assert html =~ "<svg"
    end

    test "empty data renders SVG without polyline points crash" do
      html = render_component(&H.render_empty_data/1, %{})
      assert html =~ "<svg"
    end

    test "SVG has viewBox attribute" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "viewBox"
    end

    test "SVG fill is none (line chart, not area)" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(fill="none")
    end
  end
end
