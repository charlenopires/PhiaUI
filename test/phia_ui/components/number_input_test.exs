defmodule PhiaUi.Components.NumberInputTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.NumberInput

    def render_basic(assigns) do
      ~H"""
      <.number_input name="quantity" value={5} />
      """
    end

    def render_with_min_max(assigns) do
      ~H"""
      <.number_input name="qty" value={10} min={0} max={100} />
      """
    end

    def render_with_step(assigns) do
      ~H"""
      <.number_input name="qty" value={0} step={5} />
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.number_input name="qty" value={0} disabled={true} />
      """
    end

    def render_readonly(assigns) do
      ~H"""
      <.number_input name="qty" value={42} readonly={true} />
      """
    end

    def render_with_prefix(assigns) do
      ~H"""
      <.number_input name="price" value={9.99} prefix="$" />
      """
    end

    def render_with_suffix(assigns) do
      ~H"""
      <.number_input name="weight" value={70} suffix="kg" />
      """
    end

    def render_with_prefix_and_suffix(assigns) do
      ~H"""
      <.number_input name="price" value={9.99} prefix="$" suffix="USD" />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.number_input name="qty" value={0} class="custom-class" />
      """
    end

    def render_with_placeholder(assigns) do
      ~H"""
      <.number_input name="qty" value={nil} placeholder="Enter amount" />
      """
    end

    def render_with_id(assigns) do
      ~H"""
      <.number_input id="my-number" name="qty" value={0} />
      """
    end

    def render_form_number_input(assigns) do
      ~H"""
      <.form_number_input field={@field} label="Quantity" />
      """
    end

    def render_form_no_label(assigns) do
      ~H"""
      <.form_number_input field={@field} />
      """
    end

    def render_form_with_prefix(assigns) do
      ~H"""
      <.form_number_input field={@field} label="Price" prefix="$" />
      """
    end

    def render_form_with_suffix(assigns) do
      ~H"""
      <.form_number_input field={@field} label="Weight" suffix="kg" />
      """
    end

    def render_form_disabled(assigns) do
      ~H"""
      <.form_number_input field={@field} label="Qty" disabled={true} />
      """
    end

    def render_form_with_class(assigns) do
      ~H"""
      <.form_number_input field={@field} label="Qty" class="my-class" />
      """
    end
  end

  defp make_field(opts \\ []) do
    errors = Keyword.get(opts, :errors, [])
    value = Keyword.get(opts, :value, "")

    form = Phoenix.HTML.FormData.to_form(%{"quantity" => value}, as: :order)
    field = form[:quantity]
    %{field | errors: errors}
  end

  # ---------------------------------------------------------------------------
  # number_input/1
  # ---------------------------------------------------------------------------

  describe "number_input/1" do
    test "renders input with type=number" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(type="number")
    end

    test "renders name attribute" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(name="quantity")
    end

    test "renders value attribute" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(value="5")
    end

    test "renders min attribute" do
      html = render_component(&H.render_with_min_max/1, %{})
      assert html =~ ~s(min="0")
    end

    test "renders max attribute" do
      html = render_component(&H.render_with_min_max/1, %{})
      assert html =~ ~s(max="100")
    end

    test "renders step attribute" do
      html = render_component(&H.render_with_step/1, %{})
      assert html =~ ~s(step="5")
    end

    test "renders decrement button with aria-label Decrease" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(aria-label="Decrease")
    end

    test "renders increment button with aria-label Increase" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(aria-label="Increase")
    end

    test "decrement button has type=button" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(type="button")
    end

    test "disabled attribute is rendered on input" do
      html = render_component(&H.render_disabled/1, %{})
      assert html =~ "disabled"
    end

    test "readonly attribute is rendered on input" do
      html = render_component(&H.render_readonly/1, %{})
      assert html =~ "readonly"
    end

    test "renders prefix span when prefix given" do
      html = render_component(&H.render_with_prefix/1, %{})
      assert html =~ "$"
      assert html =~ "text-muted-foreground"
    end

    test "renders suffix span when suffix given" do
      html = render_component(&H.render_with_suffix/1, %{})
      assert html =~ "kg"
    end

    test "custom class is applied to input" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "custom-class"
    end

    test "renders aria-valuemin, aria-valuemax, aria-valuenow" do
      html = render_component(&H.render_with_min_max/1, %{})
      assert html =~ ~s(aria-valuemin="0")
      assert html =~ ~s(aria-valuemax="100")
      assert html =~ ~s(aria-valuenow="10")
    end

    test "renders id attribute when given" do
      html = render_component(&H.render_with_id/1, %{})
      assert html =~ ~s(id="my-number")
    end
  end

  # ---------------------------------------------------------------------------
  # form_number_input/1
  # ---------------------------------------------------------------------------

  describe "form_number_input/1" do
    test "renders label when given" do
      field = make_field()
      html = render_component(&H.render_form_number_input/1, %{field: field})
      assert html =~ "Quantity"
      assert html =~ "<label"
    end

    test "renders input element" do
      field = make_field()
      html = render_component(&H.render_form_number_input/1, %{field: field})
      assert html =~ ~s(type="number")
    end

    test "label for attribute matches field id" do
      field = make_field()
      html = render_component(&H.render_form_number_input/1, %{field: field})
      assert html =~ ~s(for="order_quantity")
    end

    test "input name matches field name" do
      field = make_field()
      html = render_component(&H.render_form_number_input/1, %{field: field})
      assert html =~ ~s(name="order[quantity]")
    end

    test "input value matches field value" do
      field = make_field(value: 42)
      html = render_component(&H.render_form_number_input/1, %{field: field})
      assert html =~ ~s(value="42")
    end

    test "renders error messages from field errors" do
      field = make_field(errors: [{"must be greater than %{count}", [count: 0, validation: :number]}])
      html = render_component(&H.render_form_number_input/1, %{field: field})
      assert html =~ "must be greater than 0"
      assert html =~ "text-destructive"
    end

    test "does not render label when label not given" do
      field = make_field()
      html = render_component(&H.render_form_no_label/1, %{field: field})
      refute html =~ "<label"
    end

    test "renders prefix from props" do
      field = make_field()
      html = render_component(&H.render_form_with_prefix/1, %{field: field})
      assert html =~ "$"
    end

    test "renders suffix from props" do
      field = make_field()
      html = render_component(&H.render_form_with_suffix/1, %{field: field})
      assert html =~ "kg"
    end

    test "disabled propagates to input" do
      field = make_field()
      html = render_component(&H.render_form_disabled/1, %{field: field})
      assert html =~ "disabled"
    end

    test "custom class is applied" do
      field = make_field()
      html = render_component(&H.render_form_with_class/1, %{field: field})
      assert html =~ "my-class"
    end

    test "renders without errors when field has no errors" do
      field = make_field(errors: [])
      html = render_component(&H.render_form_number_input/1, %{field: field})
      refute html =~ "text-destructive"
    end
  end
end
