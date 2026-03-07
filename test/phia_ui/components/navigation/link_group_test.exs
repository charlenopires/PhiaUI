defmodule PhiaUi.Components.LinkGroupTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.LinkGroup

    def render_group(assigns) do
      ~H"""
      <.link_group>
        <.link_group_heading>Resources</.link_group_heading>
        <.link_group_item href="/docs">Documentation</.link_group_item>
        <.link_group_item href="/blog">Blog</.link_group_item>
      </.link_group>
      """
    end

    def render_external(assigns) do
      ~H"""
      <.link_group>
        <.link_group_item href="https://example.com" external={true}>
          External Link
        </.link_group_item>
      </.link_group>
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.link_group>
        <.link_group_item href="/coming-soon" disabled={true}>
          Coming Soon
        </.link_group_item>
      </.link_group>
      """
    end
  end

  defp render_group, do: render_component(&H.render_group/1, %{})
  defp render_external, do: render_component(&H.render_external/1, %{})
  defp render_disabled, do: render_component(&H.render_disabled/1, %{})

  describe "link_group/1" do
    test "renders a flex column container" do
      assert render_group() =~ "flex"
      assert render_group() =~ "flex-col"
    end
  end

  describe "link_group_heading/1" do
    test "renders h3 element" do
      assert render_group() =~ "<h3"
    end

    test "renders heading text" do
      assert render_group() =~ "Resources"
    end

    test "uses semibold font weight" do
      assert render_group() =~ "font-semibold"
    end
  end

  describe "link_group_item/1" do
    test "renders anchor element" do
      assert render_group() =~ "<a"
    end

    test "renders link text" do
      assert render_group() =~ "Documentation"
    end

    test "renders href" do
      assert render_group() =~ ~s(href="/docs")
    end

    test "uses muted foreground color" do
      assert render_group() =~ "text-muted-foreground"
    end
  end

  describe "link_group_item/1 — external" do
    test "adds target=_blank for external links" do
      assert render_external() =~ ~s(target="_blank")
    end

    test "adds rel=noopener noreferrer for external links" do
      assert render_external() =~ "noopener"
      assert render_external() =~ "noreferrer"
    end
  end

  describe "link_group_item/1 — disabled" do
    test "adds pointer-events-none for disabled" do
      assert render_disabled() =~ "pointer-events-none"
    end

    test "adds opacity-50 for disabled" do
      assert render_disabled() =~ "opacity-50"
    end

    test "removes href for disabled" do
      html = render_disabled()
      refute html =~ ~s(href="/coming-soon")
    end
  end
end
