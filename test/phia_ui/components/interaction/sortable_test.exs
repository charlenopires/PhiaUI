defmodule PhiaUi.Components.SortableTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Sortable

    def render_handle(assigns) do
      ~H"""
      <.drag_handle
        size={assigns[:size] || "md"}
        aria_label={assigns[:aria_label] || "Drag to reorder"}
        class={assigns[:class]}
      />
      """
    end

    def render_indicator(assigns) do
      ~H"""
      <.drop_indicator
        orientation={assigns[:orientation] || "horizontal"}
        active={assigns[:active] || false}
        class={assigns[:class]}
      />
      """
    end

    def render_list(assigns) do
      ~H"""
      <.sortable_list
        id={assigns[:id] || "list-1"}
        orientation={assigns[:orientation] || "vertical"}
        handle={assigns[:handle] || false}
        on_reorder={assigns[:on_reorder] || "reorder"}
        class={assigns[:class]}
      >
        {assigns[:content] || "list content"}
      </.sortable_list>
      """
    end

    def render_item(assigns) do
      ~H"""
      <.sortable_item
        id={assigns[:id] || "item-1"}
        index={assigns[:index] || 0}
        disabled={assigns[:disabled] || false}
        class={assigns[:class]}
      >
        {assigns[:content] || "item content"}
      </.sortable_item>
      """
    end

    def render_item_with_handle(assigns) do
      ~H"""
      <.sortable_item id="item-h" index={0}>
        <:handle>
          <.drag_handle />
        </:handle>
        Item with handle
      </.sortable_item>
      """
    end
  end

  defp render_handle(attrs \\ %{}), do: render_component(&H.render_handle/1, attrs)
  defp render_indicator(attrs \\ %{}), do: render_component(&H.render_indicator/1, attrs)
  defp render_list(attrs \\ %{}), do: render_component(&H.render_list/1, attrs)
  defp render_item(attrs \\ %{}), do: render_component(&H.render_item/1, attrs)
  defp render_item_with_handle, do: render_component(&H.render_item_with_handle/1, %{})

  # ---------------------------------------------------------------------------
  # drag_handle/1
  # ---------------------------------------------------------------------------

  describe "drag_handle/1" do
    test "renders a button element" do
      assert render_handle() =~ "<button"
    end

    test "has type=button" do
      assert render_handle() =~ ~s(type="button")
    end

    test "has data-sortable-handle attribute" do
      assert render_handle() =~ "data-sortable-handle"
    end

    test "has tabindex=0" do
      assert render_handle() =~ ~s(tabindex="0")
    end

    test "renders default aria-label" do
      assert render_handle() =~ ~s(aria-label="Drag to reorder")
    end

    test "renders custom aria-label" do
      assert render_handle(%{aria_label: "Move item"}) =~ ~s(aria-label="Move item")
    end

    test "applies size variant sm" do
      assert render_handle(%{size: "sm"}) =~ "w-3"
    end

    test "applies size variant lg" do
      assert render_handle(%{size: "lg"}) =~ "w-5"
    end

    test "contains an SVG grip icon" do
      assert render_handle() =~ "<svg"
      assert render_handle() =~ "<circle"
    end

    test "cursor-grab class present" do
      assert render_handle() =~ "cursor-grab"
    end

    test "applies custom class" do
      assert render_handle(%{class: "my-handle"}) =~ "my-handle"
    end
  end

  # ---------------------------------------------------------------------------
  # drop_indicator/1
  # ---------------------------------------------------------------------------

  describe "drop_indicator/1" do
    test "renders a div element" do
      assert render_indicator() =~ "<div"
    end

    test "has data-drop-indicator attribute" do
      assert render_indicator() =~ "data-drop-indicator"
    end

    test "has aria-hidden=true" do
      assert render_indicator() =~ ~s(aria-hidden="true")
    end

    test "horizontal inactive has bg-transparent" do
      html = render_indicator(%{orientation: "horizontal", active: false})
      assert html =~ "bg-transparent"
    end

    test "horizontal active has bg-primary" do
      html = render_indicator(%{orientation: "horizontal", active: true})
      assert html =~ "bg-primary"
    end

    test "vertical inactive uses w-0.5" do
      html = render_indicator(%{orientation: "vertical", active: false})
      assert html =~ "w-0.5"
    end

    test "vertical active uses bg-primary" do
      html = render_indicator(%{orientation: "vertical", active: true})
      assert html =~ "bg-primary"
      assert html =~ "w-0.5"
    end

    test "applies custom class" do
      assert render_indicator(%{class: "my-indicator"}) =~ "my-indicator"
    end
  end

  # ---------------------------------------------------------------------------
  # sortable_list/1
  # ---------------------------------------------------------------------------

  describe "sortable_list/1" do
    test "renders a ul element" do
      assert render_list() =~ "<ul"
    end

    test "has phx-hook=PhiaSortable" do
      assert render_list() =~ ~s(phx-hook="PhiaSortable")
    end

    test "has role=list" do
      assert render_list() =~ ~s(role="list")
    end

    test "forwards id attribute" do
      assert render_list(%{id: "my-list"}) =~ ~s(id="my-list")
    end

    test "has data-orientation attribute" do
      assert render_list(%{orientation: "horizontal"}) =~ ~s(data-orientation="horizontal")
    end

    test "has data-handle attribute" do
      assert render_list(%{handle: true}) =~ ~s(data-handle="true")
    end

    test "has data-on-reorder attribute" do
      assert render_list(%{on_reorder: "my_event"}) =~ ~s(data-on-reorder="my_event")
    end

    test "vertical orientation adds flex-col" do
      assert render_list(%{orientation: "vertical"}) =~ "flex-col"
    end

    test "horizontal orientation adds flex-row" do
      assert render_list(%{orientation: "horizontal"}) =~ "flex-row"
    end

    test "renders inner content" do
      assert render_list(%{content: "slot content"}) =~ "slot content"
    end

    test "applies custom class" do
      assert render_list(%{class: "my-list"}) =~ "my-list"
    end
  end

  # ---------------------------------------------------------------------------
  # sortable_item/1
  # ---------------------------------------------------------------------------

  describe "sortable_item/1" do
    test "renders an li element" do
      assert render_item() =~ "<li"
    end

    test "has data-sortable-item attribute" do
      assert render_item() =~ "data-sortable-item"
    end

    test "has data-index attribute" do
      assert render_item(%{index: 3}) =~ ~s(data-index="3")
    end

    test "draggable is true when not disabled" do
      assert render_item(%{disabled: false}) =~ ~s(draggable="true")
    end

    test "draggable is false when disabled" do
      assert render_item(%{disabled: true}) =~ ~s(draggable="false")
    end

    test "disabled item has opacity class" do
      assert render_item(%{disabled: true}) =~ "opacity-50"
    end

    test "forwards id attribute" do
      assert render_item(%{id: "item-xyz"}) =~ ~s(id="item-xyz")
    end

    test "renders inner content" do
      assert render_item(%{content: "task title"}) =~ "task title"
    end

    test "has aria-roledescription" do
      assert render_item() =~ "sortable item"
    end

    test "applies custom class" do
      assert render_item(%{class: "my-item"}) =~ "my-item"
    end

    test "renders handle slot" do
      assert render_item_with_handle() =~ "data-sortable-handle"
    end
  end
end
