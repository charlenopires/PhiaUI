defmodule PhiaUi.Components.Surface.AnimatedSurfaceTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.AnimatedSurface

    def render_border_beam(assigns),
      do: ~H[<.border_beam {assigns}>content</.border_beam>]

    def render_shine_border(assigns),
      do: ~H[<.shine_border {assigns}>content</.shine_border>]

    def render_magic_card(assigns),
      do: ~H[<.magic_card {assigns}>content</.magic_card>]

    def render_card_spotlight(assigns),
      do: ~H[<.card_spotlight {assigns}>content</.card_spotlight>]

    def render_moving_border(assigns),
      do: ~H[<.moving_border {assigns}>content</.moving_border>]
  end

  # ---------------------------------------------------------------------------
  # border_beam/1
  # ---------------------------------------------------------------------------

  describe "border_beam/1" do
    test "renders overflow-hidden rounded-xl" do
      html = render_component(&H.render_border_beam/1, %{
        duration: 8,
        color_from: "#ffaa40",
        color_to: "#9c40ff",
        class: nil
      })
      assert html =~ "overflow-hidden"
      assert html =~ "rounded-xl"
    end

    test "injects color_from into conic-gradient style" do
      html = render_component(&H.render_border_beam/1, %{
        duration: 8,
        color_from: "#ffaa40",
        color_to: "#9c40ff",
        class: nil
      })
      assert html =~ "#ffaa40"
      assert html =~ "conic-gradient"
    end

    test "uses phia-border-beam animation name" do
      html = render_component(&H.render_border_beam/1, %{
        duration: 8,
        color_from: "#ffaa40",
        color_to: "#9c40ff",
        class: nil
      })
      assert html =~ "phia-border-beam"
    end

    test "duration is embedded in animation style" do
      html = render_component(&H.render_border_beam/1, %{
        duration: 12,
        color_from: "#ffaa40",
        color_to: "#9c40ff",
        class: nil
      })
      assert html =~ "12s"
    end

    test "renders content in z-10 wrapper" do
      html = render_component(&H.render_border_beam/1, %{
        duration: 8,
        color_from: "#ffaa40",
        color_to: "#9c40ff",
        class: nil
      })
      assert html =~ "z-10"
      assert html =~ "content"
    end
  end

  # ---------------------------------------------------------------------------
  # shine_border/1
  # ---------------------------------------------------------------------------

  describe "shine_border/1" do
    test "renders shine_color in style" do
      html = render_component(&H.render_shine_border/1, %{shine_color: "#gold", duration: 6, class: nil})
      assert html =~ "#gold"
      assert html =~ "conic-gradient"
    end

    test "uses phia-shine-border animation name" do
      html = render_component(&H.render_shine_border/1, %{shine_color: "#ffffff", duration: 6, class: nil})
      assert html =~ "phia-shine-border"
    end

    test "duration is embedded in animation style" do
      html = render_component(&H.render_shine_border/1, %{shine_color: "#ffffff", duration: 10, class: nil})
      assert html =~ "10s"
    end

    test "renders bg-card wrapper" do
      html = render_component(&H.render_shine_border/1, %{shine_color: "#ffffff", duration: 6, class: nil})
      assert html =~ "bg-card"
    end

    test "renders content" do
      html = render_component(&H.render_shine_border/1, %{shine_color: "#ffffff", duration: 6, class: nil})
      assert html =~ "content"
    end
  end

  # ---------------------------------------------------------------------------
  # magic_card/1
  # ---------------------------------------------------------------------------

  describe "magic_card/1" do
    test "renders id attribute" do
      html = render_component(&H.render_magic_card/1, %{id: "my-magic", gradient_color: "#262626", class: nil})
      assert html =~ ~s[id="my-magic"]
    end

    test "renders phx-hook=PhiaMagicCard" do
      html = render_component(&H.render_magic_card/1, %{id: "my-magic", gradient_color: "#262626", class: nil})
      assert html =~ ~s[phx-hook="PhiaMagicCard"]
    end

    test "renders data-gradient-color" do
      html = render_component(&H.render_magic_card/1, %{id: "my-magic", gradient_color: "#1a1a2e", class: nil})
      assert html =~ ~s[data-gradient-color="#1a1a2e"]
    end

    test "renders data-magic-overlay child" do
      html = render_component(&H.render_magic_card/1, %{id: "my-magic", gradient_color: "#262626", class: nil})
      assert html =~ "data-magic-overlay"
    end

    test "renders content in z-10 wrapper" do
      html = render_component(&H.render_magic_card/1, %{id: "my-magic", gradient_color: "#262626", class: nil})
      assert html =~ "relative z-10"
      assert html =~ "content"
    end

    test "renders bg-card and border" do
      html = render_component(&H.render_magic_card/1, %{id: "my-magic", gradient_color: "#262626", class: nil})
      assert html =~ "bg-card"
      assert html =~ "border-border"
    end
  end

  # ---------------------------------------------------------------------------
  # card_spotlight/1
  # ---------------------------------------------------------------------------

  describe "card_spotlight/1" do
    test "renders id attribute" do
      html = render_component(&H.render_card_spotlight/1, %{
        id: "spotlight-card",
        color: "rgba(255,255,255,0.1)",
        size: 300,
        class: nil
      })
      assert html =~ ~s[id="spotlight-card"]
    end

    test "renders phx-hook=PhiaCardSpotlight" do
      html = render_component(&H.render_card_spotlight/1, %{
        id: "spotlight-card",
        color: "rgba(255,255,255,0.1)",
        size: 300,
        class: nil
      })
      assert html =~ ~s[phx-hook="PhiaCardSpotlight"]
    end

    test "renders data-size attribute" do
      html = render_component(&H.render_card_spotlight/1, %{
        id: "spotlight-card",
        color: "rgba(255,255,255,0.1)",
        size: 400,
        class: nil
      })
      assert html =~ ~s[data-size="400"]
    end

    test "renders data-color attribute" do
      html = render_component(&H.render_card_spotlight/1, %{
        id: "spotlight-card",
        color: "rgba(120,80,255,0.15)",
        size: 300,
        class: nil
      })
      assert html =~ "data-color"
    end

    test "renders data-spotlight-overlay child" do
      html = render_component(&H.render_card_spotlight/1, %{
        id: "spotlight-card",
        color: "rgba(255,255,255,0.1)",
        size: 300,
        class: nil
      })
      assert html =~ "data-spotlight-overlay"
    end

    test "renders content in z-10 wrapper" do
      html = render_component(&H.render_card_spotlight/1, %{
        id: "spotlight-card",
        color: "rgba(255,255,255,0.1)",
        size: 300,
        class: nil
      })
      assert html =~ "relative z-10"
      assert html =~ "content"
    end
  end

  # ---------------------------------------------------------------------------
  # moving_border/1
  # ---------------------------------------------------------------------------

  describe "moving_border/1" do
    test "renders p-px overflow-hidden rounded-xl" do
      html = render_component(&H.render_moving_border/1, %{duration: 4, class: nil})
      assert html =~ "p-px"
      assert html =~ "overflow-hidden"
    end

    test "uses phia-moving-border animation" do
      html = render_component(&H.render_moving_border/1, %{duration: 4, class: nil})
      assert html =~ "phia-moving-border"
    end

    test "duration embedded in style" do
      html = render_component(&H.render_moving_border/1, %{duration: 8, class: nil})
      assert html =~ "8s"
    end

    test "inner div has bg-card" do
      html = render_component(&H.render_moving_border/1, %{duration: 4, class: nil})
      assert html =~ "bg-card"
    end

    test "renders content" do
      html = render_component(&H.render_moving_border/1, %{duration: 4, class: nil})
      assert html =~ "content"
    end
  end
end
