defmodule PhiaUi.Components.Data.ChartToolboxTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Data.ChartToolbox

    def render_default(assigns) do
      ~H"""
      <.chart_toolbox chart_id="chart-1" />
      """
    end

    def render_download_only(assigns) do
      ~H"""
      <.chart_toolbox chart_id="chart-2" tools={[:download]} />
      """
    end

    def render_reset_only(assigns) do
      ~H"""
      <.chart_toolbox chart_id="chart-3" tools={[:reset]} />
      """
    end

    def render_with_series(assigns) do
      ~H"""
      <.chart_toolbox
        chart_id="chart-4"
        tools={[:toggle_series]}
        all_series={["Revenue", "Cost"]}
        visible_series={["Revenue"]}
        on_toggle_series="toggle-series"
      />
      """
    end

    def render_top_left(assigns) do
      ~H"""
      <.chart_toolbox chart_id="chart-5" position={:top_left} />
      """
    end

    def render_bottom_right(assigns) do
      ~H"""
      <.chart_toolbox chart_id="chart-6" position={:bottom_right} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.chart_toolbox chart_id="chart-7" class="my-toolbox" />
      """
    end

    def render_with_reset_event(assigns) do
      ~H"""
      <.chart_toolbox chart_id="chart-8" tools={[:reset]} on_reset_zoom="reset-zoom" />
      """
    end

    def render_empty_tools(assigns) do
      ~H"""
      <.chart_toolbox chart_id="chart-9" tools={[]} />
      """
    end

    def render_all_visible(assigns) do
      ~H"""
      <.chart_toolbox
        chart_id="chart-10"
        tools={[:toggle_series]}
        all_series={["A", "B"]}
        visible_series={["A", "B"]}
      />
      """
    end
  end

  describe "chart_toolbox/1" do
    test "renders toolbar role" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(role="toolbar")
    end

    test "renders aria label" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Chart tools"
    end

    test "renders download button by default" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Download chart"
    end

    test "renders reset button by default" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Reset zoom"
    end

    test "download-only hides reset" do
      html = render_component(&H.render_download_only/1, %{})
      assert html =~ "Download chart"
      refute html =~ "Reset zoom"
    end

    test "reset-only hides download" do
      html = render_component(&H.render_reset_only/1, %{})
      refute html =~ "Download chart"
      assert html =~ "Reset zoom"
    end

    test "renders series toggle buttons" do
      html = render_component(&H.render_with_series/1, %{})
      assert html =~ "Revenue"
      assert html =~ "Cost"
    end

    test "visible series has active styling" do
      html = render_component(&H.render_with_series/1, %{})
      assert html =~ ~s(aria-pressed="true")
    end

    test "hidden series has inactive styling" do
      html = render_component(&H.render_with_series/1, %{})
      assert html =~ "line-through"
    end

    test "series toggle sends event" do
      html = render_component(&H.render_with_series/1, %{})
      assert html =~ "toggle-series"
    end

    test "top_left position" do
      html = render_component(&H.render_top_left/1, %{})
      assert html =~ "top-0"
      assert html =~ "left-0"
    end

    test "bottom_right position" do
      html = render_component(&H.render_bottom_right/1, %{})
      assert html =~ "bottom-0"
      assert html =~ "right-0"
    end

    test "custom class applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-toolbox"
    end

    test "custom reset event" do
      html = render_component(&H.render_with_reset_event/1, %{})
      assert html =~ "reset-zoom"
    end

    test "empty tools renders toolbar without buttons" do
      html = render_component(&H.render_empty_tools/1, %{})
      assert html =~ ~s(role="toolbar")
      refute html =~ "Download chart"
      refute html =~ "Reset zoom"
    end

    test "all series visible have active state" do
      html = render_component(&H.render_all_visible/1, %{})
      refute html =~ "line-through"
    end

    test "download dispatches to chart id" do
      html = render_component(&H.render_download_only/1, %{})
      assert html =~ "chart-2"
    end
  end
end
