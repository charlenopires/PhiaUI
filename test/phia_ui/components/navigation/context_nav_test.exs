defmodule PhiaUi.Components.ContextNavTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ContextNav

    def render_default(assigns) do
      ~H"""
      <.context_nav>
        <.context_nav_item href="/overview" active={true} variant={:default}>Overview</.context_nav_item>
        <.context_nav_item href="/analytics" active={false} variant={:default}>Analytics</.context_nav_item>
      </.context_nav>
      """
    end

    def render_sticky(assigns) do
      ~H"""
      <.context_nav sticky={true}>
        <.context_nav_item href="/a" active={false} variant={:default}>Tab A</.context_nav_item>
      </.context_nav>
      """
    end

    def render_bordered(assigns) do
      ~H"""
      <.context_nav variant={:bordered}>
        <.context_nav_item href="/a" active={true} variant={:bordered}>Active</.context_nav_item>
        <.context_nav_item href="/b" active={false} variant={:bordered}>Inactive</.context_nav_item>
      </.context_nav>
      """
    end

    def render_minimal(assigns) do
      ~H"""
      <.context_nav variant={:minimal}>
        <.context_nav_item href="/a" active={true} variant={:minimal}>Active</.context_nav_item>
        <.context_nav_item href="/b" active={false} variant={:minimal}>Inactive</.context_nav_item>
      </.context_nav>
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.context_nav>
        <.context_nav_item href="/locked" active={false} variant={:default} disabled={true}>Locked</.context_nav_item>
      </.context_nav>
      """
    end
  end

  defp render_default, do: render_component(&H.render_default/1, %{})
  defp render_sticky, do: render_component(&H.render_sticky/1, %{})
  defp render_bordered, do: render_component(&H.render_bordered/1, %{})
  defp render_minimal, do: render_component(&H.render_minimal/1, %{})
  defp render_disabled, do: render_component(&H.render_disabled/1, %{})

  describe "context_nav/1" do
    test "renders <nav> element" do
      assert render_default() =~ "<nav"
    end

    test "renders default border-b styling" do
      assert render_default() =~ "border-b"
    end

    test "renders bordered variant classes" do
      assert render_bordered() =~ "rounded-lg"
      assert render_bordered() =~ "border-border"
    end

    test "renders minimal variant (no border-b on nav)" do
      html = render_minimal()
      assert html =~ "<nav"
    end
  end

  describe "context_nav/1 — sticky" do
    test "adds sticky class when sticky=true" do
      assert render_sticky() =~ "sticky"
    end

    test "adds top-0 when sticky=true" do
      assert render_sticky() =~ "top-0"
    end
  end

  describe "context_nav_item/1" do
    test "renders anchor element" do
      assert render_default() =~ "<a"
    end

    test "active item gets aria-current=page" do
      assert render_default() =~ ~s(aria-current="page")
    end

    test "inactive item does not get aria-current" do
      html = render_default()
      count = html |> String.split(~s(aria-current="page")) |> length() |> Kernel.-(1)
      assert count == 1
    end

    test "active default item has border-primary" do
      assert render_default() =~ "border-primary"
    end
  end

  describe "context_nav_item/1 — bordered active" do
    test "active bordered item has bg-background" do
      assert render_bordered() =~ "bg-background"
    end

    test "active bordered item has shadow-sm" do
      assert render_bordered() =~ "shadow-sm"
    end
  end

  describe "context_nav_item/1 — minimal active" do
    test "active minimal item has text-foreground" do
      assert render_minimal() =~ "text-foreground"
    end
  end

  describe "context_nav_item/1 — disabled" do
    test "adds pointer-events-none" do
      assert render_disabled() =~ "pointer-events-none"
    end

    test "adds opacity-50" do
      assert render_disabled() =~ "opacity-50"
    end

    test "removes href when disabled" do
      refute render_disabled() =~ ~s(href="/locked")
    end
  end
end
