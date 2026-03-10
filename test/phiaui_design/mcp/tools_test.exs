defmodule PhiaUiDesign.Mcp.ToolsTest do
  use ExUnit.Case, async: true

  alias PhiaUiDesign.Canvas.Scene
  alias PhiaUiDesign.Mcp.Tools

  # ---------------------------------------------------------------------------
  # Helper: create a scene + state and ensure cleanup
  # ---------------------------------------------------------------------------

  defp new_state(_context \\ %{}) do
    scene = Scene.new()
    on_exit(fn -> try do Scene.destroy(scene) rescue _ -> :ok end end)
    %{scene: scene, theme: :zinc}
  end

  defp text_from_result(result) do
    result
    |> Map.get("content")
    |> hd()
    |> Map.get("text")
  end

  # ---------------------------------------------------------------------------
  # insert_phia_component
  # ---------------------------------------------------------------------------

  describe "insert_phia_component" do
    test "inserts a component and returns the node ID" do
      state = new_state()

      {result, _state} =
        Tools.execute("insert_phia_component", %{"component" => "button"}, state)

      text = text_from_result(result)
      assert text =~ "Inserted <.button>"
      assert text =~ "id:"
    end

    test "inserts a component with attrs" do
      state = new_state()

      {result, _state} =
        Tools.execute(
          "insert_phia_component",
          %{"component" => "button", "attrs" => %{"variant" => ":destructive"}},
          state
        )

      text = text_from_result(result)
      assert text =~ "Inserted <.button>"

      # Verify the node is in the scene
      assert Scene.count(state.scene) == 1
    end

    test "inserts a component with slots" do
      state = new_state()

      {_result, _state} =
        Tools.execute(
          "insert_phia_component",
          %{"component" => "button", "slots" => %{"inner_block" => "Click me"}},
          state
        )

      [node] = Scene.all_nodes(state.scene)
      assert node.slots[:inner_block] == "Click me"
    end

    test "inserts a component under a parent" do
      state = new_state()

      # Insert a parent first
      {result1, _state} =
        Tools.execute("insert_phia_component", %{"component" => "card"}, state)

      parent_id = extract_id(text_from_result(result1))

      # Insert child under parent
      {_result2, _state} =
        Tools.execute(
          "insert_phia_component",
          %{"component" => "button", "parent_id" => parent_id},
          state
        )

      {:ok, parent} = Scene.get_node(state.scene, parent_id)
      assert length(parent.children) == 1
    end

    test "inserts a component with a custom name" do
      state = new_state()

      {_result, _state} =
        Tools.execute(
          "insert_phia_component",
          %{"component" => "button", "name" => "Primary CTA"},
          state
        )

      [node] = Scene.all_nodes(state.scene)
      assert node.name == "Primary CTA"
    end

    test "coerces string attr values to atoms when prefixed with colon" do
      state = new_state()

      {_result, _state} =
        Tools.execute(
          "insert_phia_component",
          %{"component" => "button", "attrs" => %{"variant" => ":outline"}},
          state
        )

      [node] = Scene.all_nodes(state.scene)
      assert node.attrs[:variant] == :outline
    end

    test "coerces string boolean values" do
      state = new_state()

      {_result, _state} =
        Tools.execute(
          "insert_phia_component",
          %{"component" => "button", "attrs" => %{"disabled" => "true"}},
          state
        )

      [node] = Scene.all_nodes(state.scene)
      assert node.attrs[:disabled] == true
    end

    test "coerces numeric string values to integers" do
      state = new_state()

      {_result, _state} =
        Tools.execute(
          "insert_phia_component",
          %{"component" => "heading", "attrs" => %{"level" => "3"}},
          state
        )

      [node] = Scene.all_nodes(state.scene)
      assert node.attrs[:level] == 3
    end
  end

  # ---------------------------------------------------------------------------
  # set_phia_attr
  # ---------------------------------------------------------------------------

  describe "set_phia_attr" do
    test "updates attrs on an existing node" do
      state = new_state()

      {result, _state} =
        Tools.execute("insert_phia_component", %{"component" => "button"}, state)

      node_id = extract_id(text_from_result(result))

      {update_result, _state} =
        Tools.execute(
          "set_phia_attr",
          %{"node_id" => node_id, "attrs" => %{"variant" => ":destructive"}},
          state
        )

      text = text_from_result(update_result)
      assert text =~ "Updated attrs"

      {:ok, node} = Scene.get_node(state.scene, node_id)
      assert node.attrs[:variant] == :destructive
    end

    test "returns error for missing node" do
      state = new_state()

      {result, _state} =
        Tools.execute(
          "set_phia_attr",
          %{"node_id" => "nonexistent-id", "attrs" => %{"variant" => ":ghost"}},
          state
        )

      text = text_from_result(result)
      assert text =~ "Error"
    end
  end

  # ---------------------------------------------------------------------------
  # set_phia_slot
  # ---------------------------------------------------------------------------

  describe "set_phia_slot" do
    test "sets a slot on an existing node" do
      state = new_state()

      {result, _state} =
        Tools.execute("insert_phia_component", %{"component" => "button"}, state)

      node_id = extract_id(text_from_result(result))

      {slot_result, _state} =
        Tools.execute(
          "set_phia_slot",
          %{"node_id" => node_id, "slot_name" => "inner_block", "content" => "New text"},
          state
        )

      text = text_from_result(slot_result)
      assert text =~ "Set slot :inner_block"

      {:ok, node} = Scene.get_node(state.scene, node_id)
      assert node.slots[:inner_block] == "New text"
    end

    test "returns error for missing node" do
      state = new_state()

      {result, _state} =
        Tools.execute(
          "set_phia_slot",
          %{"node_id" => "missing", "slot_name" => "inner_block", "content" => "text"},
          state
        )

      text = text_from_result(result)
      assert text =~ "not found"
    end
  end

  # ---------------------------------------------------------------------------
  # delete_phia_node
  # ---------------------------------------------------------------------------

  describe "delete_phia_node" do
    test "deletes a node from the scene" do
      state = new_state()

      {result, _state} =
        Tools.execute("insert_phia_component", %{"component" => "button"}, state)

      node_id = extract_id(text_from_result(result))
      assert Scene.count(state.scene) == 1

      {delete_result, _state} =
        Tools.execute("delete_phia_node", %{"node_id" => node_id}, state)

      text = text_from_result(delete_result)
      assert text =~ "Deleted node"
      assert Scene.count(state.scene) == 0
    end

    test "returns error for missing node" do
      state = new_state()

      {result, _state} =
        Tools.execute("delete_phia_node", %{"node_id" => "nonexistent"}, state)

      text = text_from_result(result)
      assert text =~ "Error"
    end
  end

  # ---------------------------------------------------------------------------
  # move_phia_node
  # ---------------------------------------------------------------------------

  describe "move_phia_node" do
    test "moves a node under a new parent" do
      state = new_state()

      {r1, _} = Tools.execute("insert_phia_component", %{"component" => "card"}, state)
      parent_id = extract_id(text_from_result(r1))

      {r2, _} = Tools.execute("insert_phia_component", %{"component" => "button"}, state)
      child_id = extract_id(text_from_result(r2))

      {move_result, _} =
        Tools.execute(
          "move_phia_node",
          %{"node_id" => child_id, "new_parent_id" => parent_id},
          state
        )

      text = text_from_result(move_result)
      assert text =~ "Moved"
      assert text =~ "under #{parent_id}"

      {:ok, parent} = Scene.get_node(state.scene, parent_id)
      assert child_id in parent.children
    end

    test "moves a node to root when new_parent_id is nil" do
      state = new_state()

      {r1, _} = Tools.execute("insert_phia_component", %{"component" => "card"}, state)
      parent_id = extract_id(text_from_result(r1))

      {r2, _} =
        Tools.execute(
          "insert_phia_component",
          %{"component" => "button", "parent_id" => parent_id},
          state
        )

      child_id = extract_id(text_from_result(r2))

      {move_result, _} =
        Tools.execute(
          "move_phia_node",
          %{"node_id" => child_id, "new_parent_id" => nil},
          state
        )

      text = text_from_result(move_result)
      assert text =~ "to root"
    end
  end

  # ---------------------------------------------------------------------------
  # set_phia_theme / get_phia_theme
  # ---------------------------------------------------------------------------

  describe "set_phia_theme and get_phia_theme" do
    test "set_phia_theme updates the state theme" do
      state = new_state()

      {result, new_state} =
        Tools.execute("set_phia_theme", %{"theme" => "rose"}, state)

      text = text_from_result(result)
      assert text =~ "Theme set to :rose"
      assert new_state.theme == :rose
    end

    test "get_phia_theme returns the current theme" do
      state = new_state()

      {result, _} = Tools.execute("get_phia_theme", %{}, state)

      text = text_from_result(result)
      assert text =~ "Current theme: :zinc"
    end

    test "get_phia_theme reflects theme change" do
      state = new_state()

      {_, state} = Tools.execute("set_phia_theme", %{"theme" => "violet"}, state)
      {result, _} = Tools.execute("get_phia_theme", %{}, state)

      text = text_from_result(result)
      assert text =~ "Current theme: :violet"
    end
  end

  # ---------------------------------------------------------------------------
  # get_scene_tree
  # ---------------------------------------------------------------------------

  describe "get_scene_tree" do
    test "returns empty message for empty scene" do
      state = new_state()

      {result, _} = Tools.execute("get_scene_tree", %{}, state)

      text = text_from_result(result)
      assert text =~ "Scene is empty"
    end

    test "returns JSON tree for populated scene" do
      state = new_state()

      Tools.execute("insert_phia_component", %{"component" => "button"}, state)

      {result, _} = Tools.execute("get_scene_tree", %{}, state)

      text = text_from_result(result)
      parsed = Jason.decode!(text)
      assert is_list(parsed)
      assert length(parsed) == 1
      assert hd(parsed)["type"] == "phia_component"
    end
  end

  # ---------------------------------------------------------------------------
  # clear_scene
  # ---------------------------------------------------------------------------

  describe "clear_scene" do
    test "clears all nodes and returns a new scene in state" do
      state = new_state()

      Tools.execute("insert_phia_component", %{"component" => "button"}, state)
      Tools.execute("insert_phia_component", %{"component" => "badge"}, state)

      assert Scene.count(state.scene) == 2

      {result, new_state} = Tools.execute("clear_scene", %{}, state)

      text = text_from_result(result)
      assert text =~ "Cleared 2 nodes"

      # The new scene in the returned state should be empty
      assert Scene.count(new_state.scene) == 0

      # Cleanup the new scene in on_exit
      on_exit(fn -> try do Scene.destroy(new_state.scene) rescue _ -> :ok end end)
    end
  end

  # ---------------------------------------------------------------------------
  # export_heex
  # ---------------------------------------------------------------------------

  describe "export_heex" do
    test "returns empty message for empty scene" do
      state = new_state()

      {result, _} = Tools.execute("export_heex", %{}, state)

      text = text_from_result(result)
      assert text =~ "Scene is empty"
    end

    test "returns HEEx for scene with components" do
      state = new_state()

      Tools.execute(
        "insert_phia_component",
        %{"component" => "button", "slots" => %{"inner_block" => "Click"}},
        state
      )

      {result, _} = Tools.execute("export_heex", %{}, state)

      text = text_from_result(result)
      assert text =~ ".button"
      assert text =~ "Click"
    end
  end

  # ---------------------------------------------------------------------------
  # export_liveview
  # ---------------------------------------------------------------------------

  describe "export_liveview" do
    test "generates a LiveView module string" do
      state = new_state()

      Tools.execute(
        "insert_phia_component",
        %{"component" => "button", "slots" => %{"inner_block" => "Hello"}},
        state
      )

      {result, _} = Tools.execute("export_liveview", %{}, state)

      text = text_from_result(result)
      assert text =~ "defmodule MyAppWeb.DesignedLive do"
      assert text =~ "use MyAppWeb, :live_view"
      assert text =~ "def render(assigns)"
    end

    test "uses custom module_name and web_module" do
      state = new_state()

      Tools.execute("insert_phia_component", %{"component" => "button"}, state)

      {result, _} =
        Tools.execute(
          "export_liveview",
          %{"module_name" => "FooWeb.DashboardLive", "web_module" => "FooWeb"},
          state
        )

      text = text_from_result(result)
      assert text =~ "defmodule FooWeb.DashboardLive do"
      assert text =~ "use FooWeb, :live_view"
    end
  end

  # ---------------------------------------------------------------------------
  # Unknown tool
  # ---------------------------------------------------------------------------

  describe "unknown tool" do
    test "returns an unknown tool message" do
      state = new_state()

      {result, _} = Tools.execute("nonexistent_tool", %{}, state)

      text = text_from_result(result)
      assert text =~ "Unknown tool: nonexistent_tool"
    end
  end

  # ---------------------------------------------------------------------------
  # Result format
  # ---------------------------------------------------------------------------

  describe "result format" do
    test "every result has the content key with a list of text items" do
      state = new_state()

      {result, _} = Tools.execute("get_phia_theme", %{}, state)

      assert is_map(result)
      assert is_list(result["content"])
      assert length(result["content"]) == 1

      item = hd(result["content"])
      assert item["type"] == "text"
      assert is_binary(item["text"])
    end
  end

  # ---------------------------------------------------------------------------
  # Error rescue
  # ---------------------------------------------------------------------------

  describe "error handling" do
    test "rescues exceptions and returns error text" do
      # Force an error by providing a state with a destroyed scene
      scene = Scene.new()
      Scene.destroy(scene)
      state = %{scene: scene, theme: :zinc}

      {result, _state} =
        Tools.execute("get_scene_tree", %{}, state)

      text = text_from_result(result)
      assert text =~ "Error"
    end
  end

  # ---------------------------------------------------------------------------
  # Private helper
  # ---------------------------------------------------------------------------

  # Extract node ID from text like "Inserted <.button> with id: ABC123"
  defp extract_id(text) do
    case Regex.run(~r/id:\s*(\S+)/, text) do
      [_, id] -> id
      _ -> raise "Could not extract ID from: #{text}"
    end
  end
end
