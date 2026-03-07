defmodule PhiaUi.Components.IconButtonTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.IconButton

    def render_default(assigns) do
      ~H"""
      <.icon_button icon="x" label="Close" />
      """
    end

    def render_no_tooltip(assigns) do
      ~H"""
      <.icon_button icon="x" label="Close" tooltip={false} />
      """
    end

    def render_variant(assigns) do
      ~H"""
      <.icon_button icon="trash-2" label="Delete" variant={@variant} />
      """
    end

    def render_size(assigns) do
      ~H"""
      <.icon_button icon="plus" label="Add" size={@size} />
      """
    end

    def render_circle(assigns) do
      ~H"""
      <.icon_button icon="plus" label="Add" shape={:circle} />
      """
    end

    def render_loading(assigns) do
      ~H"""
      <.icon_button icon="refresh-cw" label="Refresh" loading={true} />
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.icon_button icon="x" label="Close" disabled={true} />
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.icon_button icon="x" label="Close" class="my-icon-btn" />
      """
    end
  end

  defp render_default, do: render_component(&H.render_default/1, %{})
  defp render_no_tooltip, do: render_component(&H.render_no_tooltip/1, %{})
  defp render_variant(v), do: render_component(&H.render_variant/1, %{variant: v})
  defp render_size(s), do: render_component(&H.render_size/1, %{size: s})
  defp render_circle, do: render_component(&H.render_circle/1, %{})
  defp render_loading, do: render_component(&H.render_loading/1, %{})
  defp render_disabled, do: render_component(&H.render_disabled/1, %{})
  defp render_with_class, do: render_component(&H.render_with_class/1, %{})

  describe "icon_button/1" do
    test "renders a button element" do
      assert render_default() =~ "<button"
    end

    test "button has correct aria-label" do
      assert render_default() =~ ~s(aria-label="Close")
    end

    test "renders tooltip span by default" do
      html = render_default()
      assert html =~ ~s(role="tooltip")
      assert html =~ "Close"
    end

    test "no tooltip span when tooltip={false}" do
      refute render_no_tooltip() =~ ~s(role="tooltip")
    end

    test "tooltip text matches label" do
      assert render_default() =~ "Close"
    end

    test "ghost variant (default) has hover:bg-accent" do
      assert render_default() =~ "hover:bg-accent"
    end

    test "default variant applies primary bg" do
      assert render_variant(:default) =~ "bg-primary"
    end

    test "destructive variant applies destructive bg" do
      assert render_variant(:destructive) =~ "bg-destructive"
    end

    test "outline variant applies border" do
      assert render_variant(:outline) =~ "border"
    end

    test "secondary variant applies secondary bg" do
      assert render_variant(:secondary) =~ "bg-secondary"
    end

    test ":xs size applies h-6 w-6" do
      assert render_size(:xs) =~ "h-6 w-6"
    end

    test ":sm size applies h-8 w-8" do
      assert render_size(:sm) =~ "h-8 w-8"
    end

    test ":default size applies h-9 w-9" do
      assert render_size(:default) =~ "h-9 w-9"
    end

    test ":lg size applies h-11 w-11" do
      assert render_size(:lg) =~ "h-11 w-11"
    end

    test "circle shape applies rounded-full" do
      assert render_circle() =~ "rounded-full"
    end

    test "square shape (default) applies rounded-md" do
      assert render_default() =~ "rounded-md"
    end

    test "loading shows spinner SVG" do
      assert render_loading() =~ "animate-spin"
    end

    test "loading sets aria-busy" do
      assert render_loading() =~ ~s(aria-busy="true")
    end

    test "disabled adds opacity-50" do
      assert render_disabled() =~ "opacity-50"
    end

    test "custom class applied to button" do
      assert render_with_class() =~ "my-icon-btn"
    end

    test "focus-visible ring classes present" do
      assert render_default() =~ "focus-visible:ring-2"
    end

    test "function is exported" do
      assert function_exported?(PhiaUi.Components.IconButton, :icon_button, 1)
    end
  end
end
