defmodule PhiaUiDesign.Canvas.Scene do
  @moduledoc """
  ETS-backed scene graph for the design canvas.

  Each scene is an ETS table containing Node structs keyed by their ID.
  A special `:root` entry tracks the top-level node IDs.
  """

  alias PhiaUiDesign.Canvas.Node

  @type scene_id :: reference()

  @doc "Create a new empty scene"
  def new do
    table = :ets.new(:scene, [:set, :public, read_concurrency: true])
    :ets.insert(table, {:__root_children__, []})
    :ets.insert(table, {:__meta__, %{name: "Untitled", created_at: DateTime.utc_now()}})
    :ets.insert(table, {:__variables__, %{}})
    table
  end

  @doc "Insert a node into the scene"
  def insert(scene, %Node{} = node) do
    :ets.insert(scene, {node.id, node})

    # Add to parent's children list or root children
    if node.parent_id do
      update_children(scene, node.parent_id, fn children -> children ++ [node.id] end)
    else
      update_root_children(scene, fn children -> children ++ [node.id] end)
    end

    {:ok, node}
  end

  @doc "Insert a PhiaUI component into the scene"
  def insert_component(scene, component_name, opts \\ []) do
    registry_entry = PhiaUi.ComponentRegistry.get(component_name)

    node =
      Node.new_component(component_name,
        module: registry_entry && registry_entry.module,
        attrs: Keyword.get(opts, :attrs, %{}),
        slots: Keyword.get(opts, :slots, %{}),
        parent_id: Keyword.get(opts, :parent_id),
        name: Keyword.get(opts, :name, to_string(component_name))
      )

    insert(scene, node)
  end

  @doc "Insert an HTML element into the scene"
  def insert_element(scene, tag, opts \\ []) do
    node =
      Node.new_element(tag,
        classes: Keyword.get(opts, :classes),
        parent_id: Keyword.get(opts, :parent_id),
        name: Keyword.get(opts, :name, tag)
      )

    insert(scene, node)
  end

  @doc "Get a node by ID"
  def get_node(scene, node_id) do
    case :ets.lookup(scene, node_id) do
      [{^node_id, %Node{} = node}] -> {:ok, node}
      _ -> {:error, :not_found}
    end
  end

  @doc "Update a node's attributes"
  def update_node(scene, node_id, changes) when is_map(changes) do
    with {:ok, node} <- get_node(scene, node_id) do
      updated = Map.merge(node, changes)
      :ets.insert(scene, {node_id, updated})
      {:ok, updated}
    end
  end

  @doc "Update a node's component attrs"
  def update_attrs(scene, node_id, attr_changes) when is_map(attr_changes) do
    with {:ok, node} <- get_node(scene, node_id) do
      updated = %{node | attrs: Map.merge(node.attrs, attr_changes)}
      :ets.insert(scene, {node_id, updated})
      {:ok, updated}
    end
  end

  @doc "Delete a node from the scene"
  def delete_node(scene, node_id) do
    with {:ok, node} <- get_node(scene, node_id) do
      # Remove from parent's children
      if node.parent_id do
        update_children(scene, node.parent_id, fn children ->
          List.delete(children, node_id)
        end)
      else
        update_root_children(scene, fn children -> List.delete(children, node_id) end)
      end

      # Recursively delete children
      Enum.each(node.children, &delete_node(scene, &1))

      # Delete the node itself
      :ets.delete(scene, node_id)
      :ok
    end
  end

  @doc "Move a node to a new parent at a given index"
  def move_node(scene, node_id, new_parent_id, index \\ -1) do
    with {:ok, node} <- get_node(scene, node_id) do
      # Remove from old parent
      if node.parent_id do
        update_children(scene, node.parent_id, &List.delete(&1, node_id))
      else
        update_root_children(scene, &List.delete(&1, node_id))
      end

      # Add to new parent
      if new_parent_id do
        update_children(scene, new_parent_id, fn children ->
          insert_at_index(children, node_id, index)
        end)
      else
        update_root_children(scene, fn children ->
          insert_at_index(children, node_id, index)
        end)
      end

      updated = %{node | parent_id: new_parent_id}
      :ets.insert(scene, {node_id, updated})
      {:ok, updated}
    end
  end

  @doc "Get all nodes as a flat list"
  def all_nodes(scene) do
    :ets.tab2list(scene)
    |> Enum.filter(fn
      {_id, %Node{}} -> true
      _ -> false
    end)
    |> Enum.map(fn {_id, node} -> node end)
  end

  @doc "Build the scene as a tree structure (nested maps)"
  def to_tree(scene) do
    root_children = get_root_children(scene)
    Enum.map(root_children, &build_tree_node(scene, &1))
  end

  @doc "Get root-level children IDs"
  def get_root_children(scene) do
    case :ets.lookup(scene, :__root_children__) do
      [{:__root_children__, children}] -> children
      _ -> []
    end
  end

  @doc "Count total nodes in the scene"
  def count(scene) do
    all_nodes(scene) |> length()
  end

  @doc "Get all unique component names used in the scene"
  def components_used(scene) do
    all_nodes(scene)
    |> Enum.filter(&(&1.type == :phia_component))
    |> Enum.map(& &1.component)
    |> Enum.uniq()
  end

  @doc "Get all JS hooks needed by components in the scene"
  def hooks_needed(scene) do
    components_used(scene)
    |> Enum.map(&PhiaUi.ComponentRegistry.get/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.flat_map(& &1.js_hooks)
    |> Enum.uniq()
  end

  @doc "Find nodes matching a predicate function"
  def find_nodes(scene, predicate) when is_function(predicate, 1) do
    all_nodes(scene)
    |> Enum.filter(predicate)
  end

  @doc "Destroy the scene (delete ETS table)"
  def destroy(scene) do
    :ets.delete(scene)
    :ok
  end

  # Private helpers

  defp build_tree_node(scene, node_id) do
    case get_node(scene, node_id) do
      {:ok, node} ->
        children = Enum.map(node.children, &build_tree_node(scene, &1))
        %{node: node, children: children}

      _ ->
        nil
    end
  end

  defp update_children(scene, parent_id, fun) do
    case get_node(scene, parent_id) do
      {:ok, parent} ->
        updated = %{parent | children: fun.(parent.children)}
        :ets.insert(scene, {parent_id, updated})

      _ ->
        :ok
    end
  end

  defp update_root_children(scene, fun) do
    children = get_root_children(scene)
    :ets.insert(scene, {:__root_children__, fun.(children)})
  end

  defp insert_at_index(list, item, index) when index < 0, do: list ++ [item]
  defp insert_at_index(list, item, index), do: List.insert_at(list, index, item)
end
