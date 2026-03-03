defmodule PhiaUi.Components.CheckboxTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helpers
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Checkbox

    def render_unchecked(assigns) do
      ~H"""
      <.checkbox id="cb1" name="agree" />
      """
    end

    def render_checked(assigns) do
      ~H"""
      <.checkbox id="cb2" name="agree" checked={true} />
      """
    end

    def render_indeterminate(assigns) do
      ~H"""
      <.checkbox id="cb3" name="agree" indeterminate={true} />
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.checkbox id="cb4" name="agree" disabled={true} />
      """
    end

    attr(:class, :string, default: nil)

    def render_with_class(assigns) do
      ~H"""
      <.checkbox id="cb5" name="agree" class={@class} />
      """
    end

    def render_with_phx_change(assigns) do
      ~H"""
      <.checkbox id="cb6" name="agree" phx-change="toggle" />
      """
    end

    attr(:field, Phoenix.HTML.FormField)
    attr(:label, :string, default: nil)

    def render_form_checkbox(assigns) do
      ~H"""
      <.form_checkbox field={@field} label={@label} />
      """
    end

    attr(:field, Phoenix.HTML.FormField)

    def render_form_checkbox_disabled(assigns) do
      ~H"""
      <.form_checkbox field={@field} disabled={true} />
      """
    end
  end

  defp make_field(value \\ "", errors \\ []) do
    form = Phoenix.HTML.FormData.to_form(%{"agreed" => value}, as: :user)
    field = form[:agreed]
    %{field | errors: errors}
  end

  # ---------------------------------------------------------------------------
  # checkbox/1 — basic rendering
  # ---------------------------------------------------------------------------

  describe "checkbox/1 basic rendering" do
    test "renders input element" do
      html = render_component(&H.render_unchecked/1, %{})
      assert html =~ "<input"
    end

    test "renders type=checkbox" do
      html = render_component(&H.render_unchecked/1, %{})
      assert html =~ ~s(type="checkbox")
    end

    test "renders with id attribute" do
      html = render_component(&H.render_unchecked/1, %{})
      assert html =~ ~s(id="cb1")
    end

    test "renders with name attribute" do
      html = render_component(&H.render_unchecked/1, %{})
      assert html =~ ~s(name="agree")
    end
  end

  # ---------------------------------------------------------------------------
  # checkbox/1 — data-state attribute
  # ---------------------------------------------------------------------------

  describe "checkbox/1 data-state" do
    test "unchecked has data-state=unchecked" do
      html = render_component(&H.render_unchecked/1, %{})
      assert html =~ ~s(data-state="unchecked")
    end

    test "checked has data-state=checked" do
      html = render_component(&H.render_checked/1, %{})
      assert html =~ ~s(data-state="checked")
    end

    test "indeterminate has data-state=indeterminate" do
      html = render_component(&H.render_indeterminate/1, %{})
      assert html =~ ~s(data-state="indeterminate")
    end
  end

  # ---------------------------------------------------------------------------
  # checkbox/1 — aria attributes
  # ---------------------------------------------------------------------------

  describe "checkbox/1 aria attributes" do
    test "unchecked has aria-checked=false" do
      html = render_component(&H.render_unchecked/1, %{})
      assert html =~ ~s(aria-checked="false")
    end

    test "checked has aria-checked=true" do
      html = render_component(&H.render_checked/1, %{})
      assert html =~ ~s(aria-checked="true")
    end

    test "indeterminate has aria-checked=mixed" do
      html = render_component(&H.render_indeterminate/1, %{})
      assert html =~ ~s(aria-checked="mixed")
    end
  end

  # ---------------------------------------------------------------------------
  # checkbox/1 — disabled state
  # ---------------------------------------------------------------------------

  describe "checkbox/1 disabled state" do
    test "disabled=true renders disabled HTML attribute" do
      html = render_component(&H.render_disabled/1, %{})
      assert html =~ "disabled"
    end

    test "disabled=true has disabled:cursor-not-allowed class" do
      html = render_component(&H.render_disabled/1, %{})
      assert html =~ "disabled:cursor-not-allowed"
    end

    test "disabled=false does not render disabled HTML attribute" do
      html = render_component(&H.render_unchecked/1, %{})
      refute html =~ ~s( disabled ")
      refute html =~ ~s( disabled>)
    end
  end

  # ---------------------------------------------------------------------------
  # checkbox/1 — Tailwind classes
  # ---------------------------------------------------------------------------

  describe "checkbox/1 Tailwind classes" do
    test "has h-4 w-4 classes" do
      html = render_component(&H.render_unchecked/1, %{})
      assert html =~ "h-4"
      assert html =~ "w-4"
    end

    test "has rounded-sm class" do
      html = render_component(&H.render_unchecked/1, %{})
      assert html =~ "rounded-sm"
    end

    test "has border border-primary classes" do
      html = render_component(&H.render_unchecked/1, %{})
      assert html =~ "border-primary"
    end

    test "has focus-visible:ring-2 class" do
      html = render_component(&H.render_unchecked/1, %{})
      assert html =~ "focus-visible:ring-2"
    end

    test "has accent-primary class" do
      html = render_component(&H.render_unchecked/1, %{})
      assert html =~ "accent-primary"
    end
  end

  # ---------------------------------------------------------------------------
  # checkbox/1 — class override
  # ---------------------------------------------------------------------------

  describe "checkbox/1 class override" do
    test "accepts additional custom class" do
      html = render_component(&H.render_with_class/1, %{class: "my-extra-class"})
      assert html =~ "my-extra-class"
    end
  end

  # ---------------------------------------------------------------------------
  # checkbox/1 — phx-change passthrough
  # ---------------------------------------------------------------------------

  describe "checkbox/1 phx-change" do
    test "passes phx-change to input element" do
      html = render_component(&H.render_with_phx_change/1, %{})
      assert html =~ ~s(phx-change="toggle")
    end
  end

  # ---------------------------------------------------------------------------
  # form_checkbox/1 — basic rendering
  # ---------------------------------------------------------------------------

  describe "form_checkbox/1 basic rendering" do
    test "renders input element" do
      html = render_component(&H.render_form_checkbox/1, %{field: make_field()})
      assert html =~ "<input"
    end

    test "renders type=checkbox" do
      html = render_component(&H.render_form_checkbox/1, %{field: make_field()})
      assert html =~ ~s(type="checkbox")
    end

    test "uses field id from FormField" do
      html = render_component(&H.render_form_checkbox/1, %{field: make_field()})
      assert html =~ ~s(id="user_agreed")
    end

    test "uses field name from FormField" do
      html = render_component(&H.render_form_checkbox/1, %{field: make_field()})
      assert html =~ ~s(name="user[agreed]")
    end
  end

  # ---------------------------------------------------------------------------
  # form_checkbox/1 — label rendering
  # ---------------------------------------------------------------------------

  describe "form_checkbox/1 label" do
    test "renders label when label attr given" do
      html = render_component(&H.render_form_checkbox/1, %{field: make_field(), label: "I agree"})
      assert html =~ "<label"
      assert html =~ "I agree"
    end

    test "label has for attribute matching field id" do
      html = render_component(&H.render_form_checkbox/1, %{field: make_field(), label: "I agree"})
      assert html =~ ~s(for="user_agreed")
    end

    test "does not render label when label is nil" do
      html = render_component(&H.render_form_checkbox/1, %{field: make_field()})
      refute html =~ "<label"
    end
  end

  # ---------------------------------------------------------------------------
  # form_checkbox/1 — checked state from FormField
  # ---------------------------------------------------------------------------

  describe "form_checkbox/1 checked state" do
    test "checked when field value is true" do
      html = render_component(&H.render_form_checkbox/1, %{field: make_field("true")})
      assert html =~ ~s(data-state="checked")
    end

    test "unchecked when field value is empty string" do
      html = render_component(&H.render_form_checkbox/1, %{field: make_field("")})
      assert html =~ ~s(data-state="unchecked")
    end
  end

  # ---------------------------------------------------------------------------
  # form_checkbox/1 — disabled state
  # ---------------------------------------------------------------------------

  describe "form_checkbox/1 disabled state" do
    test "disabled=true sets pointer-events-none on wrapper" do
      html = render_component(&H.render_form_checkbox_disabled/1, %{field: make_field()})
      assert html =~ "pointer-events-none"
    end

    test "disabled=true sets opacity-50 on wrapper" do
      html = render_component(&H.render_form_checkbox_disabled/1, %{field: make_field()})
      assert html =~ "opacity-50"
    end
  end

  # ---------------------------------------------------------------------------
  # form_checkbox/1 — errors
  # ---------------------------------------------------------------------------

  describe "form_checkbox/1 errors" do
    test "renders error message from field.errors" do
      field = make_field("", [{"must be accepted", [validation: :acceptance]}])
      html = render_component(&H.render_form_checkbox/1, %{field: field})
      assert html =~ "must be accepted"
    end

    test "error paragraph has text-destructive class" do
      field = make_field("", [{"must be accepted", []}])
      html = render_component(&H.render_form_checkbox/1, %{field: field})
      assert html =~ "text-destructive"
    end

    test "sets aria-invalid=true when field has errors" do
      field = make_field("", [{"must be accepted", []}])
      html = render_component(&H.render_form_checkbox/1, %{field: field})
      assert html =~ ~s(aria-invalid="true")
    end

    test "no error paragraph when no errors" do
      html = render_component(&H.render_form_checkbox/1, %{field: make_field()})
      refute html =~ "text-destructive"
    end

    test "no aria-invalid when no errors" do
      html = render_component(&H.render_form_checkbox/1, %{field: make_field()})
      refute html =~ "aria-invalid"
    end
  end
end
