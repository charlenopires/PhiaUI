defmodule PhiaUi.Components.ResponsiveTableTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ResponsiveTable

    def render_table(assigns) do
      ~H"""
      <.responsive_table>
        <:header>
          <tr>
            <th>Name</th>
            <th>Email</th>
          </tr>
        </:header>
        <.responsive_table_row>
          <.responsive_table_field label="Name">Alice</.responsive_table_field>
          <.responsive_table_field label="Email">alice@example.com</.responsive_table_field>
        </.responsive_table_row>
      </.responsive_table>
      """
    end

    attr(:class, :string, default: nil)

    def render_table_custom(assigns) do
      ~H"""
      <.responsive_table class={@class}>
        <:header><tr><th>Col</th></tr></:header>
        <.responsive_table_row>
          <.responsive_table_field label="Col">Value</.responsive_table_field>
        </.responsive_table_row>
      </.responsive_table>
      """
    end

    attr(:class, :string, default: nil)

    def render_row(assigns) do
      ~H"""
      <table><tbody>
        <.responsive_table_row class={@class}>
          <td>Content</td>
        </.responsive_table_row>
      </tbody></table>
      """
    end

    attr(:label, :string, default: "Column")
    attr(:class, :string, default: nil)

    def render_field(assigns) do
      ~H"""
      <table><tbody><tr>
        <.responsive_table_field label={@label} class={@class}>
          Value
        </.responsive_table_field>
      </tr></tbody></table>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # responsive_table/1
  # ---------------------------------------------------------------------------

  describe "responsive_table/1" do
    test "renders overflow wrapper" do
      html = render_component(&H.render_table/1, %{})
      assert html =~ "overflow-x-auto"
    end

    test "renders table element" do
      html = render_component(&H.render_table/1, %{})
      assert html =~ "<table"
    end

    test "renders thead with header slot" do
      html = render_component(&H.render_table/1, %{})
      assert html =~ "<thead"
      assert html =~ "Name"
      assert html =~ "Email"
    end

    test "renders tbody" do
      html = render_component(&H.render_table/1, %{})
      assert html =~ "<tbody"
    end

    test "renders row content" do
      html = render_component(&H.render_table/1, %{})
      assert html =~ "Alice"
      assert html =~ "alice@example.com"
    end

    test "accepts custom class" do
      html = render_component(&H.render_table_custom/1, %{class: "phia-responsive-table"})
      assert html =~ "phia-responsive-table"
    end
  end

  # ---------------------------------------------------------------------------
  # responsive_table_row/1
  # ---------------------------------------------------------------------------

  describe "responsive_table_row/1" do
    test "renders tr element" do
      html = render_component(&H.render_row/1, %{})
      assert html =~ "<tr"
    end

    test "has hover styling" do
      html = render_component(&H.render_row/1, %{})
      assert html =~ "hover:bg-muted/50"
    end

    test "has border-b" do
      html = render_component(&H.render_row/1, %{})
      assert html =~ "border-b"
    end

    test "accepts custom class" do
      html = render_component(&H.render_row/1, %{class: "my-row"})
      assert html =~ "my-row"
    end

    test "renders inner content" do
      html = render_component(&H.render_row/1, %{})
      assert html =~ "Content"
    end
  end

  # ---------------------------------------------------------------------------
  # responsive_table_field/1
  # ---------------------------------------------------------------------------

  describe "responsive_table_field/1" do
    test "renders td element" do
      html = render_component(&H.render_field/1, %{})
      assert html =~ "<td"
    end

    test "has data-label attribute" do
      html = render_component(&H.render_field/1, %{label: "My Column"})
      assert html =~ ~s(data-label="My Column")
    end

    test "has align-middle" do
      html = render_component(&H.render_field/1, %{})
      assert html =~ "align-middle"
    end

    test "renders inner content" do
      html = render_component(&H.render_field/1, %{})
      assert html =~ "Value"
    end

    test "accepts custom class" do
      html = render_component(&H.render_field/1, %{class: "font-bold"})
      assert html =~ "font-bold"
    end
  end
end
