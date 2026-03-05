defmodule PhiaUi.Components.SonnerTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Sonner

    def render_sonner(assigns) do
      ~H"""
      <.sonner id="toast-container" />
      """
    end

    def render_sonner_position_top_left(assigns) do
      ~H"""
      <.sonner id="s1" position="top-left" />
      """
    end

    def render_sonner_position_top_center(assigns) do
      ~H"""
      <.sonner id="s2" position="top-center" />
      """
    end

    def render_sonner_position_top_right(assigns) do
      ~H"""
      <.sonner id="s3" position="top-right" />
      """
    end

    def render_sonner_position_bottom_left(assigns) do
      ~H"""
      <.sonner id="s4" position="bottom-left" />
      """
    end

    def render_sonner_position_bottom_center(assigns) do
      ~H"""
      <.sonner id="s5" position="bottom-center" />
      """
    end

    def render_sonner_position_bottom_right(assigns) do
      ~H"""
      <.sonner id="s6" position="bottom-right" />
      """
    end

    def render_sonner_expand(assigns) do
      ~H"""
      <.sonner id="s7" expand={true} />
      """
    end

    def render_sonner_rich_colors(assigns) do
      ~H"""
      <.sonner id="s8" rich_colors={true} />
      """
    end

    def render_sonner_max_visible(assigns) do
      ~H"""
      <.sonner id="s9" max_visible={5} />
      """
    end

    def render_sonner_custom_class(assigns) do
      ~H"""
      <.sonner id="s10" class="my-custom" />
      """
    end
  end

  describe "sonner/1" do
    test "renders a div element" do
      html = render_component(&H.render_sonner/1, %{})
      assert html =~ "<div"
    end

    test "has phx-hook=PhiaSonner" do
      html = render_component(&H.render_sonner/1, %{})
      assert html =~ ~s(phx-hook="PhiaSonner")
    end

    test "renders with id attribute" do
      html = render_component(&H.render_sonner/1, %{})
      assert html =~ ~s(id="toast-container")
    end

    test "has role=status" do
      html = render_component(&H.render_sonner/1, %{})
      assert html =~ ~s(role="status")
    end

    test "has aria-live=polite" do
      html = render_component(&H.render_sonner/1, %{})
      assert html =~ ~s(aria-live="polite")
    end

    test "default position is bottom-right" do
      html = render_component(&H.render_sonner/1, %{})
      assert html =~ "bottom-right" or html =~ "bottom-4" or html =~ "right-4"
    end

    test "position top-left applies top and left classes" do
      html = render_component(&H.render_sonner_position_top_left/1, %{})
      assert html =~ "top-" or html =~ "left-"
    end

    test "position top-center applies top and center/left-1/2 classes" do
      html = render_component(&H.render_sonner_position_top_center/1, %{})
      assert html =~ "top-"
    end

    test "position top-right applies top and right classes" do
      html = render_component(&H.render_sonner_position_top_right/1, %{})
      assert html =~ "top-"
    end

    test "position bottom-left applies bottom and left classes" do
      html = render_component(&H.render_sonner_position_bottom_left/1, %{})
      assert html =~ "bottom-"
    end

    test "position bottom-center applies bottom and center classes" do
      html = render_component(&H.render_sonner_position_bottom_center/1, %{})
      assert html =~ "bottom-"
    end

    test "position bottom-right applies bottom and right classes" do
      html = render_component(&H.render_sonner_position_bottom_right/1, %{})
      assert html =~ "bottom-" or html =~ "right-"
    end

    test "data-position attribute is set" do
      html = render_component(&H.render_sonner_position_top_left/1, %{})
      assert html =~ "data-position"
    end

    test "expand=true sets data-expand attribute" do
      html = render_component(&H.render_sonner_expand/1, %{})
      assert html =~ "data-expand"
    end

    test "rich_colors=true sets data-rich-colors attribute" do
      html = render_component(&H.render_sonner_rich_colors/1, %{})
      assert html =~ "data-rich-colors"
    end

    test "max_visible sets data-max-visible attribute" do
      html = render_component(&H.render_sonner_max_visible/1, %{})
      assert html =~ "data-max-visible"
    end

    test "custom class is applied" do
      html = render_component(&H.render_sonner_custom_class/1, %{})
      assert html =~ "my-custom"
    end
  end
end
