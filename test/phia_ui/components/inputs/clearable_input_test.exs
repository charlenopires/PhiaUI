defmodule PhiaUi.Components.ClearableInputTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ClearableInput

    def render_default(assigns) do
      ~H"""
      <.clearable_input name="filter" value={nil} />
      """
    end

    def render_with_value(assigns) do
      ~H"""
      <.clearable_input name="filter" value="something" on_clear="clear_filter" />
      """
    end

    def render_no_on_clear(assigns) do
      ~H"""
      <.clearable_input name="filter" value="something" />
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.clearable_input name="filter" value="hello" disabled={true} on_clear="clear" />
      """
    end

    def render_email(assigns) do
      ~H"""
      <.clearable_input name="email" value={nil} type="email" placeholder="you@example.com" />
      """
    end

    attr(:field, Phoenix.HTML.FormField)
    attr(:label, :string, default: nil)
    attr(:on_clear, :string, default: nil)

    def render_form(assigns) do
      ~H"""
      <.form_clearable_input field={@field} label={@label} on_clear={@on_clear} />
      """
    end
  end

  defp make_field(value \\ "", errors \\ []) do
    form = Phoenix.HTML.FormData.to_form(%{"name" => value}, as: :user)
    field = form[:name]
    %{field | errors: errors}
  end

  describe "clearable_input/1 rendering" do
    test "renders an input element" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<input"
    end

    test "renders with type text by default" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(type="text")
    end

    test "renders email type when specified" do
      html = render_component(&H.render_email/1, %{})
      assert html =~ ~s(type="email")
      assert html =~ "you@example.com"
    end

    test "renders clear button when value is present and on_clear is set" do
      html = render_component(&H.render_with_value/1, %{})
      assert html =~ "Clear input"
    end

    test "does not render clear button when value is nil" do
      html = render_component(&H.render_default/1, %{})
      refute html =~ "Clear input"
    end

    test "does not render clear button when on_clear is not set" do
      html = render_component(&H.render_no_on_clear/1, %{})
      refute html =~ "Clear input"
    end

    test "does not render clear button when disabled" do
      html = render_component(&H.render_disabled/1, %{})
      refute html =~ "Clear input"
    end

    test "has base input classes" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "rounded-md"
      assert html =~ "border-input"
    end
  end

  describe "form_clearable_input/1" do
    test "renders label" do
      html = render_component(&H.render_form/1, %{field: make_field(), label: "Username"})
      assert html =~ "Username"
      assert html =~ "<label"
    end

    test "renders error messages" do
      field = make_field("", [{"is required", []}])
      html = render_component(&H.render_form/1, %{field: field})
      assert html =~ "is required"
      assert html =~ "text-destructive"
    end

    test "adds border-destructive when errors present" do
      field = make_field("", [{"is invalid", []}])
      html = render_component(&H.render_form/1, %{field: field})
      assert html =~ "border-destructive"
    end

    test "uses field id, name, value" do
      html = render_component(&H.render_form/1, %{field: make_field("testval")})
      assert html =~ "testval"
      assert html =~ ~s(name="user[name]")
    end
  end
end
