defmodule Mix.Tasks.Phia.Design.Mcp do
  @moduledoc """
  Starts the PhiaUI Design MCP server for Claude Code integration.

  ## Usage

      mix phia.design.mcp

  The server communicates over stdio using JSON-RPC 2.0 (MCP protocol).
  Configure Claude Code to use it by adding to `.mcp.json`:

      {
        "mcpServers": {
          "phiaui-design": {
            "command": "mix",
            "args": ["phia.design.mcp"],
            "env": {"MIX_ENV": "dev"}
          }
        }
      }

  ## Available Tools

  | Tool | Description |
  |------|-------------|
  | `insert_phia_component` | Insert a component by name + attrs |
  | `set_phia_attr` | Update attrs on a node |
  | `set_phia_slot` | Update slot content on a node |
  | `delete_phia_node` | Remove a node from the scene |
  | `move_phia_node` | Move a node to a new parent |
  | `get_phia_component_info` | Get attrs/slots/variants for a component |
  | `get_phia_catalog` | List all 623+ components by tier |
  | `get_phia_families` | List composable family groups |
  | `insert_phia_page` | Apply a page template |
  | `set_phia_theme` | Switch theme preset |
  | `get_phia_theme` | Get current theme |
  | `export_heex` | Export scene as HEEx template |
  | `export_liveview` | Export scene as LiveView module |
  | `get_scene_tree` | Get scene structure as JSON |
  | `clear_scene` | Clear all nodes |
  """

  @shortdoc "Starts the PhiaUI Design MCP server (stdio)"

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    PhiaUiDesign.Mcp.Server.run()
  end
end
