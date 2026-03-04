defmodule PhiaUi.Components.TreeTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Tree

    def render_tree(assigns) do
      ~H"""
      <.tree id="my-tree">
        <.tree_item label="src" />
      </.tree>
      """
    end

    def render_tree_with_class(assigns) do
      ~H"""
      <.tree id="my-tree" class="custom-tree-class">
        <.tree_item label="item" />
      </.tree>
      """
    end

    def render_leaf(assigns) do
      ~H"""
      <.tree id="t">
        <.tree_item label="app.ex" />
      </.tree>
      """
    end

    def render_leaf_with_click(assigns) do
      ~H"""
      <.tree id="t">
        <.tree_item label="app.ex" on_click="open_file" value="app.ex" />
      </.tree>
      """
    end

    def render_leaf_with_class(assigns) do
      ~H"""
      <.tree id="t">
        <.tree_item label="app.ex" class="my-leaf-class" />
      </.tree>
      """
    end

    def render_leaf_no_click(assigns) do
      ~H"""
      <.tree id="t">
        <.tree_item label="app.ex" />
      </.tree>
      """
    end

    def render_expandable_open(assigns) do
      ~H"""
      <.tree id="t">
        <.tree_item label="src" expandable={true} expanded={true}>
          <.tree_item label="app.ex" />
        </.tree_item>
      </.tree>
      """
    end

    def render_expandable_closed(assigns) do
      ~H"""
      <.tree id="t">
        <.tree_item label="src" expandable={true} expanded={false}>
          <.tree_item label="app.ex" />
        </.tree_item>
      </.tree>
      """
    end

    def render_expandable_default(assigns) do
      ~H"""
      <.tree id="t">
        <.tree_item label="src" expandable={true}>
          <.tree_item label="nested.ex" />
        </.tree_item>
      </.tree>
      """
    end

    def render_nested(assigns) do
      ~H"""
      <.tree id="file-tree">
        <.tree_item label="src" expandable={true} expanded={true}>
          <.tree_item label="components" expandable={true}>
            <.tree_item label="button.ex" on_click="open_file" value="button.ex" />
          </.tree_item>
          <.tree_item label="app.ex" value="app.ex" />
        </.tree_item>
        <.tree_item label="mix.exs" value="mix.exs" />
      </.tree>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # tree/1
  # ---------------------------------------------------------------------------

  describe "tree/1" do
    test "renders ul element" do
      html = render_component(&H.render_tree/1, %{})
      assert html =~ "<ul"
    end

    test "has role=tree" do
      html = render_component(&H.render_tree/1, %{})
      assert html =~ ~s(role="tree")
    end

    test "renders inner_block content" do
      html = render_component(&H.render_tree/1, %{})
      assert html =~ "src"
    end

    test "applies custom class" do
      html = render_component(&H.render_tree_with_class/1, %{})
      assert html =~ "custom-tree-class"
    end

    test "renders with id attr" do
      html = render_component(&H.render_tree/1, %{})
      assert html =~ ~s(id="my-tree")
    end
  end

  # ---------------------------------------------------------------------------
  # tree_item/1 leaf
  # ---------------------------------------------------------------------------

  describe "tree_item/1 leaf" do
    test "renders li element" do
      html = render_component(&H.render_leaf/1, %{})
      assert html =~ "<li"
    end

    test "li has role=treeitem" do
      html = render_component(&H.render_leaf/1, %{})
      assert html =~ ~s(role="treeitem")
    end

    test "renders label text" do
      html = render_component(&H.render_leaf/1, %{})
      assert html =~ "app.ex"
    end

    test "has hover:bg-accent class" do
      html = render_component(&H.render_leaf/1, %{})
      assert html =~ "hover:bg-accent"
    end

    test "leaf does not render details element" do
      html = render_component(&H.render_leaf/1, %{})
      refute html =~ "<details"
    end

    test "leaf has cursor-pointer class" do
      html = render_component(&H.render_leaf/1, %{})
      assert html =~ "cursor-pointer"
    end

    test "phx-click attr when on_click given" do
      html = render_component(&H.render_leaf_with_click/1, %{})
      assert html =~ ~s(phx-click="open_file")
    end

    test "phx-value-value attr when value given" do
      html = render_component(&H.render_leaf_with_click/1, %{})
      assert html =~ ~s(phx-value-value="app.ex")
    end

    test "no phx-click when on_click not given" do
      html = render_component(&H.render_leaf_no_click/1, %{})
      refute html =~ "phx-click"
    end

    test "custom class applied" do
      html = render_component(&H.render_leaf_with_class/1, %{})
      assert html =~ "my-leaf-class"
    end
  end

  # ---------------------------------------------------------------------------
  # tree_item/1 expandable
  # ---------------------------------------------------------------------------

  describe "tree_item/1 expandable" do
    test "renders details element when expandable" do
      html = render_component(&H.render_expandable_open/1, %{})
      assert html =~ "<details"
    end

    test "renders summary element" do
      html = render_component(&H.render_expandable_open/1, %{})
      assert html =~ "<summary"
    end

    test "summary has label text" do
      html = render_component(&H.render_expandable_open/1, %{})
      assert html =~ "src"
    end

    test "details is open when expanded=true" do
      html = render_component(&H.render_expandable_open/1, %{})
      assert html =~ "open"
    end

    test "details is NOT open when expanded=false" do
      html = render_component(&H.render_expandable_closed/1, %{})
      # The details element should exist but not have the open attribute
      assert html =~ "<details"
      refute html =~ ~s(<details open)
    end

    test "has aria-expanded=true when expanded" do
      html = render_component(&H.render_expandable_open/1, %{})
      assert html =~ ~s(aria-expanded="true")
    end

    test "has aria-expanded=false when not expanded" do
      html = render_component(&H.render_expandable_closed/1, %{})
      assert html =~ ~s(aria-expanded="false")
    end

    test "renders nested items in ul with role=group" do
      html = render_component(&H.render_expandable_open/1, %{})
      assert html =~ ~s(role="group")
    end

    test "chevron SVG rendered in summary" do
      html = render_component(&H.render_expandable_open/1, %{})
      assert html =~ "<svg"
      assert html =~ "polyline"
    end

    test "renders inner_block content" do
      html = render_component(&H.render_expandable_open/1, %{})
      assert html =~ "app.ex"
    end
  end
end
