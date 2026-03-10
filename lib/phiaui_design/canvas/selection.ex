defmodule PhiaUiDesign.Canvas.Selection do
  @moduledoc """
  Manages selection state for the design canvas.
  """

  defstruct selected_ids: MapSet.new(), hovered_id: nil

  @type t :: %__MODULE__{
          selected_ids: MapSet.t(String.t()),
          hovered_id: String.t() | nil
        }

  def new, do: %__MODULE__{}

  @doc "Select a single node (clearing previous selection)"
  def select(%__MODULE__{} = sel, node_id) do
    %{sel | selected_ids: MapSet.new([node_id])}
  end

  @doc "Toggle selection of a node (for multi-select with Shift)"
  def toggle(%__MODULE__{} = sel, node_id) do
    if MapSet.member?(sel.selected_ids, node_id) do
      %{sel | selected_ids: MapSet.delete(sel.selected_ids, node_id)}
    else
      %{sel | selected_ids: MapSet.put(sel.selected_ids, node_id)}
    end
  end

  @doc "Clear all selection"
  def clear(%__MODULE__{} = sel) do
    %{sel | selected_ids: MapSet.new(), hovered_id: nil}
  end

  @doc "Set hovered node"
  def hover(%__MODULE__{} = sel, node_id) do
    %{sel | hovered_id: node_id}
  end

  @doc "Check if a node is selected"
  def selected?(%__MODULE__{} = sel, node_id) do
    MapSet.member?(sel.selected_ids, node_id)
  end

  @doc "Get the single selected node ID (or nil if none/multiple)"
  def single_selected(%__MODULE__{} = sel) do
    case MapSet.to_list(sel.selected_ids) do
      [id] -> id
      _ -> nil
    end
  end

  @doc "Get count of selected nodes"
  def count(%__MODULE__{} = sel) do
    MapSet.size(sel.selected_ids)
  end
end
