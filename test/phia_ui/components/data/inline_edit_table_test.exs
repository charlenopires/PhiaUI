defmodule PhiaUi.Components.InlineEditTableTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.InlineEditTable

    attr(:editing, :boolean, default: false)

    def render_cell(assigns) do
      ~H"""
      <table><tbody><tr>
        <.editable_cell editing={@editing}>
          <:view>View content</:view>
          <:edit><input type="text" value="edit val" /></:edit>
        </.editable_cell>
      </tr></tbody></table>
      """
    end

    attr(:editing, :boolean, default: false)

    def render_row(assigns) do
      ~H"""
      <table><tbody>
        <.editable_row editing={@editing}>
          <td>content</td>
        </.editable_row>
      </tbody></table>
      """
    end

    attr(:row_id, :string, default: "row-1")
    attr(:saving, :boolean, default: false)
    attr(:on_save, :string, default: "save_row")
    attr(:on_cancel, :string, default: "cancel_edit")

    def render_actions(assigns) do
      ~H"""
      <table><tbody><tr>
        <.editable_row_actions
          row_id={@row_id}
          saving={@saving}
          on_save={@on_save}
          on_cancel={@on_cancel}
        />
      </tr></tbody></table>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # editable_cell/1
  # ---------------------------------------------------------------------------

  describe "editable_cell/1" do
    test "renders td element" do
      html = render_component(&H.render_cell/1, %{})
      assert html =~ "<td"
    end

    test "shows view slot when not editing" do
      html = render_component(&H.render_cell/1, %{editing: false})
      assert html =~ "View content"
    end

    test "shows edit slot when editing" do
      html = render_component(&H.render_cell/1, %{editing: true})
      assert html =~ "edit val"
    end

    test "hides edit when not editing" do
      html = render_component(&H.render_cell/1, %{editing: false})
      refute html =~ "edit val"
    end

    test "hides view when editing" do
      html = render_component(&H.render_cell/1, %{editing: true})
      refute html =~ "View content"
    end

    test "has align-middle class" do
      html = render_component(&H.render_cell/1, %{})
      assert html =~ "align-middle"
    end
  end

  # ---------------------------------------------------------------------------
  # editable_row/1
  # ---------------------------------------------------------------------------

  describe "editable_row/1" do
    test "renders tr element" do
      html = render_component(&H.render_row/1, %{})
      assert html =~ "<tr"
    end

    test "sets data-editing=true when editing" do
      html = render_component(&H.render_row/1, %{editing: true})
      assert html =~ ~s(data-editing="true")
    end

    test "does not set data-editing when not editing" do
      html = render_component(&H.render_row/1, %{editing: false})
      refute html =~ "data-editing"
    end

    test "adds ring and bg-muted when editing" do
      html = render_component(&H.render_row/1, %{editing: true})
      assert html =~ "bg-muted/20"
      assert html =~ "ring-primary/30"
    end

    test "does not add ring when not editing" do
      html = render_component(&H.render_row/1, %{editing: false})
      refute html =~ "ring-primary"
    end

    test "renders inner content" do
      html = render_component(&H.render_row/1, %{})
      assert html =~ "content"
    end
  end

  # ---------------------------------------------------------------------------
  # editable_row_actions/1
  # ---------------------------------------------------------------------------

  describe "editable_row_actions/1" do
    test "renders td element" do
      html = render_component(&H.render_actions/1, %{})
      assert html =~ "<td"
    end

    test "renders Save and Cancel buttons" do
      html = render_component(&H.render_actions/1, %{})
      assert html =~ "Save"
      assert html =~ "Cancel"
    end

    test "Save button fires on_save event" do
      html = render_component(&H.render_actions/1, %{on_save: "my_save", row_id: "r1"})
      assert html =~ ~s(phx-click="my_save")
      assert html =~ ~s(phx-value-id="r1")
    end

    test "Cancel button fires on_cancel event" do
      html = render_component(&H.render_actions/1, %{on_cancel: "my_cancel", row_id: "r1"})
      assert html =~ ~s(phx-click="my_cancel")
    end

    test "Save button has aria-label" do
      html = render_component(&H.render_actions/1, %{})
      assert html =~ ~s(aria-label="Save row")
    end

    test "Cancel button has aria-label" do
      html = render_component(&H.render_actions/1, %{})
      assert html =~ ~s(aria-label="Cancel edit")
    end

    test "adds pointer-events-none when saving" do
      html = render_component(&H.render_actions/1, %{saving: true})
      assert html =~ "pointer-events-none"
      assert html =~ "opacity-60"
    end

    test "does not add pointer-events-none when not saving" do
      html = render_component(&H.render_actions/1, %{saving: false})
      refute html =~ "pointer-events-none"
    end
  end
end
