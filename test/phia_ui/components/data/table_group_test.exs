defmodule PhiaUi.Components.TableGroupTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.TableGroup

    attr(:class, :string, default: nil)

    def render_group(assigns) do
      ~H"""
      <table>
        <.table_group class={@class}>
          <tr><td>Row</td></tr>
        </.table_group>
      </table>
      """
    end

    attr(:label, :string, default: "Group Label")
    attr(:count, :integer, default: nil)
    attr(:collapsed, :boolean, default: false)
    attr(:on_toggle, :string, default: nil)
    attr(:row_id, :string, default: nil)
    attr(:col_span, :integer, default: 100)

    def render_group_header(assigns) do
      ~H"""
      <table><tbody>
        <.table_group_header
          label={@label}
          count={@count}
          collapsed={@collapsed}
          on_toggle={@on_toggle}
          row_id={@row_id}
          col_span={@col_span}
        />
      </tbody></table>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # table_group/1
  # ---------------------------------------------------------------------------

  describe "table_group/1" do
    test "renders tbody element" do
      html = render_component(&H.render_group/1, %{})
      assert html =~ "<tbody"
    end

    test "has group class" do
      html = render_component(&H.render_group/1, %{})
      assert html =~ "group"
    end

    test "renders inner content" do
      html = render_component(&H.render_group/1, %{})
      assert html =~ "Row"
    end

    test "accepts custom class" do
      html = render_component(&H.render_group/1, %{class: "my-group"})
      assert html =~ "my-group"
    end
  end

  # ---------------------------------------------------------------------------
  # table_group_header/1
  # ---------------------------------------------------------------------------

  describe "table_group_header/1" do
    test "renders tr element" do
      html = render_component(&H.render_group_header/1, %{})
      assert html =~ "<tr"
    end

    test "renders label text" do
      html = render_component(&H.render_group_header/1, %{label: "My Group"})
      assert html =~ "My Group"
    end

    test "has td with col_span" do
      html = render_component(&H.render_group_header/1, %{col_span: 5})
      assert html =~ ~s(colspan="5")
    end

    test "renders count badge when provided" do
      html = render_component(&H.render_group_header/1, %{count: 7})
      assert html =~ "7"
      assert html =~ "rounded-full"
    end

    test "does not render count badge when nil" do
      html = render_component(&H.render_group_header/1, %{count: nil})
      refute html =~ "rounded-full bg-muted px-1.5"
    end

    test "renders chevron button when on_toggle is set" do
      html = render_component(&H.render_group_header/1, %{on_toggle: "toggle_group", row_id: "grp-1"})
      assert html =~ "<button"
      assert html =~ ~s(phx-click="toggle_group")
      assert html =~ ~s(phx-value-id="grp-1")
    end

    test "does not render toggle button when on_toggle is nil" do
      html = render_component(&H.render_group_header/1, %{on_toggle: nil})
      refute html =~ "<button"
    end

    test "chevron rotates when collapsed" do
      html = render_component(&H.render_group_header/1, %{on_toggle: "t", collapsed: true})
      assert html =~ "-rotate-90"
    end

    test "chevron points down when not collapsed" do
      html = render_component(&H.render_group_header/1, %{on_toggle: "t", collapsed: false})
      refute html =~ "-rotate-90"
    end

    test "has muted background styling" do
      html = render_component(&H.render_group_header/1, %{})
      assert html =~ "bg-muted/30"
    end
  end
end
