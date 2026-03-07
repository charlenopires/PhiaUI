defmodule PhiaUi.Components.BackToTopTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.BackToTop

    def render_default(assigns) do
      ~H"""
      <.back_to_top id="btt" threshold={200} smooth={true} variant={:circle} position={:bottom_right} />
      """
    end

    def render_pill(assigns) do
      ~H"""
      <.back_to_top id="btt-pill" threshold={300} smooth={false} variant={:pill} position={:bottom_left} />
      """
    end

    def render_center(assigns) do
      ~H"""
      <.back_to_top id="btt-center" threshold={200} smooth={true} variant={:circle} position={:bottom_center} />
      """
    end
  end

  defp render_default, do: render_component(&H.render_default/1, %{})
  defp render_pill, do: render_component(&H.render_pill/1, %{})
  defp render_center, do: render_component(&H.render_center/1, %{})

  describe "back_to_top/1" do
    test "renders <button> element" do
      assert render_default() =~ "<button"
    end

    test "has phx-hook=PhiaBackTop" do
      assert render_default() =~ ~s(phx-hook="PhiaBackTop")
    end

    test "starts with opacity-0" do
      assert render_default() =~ "opacity-0"
    end

    test "has aria-label for accessibility" do
      assert render_default() =~ ~s(aria-label="Scroll to top")
    end

    test "forwards data-threshold" do
      assert render_default() =~ ~s(data-threshold="200")
    end

    test "forwards data-smooth" do
      assert render_default() =~ "data-smooth"
    end

    test "has screen reader text" do
      assert render_default() =~ "Scroll to top"
    end

    test "circle variant has rounded-full" do
      assert render_default() =~ "rounded-full"
    end

    test "pill variant has px-4" do
      assert render_pill() =~ "px-4"
    end

    test "bottom_right position has right-6 class" do
      assert render_default() =~ "right-6"
    end

    test "bottom_left position has left-6 class" do
      assert render_pill() =~ "left-6"
    end

    test "bottom_center position has left-1/2 class" do
      assert render_center() =~ "left-1/2"
    end

    test "renders upward arrow SVG" do
      assert render_default() =~ "<svg"
    end

    test "has fixed positioning" do
      assert render_default() =~ "fixed"
    end
  end
end
