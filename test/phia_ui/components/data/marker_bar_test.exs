defmodule PhiaUi.Components.Data.MarkerBarTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Data.MarkerBar

    def render_default(assigns) do
      ~H"""
      <.marker_bar value={62} />
      """
    end

    def render_custom_color(assigns) do
      ~H"""
      <.marker_bar value={80} color="oklch(0.60 0.20 240)" />
      """
    end

    def render_animated(assigns) do
      ~H"""
      <.marker_bar value={50} show_animation />
      """
    end

    def render_with_tooltip(assigns) do
      ~H"""
      <.marker_bar value={75} tooltip="75th percentile" />
      """
    end
  end

  describe "marker_bar/1" do
    test "renders bar with marker at position" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "left: 62%"
      assert html =~ "bg-muted"
    end

    test "renders marker with ring styling" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "ring-2"
      assert html =~ "ring-background"
    end

    test "uses default primary color when no custom color" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "bg-primary"
    end

    test "applies custom color" do
      html = render_component(&H.render_custom_color/1, %{})
      assert html =~ "oklch(0.60 0.20 240)"
    end

    test "renders with animation transition" do
      html = render_component(&H.render_animated/1, %{})
      assert html =~ "transition-all"
      assert html =~ "duration-1000"
    end

    test "renders tooltip title" do
      html = render_component(&H.render_with_tooltip/1, %{})
      assert html =~ "75th percentile"
    end
  end
end
