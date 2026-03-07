defmodule PhiaUi.Components.ExpandableTableTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ExpandableTable

    attr(:row_id, :string, default: "row-1")
    attr(:expanded, :boolean, default: false)
    attr(:on_toggle, :string, default: "toggle_row")

    def render_row(assigns) do
      ~H"""
      <table><tbody>
        <.expandable_table_row row_id={@row_id} expanded={@expanded} on_toggle={@on_toggle}>
          <td>Cell content</td>
        </.expandable_table_row>
      </tbody></table>
      """
    end

    attr(:row_id, :string, default: "row-1")
    attr(:expanded, :boolean, default: false)
    attr(:col_span, :integer, default: 100)

    def render_detail(assigns) do
      ~H"""
      <table><tbody>
        <.expandable_table_detail row_id={@row_id} expanded={@expanded} col_span={@col_span}>
          Detail content here
        </.expandable_table_detail>
      </tbody></table>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # expandable_table_row/1
  # ---------------------------------------------------------------------------

  describe "expandable_table_row/1" do
    test "renders tr element" do
      html = render_component(&H.render_row/1, %{})
      assert html =~ "<tr"
    end

    test "renders chevron button" do
      html = render_component(&H.render_row/1, %{})
      assert html =~ "<button"
      assert html =~ "chevron-right"
    end

    test "button has aria-expanded=false when not expanded" do
      html = render_component(&H.render_row/1, %{expanded: false})
      assert html =~ ~s(aria-expanded="false")
    end

    test "button has aria-expanded=true when expanded" do
      html = render_component(&H.render_row/1, %{expanded: true})
      assert html =~ ~s(aria-expanded="true")
    end

    test "button has aria-controls referencing detail row" do
      html = render_component(&H.render_row/1, %{row_id: "order-42"})
      assert html =~ ~s(aria-controls="row-detail-order-42")
    end

    test "button fires on_toggle event with row_id" do
      html = render_component(&H.render_row/1, %{row_id: "abc", on_toggle: "my_toggle"})
      assert html =~ ~s(phx-click="my_toggle")
      assert html =~ ~s(phx-value-id="abc")
    end

    test "chevron rotates when expanded" do
      html = render_component(&H.render_row/1, %{expanded: true})
      assert html =~ "rotate-90"
    end

    test "chevron does not rotate when not expanded" do
      html = render_component(&H.render_row/1, %{expanded: false})
      refute html =~ "rotate-90"
    end

    test "renders inner_block cells" do
      html = render_component(&H.render_row/1, %{})
      assert html =~ "Cell content"
    end
  end

  # ---------------------------------------------------------------------------
  # expandable_table_detail/1
  # ---------------------------------------------------------------------------

  describe "expandable_table_detail/1" do
    test "renders tr element with correct id" do
      html = render_component(&H.render_detail/1, %{row_id: "row-99"})
      assert html =~ ~s(id="row-detail-row-99")
    end

    test "is hidden when not expanded" do
      html = render_component(&H.render_detail/1, %{expanded: false})
      assert html =~ "hidden"
    end

    test "is visible when expanded" do
      html = render_component(&H.render_detail/1, %{expanded: true})
      refute html =~ "hidden"
    end

    test "renders inner content" do
      html = render_component(&H.render_detail/1, %{})
      assert html =~ "Detail content here"
    end

    test "renders td with col_span" do
      html = render_component(&H.render_detail/1, %{col_span: 5})
      assert html =~ ~s(colspan="5")
    end
  end
end
