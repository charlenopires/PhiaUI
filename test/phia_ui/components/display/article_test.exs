defmodule PhiaUi.Components.ArticleTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Article

    def render_article(assigns) do
      ~H"""
      <.article class={assigns[:class]}>
        <:title>{assigns[:title] || "My Article"}</:title>
        <:meta :if={assigns[:meta]}>{assigns[:meta]}</:meta>
        <:lead :if={assigns[:lead]}>{assigns[:lead]}</:lead>
        {assigns[:body] || "Body content here"}
        <:footer :if={assigns[:footer]}>{assigns[:footer]}</:footer>
      </.article>
      """
    end
  end

  defp render_article(attrs \\ %{}), do: render_component(&H.render_article/1, attrs)

  describe "article/1" do
    test "renders article element" do
      assert render_article() =~ "<article"
    end

    test "renders title in h1" do
      html = render_article(%{title: "Hello World"})
      assert html =~ "<h1"
      assert html =~ "Hello World"
    end

    test "title has correct typography classes" do
      assert render_article() =~ "text-3xl"
      assert render_article() =~ "font-bold"
      assert render_article() =~ "tracking-tight"
    end

    test "renders body content" do
      assert render_article(%{body: "Some great content"}) =~ "Some great content"
    end

    test "renders meta slot when provided" do
      html = render_article(%{meta: "March 9, 2026"})
      assert html =~ "March 9, 2026"
      assert html =~ "text-muted-foreground"
    end

    test "does not render meta when not provided" do
      html = render_article()
      refute html =~ "text-sm text-muted-foreground"
    end

    test "renders lead slot when provided" do
      html = render_article(%{lead: "An introduction"})
      assert html =~ "An introduction"
      assert html =~ "text-lg"
    end

    test "renders footer slot when provided" do
      html = render_article(%{footer: "Tags: elixir"})
      assert html =~ "Tags: elixir"
      assert html =~ "border-t"
    end

    test "does not render footer when not provided" do
      html = render_article()
      refute html =~ "<footer"
    end

    test "custom class is applied" do
      assert render_article(%{class: "my-article"}) =~ "my-article"
    end
  end
end
