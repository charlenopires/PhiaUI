defmodule PhiaUiDesign.Canvas.Persistence do
  @moduledoc """
  Save and load design scenes to/from `.phia.json` files.

  Scenes are serialized as JSON containing a flat list of nodes with their
  parent-child relationships. On load, the nodes are inserted back into a
  fresh ETS scene table.

  ## File format

      {
        "version": 1,
        "name": "My Dashboard",
        "theme": "zinc",
        "nodes": [
          {
            "id": "abc123",
            "type": "phia_component",
            "component": "button",
            "attrs": {"variant": ":default"},
            "slots": {"inner_block": "Click me"},
            "parent_id": null,
            "children": ["def456"],
            "name": "My Button"
          }
        ],
        "root_children": ["abc123"]
      }
  """

  alias PhiaUiDesign.Canvas.{Scene, Node}

  @format_version 1

  # ---------------------------------------------------------------------------
  # Save
  # ---------------------------------------------------------------------------

  @doc """
  Save a scene to a `.phia.json` file.

  Options:
  - `:theme` — current theme atom (default: `:zinc`)
  """
  @spec save(reference(), Path.t(), keyword()) :: :ok | {:error, term()}
  def save(scene, path, opts \\ []) do
    theme = Keyword.get(opts, :theme, :zinc)
    meta = get_meta(scene)
    nodes = Scene.all_nodes(scene)
    root_children = Scene.get_root_children(scene)

    data = %{
      "version" => @format_version,
      "name" => meta[:name] || "Untitled",
      "theme" => to_string(theme),
      "root_children" => root_children,
      "nodes" => Enum.map(nodes, &serialize_node/1)
    }

    dir = Path.dirname(path)
    File.mkdir_p!(dir)

    case Jason.encode(data, pretty: true) do
      {:ok, json} -> File.write(path, json)
      {:error, reason} -> {:error, reason}
    end
  end

  # ---------------------------------------------------------------------------
  # Load
  # ---------------------------------------------------------------------------

  @doc """
  Load a scene from a `.phia.json` file.

  Returns `{:ok, scene, metadata}` where metadata includes `:theme` and `:name`.
  """
  @spec load(Path.t()) :: {:ok, reference(), map()} | {:error, term()}
  def load(path) do
    with {:ok, content} <- File.read(path),
         {:ok, data} <- Jason.decode(content) do
      scene = Scene.new()
      nodes = data["nodes"] || []
      root_children = data["root_children"] || []

      # First pass: insert all nodes without parent relationships
      for node_data <- nodes do
        node = deserialize_node(node_data)
        :ets.insert(scene, {node.id, node})
      end

      # Set root children
      :ets.insert(scene, {:__root_children__, root_children})

      # Update meta
      :ets.insert(scene, {:__meta__, %{
        name: data["name"] || "Untitled",
        created_at: DateTime.utc_now()
      }})

      metadata = %{
        theme: safe_to_atom(data["theme"] || "zinc"),
        name: data["name"] || "Untitled",
        version: data["version"] || 1
      }

      {:ok, scene, metadata}
    end
  end

  # ---------------------------------------------------------------------------
  # List projects
  # ---------------------------------------------------------------------------

  @doc """
  List all `.phia.json` files in a directory.
  """
  @spec list_projects(Path.t()) :: [map()]
  def list_projects(dir) do
    dir
    |> Path.join("*.phia.json")
    |> Path.wildcard()
    |> Enum.map(fn path ->
      case File.read(path) do
        {:ok, content} ->
          case Jason.decode(content) do
            {:ok, data} ->
              %{
                path: path,
                name: data["name"] || Path.basename(path, ".phia.json"),
                node_count: length(data["nodes"] || []),
                theme: data["theme"]
              }

            _ ->
              nil
          end

        _ ->
          nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  # ---------------------------------------------------------------------------
  # Serialization
  # ---------------------------------------------------------------------------

  defp serialize_node(%Node{} = node) do
    base = %{
      "id" => node.id,
      "type" => to_string(node.type),
      "name" => node.name,
      "parent_id" => node.parent_id,
      "children" => node.children,
      "locked" => node.locked,
      "visible" => node.visible
    }

    case node.type do
      :phia_component ->
        base
        |> Map.put("component", to_string(node.component))
        |> Map.put("module", if(node.module, do: inspect(node.module)))
        |> Map.put("attrs", serialize_attrs(node.attrs))
        |> Map.put("slots", serialize_attrs(node.slots))

      :html_element ->
        base
        |> Map.put("tag", node.tag)
        |> Map.put("classes", node.classes)
        |> Map.put("attrs", serialize_attrs(node.attrs))

      :text ->
        Map.put(base, "text_content", node.text_content)

      :frame ->
        Map.put(base, "classes", node.classes)

      _ ->
        base
    end
  end

  defp serialize_attrs(map) when is_map(map) do
    Map.new(map, fn {k, v} ->
      {to_string(k), serialize_value(v)}
    end)
  end

  defp serialize_attrs(_), do: %{}

  defp serialize_value(v) when is_atom(v) and not is_nil(v) and not is_boolean(v),
    do: ":#{v}"

  defp serialize_value(v), do: v

  # ---------------------------------------------------------------------------
  # Deserialization
  # ---------------------------------------------------------------------------

  defp deserialize_node(data) do
    type = safe_to_atom(data["type"])

    base = %Node{
      id: data["id"],
      type: type,
      name: data["name"] || "",
      parent_id: data["parent_id"],
      children: data["children"] || [],
      locked: data["locked"] || false,
      visible: Map.get(data, "visible", true)
    }

    case type do
      :phia_component ->
        component = safe_to_atom(data["component"])
        module = resolve_module(data["module"])

        %{base |
          component: component,
          module: module,
          attrs: deserialize_attrs(data["attrs"] || %{}),
          slots: deserialize_attrs(data["slots"] || %{})
        }

      :html_element ->
        %{base |
          tag: data["tag"],
          classes: data["classes"],
          attrs: deserialize_attrs(data["attrs"] || %{})
        }

      :text ->
        %{base | text_content: data["text_content"]}

      :frame ->
        %{base | classes: data["classes"]}

      _ ->
        base
    end
  end

  defp deserialize_attrs(map) when is_map(map) do
    Map.new(map, fn {k, v} ->
      {safe_to_atom(k), deserialize_value(v)}
    end)
  end

  defp deserialize_attrs(_), do: %{}

  defp deserialize_value(":" <> rest), do: safe_to_atom(rest)
  defp deserialize_value("true"), do: true
  defp deserialize_value("false"), do: false
  defp deserialize_value(v), do: v

  defp resolve_module(nil), do: nil

  defp resolve_module(module_string) when is_binary(module_string) do
    module_string
    |> String.trim_leading("Elixir.")
    |> then(fn s -> "Elixir." <> s end)
    |> String.to_existing_atom()
  rescue
    ArgumentError -> nil
  end

  defp safe_to_atom(str) when is_binary(str) do
    String.to_existing_atom(str)
  rescue
    ArgumentError -> String.to_atom(str)
  end

  defp safe_to_atom(atom) when is_atom(atom), do: atom

  defp get_meta(scene) do
    case :ets.lookup(scene, :__meta__) do
      [{:__meta__, meta}] -> meta
      _ -> %{}
    end
  end
end
