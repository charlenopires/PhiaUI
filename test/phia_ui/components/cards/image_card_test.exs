defmodule PhiaUi.Components.ImageCardTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ImageCard

    attr :src, :string, default: "/img.jpg"
    attr :alt, :string, default: "test"
    attr :aspect, :atom, default: :video
    attr :overlay, :boolean, default: false
    attr :class, :string, default: nil

    def render_image_card(assigns) do
      ~H"""
      <.image_card src={@src} alt={@alt} aspect={@aspect} overlay={@overlay} class={@class}>
        <p>Content</p>
      </.image_card>
      """
    end

    attr :src, :string, default: "/img.jpg"

    def render_with_badge(assigns) do
      ~H"""
      <.image_card src={@src}>
        <:badge><span>New</span></:badge>
        <p>Content</p>
      </.image_card>
      """
    end
  end

  defp render_image_card(attrs \\ %{}) do
    render_component(&H.render_image_card/1, attrs)
  end

  describe "image_card/1 basic" do
    test "renders img element" do
      assert render_image_card() =~ "<img"
    end

    test "renders src attribute" do
      assert render_image_card(%{src: "/photo.jpg"}) =~ "/photo.jpg"
    end

    test "renders alt attribute" do
      assert render_image_card(%{alt: "My photo"}) =~ "My photo"
    end

    test "renders inner content" do
      assert render_image_card() =~ "Content"
    end

    test "accepts custom class" do
      assert render_image_card(%{class: "my-custom"}) =~ "my-custom"
    end

    test "renders overflow-hidden on card" do
      assert render_image_card() =~ "overflow-hidden"
    end
  end

  describe "image_card/1 aspect ratios" do
    test ":video applies aspect-video" do
      assert render_image_card(%{aspect: :video}) =~ "aspect-video"
    end

    test ":square applies aspect-square" do
      assert render_image_card(%{aspect: :square}) =~ "aspect-square"
    end

    test ":wide applies aspect-[2/1]" do
      assert render_image_card(%{aspect: :wide}) =~ "aspect-[2/1]"
    end

    test ":tall applies aspect-[3/4]" do
      assert render_image_card(%{aspect: :tall}) =~ "aspect-[3/4]"
    end
  end

  describe "image_card/1 overlay" do
    test "overlay adds gradient class" do
      html = render_image_card(%{overlay: true})
      assert html =~ "after:bg-gradient-to-t"
    end

    test "no overlay class by default" do
      html = render_image_card(%{overlay: false})
      refute html =~ "after:bg-gradient-to-t"
    end

    test "overlay adds from-black/60" do
      html = render_image_card(%{overlay: true})
      assert html =~ "after:from-black/60"
    end
  end

  describe "image_card/1 badge slot" do
    test "renders badge slot when provided" do
      html = render_component(&H.render_with_badge/1, %{})
      assert html =~ "New"
    end

    test "badge is positioned absolutely top-left" do
      html = render_component(&H.render_with_badge/1, %{})
      assert html =~ "absolute"
      assert html =~ "top-2"
      assert html =~ "left-2"
    end
  end
end
