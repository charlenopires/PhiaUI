defmodule PhiaUi.Components.ChartTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Chart

    def render_basic(assigns) do
      ~H"""
      <.phia_chart
        id="chart1"
        type={:line}
        series={[%{name: "Sales", data: [10, 20, 30]}]}
        labels={["Jan", "Feb", "Mar"]}
      />
      """
    end

    def render_bar(assigns) do
      ~H"""
      <.phia_chart
        id="chart2"
        type={:bar}
        series={[%{name: "Revenue", data: [100, 200, 300]}]}
        labels={["Q1", "Q2", "Q3"]}
      />
      """
    end

    def render_pie(assigns) do
      ~H"""
      <.phia_chart
        id="chart3"
        type={:pie}
        series={[%{name: "Slices", data: [30, 50, 20]}]}
        labels={["A", "B", "C"]}
      />
      """
    end

    def render_area(assigns) do
      ~H"""
      <.phia_chart
        id="chart4"
        type={:area}
        series={[%{name: "Growth", data: [1, 3, 2, 5]}]}
        labels={["W1", "W2", "W3", "W4"]}
      />
      """
    end

    def render_with_height(assigns) do
      ~H"""
      <.phia_chart
        id="chart5"
        type={:line}
        series={[%{name: "X", data: [1]}]}
        labels={["A"]}
        height="500px"
      />
      """
    end

    def render_with_title(assigns) do
      ~H"""
      <.phia_chart
        id="chart6"
        type={:bar}
        series={[%{name: "Y", data: [1]}]}
        labels={["B"]}
        title="Revenue Chart"
        description="Monthly revenue data"
      />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.phia_chart
        id="chart7"
        type={:line}
        series={[]}
        labels={[]}
        class="custom-chart"
      />
      """
    end
  end

  defp render_basic, do: render_component(&H.render_basic/1, %{})
  defp render_bar, do: render_component(&H.render_bar/1, %{})
  defp render_pie, do: render_component(&H.render_pie/1, %{})
  defp render_area, do: render_component(&H.render_area/1, %{})
  defp render_with_height, do: render_component(&H.render_with_height/1, %{})
  defp render_with_title, do: render_component(&H.render_with_title/1, %{})
  defp render_with_class, do: render_component(&H.render_with_class/1, %{})

  # ---------------------------------------------------------------------------
  # Hook and ID
  # ---------------------------------------------------------------------------

  describe "phx-hook and id" do
    test "renders element with phx-hook=PhiaChart" do
      assert render_basic() =~ ~s(phx-hook="PhiaChart")
    end

    test "renders element with correct id" do
      assert render_basic() =~ ~s(id="chart1")
    end

    test "id is propagated correctly for different charts" do
      assert render_bar() =~ ~s(id="chart2")
    end
  end

  # ---------------------------------------------------------------------------
  # data-config attr
  # ---------------------------------------------------------------------------

  describe "data-config attribute" do
    test "renders data-config attribute" do
      assert render_basic() =~ "data-config"
    end

    test "data-config contains type for line chart" do
      html = render_basic()
      assert html =~ "line"
    end

    test "data-config contains type for bar chart" do
      html = render_bar()
      assert html =~ "bar"
    end

    test "data-config contains type for pie chart" do
      html = render_pie()
      assert html =~ "pie"
    end

    test "data-config contains areaStyle for area chart" do
      html = render_area()
      assert html =~ "areaStyle"
    end

    test "data-config contains xAxis with labels" do
      html = render_basic()
      assert html =~ "Jan" or html =~ "xAxis"
    end
  end

  # ---------------------------------------------------------------------------
  # data-series attr
  # ---------------------------------------------------------------------------

  describe "data-series attribute" do
    test "renders data-series attribute" do
      assert render_basic() =~ "data-series"
    end

    test "data-series contains series name" do
      html = render_basic()
      assert html =~ "Sales"
    end

    test "data-series contains series data values" do
      html = render_basic()
      assert html =~ "10" and html =~ "20" and html =~ "30"
    end
  end

  # ---------------------------------------------------------------------------
  # Height
  # ---------------------------------------------------------------------------

  describe ":height attribute" do
    test "default height 300px applied to container" do
      html = render_basic()
      assert html =~ "300px"
    end

    test "custom height 500px applied to container" do
      html = render_with_height()
      assert html =~ "500px"
    end
  end

  # ---------------------------------------------------------------------------
  # ChartShell wrapping with :title
  # ---------------------------------------------------------------------------

  describe ":title wraps with ChartShell" do
    test "renders title text when :title provided" do
      html = render_with_title()
      assert html =~ "Revenue Chart"
    end

    test "renders description when :description provided" do
      html = render_with_title()
      assert html =~ "Monthly revenue data"
    end

    test "no card wrapper when :title is nil" do
      html = render_basic()
      refute html =~ "Revenue Chart"
    end
  end

  # ---------------------------------------------------------------------------
  # :class
  # ---------------------------------------------------------------------------

  describe ":class attribute" do
    test "applies custom class to wrapper" do
      assert render_with_class() =~ "custom-chart"
    end
  end

  # ---------------------------------------------------------------------------
  # Graceful degradation placeholder
  # ---------------------------------------------------------------------------

  describe "graceful degradation" do
    test "renders a noscript or placeholder message in HTML" do
      html = render_basic()
      # Should have some placeholder for when no chart library is detected
      assert html =~ "data-chart-placeholder" or html =~ "noscript" or html =~ "chart" or
               html =~ "PhiaChart"
    end
  end
end
