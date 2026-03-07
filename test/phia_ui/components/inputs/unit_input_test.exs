defmodule PhiaUi.Components.UnitInputTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.UnitInput

    def render_currency(assigns) do
      ~H"""
      <.unit_input name="price" value="9.99" unit="currency_usd" />
      """
    end

    def render_percent(assigns) do
      ~H"""
      <.unit_input name="discount" value="15" unit="percent" />
      """
    end

    def render_kg(assigns) do
      ~H"""
      <.unit_input name="weight" value="75" unit="kg" />
      """
    end

    def render_custom(assigns) do
      ~H"""
      <.unit_input name="temp" value="36.6" unit="custom" symbol="°C" symbol_position="right" />
      """
    end

    def render_custom_left(assigns) do
      ~H"""
      <.unit_input name="rate" value="4.5" unit="custom" symbol="★" symbol_position="left" />
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.unit_input name="qty" value="10" unit="kg" disabled={true} />
      """
    end

    attr(:field, Phoenix.HTML.FormField)
    attr(:label, :string, default: nil)
    attr(:unit, :string, default: "custom")

    def render_form(assigns) do
      ~H"""
      <.form_unit_input field={@field} label={@label} unit={@unit} symbol="$" symbol_position="left" />
      """
    end
  end

  defp make_field(value \\ "", errors \\ []) do
    form = Phoenix.HTML.FormData.to_form(%{"price" => value}, as: :product)
    field = form[:price]
    %{field | errors: errors}
  end

  describe "unit_input/1 rendering" do
    test "renders number input" do
      html = render_component(&H.render_currency/1, %{})
      assert html =~ ~s(type="number")
    end

    test "renders USD prefix symbol" do
      html = render_component(&H.render_currency/1, %{})
      assert html =~ "$"
    end

    test "renders percent suffix symbol" do
      html = render_component(&H.render_percent/1, %{})
      assert html =~ "%"
    end

    test "renders kg suffix" do
      html = render_component(&H.render_kg/1, %{})
      assert html =~ "kg"
    end

    test "renders custom right suffix" do
      html = render_component(&H.render_custom/1, %{})
      assert html =~ "°C"
    end

    test "renders custom left prefix" do
      html = render_component(&H.render_custom_left/1, %{})
      assert html =~ "★"
    end

    test "renders the value" do
      html = render_component(&H.render_currency/1, %{})
      assert html =~ "9.99"
    end

    test "applies disabled styling when disabled" do
      html = render_component(&H.render_disabled/1, %{})
      assert html =~ "opacity-50"
    end

    test "has border-input and rounded-md" do
      html = render_component(&H.render_currency/1, %{})
      assert html =~ "border-input"
      assert html =~ "rounded-md"
    end
  end

  describe "form_unit_input/1" do
    test "renders label" do
      html = render_component(&H.render_form/1, %{field: make_field(), label: "Price", unit: "custom"})
      assert html =~ "Price"
    end

    test "renders errors" do
      field = make_field("", [{"must be positive", []}])
      html = render_component(&H.render_form/1, %{field: field, unit: "custom"})
      assert html =~ "must be positive"
      assert html =~ "text-destructive"
    end
  end
end
