defmodule PhiaUi.Components.MultiDragTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.MultiDrag
    import PhiaUi.Components.Sortable

    def render_multi(assigns) do
      ~H"""
      <.multi_drag_list
        id={assigns[:id] || "multi-1"}
        on_reorder={assigns[:on_reorder] || "multi_reorder"}
        class={assigns[:class]}
      >
        {assigns[:content] || "list content"}
      </.multi_drag_list>
      """
    end

    def render_multi_with_items(assigns) do
      ~H"""
      <.multi_drag_list id="multi-items" on_reorder="multi_reorder">
        <.sortable_item id="si-1" index={0}>Task One</.sortable_item>
        <.sortable_item id="si-2" index={1}>Task Two</.sortable_item>
      </.multi_drag_list>
      """
    end
  end

  defp render_multi(attrs \\ %{}), do: render_component(&H.render_multi/1, attrs)
  defp render_multi_with_items, do: render_component(&H.render_multi_with_items/1, %{})

  describe "multi_drag_list/1" do
    test "renders a ul element" do
      assert render_multi() =~ "<ul"
    end

    test "has phx-hook=PhiaMultiDrag" do
      assert render_multi() =~ ~s(phx-hook="PhiaMultiDrag")
    end

    test "has aria-multiselectable=true" do
      assert render_multi() =~ ~s(aria-multiselectable="true")
    end

    test "has role=list" do
      assert render_multi() =~ ~s(role="list")
    end

    test "forwards id attribute" do
      assert render_multi(%{id: "my-multi"}) =~ ~s(id="my-multi")
    end

    test "has data-on-reorder attribute" do
      assert render_multi(%{on_reorder: "my_reorder"}) =~ ~s(data-on-reorder="my_reorder")
    end

    test "renders inner content" do
      assert render_multi(%{content: "item content"}) =~ "item content"
    end

    test "applies custom class" do
      assert render_multi(%{class: "my-multi"}) =~ "my-multi"
    end

    test "composes with sortable_item children" do
      html = render_multi_with_items()
      assert html =~ "Task One"
      assert html =~ "Task Two"
      assert html =~ "data-sortable-item"
    end
  end
end
