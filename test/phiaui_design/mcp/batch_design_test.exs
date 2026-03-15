defmodule PhiaUiDesign.Mcp.BatchDesignTest do
  use ExUnit.Case, async: true

  alias PhiaUiDesign.Canvas.Scene
  alias PhiaUiDesign.Mcp.BatchDesign

  defp new_scene do
    scene = Scene.new()
    on_exit(fn -> try do Scene.destroy(scene) rescue _ -> :ok end end)
    scene
  end

  # ---------------------------------------------------------------------------
  # Insert operations
  # ---------------------------------------------------------------------------

  describe "insert (I)" do
    test "inserts a phia_component" do
      scene = new_scene()

      ops = [
        %{"op" => "I", "parent" => nil, "data" => %{
          "type" => "phia_component", "component" => "button",
          "slots" => %{"inner_block" => "Click"}
        }}
      ]

      assert {:ok, results, _bindings} = BatchDesign.execute(scene, ops)
      assert length(results) == 1
      assert hd(results)["op"] == "I"
      assert hd(results)["status"] == "ok"
      assert Scene.count(scene) == 1
    end

    test "inserts a frame" do
      scene = new_scene()

      ops = [
        %{"op" => "I", "parent" => nil, "data" => %{
          "type" => "frame", "name" => "Container"
        }}
      ]

      assert {:ok, [result], _} = BatchDesign.execute(scene, ops)
      assert result["status"] == "ok"

      {:ok, node} = Scene.get_node(scene, result["id"])
      assert node.type == :frame
      assert node.name == "Container"
    end

    test "inserts an HTML element" do
      scene = new_scene()

      ops = [
        %{"op" => "I", "parent" => nil, "data" => %{
          "type" => "html_element", "tag" => "section", "classes" => "flex gap-4"
        }}
      ]

      assert {:ok, [result], _} = BatchDesign.execute(scene, ops)
      {:ok, node} = Scene.get_node(scene, result["id"])
      assert node.type == :html_element
      assert node.tag == "section"
      assert node.classes == "flex gap-4"
    end

    test "inserts a text node" do
      scene = new_scene()

      ops = [
        %{"op" => "I", "parent" => nil, "data" => %{
          "type" => "text", "content" => "Hello world"
        }}
      ]

      assert {:ok, [result], _} = BatchDesign.execute(scene, ops)
      {:ok, node} = Scene.get_node(scene, result["id"])
      assert node.type == :text
      assert node.text_content == "Hello world"
    end

    test "inserts into parent using binding" do
      scene = new_scene()

      ops = [
        %{"op" => "I", "bind" => "card", "parent" => nil, "data" => %{
          "type" => "phia_component", "component" => "card"
        }},
        %{"op" => "I", "parent" => "$card", "data" => %{
          "type" => "phia_component", "component" => "button",
          "slots" => %{"inner_block" => "Click"}
        }}
      ]

      assert {:ok, results, bindings} = BatchDesign.execute(scene, ops)
      assert length(results) == 2
      assert Map.has_key?(bindings, "card")

      card_id = bindings["card"]
      {:ok, card} = Scene.get_node(scene, card_id)
      assert length(card.children) == 1
    end

    test "inserts frame with layout properties" do
      scene = new_scene()

      ops = [
        %{"op" => "I", "parent" => nil, "data" => %{
          "type" => "frame", "layout" => "vertical", "gap" => 16, "padding" => 24
        }}
      ]

      assert {:ok, [result], _} = BatchDesign.execute(scene, ops)
      {:ok, node} = Scene.get_node(scene, result["id"])
      assert node.layout == :vertical
      assert node.gap == 16
      assert node.padding == 24
    end
  end

  # ---------------------------------------------------------------------------
  # Update operations
  # ---------------------------------------------------------------------------

  describe "update (U)" do
    test "updates node attrs" do
      scene = new_scene()
      {:ok, btn} = Scene.insert_component(scene, :button, attrs: %{variant: :default})

      ops = [
        %{"op" => "U", "id" => btn.id, "data" => %{
          "attrs" => %{"variant" => ":destructive"}
        }}
      ]

      assert {:ok, [result], _} = BatchDesign.execute(scene, ops)
      assert result["status"] == "ok"

      {:ok, updated} = Scene.get_node(scene, btn.id)
      assert updated.attrs.variant == :destructive
    end

    test "updates node name" do
      scene = new_scene()
      {:ok, btn} = Scene.insert_component(scene, :button)

      ops = [
        %{"op" => "U", "id" => btn.id, "data" => %{"name" => "Primary CTA"}}
      ]

      assert {:ok, _, _} = BatchDesign.execute(scene, ops)
      {:ok, updated} = Scene.get_node(scene, btn.id)
      assert updated.name == "Primary CTA"
    end

    test "updates with binding reference" do
      scene = new_scene()

      ops = [
        %{"op" => "I", "bind" => "btn", "parent" => nil, "data" => %{
          "type" => "phia_component", "component" => "button"
        }},
        %{"op" => "U", "id" => "$btn", "data" => %{
          "attrs" => %{"variant" => ":outline"}
        }}
      ]

      assert {:ok, _, bindings} = BatchDesign.execute(scene, ops)
      {:ok, node} = Scene.get_node(scene, bindings["btn"])
      assert node.attrs.variant == :outline
    end

    test "error for missing node" do
      scene = new_scene()

      ops = [
        %{"op" => "U", "id" => "nonexistent", "data" => %{"name" => "X"}}
      ]

      assert {:error, msg, 0} = BatchDesign.execute(scene, ops)
      assert msg =~ "not found"
    end
  end

  # ---------------------------------------------------------------------------
  # Delete operations
  # ---------------------------------------------------------------------------

  describe "delete (D)" do
    test "deletes a node" do
      scene = new_scene()
      {:ok, btn} = Scene.insert_component(scene, :button)

      ops = [%{"op" => "D", "id" => btn.id}]

      assert {:ok, [result], _} = BatchDesign.execute(scene, ops)
      assert result["status"] == "ok"
      assert Scene.count(scene) == 0
    end

    test "error for missing node" do
      scene = new_scene()

      ops = [%{"op" => "D", "id" => "nonexistent"}]

      assert {:error, msg, 0} = BatchDesign.execute(scene, ops)
      assert msg =~ "not found"
    end
  end

  # ---------------------------------------------------------------------------
  # Copy operations
  # ---------------------------------------------------------------------------

  describe "copy (C)" do
    test "deep copies a node" do
      scene = new_scene()
      {:ok, card} = Scene.insert_component(scene, :card)
      {:ok, _hdr} = Scene.insert_component(scene, :card_header, parent_id: card.id)

      ops = [
        %{"op" => "C", "bind" => "copy", "id" => card.id, "parent" => nil}
      ]

      assert {:ok, [result], bindings} = BatchDesign.execute(scene, ops)
      assert result["status"] == "ok"

      copy_id = bindings["copy"]
      assert copy_id != card.id

      {:ok, copy} = Scene.get_node(scene, copy_id)
      assert copy.component == :card
      assert length(copy.children) == 1
    end

    test "copy with overrides" do
      scene = new_scene()
      {:ok, btn} = Scene.insert_component(scene, :button, attrs: %{variant: :default})

      ops = [
        %{"op" => "C", "bind" => "copy", "id" => btn.id, "parent" => nil,
          "data" => %{"attrs" => %{"variant" => ":destructive"}, "name" => "Danger Button"}}
      ]

      assert {:ok, _, bindings} = BatchDesign.execute(scene, ops)
      {:ok, copy} = Scene.get_node(scene, bindings["copy"])
      assert copy.attrs.variant == :destructive
      assert copy.name == "Danger Button"
    end
  end

  # ---------------------------------------------------------------------------
  # Move operations
  # ---------------------------------------------------------------------------

  describe "move (M)" do
    test "moves a node to a new parent" do
      scene = new_scene()
      {:ok, container} = Scene.insert_element(scene, "div")
      {:ok, btn} = Scene.insert_component(scene, :button)

      ops = [
        %{"op" => "M", "id" => btn.id, "parent" => container.id}
      ]

      assert {:ok, [result], _} = BatchDesign.execute(scene, ops)
      assert result["status"] == "ok"

      {:ok, updated_container} = Scene.get_node(scene, container.id)
      assert btn.id in updated_container.children
    end

    test "detects circular move" do
      scene = new_scene()
      {:ok, parent} = Scene.insert_element(scene, "div")
      {:ok, child} = Scene.insert_element(scene, "div", parent_id: parent.id)

      ops = [
        %{"op" => "M", "id" => parent.id, "parent" => child.id}
      ]

      assert {:error, msg, 0} = BatchDesign.execute(scene, ops)
      assert msg =~ "descendant"
    end
  end

  # ---------------------------------------------------------------------------
  # Replace operations
  # ---------------------------------------------------------------------------

  describe "replace (R)" do
    test "replaces a node with a new one" do
      scene = new_scene()
      {:ok, btn} = Scene.insert_component(scene, :button)

      ops = [
        %{"op" => "R", "bind" => "new", "id" => btn.id, "data" => %{
          "type" => "phia_component", "component" => "badge",
          "slots" => %{"inner_block" => "New"}
        }}
      ]

      assert {:ok, [result], bindings} = BatchDesign.execute(scene, ops)
      assert result["op"] == "R"

      # Old node gone
      assert {:error, :not_found} = Scene.get_node(scene, btn.id)

      # New node exists
      {:ok, new_node} = Scene.get_node(scene, bindings["new"])
      assert new_node.component == :badge
    end
  end

  # ---------------------------------------------------------------------------
  # Rollback
  # ---------------------------------------------------------------------------

  describe "rollback" do
    test "rolls back all changes on failure" do
      scene = new_scene()
      {:ok, _existing} = Scene.insert_component(scene, :button)

      ops = [
        %{"op" => "I", "parent" => nil, "data" => %{
          "type" => "phia_component", "component" => "badge"
        }},
        %{"op" => "U", "id" => "nonexistent-id", "data" => %{"name" => "X"}}
      ]

      assert {:error, _, 1} = BatchDesign.execute(scene, ops)

      # Scene should be back to original state (1 node)
      assert Scene.count(scene) == 1
    end
  end

  # ---------------------------------------------------------------------------
  # Limits
  # ---------------------------------------------------------------------------

  describe "limits" do
    test "rejects more than 25 operations" do
      scene = new_scene()

      ops = for _ <- 1..26 do
        %{"op" => "I", "parent" => nil, "data" => %{"type" => "frame"}}
      end

      assert {:error, msg, -1} = BatchDesign.execute(scene, ops)
      assert msg =~ "25"
    end

    test "accepts exactly 25 operations" do
      scene = new_scene()

      ops = for _ <- 1..25 do
        %{"op" => "I", "parent" => nil, "data" => %{"type" => "frame"}}
      end

      assert {:ok, results, _} = BatchDesign.execute(scene, ops)
      assert length(results) == 25
    end
  end

  # ---------------------------------------------------------------------------
  # Unknown operations
  # ---------------------------------------------------------------------------

  describe "unknown operations" do
    test "returns error for unknown op" do
      scene = new_scene()

      ops = [%{"op" => "X"}]

      assert {:error, msg, 0} = BatchDesign.execute(scene, ops)
      assert msg =~ "Unknown"
    end
  end
end
