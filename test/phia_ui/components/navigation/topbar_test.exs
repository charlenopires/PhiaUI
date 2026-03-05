defmodule PhiaUi.Components.TopbarTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Topbar

    attr(:class, :string, default: nil)

    def render_topbar(assigns) do
      ~H"""
      <.topbar class={@class}>
        <span>App</span>
      </.topbar>
      """
    end
  end

  describe "topbar/1" do
    test "renders header element" do
      html = render_component(&H.render_topbar/1, %{})
      assert html =~ "<header"
    end

    test "has h-14 height" do
      html = render_component(&H.render_topbar/1, %{})
      assert html =~ "h-14"
    end

    test "has border-b" do
      html = render_component(&H.render_topbar/1, %{})
      assert html =~ "border-b"
    end

    test "has flex items-center" do
      html = render_component(&H.render_topbar/1, %{})
      assert html =~ "flex"
      assert html =~ "items-center"
    end

    test "renders slot content" do
      html = render_component(&H.render_topbar/1, %{})
      assert html =~ "App"
    end

    test "accepts custom class" do
      html = render_component(&H.render_topbar/1, %{class: "px-8"})
      assert html =~ "px-8"
    end

    test "references --background CSS custom property" do
      html = render_component(&H.render_topbar/1, %{})
      assert html =~ "--background"
    end
  end
end
