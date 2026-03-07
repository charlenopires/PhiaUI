defmodule PhiaUi.Components.TocTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Toc

    def render_toc(assigns) do
      ~H"""
      <.toc id="article-toc" title="On this page" sticky={true}>
        <.toc_item id="introduction" depth={1}>Introduction</.toc_item>
        <.toc_item id="getting-started" depth={2}>Getting Started</.toc_item>
        <.toc_item id="advanced" depth={3}>Advanced Usage</.toc_item>
      </.toc>
      """
    end

    def render_not_sticky(assigns) do
      ~H"""
      <.toc id="article-toc" title="Contents" sticky={false}>
        <.toc_item id="intro" depth={1}>Intro</.toc_item>
      </.toc>
      """
    end
  end

  defp render_toc, do: render_component(&H.render_toc/1, %{})
  defp render_not_sticky, do: render_component(&H.render_not_sticky/1, %{})

  describe "toc/1" do
    test "renders <nav> element" do
      assert render_toc() =~ "<nav"
    end

    test "has phx-hook=PhiaToc" do
      assert render_toc() =~ ~s(phx-hook="PhiaToc")
    end

    test "has aria-label for accessibility" do
      assert render_toc() =~ "aria-label"
    end

    test "renders title text" do
      assert render_toc() =~ "On this page"
    end

    test "sticky=true adds sticky class" do
      assert render_toc() =~ "sticky"
    end

    test "sticky=true adds top-6" do
      assert render_toc() =~ "top-6"
    end

    test "sticky=false does not add sticky class" do
      refute render_not_sticky() =~ "sticky"
    end
  end

  describe "toc_item/1" do
    test "renders <li> element" do
      assert render_toc() =~ "<li"
    end

    test "renders anchor element" do
      assert render_toc() =~ "<a"
    end

    test "href links to heading id" do
      assert render_toc() =~ ~s(href="#introduction")
    end

    test "data-toc-target is set to heading id" do
      assert render_toc() =~ ~s(data-toc-target="introduction")
    end

    test "depth 1 has pl-0 class" do
      assert render_toc() =~ "pl-0"
    end

    test "depth 2 has pl-4 class" do
      assert render_toc() =~ "pl-4"
    end

    test "depth 3 has pl-8 class" do
      assert render_toc() =~ "pl-8"
    end

    test "has data-toc-active hover variant class in template" do
      assert render_toc() =~ "data-[toc-active]"
    end

    test "renders link text" do
      assert render_toc() =~ "Introduction"
    end
  end
end
