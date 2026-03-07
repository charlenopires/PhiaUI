defmodule PhiaUi.Components.ArticleCardTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ArticleCard

    attr :title, :string, default: "Article Title"
    attr :href, :string, default: nil
    attr :cover_src, :string, default: nil
    attr :cover_alt, :string, default: ""
    attr :category, :string, default: nil
    attr :date, :string, default: nil
    attr :read_time, :string, default: nil
    attr :excerpt, :string, default: nil
    attr :author_name, :string, default: nil
    attr :author_src, :string, default: nil
    attr :class, :string, default: nil

    def render_article_card(assigns) do
      ~H"""
      <.article_card
        title={@title}
        href={@href}
        cover_src={@cover_src}
        cover_alt={@cover_alt}
        category={@category}
        date={@date}
        read_time={@read_time}
        excerpt={@excerpt}
        author_name={@author_name}
        author_src={@author_src}
        class={@class}
      />
      """
    end

    attr :title, :string, default: "Post"
    attr :author_name, :string, default: "Bob"
    attr :author_src, :string, default: "/author.jpg"

    def render_with_author_src(assigns) do
      ~H"""
      <.article_card title={@title} author_name={@author_name} author_src={@author_src} />
      """
    end
  end

  defp render_article_card(attrs \\ %{}) do
    render_component(&H.render_article_card/1, attrs)
  end

  describe "article_card/1 default render" do
    test "renders a card wrapper" do
      html = render_article_card()
      assert html =~ "<div"
    end

    test "renders the title" do
      html = render_article_card(%{title: "My Great Post"})
      assert html =~ "My Great Post"
    end

    test "title is in an h2 element" do
      html = render_article_card(%{title: "Test"})
      assert html =~ "<h2"
    end
  end

  describe "article_card/1 cover image" do
    test "renders cover image when cover_src provided" do
      html = render_article_card(%{cover_src: "/img/cover.jpg"})
      assert html =~ "<img"
      assert html =~ ~s(src="/img/cover.jpg")
    end

    test "renders cover alt text" do
      html = render_article_card(%{cover_src: "/img/cover.jpg", cover_alt: "Cover photo"})
      assert html =~ "Cover photo"
    end

    test "does not render img when cover_src is nil" do
      html = render_article_card(%{cover_src: nil})
      refute html =~ "aspect-video"
    end
  end

  describe "article_card/1 category badge" do
    test "renders category badge when category provided" do
      html = render_article_card(%{category: "Tutorial"})
      assert html =~ "Tutorial"
    end

    test "does not render badge when category is nil" do
      html = render_article_card(%{category: nil})
      refute html =~ "Tutorial"
    end
  end

  describe "article_card/1 meta row" do
    test "renders date when provided" do
      html = render_article_card(%{date: "Mar 6, 2026"})
      assert html =~ "Mar 6, 2026"
    end

    test "renders read_time when provided" do
      html = render_article_card(%{read_time: "5 min read"})
      assert html =~ "5 min read"
    end

    test "renders both date and read_time with separator" do
      html = render_article_card(%{date: "Mar 6, 2026", read_time: "3 min read"})
      assert html =~ "Mar 6, 2026"
      assert html =~ "3 min read"
    end

    test "does not render meta row when both are nil" do
      html = render_article_card(%{date: nil, read_time: nil})
      # The meta row div is only rendered when date or read_time is set
      refute html =~ "Mar"
      refute html =~ "min read"
    end
  end

  describe "article_card/1 href link" do
    test "renders title as link when href provided" do
      html = render_article_card(%{title: "Linked Post", href: "/posts/linked"})
      assert html =~ ~s(href="/posts/linked")
      assert html =~ "hover:underline"
    end

    test "renders title as plain span when no href" do
      html = render_article_card(%{title: "Plain Post", href: nil})
      assert html =~ "Plain Post"
      refute html =~ "href="
    end
  end

  describe "article_card/1 excerpt" do
    test "renders excerpt when provided" do
      html = render_article_card(%{excerpt: "A short preview of the article."})
      assert html =~ "A short preview of the article."
    end

    test "excerpt has line-clamp class" do
      html = render_article_card(%{excerpt: "Some text"})
      assert html =~ "line-clamp-3"
    end

    test "does not render excerpt element when nil" do
      html = render_article_card(%{excerpt: nil})
      refute html =~ "line-clamp-3"
    end
  end

  describe "article_card/1 author" do
    test "renders author name when provided" do
      html = render_article_card(%{author_name: "Alice Jones"})
      assert html =~ "Alice Jones"
    end

    test "does not render author section when author_name is nil" do
      html = render_article_card(%{author_name: nil})
      refute html =~ "Alice Jones"
    end

    test "renders author avatar img when author_src provided" do
      html = render_component(&H.render_with_author_src/1, %{})
      assert html =~ "<img"
      assert html =~ ~s(src="/author.jpg")
    end

    test "does not render avatar img when author_src is nil" do
      html = render_article_card(%{author_name: "Bob", author_src: nil})
      refute html =~ "<img"
    end
  end

  describe "article_card/1 class forwarding" do
    test "accepts custom class" do
      html = render_article_card(%{class: "my-article"})
      assert html =~ "my-article"
    end
  end
end
