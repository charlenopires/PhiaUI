defmodule PhiaUi.Components.SocialButtonTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.SocialButton

    def render_google(assigns) do
      ~H"""
      <.social_button provider={:google} />
      """
    end

    def render_github(assigns) do
      ~H"""
      <.social_button provider={:github} />
      """
    end

    def render_discord(assigns) do
      ~H"""
      <.social_button provider={:discord} />
      """
    end

    def render_custom_label(assigns) do
      ~H"""
      <.social_button provider={:github} label={@label} />
      """
    end

    def render_icon_only(assigns) do
      ~H"""
      <.social_button provider={:github} icon_only={true} />
      """
    end

    def render_outline(assigns) do
      ~H"""
      <.social_button provider={:github} variant={:outline} />
      """
    end

    def render_ghost(assigns) do
      ~H"""
      <.social_button provider={:github} variant={:ghost} />
      """
    end

    def render_loading(assigns) do
      ~H"""
      <.social_button provider={:google} loading={true} />
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.social_button provider={:google} disabled={true} />
      """
    end

    def render_group(assigns) do
      ~H"""
      <.social_button_group>
        <.social_button provider={:github} />
        <.social_button provider={:google} />
      </.social_button_group>
      """
    end

    def render_group_horizontal(assigns) do
      ~H"""
      <.social_button_group orientation={:horizontal}>
        <.social_button provider={:github} />
      </.social_button_group>
      """
    end
  end

  defp render_google, do: render_component(&H.render_google/1, %{})
  defp render_github, do: render_component(&H.render_github/1, %{})
  defp render_discord, do: render_component(&H.render_discord/1, %{})
  defp render_custom_label(l), do: render_component(&H.render_custom_label/1, %{label: l})
  defp render_icon_only, do: render_component(&H.render_icon_only/1, %{})
  defp render_outline, do: render_component(&H.render_outline/1, %{})
  defp render_ghost, do: render_component(&H.render_ghost/1, %{})
  defp render_loading, do: render_component(&H.render_loading/1, %{})
  defp render_disabled, do: render_component(&H.render_disabled/1, %{})
  defp render_group, do: render_component(&H.render_group/1, %{})
  defp render_group_horizontal, do: render_component(&H.render_group_horizontal/1, %{})

  describe "social_button/1" do
    test "renders button element" do
      assert render_google() =~ "<button"
    end

    test "google renders default label" do
      assert render_google() =~ "Sign in with Google"
    end

    test "github renders default label" do
      assert render_github() =~ "Sign in with GitHub"
    end

    test "discord renders default label" do
      assert render_discord() =~ "Sign in with Discord"
    end

    test "custom label overrides default" do
      assert render_custom_label("Continue with GitHub") =~ "Continue with GitHub"
    end

    test "branded variant applies inline style for github" do
      assert render_github() =~ "background-color"
    end

    test "google branded style is white bg" do
      assert render_google() =~ "#ffffff"
    end

    test "renders SVG icon for google" do
      assert render_google() =~ "<svg"
    end

    test "renders SVG path for github" do
      assert render_github() =~ "<path"
    end

    test "icon_only makes label sr-only" do
      assert render_icon_only() =~ "sr-only"
    end

    test "icon_only still renders SVG" do
      assert render_icon_only() =~ "<svg"
    end

    test "outline variant has border classes" do
      assert render_outline() =~ "border"
    end

    test "outline variant has no inline style" do
      refute render_outline() =~ "background-color"
    end

    test "ghost variant has hover:bg-accent" do
      assert render_ghost() =~ "hover:bg-accent"
    end

    test "loading shows spinner" do
      assert render_loading() =~ "animate-spin"
    end

    test "disabled adds opacity-50" do
      assert render_disabled() =~ "opacity-50"
    end

    test "function is exported" do
      assert function_exported?(PhiaUi.Components.SocialButton, :social_button, 1)
    end
  end

  describe "social_button_group/1" do
    test "renders wrapper div" do
      assert render_group() =~ "<div"
    end

    test "vertical orientation uses flex-col" do
      assert render_group() =~ "flex-col"
    end

    test "horizontal orientation uses flex-row" do
      assert render_group_horizontal() =~ "flex-row"
    end

    test "renders children" do
      html = render_group()
      assert html =~ "Sign in with GitHub"
      assert html =~ "Sign in with Google"
    end

    test "function is exported" do
      assert function_exported?(PhiaUi.Components.SocialButton, :social_button_group, 1)
    end
  end
end
