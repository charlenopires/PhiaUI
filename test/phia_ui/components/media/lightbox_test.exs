defmodule PhiaUi.Components.LightboxTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Lightbox

    def render_lightbox(assigns) do
      ~H"""
      <.lightbox id={assigns[:id] || "gallery"} class={assigns[:class]}>
        <.lightbox_item
          src={assigns[:src] || "/img/photo1.jpg"}
          thumb_src={assigns[:thumb_src]}
          alt={assigns[:alt] || "Photo"}
          caption={assigns[:caption]}
          type={assigns[:type] || :image}
        />
      </.lightbox>
      """
    end

    def render_multiple_items(assigns) do
      ~H"""
      <.lightbox id="multi">
        <.lightbox_item src="/img/1.jpg" caption="First" />
        <.lightbox_item src="/img/2.jpg" caption="Second" />
        <.lightbox_item src="/vid/1.mp4" type={:video} caption="Video" />
      </.lightbox>
      """
    end
  end

  defp render_lightbox(attrs \\ %{}), do: render_component(&H.render_lightbox/1, attrs)
  defp render_multiple_items, do: render_component(&H.render_multiple_items/1, %{})

  describe "lightbox/1" do
    test "renders container with id" do
      html = render_lightbox(%{id: "my-gallery"})
      assert html =~ "my-gallery"
    end

    test "has PhiaLightbox hook" do
      assert render_lightbox() =~ "PhiaLightbox"
    end

    test "renders as grid" do
      assert render_lightbox() =~ "grid"
    end

    test "custom class is applied" do
      assert render_lightbox(%{class: "my-grid"}) =~ "my-grid"
    end
  end

  describe "lightbox_item/1" do
    test "renders button trigger" do
      assert render_lightbox() =~ "<button"
    end

    test "renders thumbnail image" do
      html = render_lightbox(%{src: "/img/test.jpg"})
      assert html =~ "<img"
      assert html =~ "/img/test.jpg"
    end

    test "uses thumb_src for display when provided" do
      html = render_lightbox(%{src: "/img/full.jpg", thumb_src: "/img/thumb.jpg"})
      assert html =~ "/img/thumb.jpg"
    end

    test "stores full src in data attribute" do
      html = render_lightbox(%{src: "/img/full.jpg"})
      assert html =~ "data-lightbox-src"
      assert html =~ "/img/full.jpg"
    end

    test "renders caption when provided" do
      assert render_lightbox(%{caption: "Sunset"}) =~ "Sunset"
    end

    test "does not render caption div when none" do
      html = render_lightbox()
      refute html =~ "bg-black/60"
    end

    test "video type renders play icon instead of img" do
      html = render_lightbox(%{type: :video})
      assert html =~ "<svg"
      refute html =~ "<img"
    end

    test "stores type in data attribute" do
      html = render_lightbox(%{type: :video})
      assert html =~ "data-lightbox-type"
      assert html =~ "video"
    end

    test "renders multiple items" do
      html = render_multiple_items()
      assert html =~ "/img/1.jpg"
      assert html =~ "/img/2.jpg"
      assert html =~ "/vid/1.mp4"
    end

    test "has aspect-square class" do
      assert render_lightbox() =~ "aspect-square"
    end
  end
end
