defmodule PhiaUi.Components.FormFieldTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  @valid_field %Phoenix.HTML.FormField{
    id: "user_email",
    name: "user[email]",
    value: "",
    errors: [],
    field: :email,
    form: nil
  }

  @error_field %Phoenix.HTML.FormField{
    id: "user_name",
    name: "user[name]",
    value: "",
    errors: [{"can't be blank", [validation: :required]}],
    field: :name,
    form: nil
  }

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.FormField

    def render_form_field(assigns) do
      ~H"""
      <.form_field field={@field}>
        <input id={@field.id} name={@field.name} type="text" />
      </.form_field>
      """
    end

    def render_form_field_with_label(assigns) do
      ~H"""
      <.form_field field={@field} label="Email">
        <input id={@field.id} name={@field.name} type="text" />
      </.form_field>
      """
    end

    def render_form_field_with_description(assigns) do
      ~H"""
      <.form_field field={@field} label="Email" description="Enter your email address">
        <input id={@field.id} name={@field.name} type="text" />
      </.form_field>
      """
    end

    def render_form_field_with_errors(assigns) do
      ~H"""
      <.form_field field={@field}>
        <input id={@field.id} name={@field.name} type="text" />
      </.form_field>
      """
    end

    def render_form_field_custom_class(assigns) do
      ~H"""
      <.form_field field={@field} class="my-custom">
        <input id={@field.id} name={@field.name} type="text" />
      </.form_field>
      """
    end
  end

  describe "form_field/1" do
    test "renders a wrapper div" do
      html = render_component(&H.render_form_field/1, %{field: @valid_field})
      assert html =~ "<div"
    end

    test "has space-y-2 class" do
      html = render_component(&H.render_form_field/1, %{field: @valid_field})
      assert html =~ "space-y-2"
    end

    test "renders inner_block slot" do
      html = render_component(&H.render_form_field/1, %{field: @valid_field})
      assert html =~ ~s(id="user_email")
    end

    test "renders label with for attribute when label provided" do
      html = render_component(&H.render_form_field_with_label/1, %{field: @valid_field})
      assert html =~ "<label"
      assert html =~ ~s(for="user_email")
      assert html =~ "Email"
    end

    test "no label element when label is nil" do
      html = render_component(&H.render_form_field/1, %{field: @valid_field})
      refute html =~ "<label"
    end

    test "renders description when provided" do
      html = render_component(&H.render_form_field_with_description/1, %{field: @valid_field})
      assert html =~ "Enter your email address"
    end

    test "description has text-muted-foreground class" do
      html = render_component(&H.render_form_field_with_description/1, %{field: @valid_field})
      assert html =~ "text-muted-foreground"
    end

    test "no description when not provided" do
      html = render_component(&H.render_form_field/1, %{field: @valid_field})
      refute html =~ "text-muted-foreground"
    end

    test "renders error messages when field has errors" do
      html = render_component(&H.render_form_field_with_errors/1, %{field: @error_field})
      assert html =~ "can&#39;t be blank" or html =~ "can't be blank"
    end

    test "error message has text-destructive class" do
      html = render_component(&H.render_form_field_with_errors/1, %{field: @error_field})
      assert html =~ "text-destructive"
    end

    test "no error message when field is valid" do
      html = render_component(&H.render_form_field/1, %{field: @valid_field})
      refute html =~ "text-destructive"
    end

    test "accepts custom class" do
      html =
        render_component(&H.render_form_field_custom_class/1, %{
          field: @valid_field,
          class: "my-custom"
        })

      assert html =~ "my-custom"
    end
  end
end
