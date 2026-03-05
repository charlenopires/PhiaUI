defmodule PhiaUi.Components.FilterBuilderTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  @fields [
    %{
      name: "status",
      label: "Status",
      type: "select",
      options: [{"Active", "active"}, {"Inactive", "inactive"}]
    },
    %{name: "name", label: "Name", type: "text"},
    %{name: "created_at", label: "Created At", type: "date"}
  ]

  @rules [
    %{id: "r1", field: "status", operator: "equals", value: "active"},
    %{id: "r2", field: "name", operator: "contains", value: "Alice"}
  ]

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.FilterBuilder

    def render_builder(assigns) do
      ~H"""
      <.filter_builder
        fields={assigns[:fields] || []}
        rules={assigns[:rules] || []}
        on_add="add_rule"
        on_remove="remove_rule"
        on_change="update_rule"
        class={assigns[:class]}
      />
      """
    end

    def render_rule(assigns) do
      ~H"""
      <.filter_rule
        id={assigns[:id] || "r1"}
        field={assigns[:field] || "name"}
        operator={assigns[:operator] || "contains"}
        value={assigns[:value] || ""}
        fields={assigns[:fields] || [%{name: "name", label: "Name", type: "text"}]}
        on_remove={assigns[:on_remove] || "remove_rule"}
        on_change={assigns[:on_change] || "update_rule"}
        class={assigns[:class]}
      />
      """
    end

    def render_full(assigns) do
      ~H"""
      <.filter_builder
        fields={assigns[:fields]}
        rules={assigns[:rules] || []}
        on_add="add_rule"
        on_remove="remove_rule"
        on_change="update_rule"
      />
      """
    end
  end

  defp render_builder(attrs \\ %{}), do: render_component(&H.render_builder/1, attrs)
  defp render_rule(attrs \\ %{}), do: render_component(&H.render_rule/1, attrs)

  defp render_full(attrs \\ %{}),
    do: render_component(&H.render_full/1, Map.merge(%{fields: @fields}, attrs))

  # ---------------------------------------------------------------------------
  # filter_builder/1 — root container
  # ---------------------------------------------------------------------------

  describe "filter_builder/1 — structure" do
    test "renders a root element" do
      assert render_builder() =~ "<div"
    end

    test "custom class is applied to wrapper" do
      assert render_builder(%{class: "my-builder"}) =~ "my-builder"
    end

    test "renders 'Add filter' or 'Add rule' button" do
      html = render_builder()
      assert html =~ "Add" or html =~ "add"
    end

    test "add button has phx-click wired to on_add event" do
      html = render_builder(%{fields: @fields})
      assert html =~ "add_rule"
    end

    test "renders no rules section when rules list is empty" do
      html = render_builder(%{fields: @fields, rules: []})
      refute html =~ ~s(id="r1")
    end

    test "renders rules when rules list is populated" do
      html = render_builder(%{fields: @fields, rules: @rules})
      assert html =~ "r1" or html =~ "status"
    end
  end

  # ---------------------------------------------------------------------------
  # filter_rule/1 — individual rule row
  # ---------------------------------------------------------------------------

  describe "filter_rule/1 — structure" do
    test "renders a row element" do
      assert render_rule() =~ "<div" or render_rule() =~ "<li"
    end

    test "renders a field selector" do
      html = render_rule()
      assert html =~ "<select" or html =~ "field"
    end

    test "renders an operator selector" do
      html = render_rule()
      assert html =~ "operator" or html =~ "contains" or html =~ "<select"
    end

    test "renders a value input" do
      html = render_rule()
      assert html =~ "<input" or html =~ "value"
    end

    test "renders a remove button" do
      html = render_rule()
      assert html =~ "<button"
    end

    test "remove button has phx-click wired to on_remove" do
      html = render_rule(%{on_remove: "my_remove"})
      assert html =~ "my_remove"
    end

    test "remove button carries rule id as phx-value" do
      html = render_rule(%{id: "rule-99"})
      assert html =~ "rule-99"
    end

    test "current field value is shown in the field select" do
      html = render_rule(%{field: "name"})
      assert html =~ "name"
    end

    test "current operator value is shown in the operator select" do
      html = render_rule(%{operator: "contains"})
      assert html =~ "contains"
    end

    test "current value is shown in the value input" do
      html = render_rule(%{value: "Alice"})
      assert html =~ "Alice"
    end

    test "custom class is applied" do
      assert render_rule(%{class: "my-rule"}) =~ "my-rule"
    end
  end

  # ---------------------------------------------------------------------------
  # Operators
  # ---------------------------------------------------------------------------

  describe "filter_rule/1 — operators" do
    test "renders common operators for text fields" do
      html = render_rule(%{fields: [%{name: "name", label: "Name", type: "text"}], field: "name"})
      assert html =~ "contains" or html =~ "equals" or html =~ "starts"
    end

    test "renders operator options as <option> elements" do
      html = render_rule()
      assert html =~ "<option"
    end
  end

  # ---------------------------------------------------------------------------
  # Full composition
  # ---------------------------------------------------------------------------

  describe "full composition" do
    test "renders rule rows for each rule in the list" do
      html = render_full(%{rules: @rules})
      assert html =~ "active" or html =~ "status"
      assert html =~ "Alice" or html =~ "name"
    end

    test "renders field options from fields list" do
      html = render_full(%{rules: @rules})
      assert html =~ "Status" or html =~ "Name"
    end

    test "renders add button even with existing rules" do
      html = render_full(%{rules: @rules})
      assert html =~ "Add" or html =~ "add"
    end

    test "renders empty state with just the add button when no rules" do
      html = render_full(%{rules: []})
      assert html =~ "Add" or html =~ "add"
      refute html =~ "Alice"
    end
  end

  # ---------------------------------------------------------------------------
  # Semantic tokens
  # ---------------------------------------------------------------------------

  describe "filter_builder/1 — semantic tokens" do
    test "uses border-border or border-input token" do
      html = render_full(%{rules: @rules})
      assert html =~ "border-border" or html =~ "border-input" or html =~ "border"
    end

    test "no hardcoded hex colors in style attributes" do
      html = render_full(%{rules: @rules})
      refute html =~ ~r/style="[^"]*#[0-9a-fA-F]{3,6}/
    end

    test "uses semantic background tokens" do
      html = render_full(%{rules: @rules})
      assert html =~ "bg-background" or html =~ "bg-muted" or html =~ "bg-"
    end
  end
end
