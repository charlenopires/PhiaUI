defmodule PhiaUi.Components.PasswordInputTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helpers — render wrappers in a dedicated Phoenix.Component module
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.PasswordInput

    def render_basic(assigns) do
      ~H"""
      <.password_input id="pwd1" name="password" />
      """
    end

    def render_with_value(assigns) do
      ~H"""
      <.password_input id="pwd2" name="password" value="secret123" />
      """
    end

    def render_with_placeholder(assigns) do
      ~H"""
      <.password_input id="pwd3" name="password" placeholder="Enter password" />
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.password_input id="pwd4" name="password" disabled={true} />
      """
    end

    def render_required(assigns) do
      ~H"""
      <.password_input id="pwd5" name="password" required={true} />
      """
    end

    attr(:autocomplete, :string, default: "current-password")

    def render_with_autocomplete(assigns) do
      ~H"""
      <.password_input id="pwd6" name="password" autocomplete={@autocomplete} />
      """
    end

    attr(:class, :string, default: nil)

    def render_with_class(assigns) do
      ~H"""
      <.password_input id="pwd7" name="password" class={@class} />
      """
    end

    attr(:field, Phoenix.HTML.FormField)
    attr(:label, :string, default: nil)
    attr(:class, :string, default: nil)

    def render_form_password(assigns) do
      ~H"""
      <.form_password_input field={@field} label={@label} class={@class} />
      """
    end

    attr(:field, Phoenix.HTML.FormField)

    def render_form_password_disabled(assigns) do
      ~H"""
      <.form_password_input field={@field} disabled={true} />
      """
    end

    attr(:field, Phoenix.HTML.FormField)

    def render_form_password_no_label(assigns) do
      ~H"""
      <.form_password_input field={@field} />
      """
    end
  end

  defp make_field(value \\ "", errors \\ []) do
    form = Phoenix.HTML.FormData.to_form(%{"password" => value}, as: :user)
    field = form[:password]
    %{field | errors: errors}
  end

  # ---------------------------------------------------------------------------
  # password_input/1
  # ---------------------------------------------------------------------------

  describe "password_input/1" do
    test "renders input with type=password" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(type="password")
    end

    test "renders toggle button" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ "<button"
      assert html =~ ~s(type="button")
    end

    test "toggle button has aria-label Show password" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(aria-label="Show password")
    end

    test "renders name attribute" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(name="password")
    end

    test "renders value attribute" do
      html = render_component(&H.render_with_value/1, %{})
      assert html =~ ~s(value="secret123")
    end

    test "renders placeholder attribute" do
      html = render_component(&H.render_with_placeholder/1, %{})
      assert html =~ ~s(placeholder="Enter password")
    end

    test "disabled attr disables the input" do
      html = render_component(&H.render_disabled/1, %{})
      assert html =~ ~s(<input) and html =~ "disabled"
    end

    test "disabled attr disables the toggle button" do
      html = render_component(&H.render_disabled/1, %{})
      assert html =~ "<button"
      assert html =~ "disabled"
    end

    test "autocomplete defaults to current-password" do
      html = render_component(&H.render_basic/1, %{})
      assert html =~ ~s(autocomplete="current-password")
    end

    test "autocomplete can be customized" do
      html = render_component(&H.render_with_autocomplete/1, %{autocomplete: "new-password"})
      assert html =~ ~s(autocomplete="new-password")
    end

    test "custom class is applied" do
      html = render_component(&H.render_with_class/1, %{class: "my-custom-class"})
      assert html =~ "my-custom-class"
    end

    test "renders with required attribute" do
      html = render_component(&H.render_required/1, %{})
      assert html =~ "required"
    end
  end

  # ---------------------------------------------------------------------------
  # form_password_input/1
  # ---------------------------------------------------------------------------

  describe "form_password_input/1" do
    test "renders label when label attr is given" do
      html =
        render_component(&H.render_form_password/1, %{field: make_field(), label: "Password"})

      assert html =~ "<label"
      assert html =~ "Password"
    end

    test "uses field.id for input id" do
      html = render_component(&H.render_form_password/1, %{field: make_field()})
      assert html =~ ~s(id="user_password")
    end

    test "uses field.name for input name" do
      html = render_component(&H.render_form_password/1, %{field: make_field()})
      assert html =~ ~s(name="user[password]")
    end

    test "uses field.value for input value" do
      html = render_component(&H.render_form_password/1, %{field: make_field("mypassword")})
      assert html =~ ~s(value="mypassword")
    end

    test "renders errors from field" do
      errors = [{"can't be blank", [validation: :required]}]
      html = render_component(&H.render_form_password/1, %{field: make_field("", errors)})
      assert html =~ "can&#39;t be blank"
    end

    test "does not render label when label is not given" do
      html = render_component(&H.render_form_password_no_label/1, %{field: make_field()})
      refute html =~ "<label"
    end

    test "custom class is applied" do
      html =
        render_component(&H.render_form_password/1, %{
          field: make_field(),
          class: "form-extra-class"
        })

      assert html =~ "form-extra-class"
    end

    test "disabled propagates to input" do
      html = render_component(&H.render_form_password_disabled/1, %{field: make_field()})
      assert html =~ "disabled"
    end
  end
end
