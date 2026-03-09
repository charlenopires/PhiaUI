defmodule PhiaUi.Components.Layout.CoverTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Layout.Cover

    def render_cover(assigns) do
      ~H"""
      <.cover
        src={assigns[:src]}
        video_src={assigns[:video_src]}
        video_type={assigns[:video_type] || "video/mp4"}
        height={assigns[:height] || :lg}
        overlay={assigns[:overlay] || :dark}
        overlay_opacity={assigns[:overlay_opacity] || :md}
        position={assigns[:position] || :center}
        class={assigns[:class]}
      >
        {assigns[:content] || "Cover content"}
      </.cover>
      """
    end
  end

  defp render_cover(attrs \\ %{}), do: render_component(&H.render_cover/1, attrs)

  describe "cover/1" do
    test "renders content" do
      assert render_cover(%{content: "Hello World"}) =~ "Hello World"
    end

    test "renders image background when src provided" do
      html = render_cover(%{src: "/img/hero.jpg"})
      assert html =~ "<img"
      assert html =~ "/img/hero.jpg"
      assert html =~ "object-cover"
    end

    test "renders video background when video_src provided" do
      html = render_cover(%{video_src: "/vid/bg.mp4"})
      assert html =~ "<video"
      assert html =~ "/vid/bg.mp4"
    end

    test "does not render img when no src" do
      html = render_cover()
      refute html =~ "<img"
    end

    test "height :sm applies h-48" do
      assert render_cover(%{height: :sm}) =~ "h-48"
    end

    test "height :viewport applies min-h-dvh" do
      assert render_cover(%{height: :viewport}) =~ "min-h-dvh"
    end

    test "default height is h-96" do
      assert render_cover() =~ "h-96"
    end

    test "overlay :dark adds bg-black" do
      assert render_cover(%{overlay: :dark}) =~ "bg-black"
    end

    test "overlay :none does not render overlay div" do
      html = render_cover(%{overlay: :none})
      refute html =~ "opacity-50"
    end

    test "overlay :gradient adds gradient class" do
      assert render_cover(%{overlay: :gradient}) =~ "bg-gradient-to-t"
    end

    test "position :center centers content" do
      assert render_cover(%{position: :center}) =~ "items-center"
    end

    test "position :bottom aligns to bottom" do
      assert render_cover(%{position: :bottom}) =~ "items-end"
    end

    test "custom class is applied" do
      assert render_cover(%{class: "my-cover"}) =~ "my-cover"
    end

    test "has relative and overflow-hidden" do
      html = render_cover()
      assert html =~ "relative"
      assert html =~ "overflow-hidden"
    end
  end
end
