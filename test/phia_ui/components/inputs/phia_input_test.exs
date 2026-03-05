defmodule PhiaUi.Components.PhiaInputTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  @valid_field %Phoenix.HTML.FormField{
    id: "user_email",
    name: "user[email]",
    value: "test@example.com",
    errors: [],
    field: :email,
    form: nil
  }

  @error_field %Phoenix.HTML.FormField{
    id: "user_name",
    name: "user[name]",
    value: "",
    errors: [
      {"can't be blank", [validation: :required]},
      {"should be at least %{count} character(s)", [count: 2, validation: :length]}
    ],
    field: :name,
    form: nil
  }

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.PhiaInput

    def render_input(assigns) do
      ~H"""
      <.phia_input field={@field} />
      """
    end

    def render_input_with_label(assigns) do
      ~H"""
      <.phia_input field={@field} label="Email address" />
      """
    end

    def render_input_with_description(assigns) do
      ~H"""
      <.phia_input field={@field} label="Email" description="We'll never share your email" />
      """
    end

    def render_input_type_email(assigns) do
      ~H"""
      <.phia_input field={@field} type="email" />
      """
    end

    def render_input_type_password(assigns) do
      ~H"""
      <.phia_input field={@field} type="password" />
      """
    end

    def render_input_with_errors(assigns) do
      ~H"""
      <.phia_input field={@field} />
      """
    end

    def render_input_custom_class(assigns) do
      ~H"""
      <.phia_input field={@field} class="font-mono" />
      """
    end

    def render_input_with_debounce(assigns) do
      ~H"""
      <.phia_input field={@field} phx-debounce="blur" />
      """
    end

    def render_input_with_placeholder(assigns) do
      ~H"""
      <.phia_input field={@field} placeholder="Enter email" />
      """
    end
  end

  describe "phia_input/1" do
    test "renders a wrapper div" do
      html = render_component(&H.render_input/1, %{field: @valid_field})
      assert html =~ "<div"
    end

    test "renders input element" do
      html = render_component(&H.render_input/1, %{field: @valid_field})
      assert html =~ "<input"
    end

    test "input has correct id from field" do
      html = render_component(&H.render_input/1, %{field: @valid_field})
      assert html =~ ~s(id="user_email")
    end

    test "input has correct name from field" do
      html = render_component(&H.render_input/1, %{field: @valid_field})
      assert html =~ ~s(name="user[email]")
    end

    test "input has correct value from field" do
      html = render_component(&H.render_input/1, %{field: @valid_field})
      assert html =~ "test@example.com"
    end

    test "default type is text" do
      html = render_component(&H.render_input/1, %{field: @valid_field})
      assert html =~ ~s(type="text")
    end

    test "type=email sets email type" do
      html = render_component(&H.render_input_type_email/1, %{field: @valid_field})
      assert html =~ ~s(type="email")
    end

    test "type=password sets password type" do
      html = render_component(&H.render_input_type_password/1, %{field: @valid_field})
      assert html =~ ~s(type="password")
    end

    test "renders label with for attribute when label provided" do
      html = render_component(&H.render_input_with_label/1, %{field: @valid_field})
      assert html =~ "<label"
      assert html =~ ~s(for="user_email")
      assert html =~ "Email address"
    end

    test "no label when label is nil" do
      html = render_component(&H.render_input/1, %{field: @valid_field})
      refute html =~ "<label"
    end

    test "renders description when provided" do
      html = render_component(&H.render_input_with_description/1, %{field: @valid_field})
      assert html =~ "We&#39;ll never share your email" or html =~ "We'll never share your email"
    end

    test "description has text-muted-foreground class" do
      html = render_component(&H.render_input_with_description/1, %{field: @valid_field})
      assert html =~ "text-muted-foreground"
    end

    test "input has focus-visible:ring-2 class" do
      html = render_component(&H.render_input/1, %{field: @valid_field})
      assert html =~ "focus-visible:ring-2" or html =~ "ring-2"
    end

    test "input has border-destructive when field has errors" do
      html = render_component(&H.render_input_with_errors/1, %{field: @error_field})
      assert html =~ "border-destructive"
    end

    test "renders error messages when field has errors" do
      html = render_component(&H.render_input_with_errors/1, %{field: @error_field})
      assert html =~ "can&#39;t be blank" or html =~ "can't be blank"
    end

    test "error messages interpolate %{count} placeholder" do
      html = render_component(&H.render_input_with_errors/1, %{field: @error_field})
      assert html =~ "2"
    end

    test "error message has text-destructive class" do
      html = render_component(&H.render_input_with_errors/1, %{field: @error_field})
      assert html =~ "text-destructive"
    end

    test "no error message when field is valid" do
      html = render_component(&H.render_input/1, %{field: @valid_field})
      refute html =~ "text-destructive"
    end

    test "custom class is applied to input" do
      html = render_component(&H.render_input_custom_class/1, %{field: @valid_field})
      assert html =~ "font-mono"
    end

    test "phx-debounce is forwarded" do
      html = render_component(&H.render_input_with_debounce/1, %{field: @valid_field})
      assert html =~ "phx-debounce"
    end

    test "placeholder is forwarded" do
      html = render_component(&H.render_input_with_placeholder/1, %{field: @valid_field})
      assert html =~ "Enter email"
    end
  end
end
