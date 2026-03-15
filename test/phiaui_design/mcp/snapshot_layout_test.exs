defmodule PhiaUiDesign.Mcp.SnapshotLayoutTest do
  use ExUnit.Case, async: true

  alias PhiaUiDesign.Canvas.{Scene, Node}
  alias PhiaUiDesign.Mcp.SnapshotLayout

  defp new_scene do
    scene = Scene.new()
    on_exit(fn -> try do Scene.destroy(scene) rescue _ -> :ok end end)
    scene
  end

  # ---------------------------------------------------------------------------
  # Basic computation
  # ---------------------------------------------------------------------------

  describe "basic bounding boxes" do
    test "empty scene returns empty list" do
      scene = new_scene()

      assert {:ok, []} = SnapshotLayout.execute(scene)
    end

    test "single component returns estimated bbox" do
      scene = new_scene()
      {:ok, _btn} = Scene.insert_component(scene, :button)

      {:ok, tree} = SnapshotLayout.execute(scene)

      assert length(tree) == 1
      entry = hd(tree)
      assert entry.bbox.x == 0
      assert entry.bbox.y == 0
      assert entry.bbox.width > 0
      assert entry.bbox.height > 0
    end

    test "multiple root nodes are stacked vertically" do
      scene = new_scene()
      {:ok, _btn1} = Scene.insert_component(scene, :button)
      {:ok, _btn2} = Scene.insert_component(scene, :button)

      {:ok, tree} = SnapshotLayout.execute(scene)

      assert length(tree) == 2
      [first, second] = tree
      assert second.bbox.y > first.bbox.y
    end
  end

  # ---------------------------------------------------------------------------
  # Layout properties
  # ---------------------------------------------------------------------------

  describe "layout properties" do
    test "vertical layout stacks children" do
      scene = new_scene()

      frame = Node.new_frame(
        layout: :vertical,
        gap: 16,
        padding: 8
      )
      {:ok, _} = Scene.insert(scene, frame)

      {:ok, btn1} = Scene.insert_component(scene, :button, parent_id: frame.id)
      {:ok, btn2} = Scene.insert_component(scene, :button, parent_id: frame.id)

      {:ok, tree} = SnapshotLayout.execute(scene, %{"max_depth" => 2})

      assert length(tree) == 1
      parent = hd(tree)
      assert length(parent.children) == 2

      [child1, child2] = parent.children
      # Second child should be below first with gap
      assert child2.bbox.y > child1.bbox.y
    end

    test "horizontal layout stacks children side by side" do
      scene = new_scene()

      frame = Node.new_frame(
        layout: :horizontal,
        gap: 16
      )
      {:ok, _} = Scene.insert(scene, frame)

      {:ok, _} = Scene.insert_component(scene, :button, parent_id: frame.id)
      {:ok, _} = Scene.insert_component(scene, :button, parent_id: frame.id)

      {:ok, tree} = SnapshotLayout.execute(scene, %{"max_depth" => 2})

      parent = hd(tree)
      [child1, child2] = parent.children
      assert child2.bbox.x > child1.bbox.x
    end

    test "width: fill uses container width" do
      scene = new_scene()

      frame = Node.new_frame(width: :fill)
      {:ok, _} = Scene.insert(scene, frame)

      {:ok, tree} = SnapshotLayout.execute(scene, %{"viewport_width" => 800})

      assert hd(tree).bbox.width == 800
    end
  end

  # ---------------------------------------------------------------------------
  # Problem detection
  # ---------------------------------------------------------------------------

  describe "problem detection" do
    test "detects missing layout on frame with children" do
      scene = new_scene()

      frame = Node.new_frame()
      {:ok, _} = Scene.insert(scene, frame)
      {:ok, _} = Scene.insert_component(scene, :button, parent_id: frame.id)

      {:ok, tree} = SnapshotLayout.execute(scene, %{"max_depth" => 2})

      parent = hd(tree)
      assert "missing-layout: frame has children but no layout direction" in parent.problems
    end

    test "problems_only filters non-problematic nodes" do
      scene = new_scene()
      {:ok, _btn} = Scene.insert_component(scene, :button)

      {:ok, tree} = SnapshotLayout.execute(scene, %{"problems_only" => true})

      # A simple button with no problems should be filtered out
      assert tree == []
    end
  end

  # ---------------------------------------------------------------------------
  # Options
  # ---------------------------------------------------------------------------

  describe "options" do
    test "max_depth limits recursion" do
      scene = new_scene()

      frame = Node.new_frame(layout: :vertical)
      {:ok, _} = Scene.insert(scene, frame)
      {:ok, _} = Scene.insert_component(scene, :button, parent_id: frame.id)

      {:ok, tree_shallow} = SnapshotLayout.execute(scene, %{"max_depth" => 0})
      parent = hd(tree_shallow)
      refute Map.has_key?(parent, :children)
    end

    test "parent_id scopes to subtree" do
      scene = new_scene()
      {:ok, container} = Scene.insert_element(scene, "div")
      {:ok, _btn} = Scene.insert_component(scene, :button, parent_id: container.id)
      {:ok, _other} = Scene.insert_component(scene, :badge)

      {:ok, tree} = SnapshotLayout.execute(scene, %{
        "parent_id" => container.id,
        "max_depth" => 1
      })

      # Only children of container
      assert length(tree) == 1
      assert hd(tree).type == "phia_component"
    end

    test "custom viewport width" do
      scene = new_scene()
      {:ok, _div} = Scene.insert_element(scene, "div")

      {:ok, tree} = SnapshotLayout.execute(scene, %{"viewport_width" => 600})

      assert hd(tree).bbox.width == 600
    end
  end
end
