defmodule PhiaUi.Components.FieldTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Field

    def render_full(assigns) do
      ~H"""
      <.field>
        <.field_label for="email" required={true}>Email</.field_label>
        <input id="email" type="email" />
        <.field_description>Enter your email address.</.field_description>
        <.field_message error="Invalid email" />
      </.field>
      """
    end

    def render_no_error(assigns) do
      ~H"""
      <.field>
        <.field_label for="name">Name</.field_label>
        <input id="name" type="text" />
        <.field_message error={nil} />
      </.field>
      """
    end

    def render_required_label(assigns) do
      ~H"""
      <.field>
        <.field_label for="phone" required={true}>Phone</.field_label>
      </.field>
      """
    end

    def render_not_required_label(assigns) do
      ~H"""
      <.field>
        <.field_label for="nickname">Nickname</.field_label>
      </.field>
      """
    end

    def render_with_custom_class(assigns) do
      ~H"""
      <.field class="my-custom-field">
        <input type="text" />
      </.field>
      """
    end

    def render_with_rest(assigns) do
      ~H"""
      <.field data-testid="my-field">
        <input type="text" />
      </.field>
      """
    end

    def render_label_with_rest(assigns) do
      ~H"""
      <.field>
        <.field_label for="user" data-testid="my-label">User</.field_label>
      </.field>
      """
    end

    def render_description_with_class(assigns) do
      ~H"""
      <.field>
        <.field_description class="extra-desc">Helper text.</.field_description>
      </.field>
      """
    end

    def render_message_with_class(assigns) do
      ~H"""
      <.field>
        <.field_message error="Some error" class="extra-error" />
      </.field>
      """
    end

    def render_checkbox_wrapper(assigns) do
      ~H"""
      <.field>
        <.field_label for="agree">Accept Terms</.field_label>
        <input id="agree" type="checkbox" />
        <.field_description>You must accept to continue.</.field_description>
        <.field_message error={nil} />
      </.field>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # field/1
  # ---------------------------------------------------------------------------

  describe "field/1" do
    test "renders wrapper with space-y-2" do
      html = render_component(&H.render_full/1, %{})
      assert html =~ "space-y-2"
    end

    test "renders inner_block content" do
      html = render_component(&H.render_full/1, %{})
      assert html =~ "email"
    end

    test "accepts custom class" do
      html = render_component(&H.render_with_custom_class/1, %{})
      assert html =~ "my-custom-field"
      assert html =~ "space-y-2"
    end

    test "forwards @rest attributes to root element" do
      html = render_component(&H.render_with_rest/1, %{})
      assert html =~ ~s(data-testid="my-field")
    end
  end

  # ---------------------------------------------------------------------------
  # field_label/1
  # ---------------------------------------------------------------------------

  describe "field_label/1" do
    test "renders label element" do
      html = render_component(&H.render_full/1, %{})
      assert html =~ "<label"
    end

    test "renders label with for attribute" do
      html = render_component(&H.render_full/1, %{})
      assert html =~ ~s(for="email")
    end

    test "renders label text" do
      html = render_component(&H.render_full/1, %{})
      assert html =~ "Email"
    end

    test "renders text-sm font-medium classes" do
      html = render_component(&H.render_full/1, %{})
      assert html =~ "text-sm"
      assert html =~ "font-medium"
    end

    test "renders leading-none class" do
      html = render_component(&H.render_full/1, %{})
      assert html =~ "leading-none"
    end

    test "shows asterisk when required=true" do
      html = render_component(&H.render_required_label/1, %{})
      assert html =~ "*"
    end

    test "asterisk has text-destructive class" do
      html = render_component(&H.render_required_label/1, %{})
      assert html =~ "text-destructive"
      assert html =~ "*"
    end

    test "asterisk has aria-hidden=true" do
      html = render_component(&H.render_required_label/1, %{})
      assert html =~ ~s(aria-hidden="true")
    end

    test "does not show asterisk when required is false (default)" do
      html = render_component(&H.render_not_required_label/1, %{})
      refute html =~ "*"
    end

    test "forwards @rest attributes to label element" do
      html = render_component(&H.render_label_with_rest/1, %{})
      assert html =~ ~s(data-testid="my-label")
    end
  end

  # ---------------------------------------------------------------------------
  # field_description/1
  # ---------------------------------------------------------------------------

  describe "field_description/1" do
    test "renders description text" do
      html = render_component(&H.render_full/1, %{})
      assert html =~ "Enter your email address."
    end

    test "renders text-muted-foreground class" do
      html = render_component(&H.render_full/1, %{})
      assert html =~ "text-muted-foreground"
    end

    test "renders text-sm class" do
      html = render_component(&H.render_full/1, %{})
      assert html =~ "text-sm"
    end

    test "accepts custom class" do
      html = render_component(&H.render_description_with_class/1, %{})
      assert html =~ "extra-desc"
      assert html =~ "text-muted-foreground"
    end
  end

  # ---------------------------------------------------------------------------
  # field_message/1
  # ---------------------------------------------------------------------------

  describe "field_message/1" do
    test "renders error message when error is set" do
      html = render_component(&H.render_full/1, %{})
      assert html =~ "Invalid email"
    end

    test "renders text-destructive class when error is set" do
      html = render_component(&H.render_full/1, %{})
      assert html =~ "text-destructive"
    end

    test "renders text-sm font-medium when error is set" do
      html = render_component(&H.render_full/1, %{})
      assert html =~ "text-sm"
      assert html =~ "font-medium"
    end

    test "does not render when error is nil" do
      html = render_component(&H.render_no_error/1, %{})
      refute html =~ "text-destructive"
    end

    test "does not render error paragraph when error is nil" do
      html = render_component(&H.render_no_error/1, %{})
      refute html =~ "Invalid"
    end

    test "accepts custom class" do
      html = render_component(&H.render_message_with_class/1, %{})
      assert html =~ "extra-error"
      assert html =~ "text-destructive"
    end
  end

  # ---------------------------------------------------------------------------
  # Composition: checkbox/radio/switch wrapper
  # ---------------------------------------------------------------------------

  describe "composition as wrapper for custom inputs" do
    test "renders inner_block slot content (e.g. checkbox input)" do
      html = render_component(&H.render_checkbox_wrapper/1, %{})

      assert html =~ ~s(for="agree")
      assert html =~ "Accept Terms"
      assert html =~ ~s(type="checkbox")
      assert html =~ "You must accept to continue."
    end
  end

  # ---------------------------------------------------------------------------
  # Function exports
  # ---------------------------------------------------------------------------

  describe "module exports" do
    test "field/1 is exported" do
      assert function_exported?(PhiaUi.Components.Field, :field, 1)
    end

    test "field_label/1 is exported" do
      assert function_exported?(PhiaUi.Components.Field, :field_label, 1)
    end

    test "field_description/1 is exported" do
      assert function_exported?(PhiaUi.Components.Field, :field_description, 1)
    end

    test "field_message/1 is exported" do
      assert function_exported?(PhiaUi.Components.Field, :field_message, 1)
    end
  end
end
