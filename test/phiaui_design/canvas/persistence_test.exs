defmodule PhiaUiDesign.Canvas.PersistenceTest do
  use ExUnit.Case, async: true

  alias PhiaUiDesign.Canvas.{Scene, Node, Persistence}

  # ---------------------------------------------------------------------------
  # Helper: create a scene and ensure cleanup
  # ---------------------------------------------------------------------------

  defp new_scene(_context \\ %{}) do
    scene = Scene.new()
    on_exit(fn -> try do Scene.destroy(scene) rescue _ -> :ok end end)
    scene
  end

  defp tmp_path(suffix) do
    dir = System.tmp_dir!()
    name = "phiaui_test_#{System.unique_integer([:positive])}_#{suffix}.phia.json"
    path = Path.join(dir, name)
    on_exit(fn -> File.rm(path) end)
    path
  end

  defp tmp_dir do
    dir = Path.join(System.tmp_dir!(), "phiaui_test_#{System.unique_integer([:positive])}")
    File.mkdir_p!(dir)
    on_exit(fn -> File.rm_rf(dir) end)
    dir
  end

  # ---------------------------------------------------------------------------
  # save/3 — basic
  # ---------------------------------------------------------------------------

  describe "save/3" do
    test "saves an empty scene to a file and returns :ok" do
      scene = new_scene()
      path = tmp_path("empty")

      assert :ok = Persistence.save(scene, path)
      assert File.exists?(path)
    end

    test "saves a scene with a single component" do
      scene = new_scene()
      Scene.insert_component(scene, :button, attrs: %{variant: :destructive})
      path = tmp_path("single")

      assert :ok = Persistence.save(scene, path)

      {:ok, content} = File.read(path)
      data = Jason.decode!(content)
      assert data["version"] == 1
      assert length(data["nodes"]) == 1
    end

    test "saves theme option as string in JSON" do
      scene = new_scene()
      path = tmp_path("theme")

      assert :ok = Persistence.save(scene, path, theme: :rose)

      {:ok, content} = File.read(path)
      data = Jason.decode!(content)
      assert data["theme"] == "rose"
    end

    test "defaults theme to zinc when not specified" do
      scene = new_scene()
      path = tmp_path("default_theme")

      assert :ok = Persistence.save(scene, path)

      {:ok, content} = File.read(path)
      data = Jason.decode!(content)
      assert data["theme"] == "zinc"
    end

    test "saves node attrs and slots" do
      scene = new_scene()

      Scene.insert_component(scene, :button,
        attrs: %{variant: :outline, size: :lg},
        slots: %{inner_block: "Click me"}
      )

      path = tmp_path("attrs")
      assert :ok = Persistence.save(scene, path)

      {:ok, content} = File.read(path)
      data = Jason.decode!(content)
      node = hd(data["nodes"])
      assert node["attrs"]["variant"] == ":outline"
      assert node["attrs"]["size"] == ":lg"
      assert node["slots"]["inner_block"] == "Click me"
    end

    test "saves parent-child relationships" do
      scene = new_scene()
      {:ok, parent} = Scene.insert_element(scene, "div")
      {:ok, child} = Scene.insert_component(scene, :button, parent_id: parent.id)

      path = tmp_path("parent_child")
      assert :ok = Persistence.save(scene, path)

      {:ok, content} = File.read(path)
      data = Jason.decode!(content)
      assert length(data["nodes"]) == 2

      parent_data = Enum.find(data["nodes"], &(&1["id"] == parent.id))
      child_data = Enum.find(data["nodes"], &(&1["id"] == child.id))

      assert child.id in parent_data["children"]
      assert child_data["parent_id"] == parent.id
    end

    test "creates parent directories if they do not exist" do
      scene = new_scene()
      nested_dir = Path.join(System.tmp_dir!(), "phiaui_nested_#{System.unique_integer([:positive])}")
      path = Path.join(nested_dir, "deep/project.phia.json")
      on_exit(fn -> File.rm_rf(nested_dir) end)

      assert :ok = Persistence.save(scene, path)
      assert File.exists?(path)
    end

    test "saves root_children list" do
      scene = new_scene()
      {:ok, btn1} = Scene.insert_component(scene, :button)
      {:ok, btn2} = Scene.insert_component(scene, :badge)

      path = tmp_path("root_children")
      assert :ok = Persistence.save(scene, path)

      {:ok, content} = File.read(path)
      data = Jason.decode!(content)
      assert btn1.id in data["root_children"]
      assert btn2.id in data["root_children"]
    end

    test "saves node locked and visible flags" do
      scene = new_scene()
      {:ok, node} = Scene.insert_component(scene, :button)
      Scene.update_node(scene, node.id, %{locked: true, visible: false})

      path = tmp_path("flags")
      assert :ok = Persistence.save(scene, path)

      {:ok, content} = File.read(path)
      data = Jason.decode!(content)
      node_data = hd(data["nodes"])
      assert node_data["locked"] == true
      assert node_data["visible"] == false
    end
  end

  # ---------------------------------------------------------------------------
  # load/1 — basic
  # ---------------------------------------------------------------------------

  describe "load/1" do
    test "loads a saved scene and returns {:ok, scene, metadata}" do
      scene = new_scene()
      Scene.insert_component(scene, :button, attrs: %{variant: :outline})
      path = tmp_path("load_basic")

      Persistence.save(scene, path, theme: :rose)

      {:ok, loaded_scene, metadata} = Persistence.load(path)
      on_exit(fn -> try do Scene.destroy(loaded_scene) rescue _ -> :ok end end)

      assert is_reference(loaded_scene)
      assert metadata.theme == :rose
      assert metadata.name == "Untitled"
      assert metadata.version == 1
    end

    test "loaded scene has the same number of nodes" do
      scene = new_scene()
      Scene.insert_component(scene, :button)
      Scene.insert_component(scene, :badge)
      Scene.insert_component(scene, :card)
      path = tmp_path("load_count")

      Persistence.save(scene, path)
      {:ok, loaded_scene, _meta} = Persistence.load(path)
      on_exit(fn -> try do Scene.destroy(loaded_scene) rescue _ -> :ok end end)

      assert Scene.count(loaded_scene) == 3
    end

    test "loaded nodes preserve component type and name" do
      scene = new_scene()
      {:ok, original} = Scene.insert_component(scene, :button, name: "Primary CTA")
      path = tmp_path("load_type")

      Persistence.save(scene, path)
      {:ok, loaded_scene, _meta} = Persistence.load(path)
      on_exit(fn -> try do Scene.destroy(loaded_scene) rescue _ -> :ok end end)

      {:ok, loaded_node} = Scene.get_node(loaded_scene, original.id)
      assert loaded_node.type == :phia_component
      assert loaded_node.component == :button
      assert loaded_node.name == "Primary CTA"
    end

    test "loaded nodes preserve attrs" do
      scene = new_scene()

      {:ok, original} =
        Scene.insert_component(scene, :button,
          attrs: %{variant: :destructive, disabled: true}
        )

      path = tmp_path("load_attrs")
      Persistence.save(scene, path)

      {:ok, loaded_scene, _meta} = Persistence.load(path)
      on_exit(fn -> try do Scene.destroy(loaded_scene) rescue _ -> :ok end end)

      {:ok, loaded_node} = Scene.get_node(loaded_scene, original.id)
      assert loaded_node.attrs[:variant] == :destructive
      assert loaded_node.attrs[:disabled] == true
    end

    test "loaded nodes preserve slots" do
      scene = new_scene()

      {:ok, original} =
        Scene.insert_component(scene, :button,
          slots: %{inner_block: "Click me"}
        )

      path = tmp_path("load_slots")
      Persistence.save(scene, path)

      {:ok, loaded_scene, _meta} = Persistence.load(path)
      on_exit(fn -> try do Scene.destroy(loaded_scene) rescue _ -> :ok end end)

      {:ok, loaded_node} = Scene.get_node(loaded_scene, original.id)
      assert loaded_node.slots[:inner_block] == "Click me"
    end

    test "loaded nodes preserve parent-child relationships" do
      scene = new_scene()
      {:ok, parent} = Scene.insert_element(scene, "div")
      {:ok, child} = Scene.insert_component(scene, :button, parent_id: parent.id)
      path = tmp_path("load_tree")

      Persistence.save(scene, path)
      {:ok, loaded_scene, _meta} = Persistence.load(path)
      on_exit(fn -> try do Scene.destroy(loaded_scene) rescue _ -> :ok end end)

      {:ok, loaded_parent} = Scene.get_node(loaded_scene, parent.id)
      {:ok, loaded_child} = Scene.get_node(loaded_scene, child.id)

      assert child.id in loaded_parent.children
      assert loaded_child.parent_id == parent.id
    end

    test "returns error for nonexistent file" do
      assert {:error, :enoent} = Persistence.load("/tmp/nonexistent_file.phia.json")
    end

    test "returns error for invalid JSON" do
      path = tmp_path("invalid_json")
      File.write!(path, "not valid json {{{")

      assert {:error, _} = Persistence.load(path)
    end

    test "loaded scene preserves root_children order" do
      scene = new_scene()
      {:ok, btn1} = Scene.insert_component(scene, :button, name: "First")
      {:ok, btn2} = Scene.insert_component(scene, :badge, name: "Second")
      path = tmp_path("load_order")

      Persistence.save(scene, path)
      {:ok, loaded_scene, _meta} = Persistence.load(path)
      on_exit(fn -> try do Scene.destroy(loaded_scene) rescue _ -> :ok end end)

      root_children = Scene.get_root_children(loaded_scene)
      assert root_children == [btn1.id, btn2.id]
    end

    test "preserves locked and visible flags on load" do
      scene = new_scene()
      {:ok, node} = Scene.insert_component(scene, :button)
      Scene.update_node(scene, node.id, %{locked: true, visible: false})
      path = tmp_path("load_flags")

      Persistence.save(scene, path)
      {:ok, loaded_scene, _meta} = Persistence.load(path)
      on_exit(fn -> try do Scene.destroy(loaded_scene) rescue _ -> :ok end end)

      {:ok, loaded_node} = Scene.get_node(loaded_scene, node.id)
      assert loaded_node.locked == true
      assert loaded_node.visible == false
    end
  end

  # ---------------------------------------------------------------------------
  # Round-trip: save then load
  # ---------------------------------------------------------------------------

  describe "round-trip save/load" do
    test "complex scene survives round-trip" do
      scene = new_scene()

      {:ok, root} = Scene.insert_element(scene, "div", classes: "flex gap-4")
      {:ok, btn} = Scene.insert_component(scene, :button,
        attrs: %{variant: :outline, size: :sm},
        slots: %{inner_block: "Save"},
        parent_id: root.id,
        name: "Save Button"
      )
      {:ok, badge} = Scene.insert_component(scene, :badge,
        attrs: %{variant: :secondary},
        slots: %{inner_block: "New"},
        parent_id: root.id,
        name: "Status Badge"
      )

      path = tmp_path("roundtrip")
      Persistence.save(scene, path, theme: :violet)

      {:ok, loaded_scene, meta} = Persistence.load(path)
      on_exit(fn -> try do Scene.destroy(loaded_scene) rescue _ -> :ok end end)

      # Metadata
      assert meta.theme == :violet

      # Node count
      assert Scene.count(loaded_scene) == 3

      # Root structure
      root_children = Scene.get_root_children(loaded_scene)
      assert root_children == [root.id]

      # Parent's children
      {:ok, loaded_root} = Scene.get_node(loaded_scene, root.id)
      assert loaded_root.type == :html_element
      assert loaded_root.tag == "div"
      assert loaded_root.classes == "flex gap-4"
      assert btn.id in loaded_root.children
      assert badge.id in loaded_root.children

      # Child nodes
      {:ok, loaded_btn} = Scene.get_node(loaded_scene, btn.id)
      assert loaded_btn.component == :button
      assert loaded_btn.attrs[:variant] == :outline
      assert loaded_btn.attrs[:size] == :sm
      assert loaded_btn.slots[:inner_block] == "Save"
      assert loaded_btn.name == "Save Button"
      assert loaded_btn.parent_id == root.id
    end
  end

  # ---------------------------------------------------------------------------
  # list_projects/1
  # ---------------------------------------------------------------------------

  describe "list_projects/1" do
    test "returns empty list for directory with no .phia.json files" do
      dir = tmp_dir()

      assert Persistence.list_projects(dir) == []
    end

    test "returns empty list for nonexistent directory" do
      assert Persistence.list_projects("/tmp/nonexistent_dir_abc123") == []
    end

    test "lists all .phia.json files with metadata" do
      dir = tmp_dir()

      # Save two projects
      scene1 = new_scene()
      Scene.insert_component(scene1, :button)
      Scene.insert_component(scene1, :badge)
      path1 = Path.join(dir, "project_a.phia.json")
      Persistence.save(scene1, path1, theme: :zinc)

      scene2 = new_scene()
      Scene.insert_component(scene2, :card)
      path2 = Path.join(dir, "project_b.phia.json")
      Persistence.save(scene2, path2, theme: :rose)

      projects = Persistence.list_projects(dir)
      assert length(projects) == 2

      # Sort by path for deterministic comparison
      sorted = Enum.sort_by(projects, & &1.path)
      [proj_a, proj_b] = sorted

      assert proj_a.path == path1
      assert proj_a.node_count == 2
      assert proj_a.theme == "zinc"

      assert proj_b.path == path2
      assert proj_b.node_count == 1
      assert proj_b.theme == "rose"
    end

    test "skips invalid JSON files" do
      dir = tmp_dir()

      # Create a valid project
      scene = new_scene()
      Scene.insert_component(scene, :button)
      path = Path.join(dir, "valid.phia.json")
      Persistence.save(scene, path)

      # Create an invalid file
      invalid_path = Path.join(dir, "broken.phia.json")
      File.write!(invalid_path, "{not valid json")

      projects = Persistence.list_projects(dir)
      assert length(projects) == 1
      assert hd(projects).path == path
    end

    test "uses filename as fallback name when name key is missing" do
      dir = tmp_dir()

      # Write a minimal JSON without a name key
      path = Path.join(dir, "no_name.phia.json")
      data = %{"version" => 1, "nodes" => [], "root_children" => []}
      File.write!(path, Jason.encode!(data))

      projects = Persistence.list_projects(dir)
      assert length(projects) == 1
      assert hd(projects).name == "no_name"
    end
  end

  # ---------------------------------------------------------------------------
  # Serialization edge cases
  # ---------------------------------------------------------------------------

  describe "serialization edge cases" do
    test "handles HTML element nodes" do
      scene = new_scene()
      {:ok, div} = Scene.insert_element(scene, "div", classes: "flex gap-4")
      path = tmp_path("html_element")

      Persistence.save(scene, path)
      {:ok, loaded_scene, _meta} = Persistence.load(path)
      on_exit(fn -> try do Scene.destroy(loaded_scene) rescue _ -> :ok end end)

      {:ok, loaded_div} = Scene.get_node(loaded_scene, div.id)
      assert loaded_div.type == :html_element
      assert loaded_div.tag == "div"
      assert loaded_div.classes == "flex gap-4"
    end

    test "handles text nodes" do
      scene = new_scene()
      text_node = Node.new_text("Hello world", name: "Greeting")
      Scene.insert(scene, text_node)
      path = tmp_path("text_node")

      Persistence.save(scene, path)
      {:ok, loaded_scene, _meta} = Persistence.load(path)
      on_exit(fn -> try do Scene.destroy(loaded_scene) rescue _ -> :ok end end)

      {:ok, loaded_text} = Scene.get_node(loaded_scene, text_node.id)
      assert loaded_text.type == :text
      assert loaded_text.text_content == "Hello world"
    end

    test "handles frame nodes" do
      scene = new_scene()
      frame = Node.new_frame(classes: "p-4", name: "Group")
      Scene.insert(scene, frame)
      path = tmp_path("frame_node")

      Persistence.save(scene, path)
      {:ok, loaded_scene, _meta} = Persistence.load(path)
      on_exit(fn -> try do Scene.destroy(loaded_scene) rescue _ -> :ok end end)

      {:ok, loaded_frame} = Scene.get_node(loaded_scene, frame.id)
      assert loaded_frame.type == :frame
      assert loaded_frame.classes == "p-4"
    end

    test "handles boolean attr values through serialization" do
      scene = new_scene()
      Scene.insert_component(scene, :button, attrs: %{disabled: true, hidden: false})
      path = tmp_path("boolean_attrs")

      Persistence.save(scene, path)
      {:ok, loaded_scene, _meta} = Persistence.load(path)
      on_exit(fn -> try do Scene.destroy(loaded_scene) rescue _ -> :ok end end)

      [node] = Scene.all_nodes(loaded_scene)
      assert node.attrs[:disabled] == true
      assert node.attrs[:hidden] == false
    end
  end
end
