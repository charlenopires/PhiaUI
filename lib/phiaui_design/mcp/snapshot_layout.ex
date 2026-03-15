defmodule PhiaUiDesign.Mcp.SnapshotLayout do
  @moduledoc """
  Computes approximate bounding boxes from layout properties.

  Since PhiaUI Design operates without a browser engine, bounding boxes are
  estimated from layout direction, gap, padding, and sizing properties.
  Component defaults are used for leaf nodes without explicit dimensions.
  """

  alias PhiaUiDesign.Canvas.{Scene, Node}

  @default_viewport_width 1280

  # Estimated component default sizes (width x height in px)
  @component_defaults %{
    button: {120, 40},
    badge: {80, 28},
    input: {320, 40},
    card: {320, 200},
    avatar: {40, 40},
    separator: {0, 1},
    heading: {320, 32},
    text: {320, 20},
    paragraph: {320, 60},
    lead: {320, 24},
    label: {120, 20},
    stat_card: {240, 120},
    data_table: {640, 300},
    page_header: {640, 64},
    nav_list: {200, 200},
    select: {200, 40},
    search_input: {240, 40},
    form_section: {640, 200},
    form_grid: {640, 100},
    form_actions: {640, 48},
    pricing_card: {320, 400},
    feature_card: {320, 200},
    cta_card: {640, 200}
  }

  @doc """
  Compute approximate layout bounding boxes for the scene.

  ## Options

  - `parent_id` — scope to a subtree (nil = entire scene)
  - `max_depth` — how deep to recurse (default 2)
  - `problems_only` — only return nodes with detected problems (default false)
  - `viewport_width` — root container width in px (default 1280)

  Returns `{:ok, tree}` where tree is a list of node bbox maps.
  """
  @spec execute(reference(), map()) :: {:ok, [map()]}
  def execute(scene, params \\ %{}) do
    parent_id = params["parent_id"]
    max_depth = params["max_depth"] || 2
    problems_only = params["problems_only"] || false
    viewport_width = params["viewport_width"] || @default_viewport_width

    node_ids =
      if parent_id do
        case Scene.get_node(scene, parent_id) do
          {:ok, node} -> node.children
          _ -> []
        end
      else
        Scene.get_root_children(scene)
      end

    tree =
      node_ids
      |> Enum.with_index()
      |> Enum.reduce({[], 0}, fn {id, _idx}, {acc, y_offset} ->
        case compute_bbox(scene, id, 0, 0, y_offset, viewport_width, max_depth) do
          nil ->
            {acc, y_offset}

          entry ->
            new_y = y_offset + entry.bbox.height + default_gap()
            {acc ++ [entry], new_y}
        end
      end)
      |> elem(0)

    tree =
      if problems_only do
        filter_problems(tree)
      else
        tree
      end

    {:ok, tree}
  end

  # ---------------------------------------------------------------------------
  # Bbox computation
  # ---------------------------------------------------------------------------

  defp compute_bbox(_scene, _id, _x, _y, _y_offset, _container_w, depth) when depth < 0 do
    nil
  end

  defp compute_bbox(scene, node_id, x, y_base, y_offset, container_w, depth) do
    case Scene.get_node(scene, node_id) do
      {:ok, node} ->
        y = y_base + y_offset
        {node_w, node_h} = estimate_size(node, container_w)

        # Compute padding
        {pt, pr, pb, pl} = extract_padding(node)
        content_w = max(node_w - pl - pr, 0)

        # Compute children bboxes
        {children, content_h} =
          if depth > 0 and node.children != [] do
            compute_children(scene, node, x + pl, y + pt, content_w, depth - 1)
          else
            {[], 0}
          end

        # Adjust height to fit content
        final_h =
          if content_h > 0 do
            max(node_h, content_h + pt + pb)
          else
            node_h
          end

        problems = detect_problems(node, node_w, final_h, container_w, children)

        entry = %{
          id: node.id,
          name: node.name,
          type: to_string(node.type),
          bbox: %{x: x, y: y, width: node_w, height: final_h},
          problems: problems
        }

        if children != [] do
          Map.put(entry, :children, children)
        else
          entry
        end

      _ ->
        nil
    end
  end

  defp compute_children(scene, node, x, y, container_w, depth) do
    layout = Map.get(node, :layout)
    gap = Map.get(node, :gap) || 0
    gap = if is_integer(gap), do: gap, else: default_gap()

    case layout do
      :horizontal ->
        compute_horizontal(scene, node.children, x, y, container_w, gap, depth)

      _ ->
        # Default: vertical stacking (including :vertical and nil)
        compute_vertical(scene, node.children, x, y, container_w, gap, depth)
    end
  end

  defp compute_vertical(scene, child_ids, x, y, container_w, gap, depth) do
    {children, total_h} =
      Enum.reduce(child_ids, {[], 0}, fn id, {acc, offset} ->
        case compute_bbox(scene, id, x, y, offset, container_w, depth) do
          nil ->
            {acc, offset}

          entry ->
            next_offset = offset + entry.bbox.height + gap
            {acc ++ [entry], next_offset}
        end
      end)

    # Remove trailing gap
    total_h = if total_h > 0, do: total_h - gap, else: 0
    {children, total_h}
  end

  defp compute_horizontal(scene, child_ids, x, y, container_w, gap, depth) do
    {children, total_w, max_h} =
      Enum.reduce(child_ids, {[], 0, 0}, fn id, {acc, x_offset, max_h} ->
        remaining_w = max(container_w - x_offset, 0)

        case compute_bbox(scene, id, x + x_offset, y, 0, remaining_w, depth) do
          nil ->
            {acc, x_offset, max_h}

          entry ->
            next_x = x_offset + entry.bbox.width + gap
            {acc ++ [entry], next_x, max(max_h, entry.bbox.height)}
        end
      end)

    _ = total_w
    {children, max_h}
  end

  # ---------------------------------------------------------------------------
  # Size estimation
  # ---------------------------------------------------------------------------

  defp estimate_size(%Node{type: :phia_component, component: component} = node, container_w) do
    {default_w, default_h} = Map.get(@component_defaults, component, {200, 40})
    w = resolve_width(node, container_w, default_w)
    h = resolve_height(node, default_h)
    {w, h}
  end

  defp estimate_size(%Node{type: :html_element} = node, container_w) do
    w = resolve_width(node, container_w, container_w)
    h = resolve_height(node, 40)
    {w, h}
  end

  defp estimate_size(%Node{type: :frame} = node, container_w) do
    w = resolve_width(node, container_w, container_w)
    h = resolve_height(node, 40)
    {w, h}
  end

  defp estimate_size(%Node{type: :text, text_content: content}, container_w) do
    # Rough estimate: ~8px per character, ~20px height per line
    chars = String.length(content || "")
    lines = max(div(chars * 8, container_w) + 1, 1)
    {container_w, lines * 20}
  end

  defp estimate_size(_, container_w), do: {container_w, 40}

  defp resolve_width(node, container_w, default) do
    case Map.get(node, :width) do
      :fill -> container_w
      :hug -> default
      px when is_integer(px) -> px
      pct when is_binary(pct) ->
        case Integer.parse(String.replace(pct, "%", "")) do
          {n, _} -> div(container_w * n, 100)
          _ -> default
        end
      _ -> default
    end
  end

  defp resolve_height(node, default) do
    case Map.get(node, :height) do
      :fill -> default
      :hug -> default
      px when is_integer(px) -> px
      _ -> default
    end
  end

  defp extract_padding(node) do
    case Map.get(node, :padding) do
      [t, r, b, l] when is_integer(t) and is_integer(r) and is_integer(b) and is_integer(l) ->
        {t, r, b, l}

      px when is_integer(px) ->
        {px, px, px, px}

      _ ->
        {0, 0, 0, 0}
    end
  end

  # ---------------------------------------------------------------------------
  # Problem detection
  # ---------------------------------------------------------------------------

  defp detect_problems(node, width, height, container_w, children) do
    problems = []

    problems =
      if width > container_w do
        ["overflow: width #{width}px exceeds container #{container_w}px" | problems]
      else
        problems
      end

    problems =
      if width == 0 or height == 0 do
        ["zero-size: #{width}x#{height}" | problems]
      else
        problems
      end

    problems =
      if node.children != [] and Map.get(node, :layout) == nil and node.type == :frame do
        ["missing-layout: frame has children but no layout direction" | problems]
      else
        problems
      end

    # Check children overflow
    parent_w = case Map.get(node, :width) do
      w when is_integer(w) -> w
      _ -> container_w
    end

    problems =
      Enum.reduce(children, problems, fn child, acc ->
        child_bbox = child.bbox

        if child_bbox.x + child_bbox.width > parent_w + 1 do
          ["child-overflow: #{child.id} exceeds parent width" | acc]
        else
          acc
        end
      end)

    Enum.reverse(problems)
  end

  defp default_gap, do: 8

  # ---------------------------------------------------------------------------
  # Problem filtering
  # ---------------------------------------------------------------------------

  defp filter_problems(tree) do
    tree
    |> Enum.map(&filter_problems_node/1)
    |> Enum.reject(&is_nil/1)
  end

  defp filter_problems_node(%{problems: problems, children: children} = entry) do
    filtered_children =
      children
      |> Enum.map(&filter_problems_node/1)
      |> Enum.reject(&is_nil/1)

    if problems != [] or filtered_children != [] do
      %{entry | children: filtered_children}
    else
      nil
    end
  end

  defp filter_problems_node(%{problems: problems} = entry) do
    if problems != [], do: entry, else: nil
  end
end
