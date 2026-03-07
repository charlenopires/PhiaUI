defmodule PhiaUi.Components.FormLayoutTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helper module
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.FormLayout

    attr :title, :string, default: "Section Title"
    attr :description, :string, default: nil
    attr :collapsible, :boolean, default: false
    attr :open, :boolean, default: true
    attr :class, :string, default: nil

    def render_form_section(assigns) do
      ~H"""
      <.form_section title={@title} description={@description} collapsible={@collapsible} open={@open} class={@class}>
        <p>Section content</p>
      </.form_section>
      """
    end

    attr :legend, :string, default: "Legend Text"
    attr :required, :boolean, default: false
    attr :disabled, :boolean, default: false
    attr :class, :string, default: nil

    def render_form_fieldset(assigns) do
      ~H"""
      <.form_fieldset legend={@legend} required={@required} disabled={@disabled} class={@class}>
        <input type="text" name="field" />
      </.form_fieldset>
      """
    end

    attr :cols, :integer, default: 2
    attr :gap, :string, default: "md"
    attr :class, :string, default: nil

    def render_form_grid(assigns) do
      ~H"""
      <.form_grid cols={@cols} gap={@gap} class={@class}>
        <div>Field 1</div>
        <div>Field 2</div>
      </.form_grid>
      """
    end

    def render_form_row(assigns) do
      ~H"""
      <.form_row>
        <div class="flex-1">Field A</div>
        <div class="flex-1">Field B</div>
      </.form_row>
      """
    end

    attr :align, :string, default: "end"
    attr :class, :string, default: nil

    def render_form_actions(assigns) do
      ~H"""
      <.form_actions align={@align} class={@class}>
        <button type="button">Cancel</button>
        <button type="submit">Save</button>
      </.form_actions>
      """
    end

    attr :errors, :list, default: []
    attr :title, :string, default: "Please fix the following errors:"

    def render_form_summary(assigns) do
      ~H"""
      <.form_summary errors={@errors} title={@title} />
      """
    end
  end

  # ---------------------------------------------------------------------------
  # form_section/1
  # ---------------------------------------------------------------------------

  describe "form_section/1 - static (non-collapsible)" do
    test "renders title" do
      html = render_component(&H.render_form_section/1, %{title: "My Section"})
      assert html =~ "My Section"
    end

    test "renders inner content" do
      html = render_component(&H.render_form_section/1, %{})
      assert html =~ "Section content"
    end

    test "renders description when provided" do
      html = render_component(&H.render_form_section/1, %{description: "Helper text"})
      assert html =~ "Helper text"
    end

    test "does not render description when nil" do
      html = render_component(&H.render_form_section/1, %{description: nil})
      refute html =~ "Helper text"
    end

    test "renders a <div> root (not <details>) when collapsible is false" do
      html = render_component(&H.render_form_section/1, %{collapsible: false})
      assert html =~ "<div"
      refute html =~ "<details"
    end

    test "applies custom class" do
      html =
        render_component(&H.render_form_section/1, %{
          title: "T",
          class: "custom-section-class"
        })

      assert html =~ "custom-section-class"
    end
  end

  describe "form_section/1 - collapsible" do
    test "renders <details> element when collapsible is true" do
      html = render_component(&H.render_form_section/1, %{collapsible: true})
      assert html =~ "<details"
      assert html =~ "<summary"
    end

    test "sets open attribute on details when open is true" do
      html = render_component(&H.render_form_section/1, %{collapsible: true, open: true})
      assert html =~ "open"
    end

    test "renders chevron SVG for collapsible sections" do
      html = render_component(&H.render_form_section/1, %{collapsible: true})
      assert html =~ "<polyline"
    end

    test "renders title inside summary" do
      html = render_component(&H.render_form_section/1, %{collapsible: true, title: "Advanced"})
      assert html =~ "Advanced"
      assert html =~ "<summary"
    end
  end

  # ---------------------------------------------------------------------------
  # form_fieldset/1
  # ---------------------------------------------------------------------------

  describe "form_fieldset/1" do
    test "renders <fieldset> element" do
      html = render_component(&H.render_form_fieldset/1, %{})
      assert html =~ "<fieldset"
    end

    test "renders <legend> with text" do
      html = render_component(&H.render_form_fieldset/1, %{legend: "Contact Info"})
      assert html =~ "<legend"
      assert html =~ "Contact Info"
    end

    test "renders asterisk when required is true" do
      html = render_component(&H.render_form_fieldset/1, %{required: true})
      assert html =~ "*"
    end

    test "does not render asterisk when required is false" do
      html = render_component(&H.render_form_fieldset/1, %{required: false})
      refute html =~ ~s(aria-hidden="true")
    end

    test "sets disabled attribute when disabled is true" do
      html = render_component(&H.render_form_fieldset/1, %{disabled: true})
      assert html =~ "disabled"
    end

    test "renders inner content" do
      html = render_component(&H.render_form_fieldset/1, %{})
      assert html =~ ~s(type="text")
    end

    test "applies custom class" do
      html = render_component(&H.render_form_fieldset/1, %{class: "my-fieldset"})
      assert html =~ "my-fieldset"
    end
  end

  # ---------------------------------------------------------------------------
  # form_grid/1
  # ---------------------------------------------------------------------------

  describe "form_grid/1" do
    test "renders a grid container" do
      html = render_component(&H.render_form_grid/1, %{})
      assert html =~ "grid"
    end

    test "applies sm:grid-cols-2 class for cols=2 (default)" do
      html = render_component(&H.render_form_grid/1, %{cols: 2})
      assert html =~ "sm:grid-cols-2"
    end

    test "applies sm:grid-cols-3 class for cols=3" do
      html = render_component(&H.render_form_grid/1, %{cols: 3})
      assert html =~ "sm:grid-cols-3"
    end

    test "applies sm:grid-cols-4 class for cols=4" do
      html = render_component(&H.render_form_grid/1, %{cols: 4})
      assert html =~ "sm:grid-cols-4"
    end

    test "applies gap-3 for gap=sm" do
      html = render_component(&H.render_form_grid/1, %{gap: "sm"})
      assert html =~ "gap-3"
    end

    test "applies gap-4 for gap=md (default)" do
      html = render_component(&H.render_form_grid/1, %{gap: "md"})
      assert html =~ "gap-4"
    end

    test "applies gap-6 for gap=lg" do
      html = render_component(&H.render_form_grid/1, %{gap: "lg"})
      assert html =~ "gap-6"
    end

    test "renders inner content" do
      html = render_component(&H.render_form_grid/1, %{})
      assert html =~ "Field 1"
      assert html =~ "Field 2"
    end

    test "applies custom class" do
      html = render_component(&H.render_form_grid/1, %{class: "my-grid"})
      assert html =~ "my-grid"
    end
  end

  # ---------------------------------------------------------------------------
  # form_row/1
  # ---------------------------------------------------------------------------

  describe "form_row/1" do
    test "renders a flex container" do
      html = render_component(&H.render_form_row/1, %{})
      assert html =~ "flex"
    end

    test "renders inner content" do
      html = render_component(&H.render_form_row/1, %{})
      assert html =~ "Field A"
      assert html =~ "Field B"
    end

    test "has responsive stacking classes" do
      html = render_component(&H.render_form_row/1, %{})
      assert html =~ "flex-col"
      assert html =~ "sm:flex-row"
    end
  end

  # ---------------------------------------------------------------------------
  # form_actions/1
  # ---------------------------------------------------------------------------

  describe "form_actions/1" do
    test "renders action buttons" do
      html = render_component(&H.render_form_actions/1, %{})
      assert html =~ "Cancel"
      assert html =~ "Save"
    end

    test "applies justify-end for align=end (default)" do
      html = render_component(&H.render_form_actions/1, %{align: "end"})
      assert html =~ "justify-end"
    end

    test "applies justify-start for align=start" do
      html = render_component(&H.render_form_actions/1, %{align: "start"})
      assert html =~ "justify-start"
    end

    test "applies justify-center for align=center" do
      html = render_component(&H.render_form_actions/1, %{align: "center"})
      assert html =~ "justify-center"
    end

    test "applies justify-between for align=between" do
      html = render_component(&H.render_form_actions/1, %{align: "between"})
      assert html =~ "justify-between"
    end

    test "renders top border" do
      html = render_component(&H.render_form_actions/1, %{})
      assert html =~ "border-t"
    end

    test "applies custom class" do
      html = render_component(&H.render_form_actions/1, %{class: "custom-actions"})
      assert html =~ "custom-actions"
    end
  end

  # ---------------------------------------------------------------------------
  # form_summary/1
  # ---------------------------------------------------------------------------

  describe "form_summary/1 - empty errors" do
    test "renders nothing when errors list is empty" do
      html = render_component(&H.render_form_summary/1, %{errors: []})
      assert html == ""
    end
  end

  describe "form_summary/1 - with errors" do
    test "renders role=alert when errors are present" do
      html = render_component(&H.render_form_summary/1, %{errors: ["Name is required"]})
      assert html =~ ~s(role="alert")
    end

    test "renders aria-live=polite" do
      html = render_component(&H.render_form_summary/1, %{errors: ["Some error"]})
      assert html =~ ~s(aria-live="polite")
    end

    test "renders title text" do
      html =
        render_component(&H.render_form_summary/1, %{
          errors: ["Error"],
          title: "Fix these issues:"
        })

      assert html =~ "Fix these issues:"
    end

    test "renders each error in a list item" do
      html =
        render_component(&H.render_form_summary/1, %{
          errors: ["Name is required", "Email is invalid"]
        })

      assert html =~ "Name is required"
      assert html =~ "Email is invalid"
      assert html =~ "<li"
    end

    test "renders multiple errors" do
      errors = ["Error 1", "Error 2", "Error 3"]
      html = render_component(&H.render_form_summary/1, %{errors: errors})

      Enum.each(errors, fn e -> assert html =~ e end)
    end

    test "uses destructive styling" do
      html = render_component(&H.render_form_summary/1, %{errors: ["error"]})
      assert html =~ "destructive"
    end
  end
end
