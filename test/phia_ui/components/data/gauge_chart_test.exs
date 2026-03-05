defmodule PhiaUi.Components.GaugeChartTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.GaugeChart

    def render_default(assigns) do
      ~H"""
      <.gauge_chart value={78} />
      """
    end

    def render_zero(assigns) do
      ~H"""
      <.gauge_chart value={0} />
      """
    end

    def render_full(assigns) do
      ~H"""
      <.gauge_chart value={100} />
      """
    end

    def render_with_label(assigns) do
      ~H"""
      <.gauge_chart value={75} label="Mental Health Score" />
      """
    end

    def render_custom_max(assigns) do
      ~H"""
      <.gauge_chart value={150} max={200} label="Cholesterol" />
      """
    end

    def render_blue(assigns) do
      ~H"""
      <.gauge_chart value={50} color={:blue} />
      """
    end

    def render_green(assigns) do
      ~H"""
      <.gauge_chart value={50} color={:green} />
      """
    end

    def render_orange(assigns) do
      ~H"""
      <.gauge_chart value={50} color={:orange} />
      """
    end

    def render_red(assigns) do
      ~H"""
      <.gauge_chart value={50} color={:red} />
      """
    end

    def render_purple(assigns) do
      ~H"""
      <.gauge_chart value={50} color={:purple} />
      """
    end

    def render_sm(assigns) do
      ~H"""
      <.gauge_chart value={60} size={:sm} />
      """
    end

    def render_lg(assigns) do
      ~H"""
      <.gauge_chart value={60} size={:lg} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.gauge_chart value={50} class="my-gauge-class" />
      """
    end

    def render_with_value_display(assigns) do
      ~H"""
      <.gauge_chart value={42} max={100} />
      """
    end
  end

  describe "gauge_chart/1" do
    test "renders a root element" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<div"
    end

    test "renders an SVG element" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<svg"
    end

    test "renders two arc paths (track + filled)" do
      html = render_component(&H.render_default/1, %{})
      count = html |> String.split("<path") |> length() |> Kernel.-(1)
      assert count >= 2
    end

    test "renders the numeric value in the center" do
      html = render_component(&H.render_with_value_display/1, %{})
      assert html =~ "42"
    end

    test "renders label when provided" do
      html = render_component(&H.render_with_label/1, %{})
      assert html =~ "Mental Health Score"
    end

    test "no label rendered when not provided" do
      html = render_component(&H.render_default/1, %{})
      refute html =~ "Mental Health Score"
    end

    test "custom max shows value out of max" do
      html = render_component(&H.render_custom_max/1, %{})
      assert html =~ "150"
    end

    test "color :blue applies blue stroke" do
      html = render_component(&H.render_blue/1, %{})
      assert html =~ "blue"
    end

    test "color :green applies green stroke" do
      html = render_component(&H.render_green/1, %{})
      assert html =~ "green"
    end

    test "color :orange applies orange stroke" do
      html = render_component(&H.render_orange/1, %{})
      assert html =~ "orange"
    end

    test "color :red applies red stroke" do
      html = render_component(&H.render_red/1, %{})
      assert html =~ "red"
    end

    test "color :purple applies purple stroke" do
      html = render_component(&H.render_purple/1, %{})
      assert html =~ "purple"
    end

    test "size :sm produces smaller dimensions" do
      html_sm = render_component(&H.render_sm/1, %{})
      html_default = render_component(&H.render_default/1, %{})
      # sm SVG dimensions should be smaller than default
      assert html_sm =~ ~s(class="h-24 w-24")
      assert html_default =~ ~s(class="h-32 w-32")
    end

    test "size :lg produces larger dimensions" do
      html = render_component(&H.render_lg/1, %{})
      assert html =~ ~s(class="h-40 w-40")
    end

    test "custom class applied to root element" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-gauge-class"
    end

    test "value 0 renders without error" do
      html = render_component(&H.render_zero/1, %{})
      assert html =~ "<svg"
    end

    test "value at max renders full arc" do
      html = render_component(&H.render_full/1, %{})
      assert html =~ "<svg"
      assert html =~ "100"
    end

    test "arc uses stroke-dasharray and stroke-dashoffset for animation" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "stroke-dasharray"
      assert html =~ "stroke-dashoffset"
    end

    test "track arc has muted color" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "muted"
    end

    test "SVG viewBox is present" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "viewBox"
    end
  end
end
