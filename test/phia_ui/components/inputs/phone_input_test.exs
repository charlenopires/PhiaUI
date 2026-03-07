defmodule PhiaUi.Components.PhoneInputTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.PhoneInput

    def render_default(assigns) do
      ~H"""
      <.phone_input name="phone" value="5551234567" />
      """
    end

    def render_uk(assigns) do
      ~H"""
      <.phone_input name="phone" value="07700900000" selected_code="+44" />
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.phone_input name="phone" value={nil} disabled={true} />
      """
    end

    attr(:field, Phoenix.HTML.FormField)
    attr(:label, :string, default: nil)

    def render_form(assigns) do
      ~H"""
      <.form_phone_input field={@field} label={@label} />
      """
    end
  end

  defp make_field(value \\ "", errors \\ []) do
    form = Phoenix.HTML.FormData.to_form(%{"phone" => value}, as: :user)
    field = form[:phone]
    %{field | errors: errors}
  end

  describe "phone_input/1 rendering" do
    test "renders an input element" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<input"
    end

    test "renders input type tel" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(type="tel")
    end

    test "renders country code select" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<select"
    end

    test "renders US flag and +1 by default" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "+1"
      assert html =~ "🇺🇸"
    end

    test "selects UK code when selected_code is +44" do
      html = render_component(&H.render_uk/1, %{})
      assert html =~ "+44"
      assert html =~ "🇬🇧"
    end

    test "renders phone value in input" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "5551234567"
    end

    test "applies disabled styling when disabled" do
      html = render_component(&H.render_disabled/1, %{})
      assert html =~ "opacity-50"
    end

    test "includes common country codes" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "🇧🇷"
      assert html =~ "+55"
      assert html =~ "🇩🇪"
      assert html =~ "+49"
    end
  end

  describe "form_phone_input/1" do
    test "renders label" do
      html = render_component(&H.render_form/1, %{field: make_field(), label: "Phone"})
      assert html =~ "Phone"
      assert html =~ "<label"
    end

    test "renders error messages" do
      field = make_field("", [{"is invalid", []}])
      html = render_component(&H.render_form/1, %{field: field})
      assert html =~ "is invalid"
      assert html =~ "text-destructive"
    end

    test "renders field value" do
      html = render_component(&H.render_form/1, %{field: make_field("1234")})
      assert html =~ "1234"
    end
  end
end
