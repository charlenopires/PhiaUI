defmodule Mix.Tasks.Phia.Design.Mcp do
  @moduledoc """
  Starts the PhiaUI Design MCP server for Claude Code integration.

  The MCP (Model Context Protocol) server lets Claude Code build Phoenix
  LiveView UIs by describing them in natural language. Claude uses 15
  tools to browse components, insert them into a scene, configure
  attributes/slots, and export production-ready code.

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

  ## Workflow Example

  1. Configure MCP as shown above
  2. Open Claude Code in your Phoenix project
  3. Ask: "Design a dashboard with stat cards, a bar chart, and a data grid"
  4. Claude browses the catalog, inserts components, configures attrs
  5. Ask: "Export as MyAppWeb.DashboardLive"
  6. Claude exports a complete LiveView module
  7. Run `mix compile` — it works

  ## Available Tools

  ### Component manipulation
  | Tool | Description |
  |------|-------------|
  | `insert_phia_component` | Insert a component by name with attrs and slots |
  | `set_phia_attr` | Update attributes on a node by ID |
  | `set_phia_slot` | Update slot content (e.g., inner_block text) |
  | `delete_phia_node` | Remove a node and its children |
  | `move_phia_node` | Move a node to a new parent at index |

  ### Catalog browsing
  | Tool | Description |
  |------|-------------|
  | `get_phia_component_info` | Get attrs, slots, variants for a component |
  | `get_phia_catalog` | List all 829 components grouped by tier |
  | `get_phia_families` | List composable family groups (card, form, etc.) |

  ### Templates and themes
  | Tool | Description |
  |------|-------------|
  | `insert_phia_page` | Apply a page template (dashboard, settings, auth, etc.) |
  | `set_phia_theme` | Switch theme (zinc, slate, rose, blue, green, violet) |
  | `get_phia_theme` | Get current theme |

  ### Export
  | Tool | Description |
  |------|-------------|
  | `export_heex` | Export scene as HEEx template |
  | `export_liveview` | Export as complete LiveView module |
  | `get_scene_tree` | Get scene structure as JSON |
  | `clear_scene` | Clear all nodes |

  ## Related Tasks

  - `mix phia.design` — visual editor (browser-based)
  - `mix phia.design.export` — CLI export from `.phia.json` files
  - `mix phia.design.analyze` — analyze designs for dependencies
  """

  @shortdoc "Starts the PhiaUI Design MCP server (stdio)"

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    PhiaUiDesign.Mcp.Server.run()
  end
end
