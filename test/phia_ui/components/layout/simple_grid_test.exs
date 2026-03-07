defmodule PhiaUi.Components.Layout.SimpleGridTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Layout.SimpleGrid

    def render_simple_grid(assigns) do
      ~H"""
      <.simple_grid
        cols={assigns[:cols]}
        min_child_width={assigns[:min_child_width]}
        gap={assigns[:gap] || 4}
        class={assigns[:class]}
      >
        child
      </.simple_grid>
      """
    end
  end

  defp render_simple_grid(attrs \\ %{}) do
    render_component(&H.render_simple_grid/1, attrs)
  end

  describe "simple_grid/1 defaults" do
    test "renders a div" do
      assert render_simple_grid() =~ "<div"
    end

    test "applies grid class" do
      assert render_simple_grid() =~ "grid"
    end

    test "applies default gap-4" do
      assert render_simple_grid() =~ "gap-4"
    end

    test "renders children" do
      assert render_simple_grid() =~ "child"
    end
  end

  describe "simple_grid/1 cols preset" do
    test "cols 1 applies grid-cols-1" do
      assert render_simple_grid(%{cols: 1}) =~ "grid-cols-1"
    end

    test "cols 2 includes sm:grid-cols-2" do
      assert render_simple_grid(%{cols: 2}) =~ "sm:grid-cols-2"
    end

    test "cols 3 includes md:grid-cols-3" do
      assert render_simple_grid(%{cols: 3}) =~ "md:grid-cols-3"
    end

    test "cols 4 includes lg:grid-cols-4" do
      assert render_simple_grid(%{cols: 4}) =~ "lg:grid-cols-4"
    end
  end

  describe "simple_grid/1 min_child_width" do
    test "sets inline style with auto-fit" do
      html = render_simple_grid(%{min_child_width: "200px"})
      assert html =~ "auto-fit"
      assert html =~ "200px"
    end
  end

  describe "simple_grid/1 class forwarding" do
    test "forwards custom class" do
      assert render_simple_grid(%{class: "mt-8"}) =~ "mt-8"
    end
  end
end
