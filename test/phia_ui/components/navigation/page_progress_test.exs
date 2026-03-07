defmodule PhiaUi.Components.PageProgressTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.PageProgress

    def render_default(assigns) do
      ~H"""
      <.page_progress id="progress" variant={:default} position={:top} />
      """
    end

    def render_gradient(assigns) do
      ~H"""
      <.page_progress id="progress" variant={:gradient} position={:top} />
      """
    end

    def render_thin(assigns) do
      ~H"""
      <.page_progress id="progress" variant={:thin} position={:top} />
      """
    end

    def render_bottom(assigns) do
      ~H"""
      <.page_progress id="progress" variant={:default} position={:bottom} />
      """
    end

    def render_custom_color(assigns) do
      ~H"""
      <.page_progress id="progress" variant={:default} position={:top} color="red" />
      """
    end

    def render_no_color(assigns) do
      ~H"""
      <.page_progress id="progress" variant={:default} position={:top} color={nil} />
      """
    end
  end

  defp render_default, do: render_component(&H.render_default/1, %{})
  defp render_gradient, do: render_component(&H.render_gradient/1, %{})
  defp render_thin, do: render_component(&H.render_thin/1, %{})
  defp render_bottom, do: render_component(&H.render_bottom/1, %{})
  defp render_custom_color, do: render_component(&H.render_custom_color/1, %{})
  defp render_no_color, do: render_component(&H.render_no_color/1, %{})

  describe "page_progress/1" do
    test "has phx-hook=PhiaPageProgress" do
      assert render_default() =~ ~s(phx-hook="PhiaPageProgress")
    end

    test "has role=progressbar" do
      assert render_default() =~ ~s(role="progressbar")
    end

    test "has aria-valuemin=0" do
      assert render_default() =~ ~s(aria-valuemin="0")
    end

    test "has aria-valuemax=100" do
      assert render_default() =~ ~s(aria-valuemax="100")
    end

    test "has aria-valuenow=0 initially" do
      assert render_default() =~ ~s(aria-valuenow="0")
    end

    test "starts with w-0 (hook drives width)" do
      assert render_default() =~ "w-0"
    end

    test "default variant has h-1" do
      assert render_default() =~ "h-1"
    end

    test "default variant has bg-primary" do
      assert render_default() =~ "bg-primary"
    end

    test "gradient variant has bg-gradient-to-r" do
      assert render_gradient() =~ "bg-gradient-to-r"
    end

    test "thin variant has h-0.5" do
      assert render_thin() =~ "h-0.5"
    end

    test "top position has fixed top-0 left-0" do
      html = render_default()
      assert html =~ "fixed"
      assert html =~ "top-0"
      assert html =~ "left-0"
    end

    test "bottom position has bottom-0" do
      assert render_bottom() =~ "bottom-0"
    end

    test "renders inline style when color is set" do
      assert render_custom_color() =~ ~s(style="background: red")
    end

    test "does not render background style when color is nil" do
      refute render_no_color() =~ ~s(style="background)
    end
  end
end
