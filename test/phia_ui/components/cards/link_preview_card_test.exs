defmodule PhiaUi.Components.LinkPreviewCardTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.LinkPreviewCard

    attr(:url, :string, default: "https://example.com/page")
    attr(:title, :string, default: "Example Page")
    attr(:description, :string, default: nil)
    attr(:image_src, :string, default: nil)
    attr(:favicon_src, :string, default: nil)
    attr(:site_name, :string, default: nil)
    attr(:variant, :atom, default: :default)
    attr(:class, :string, default: nil)

    def render_link_preview_card(assigns) do
      ~H"""
      <.link_preview_card
        url={@url}
        title={@title}
        description={@description}
        image_src={@image_src}
        favicon_src={@favicon_src}
        site_name={@site_name}
        variant={@variant}
        class={@class}
      />
      """
    end
  end

  defp render_link_preview_card(attrs \\ %{}) do
    render_component(&H.render_link_preview_card/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # Basic rendering
  # ---------------------------------------------------------------------------

  describe "link_preview_card/1 basic rendering" do
    test "renders a wrapper element" do
      html = render_link_preview_card()
      assert html =~ "<div"
    end

    test "renders the title" do
      html = render_link_preview_card(%{title: "Phoenix Framework"})
      assert html =~ "Phoenix Framework"
    end

    test "renders the url as href" do
      html = render_link_preview_card(%{url: "https://phoenixframework.org"})
      assert html =~ "https://phoenixframework.org"
    end
  end

  # ---------------------------------------------------------------------------
  # Domain extraction
  # ---------------------------------------------------------------------------

  describe "link_preview_card/1 domain extraction" do
    test "extracts domain from full URL" do
      html = render_link_preview_card(%{url: "https://elixir-lang.org/docs"})
      assert html =~ "elixir-lang.org"
    end

    test "extracts domain from URL with path and query" do
      html = render_link_preview_card(%{url: "https://hexdocs.pm/phoenix/overview.html?q=test"})
      assert html =~ "hexdocs.pm"
    end

    test "handles URL without path" do
      html = render_link_preview_card(%{url: "https://example.com"})
      assert html =~ "example.com"
    end
  end

  # ---------------------------------------------------------------------------
  # Description
  # ---------------------------------------------------------------------------

  describe "link_preview_card/1 description" do
    test "renders description when provided" do
      html = render_link_preview_card(%{description: "A great framework for web apps."})
      assert html =~ "A great framework for web apps."
    end

    test "description not rendered when nil" do
      html = render_link_preview_card(%{description: nil})
      refute html =~ "line-clamp-2"
    end
  end

  # ---------------------------------------------------------------------------
  # Image
  # ---------------------------------------------------------------------------

  describe "link_preview_card/1 image_src" do
    test "renders image when image_src provided" do
      html = render_link_preview_card(%{image_src: "/og/preview.png"})
      assert html =~ ~s(src="/og/preview.png")
    end

    test "image not rendered when image_src is nil" do
      html = render_link_preview_card(%{image_src: nil})
      refute html =~ "aspect-video"
    end
  end

  # ---------------------------------------------------------------------------
  # Favicon
  # ---------------------------------------------------------------------------

  describe "link_preview_card/1 favicon_src" do
    test "renders favicon img when favicon_src provided" do
      html = render_link_preview_card(%{favicon_src: "/favicon.ico"})
      assert html =~ ~s(src="/favicon.ico")
    end

    test "favicon not rendered when favicon_src is nil" do
      html = render_link_preview_card(%{favicon_src: nil, site_name: nil})
      refute html =~ "/favicon.ico"
    end
  end

  # ---------------------------------------------------------------------------
  # Site name
  # ---------------------------------------------------------------------------

  describe "link_preview_card/1 site_name" do
    test "renders site_name when provided" do
      html = render_link_preview_card(%{site_name: "Phoenix Framework"})
      assert html =~ "Phoenix Framework"
    end

    test "site_name not rendered when nil" do
      html = render_link_preview_card(%{site_name: nil, favicon_src: nil})
      refute html =~ "Phoenix Framework"
    end
  end

  # ---------------------------------------------------------------------------
  # :default variant
  # ---------------------------------------------------------------------------

  describe "link_preview_card/1 :default variant" do
    test "renders external-link icon" do
      html = render_link_preview_card(%{variant: :default})
      assert html =~ ~s(href="/icons/lucide-sprite.svg#icon-external-link")
    end

    test "renders as a card with border" do
      html = render_link_preview_card(%{variant: :default})
      assert html =~ "border"
    end

    test "renders image when image_src provided" do
      html = render_link_preview_card(%{variant: :default, image_src: "/img.jpg"})
      assert html =~ "aspect-video"
    end
  end

  # ---------------------------------------------------------------------------
  # :compact variant
  # ---------------------------------------------------------------------------

  describe "link_preview_card/1 :compact variant" do
    test "renders title" do
      html = render_link_preview_card(%{variant: :compact, title: "Compact Title"})
      assert html =~ "Compact Title"
    end

    test "renders domain" do
      html = render_link_preview_card(%{variant: :compact, url: "https://compact.example.com"})
      assert html =~ "compact.example.com"
    end

    test "renders external-link icon" do
      html = render_link_preview_card(%{variant: :compact})
      assert html =~ ~s(href="/icons/lucide-sprite.svg#icon-external-link")
    end

    test "does not render image" do
      html = render_link_preview_card(%{variant: :compact, image_src: "/img.jpg"})
      refute html =~ "aspect-video"
    end
  end

  # ---------------------------------------------------------------------------
  # :minimal variant
  # ---------------------------------------------------------------------------

  describe "link_preview_card/1 :minimal variant" do
    test "renders title as a link" do
      html = render_link_preview_card(%{variant: :minimal, title: "Minimal Link"})
      assert html =~ "Minimal Link"
    end

    test "renders domain" do
      html = render_link_preview_card(%{variant: :minimal, url: "https://minimal.example.com"})
      assert html =~ "minimal.example.com"
    end

    test "does not render external-link icon" do
      html = render_link_preview_card(%{variant: :minimal})
      refute html =~ ~s(href="/icons/lucide-sprite.svg#icon-external-link")
    end

    test "does not render card border" do
      html = render_link_preview_card(%{variant: :minimal})
      refute html =~ "rounded-lg border"
    end
  end

  # ---------------------------------------------------------------------------
  # Custom class
  # ---------------------------------------------------------------------------

  describe "link_preview_card/1 class" do
    test "accepts custom class" do
      html = render_link_preview_card(%{class: "my-preview-class"})
      assert html =~ "my-preview-class"
    end
  end
end
