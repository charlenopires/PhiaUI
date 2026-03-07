defmodule PhiaUi.Components.Layout.StickyTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Layout.Sticky

    def render_sticky(assigns) do
      ~H"""
      <.sticky
        position={assigns[:position] || :top}
        offset={assigns[:offset] || 0}
        z={assigns[:z] || 10}
        class={assigns[:class]}
      >
        content
      </.sticky>
      """
    end
  end

  defp render_sticky(attrs \\ %{}) do
    render_component(&H.render_sticky/1, attrs)
  end

  describe "sticky/1 default" do
    test "renders a div" do
      assert render_sticky() =~ "<div"
    end

    test "applies sticky class" do
      assert render_sticky() =~ "sticky"
    end

    test "defaults to top-0" do
      assert render_sticky() =~ "top-0"
    end

    test "defaults to z-10" do
      assert render_sticky() =~ "z-10"
    end

    test "renders inner content" do
      assert render_sticky() =~ "content"
    end
  end

  describe "sticky/1 position" do
    test "top position with offset" do
      html = render_sticky(%{position: :top, offset: 4})
      assert html =~ "top-4"
      assert html =~ "sticky"
    end

    test "bottom position zero offset" do
      html = render_sticky(%{position: :bottom, offset: 0})
      assert html =~ "bottom-0"
      assert html =~ "sticky"
    end

    test "bottom position with offset" do
      html = render_sticky(%{position: :bottom, offset: 16})
      assert html =~ "bottom-16"
    end
  end

  describe "sticky/1 z-index" do
    test "z-0" do
      assert render_sticky(%{z: 0}) =~ "z-0"
    end

    test "z-50" do
      assert render_sticky(%{z: 50}) =~ "z-50"
    end
  end

  describe "sticky/1 class forwarding" do
    test "forwards custom class" do
      assert render_sticky(%{class: "bg-background"}) =~ "bg-background"
    end
  end
end
