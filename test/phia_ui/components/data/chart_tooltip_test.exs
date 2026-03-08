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

    def render_frame(assigns) do
      ~H"""
      <.chart_tooltip_frame>
        <.chart_tooltip_header label="January 2024" />
        <.chart_tooltip_row name="Revenue" value="$1,234" color="oklch(0.60 0.20 240)" />
        <.chart_tooltip_row name="Cost" value="$890" color="oklch(0.65 0.22 30)" />
      </.chart_tooltip_frame>
      """
    end

    def render_frame_custom_class(assigns) do
      ~H"""
      <.chart_tooltip_frame class="w-64">
        <.chart_tooltip_row name="Sales" value="100" color="red" />
      </.chart_tooltip_frame>
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

  describe "chart_tooltip_frame/1" do
    test "renders container with border and shadow" do
      html = render_component(&H.render_frame/1, %{})
      assert html =~ "rounded-lg"
      assert html =~ "shadow-md"
      assert html =~ "border"
    end

    test "renders popover theme classes" do
      html = render_component(&H.render_frame/1, %{})
      assert html =~ "bg-popover"
      assert html =~ "text-popover-foreground"
    end

    test "applies custom class" do
      html = render_component(&H.render_frame_custom_class/1, %{})
      assert html =~ "w-64"
    end
  end

  describe "chart_tooltip_header/1" do
    test "renders header label" do
      html = render_component(&H.render_frame/1, %{})
      assert html =~ "January 2024"
    end

    test "renders with bottom border" do
      html = render_component(&H.render_frame/1, %{})
      assert html =~ "border-b"
    end

    test "renders with font-medium" do
      html = render_component(&H.render_frame/1, %{})
      assert html =~ "font-medium"
    end
  end

  describe "chart_tooltip_row/1" do
    test "renders series name and value" do
      html = render_component(&H.render_frame/1, %{})
      assert html =~ "Revenue"
      assert html =~ "$1,234"
      assert html =~ "Cost"
      assert html =~ "$890"
    end

    test "renders color swatch with inline style" do
      html = render_component(&H.render_frame/1, %{})
      assert html =~ "oklch(0.60 0.20 240)"
      assert html =~ "oklch(0.65 0.22 30)"
    end

    test "renders swatch as rounded circle" do
      html = render_component(&H.render_frame/1, %{})
      assert html =~ "rounded-full"
      assert html =~ "size-3"
    end

    test "renders value with tabular-nums" do
      html = render_component(&H.render_frame/1, %{})
      assert html =~ "tabular-nums"
    end
  end
end
