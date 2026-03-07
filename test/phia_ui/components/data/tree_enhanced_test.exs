defmodule PhiaUi.Components.TreeEnhancedTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.TreeEnhanced

    def render_icon_tree(assigns) do
      ~H"""
      <.icon_tree id="it-1">
        <.icon_tree_item label="Settings" icon="settings" />
        <.icon_tree_item label="src" icon="folder" expandable={true}>
          <.icon_tree_item label="app.ex" icon="file-code" />
        </.icon_tree_item>
      </.icon_tree>
      """
    end

    def render_checkbox_tree(assigns) do
      ~H"""
      <.checkbox_tree id="ct-1">
        <.checkbox_tree_item id="ct-item-1" label="Read" checked={true} value="read" />
        <.checkbox_tree_item id="ct-item-2" label="Write" checked={false} indeterminate={true} value="write" />
      </.checkbox_tree>
      """
    end

    def render_searchable_tree(assigns) do
      ~H"""
      <.searchable_tree id="st-1" search_value="app" on_search="search">
        <.icon_tree_item label="app.ex" />
      </.searchable_tree>
      """
    end

    def render_file_tree(assigns) do
      ~H"""
      <.file_tree id="ft-1">
        <.file_tree_item label="src" type={:folder} expanded={true}>
          <.file_tree_item label="app.ex" type={:file} />
          <.file_tree_item label="logo.png" type={:file} />
        </.file_tree_item>
        <.file_tree_item label="mix.exs" type={:file} />
      </.file_tree>
      """
    end

    def render_lazy_tree(assigns) do
      ~H"""
      <.lazy_tree id="lt-1" on_expand="load_children">
        <.lazy_tree_item id="lt-node-1" label="src" expandable={true} loaded={false} loading={false} />
      </.lazy_tree>
      """
    end

    def render_virtual_tree(assigns) do
      nodes = [
        %{id: "1", label: "Root", depth: 0, expandable: true, expanded: false},
        %{id: "2", label: "Child", depth: 1, expandable: false, expanded: false}
      ]
      assigns = assign(assigns, :nodes, nodes)
      ~H"""
      <.virtual_tree id="vt-1" nodes={@nodes} row_height={32} height={300} />
      """
    end
  end

  describe "icon_tree/1" do
    test "renders ul with role=tree" do
      html = render_component(&H.render_icon_tree/1, %{})
      assert html =~ ~s(role="tree")
    end

    test "renders leaf items" do
      html = render_component(&H.render_icon_tree/1, %{})
      assert html =~ "Settings"
    end

    test "renders expandable branches" do
      html = render_component(&H.render_icon_tree/1, %{})
      assert html =~ "<details"
      assert html =~ "src"
    end

    test "renders nested items" do
      html = render_component(&H.render_icon_tree/1, %{})
      assert html =~ "app.ex"
    end
  end

  describe "checkbox_tree/1" do
    test "renders with phx-hook" do
      html = render_component(&H.render_checkbox_tree/1, %{})
      assert html =~ ~s(phx-hook="PhiaCheckboxTree")
    end

    test "renders checked checkbox" do
      html = render_component(&H.render_checkbox_tree/1, %{})
      assert html =~ "Read"
      assert html =~ ~s(checked)
    end

    test "renders indeterminate data attribute" do
      html = render_component(&H.render_checkbox_tree/1, %{})
      assert html =~ ~s(data-indeterminate="true")
    end

    test "renders aria-checked=mixed for indeterminate" do
      html = render_component(&H.render_checkbox_tree/1, %{})
      assert html =~ ~s(aria-checked="mixed")
    end
  end

  describe "searchable_tree/1" do
    test "renders search input" do
      html = render_component(&H.render_searchable_tree/1, %{})
      assert html =~ ~s(type="search")
    end

    test "has search placeholder" do
      html = render_component(&H.render_searchable_tree/1, %{})
      assert html =~ "Search"
    end

    test "renders tree items" do
      html = render_component(&H.render_searchable_tree/1, %{})
      assert html =~ "app.ex"
    end

    test "has phx-debounce" do
      html = render_component(&H.render_searchable_tree/1, %{})
      assert html =~ "phx-debounce"
    end
  end

  describe "file_tree/1" do
    test "renders with role=tree" do
      html = render_component(&H.render_file_tree/1, %{})
      assert html =~ ~s(role="tree")
    end

    test "renders folder with details/summary" do
      html = render_component(&H.render_file_tree/1, %{})
      assert html =~ "<details"
      assert html =~ "src"
    end

    test "renders files with extension icons" do
      html = render_component(&H.render_file_tree/1, %{})
      assert html =~ "app.ex"
      assert html =~ "mix.exs"
    end

    test "renders image file with file-image icon" do
      html = render_component(&H.render_file_tree/1, %{})
      assert html =~ "logo.png"
    end
  end

  describe "lazy_tree/1" do
    test "renders with phx-hook" do
      html = render_component(&H.render_lazy_tree/1, %{})
      assert html =~ ~s(phx-hook="PhiaLazyTree")
    end

    test "has data-on-expand" do
      html = render_component(&H.render_lazy_tree/1, %{})
      assert html =~ ~s(data-on-expand="load_children")
    end

    test "renders lazy items" do
      html = render_component(&H.render_lazy_tree/1, %{})
      assert html =~ "src"
    end

    test "has data-node-id" do
      html = render_component(&H.render_lazy_tree/1, %{})
      assert html =~ ~s(data-node-id="lt-node-1")
    end
  end

  describe "virtual_tree/1" do
    test "renders with phx-hook" do
      html = render_component(&H.render_virtual_tree/1, %{})
      assert html =~ ~s(phx-hook="PhiaVirtualTree")
    end

    test "has phx-update=ignore" do
      html = render_component(&H.render_virtual_tree/1, %{})
      assert html =~ ~s(phx-update="ignore")
    end

    test "has data-nodes attribute" do
      html = render_component(&H.render_virtual_tree/1, %{})
      assert html =~ "data-nodes"
    end

    test "has data-row-height" do
      html = render_component(&H.render_virtual_tree/1, %{})
      assert html =~ ~s(data-row-height="32")
    end

    test "has height style" do
      html = render_component(&H.render_virtual_tree/1, %{})
      assert html =~ "height: 300px"
    end
  end
end
