defmodule PhiaUi.Components.SplitButtonTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.SplitButton

    def render_default(assigns) do
      ~H"""
      <.split_button id="split-1">
        Save
        <:dropdown>
          <div data-split-item role="menuitem">Save as draft</div>
        </:dropdown>
      </.split_button>
      """
    end

    def render_variant(assigns) do
      ~H"""
      <.split_button id="split-2" variant={@variant}>
        Action
        <:dropdown>
          <div data-split-item role="menuitem">Item</div>
        </:dropdown>
      </.split_button>
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.split_button id="split-3" disabled={true}>
        Save
        <:dropdown>
          <div data-split-item role="menuitem">Item</div>
        </:dropdown>
      </.split_button>
      """
    end

    def render_loading(assigns) do
      ~H"""
      <.split_button id="split-4" loading={true}>
        Saving
        <:dropdown>
          <div data-split-item role="menuitem">Item</div>
        </:dropdown>
      </.split_button>
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.split_button id="split-5" class="my-custom">
        Save
        <:dropdown>
          <div data-split-item role="menuitem">Item</div>
        </:dropdown>
      </.split_button>
      """
    end
  end

  defp render_default, do: render_component(&H.render_default/1, %{})
  defp render_variant(v), do: render_component(&H.render_variant/1, %{variant: v})
  defp render_disabled, do: render_component(&H.render_disabled/1, %{})
  defp render_loading, do: render_component(&H.render_loading/1, %{})
  defp render_with_class, do: render_component(&H.render_with_class/1, %{})

  describe "split_button/1" do
    test "renders wrapper div with id" do
      assert render_default() =~ ~s(id="split-1")
    end

    test "has phx-hook=\"PhiaSplitButton\"" do
      assert render_default() =~ ~s(phx-hook="PhiaSplitButton")
    end

    test "renders two buttons (primary + caret)" do
      html = render_default()
      assert html =~ "<button"
      assert html =~ "data-split-caret"
    end

    test "primary button renders inner_block content" do
      assert render_default() =~ "Save"
    end

    test "caret button has aria-expanded=\"false\" initially" do
      assert render_default() =~ ~s(aria-expanded="false")
    end

    test "caret button has aria-haspopup=\"true\"" do
      assert render_default() =~ ~s(aria-haspopup="true")
    end

    test "renders dropdown div with data-split-dropdown" do
      assert render_default() =~ "data-split-dropdown"
    end

    test "dropdown has role=\"menu\"" do
      assert render_default() =~ ~s(role="menu")
    end

    test "dropdown is hidden by default" do
      assert render_default() =~ ~r/data-split-dropdown[^>]*class="hidden/
    end

    test "dropdown renders slot content" do
      assert render_default() =~ "Save as draft"
    end

    test "dropdown items have data-split-item" do
      assert render_default() =~ "data-split-item"
    end

    test "default variant applies primary classes" do
      html = render_default()
      assert html =~ "bg-primary"
    end

    test "destructive variant applies destructive classes" do
      assert render_variant(:destructive) =~ "bg-destructive"
    end

    test "outline variant applies border classes" do
      assert render_variant(:outline) =~ "border"
    end

    test "secondary variant applies secondary classes" do
      assert render_variant(:secondary) =~ "bg-secondary"
    end

    test "disabled adds pointer-events-none and opacity-50" do
      html = render_disabled()
      assert html =~ "pointer-events-none"
      assert html =~ "opacity-50"
    end

    test "loading shows spinner SVG" do
      assert render_loading() =~ "animate-spin"
    end

    test "custom class applied to wrapper" do
      assert render_with_class() =~ "my-custom"
    end

    test "dropdown id is id + '-dropdown'" do
      assert render_default() =~ ~s(id="split-1-dropdown")
    end

    test "wrapper div has relative positioning class" do
      assert render_default() =~ "relative"
    end

    test "function is exported" do
      assert function_exported?(PhiaUi.Components.SplitButton, :split_button, 1)
    end
  end
end
