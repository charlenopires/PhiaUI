defmodule PhiaUi.Components.ComparisonTableTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ComparisonTable

    def render_basic(assigns) do
      ~H"""
      <.comparison_table
        plans={[
          %{name: "Starter", highlighted: false},
          %{name: "Pro", highlighted: true}
        ]}
        features={[
          %{label: "Users", values: ["1", "10"]},
          %{label: "API", values: [false, true]}
        ]}
      />
      """
    end

    def render_string_cell(assigns) do
      ~H"""
      <.comparison_table
        plans={[%{name: "A", highlighted: false}]}
        features={[%{label: "SLA", values: ["99.9%"]}]}
      />
      """
    end

    def render_true_cell(assigns) do
      ~H"""
      <.comparison_table
        plans={[%{name: "A", highlighted: false}]}
        features={[%{label: "Support", values: [true]}]}
      />
      """
    end

    def render_false_cell(assigns) do
      ~H"""
      <.comparison_table
        plans={[%{name: "A", highlighted: false}]}
        features={[%{label: "Custom", values: [false]}]}
      />
      """
    end

    def render_with_footer(assigns) do
      ~H"""
      <.comparison_table
        plans={[%{name: "Plan", highlighted: false}]}
        features={[]}
      >
        <:footer>Footer content</:footer>
      </.comparison_table>
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.comparison_table
        plans={[%{name: "A", highlighted: false}]}
        features={[]}
        class="my-table"
      />
      """
    end
  end

  describe "comparison_table/1" do
    test "renders a table element" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<table"
    end

    test "renders plan names in thead" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "Starter"
      assert html =~ "Pro"
    end

    test "renders feature labels" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "Users"
      assert html =~ "API"
    end

    test "highlighted column gets bg-primary/5 class" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "bg-primary/5"
    end

    test "highlighted column gets border class" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "border-primary/20"
    end

    test "true value renders check icon" do
      html = render_component(&H.render_true_cell/1, %{})
      assert html =~ "check"
      assert html =~ "text-green-600"
    end

    test "false value renders minus icon" do
      html = render_component(&H.render_false_cell/1, %{})
      assert html =~ "minus"
    end

    test "string value is rendered as text" do
      html = render_component(&H.render_string_cell/1, %{})
      assert html =~ "99.9%"
    end

    test "overflow wrapper is present" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "overflow-x-auto"
    end

    test "footer slot is rendered" do
      html = render_component(&H.render_with_footer/1, %{})
      assert html =~ "Footer content"
    end

    test "custom class applied to root" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-table"
    end
  end
end
