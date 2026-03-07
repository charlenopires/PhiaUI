defmodule PhiaUi.Components.DraggableTreeTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.DraggableTree

    def render_tree(assigns) do
      ~H"""
      <.draggable_tree
        id={assigns[:id] || "tree-1"}
        on_reorder={assigns[:on_reorder] || "tree_reorder"}
        class={assigns[:class]}
      >
        {assigns[:content] || "tree content"}
      </.draggable_tree>
      """
    end

    def render_node(assigns) do
      ~H"""
      <.draggable_tree_node
        id={assigns[:id] || "node-1"}
        label={assigns[:label] || "Node Label"}
        depth={assigns[:depth] || 0}
        expanded={if Map.has_key?(assigns, :expanded), do: assigns.expanded, else: true}
        leaf={assigns[:leaf] || false}
        class={assigns[:class]}
      >
        {assigns[:content]}
      </.draggable_tree_node>
      """
    end

    def render_node_with_icon(assigns) do
      ~H"""
      <.draggable_tree_node id="node-icon" label="With Icon" depth={0} leaf={true}>
        <:icon>
          <span class="custom-icon" />
        </:icon>
      </.draggable_tree_node>
      """
    end

    def render_full_tree(assigns) do
      ~H"""
      <.draggable_tree id="full-tree" on_reorder="tree_reordered">
        <.draggable_tree_node id="branch-1" label="Section A" depth={0}>
          <.draggable_tree_node id="leaf-1a" label="Item A1" depth={1} leaf={true} />
          <.draggable_tree_node id="leaf-1b" label="Item A2" depth={1} leaf={true} />
        </.draggable_tree_node>
        <.draggable_tree_node id="leaf-2" label="Section B" depth={0} leaf={true} />
      </.draggable_tree>
      """
    end
  end

  defp render_tree(attrs \\ %{}), do: render_component(&H.render_tree/1, attrs)
  defp render_node(attrs \\ %{}), do: render_component(&H.render_node/1, attrs)
  defp render_node_with_icon, do: render_component(&H.render_node_with_icon/1, %{})
  defp render_full_tree, do: render_component(&H.render_full_tree/1, %{})

  # ---------------------------------------------------------------------------
  # draggable_tree/1
  # ---------------------------------------------------------------------------

  describe "draggable_tree/1" do
    test "renders a ul element" do
      assert render_tree() =~ "<ul"
    end

    test "has phx-hook=PhiaDraggableTree" do
      assert render_tree() =~ ~s(phx-hook="PhiaDraggableTree")
    end

    test "has role=tree" do
      assert render_tree() =~ ~s(role="tree")
    end

    test "has aria-label" do
      assert render_tree() =~ "Draggable tree"
    end

    test "forwards id attribute" do
      assert render_tree(%{id: "my-tree"}) =~ ~s(id="my-tree")
    end

    test "has data-on-reorder attribute" do
      assert render_tree(%{on_reorder: "tree_moved"}) =~ ~s(data-on-reorder="tree_moved")
    end

    test "renders inner content" do
      assert render_tree(%{content: "tree body"}) =~ "tree body"
    end

    test "applies custom class" do
      assert render_tree(%{class: "my-tree"}) =~ "my-tree"
    end
  end

  # ---------------------------------------------------------------------------
  # draggable_tree_node/1
  # ---------------------------------------------------------------------------

  describe "draggable_tree_node/1 — structure" do
    test "renders an li element" do
      assert render_node() =~ "<li"
    end

    test "has role=treeitem" do
      assert render_node() =~ ~s(role="treeitem")
    end

    test "has data-tree-node attribute" do
      assert render_node() =~ "data-tree-node"
    end

    test "has data-depth attribute" do
      assert render_node(%{depth: 2}) =~ ~s(data-depth="2")
    end

    test "has draggable=true" do
      assert render_node() =~ ~s(draggable="true")
    end

    test "renders label" do
      assert render_node(%{label: "My Node"}) =~ "My Node"
    end

    test "forwards id attribute" do
      assert render_node(%{id: "node-xyz"}) =~ ~s(id="node-xyz")
    end

    test "applies custom class" do
      assert render_node(%{class: "my-node"}) =~ "my-node"
    end
  end

  describe "draggable_tree_node/1 — expand/collapse" do
    test "non-leaf shows expand/collapse button" do
      html = render_node(%{leaf: false})
      assert html =~ "data-tree-toggle"
    end

    test "leaf node hides toggle button" do
      html = render_node(%{leaf: true})
      refute html =~ "data-tree-toggle"
    end

    test "expanded=true shows children group" do
      html = render_node(%{leaf: false, expanded: true, content: "child"})
      assert html =~ ~s(role="group")
    end

    test "expanded=false hides children group" do
      html = render_node(%{leaf: false, expanded: false, content: "child"})
      refute html =~ ~s(role="group")
    end

    test "leaf node has data-leaf=true" do
      assert render_node(%{leaf: true}) =~ ~s(data-leaf="true")
    end

    test "non-leaf node has aria-expanded" do
      assert render_node(%{leaf: false, expanded: true}) =~ ~s(aria-expanded="true")
    end
  end

  describe "draggable_tree_node/1 — depth padding" do
    test "depth 0 uses padding-left 8px" do
      assert render_node(%{depth: 0}) =~ "padding-left: 8px"
    end

    test "depth 1 uses padding-left 24px" do
      assert render_node(%{depth: 1}) =~ "padding-left: 24px"
    end

    test "depth 2 uses padding-left 40px" do
      assert render_node(%{depth: 2}) =~ "padding-left: 40px"
    end
  end

  describe "draggable_tree_node/1 — icon slot" do
    test "renders custom icon slot" do
      assert render_node_with_icon() =~ "custom-icon"
    end
  end

  describe "full tree composition" do
    test "renders nested branch and leaf nodes" do
      html = render_full_tree()
      assert html =~ "Section A"
      assert html =~ "Item A1"
      assert html =~ "Item A2"
      assert html =~ "Section B"
    end

    test "root tree has phx-hook" do
      assert render_full_tree() =~ ~s(phx-hook="PhiaDraggableTree")
    end

    test "leaf nodes do not show toggle buttons" do
      html = render_full_tree()
      # leaf-1a, leaf-1b, leaf-2 are leaves; only branch-1 has toggle
      # Count data-tree-toggle occurrences — should be 1 (branch-1 only)
      matches = Regex.scan(~r/data-tree-toggle/, html)
      assert length(matches) == 1
    end
  end
end
