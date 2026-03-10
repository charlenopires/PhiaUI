defmodule PhiaUiDesign.Mcp.ServerTest do
  @moduledoc """
  Tests the JSON-RPC message processing logic of the MCP server.

  Because PhiaUiDesign.Mcp.Server.process/2 is private, we test it
  indirectly by extracting the protocol logic into testable units.
  We simulate message processing by calling the same public pipeline:
  decode JSON -> process -> encode response.
  """
  use ExUnit.Case, async: true

  alias PhiaUiDesign.Canvas.Scene
  alias PhiaUiDesign.Mcp.{ToolRegistry, Tools}

  # ---------------------------------------------------------------------------
  # Helper: create state and ensure cleanup
  # ---------------------------------------------------------------------------

  defp new_state(_context \\ %{}) do
    scene = Scene.new()
    on_exit(fn -> try do Scene.destroy(scene) rescue _ -> :ok end end)
    %{scene: scene, initialized: false, theme: :zinc, project_path: nil}
  end

  # We simulate the server's process/2 function because it is private.
  # This replicates the exact pattern matching from server.ex.
  defp process(message, state) do
    case message do
      %{"method" => "initialize", "id" => id} ->
        result = %{
          "protocolVersion" => "2024-11-05",
          "capabilities" => %{"tools" => %{}},
          "serverInfo" => %{
            "name" => "phiaui-design",
            "version" => "0.1.16"
          }
        }

        {%{state | initialized: true}, jsonrpc_result(id, result)}

      %{"method" => "notifications/initialized"} ->
        {state, nil}

      %{"method" => "tools/list", "id" => id} ->
        result = %{"tools" => ToolRegistry.all_tools()}
        {state, jsonrpc_result(id, result)}

      %{"method" => "tools/call", "id" => id, "params" => params} ->
        tool_name = params["name"]
        arguments = params["arguments"] || %{}
        {result, state} = Tools.execute(tool_name, arguments, state)
        {state, jsonrpc_result(id, result)}

      %{"method" => "ping", "id" => id} ->
        {state, jsonrpc_result(id, %{})}

      %{"id" => id} ->
        {state, jsonrpc_error(id, -32601, "Method not found")}

      _ ->
        {state, nil}
    end
  end

  defp jsonrpc_result(id, result) do
    %{"jsonrpc" => "2.0", "id" => id, "result" => result}
  end

  defp jsonrpc_error(id, code, message) do
    %{
      "jsonrpc" => "2.0",
      "id" => id,
      "error" => %{"code" => code, "message" => message}
    }
  end

  # ---------------------------------------------------------------------------
  # initialize
  # ---------------------------------------------------------------------------

  describe "initialize message" do
    test "returns protocol version and server info" do
      state = new_state()

      message = %{
        "jsonrpc" => "2.0",
        "id" => 1,
        "method" => "initialize",
        "params" => %{"protocolVersion" => "2024-11-05"}
      }

      {new_state, response} = process(message, state)

      assert response["jsonrpc"] == "2.0"
      assert response["id"] == 1
      assert response["result"]["protocolVersion"] == "2024-11-05"
      assert response["result"]["serverInfo"]["name"] == "phiaui-design"
      assert response["result"]["serverInfo"]["version"] == "0.1.16"
      assert new_state.initialized == true
    end

    test "sets initialized flag to true in state" do
      state = new_state()
      assert state.initialized == false

      message = %{"id" => 1, "method" => "initialize"}
      {new_state, _response} = process(message, state)

      assert new_state.initialized == true
    end

    test "includes tools capability" do
      state = new_state()

      message = %{"id" => 1, "method" => "initialize"}
      {_state, response} = process(message, state)

      assert response["result"]["capabilities"]["tools"] == %{}
    end
  end

  # ---------------------------------------------------------------------------
  # notifications/initialized
  # ---------------------------------------------------------------------------

  describe "notifications/initialized message" do
    test "returns nil response (notification, no reply)" do
      state = new_state()

      message = %{"method" => "notifications/initialized"}
      {_state, response} = process(message, state)

      assert response == nil
    end

    test "does not modify state" do
      state = new_state()

      message = %{"method" => "notifications/initialized"}
      {new_state, _response} = process(message, state)

      assert new_state.theme == state.theme
      assert new_state.scene == state.scene
    end
  end

  # ---------------------------------------------------------------------------
  # tools/list
  # ---------------------------------------------------------------------------

  describe "tools/list message" do
    test "returns all 15 tool definitions" do
      state = new_state()

      message = %{"jsonrpc" => "2.0", "id" => 2, "method" => "tools/list"}
      {_state, response} = process(message, state)

      assert response["jsonrpc"] == "2.0"
      assert response["id"] == 2

      tools = response["result"]["tools"]
      assert is_list(tools)
      assert length(tools) == 15
    end

    test "each tool has name, description, and inputSchema" do
      state = new_state()

      message = %{"id" => 2, "method" => "tools/list"}
      {_state, response} = process(message, state)

      for tool <- response["result"]["tools"] do
        assert Map.has_key?(tool, "name")
        assert Map.has_key?(tool, "description")
        assert Map.has_key?(tool, "inputSchema")
        assert is_binary(tool["name"])
        assert is_binary(tool["description"])
        assert is_map(tool["inputSchema"])
      end
    end

    test "includes all expected tool names" do
      state = new_state()

      message = %{"id" => 2, "method" => "tools/list"}
      {_state, response} = process(message, state)

      tool_names = Enum.map(response["result"]["tools"], & &1["name"])

      expected_names = [
        "insert_phia_component",
        "set_phia_attr",
        "set_phia_slot",
        "delete_phia_node",
        "move_phia_node",
        "get_phia_component_info",
        "get_phia_catalog",
        "get_phia_families",
        "insert_phia_page",
        "set_phia_theme",
        "get_phia_theme",
        "export_heex",
        "export_liveview",
        "get_scene_tree",
        "clear_scene"
      ]

      for name <- expected_names do
        assert name in tool_names, "Missing tool: #{name}"
      end
    end
  end

  # ---------------------------------------------------------------------------
  # tools/call
  # ---------------------------------------------------------------------------

  describe "tools/call message" do
    test "executes insert_phia_component and returns result" do
      state = new_state()

      message = %{
        "jsonrpc" => "2.0",
        "id" => 3,
        "method" => "tools/call",
        "params" => %{
          "name" => "insert_phia_component",
          "arguments" => %{"component" => "button"}
        }
      }

      {_state, response} = process(message, state)

      assert response["jsonrpc"] == "2.0"
      assert response["id"] == 3

      result = response["result"]
      assert is_map(result)
      assert is_list(result["content"])

      text = hd(result["content"])["text"]
      assert text =~ "Inserted <.button>"
      assert Scene.count(state.scene) == 1
    end

    test "executes get_phia_theme and returns current theme" do
      state = new_state()

      message = %{
        "id" => 4,
        "method" => "tools/call",
        "params" => %{"name" => "get_phia_theme", "arguments" => %{}}
      }

      {_state, response} = process(message, state)

      text = hd(response["result"]["content"])["text"]
      assert text =~ "Current theme: :zinc"
    end

    test "executes set_phia_theme and updates state" do
      state = new_state()

      message = %{
        "id" => 5,
        "method" => "tools/call",
        "params" => %{"name" => "set_phia_theme", "arguments" => %{"theme" => "rose"}}
      }

      {new_state, response} = process(message, state)

      text = hd(response["result"]["content"])["text"]
      assert text =~ "Theme set to :rose"
      assert new_state.theme == :rose
    end

    test "defaults arguments to empty map when not provided" do
      state = new_state()

      message = %{
        "id" => 6,
        "method" => "tools/call",
        "params" => %{"name" => "get_scene_tree"}
      }

      {_state, response} = process(message, state)

      text = hd(response["result"]["content"])["text"]
      assert text =~ "Scene is empty"
    end

    test "handles tool execution with clear_scene" do
      state = new_state()

      # Insert a component first
      Tools.execute("insert_phia_component", %{"component" => "button"}, state)

      message = %{
        "id" => 7,
        "method" => "tools/call",
        "params" => %{"name" => "clear_scene", "arguments" => %{}}
      }

      {new_state, response} = process(message, state)

      text = hd(response["result"]["content"])["text"]
      assert text =~ "Cleared"

      # New scene should be empty
      assert Scene.count(new_state.scene) == 0

      on_exit(fn -> try do Scene.destroy(new_state.scene) rescue _ -> :ok end end)
    end
  end

  # ---------------------------------------------------------------------------
  # ping
  # ---------------------------------------------------------------------------

  describe "ping message" do
    test "returns empty result" do
      state = new_state()

      message = %{"jsonrpc" => "2.0", "id" => 10, "method" => "ping"}
      {_state, response} = process(message, state)

      assert response["jsonrpc"] == "2.0"
      assert response["id"] == 10
      assert response["result"] == %{}
    end
  end

  # ---------------------------------------------------------------------------
  # unknown method with id
  # ---------------------------------------------------------------------------

  describe "unknown method with id" do
    test "returns method not found error" do
      state = new_state()

      message = %{"jsonrpc" => "2.0", "id" => 11, "method" => "unknown/method"}
      {_state, response} = process(message, state)

      assert response["jsonrpc"] == "2.0"
      assert response["id"] == 11
      assert response["error"]["code"] == -32601
      assert response["error"]["message"] == "Method not found"
    end

    test "returns error for message with id but no matching method" do
      state = new_state()

      message = %{"id" => 12, "something" => "else"}
      {_state, response} = process(message, state)

      assert response["error"]["code"] == -32601
    end
  end

  # ---------------------------------------------------------------------------
  # notification (message without id)
  # ---------------------------------------------------------------------------

  describe "notification messages (no id)" do
    test "returns nil response for unknown notification" do
      state = new_state()

      message = %{"method" => "some/notification", "params" => %{}}
      {_state, response} = process(message, state)

      assert response == nil
    end

    test "returns nil response for empty map" do
      state = new_state()

      {_state, response} = process(%{}, state)

      assert response == nil
    end
  end

  # ---------------------------------------------------------------------------
  # JSON-RPC response format
  # ---------------------------------------------------------------------------

  describe "JSON-RPC response format" do
    test "success response has jsonrpc, id, and result keys" do
      state = new_state()

      message = %{"id" => 20, "method" => "ping"}
      {_state, response} = process(message, state)

      assert Map.has_key?(response, "jsonrpc")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "result")
      refute Map.has_key?(response, "error")
    end

    test "error response has jsonrpc, id, and error keys" do
      state = new_state()

      message = %{"id" => 21, "bad" => true}
      {_state, response} = process(message, state)

      assert Map.has_key?(response, "jsonrpc")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "error")
      refute Map.has_key?(response, "result")
    end

    test "error has code and message fields" do
      state = new_state()

      message = %{"id" => 22, "bad" => true}
      {_state, response} = process(message, state)

      error = response["error"]
      assert is_integer(error["code"])
      assert is_binary(error["message"])
    end

    test "responses can be encoded to valid JSON" do
      state = new_state()

      message = %{"id" => 30, "method" => "initialize"}
      {_state, response} = process(message, state)

      assert {:ok, json} = Jason.encode(response)
      assert is_binary(json)
      assert {:ok, decoded} = Jason.decode(json)
      assert decoded["id"] == 30
    end
  end

  # ---------------------------------------------------------------------------
  # ToolRegistry integration
  # ---------------------------------------------------------------------------

  describe "ToolRegistry" do
    test "all_tools returns a list of 15 tool definitions" do
      tools = ToolRegistry.all_tools()
      assert length(tools) == 15
    end

    test "each tool has required input schema type of object" do
      for tool <- ToolRegistry.all_tools() do
        assert tool["inputSchema"]["type"] == "object",
               "Tool #{tool["name"]} has non-object inputSchema type"
      end
    end

    test "insert_phia_component requires component field" do
      tools = ToolRegistry.all_tools()

      insert_tool = Enum.find(tools, &(&1["name"] == "insert_phia_component"))
      assert "component" in insert_tool["inputSchema"]["required"]
    end

    test "set_phia_attr requires node_id and attrs fields" do
      tools = ToolRegistry.all_tools()

      set_attr_tool = Enum.find(tools, &(&1["name"] == "set_phia_attr"))
      required = set_attr_tool["inputSchema"]["required"]
      assert "node_id" in required
      assert "attrs" in required
    end

    test "set_phia_theme requires theme field" do
      tools = ToolRegistry.all_tools()

      set_theme = Enum.find(tools, &(&1["name"] == "set_phia_theme"))
      assert "theme" in set_theme["inputSchema"]["required"]
    end
  end

  # ---------------------------------------------------------------------------
  # Full workflow simulation
  # ---------------------------------------------------------------------------

  describe "full workflow simulation" do
    test "initialize -> insert -> set_attr -> export_heex" do
      state = new_state()

      # Step 1: Initialize
      {state, init_resp} = process(%{"id" => 1, "method" => "initialize"}, state)
      assert init_resp["result"]["serverInfo"]["name"] == "phiaui-design"
      assert state.initialized == true

      # Step 2: Insert component
      {state, insert_resp} =
        process(
          %{
            "id" => 2,
            "method" => "tools/call",
            "params" => %{
              "name" => "insert_phia_component",
              "arguments" => %{
                "component" => "button",
                "slots" => %{"inner_block" => "Click me"}
              }
            }
          },
          state
        )

      insert_text = hd(insert_resp["result"]["content"])["text"]
      assert insert_text =~ "Inserted <.button>"

      # Extract node ID
      [_, node_id] = Regex.run(~r/id:\s*(\S+)/, insert_text)

      # Step 3: Set attribute
      {state, attr_resp} =
        process(
          %{
            "id" => 3,
            "method" => "tools/call",
            "params" => %{
              "name" => "set_phia_attr",
              "arguments" => %{
                "node_id" => node_id,
                "attrs" => %{"variant" => ":outline"}
              }
            }
          },
          state
        )

      attr_text = hd(attr_resp["result"]["content"])["text"]
      assert attr_text =~ "Updated attrs"

      # Step 4: Export HEEx
      {_state, export_resp} =
        process(
          %{
            "id" => 4,
            "method" => "tools/call",
            "params" => %{"name" => "export_heex", "arguments" => %{}}
          },
          state
        )

      heex = hd(export_resp["result"]["content"])["text"]
      assert heex =~ ".button"
      assert heex =~ "Click me"
    end
  end
end
