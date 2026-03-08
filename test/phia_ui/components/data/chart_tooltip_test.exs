defmodule PhiaUi.Components.Data.ChartTooltipTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Data.ChartTooltip

    def render_default(assigns) do
      ~H"""
      <svg viewBox="0 0 400 300">
        <.chart_tooltip x={200} y={150}>
          <span>Revenue: 350</span>
        </.chart_tooltip>
      </svg>
      """
    end

    def render_hidden(assigns) do
      ~H"""
      <svg viewBox="0 0 400 300">
        <.chart_tooltip x={100} y={100} visible={false}>
          <span>Hidden</span>
        </.chart_tooltip>
      </svg>
      """
    end

    def render_custom_size(assigns) do
      ~H"""
      <svg viewBox="0 0 400 300">
        <.chart_tooltip x={200} y={150} width={200} height={60}>
          <span>Wide tooltip</span>
        </.chart_tooltip>
      </svg>
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <svg viewBox="0 0 400 300">
        <.chart_tooltip x={200} y={150} class="custom-tip">
          <span>Styled</span>
        </.chart_tooltip>
      </svg>
      """
    end
  end

  describe "chart_tooltip/1" do
    test "renders foreignObject with content" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "foreignObject"
      assert html =~ "Revenue: 350"
    end

    test "positions foreignObject centered above point" do
      html = render_component(&H.render_default/1, %{})
      # x=200, width=120 → fo_x = 200-60 = 140
      assert html =~ ~s(x="140)
    end

    test "hides when visible is false" do
      html = render_component(&H.render_hidden/1, %{})
      refute html =~ "foreignObject"
      refute html =~ "Hidden"
    end

    test "applies custom width and height" do
      html = render_component(&H.render_custom_size/1, %{})
      assert html =~ ~s(width="200")
      assert html =~ ~s(height="60")
    end

    test "applies default theme classes" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "bg-popover"
      assert html =~ "text-popover-foreground"
    end

    test "applies custom class" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "custom-tip"
    end
  end
end
