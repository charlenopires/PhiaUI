defmodule PhiaUiDesign.Mcp.BatchGet do
  @moduledoc """
  Pattern-based search and batch retrieval of nodes from the scene graph.

  Supports searching by type, name (regex), component name, and specific
  node IDs. Results are returned with configurable depth for child expansion.
  """

  alias PhiaUiDesign.Canvas.{Scene, Node}

  @doc """
  Execute a batch_get query against the scene.

  ## Query params

  - `patterns` — list of pattern maps: `%{"type" => ..., "name" => ..., "component" => ...}`
  - `node_ids` — list of specific node IDs to read
  - `parent_id` — scope search to a subtree
  - `read_depth` — how deep to expand match children (default 1; `0` = node only)
  - `search_depth` — how deep to search for matches (default unlimited)

  Returns `{:ok, results}` where results is a list of serialized node maps.
  """
  @spec execute(reference(), map()) :: {:ok, [map()]}
  def execute(scene, query) do
    patterns = query["patterns"] || []
    node_ids = query["node_ids"] || []
    parent_id = query["parent_id"]
    read_depth = query["read_depth"] || 1
    _search_depth = query["search_depth"]

    # Collect matched nodes from patterns
    pattern_matches =
      if patterns == [] do
        []
      else
        candidates = collect_candidates(scene, parent_id)
        Enum.filter(candidates, fn node -> matches_any_pattern?(node, patterns) end)
      end

    # Collect nodes by ID
    id_matches =
      Enum.flat_map(node_ids, fn id ->
        case Scene.get_node(scene, id) do
          {:ok, node} -> [node]
          _ -> []
        end
      end)

    # Deduplicate by ID
    all_matches =
      (pattern_matches ++ id_matches)
      |> Enum.uniq_by(& &1.id)

    # Serialize with read_depth
    results = Enum.map(all_matches, &serialize_node(scene, &1, read_depth))

    {:ok, results}
  end

  # ---------------------------------------------------------------------------
  # Candidate collection
  # ---------------------------------------------------------------------------

  defp collect_candidates(scene, nil) do
    Scene.all_nodes(scene)
  end

  defp collect_candidates(scene, parent_id) do
    collect_subtree(scene, parent_id)
  end

  defp collect_subtree(scene, node_id) do
    case Scene.get_node(scene, node_id) do
      {:ok, node} ->
        children = Enum.flat_map(node.children, &collect_subtree(scene, &1))
        [node | children]

      _ ->
        []
    end
  end

  # ---------------------------------------------------------------------------
  # Pattern matching
  # ---------------------------------------------------------------------------

  defp matches_any_pattern?(node, patterns) do
    Enum.any?(patterns, &matches_pattern?(node, &1))
  end

  defp matches_pattern?(node, pattern) do
    type_match?(node, pattern) and
      name_match?(node, pattern) and
      component_match?(node, pattern)
  end

  defp type_match?(_node, %{"type" => nil}), do: true
  defp type_match?(_node, pattern) when not is_map_key(pattern, "type"), do: true

  defp type_match?(node, %{"type" => type}) do
    to_string(node.type) == type
  end

  defp name_match?(_node, %{"name" => nil}), do: true
  defp name_match?(_node, pattern) when not is_map_key(pattern, "name"), do: true

  defp name_match?(node, %{"name" => name_pattern}) do
    case Regex.compile(name_pattern) do
      {:ok, regex} -> Regex.match?(regex, node.name || "")
      _ -> node.name == name_pattern
    end
  end

  defp component_match?(_node, %{"component" => nil}), do: true
  defp component_match?(_node, pattern) when not is_map_key(pattern, "component"), do: true

  defp component_match?(node, %{"component" => component}) do
    to_string(node.component) == component
  end

  # ---------------------------------------------------------------------------
  # Serialization
  # ---------------------------------------------------------------------------

  defp serialize_node(_scene, %Node{} = node, 0) do
    base_map(node)
    |> maybe_add_children_truncated(node)
  end

  defp serialize_node(scene, %Node{} = node, depth) do
    base = base_map(node)

    if node.children == [] do
      base
    else
      children =
        Enum.map(node.children, fn child_id ->
          case Scene.get_node(scene, child_id) do
            {:ok, child} -> serialize_node(scene, child, depth - 1)
            _ -> %{"id" => child_id, "error" => "not_found"}
          end
        end)

      Map.put(base, "children", children)
    end
  end

  defp base_map(%Node{} = node) do
    base = %{
      "id" => node.id,
      "type" => to_string(node.type),
      "name" => node.name
    }

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
        base
        |> Map.put("classes", node.classes)
        |> maybe_add_layout(node)

      _ ->
        base
    end
  end

  defp maybe_add_children_truncated(map, %{children: []}), do: map

  defp maybe_add_children_truncated(map, %{children: children}) do
    Map.put(map, "children", Enum.map(children, fn id -> %{"id" => id, "_truncated" => true} end))
  end

  defp maybe_add_layout(map, node) do
    layout_fields = [:layout, :gap, :padding, :justify_content, :align_items, :wrap, :width, :height]

    Enum.reduce(layout_fields, map, fn field, acc ->
      case Map.get(node, field) do
        nil -> acc
        false when field == :wrap -> acc
        value -> Map.put(acc, to_string(field), stringify_value(value))
      end
    end)
  end

  defp stringify_map(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {to_string(k), stringify_value(v)} end)
  end

  defp stringify_map(other), do: other

  defp stringify_value(v) when is_atom(v) and not is_nil(v) and not is_boolean(v),
    do: ":#{v}"

  defp stringify_value(v), do: v
end
