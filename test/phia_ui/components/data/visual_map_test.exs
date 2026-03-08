defmodule PhiaUi.Components.Data.VisualMapTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Data.VisualMap

    def render_default(assigns) do
      ~H"""
      <.visual_map />
      """
    end

    def render_custom_range(assigns) do
      ~H"""
      <.visual_map min={0} max={500} />
      """
    end

    def render_custom_colors(assigns) do
      ~H"""
      <.visual_map
        colors={["oklch(0.95 0.05 120)", "oklch(0.70 0.15 60)", "oklch(0.50 0.25 0)"]}
      />
      """
    end

    def render_vertical(assigns) do
      ~H"""
      <.visual_map orientation={:vertical} width={20} height={200} />
      """
    end

    def render_no_labels(assigns) do
      ~H"""
      <.visual_map show_labels={false} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.visual_map class="my-visual-map" />
      """
    end

    def render_custom_dimensions(assigns) do
      ~H"""
      <.visual_map width={300} height={30} />
      """
    end
  end

  describe "visual_map/1" do
    test "renders root div" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<div"
    end

    test "renders SVG" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<svg"
    end

    test "renders gradient rect" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<rect"
      assert html =~ "url(#"
    end

    test "renders linearGradient with stops" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "linearGradient"
      assert html =~ "<stop"
    end

    test "renders min and max labels by default" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "0"
      assert html =~ "100"
    end

    test "renders custom range labels" do
      html = render_component(&H.render_custom_range/1, %{})
      assert html =~ "0"
      assert html =~ "500"
    end

    test "renders multiple color stops" do
      html = render_component(&H.render_custom_colors/1, %{})
      stop_count = html |> String.split("<stop") |> length() |> Kernel.-(1)
      assert stop_count == 3
    end

    test "renders vertical orientation" do
      html = render_component(&H.render_vertical/1, %{})
      assert html =~ "flex-col"
    end

    test "hides labels when show_labels is false" do
      html = render_component(&H.render_no_labels/1, %{})
      refute html =~ "text-muted-foreground"
    end

    test "renders custom class" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-visual-map"
    end

    test "renders custom dimensions" do
      html = render_component(&H.render_custom_dimensions/1, %{})
      assert html =~ ~s(width="300")
      assert html =~ ~s(height="30")
    end

    test "renders aria label" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Color scale"
    end

    test "renders role img" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(role="img")
    end

    test "default width is 200 for horizontal" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(width="200")
    end
  end
end
