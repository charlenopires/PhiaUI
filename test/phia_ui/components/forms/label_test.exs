defmodule PhiaUi.Components.LabelTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Label

    def render_label(assigns) do
      ~H"""
      <.label>Email</.label>
      """
    end

    def render_label_for(assigns) do
      ~H"""
      <.label for="email-input">Email</.label>
      """
    end

    def render_label_required(assigns) do
      ~H"""
      <.label required={true}>Password</.label>
      """
    end

    def render_label_not_required(assigns) do
      ~H"""
      <.label required={false}>Name</.label>
      """
    end

    def render_label_custom_class(assigns) do
      ~H"""
      <.label class="my-custom">Label</.label>
      """
    end

    def render_label_global_attr(assigns) do
      ~H"""
      <.label data-testid="my-label">Label</.label>
      """
    end
  end

  describe "label/1" do
    test "renders label element" do
      html = render_component(&H.render_label/1, %{})
      assert html =~ "<label"
    end

    test "renders inner_block content" do
      html = render_component(&H.render_label/1, %{})
      assert html =~ "Email"
    end

    test "has text-sm class" do
      html = render_component(&H.render_label/1, %{})
      assert html =~ "text-sm"
    end

    test "has font-medium class" do
      html = render_component(&H.render_label/1, %{})
      assert html =~ "font-medium"
    end

    test "has leading-none class" do
      html = render_component(&H.render_label/1, %{})
      assert html =~ "leading-none"
    end

    test "for attribute is set when provided" do
      html = render_component(&H.render_label_for/1, %{})
      assert html =~ ~s(for="email-input")
    end

    test "required=true renders asterisk span" do
      html = render_component(&H.render_label_required/1, %{})
      assert html =~ "<span"
      assert html =~ "*"
    end

    test "required asterisk has aria-hidden=true" do
      html = render_component(&H.render_label_required/1, %{})
      assert html =~ ~s(aria-hidden="true")
    end

    test "required asterisk has text-destructive class" do
      html = render_component(&H.render_label_required/1, %{})
      assert html =~ "text-destructive"
    end

    test "required=false does not render asterisk" do
      html = render_component(&H.render_label_not_required/1, %{})
      refute html =~ "*"
    end

    test "no asterisk by default" do
      html = render_component(&H.render_label/1, %{})
      refute html =~ "*"
    end

    test "custom class is applied" do
      html = render_component(&H.render_label_custom_class/1, %{})
      assert html =~ "my-custom"
    end

    test "global attributes are forwarded" do
      html = render_component(&H.render_label_global_attr/1, %{})
      assert html =~ ~s(data-testid="my-label")
    end
  end
end
