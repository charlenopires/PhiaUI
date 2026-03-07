defmodule PhiaUi.Components.SortableGridTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.SortableGrid

    def render_grid(assigns) do
      ~H"""
      <.sortable_grid
        id={assigns[:id] || "grid-1"}
        cols={assigns[:cols] || 3}
        gap={assigns[:gap] || "md"}
        on_reorder={assigns[:on_reorder] || "grid_reorder"}
        class={assigns[:class]}
      >
        {assigns[:content] || "grid content"}
      </.sortable_grid>
      """
    end

    def render_item(assigns) do
      ~H"""
      <.sortable_grid_item
        id={assigns[:id] || "gitem-1"}
        index={assigns[:index] || 0}
        aspect={assigns[:aspect] || "auto"}
        class={assigns[:class]}
      >
        {assigns[:content] || "cell content"}
      </.sortable_grid_item>
      """
    end
  end

  defp render_grid(attrs \\ %{}), do: render_component(&H.render_grid/1, attrs)
  defp render_item(attrs \\ %{}), do: render_component(&H.render_item/1, attrs)

  # ---------------------------------------------------------------------------
  # sortable_grid/1
  # ---------------------------------------------------------------------------

  describe "sortable_grid/1" do
    test "renders a div element" do
      assert render_grid() =~ "<div"
    end

    test "has phx-hook=PhiaSortableGrid" do
      assert render_grid() =~ ~s(phx-hook="PhiaSortableGrid")
    end

    test "forwards id attribute" do
      assert render_grid(%{id: "my-grid"}) =~ ~s(id="my-grid")
    end

    test "has data-on-reorder attribute" do
      assert render_grid(%{on_reorder: "my_event"}) =~ ~s(data-on-reorder="my_event")
    end

    test "renders grid class" do
      assert render_grid() =~ "grid"
    end

    test "cols=2 renders grid-cols-2" do
      assert render_grid(%{cols: 2}) =~ "grid-cols-2"
    end

    test "cols=3 renders grid-cols-3" do
      assert render_grid(%{cols: 3}) =~ "grid-cols-3"
    end

    test "cols=4 renders grid-cols-4" do
      assert render_grid(%{cols: 4}) =~ "grid-cols-4"
    end

    test "gap=sm renders gap-2" do
      assert render_grid(%{gap: "sm"}) =~ "gap-2"
    end

    test "gap=md renders gap-4" do
      assert render_grid(%{gap: "md"}) =~ "gap-4"
    end

    test "gap=lg renders gap-6" do
      assert render_grid(%{gap: "lg"}) =~ "gap-6"
    end

    test "renders inner content" do
      assert render_grid(%{content: "grid cell"}) =~ "grid cell"
    end

    test "applies custom class" do
      assert render_grid(%{class: "my-grid"}) =~ "my-grid"
    end
  end

  # ---------------------------------------------------------------------------
  # sortable_grid_item/1
  # ---------------------------------------------------------------------------

  describe "sortable_grid_item/1" do
    test "renders a div element" do
      assert render_item() =~ "<div"
    end

    test "has data-sortable-grid-item attribute" do
      assert render_item() =~ "data-sortable-grid-item"
    end

    test "has draggable=true" do
      assert render_item() =~ ~s(draggable="true")
    end

    test "has data-index attribute" do
      assert render_item(%{index: 5}) =~ ~s(data-index="5")
    end

    test "aspect=square adds aspect-square" do
      assert render_item(%{aspect: "square"}) =~ "aspect-square"
    end

    test "aspect=video adds aspect-video" do
      assert render_item(%{aspect: "video"}) =~ "aspect-video"
    end

    test "renders inner content" do
      assert render_item(%{content: "cell body"}) =~ "cell body"
    end

    test "applies custom class" do
      assert render_item(%{class: "my-cell"}) =~ "my-cell"
    end

    test "forwards id attribute" do
      assert render_item(%{id: "cell-42"}) =~ ~s(id="cell-42")
    end
  end
end
