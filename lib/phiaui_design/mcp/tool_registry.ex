defmodule PhiaUiDesign.Mcp.ToolRegistry do
  @moduledoc """
  Defines all MCP tool specifications with JSON Schema input definitions.

  Each tool is a map with `name`, `description`, and `inputSchema` keys,
  following the MCP tool definition format.
  """

  @doc "Return all tool definitions for the `tools/list` response."
  @spec all_tools() :: [map()]
  def all_tools do
    [
      insert_phia_component(),
      set_phia_attr(),
      set_phia_slot(),
      delete_phia_node(),
      move_phia_node(),
      get_phia_component_info(),
      get_phia_catalog(),
      get_phia_families(),
      insert_phia_page(),
      set_phia_theme(),
      get_phia_theme(),
      export_heex(),
      export_liveview(),
      get_scene_tree(),
      clear_scene(),
      batch_design(),
      batch_get(),
      snapshot_layout(),
      get_phia_variables(),
      set_phia_variables()
    ]
  end

  # ---------------------------------------------------------------------------
  # Component tools
  # ---------------------------------------------------------------------------

  defp insert_phia_component do
    %{
      "name" => "insert_phia_component",
      "description" =>
        "Insert a PhiaUI component into the design canvas. " <>
          "Returns the new node ID. Use get_phia_catalog to discover available components.",
      "inputSchema" => %{
        "type" => "object",
        "properties" => %{
          "component" => %{
            "type" => "string",
            "description" => "Component name (e.g., 'button', 'card', 'input', 'badge')"
          },
          "attrs" => %{
            "type" => "object",
            "description" =>
              "Component attributes as key-value pairs (e.g., {\"variant\": \"outline\", \"size\": \"lg\"})"
          },
          "slots" => %{
            "type" => "object",
            "description" =>
              "Slot content (e.g., {\"inner_block\": \"Click me\"}). Use inner_block for the default slot."
          },
          "parent_id" => %{
            "type" => "string",
            "description" => "ID of parent node to insert into. Omit for root-level insertion."
          },
          "name" => %{
            "type" => "string",
            "description" => "Display name for the node in the layer tree (optional)."
          }
        },
        "required" => ["component"]
      }
    }
  end

  defp set_phia_attr do
    %{
      "name" => "set_phia_attr",
      "description" => "Update one or more attributes on an existing node.",
      "inputSchema" => %{
        "type" => "object",
        "properties" => %{
          "node_id" => %{"type" => "string", "description" => "ID of the node to update"},
          "attrs" => %{
            "type" => "object",
            "description" => "Attributes to set or update (merged with existing)"
          }
        },
        "required" => ["node_id", "attrs"]
      }
    }
  end

  defp set_phia_slot do
    %{
      "name" => "set_phia_slot",
      "description" => "Update slot content on an existing node.",
      "inputSchema" => %{
        "type" => "object",
        "properties" => %{
          "node_id" => %{"type" => "string", "description" => "ID of the node to update"},
          "slot_name" => %{
            "type" => "string",
            "description" => "Slot name (e.g., 'inner_block', 'header', 'footer')"
          },
          "content" => %{"type" => "string", "description" => "Text content for the slot"}
        },
        "required" => ["node_id", "slot_name", "content"]
      }
    }
  end

  defp delete_phia_node do
    %{
      "name" => "delete_phia_node",
      "description" => "Remove a node and all its children from the scene.",
      "inputSchema" => %{
        "type" => "object",
        "properties" => %{
          "node_id" => %{"type" => "string", "description" => "ID of the node to delete"}
        },
        "required" => ["node_id"]
      }
    }
  end

  defp move_phia_node do
    %{
      "name" => "move_phia_node",
      "description" => "Move a node to a new parent at a given index.",
      "inputSchema" => %{
        "type" => "object",
        "properties" => %{
          "node_id" => %{"type" => "string", "description" => "ID of the node to move"},
          "new_parent_id" => %{
            "type" => "string",
            "description" => "ID of the new parent node (null for root level)"
          },
          "index" => %{
            "type" => "integer",
            "description" => "Position among siblings (0-based). Use -1 for end."
          }
        },
        "required" => ["node_id"]
      }
    }
  end

  # ---------------------------------------------------------------------------
  # Catalog tools
  # ---------------------------------------------------------------------------

  defp get_phia_component_info do
    %{
      "name" => "get_phia_component_info",
      "description" =>
        "Get detailed info about a component: attrs, slots, variants, tier, hooks.",
      "inputSchema" => %{
        "type" => "object",
        "properties" => %{
          "component" => %{
            "type" => "string",
            "description" => "Component name (e.g., 'button', 'card')"
          }
        },
        "required" => ["component"]
      }
    }
  end

  defp get_phia_catalog do
    %{
      "name" => "get_phia_catalog",
      "description" =>
        "Return all 650+ PhiaUI components grouped by tier " <>
          "(primitive, interactive, form, navigation, shell, widget, layout, surface, animation).",
      "inputSchema" => %{
        "type" => "object",
        "properties" => %{
          "tier" => %{
            "type" => "string",
            "description" =>
              "Filter by tier (optional). One of: primitive, interactive, form, navigation, shell, widget, layout, surface, animation."
          }
        }
      }
    }
  end

  defp get_phia_families do
    %{
      "name" => "get_phia_families",
      "description" =>
        "Return composable component families (e.g., card = card + card_header + card_content + card_footer).",
      "inputSchema" => %{
        "type" => "object",
        "properties" => %{}
      }
    }
  end

  # ---------------------------------------------------------------------------
  # Layout / template tools
  # ---------------------------------------------------------------------------

  defp insert_phia_page do
    %{
      "name" => "insert_phia_page",
      "description" =>
        "Apply a pre-built page template. Available: dashboard, settings, auth_login, " <>
          "auth_register, landing, crud_list, profile, pricing, empty.",
      "inputSchema" => %{
        "type" => "object",
        "properties" => %{
          "template" => %{
            "type" => "string",
            "description" =>
              "Template key: dashboard, settings, auth_login, auth_register, landing, crud_list, profile, pricing, empty"
          }
        },
        "required" => ["template"]
      }
    }
  end

  # ---------------------------------------------------------------------------
  # Theme tools
  # ---------------------------------------------------------------------------

  defp set_phia_theme do
    %{
      "name" => "set_phia_theme",
      "description" => "Switch the design theme preset.",
      "inputSchema" => %{
        "type" => "object",
        "properties" => %{
          "theme" => %{
            "type" => "string",
            "description" =>
              "Theme name: zinc, slate, blue, rose, orange, green, violet, neutral"
          }
        },
        "required" => ["theme"]
      }
    }
  end

  defp get_phia_theme do
    %{
      "name" => "get_phia_theme",
      "description" => "Return the current theme name.",
      "inputSchema" => %{
        "type" => "object",
        "properties" => %{}
      }
    }
  end

  # ---------------------------------------------------------------------------
  # Export tools
  # ---------------------------------------------------------------------------

  defp export_heex do
    %{
      "name" => "export_heex",
      "description" => "Export the current scene as a HEEx template string.",
      "inputSchema" => %{
        "type" => "object",
        "properties" => %{}
      }
    }
  end

  defp export_liveview do
    %{
      "name" => "export_liveview",
      "description" => "Export the current scene as a complete LiveView module.",
      "inputSchema" => %{
        "type" => "object",
        "properties" => %{
          "module_name" => %{
            "type" => "string",
            "description" =>
              "Fully-qualified module name (default: MyAppWeb.DesignedLive)"
          },
          "web_module" => %{
            "type" => "string",
            "description" => "Phoenix web module (default: MyAppWeb)"
          }
        }
      }
    }
  end

  # ---------------------------------------------------------------------------
  # Scene tools
  # ---------------------------------------------------------------------------

  defp get_scene_tree do
    %{
      "name" => "get_scene_tree",
      "description" =>
        "Return the current scene structure as a JSON tree with node IDs, types, attrs, and slots.",
      "inputSchema" => %{
        "type" => "object",
        "properties" => %{}
      }
    }
  end

  defp clear_scene do
    %{
      "name" => "clear_scene",
      "description" => "Remove all nodes from the scene, starting fresh.",
      "inputSchema" => %{
        "type" => "object",
        "properties" => %{}
      }
    }
  end

  # ---------------------------------------------------------------------------
  # Batch design tools
  # ---------------------------------------------------------------------------

  defp batch_design do
    %{
      "name" => "batch_design",
      "description" =>
        "Execute multiple design operations atomically (max 25). " <>
          "Operations: I(insert), C(copy), U(update), R(replace), M(move), D(delete). " <>
          "Supports bindings ($name) for referencing created nodes. " <>
          "Rolls back all changes on any failure.",
      "inputSchema" => %{
        "type" => "object",
        "properties" => %{
          "operations" => %{
            "type" => "array",
            "description" =>
              "List of operation objects. Each has 'op' (I/C/U/R/M/D), optional 'bind', " <>
                "'id' or 'parent' (use $binding to reference), and 'data' with node details.",
            "items" => %{
              "type" => "object",
              "properties" => %{
                "op" => %{
                  "type" => "string",
                  "enum" => ["I", "C", "U", "R", "M", "D"],
                  "description" => "Operation type"
                },
                "bind" => %{
                  "type" => "string",
                  "description" => "Name to bind the resulting node ID (for $ref in later ops)"
                },
                "id" => %{
                  "type" => "string",
                  "description" => "Target node ID (or $binding reference)"
                },
                "parent" => %{
                  "type" => "string",
                  "description" => "Parent node ID (or $binding reference, null for root)"
                },
                "index" => %{
                  "type" => "integer",
                  "description" => "Position index for Move operations"
                },
                "data" => %{
                  "type" => "object",
                  "description" =>
                    "Node data: type (phia_component/html_element/text/frame), " <>
                      "component, tag, attrs, slots, classes, name, layout properties"
                }
              },
              "required" => ["op"]
            }
          }
        },
        "required" => ["operations"]
      }
    }
  end

  defp batch_get do
    %{
      "name" => "batch_get",
      "description" =>
        "Search and retrieve nodes by pattern matching or specific IDs. " <>
          "Supports type, name (regex), and component filters with configurable depth.",
      "inputSchema" => %{
        "type" => "object",
        "properties" => %{
          "patterns" => %{
            "type" => "array",
            "description" =>
              "Search patterns: [{\"type\": \"frame\", \"name\": \"Side.*\", \"component\": \"button\"}]",
            "items" => %{
              "type" => "object",
              "properties" => %{
                "type" => %{"type" => "string", "description" => "Node type filter"},
                "name" => %{"type" => "string", "description" => "Name regex pattern"},
                "component" => %{"type" => "string", "description" => "Component name filter"}
              }
            }
          },
          "node_ids" => %{
            "type" => "array",
            "items" => %{"type" => "string"},
            "description" => "Specific node IDs to retrieve"
          },
          "parent_id" => %{
            "type" => "string",
            "description" => "Scope search to children of this node"
          },
          "read_depth" => %{
            "type" => "integer",
            "description" => "How deep to expand children (default 1, 0 = node only)"
          }
        }
      }
    }
  end

  defp snapshot_layout do
    %{
      "name" => "snapshot_layout",
      "description" =>
        "Compute approximate bounding boxes for scene nodes based on layout properties. " <>
          "Detects overflow, zero-size, and missing layout problems.",
      "inputSchema" => %{
        "type" => "object",
        "properties" => %{
          "parent_id" => %{
            "type" => "string",
            "description" => "Scope to a subtree (null = entire scene)"
          },
          "max_depth" => %{
            "type" => "integer",
            "description" => "How deep to recurse (default 2)"
          },
          "problems_only" => %{
            "type" => "boolean",
            "description" => "Only return nodes with detected problems (default false)"
          },
          "viewport_width" => %{
            "type" => "integer",
            "description" => "Root container width in px (default 1280)"
          }
        }
      }
    }
  end

  defp get_phia_variables do
    %{
      "name" => "get_phia_variables",
      "description" => "Get all design variables/tokens defined in the current scene.",
      "inputSchema" => %{
        "type" => "object",
        "properties" => %{}
      }
    }
  end

  defp set_phia_variables do
    %{
      "name" => "set_phia_variables",
      "description" =>
        "Set or update design variables/tokens. Variables can be referenced in attrs as $name.",
      "inputSchema" => %{
        "type" => "object",
        "properties" => %{
          "variables" => %{
            "type" => "object",
            "description" =>
              "Map of variable definitions: {\"primary\": {\"value\": \"#3b82f6\", \"type\": \"color\", " <>
                "\"theme_overrides\": {\"dark\": \"#60a5fa\"}}}",
            "additionalProperties" => %{
              "type" => "object",
              "properties" => %{
                "value" => %{"description" => "Default value"},
                "type" => %{
                  "type" => "string",
                  "enum" => ["color", "spacing", "number", "string"],
                  "description" => "Variable type"
                },
                "theme_overrides" => %{
                  "type" => "object",
                  "description" => "Theme-specific value overrides"
                }
              },
              "required" => ["value", "type"]
            }
          },
          "delete" => %{
            "type" => "array",
            "items" => %{"type" => "string"},
            "description" => "Variable names to delete"
          }
        }
      }
    }
  end
end
