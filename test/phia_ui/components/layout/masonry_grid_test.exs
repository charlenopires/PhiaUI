defmodule PhiaUi.Components.Layout.MasonryGridTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Layout.MasonryGrid

    def render_masonry_grid(assigns) do
      ~H"""
      <.masonry_grid
        cols={assigns[:cols] || 3}
        gap={assigns[:gap] || 4}
        class={assigns[:class]}
      >
        <div>item</div>
      </.masonry_grid>
      """
    end
  end

  defp render_masonry_grid(attrs \\ %{}) do
    render_component(&H.render_masonry_grid/1, attrs)
  end

  describe "masonry_grid/1 defaults" do
    test "renders a div" do
      assert render_masonry_grid() =~ "<div"
    end

    test "applies columns-3 by default" do
      assert render_masonry_grid() =~ "columns-3"
    end

    test "applies default gap-4" do
      assert render_masonry_grid() =~ "gap-4"
    end

    test "renders children" do
      assert render_masonry_grid() =~ "item"
    end
  end

  describe "masonry_grid/1 cols" do
    test "1 column" do
      assert render_masonry_grid(%{cols: 1}) =~ "columns-1"
    end

    test "2 columns" do
      assert render_masonry_grid(%{cols: 2}) =~ "columns-2"
    end

    test "4 columns" do
      assert render_masonry_grid(%{cols: 4}) =~ "columns-4"
    end

    test "5 columns" do
      assert render_masonry_grid(%{cols: 5}) =~ "columns-5"
    end
  end

  describe "masonry_grid/1 gap" do
    test "custom gap" do
      assert render_masonry_grid(%{gap: 6}) =~ "gap-6"
    end
  end

  describe "masonry_grid/1 class forwarding" do
    test "forwards custom class" do
      assert render_masonry_grid(%{class: "mt-8"}) =~ "mt-8"
    end
  end
end
