defmodule PhiaUi.Components.MultiDrag do
  @moduledoc """
  Multi-select drag-and-drop list component for PhiaUI.

  Wraps `sortable_item/1` items with multi-selection behaviour powered by the
  `PhiaMultiDrag` hook. Supports click, Ctrl/Meta+click, and Shift+click
  selection, then dragging all selected items together.

  ## Example

      <.multi_drag_list id="tasks" on_reorder="multi_reorder">
        <.sortable_item :for={{item, idx} <- Enum.with_index(@items)}
          id={item.id} index={idx}>
          {item.title}
        </.sortable_item>
      </.multi_drag_list>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # multi_drag_list/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :on_reorder, :string, default: "multi_reorder"
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Renders a multi-select sortable list backed by the `PhiaMultiDrag` hook.

  Items support multi-selection (click, Ctrl+click, Shift+click). Dragging any
  selected item moves the entire selection. The hook emits `on_reorder` with
  `%{ids: ["id1", "id2", ...], new_index: N}`.
  """
  def multi_drag_list(assigns) do
    ~H"""
    <ul
      id={@id}
      phx-hook="PhiaMultiDrag"
      data-on-reorder={@on_reorder}
      role="list"
      aria-multiselectable="true"
      class={cn(["flex flex-col gap-2", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </ul>
    """
  end
end
