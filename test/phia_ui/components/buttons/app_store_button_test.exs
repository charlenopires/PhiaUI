defmodule PhiaUi.Components.AppStoreButtonTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.AppStoreButton

    def render_apple(assigns) do
      ~H"""
      <.app_store_button store={:apple} />
      """
    end

    def render_google(assigns) do
      ~H"""
      <.app_store_button store={:google} />
      """
    end

    def render_default_variant(assigns) do
      ~H"""
      <.app_store_button store={:apple} variant={:default} />
      """
    end

    def render_outline_variant(assigns) do
      ~H"""
      <.app_store_button store={:apple} variant={:outline} />
      """
    end

    def render_with_href(assigns) do
      ~H"""
      <.app_store_button store={:apple} href={@href} />
      """
    end

    def render_sm(assigns) do
      ~H"""
      <.app_store_button store={:apple} size={:sm} />
      """
    end

    def render_lg(assigns) do
      ~H"""
      <.app_store_button store={:apple} size={:lg} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.app_store_button store={:apple} class={@class} />
      """
    end
  end

  defp render_apple, do: render_component(&H.render_apple/1, %{})
  defp render_google, do: render_component(&H.render_google/1, %{})
  defp render_default_variant, do: render_component(&H.render_default_variant/1, %{})
  defp render_outline_variant, do: render_component(&H.render_outline_variant/1, %{})
  defp render_with_href(href), do: render_component(&H.render_with_href/1, %{href: href})
  defp render_sm, do: render_component(&H.render_sm/1, %{})
  defp render_lg, do: render_component(&H.render_lg/1, %{})
  defp render_custom_class(class), do: render_component(&H.render_custom_class/1, %{class: class})

  describe "app_store_button/1" do
    test "apple store renders App Store label" do
      assert render_apple() =~ "App Store"
    end

    test "apple store renders Download on the subtext" do
      assert render_apple() =~ "Download on the"
    end

    test "google store renders Google Play label" do
      assert render_google() =~ "Google Play"
    end

    test "google store renders Get it on subtext" do
      assert render_google() =~ "Get it on"
    end

    test "default variant renders bg-foreground" do
      assert render_default_variant() =~ "bg-foreground"
    end

    test "outline variant renders border" do
      assert render_outline_variant() =~ "border"
    end

    test "renders href attribute" do
      html = render_with_href("https://apps.apple.com/app/123")
      assert html =~ "https://apps.apple.com/app/123"
    end

    test "renders target _blank" do
      assert render_apple() =~ "target=\"_blank\""
    end

    test "size sm renders h-10" do
      assert render_sm() =~ "h-10"
    end

    test "size lg renders h-14" do
      assert render_lg() =~ "h-14"
    end

    test "custom class is merged" do
      assert render_custom_class("my-custom-class") =~ "my-custom-class"
    end

    test "renders SVG icon" do
      assert render_apple() =~ "<svg"
      assert render_apple() =~ "<path"
    end

    test "renders anchor element with role button" do
      html = render_apple()
      assert html =~ "<a"
      assert html =~ "role=\"button\""
    end

    test "function is exported" do
      assert function_exported?(PhiaUi.Components.AppStoreButton, :app_store_button, 1)
    end
  end
end
