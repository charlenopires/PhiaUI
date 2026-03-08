defmodule PhiaUi.Components.Data.DataZoomTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Data.DataZoom

    def render_default(assigns) do
      ~H"""
      <.data_zoom id="zoom-1" />
      """
    end

    def render_custom_range(assigns) do
      ~H"""
      <.data_zoom id="zoom-2" start={0.2} end_val={0.8} />
      """
    end

    def render_with_minimap(assigns) do
      ~H"""
      <.data_zoom
        id="zoom-3"
        show_minimap={true}
        minimap_data={[10, 25, 30, 15, 40, 35, 20]}
      />
      """
    end

    def render_custom_height(assigns) do
      ~H"""
      <.data_zoom id="zoom-4" height={60} />
      """
    end

    def render_with_event(assigns) do
      ~H"""
      <.data_zoom id="zoom-5" on_change="zoom-changed" />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.data_zoom id="zoom-6" class="my-zoom" />
      """
    end

    def render_custom_minimap_color(assigns) do
      ~H"""
      <.data_zoom
        id="zoom-7"
        show_minimap={true}
        minimap_data={[1, 2, 3]}
        minimap_color="oklch(0.70 0.18 145)"
      />
      """
    end
  end

  describe "data_zoom/1" do
    test "renders root div with id" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(id="zoom-1")
    end

    test "renders phx-hook" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(phx-hook="PhiaDataZoom")
    end

    test "renders slider role" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(role="slider")
    end

    test "renders default start and end" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(data-start="0.0")
      assert html =~ ~s(data-end="1.0")
    end

    test "renders custom range" do
      html = render_component(&H.render_custom_range/1, %{})
      assert html =~ ~s(data-start="0.2")
      assert html =~ ~s(data-end="0.8")
    end

    test "renders handles" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(data-role="handle-start")
      assert html =~ ~s(data-role="handle-end")
    end

    test "renders window" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(data-role="window")
    end

    test "renders minimap when enabled" do
      html = render_component(&H.render_with_minimap/1, %{})
      assert html =~ "<svg"
      assert html =~ "<path"
    end

    test "hides minimap by default" do
      html = render_component(&H.render_default/1, %{})
      refute html =~ "<svg"
    end

    test "renders custom height" do
      html = render_component(&H.render_custom_height/1, %{})
      assert html =~ "height: 60px"
    end

    test "renders event name" do
      html = render_component(&H.render_with_event/1, %{})
      assert html =~ ~s(data-event="zoom-changed")
    end

    test "applies custom class" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-zoom"
    end

    test "renders custom minimap color" do
      html = render_component(&H.render_custom_minimap_color/1, %{})
      assert html =~ "oklch(0.70 0.18 145)"
    end

    test "renders aria label" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Data zoom range"
    end
  end
end
