defmodule PhiaUi.Components.Layout.FixedBarTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Layout.FixedBar

    def render_fixed_bar(assigns) do
      ~H"""
      <.fixed_bar
        position={assigns[:position] || :bottom}
        z={assigns[:z] || 40}
        class={assigns[:class]}
      >
        content
      </.fixed_bar>
      """
    end
  end

  defp render_fixed_bar(attrs \\ %{}) do
    render_component(&H.render_fixed_bar/1, attrs)
  end

  describe "fixed_bar/1 default" do
    test "renders a div" do
      assert render_fixed_bar() =~ "<div"
    end

    test "applies fixed and inset-x-0" do
      html = render_fixed_bar()
      assert html =~ "fixed"
      assert html =~ "inset-x-0"
    end

    test "defaults to bottom" do
      assert render_fixed_bar() =~ "bottom-0"
    end

    test "defaults to z-40" do
      assert render_fixed_bar() =~ "z-40"
    end

    test "bottom position gets top border" do
      assert render_fixed_bar(%{position: :bottom}) =~ "border-t"
    end

    test "renders inner content" do
      assert render_fixed_bar() =~ "content"
    end
  end

  describe "fixed_bar/1 position top" do
    test "applies top-0" do
      assert render_fixed_bar(%{position: :top}) =~ "top-0"
    end

    test "top position gets bottom border" do
      assert render_fixed_bar(%{position: :top}) =~ "border-b"
    end
  end

  describe "fixed_bar/1 z-index" do
    test "z-50" do
      assert render_fixed_bar(%{z: 50}) =~ "z-50"
    end

    test "z-0" do
      assert render_fixed_bar(%{z: 0}) =~ "z-0"
    end
  end

  describe "fixed_bar/1 class forwarding" do
    test "forwards custom class" do
      assert render_fixed_bar(%{class: "p-4"}) =~ "p-4"
    end
  end
end
