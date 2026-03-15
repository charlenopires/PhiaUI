defmodule PhiaUiDesign.Mcp.BatchGetTest do
  use ExUnit.Case, async: true

  alias PhiaUiDesign.Canvas.Scene
  alias PhiaUiDesign.Mcp.BatchGet

  defp new_scene do
    scene = Scene.new()
    on_exit(fn -> try do Scene.destroy(scene) rescue _ -> :ok end end)
    scene
  end

  # ---------------------------------------------------------------------------
  # Pattern matching
  # ---------------------------------------------------------------------------

  describe "pattern matching" do
    test "matches by type" do
      scene = new_scene()
      {:ok, _btn} = Scene.insert_component(scene, :button)
      {:ok, _div} = Scene.insert_element(scene, "div")

      {:ok, results} = BatchGet.execute(scene, %{
        "patterns" => [%{"type" => "phia_component"}]
      })

      assert length(results) == 1
      assert hd(results)["type"] == "phia_component"
    end

    test "matches by component name" do
      scene = new_scene()
      {:ok, _btn} = Scene.insert_component(scene, :button)
      {:ok, _badge} = Scene.insert_component(scene, :badge)

      {:ok, results} = BatchGet.execute(scene, %{
        "patterns" => [%{"component" => "button"}]
      })

      assert length(results) == 1
      assert hd(results)["component"] == "button"
    end

    test "matches by name regex" do
      scene = new_scene()
      {:ok, _} = Scene.insert_element(scene, "aside", name: "Sidebar Nav")
      {:ok, _} = Scene.insert_element(scene, "main", name: "Main Content")

      {:ok, results} = BatchGet.execute(scene, %{
        "patterns" => [%{"name" => "Side.*"}]
      })

      assert length(results) == 1
      assert hd(results)["name"] == "Sidebar Nav"
    end

    test "matches multiple patterns (union)" do
      scene = new_scene()
      {:ok, _btn} = Scene.insert_component(scene, :button)
      {:ok, _badge} = Scene.insert_component(scene, :badge)
      {:ok, _div} = Scene.insert_element(scene, "div")

      {:ok, results} = BatchGet.execute(scene, %{
        "patterns" => [
          %{"component" => "button"},
          %{"component" => "badge"}
        ]
      })

      assert length(results) == 2
    end

    test "deduplicates results" do
      scene = new_scene()
      {:ok, btn} = Scene.insert_component(scene, :button, name: "button")

      {:ok, results} = BatchGet.execute(scene, %{
        "patterns" => [%{"component" => "button"}],
        "node_ids" => [btn.id]
      })

      assert length(results) == 1
    end
  end

  # ---------------------------------------------------------------------------
  # Node ID retrieval
  # ---------------------------------------------------------------------------

  describe "node_ids retrieval" do
    test "retrieves specific nodes by ID" do
      scene = new_scene()
      {:ok, btn} = Scene.insert_component(scene, :button)
      {:ok, _other} = Scene.insert_component(scene, :badge)

      {:ok, results} = BatchGet.execute(scene, %{
        "node_ids" => [btn.id]
      })

      assert length(results) == 1
      assert hd(results)["id"] == btn.id
    end

    test "ignores non-existent IDs" do
      scene = new_scene()

      {:ok, results} = BatchGet.execute(scene, %{
        "node_ids" => ["nonexistent"]
      })

      assert results == []
    end
  end

  # ---------------------------------------------------------------------------
  # Read depth
  # ---------------------------------------------------------------------------

  describe "read depth" do
    test "depth 0 truncates children" do
      scene = new_scene()
      {:ok, parent} = Scene.insert_element(scene, "div", name: "Parent")
      {:ok, _child} = Scene.insert_component(scene, :button, parent_id: parent.id)

      {:ok, results} = BatchGet.execute(scene, %{
        "node_ids" => [parent.id],
        "read_depth" => 0
      })

      assert length(results) == 1
      parent_result = hd(results)
      assert length(parent_result["children"]) == 1
      assert hd(parent_result["children"])["_truncated"] == true
    end

    test "depth 1 expands one level" do
      scene = new_scene()
      {:ok, parent} = Scene.insert_element(scene, "div", name: "Parent")
      {:ok, child} = Scene.insert_component(scene, :button, parent_id: parent.id)

      {:ok, results} = BatchGet.execute(scene, %{
        "node_ids" => [parent.id],
        "read_depth" => 1
      })

      parent_result = hd(results)
      assert length(parent_result["children"]) == 1
      child_result = hd(parent_result["children"])
      assert child_result["id"] == child.id
      refute Map.has_key?(child_result, "_truncated")
    end
  end

  # ---------------------------------------------------------------------------
  # Parent scope
  # ---------------------------------------------------------------------------

  describe "parent_id scope" do
    test "scopes search to subtree" do
      scene = new_scene()
      {:ok, container} = Scene.insert_element(scene, "div")
      {:ok, _inner_btn} = Scene.insert_component(scene, :button, parent_id: container.id)
      {:ok, _outer_btn} = Scene.insert_component(scene, :button)

      {:ok, results} = BatchGet.execute(scene, %{
        "patterns" => [%{"component" => "button"}],
        "parent_id" => container.id
      })

      # Only the button inside container
      assert length(results) == 1
    end
  end

  # ---------------------------------------------------------------------------
  # Empty queries
  # ---------------------------------------------------------------------------

  describe "empty queries" do
    test "returns empty for no patterns and no IDs" do
      scene = new_scene()
      {:ok, _} = Scene.insert_component(scene, :button)

      {:ok, results} = BatchGet.execute(scene, %{})

      assert results == []
    end
  end
end
