defmodule PhiaUi.Components.ChartShellTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ChartShell

    attr(:title, :string, default: "Revenue Over Time")
    attr(:description, :string, default: nil)
    attr(:period, :string, default: nil)
    attr(:min_height, :string, default: "300px")
    attr(:class, :string, default: nil)

    def render_chart_shell(assigns) do
      ~H"""
      <.chart_shell
        title={@title}
        description={@description}
        period={@period}
        min_height={@min_height}
        class={@class}
      >
        <div id="chart-content">Chart goes here</div>
      </.chart_shell>
      """
    end

    def render_with_actions(assigns) do
      ~H"""
      <.chart_shell title="Sales">
        <:actions>
          <button>Download</button>
          <button>Filter</button>
        </:actions>
        <div>Chart</div>
      </.chart_shell>
      """
    end

    def render_minimal(assigns) do
      ~H"""
      <.chart_shell title="Simple Chart">
        <div>Content</div>
      </.chart_shell>
      """
    end
  end

  defp render_chart(attrs \\ %{}) do
    render_component(&H.render_chart_shell/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # :title attr (required)
  # ---------------------------------------------------------------------------

  describe "chart_shell/1 :title attr" do
    test "renders the title" do
      html = render_chart(%{title: "Monthly Revenue"})
      assert html =~ "Monthly Revenue"
    end

    test "title is rendered in a heading element" do
      html = render_chart(%{title: "Sales Trend"})
      assert html =~ "<h3"
      assert html =~ "Sales Trend"
    end
  end

  # ---------------------------------------------------------------------------
  # :description attr (optional)
  # ---------------------------------------------------------------------------

  describe "chart_shell/1 :description attr" do
    test "renders description when provided" do
      html = render_chart(%{description: "Monthly breakdown by region"})
      assert html =~ "Monthly breakdown by region"
    end

    test "description has muted-foreground styling" do
      html = render_chart(%{description: "Hint text"})
      assert html =~ "text-muted-foreground"
    end

    test "description element is omitted when nil" do
      html = render_component(&H.render_minimal/1, %{})
      # minimal render has no description — muted-foreground only comes from description
      refute html =~ "Monthly breakdown"
    end
  end

  # ---------------------------------------------------------------------------
  # :period attr (optional)
  # ---------------------------------------------------------------------------

  describe "chart_shell/1 :period attr" do
    test "renders period when provided" do
      html = render_chart(%{period: "Last 30 days"})
      assert html =~ "Last 30 days"
    end

    test "period is omitted when nil" do
      html = render_component(&H.render_minimal/1, %{})
      refute html =~ "Last 30 days"
    end
  end

  # ---------------------------------------------------------------------------
  # :actions slot
  # ---------------------------------------------------------------------------

  describe "chart_shell/1 :actions slot" do
    test "renders actions slot content when provided" do
      html = render_component(&H.render_with_actions/1, %{})
      assert html =~ "Download"
      assert html =~ "Filter"
    end

    test "actions slot is omitted when not provided" do
      html = render_component(&H.render_minimal/1, %{})
      refute html =~ "Download"
    end
  end

  # ---------------------------------------------------------------------------
  # inner_block slot
  # ---------------------------------------------------------------------------

  describe "chart_shell/1 inner_block slot" do
    test "renders chart content" do
      html = render_chart()
      assert html =~ "Chart goes here"
    end

    test "chart content is inside a div with min-height style" do
      html = render_chart()
      assert html =~ "min-height"
      assert html =~ "Chart goes here"
    end
  end

  # ---------------------------------------------------------------------------
  # Uses Card sub-components internally
  # ---------------------------------------------------------------------------

  describe "chart_shell/1 uses Card sub-components" do
    test "renders rounded-lg border (card outer wrapper)" do
      html = render_chart()
      assert html =~ "rounded-lg"
      assert html =~ "border"
    end

    test "renders card header area (flex flex-col space-y-1.5 p-6)" do
      html = render_chart()
      assert html =~ "space-y-1.5"
    end

    test "renders card content area (p-6 pt-0)" do
      html = render_chart()
      assert html =~ "pt-0"
    end

    test "title uses card_title styling (font-semibold)" do
      html = render_chart(%{title: "KPI Chart"})
      assert html =~ "font-semibold"
    end
  end

  # ---------------------------------------------------------------------------
  # :min_height attr
  # ---------------------------------------------------------------------------

  describe "chart_shell/1 :min_height attr" do
    test "defaults to 300px" do
      html = render_chart()
      assert html =~ "300px"
    end

    test "accepts custom min_height" do
      html = render_chart(%{min_height: "500px"})
      assert html =~ "500px"
    end

    test "min-height is applied as inline style" do
      html = render_chart(%{min_height: "400px"})
      assert html =~ ~s(min-height)
      assert html =~ "400px"
    end
  end

  # ---------------------------------------------------------------------------
  # :class attr
  # ---------------------------------------------------------------------------

  describe "chart_shell/1 :class attr" do
    test "accepts custom class" do
      html = render_chart(%{class: "my-chart-widget"})
      assert html =~ "my-chart-widget"
    end
  end
end
