defmodule PhiaUiDesign.Canvas.SceneTest do
  # ETS tables are per-process and we create fresh ones each test,
  # so async: true is safe here (no shared named tables).
  use ExUnit.Case, async: true

  alias PhiaUiDesign.Canvas.{Scene, Node}

  # ---------------------------------------------------------------------------
  # Helper: create a scene and ensure cleanup
  # ---------------------------------------------------------------------------

  defp new_scene(_context \\ %{}) do
    scene = Scene.new()
    on_exit(fn -> try do Scene.destroy(scene) rescue _ -> :ok end end)
    scene
  end

  # ---------------------------------------------------------------------------
  # Scene.new/0
  # ---------------------------------------------------------------------------

  describe "new/0" do
    test "creates an ETS table reference" do
      scene = new_scene()

      assert is_reference(scene)
    end

    test "starts with zero nodes" do
      scene = new_scene()

      assert Scene.count(scene) == 0
    end

    test "starts with no root children" do
      scene = new_scene()

      assert Scene.get_root_children(scene) == []
    end

    test "stores metadata with default name" do
      scene = new_scene()

      [{:__meta__, meta}] = :ets.lookup(scene, :__meta__)
      assert meta.name == "Untitled"
      assert %DateTime{} = meta.created_at
    end
  end

  # ---------------------------------------------------------------------------
  # Scene.insert_component/3
  # ---------------------------------------------------------------------------

  describe "insert_component/3" do
    test "inserts a component node and returns {:ok, node}" do
      scene = new_scene()

      assert {:ok, %Node{} = node} = Scene.insert_component(scene, :button)
      assert node.type == :phia_component
      assert node.component == :button
    end

    test "stores attrs on the node" do
      scene = new_scene()

      {:ok, node} = Scene.insert_component(scene, :button, attrs: %{variant: :destructive})

      assert node.attrs == %{variant: :destructive}
    end

    test "stores slots on the node" do
      scene = new_scene()

      {:ok, node} = Scene.insert_component(scene, :button, slots: %{inner_block: "Click"})

      assert node.slots == %{inner_block: "Click"}
    end

    test "adds the node to root children when no parent_id" do
      scene = new_scene()

      {:ok, node} = Scene.insert_component(scene, :button)

      assert node.id in Scene.get_root_children(scene)
    end

    test "resolves module from the component registry" do
      scene = new_scene()

      {:ok, node} = Scene.insert_component(scene, :button)

      assert node.module == PhiaUi.Components.Button
    end

    test "uses the provided name" do
      scene = new_scene()

      {:ok, node} = Scene.insert_component(scene, :button, name: "Primary CTA")

      assert node.name == "Primary CTA"
    end

    test "defaults name to stringified component atom" do
      scene = new_scene()

      {:ok, node} = Scene.insert_component(scene, :button)

      assert node.name == "button"
    end

    test "adds node as child of parent when parent_id is given" do
      scene = new_scene()

      {:ok, parent} = Scene.insert_element(scene, "div")
      {:ok, child} = Scene.insert_component(scene, :button, parent_id: parent.id)

      assert child.parent_id == parent.id

      {:ok, updated_parent} = Scene.get_node(scene, parent.id)
      assert child.id in updated_parent.children
    end

    test "increments the scene count" do
      scene = new_scene()

      Scene.insert_component(scene, :button)
      Scene.insert_component(scene, :badge)

      assert Scene.count(scene) == 2
    end
  end

  # ---------------------------------------------------------------------------
  # Scene.insert_element/3
  # ---------------------------------------------------------------------------

  describe "insert_element/3" do
    test "inserts an HTML element node" do
      scene = new_scene()

      assert {:ok, %Node{} = node} = Scene.insert_element(scene, "div")
      assert node.type == :html_element
      assert node.tag == "div"
    end

    test "stores classes" do
      scene = new_scene()

      {:ok, node} = Scene.insert_element(scene, "div", classes: "flex gap-4")

      assert node.classes == "flex gap-4"
    end

    test "adds to root children by default" do
      scene = new_scene()

      {:ok, node} = Scene.insert_element(scene, "section")

      assert node.id in Scene.get_root_children(scene)
    end

    test "adds to parent when parent_id given" do
      scene = new_scene()

      {:ok, parent} = Scene.insert_element(scene, "div")
      {:ok, child} = Scene.insert_element(scene, "span", parent_id: parent.id)

      assert child.parent_id == parent.id
      {:ok, updated_parent} = Scene.get_node(scene, parent.id)
      assert child.id in updated_parent.children
    end

    test "uses tag as default name" do
      scene = new_scene()

      {:ok, node} = Scene.insert_element(scene, "main")

      assert node.name == "main"
    end
  end

  # ---------------------------------------------------------------------------
  # Scene.get_node/2
  # ---------------------------------------------------------------------------

  describe "get_node/2" do
    test "returns {:ok, node} for existing node" do
      scene = new_scene()
      {:ok, inserted} = Scene.insert_component(scene, :button)

      assert {:ok, %Node{} = found} = Scene.get_node(scene, inserted.id)
      assert found.id == inserted.id
      assert found.component == :button
    end

    test "returns {:error, :not_found} for missing ID" do
      scene = new_scene()

      assert {:error, :not_found} = Scene.get_node(scene, "nonexistent-id")
    end
  end

  # ---------------------------------------------------------------------------
  # Scene.update_attrs/3
  # ---------------------------------------------------------------------------

  describe "update_attrs/3" do
    test "merges new attrs into existing node attrs" do
      scene = new_scene()
      {:ok, node} = Scene.insert_component(scene, :button, attrs: %{variant: :default})

      {:ok, updated} = Scene.update_attrs(scene, node.id, %{variant: :destructive})

      assert updated.attrs.variant == :destructive
    end

    test "preserves existing attrs not in the changes" do
      scene = new_scene()
      {:ok, node} = Scene.insert_component(scene, :button, attrs: %{variant: :default, size: :lg})

      {:ok, updated} = Scene.update_attrs(scene, node.id, %{variant: :outline})

      assert updated.attrs.variant == :outline
      assert updated.attrs.size == :lg
    end

    test "adds new attrs that did not exist before" do
      scene = new_scene()
      {:ok, node} = Scene.insert_component(scene, :button, attrs: %{variant: :default})

      {:ok, updated} = Scene.update_attrs(scene, node.id, %{disabled: true})

      assert updated.attrs.disabled == true
      assert updated.attrs.variant == :default
    end

    test "persists the update in ETS" do
      scene = new_scene()
      {:ok, node} = Scene.insert_component(scene, :button, attrs: %{variant: :default})

      Scene.update_attrs(scene, node.id, %{variant: :ghost})

      {:ok, fetched} = Scene.get_node(scene, node.id)
      assert fetched.attrs.variant == :ghost
    end

    test "returns {:error, :not_found} for missing node" do
      scene = new_scene()

      assert {:error, :not_found} = Scene.update_attrs(scene, "missing", %{variant: :ghost})
    end
  end

  # ---------------------------------------------------------------------------
  # Scene.update_node/3
  # ---------------------------------------------------------------------------

  describe "update_node/3" do
    test "merges changes into the node struct" do
      scene = new_scene()
      {:ok, node} = Scene.insert_component(scene, :button)

      {:ok, updated} = Scene.update_node(scene, node.id, %{locked: true, name: "Locked Button"})

      assert updated.locked == true
      assert updated.name == "Locked Button"
    end

    test "persists the update in ETS" do
      scene = new_scene()
      {:ok, node} = Scene.insert_component(scene, :button)

      Scene.update_node(scene, node.id, %{visible: false})

      {:ok, fetched} = Scene.get_node(scene, node.id)
      assert fetched.visible == false
    end

    test "returns {:error, :not_found} for missing node" do
      scene = new_scene()

      assert {:error, :not_found} = Scene.update_node(scene, "missing", %{locked: true})
    end
  end

  # ---------------------------------------------------------------------------
  # Scene.delete_node/2
  # ---------------------------------------------------------------------------

  describe "delete_node/2" do
    test "removes a root-level node" do
      scene = new_scene()
      {:ok, node} = Scene.insert_component(scene, :button)

      assert :ok = Scene.delete_node(scene, node.id)

      assert {:error, :not_found} = Scene.get_node(scene, node.id)
      assert Scene.count(scene) == 0
    end

    test "removes the node from root children" do
      scene = new_scene()
      {:ok, node} = Scene.insert_component(scene, :button)

      Scene.delete_node(scene, node.id)

      refute node.id in Scene.get_root_children(scene)
    end

    test "removes a child node from its parent children list" do
      scene = new_scene()
      {:ok, parent} = Scene.insert_element(scene, "div")
      {:ok, child} = Scene.insert_component(scene, :button, parent_id: parent.id)

      Scene.delete_node(scene, child.id)

      {:ok, updated_parent} = Scene.get_node(scene, parent.id)
      refute child.id in updated_parent.children
    end

    test "recursively deletes children" do
      scene = new_scene()
      {:ok, parent} = Scene.insert_element(scene, "div")
      {:ok, child} = Scene.insert_component(scene, :button, parent_id: parent.id)

      # Delete the parent — child should also be gone
      Scene.delete_node(scene, parent.id)

      assert {:error, :not_found} = Scene.get_node(scene, child.id)
      assert Scene.count(scene) == 0
    end

    test "returns {:error, :not_found} for missing node" do
      scene = new_scene()

      assert {:error, :not_found} = Scene.delete_node(scene, "missing")
    end
  end

  # ---------------------------------------------------------------------------
  # Scene.move_node/4
  # ---------------------------------------------------------------------------

  describe "move_node/4" do
    test "moves a root node into a parent" do
      scene = new_scene()
      {:ok, container} = Scene.insert_element(scene, "div")
      {:ok, btn} = Scene.insert_component(scene, :button)

      {:ok, moved} = Scene.move_node(scene, btn.id, container.id)

      assert moved.parent_id == container.id

      {:ok, updated_container} = Scene.get_node(scene, container.id)
      assert btn.id in updated_container.children

      refute btn.id in Scene.get_root_children(scene)
    end

    test "moves a child node to a different parent" do
      scene = new_scene()
      {:ok, parent_a} = Scene.insert_element(scene, "div")
      {:ok, parent_b} = Scene.insert_element(scene, "section")
      {:ok, child} = Scene.insert_component(scene, :button, parent_id: parent_a.id)

      {:ok, moved} = Scene.move_node(scene, child.id, parent_b.id)

      assert moved.parent_id == parent_b.id

      {:ok, updated_a} = Scene.get_node(scene, parent_a.id)
      refute child.id in updated_a.children

      {:ok, updated_b} = Scene.get_node(scene, parent_b.id)
      assert child.id in updated_b.children
    end

    test "moves a child to root (nil parent)" do
      scene = new_scene()
      {:ok, parent} = Scene.insert_element(scene, "div")
      {:ok, child} = Scene.insert_component(scene, :button, parent_id: parent.id)

      {:ok, moved} = Scene.move_node(scene, child.id, nil)

      assert moved.parent_id == nil
      assert child.id in Scene.get_root_children(scene)
    end

    test "moves a node to a specific index" do
      scene = new_scene()
      {:ok, container} = Scene.insert_element(scene, "div")
      {:ok, child_a} = Scene.insert_component(scene, :button, parent_id: container.id)
      {:ok, child_b} = Scene.insert_component(scene, :badge, parent_id: container.id)

      # Now insert a new node at index 0 (before child_a)
      {:ok, new_node} = Scene.insert_component(scene, :input)
      Scene.move_node(scene, new_node.id, container.id, 0)

      {:ok, updated_container} = Scene.get_node(scene, container.id)
      assert hd(updated_container.children) == new_node.id
      assert child_a.id in updated_container.children
      assert child_b.id in updated_container.children
    end

    test "moves to end when index is -1 (default)" do
      scene = new_scene()
      {:ok, container} = Scene.insert_element(scene, "div")
      {:ok, _child_a} = Scene.insert_component(scene, :button, parent_id: container.id)

      {:ok, new_node} = Scene.insert_component(scene, :badge)
      Scene.move_node(scene, new_node.id, container.id)

      {:ok, updated_container} = Scene.get_node(scene, container.id)
      assert List.last(updated_container.children) == new_node.id
    end

    test "returns {:error, :not_found} for missing node" do
      scene = new_scene()
      {:ok, container} = Scene.insert_element(scene, "div")

      assert {:error, :not_found} = Scene.move_node(scene, "missing", container.id)
    end
  end

  # ---------------------------------------------------------------------------
  # Scene.to_tree/1
  # ---------------------------------------------------------------------------

  describe "to_tree/1" do
    test "returns empty list for empty scene" do
      scene = new_scene()

      assert Scene.to_tree(scene) == []
    end

    test "returns flat list for root-level nodes" do
      scene = new_scene()
      {:ok, btn} = Scene.insert_component(scene, :button)

      tree = Scene.to_tree(scene)

      assert length(tree) == 1
      assert %{node: %Node{id: id}, children: []} = hd(tree)
      assert id == btn.id
    end

    test "nests children under their parent" do
      scene = new_scene()
      {:ok, parent} = Scene.insert_element(scene, "div")
      {:ok, child} = Scene.insert_component(scene, :button, parent_id: parent.id)

      tree = Scene.to_tree(scene)

      assert length(tree) == 1

      root = hd(tree)
      assert root.node.id == parent.id
      assert length(root.children) == 1
      assert hd(root.children).node.id == child.id
    end

    test "handles deeply nested trees" do
      scene = new_scene()
      {:ok, l1} = Scene.insert_element(scene, "div")
      {:ok, l2} = Scene.insert_element(scene, "section", parent_id: l1.id)
      {:ok, l3} = Scene.insert_component(scene, :button, parent_id: l2.id)

      tree = Scene.to_tree(scene)

      assert length(tree) == 1
      level1 = hd(tree)
      assert level1.node.id == l1.id

      level2 = hd(level1.children)
      assert level2.node.id == l2.id

      level3 = hd(level2.children)
      assert level3.node.id == l3.id
      assert level3.children == []
    end

    test "preserves sibling order" do
      scene = new_scene()
      {:ok, parent} = Scene.insert_element(scene, "div")
      {:ok, first} = Scene.insert_component(scene, :button, parent_id: parent.id)
      {:ok, second} = Scene.insert_component(scene, :badge, parent_id: parent.id)

      tree = Scene.to_tree(scene)
      children = hd(tree).children
      child_ids = Enum.map(children, & &1.node.id)

      assert child_ids == [first.id, second.id]
    end
  end

  # ---------------------------------------------------------------------------
  # Scene.all_nodes/1
  # ---------------------------------------------------------------------------

  describe "all_nodes/1" do
    test "returns all nodes as a flat list" do
      scene = new_scene()
      {:ok, _} = Scene.insert_component(scene, :button)
      {:ok, _} = Scene.insert_element(scene, "div")

      nodes = Scene.all_nodes(scene)

      assert length(nodes) == 2
      assert Enum.all?(nodes, &match?(%Node{}, &1))
    end

    test "returns empty list for empty scene" do
      scene = new_scene()

      assert Scene.all_nodes(scene) == []
    end

    test "excludes metadata entries" do
      scene = new_scene()
      {:ok, _} = Scene.insert_component(scene, :button)

      nodes = Scene.all_nodes(scene)

      # Only actual Node structs, not :__root_children__ or :__meta__
      assert length(nodes) == 1
    end
  end

  # ---------------------------------------------------------------------------
  # Scene.components_used/1
  # ---------------------------------------------------------------------------

  describe "components_used/1" do
    test "returns unique component names in the scene" do
      scene = new_scene()
      Scene.insert_component(scene, :button)
      Scene.insert_component(scene, :badge)
      Scene.insert_component(scene, :button)

      used = Scene.components_used(scene)

      assert :button in used
      assert :badge in used
      assert length(used) == 2
    end

    test "returns empty list for empty scene" do
      scene = new_scene()

      assert Scene.components_used(scene) == []
    end

    test "excludes HTML element nodes" do
      scene = new_scene()
      Scene.insert_component(scene, :button)
      Scene.insert_element(scene, "div")

      used = Scene.components_used(scene)

      assert used == [:button]
    end
  end

  # ---------------------------------------------------------------------------
  # Scene.hooks_needed/1
  # ---------------------------------------------------------------------------

  describe "hooks_needed/1" do
    test "returns JS hooks from the component registry" do
      scene = new_scene()
      Scene.insert_component(scene, :dialog)

      hooks = Scene.hooks_needed(scene)

      # dialog has ["PhiaFocusTrap", "PhiaDialog"] hooks per the registry
      assert "PhiaFocusTrap" in hooks
      assert "PhiaDialog" in hooks
    end

    test "returns empty list when no components need hooks" do
      scene = new_scene()
      Scene.insert_component(scene, :button)

      hooks = Scene.hooks_needed(scene)

      assert hooks == []
    end

    test "deduplicates hooks across components" do
      scene = new_scene()
      # dialog has PhiaFocusTrap, sheet also has PhiaFocusTrap
      Scene.insert_component(scene, :dialog)
      Scene.insert_component(scene, :sheet)

      hooks = Scene.hooks_needed(scene)

      # PhiaFocusTrap should appear only once
      assert length(Enum.filter(hooks, &(&1 == "PhiaFocusTrap"))) == 1
    end

    test "returns empty list for empty scene" do
      scene = new_scene()

      assert Scene.hooks_needed(scene) == []
    end
  end

  # ---------------------------------------------------------------------------
  # Scene.count/1
  # ---------------------------------------------------------------------------

  describe "count/1" do
    test "returns zero for empty scene" do
      scene = new_scene()

      assert Scene.count(scene) == 0
    end

    test "returns correct count after inserts" do
      scene = new_scene()
      Scene.insert_component(scene, :button)
      Scene.insert_element(scene, "div")
      Scene.insert_component(scene, :badge)

      assert Scene.count(scene) == 3
    end

    test "returns correct count after deletes" do
      scene = new_scene()
      {:ok, node} = Scene.insert_component(scene, :button)
      Scene.insert_component(scene, :badge)
      Scene.delete_node(scene, node.id)

      assert Scene.count(scene) == 1
    end
  end

  # ---------------------------------------------------------------------------
  # Scene.destroy/1
  # ---------------------------------------------------------------------------

  describe "destroy/1" do
    test "deletes the ETS table and returns :ok" do
      scene = Scene.new()

      assert :ok = Scene.destroy(scene)

      # Table should no longer exist
      assert_raise ArgumentError, fn ->
        :ets.lookup(scene, :__meta__)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Scene.insert/2 (direct node insertion)
  # ---------------------------------------------------------------------------

  describe "insert/2" do
    test "inserts a raw Node struct" do
      scene = new_scene()
      node = Node.new_component(:button, id: "raw-node")

      assert {:ok, ^node} = Scene.insert(scene, node)
      assert {:ok, fetched} = Scene.get_node(scene, "raw-node")
      assert fetched.component == :button
    end

    test "adds to root when node has no parent_id" do
      scene = new_scene()
      node = Node.new_text("hello", id: "text-node")

      Scene.insert(scene, node)

      assert "text-node" in Scene.get_root_children(scene)
    end

    test "adds to parent children when node has parent_id" do
      scene = new_scene()
      {:ok, parent} = Scene.insert_element(scene, "div")
      child = Node.new_text("hello", id: "child-text", parent_id: parent.id)

      Scene.insert(scene, child)

      {:ok, updated_parent} = Scene.get_node(scene, parent.id)
      assert "child-text" in updated_parent.children
    end
  end
end
