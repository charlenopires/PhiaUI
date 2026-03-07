defmodule PhiaUi.Components.SortableGrid do
  @moduledoc """
  Sortable grid drag-and-drop components for PhiaUI.

  Provides `sortable_grid/1` and `sortable_grid_item/1`. Pair with the
  `PhiaSortableGrid` hook for 2D nearest-neighbour drag-and-drop reordering.

  ## Example

      <.sortable_grid id="photo-grid" cols={3} on_reorder="grid_reorder">
        <.sortable_grid_item :for={{img, idx} <- Enum.with_index(@images)}
          id={"img-\#{img.id}"} index={idx} aspect="square">
          <img src={img.url} class="w-full h-full object-cover" />
        </.sortable_grid_item>
      </.sortable_grid>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # sortable_grid/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :cols, :integer, default: 3
  attr :gap, :string, values: ~w(sm md lg), default: "md"
  attr :on_reorder, :string, default: "grid_reorder"
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Renders a sortable grid container backed by the `PhiaSortableGrid` hook.

  The hook uses 2D Euclidean nearest-neighbour comparison to find the closest
  grid cell when dragging, giving a natural feel for image galleries and card
  grids. Emits `on_reorder` with `%{old_index: N, new_index: M, id: "dom-id"}`.
  """
  def sortable_grid(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaSortableGrid"
      data-on-reorder={@on_reorder}
      class={cn([
        "grid",
        grid_cols_class(@cols),
        grid_gap_class(@gap),
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp grid_cols_class(2), do: "grid-cols-2"
  defp grid_cols_class(3), do: "grid-cols-3"
  defp grid_cols_class(4), do: "grid-cols-4"
  defp grid_cols_class(_), do: "grid-cols-3"

  defp grid_gap_class("sm"), do: "gap-2"
  defp grid_gap_class("md"), do: "gap-4"
  defp grid_gap_class("lg"), do: "gap-6"

  # ---------------------------------------------------------------------------
  # sortable_grid_item/1
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :index, :integer, required: true
  attr :aspect, :string, values: ~w(square video auto), default: "auto"
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Renders a single sortable grid cell.

  The `aspect` attribute locks the cell ratio: `"square"` (1:1), `"video"` (16:9),
  or `"auto"` (natural height). The hook sets `data-dragging` during the drag.
  """
  def sortable_grid_item(assigns) do
    ~H"""
    <div
      id={@id}
      data-sortable-grid-item
      data-index={@index}
      draggable="true"
      class={cn([
        "relative rounded-md border border-border bg-background overflow-hidden",
        "transition-transform duration-150",
        "data-[dragging]:scale-95 data-[dragging]:opacity-60 data-[dragging]:shadow-xl",
        aspect_class(@aspect),
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp aspect_class("square"), do: "aspect-square"
  defp aspect_class("video"), do: "aspect-video"
  defp aspect_class("auto"), do: ""
end
