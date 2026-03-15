defmodule PhiaUiDesign.Mcp.BatchDesign do
  @moduledoc """
  Execute multiple design operations atomically with bindings and rollback.

  Parses a JSON-based DSL of operations (Insert, Copy, Update, Replace,
  Move, Delete) and executes them sequentially against the scene ETS.
  If any operation fails, the entire batch is rolled back to the pre-execution
  snapshot.

  ## Operations

  | Op  | Action  | Required fields                          |
  |-----|---------|------------------------------------------|
  | `I` | Insert  | `parent`, `data` (type, component/tag)   |
  | `C` | Copy    | `id`, `parent`                           |
  | `U` | Update  | `id`, `data` (attrs/slots/classes/layout) |
  | `R` | Replace | `id`, `data` (new node definition)        |
  | `M` | Move    | `id`, `parent`, optional `index`         |
  | `D` | Delete  | `id`                                     |

  ## Bindings

  Operations with `"bind"` store the created/resulting node ID.
  Subsequent operations can reference `"$binding_name"` in `id` or `parent` fields.

  ## Limits

  Maximum 25 operations per batch (matching OpenPencil convention).
  """

  alias PhiaUiDesign.Canvas.{Scene, Node}

  @max_operations 25

  @doc """
  Execute a batch of operations against the scene.

  Returns `{:ok, results, bindings}` on success or `{:error, message, op_index}` on failure.
  On failure, the scene is rolled back to its pre-execution state.
  """
  @spec execute(reference(), [map()], map()) :: {:ok, [map()], map()} | {:error, String.t(), integer()}
  def execute(scene, operations, state \\ %{}) do
    _ = state

    if length(operations) > @max_operations do
      {:error, "Maximum #{@max_operations} operations per batch (got #{length(operations)})", -1}
    else
      snapshot = :ets.tab2list(scene)
      do_execute(scene, operations, snapshot)
    end
  end

  # ---------------------------------------------------------------------------
  # Execution loop
  # ---------------------------------------------------------------------------

  defp do_execute(scene, operations, snapshot) do
    result =
      operations
      |> Enum.with_index()
      |> Enum.reduce_while({[], %{}}, fn {op, index}, {results, bindings} ->
        case execute_op(scene, op, bindings) do
          {:ok, result} ->
            new_bindings = maybe_store_binding(bindings, op, result)
            {:cont, {results ++ [Map.put(result, "index", index)], new_bindings}}

          {:error, reason} ->
            rollback(scene, snapshot)
            {:halt, {:error, reason, index}}
        end
      end)

    case result do
      {:error, reason, index} -> {:error, reason, index}
      {results, bindings} -> {:ok, results, bindings}
    end
  end

  # ---------------------------------------------------------------------------
  # Operation dispatch
  # ---------------------------------------------------------------------------

  defp execute_op(scene, %{"op" => "I"} = op, bindings) do
    parent_id = resolve_ref(op["parent"], bindings)
    data = op["data"] || %{}
    type = data["type"] || "frame"

    case type do
      "phia_component" ->
        insert_component(scene, parent_id, data)

      "html_element" ->
        insert_element(scene, parent_id, data)

      "text" ->
        insert_text(scene, parent_id, data)

      _ ->
        insert_frame(scene, parent_id, data)
    end
  end

  defp execute_op(scene, %{"op" => "C"} = op, bindings) do
    source_id = resolve_ref(op["id"], bindings)
    parent_id = resolve_ref(op["parent"], bindings)
    overrides = op["data"] || %{}

    deep_copy(scene, source_id, parent_id, overrides)
  end

  defp execute_op(scene, %{"op" => "U"} = op, bindings) do
    node_id = resolve_ref(op["id"], bindings)
    data = op["data"] || %{}

    update_node(scene, node_id, data)
  end

  defp execute_op(scene, %{"op" => "R"} = op, bindings) do
    node_id = resolve_ref(op["id"], bindings)
    data = op["data"] || %{}

    replace_node(scene, node_id, data)
  end

  defp execute_op(scene, %{"op" => "M"} = op, bindings) do
    node_id = resolve_ref(op["id"], bindings)
    parent_id = resolve_ref(op["parent"], bindings)
    index = op["index"] || -1

    move_node(scene, node_id, parent_id, index)
  end

  defp execute_op(scene, %{"op" => "D"} = op, bindings) do
    node_id = resolve_ref(op["id"], bindings)

    delete_node(scene, node_id)
  end

  defp execute_op(_scene, %{"op" => op}, _bindings) do
    {:error, "Unknown operation: #{op}"}
  end

  defp execute_op(_scene, op, _bindings) do
    {:error, "Missing 'op' field in operation: #{inspect(op)}"}
  end

  # ---------------------------------------------------------------------------
  # Insert operations
  # ---------------------------------------------------------------------------

  defp insert_component(scene, parent_id, data) do
    component = safe_to_atom(data["component"] || "div")
    attrs = atomize_map(data["attrs"] || %{})
    slots = atomize_map(data["slots"] || %{})
    name = data["name"]
    layout_opts = extract_layout_opts(data)

    registry_entry = PhiaUi.ComponentRegistry.get(component)

    node =
      Node.new_component(component,
        module: registry_entry && registry_entry.module,
        attrs: attrs,
        slots: slots,
        parent_id: parent_id,
        name: name || to_string(component)
      )

    node = apply_layout_opts(node, layout_opts)
    {:ok, _} = Scene.insert(scene, node)
    {:ok, %{"op" => "I", "id" => node.id, "status" => "ok"}}
  end

  defp insert_element(scene, parent_id, data) do
    tag = data["tag"] || "div"
    classes = data["classes"]
    name = data["name"] || tag
    layout_opts = extract_layout_opts(data)

    node = Node.new_element(tag, parent_id: parent_id, classes: classes, name: name)
    node = apply_layout_opts(node, layout_opts)
    {:ok, _} = Scene.insert(scene, node)
    {:ok, %{"op" => "I", "id" => node.id, "status" => "ok"}}
  end

  defp insert_text(scene, parent_id, data) do
    content = data["content"] || data["text_content"] || ""
    name = data["name"]

    opts = [parent_id: parent_id]
    opts = if name, do: Keyword.put(opts, :name, name), else: opts

    node = Node.new_text(content, opts)
    {:ok, _} = Scene.insert(scene, node)
    {:ok, %{"op" => "I", "id" => node.id, "status" => "ok"}}
  end

  defp insert_frame(scene, parent_id, data) do
    classes = data["classes"]
    name = data["name"] || "Frame"
    layout_opts = extract_layout_opts(data)

    node = Node.new_frame(parent_id: parent_id, classes: classes, name: name)
    node = apply_layout_opts(node, layout_opts)
    {:ok, _} = Scene.insert(scene, node)
    {:ok, %{"op" => "I", "id" => node.id, "status" => "ok"}}
  end

  # ---------------------------------------------------------------------------
  # Copy (deep clone)
  # ---------------------------------------------------------------------------

  defp deep_copy(scene, source_id, parent_id, overrides) do
    case Scene.get_node(scene, source_id) do
      {:ok, source} ->
        do_deep_copy(scene, source, parent_id, overrides)

      {:error, _} ->
        {:error, "Node #{source_id} not found for copy"}
    end
  end

  defp do_deep_copy(scene, source, parent_id, overrides) do
    new_id = generate_id()

    new_node = %{source |
      id: new_id,
      parent_id: parent_id,
      children: []
    }

    # Apply overrides
    new_node =
      if attrs = overrides["attrs"] do
        %{new_node | attrs: Map.merge(new_node.attrs, atomize_map(attrs))}
      else
        new_node
      end

    new_node =
      if name = overrides["name"] do
        %{new_node | name: name}
      else
        new_node
      end

    {:ok, _} = Scene.insert(scene, new_node)

    # Recursively copy children
    for child_id <- source.children do
      case Scene.get_node(scene, child_id) do
        {:ok, child} -> do_deep_copy(scene, child, new_id, %{})
        _ -> :ok
      end
    end

    {:ok, %{"op" => "C", "id" => new_id, "status" => "ok"}}
  end

  # ---------------------------------------------------------------------------
  # Update
  # ---------------------------------------------------------------------------

  defp update_node(scene, node_id, data) do
    case Scene.get_node(scene, node_id) do
      {:ok, node} ->
        changes = %{}

        changes =
          if attrs = data["attrs"] do
            Map.put(changes, :attrs, Map.merge(node.attrs, atomize_map(attrs)))
          else
            changes
          end

        changes =
          if slots = data["slots"] do
            Map.put(changes, :slots, Map.merge(node.slots, atomize_map(slots)))
          else
            changes
          end

        changes =
          if classes = data["classes"] do
            Map.put(changes, :classes, classes)
          else
            changes
          end

        changes =
          if name = data["name"] do
            Map.put(changes, :name, name)
          else
            changes
          end

        # Layout property updates
        layout_opts = extract_layout_opts(data)
        changes = Map.merge(changes, layout_opts)

        {:ok, _} = Scene.update_node(scene, node_id, changes)
        {:ok, %{"op" => "U", "id" => node_id, "status" => "ok"}}

      {:error, _} ->
        {:error, "Node #{node_id} not found for update"}
    end
  end

  # ---------------------------------------------------------------------------
  # Replace
  # ---------------------------------------------------------------------------

  defp replace_node(scene, node_id, data) do
    case Scene.get_node(scene, node_id) do
      {:ok, old_node} ->
        parent_id = old_node.parent_id

        # Delete old node (but remember its position)
        siblings =
          if parent_id do
            case Scene.get_node(scene, parent_id) do
              {:ok, parent} -> parent.children
              _ -> []
            end
          else
            Scene.get_root_children(scene)
          end

        index = Enum.find_index(siblings, &(&1 == node_id)) || -1

        # Delete old (including children)
        Scene.delete_node(scene, node_id)

        # Insert new at same position
        type = data["type"] || "frame"

        result =
          case type do
            "phia_component" -> insert_component(scene, parent_id, data)
            "html_element" -> insert_element(scene, parent_id, data)
            "text" -> insert_text(scene, parent_id, data)
            _ -> insert_frame(scene, parent_id, data)
          end

        case result do
          {:ok, %{"id" => new_id} = res} ->
            # Move to original position
            if index >= 0 do
              Scene.move_node(scene, new_id, parent_id, index)
            end

            {:ok, %{res | "op" => "R"}}

          error ->
            error
        end

      {:error, _} ->
        {:error, "Node #{node_id} not found for replace"}
    end
  end

  # ---------------------------------------------------------------------------
  # Move
  # ---------------------------------------------------------------------------

  defp move_node(scene, node_id, parent_id, index) do
    # Circular move detection
    if parent_id && is_descendant?(scene, parent_id, node_id) do
      {:error, "Cannot move node #{node_id} into its own descendant #{parent_id}"}
    else
      case Scene.move_node(scene, node_id, parent_id, index) do
        {:ok, _} -> {:ok, %{"op" => "M", "id" => node_id, "status" => "ok"}}
        {:error, reason} -> {:error, "Move failed: #{inspect(reason)}"}
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Delete
  # ---------------------------------------------------------------------------

  defp delete_node(scene, node_id) do
    case Scene.delete_node(scene, node_id) do
      :ok -> {:ok, %{"op" => "D", "id" => node_id, "status" => "ok"}}
      {:error, _} -> {:error, "Node #{node_id} not found for delete"}
    end
  end

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  defp resolve_ref(nil, _bindings), do: nil
  defp resolve_ref("$" <> name, bindings), do: Map.get(bindings, name)
  defp resolve_ref(value, _bindings), do: value

  defp maybe_store_binding(bindings, %{"bind" => name}, %{"id" => id}) when is_binary(name) do
    Map.put(bindings, name, id)
  end

  defp maybe_store_binding(bindings, _op, _result), do: bindings

  defp rollback(scene, snapshot) do
    # Clear all entries
    :ets.delete_all_objects(scene)
    # Restore snapshot
    :ets.insert(scene, snapshot)
  end

  defp is_descendant?(scene, candidate_parent, ancestor_id) do
    case Scene.get_node(scene, candidate_parent) do
      {:ok, node} ->
        cond do
          node.parent_id == ancestor_id -> true
          node.parent_id == nil -> false
          true -> is_descendant?(scene, node.parent_id, ancestor_id)
        end

      _ ->
        false
    end
  end

  defp extract_layout_opts(data) do
    layout_keys = ~w(layout gap padding justify_content align_items wrap width height)

    Enum.reduce(layout_keys, %{}, fn key, acc ->
      case Map.get(data, key) do
        nil -> acc
        value -> Map.put(acc, safe_to_atom(key), coerce_layout_value(key, value))
      end
    end)
  end

  defp apply_layout_opts(node, opts) when map_size(opts) == 0, do: node
  defp apply_layout_opts(node, opts), do: Map.merge(node, opts)

  defp coerce_layout_value("layout", v) when is_binary(v), do: safe_to_atom(v)
  defp coerce_layout_value("justify_content", v) when is_binary(v), do: safe_to_atom(v)
  defp coerce_layout_value("align_items", v) when is_binary(v), do: safe_to_atom(v)
  defp coerce_layout_value("wrap", v) when is_boolean(v), do: v
  defp coerce_layout_value("wrap", "true"), do: true
  defp coerce_layout_value("wrap", _), do: false

  defp coerce_layout_value("width", "fill"), do: :fill
  defp coerce_layout_value("width", "hug"), do: :hug
  defp coerce_layout_value("width", v) when is_integer(v), do: v
  defp coerce_layout_value("width", v) when is_binary(v), do: maybe_parse_int(v)

  defp coerce_layout_value("height", "fill"), do: :fill
  defp coerce_layout_value("height", "hug"), do: :hug
  defp coerce_layout_value("height", v) when is_integer(v), do: v
  defp coerce_layout_value("height", v) when is_binary(v), do: maybe_parse_int(v)

  defp coerce_layout_value("gap", v) when is_integer(v), do: v
  defp coerce_layout_value("gap", v) when is_binary(v), do: maybe_parse_int(v)

  defp coerce_layout_value("padding", v) when is_integer(v), do: v
  defp coerce_layout_value("padding", v) when is_list(v), do: v
  defp coerce_layout_value("padding", v) when is_binary(v), do: maybe_parse_int(v)

  defp coerce_layout_value(_key, v), do: v

  defp maybe_parse_int(s) do
    case Integer.parse(s) do
      {i, ""} -> i
      _ -> s
    end
  end

  defp generate_id do
    :crypto.strong_rand_bytes(8) |> Base.url_encode64(padding: false)
  end

  defp safe_to_atom(str) when is_binary(str) do
    String.to_existing_atom(str)
  rescue
    ArgumentError -> String.to_atom(str)
  end

  defp safe_to_atom(atom) when is_atom(atom), do: atom

  defp atomize_map(map) when is_map(map) do
    Map.new(map, fn {k, v} ->
      key = if is_binary(k), do: safe_to_atom(k), else: k
      {key, coerce_value(v)}
    end)
  end

  defp coerce_value("true"), do: true
  defp coerce_value("false"), do: false
  defp coerce_value(":" <> rest), do: safe_to_atom(rest)

  defp coerce_value(v) when is_binary(v) do
    case Integer.parse(v) do
      {int, ""} -> int
      _ -> v
    end
  end

  defp coerce_value(v), do: v
end
