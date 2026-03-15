defmodule PhiaUiDesign.Mcp.Tools do
  @moduledoc """
  Implements all 15 MCP tool handlers for the PhiaUI Design server.

  Each tool function receives parsed arguments and the server state,
  returning `{result_map, updated_state}`. The result map follows the
  MCP content format: `%{"content" => [%{"type" => "text", "text" => ...}]}`.
  """

  alias PhiaUiDesign.Canvas.{Scene, Variables}
  alias PhiaUiDesign.Codegen.{HeexEmitter, LiveviewEmitter}
  alias PhiaUiDesign.Templates.PageTemplates
  alias PhiaUiDesign.Catalog.{CatalogServer, Introspector}
  alias PhiaUiDesign.Mcp.{BatchDesign, BatchGet, SnapshotLayout}

  @doc """
  Execute a tool by name. Returns `{result, state}`.
  """
  def execute(tool_name, args, state) do
    try do
      do_execute(tool_name, args, state)
    rescue
      e ->
        {text_result("Error: #{Exception.message(e)}"), state}
    end
  end

  # ---------------------------------------------------------------------------
  # Component tools
  # ---------------------------------------------------------------------------

  defp do_execute("insert_phia_component", args, state) do
    component = safe_to_atom(args["component"])
    attrs = atomize_map(args["attrs"] || %{})
    slots = atomize_map(args["slots"] || %{})
    parent_id = args["parent_id"]
    name = args["name"]

    opts =
      [attrs: attrs, slots: slots]
      |> maybe_add(:parent_id, parent_id)
      |> maybe_add(:name, name)

    {:ok, node} = Scene.insert_component(state.scene, component, opts)
    {text_result("Inserted <.#{component}> with id: #{node.id}"), state}
  end

  defp do_execute("set_phia_attr", %{"node_id" => node_id, "attrs" => attrs}, state) do
    atomized = atomize_map(attrs)

    case Scene.update_attrs(state.scene, node_id, atomized) do
      {:ok, node} ->
        {text_result("Updated attrs on #{node.name} (#{node_id})"), state}

      {:error, reason} ->
        {text_result("Error: #{inspect(reason)}"), state}
    end
  end

  defp do_execute("set_phia_slot", args, state) do
    node_id = args["node_id"]
    slot_name = safe_to_atom(args["slot_name"])
    content = args["content"]

    case Scene.get_node(state.scene, node_id) do
      {:ok, node} ->
        new_slots = Map.put(node.slots, slot_name, content)
        Scene.update_node(state.scene, node_id, %{slots: new_slots})
        {text_result("Set slot :#{slot_name} on #{node.name}"), state}

      {:error, _} ->
        {text_result("Error: node #{node_id} not found"), state}
    end
  end

  defp do_execute("delete_phia_node", %{"node_id" => node_id}, state) do
    case Scene.delete_node(state.scene, node_id) do
      :ok ->
        {text_result("Deleted node #{node_id} and its children"), state}

      {:error, _} ->
        {text_result("Error: node #{node_id} not found"), state}
    end
  end

  defp do_execute("move_phia_node", args, state) do
    node_id = args["node_id"]
    new_parent_id = args["new_parent_id"]
    index = args["index"] || -1

    case Scene.move_node(state.scene, node_id, new_parent_id, index) do
      {:ok, _node} ->
        parent_desc = if new_parent_id, do: "under #{new_parent_id}", else: "to root"
        {text_result("Moved #{node_id} #{parent_desc} at index #{index}"), state}

      {:error, reason} ->
        {text_result("Error: #{inspect(reason)}"), state}
    end
  end

  # ---------------------------------------------------------------------------
  # Catalog tools
  # ---------------------------------------------------------------------------

  defp do_execute("get_phia_component_info", %{"component" => name}, state) do
    key = safe_to_atom(name)

    case Introspector.get_component_info(key) do
      nil ->
        {text_result("Component '#{name}' not found in registry"), state}

      info ->
        formatted = format_component_info(info)
        {text_result(formatted), state}
    end
  end

  defp do_execute("get_phia_catalog", args, state) do
    tier_filter = args["tier"]

    components =
      if tier_filter do
        CatalogServer.all()
        |> Enum.filter(&(to_string(&1.tier) == tier_filter))
      else
        CatalogServer.all()
      end

    grouped =
      components
      |> Enum.group_by(& &1.tier)
      |> Enum.sort_by(fn {tier, _} -> to_string(tier) end)
      |> Enum.map(fn {tier, comps} ->
        names = Enum.map(comps, & &1.name) |> Enum.sort()
        "## #{tier} (#{length(comps)})\n#{Enum.join(names, ", ")}"
      end)
      |> Enum.join("\n\n")

    total = length(components)
    {text_result("PhiaUI Catalog — #{total} components\n\n#{grouped}"), state}
  end

  defp do_execute("get_phia_families", _args, state) do
    families = CatalogServer.families()

    formatted =
      families
      |> Enum.map(fn fam ->
        children = Enum.map(fam.children, &to_string/1) |> Enum.join(", ")
        "#{fam.root_name}: #{to_string(fam.root)} + [#{children}]"
      end)
      |> Enum.join("\n")

    {text_result("Component families (#{length(families)}):\n\n#{formatted}"), state}
  end

  # ---------------------------------------------------------------------------
  # Layout / template tools
  # ---------------------------------------------------------------------------

  defp do_execute("insert_phia_page", %{"template" => template_name}, state) do
    key = safe_to_atom(template_name)

    case PageTemplates.apply_template(state.scene, key) do
      {:ok, _scene} ->
        count = Scene.count(state.scene)
        {text_result("Applied '#{template_name}' template. Scene now has #{count} nodes."), state}

      {:error, :unknown_template} ->
        valid = PageTemplates.keys() |> Enum.map(&to_string/1) |> Enum.join(", ")
        {text_result("Unknown template '#{template_name}'. Valid: #{valid}"), state}
    end
  end

  # ---------------------------------------------------------------------------
  # Theme tools
  # ---------------------------------------------------------------------------

  defp do_execute("set_phia_theme", %{"theme" => theme_name}, state) do
    theme = safe_to_atom(theme_name)
    {text_result("Theme set to :#{theme}"), %{state | theme: theme}}
  end

  defp do_execute("get_phia_theme", _args, state) do
    {text_result("Current theme: :#{state.theme}"), state}
  end

  # ---------------------------------------------------------------------------
  # Export tools
  # ---------------------------------------------------------------------------

  defp do_execute("export_heex", _args, state) do
    heex = HeexEmitter.emit(state.scene)

    if heex == "" do
      {text_result("Scene is empty. Insert components first."), state}
    else
      {text_result(heex), state}
    end
  end

  defp do_execute("export_liveview", args, state) do
    module_name = args["module_name"] || "MyAppWeb.DesignedLive"
    web_module = args["web_module"] || "MyAppWeb"

    code = LiveviewEmitter.emit(state.scene, module_name, web_module: web_module)

    hooks = Scene.hooks_needed(state.scene)
    commands = LiveviewEmitter.required_add_commands(Scene.components_used(state.scene))

    footer =
      if hooks != [] or commands != [] do
        parts = []

        parts =
          if hooks != [] do
            parts ++ ["\n# Required JS hooks: #{Enum.join(hooks, ", ")}"]
          else
            parts
          end

        parts =
          if commands != [] do
            parts ++ ["\n# Install commands:\n# " <> Enum.join(commands, "\n# ")]
          else
            parts
          end

        Enum.join(parts)
      else
        ""
      end

    {text_result(code <> footer), state}
  end

  # ---------------------------------------------------------------------------
  # Scene tools
  # ---------------------------------------------------------------------------

  defp do_execute("get_scene_tree", _args, state) do
    tree = Scene.to_tree(state.scene)

    if tree == [] do
      {text_result("Scene is empty."), state}
    else
      json_tree = Enum.map(tree, &tree_node_to_map/1)
      {text_result(Jason.encode!(json_tree, pretty: true)), state}
    end
  end

  defp do_execute("clear_scene", _args, state) do
    old_count = Scene.count(state.scene)
    Scene.destroy(state.scene)
    new_scene = Scene.new()
    {text_result("Cleared #{old_count} nodes."), %{state | scene: new_scene}}
  end

  # ---------------------------------------------------------------------------
  # Batch design tools
  # ---------------------------------------------------------------------------

  defp do_execute("batch_design", %{"operations" => operations}, state) do
    case BatchDesign.execute(state.scene, operations) do
      {:ok, results, bindings} ->
        output = %{
          "results" => results,
          "bindings" => bindings,
          "node_count" => Scene.count(state.scene)
        }

        {text_result(Jason.encode!(output, pretty: true)), state}

      {:error, message, index} ->
        {text_result("Error at operation #{index}: #{message}"), state}
    end
  end

  defp do_execute("batch_get", args, state) do
    case BatchGet.execute(state.scene, args) do
      {:ok, results} ->
        {text_result(Jason.encode!(results, pretty: true)), state}
    end
  end

  defp do_execute("snapshot_layout", args, state) do
    case SnapshotLayout.execute(state.scene, args) do
      {:ok, tree} ->
        output = serialize_snapshot(tree)
        {text_result(Jason.encode!(output, pretty: true)), state}
    end
  end

  # ---------------------------------------------------------------------------
  # Variable tools
  # ---------------------------------------------------------------------------

  defp do_execute("get_phia_variables", _args, state) do
    vars = Variables.get_all(state.scene)

    formatted =
      Map.new(vars, fn {name, definition} ->
        {name, %{
          "value" => definition.value,
          "type" => to_string(definition.type),
          "theme_overrides" => Map.new(definition.theme_overrides, fn {k, v} ->
            {to_string(k), v}
          end)
        }}
      end)

    {text_result(Jason.encode!(formatted, pretty: true)), state}
  end

  defp do_execute("set_phia_variables", args, state) do
    # Handle deletions
    if deletes = args["delete"] do
      Enum.each(deletes, &Variables.delete(state.scene, &1))
    end

    # Handle sets/updates
    if variables = args["variables"] do
      normalized =
        Map.new(variables, fn {name, def_map} ->
          {name, %{
            value: def_map["value"],
            type: safe_to_atom(def_map["type"] || "string"),
            theme_overrides: Map.new(def_map["theme_overrides"] || %{}, fn {k, v} ->
              {safe_to_atom(k), v}
            end)
          }}
        end)

      Variables.put_all(state.scene, normalized)
    end

    count = map_size(Variables.get_all(state.scene))
    {text_result("Variables updated. #{count} variables defined."), state}
  end

  # Unknown tool
  defp do_execute(tool_name, _args, state) do
    {text_result("Unknown tool: #{tool_name}"), state}
  end

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  defp text_result(text) do
    %{"content" => [%{"type" => "text", "text" => text}]}
  end

  defp safe_to_atom(str) when is_binary(str) do
    String.to_existing_atom(str)
  rescue
    ArgumentError -> String.to_atom(str)
  end

  defp atomize_map(map) when is_map(map) do
    Map.new(map, fn {k, v} ->
      key =
        if is_binary(k) do
          safe_to_atom(k)
        else
          k
        end

      value = coerce_value(v)
      {key, value}
    end)
  end

  # Coerce string values to appropriate Elixir types
  defp coerce_value("true"), do: true
  defp coerce_value("false"), do: false

  defp coerce_value(":" <> rest) do
    safe_to_atom(rest)
  end

  defp coerce_value(v) when is_binary(v) do
    case Integer.parse(v) do
      {int, ""} -> int
      _ ->
        case Float.parse(v) do
          {f, ""} -> f
          _ -> v
        end
    end
  end

  defp coerce_value(v) when is_integer(v), do: v
  defp coerce_value(v) when is_float(v), do: v
  defp coerce_value(true), do: true
  defp coerce_value(false), do: false
  defp coerce_value(nil), do: nil
  defp coerce_value(v) when is_list(v), do: Enum.map(v, &coerce_value/1)
  defp coerce_value(v) when is_map(v), do: atomize_map(v)
  defp coerce_value(v), do: v

  defp maybe_add(opts, _key, nil), do: opts
  defp maybe_add(opts, key, value), do: Keyword.put(opts, key, value)

  defp format_component_info(info) do
    attrs_text =
      info.attrs
      |> Enum.map(fn a ->
        req = if a.required, do: " (required)", else: ""
        vals = if a.values, do: " values: #{inspect(a.values)}", else: ""
        default = if a[:default], do: " default: #{inspect(a[:default])}", else: ""
        "  #{a.name}: #{a.type}#{req}#{vals}#{default}"
      end)
      |> Enum.join("\n")

    slots_text =
      info.slots
      |> Enum.map(fn s ->
        req = if s.required, do: " (required)", else: ""
        "  #{s.name}#{req}"
      end)
      |> Enum.join("\n")

    hooks = info.js_hooks |> Enum.join(", ")
    hooks_line = if hooks != "", do: "\nJS Hooks: #{hooks}", else: ""

    """
    Component: #{info.name}
    Module: #{inspect(info.module)}
    Tier: #{info.tier}#{hooks_line}

    Attrs:
    #{attrs_text}

    Slots:
    #{slots_text}
    """
    |> String.trim()
  end

  defp tree_node_to_map(nil), do: nil

  defp tree_node_to_map(%{node: node, children: children}) do
    base = %{
      "id" => node.id,
      "type" => to_string(node.type),
      "name" => node.name
    }

    base =
      case node.type do
        :phia_component ->
          base
          |> Map.put("component", to_string(node.component))
          |> Map.put("attrs", stringify_map(node.attrs))
          |> Map.put("slots", stringify_map(node.slots))

        :html_element ->
          base
          |> Map.put("tag", node.tag)
          |> Map.put("classes", node.classes)

        :text ->
          Map.put(base, "text_content", node.text_content)

        :frame ->
          Map.put(base, "classes", node.classes)

        _ ->
          base
      end

    if children != [] do
      Map.put(base, "children", Enum.map(children, &tree_node_to_map/1))
    else
      base
    end
  end

  defp stringify_map(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {to_string(k), stringify_value(v)} end)
  end

  defp stringify_map(other), do: other

  defp stringify_value(v) when is_atom(v) and not is_nil(v) and not is_boolean(v),
    do: ":#{v}"

  defp stringify_value(v), do: v

  defp serialize_snapshot(tree) when is_list(tree) do
    Enum.map(tree, &serialize_snapshot_node/1)
  end

  defp serialize_snapshot_node(%{bbox: bbox, children: children} = entry) do
    %{
      "id" => entry.id,
      "name" => entry.name,
      "type" => entry.type,
      "bbox" => %{
        "x" => bbox.x,
        "y" => bbox.y,
        "width" => bbox.width,
        "height" => bbox.height
      },
      "problems" => entry.problems,
      "children" => Enum.map(children, &serialize_snapshot_node/1)
    }
  end

  defp serialize_snapshot_node(%{bbox: bbox} = entry) do
    %{
      "id" => entry.id,
      "name" => entry.name,
      "type" => entry.type,
      "bbox" => %{
        "x" => bbox.x,
        "y" => bbox.y,
        "width" => bbox.width,
        "height" => bbox.height
      },
      "problems" => entry.problems
    }
  end
end
