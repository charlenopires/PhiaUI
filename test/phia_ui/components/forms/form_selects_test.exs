defmodule PhiaUi.Components.FormSelectsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helper module
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.FormSelects

    attr :label, :string, default: "Choose options"
    attr :description, :string, default: nil
    attr :errors, :list, default: []
    attr :orientation, :string, default: "vertical"

    def render_checkbox_group(assigns) do
      ~H"""
      <.checkbox_group
        label={@label}
        description={@description}
        errors={@errors}
        orientation={@orientation}
      >
        <.checkbox_group_item name="opts[]" value="a" label="Option A" />
        <.checkbox_group_item name="opts[]" value="b" label="Option B" checked={true} />
      </.checkbox_group>
      """
    end

    attr :value, :string, default: "x"
    attr :label, :string, default: "My Option"
    attr :checked, :boolean, default: false
    attr :disabled, :boolean, default: false

    def render_checkbox_group_item(assigns) do
      ~H"""
      <.checkbox_group_item
        name="items[]"
        value={@value}
        label={@label}
        checked={@checked}
        disabled={@disabled}
      />
      """
    end

    attr :field, :any
    attr :options, :list, default: [{"Elixir", "elixir"}, {"Rust", "rust"}]

    def render_form_checkbox_group(assigns) do
      ~H"""
      <.form_checkbox_group field={@field} label="Languages" options={@options} />
      """
    end

    attr :value, :string, default: "plan_a"
    attr :label, :string, default: "Plan A"
    attr :description, :string, default: nil
    attr :checked, :boolean, default: false
    attr :disabled, :boolean, default: false

    def render_radio_card(assigns) do
      ~H"""
      <.radio_card
        name="plan"
        value={@value}
        label={@label}
        description={@description}
        checked={@checked}
        disabled={@disabled}
      />
      """
    end

    attr :layout, :string, default: "stack"
    attr :cols, :integer, default: 2

    def render_radio_card_group(assigns) do
      ~H"""
      <.radio_card_group name="plan" layout={@layout} cols={@cols}>
        <.radio_card name="plan" value="free" label="Free" />
        <.radio_card name="plan" value="pro" label="Pro" />
      </.radio_card_group>
      """
    end

    attr :field, :any
    attr :options, :list, default: [{"Free", "free"}, {"Pro", "pro"}]

    def render_form_radio_card_group(assigns) do
      ~H"""
      <.form_radio_card_group field={@field} label="Plan" options={@options} />
      """
    end

    attr :id, :string, default: "cascader-1"
    attr :value, :list, default: []

    def render_cascader(assigns) do
      ~H"""
      <.cascader
        id={@id}
        name="category"
        options={[{"Electronics", "electronics"}, {"Clothing", "clothing"}]}
        value={@value}
        placeholder="Pick category"
      />
      """
    end

    attr :field, :any

    def render_form_cascader(assigns) do
      ~H"""
      <.form_cascader
        field={@field}
        label="Category"
        options={[{"A", "a"}, {"B", "b"}]}
      />
      """
    end

    attr :source_items, :list, default: [{"Alpha", "alpha"}, {"Beta", "beta"}]
    attr :target_items, :list, default: [{"Gamma", "gamma"}]

    def render_button_transfer_list(assigns) do
      ~H"""
      <.button_transfer_list
        id="my-transfer"
        source_items={@source_items}
        target_items={@target_items}
        source_label="Available"
        target_label="Selected"
      />
      """
    end
  end

  defp build_field(attrs \\ []) do
    %Phoenix.HTML.FormField{
      id: Keyword.get(attrs, :id, "user_roles"),
      name: Keyword.get(attrs, :name, "user[roles]"),
      errors: Keyword.get(attrs, :errors, []),
      field: Keyword.get(attrs, :field, :roles),
      value: Keyword.get(attrs, :value, []),
      form: nil
    }
  end

  # ---------------------------------------------------------------------------
  # checkbox_group/1
  # ---------------------------------------------------------------------------

  describe "checkbox_group/1" do
    test "renders fieldset element" do
      html = render_component(&H.render_checkbox_group/1, %{})
      assert html =~ "<fieldset"
    end

    test "renders legend with label text" do
      html = render_component(&H.render_checkbox_group/1, %{label: "Interests"})
      assert html =~ "<legend"
      assert html =~ "Interests"
    end

    test "renders description when provided" do
      html = render_component(&H.render_checkbox_group/1, %{description: "Pick all that apply"})
      assert html =~ "Pick all that apply"
    end

    test "renders error messages" do
      html = render_component(&H.render_checkbox_group/1, %{errors: ["must select at least one"]})
      assert html =~ "must select at least one"
      assert html =~ "text-destructive"
    end

    test "renders slot items" do
      html = render_component(&H.render_checkbox_group/1, %{})
      assert html =~ "Option A"
      assert html =~ "Option B"
    end

    test "applies horizontal flex layout when orientation is horizontal" do
      html = render_component(&H.render_checkbox_group/1, %{orientation: "horizontal"})
      assert html =~ "flex-wrap"
    end

    test "applies vertical flex layout when orientation is vertical" do
      html = render_component(&H.render_checkbox_group/1, %{orientation: "vertical"})
      assert html =~ "flex-col"
    end
  end

  # ---------------------------------------------------------------------------
  # checkbox_group_item/1
  # ---------------------------------------------------------------------------

  describe "checkbox_group_item/1" do
    test "renders a checkbox input" do
      html = render_component(&H.render_checkbox_group_item/1, %{})
      assert html =~ ~s(type="checkbox")
    end

    test "renders label text" do
      html = render_component(&H.render_checkbox_group_item/1, %{label: "Elixir"})
      assert html =~ "Elixir"
    end

    test "sets value attribute" do
      html = render_component(&H.render_checkbox_group_item/1, %{value: "elixir"})
      assert html =~ ~s(value="elixir")
    end

    test "sets checked attribute when checked is true" do
      html = render_component(&H.render_checkbox_group_item/1, %{checked: true})
      assert html =~ "checked"
    end

    test "sets disabled attribute when disabled is true" do
      html = render_component(&H.render_checkbox_group_item/1, %{disabled: true})
      assert html =~ "disabled"
    end

    test "applies opacity class when disabled" do
      html = render_component(&H.render_checkbox_group_item/1, %{disabled: true})
      assert html =~ "opacity-50"
    end
  end

  # ---------------------------------------------------------------------------
  # form_checkbox_group/1
  # ---------------------------------------------------------------------------

  describe "form_checkbox_group/1" do
    test "renders checkboxes for each option" do
      field = build_field()

      html =
        render_component(&H.render_form_checkbox_group/1, %{
          field: field,
          options: [{"Elixir", "elixir"}, {"Rust", "rust"}]
        })

      assert html =~ "Elixir"
      assert html =~ "Rust"
    end

    test "marks option as checked when value is in field.value" do
      field = build_field(value: ["elixir"])

      html =
        render_component(&H.render_form_checkbox_group/1, %{
          field: field,
          options: [{"Elixir", "elixir"}, {"Rust", "rust"}]
        })

      assert html =~ "checked"
    end

    test "renders errors from field.errors" do
      field = build_field(errors: [{"must select at least one", []}])
      html = render_component(&H.render_form_checkbox_group/1, %{field: field})
      assert html =~ "must select at least one"
    end

    test "uses array name format for multi-select" do
      field = build_field(name: "user[roles]")
      html = render_component(&H.render_form_checkbox_group/1, %{field: field})
      assert html =~ "user[roles][]"
    end
  end

  # ---------------------------------------------------------------------------
  # radio_card/1
  # ---------------------------------------------------------------------------

  describe "radio_card/1" do
    test "renders a hidden radio input" do
      html = render_component(&H.render_radio_card/1, %{})
      assert html =~ ~s(type="radio")
      assert html =~ "sr-only"
    end

    test "renders label text" do
      html = render_component(&H.render_radio_card/1, %{label: "Professional"})
      assert html =~ "Professional"
    end

    test "renders description when provided" do
      html = render_component(&H.render_radio_card/1, %{description: "Best for teams"})
      assert html =~ "Best for teams"
    end

    test "sets value attribute" do
      html = render_component(&H.render_radio_card/1, %{value: "pro"})
      assert html =~ ~s(value="pro")
    end

    test "sets checked attribute when checked is true" do
      html = render_component(&H.render_radio_card/1, %{checked: true})
      assert html =~ "checked"
    end

    test "applies disabled styling and attribute when disabled" do
      html = render_component(&H.render_radio_card/1, %{disabled: true})
      assert html =~ "disabled"
      assert html =~ "opacity-50"
    end

    test "includes peer-checked border ring overlay" do
      html = render_component(&H.render_radio_card/1, %{})
      assert html =~ "peer-checked:border-primary"
    end

    test "renders check dot indicator" do
      html = render_component(&H.render_radio_card/1, %{})
      assert html =~ "peer-checked:bg-primary"
    end
  end

  # ---------------------------------------------------------------------------
  # radio_card_group/1
  # ---------------------------------------------------------------------------

  describe "radio_card_group/1" do
    test "renders role=radiogroup" do
      html = render_component(&H.render_radio_card_group/1, %{})
      assert html =~ ~s(role="radiogroup")
    end

    test "renders slot content (radio cards)" do
      html = render_component(&H.render_radio_card_group/1, %{})
      assert html =~ "Free"
      assert html =~ "Pro"
    end

    test "applies grid layout with cols class when layout is grid" do
      html = render_component(&H.render_radio_card_group/1, %{layout: "grid", cols: 2})
      assert html =~ "grid-cols-2"
    end

    test "applies flex-col layout when layout is stack" do
      html = render_component(&H.render_radio_card_group/1, %{layout: "stack"})
      assert html =~ "flex-col"
    end
  end

  # ---------------------------------------------------------------------------
  # form_radio_card_group/1
  # ---------------------------------------------------------------------------

  describe "form_radio_card_group/1" do
    test "renders label" do
      field = build_field()
      html = render_component(&H.render_form_radio_card_group/1, %{field: field})
      assert html =~ "Plan"
    end

    test "renders a card for each option" do
      field = build_field()

      html =
        render_component(&H.render_form_radio_card_group/1, %{
          field: field,
          options: [{"Free", "free"}, {"Pro", "pro"}]
        })

      assert html =~ "Free"
      assert html =~ "Pro"
    end

    test "marks option as checked when it matches field.value" do
      field = build_field(value: "pro")

      html =
        render_component(&H.render_form_radio_card_group/1, %{
          field: field,
          options: [{"Free", "free"}, {"Pro", "pro"}]
        })

      assert html =~ "checked"
    end

    test "renders field errors" do
      field = build_field(errors: [{"is required", []}])
      html = render_component(&H.render_form_radio_card_group/1, %{field: field})
      assert html =~ "is required"
    end
  end

  # ---------------------------------------------------------------------------
  # cascader/1
  # ---------------------------------------------------------------------------

  describe "cascader/1" do
    test "renders with phx-hook attribute" do
      html = render_component(&H.render_cascader/1, %{id: "cas-1"})
      assert html =~ ~s(phx-hook="PhiaCascader")
    end

    test "requires id attribute for hook" do
      html = render_component(&H.render_cascader/1, %{id: "cas-2"})
      assert html =~ ~s(id="cas-2")
    end

    test "renders trigger button" do
      html = render_component(&H.render_cascader/1, %{})
      assert html =~ "data-cascader-trigger"
    end

    test "renders placeholder text when value is empty" do
      html = render_component(&H.render_cascader/1, %{value: []})
      assert html =~ "Pick category"
    end

    test "renders data-options JSON attribute" do
      html = render_component(&H.render_cascader/1, %{})
      assert html =~ "data-options"
    end

    test "renders data-value JSON attribute" do
      html = render_component(&H.render_cascader/1, %{value: []})
      assert html =~ "data-value"
    end

    test "renders hidden input for name" do
      html = render_component(&H.render_cascader/1, %{})
      assert html =~ ~s(type="hidden")
      assert html =~ ~s(name="category")
    end

    test "renders panels container" do
      html = render_component(&H.render_cascader/1, %{})
      assert html =~ "data-cascader-panels"
    end
  end

  # ---------------------------------------------------------------------------
  # form_cascader/1
  # ---------------------------------------------------------------------------

  describe "form_cascader/1" do
    test "renders label" do
      field = build_field()
      html = render_component(&H.render_form_cascader/1, %{field: field})
      assert html =~ "Category"
    end

    test "renders cascader hook" do
      field = build_field()
      html = render_component(&H.render_form_cascader/1, %{field: field})
      assert html =~ ~s(phx-hook="PhiaCascader")
    end

    test "uses field.id as cascader id" do
      field = build_field(id: "user_category")
      html = render_component(&H.render_form_cascader/1, %{field: field})
      assert html =~ ~s(id="user_category")
    end

    test "renders errors from field" do
      field = build_field(errors: [{"is required", []}])
      html = render_component(&H.render_form_cascader/1, %{field: field})
      assert html =~ "is required"
    end
  end

  # ---------------------------------------------------------------------------
  # button_transfer_list/1
  # ---------------------------------------------------------------------------

  describe "button_transfer_list/1" do
    test "renders source panel label" do
      html = render_component(&H.render_button_transfer_list/1, %{})
      assert html =~ "Available"
    end

    test "renders target panel label" do
      html = render_component(&H.render_button_transfer_list/1, %{})
      assert html =~ "Selected"
    end

    test "renders source items" do
      html = render_component(&H.render_button_transfer_list/1, %{})
      assert html =~ "Alpha"
      assert html =~ "Beta"
    end

    test "renders target items" do
      html = render_component(&H.render_button_transfer_list/1, %{})
      assert html =~ "Gamma"
    end

    test "renders control arrow buttons" do
      html = render_component(&H.render_button_transfer_list/1, %{})
      assert html =~ "to_target"
      assert html =~ "to_source"
    end

    test "renders move-all and move-selected buttons" do
      html = render_component(&H.render_button_transfer_list/1, %{})
      assert html =~ "transfer_move_selected"
      assert html =~ "transfer_move_all"
    end

    test "renders item count in panel header" do
      html = render_component(&H.render_button_transfer_list/1, %{})
      assert html =~ "(2)"
      assert html =~ "(1)"
    end

    test "uses provided id" do
      html = render_component(&H.render_button_transfer_list/1, %{})
      assert html =~ ~s(id="my-transfer")
    end
  end
end
