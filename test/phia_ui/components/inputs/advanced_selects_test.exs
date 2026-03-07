defmodule PhiaUi.Components.AdvancedSelectsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.AdvancedSelects

    attr(:id, :string, default: "ts")
    attr(:value, :string, default: nil)
    attr(:placeholder, :string, default: "Select…")
    attr(:options, :list, default: [])

    def render_tree_select(assigns) do
      ~H"""
      <.tree_select id={@id} value={@value} placeholder={@placeholder} options={@options} />
      """
    end

    attr(:option, :map, default: %{label: "Root", value: "root"})
    attr(:selected_value, :string, default: nil)
    attr(:level, :integer, default: 0)

    def render_tree_option(assigns) do
      ~H"""
      <.tree_select_option option={@option} selected_value={@selected_value} level={@level} id_prefix="ts" />
      """
    end

    attr(:id, :string, default: "rs")
    attr(:value, :string, default: nil)
    attr(:name, :string, default: "rich_select")
    attr(:options, :list, default: [])
    attr(:size, :atom, default: :default)

    def render_rich_select(assigns) do
      ~H"""
      <.rich_select id={@id} value={@value} name={@name} options={@options} size={@size} />
      """
    end

    attr(:id, :string, default: "vs")
    attr(:name, :string, default: "visual_select")
    attr(:value, :string, default: nil)
    attr(:cols, :integer, default: 3)
    attr(:options, :list, default: [])

    def render_visual_select(assigns) do
      ~H"""
      <.visual_select id={@id} name={@name} value={@value} cols={@cols} options={@options} />
      """
    end

    attr(:value, :string, default: "opt1")
    attr(:label, :string, default: "Option 1")
    attr(:selected, :boolean, default: false)
    attr(:name, :string, default: "vsi")
    attr(:image_src, :string, default: nil)

    def render_visual_select_item(assigns) do
      ~H"""
      <.visual_select_item value={@value} label={@label} selected={@selected} name={@name} image_src={@image_src} />
      """
    end

    attr(:value, :string, default: "opt1")
    attr(:label, :string, default: "Option 1")
    attr(:selected, :boolean, default: false)
    attr(:name, :string, default: "rso")
    attr(:description, :string, default: nil)

    def render_rich_select_option(assigns) do
      ~H"""
      <.rich_select_option value={@value} label={@label} selected={@selected} name={@name} description={@description} />
      """
    end
  end

  defp render_tree_select(attrs \\ %{}) do
    render_component(&H.render_tree_select/1, attrs)
  end

  defp render_rich_select(attrs \\ %{}) do
    render_component(&H.render_rich_select/1, attrs)
  end

  defp render_visual_select(attrs \\ %{}) do
    render_component(&H.render_visual_select/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # tree_select/1
  # ---------------------------------------------------------------------------

  describe "tree_select/1 — structure" do
    test "renders root container with phx-hook" do
      html = render_tree_select(%{id: "ts1"})
      assert html =~ ~s(phx-hook="PhiaTreeSelect")
    end

    test "renders trigger button" do
      html = render_tree_select()
      assert html =~ "data-tree-trigger"
    end

    test "renders dropdown panel (hidden initially)" do
      html = render_tree_select()
      assert html =~ "data-tree-panel"
      assert html =~ "hidden"
    end

    test "renders hidden input for form submission" do
      html = render_tree_select()
      assert html =~ "data-tree-input"
    end

    test "shows placeholder when no value selected" do
      html = render_tree_select(%{placeholder: "Pick a fruit"})
      assert html =~ "Pick a fruit"
    end

    test "data-options contains JSON of options" do
      opts = [%{label: "Fruits", value: "fruits", children: []}]
      html = render_tree_select(%{options: opts})
      # HTML attribute encoding: " becomes &quot;
      assert html =~ "&quot;label&quot;:&quot;Fruits&quot;"
    end
  end

  describe "tree_select/1 — options rendering" do
    test "renders flat option nodes" do
      opts = [
        %{label: "Alpha", value: "a"},
        %{label: "Beta", value: "b"}
      ]

      html = render_tree_select(%{options: opts})
      assert html =~ "Alpha"
      assert html =~ "Beta"
    end

    test "renders nested children" do
      opts = [
        %{
          label: "Parent",
          value: "p",
          children: [%{label: "Child", value: "c"}]
        }
      ]

      html = render_tree_select(%{options: opts})
      assert html =~ "Parent"
      assert html =~ "Child"
    end

    test "renders expand chevron for nodes with children" do
      opts = [
        %{label: "Parent", value: "p", children: [%{label: "C", value: "c"}]}
      ]

      html = render_tree_select(%{options: opts})
      assert html =~ "data-tree-chevron"
    end

    test "leaf nodes have no chevron" do
      opts = [%{label: "Leaf", value: "l"}]
      html = render_tree_select(%{options: opts})
      refute html =~ "data-tree-chevron"
    end
  end

  describe "tree_select_option/1" do
    test "renders option with value" do
      html =
        render_component(&H.render_tree_option/1, %{
          option: %{label: "Node A", value: "node-a"},
          selected_value: nil
        })

      assert html =~ "Node A"
      assert html =~ ~s(data-value="node-a")
    end

    test "active node has bg-accent class" do
      html =
        render_component(&H.render_tree_option/1, %{
          option: %{label: "Active", value: "active"},
          selected_value: "active"
        })

      assert html =~ "bg-accent"
    end

    test "level > 0 increases indentation via inline style" do
      html =
        render_component(&H.render_tree_option/1, %{
          option: %{label: "Child", value: "child"},
          selected_value: nil,
          level: 1
        })

      assert html =~ "padding-left:"
    end
  end

  # ---------------------------------------------------------------------------
  # rich_select/1
  # ---------------------------------------------------------------------------

  describe "rich_select/1 — structure" do
    test "renders fieldset with radio inputs" do
      opts = [%{value: "a", label: "Alpha"}, %{value: "b", label: "Beta"}]
      html = render_rich_select(%{options: opts})
      assert html =~ "<fieldset"
      assert html =~ ~s(type="radio")
    end

    test "renders all option labels" do
      opts = [%{value: "x", label: "X Option"}, %{value: "y", label: "Y Option"}]
      html = render_rich_select(%{options: opts})
      assert html =~ "X Option"
      assert html =~ "Y Option"
    end

    test "selected option has border-primary class" do
      opts = [%{value: "a", label: "Alpha"}, %{value: "b", label: "Beta"}]
      html = render_rich_select(%{options: opts, value: "a"})
      assert html =~ "border-primary"
    end

    test "selected radio input is checked" do
      opts = [%{value: "chosen", label: "Chosen"}]
      html = render_rich_select(%{options: opts, value: "chosen"})
      assert html =~ "checked"
    end

    test "unselected options do not have checked attribute" do
      opts = [%{value: "a", label: "A"}, %{value: "b", label: "B"}]
      html = render_rich_select(%{options: opts, value: "a"})
      count = html |> String.split("checked") |> length() |> Kernel.-(1)
      assert count == 1
    end

    test "checkmark SVG shown for selected option" do
      opts = [%{value: "s", label: "Selected"}]
      html = render_rich_select(%{options: opts, value: "s"})
      # Checkmark path
      assert html =~ "M20 6 9 17l-5-5"
    end

    test "renders description when provided" do
      opts = [%{value: "a", label: "Alpha", description: "The first option"}]
      html = render_rich_select(%{options: opts})
      assert html =~ "The first option"
    end

    test "renders avatar image when avatar_src provided" do
      opts = [%{value: "a", label: "Alpha", avatar_src: "/img/avatar.png"}]
      html = render_rich_select(%{options: opts})
      assert html =~ "/img/avatar.png"
    end
  end

  describe "rich_select/1 — size variants" do
    test "size=:sm renders py-1.5 class" do
      html = render_rich_select(%{options: [%{value: "x", label: "X"}], size: :sm})
      assert html =~ "py-1.5"
    end

    test "size=:lg renders py-3 class" do
      html = render_rich_select(%{options: [%{value: "x", label: "X"}], size: :lg})
      assert html =~ "py-3"
    end
  end

  # ---------------------------------------------------------------------------
  # rich_select_option/1
  # ---------------------------------------------------------------------------

  describe "rich_select_option/1" do
    test "renders label and value" do
      html =
        render_component(&H.render_rich_select_option/1, %{
          value: "opt-1",
          label: "Option One"
        })

      assert html =~ "Option One"
      assert html =~ ~s(value="opt-1")
    end

    test "selected option shows checkmark" do
      html =
        render_component(&H.render_rich_select_option/1, %{
          value: "sel",
          label: "Selected",
          selected: true
        })

      assert html =~ "M20 6 9 17l-5-5"
    end

    test "non-selected option has no checkmark" do
      html =
        render_component(&H.render_rich_select_option/1, %{
          value: "not",
          label: "Not selected",
          selected: false
        })

      refute html =~ "M20 6 9 17l-5-5"
    end

    test "renders description" do
      html =
        render_component(&H.render_rich_select_option/1, %{
          value: "d",
          label: "L",
          description: "Desc text"
        })

      assert html =~ "Desc text"
    end
  end

  # ---------------------------------------------------------------------------
  # visual_select/1
  # ---------------------------------------------------------------------------

  describe "visual_select/1 — structure" do
    test "renders fieldset" do
      html = render_visual_select(%{options: []})
      assert html =~ "<fieldset"
    end

    test "renders grid layout" do
      html = render_visual_select()
      assert html =~ "grid"
    end

    test "cols=2 renders grid-cols-2" do
      html = render_visual_select(%{cols: 2, options: []})
      assert html =~ "grid-cols-2"
    end

    test "cols=4 renders grid-cols-4" do
      html = render_visual_select(%{cols: 4, options: []})
      assert html =~ "grid-cols-4"
    end

    test "default cols=3 renders grid-cols-3" do
      html = render_visual_select(%{options: []})
      assert html =~ "grid-cols-3"
    end

    test "renders all option labels" do
      opts = [
        %{value: "a", label: "Option A"},
        %{value: "b", label: "Option B"}
      ]

      html = render_visual_select(%{options: opts})
      assert html =~ "Option A"
      assert html =~ "Option B"
    end

    test "selected item has ring-2 class" do
      opts = [%{value: "sel", label: "Selected"}]
      html = render_visual_select(%{options: opts, value: "sel"})
      assert html =~ "ring-2"
    end

    test "selected item radio is checked" do
      opts = [%{value: "c", label: "Checked"}]
      html = render_visual_select(%{options: opts, value: "c"})
      assert html =~ "checked"
    end

    test "renders image when image_src provided" do
      opts = [%{value: "img", label: "Image", image_src: "/tile.png"}]
      html = render_visual_select(%{options: opts})
      assert html =~ "/tile.png"
    end

    test "renders checkmark badge for selected item" do
      opts = [%{value: "s", label: "S"}]
      html = render_visual_select(%{options: opts, value: "s"})
      assert html =~ "absolute top-1.5 right-1.5"
    end
  end

  describe "visual_select_item/1" do
    test "renders label" do
      html = render_component(&H.render_visual_select_item/1, %{value: "v1", label: "Tile 1"})
      assert html =~ "Tile 1"
    end

    test "selected item has ring-2 class" do
      html =
        render_component(&H.render_visual_select_item/1, %{
          value: "v",
          label: "L",
          selected: true
        })

      assert html =~ "ring-2"
    end

    test "non-selected has no ring-2" do
      html =
        render_component(&H.render_visual_select_item/1, %{
          value: "v",
          label: "L",
          selected: false
        })

      refute html =~ "ring-2"
    end

    test "renders image when provided" do
      html =
        render_component(&H.render_visual_select_item/1, %{
          value: "v",
          label: "L",
          image_src: "/img.png"
        })

      assert html =~ "/img.png"
    end
  end
end
