defmodule PhiaUi.Components.Data.ResponsiveChartTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Data.ResponsiveChart

    def render_default(assigns) do
      ~H"""
      <.responsive_chart>
        <div>Chart content</div>
      </.responsive_chart>
      """
    end

    def render_custom(assigns) do
      ~H"""
      <.responsive_chart aspect_ratio="16/9" min_height="300px" class="my-chart">
        <div>Wide chart</div>
      </.responsive_chart>
      """
    end

    def render_square(assigns) do
      ~H"""
      <.responsive_chart aspect_ratio="1/1" min_height="100px">
        <div>Square</div>
      </.responsive_chart>
      """
    end
  end

  describe "responsive_chart/1" do
    test "renders wrapper div with inner content" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Chart content"
      assert html =~ "<div"
    end

    test "applies default aspect-ratio style" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "aspect-ratio: 4/3"
      assert html =~ "min-height: 200px"
    end

    test "applies custom aspect-ratio and min-height" do
      html = render_component(&H.render_custom/1, %{})
      assert html =~ "aspect-ratio: 16/9"
      assert html =~ "min-height: 300px"
    end

    test "applies custom class" do
      html = render_component(&H.render_custom/1, %{})
      assert html =~ "my-chart"
    end

    test "includes w-full class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "w-full"
    end

    test "works with square aspect ratio" do
      html = render_component(&H.render_square/1, %{})
      assert html =~ "aspect-ratio: 1/1"
      assert html =~ "Square"
    end
  end
end
