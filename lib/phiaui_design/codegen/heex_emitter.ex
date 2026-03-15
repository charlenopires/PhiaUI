defmodule PhiaUiDesign.Codegen.HeexEmitter do
  @moduledoc """
  Converts a scene graph into a valid HEEx template string.

  Walks the tree returned by `Scene.to_tree/1` and emits properly indented
  HEEx markup. Each node type maps to a different output form:

  - `:phia_component` - `<.button variant={:primary}>Label</.button>`
  - `:html_element`   - `<div class="flex gap-4">...</div>`
  - `:text`           - plain text content
  - `:frame`          - rendered as a `<div>` wrapper

  Named slots are emitted as `<:slot_name>content</:slot_name>` inside the
  component tag. The special `:inner_block` / `"inner_block"` slot is
  rendered as direct text content (not wrapped in a slot tag).
  """

  alias PhiaUiDesign.Canvas.{Scene, Node, Layout}
  alias PhiaUiDesign.Codegen.AttrFormatter

  @void_elements ~w(area base br col embed hr img input link meta param source track wbr)

  @doc """
  Emit a complete HEEx string from an entire scene.

  ## Options

  - `:indent` - initial indentation level (default: `0`)
  - `:indent_size` - number of spaces per indent level (default: `2`)

  ## Examples

      scene = Scene.new()
      {:ok, _} = Scene.insert_component(scene, :button, attrs: %{variant: :primary})
      HeexEmitter.emit(scene)
      #=> ~s(<.button variant={:primary} />)
  """
  @spec emit(reference(), keyword()) :: String.t()
  def emit(scene, opts \\ []) do
    tree = Scene.to_tree(scene)
    indent = Keyword.get(opts, :indent, 0)
    indent_size = Keyword.get(opts, :indent_size, 2)

    tree
    |> Enum.map(&emit_tree_node(&1, indent, indent_size))
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("\n")
    |> String.trim_trailing()
  end

  @doc """
  Emit HEEx for a single node (looked up by ID) and all its descendants.

  Returns an empty string if the node is not found.

  ## Options

  Same as `emit/2`.
  """
  @spec emit_node(reference(), String.t(), keyword()) :: String.t()
  def emit_node(scene, node_id, opts \\ []) do
    indent = Keyword.get(opts, :indent, 0)
    indent_size = Keyword.get(opts, :indent_size, 2)

    case Scene.get_node(scene, node_id) do
      {:ok, node} ->
        tree_node = %{node: node, children: build_children(scene, node)}
        emit_tree_node(tree_node, indent, indent_size)

      _ ->
        ""
    end
  end

  # ---------------------------------------------------------------------------
  # Tree walking
  # ---------------------------------------------------------------------------

  defp build_children(scene, %Node{children: child_ids}) do
    child_ids
    |> Enum.map(fn id ->
      case Scene.get_node(scene, id) do
        {:ok, child} -> %{node: child, children: build_children(scene, child)}
        _ -> nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  # ---------------------------------------------------------------------------
  # Node type dispatch
  # ---------------------------------------------------------------------------

  defp emit_tree_node(nil, _indent, _size), do: ""

  defp emit_tree_node(%{node: %Node{type: :text} = node}, indent, _size) do
    pad(indent) <> (node.text_content || "")
  end

  defp emit_tree_node(%{node: %Node{type: :phia_component} = node, children: children}, indent, size) do
    emit_component(node, children, indent, size)
  end

  defp emit_tree_node(%{node: %Node{type: :html_element} = node, children: children}, indent, size) do
    emit_html_element(node, children, indent, size)
  end

  defp emit_tree_node(%{node: %Node{type: :frame} = node, children: children}, indent, size) do
    # Frames render as plain <div> wrappers with layout classes merged
    layout_classes = Layout.to_classes(node)

    merged_classes =
      case {node.classes, layout_classes} do
        {nil, ""} -> nil
        {nil, lc} -> lc
        {c, ""} -> c
        {c, lc} -> "#{lc} #{c}"
      end

    div_node = %{node | type: :html_element, tag: "div", classes: merged_classes}
    emit_html_element(div_node, children, indent, size)
  end

  # ---------------------------------------------------------------------------
  # PhiaUI component rendering
  # ---------------------------------------------------------------------------

  defp emit_component(node, children, indent, size) do
    tag = ".#{node.component}"
    attrs = format_attrs_string(node.attrs)

    inner_block = extract_inner_block(node.slots)
    named_slots = format_named_slots(node.slots, indent + size)
    child_heex = emit_children(children, indent + size, size)

    # When inner_block is mixed with other content (slots or children),
    # indent it at the child level so the output is well-formatted.
    inner_block_indented =
      if inner_block != "" and (named_slots != "" or child_heex != "") do
        pad(indent + size) <> inner_block
      else
        inner_block
      end

    content_parts =
      [inner_block_indented, named_slots, child_heex]
      |> Enum.reject(&(&1 == ""))

    case content_parts do
      [] ->
        # Self-closing
        "#{pad(indent)}<#{tag}#{attrs} />"

      parts ->
        content = Enum.join(parts, "\n")
        wrap_tag(tag, attrs, content, indent, size)
    end
  end

  # ---------------------------------------------------------------------------
  # HTML element rendering
  # ---------------------------------------------------------------------------

  defp emit_html_element(node, children, indent, size) do
    tag = node.tag || "div"
    attrs = build_element_attrs(node)
    child_heex = emit_children(children, indent + size, size)

    cond do
      child_heex == "" and tag in @void_elements ->
        "#{pad(indent)}<#{tag}#{attrs} />"

      child_heex == "" ->
        "#{pad(indent)}<#{tag}#{attrs}></#{tag}>"

      true ->
        wrap_tag(tag, attrs, child_heex, indent, size)
    end
  end

  # Build the combined attrs string for an HTML element node.
  # The `classes` field is merged into attrs as the `:class` key.
  defp build_element_attrs(%Node{classes: nil, attrs: attrs}), do: format_attrs_string(attrs)

  defp build_element_attrs(%Node{classes: classes, attrs: attrs}) do
    merged = Map.put(attrs, :class, classes)
    format_attrs_string(merged)
  end

  # ---------------------------------------------------------------------------
  # Slots
  # ---------------------------------------------------------------------------

  # Extract the inner_block content (rendered as direct text, not a slot tag).
  defp extract_inner_block(slots) when map_size(slots) == 0, do: ""

  defp extract_inner_block(slots) do
    value = Map.get(slots, :inner_block) || Map.get(slots, "inner_block")

    case value do
      text when is_binary(text) and text != "" -> text
      _ -> ""
    end
  end

  # Format named slots (everything except inner_block) as `<:name>...</:name>`.
  defp format_named_slots(slots, indent) when map_size(slots) == 0 do
    _ = indent
    ""
  end

  defp format_named_slots(slots, indent) do
    slots
    |> Enum.reject(fn {k, _v} -> k in [:inner_block, "inner_block"] end)
    |> Enum.sort_by(fn {k, _v} -> to_string(k) end)
    |> Enum.map(fn {name, content} ->
      slot_name = to_string(name)

      if String.contains?(to_string(content), "\n") do
        "#{pad(indent)}<:#{slot_name}>\n#{indent_block(to_string(content), indent + 2)}\n#{pad(indent)}</:#{slot_name}>"
      else
        "#{pad(indent)}<:#{slot_name}>#{content}</:#{slot_name}>"
      end
    end)
    |> Enum.join("\n")
  end

  # ---------------------------------------------------------------------------
  # Shared helpers
  # ---------------------------------------------------------------------------

  defp emit_children(children, indent, size) do
    children
    |> Enum.map(&emit_tree_node(&1, indent, size))
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("\n")
  end

  # Wrap content inside an opening/closing tag, deciding between single-line
  # and multi-line output based on content shape.
  defp wrap_tag(tag, attrs, content, indent, _size) do
    trimmed = String.trim(content)

    if String.contains?(content, "\n") or String.length(trimmed) > 80 do
      "#{pad(indent)}<#{tag}#{attrs}>\n#{content}\n#{pad(indent)}</#{tag}>"
    else
      "#{pad(indent)}<#{tag}#{attrs}>#{trimmed}</#{tag}>"
    end
  end

  defp format_attrs_string(attrs) when map_size(attrs) == 0, do: ""

  defp format_attrs_string(attrs) do
    formatted = AttrFormatter.format_attrs(attrs)
    if formatted == "", do: "", else: " " <> formatted
  end

  defp pad(level), do: String.duplicate(" ", level)

  defp indent_block(text, level) do
    prefix = pad(level)

    text
    |> String.split("\n")
    |> Enum.map_join("\n", fn line -> prefix <> line end)
  end
end
