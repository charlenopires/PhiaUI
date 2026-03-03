defmodule PhiaUi.Components.EmptyStateTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.EmptyState

    def render_full(assigns) do
      ~H"""
      <.empty>
        <:icon>📭</:icon>
        <:title>No items found</:title>
        <:description>Get started by creating a new item.</:description>
        <:action><button>Create Item</button></:action>
      </.empty>
      """
    end

    def render_no_action(assigns) do
      ~H"""
      <.empty>
        <:title>Empty</:title>
      </.empty>
      """
    end

    def render_no_icon(assigns) do
      ~H"""
      <.empty>
        <:title>No icon here</:title>
        <:description>Just a description.</:description>
        <:action><button>Act</button></:action>
      </.empty>
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.empty class="custom-class">
        <:title>Custom class</:title>
      </.empty>
      """
    end

    def render_with_rest(assigns) do
      ~H"""
      <.empty data-testid="my-empty">
        <:title>With rest</:title>
      </.empty>
      """
    end

    def render_in_table(assigns) do
      ~H"""
      <table>
        <tbody>
          <tr>
            <td colspan="4">
              <.empty>
                <:title>No rows</:title>
              </.empty>
            </td>
          </tr>
        </tbody>
      </table>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # Full render — all slots
  # ---------------------------------------------------------------------------

  describe "empty/1" do
    test "renders with all slots" do
      html = render_component(&H.render_full/1, %{})
      assert html =~ "No items found"
      assert html =~ "Get started by creating a new item."
      assert html =~ "Create Item"
      assert html =~ "📭"
    end

    test "renders without action slot" do
      html = render_component(&H.render_no_action/1, %{})
      assert html =~ "Empty"
      refute html =~ "Create Item"
    end

    test "renders without icon slot" do
      html = render_component(&H.render_no_icon/1, %{})
      assert html =~ "No icon here"
      refute html =~ "📭"
    end

    test "renders flex-col items-center layout" do
      html = render_component(&H.render_full/1, %{})
      assert html =~ "flex flex-col items-center"
    end

    test "renders justify-center" do
      html = render_component(&H.render_full/1, %{})
      assert html =~ "justify-center"
    end

    test "renders title with text-foreground" do
      html = render_component(&H.render_full/1, %{})
      assert html =~ "text-foreground"
    end

    test "renders description with text-muted-foreground" do
      html = render_component(&H.render_full/1, %{})
      assert html =~ "text-muted-foreground"
    end

    test "renders icon wrapper with text-muted-foreground" do
      html = render_component(&H.render_full/1, %{})
      assert html =~ "text-muted-foreground"
    end

    test "does not render icon wrapper when icon slot is empty" do
      html = render_component(&H.render_no_action/1, %{})
      refute html =~ "mb-4 text-muted-foreground"
    end

    test "does not render description wrapper when description slot is empty" do
      html = render_component(&H.render_no_action/1, %{})
      refute html =~ "max-w-sm"
    end

    test "does not render action wrapper when action slot is empty" do
      html = render_component(&H.render_no_action/1, %{})
      refute html =~ "Create Item"
    end
  end

  # ---------------------------------------------------------------------------
  # :class merge and @rest
  # ---------------------------------------------------------------------------

  describe ":class merge" do
    test "adds custom class to root element" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "custom-class"
    end

    test "preserves base flex class alongside custom class" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "flex"
    end
  end

  describe "@rest passthrough" do
    test "passes data-testid to root element" do
      html = render_component(&H.render_with_rest/1, %{})
      assert html =~ ~s(data-testid="my-empty")
    end
  end

  # ---------------------------------------------------------------------------
  # Table usage
  # ---------------------------------------------------------------------------

  describe "table usage" do
    test "renders correctly inside td element" do
      html = render_component(&H.render_in_table/1, %{})
      assert html =~ "No rows"
      assert html =~ "<td"
      assert html =~ ~s(colspan="4")
    end
  end
end
