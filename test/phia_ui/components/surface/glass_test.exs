defmodule PhiaUi.Components.Surface.GlassTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Glass

    def render_glass_card(assigns), do: ~H[<.glass_card {assigns}>content</.glass_card>]
    def render_glass_panel(assigns), do: ~H[<.glass_panel {assigns}>content</.glass_panel>]
    def render_acrylic(assigns), do: ~H[<.acrylic_surface {assigns}>content</.acrylic_surface>]
    def render_liquid(assigns), do: ~H[<.liquid_glass {assigns}>content</.liquid_glass>]
    def render_neon(assigns), do: ~H[<.neon_glow_card {assigns}>content</.neon_glow_card>]
  end

  # ---------------------------------------------------------------------------
  # glass_card/1
  # ---------------------------------------------------------------------------

  describe "glass_card/1" do
    test "default blur md renders backdrop-blur-md" do
      html = render_component(&H.render_glass_card/1, %{blur: "md", opacity: "medium", class: nil})
      assert html =~ "backdrop-blur-md"
    end

    test "blur xl renders backdrop-blur-xl" do
      html = render_component(&H.render_glass_card/1, %{blur: "xl", opacity: "medium", class: nil})
      assert html =~ "backdrop-blur-xl"
    end

    test "opacity light renders bg-white/10" do
      html = render_component(&H.render_glass_card/1, %{blur: "md", opacity: "light", class: nil})
      assert html =~ "bg-white/10"
    end

    test "opacity dark renders bg-white/40" do
      html = render_component(&H.render_glass_card/1, %{blur: "md", opacity: "dark", class: nil})
      assert html =~ "bg-white/40"
    end

    test "renders white border" do
      html = render_component(&H.render_glass_card/1, %{blur: "md", opacity: "medium", class: nil})
      assert html =~ "border-white/20"
    end

    test "renders shadow-lg" do
      html = render_component(&H.render_glass_card/1, %{blur: "md", opacity: "medium", class: nil})
      assert html =~ "shadow-lg"
    end

    test "renders content" do
      html = render_component(&H.render_glass_card/1, %{blur: "md", opacity: "medium", class: nil})
      assert html =~ "content"
    end

    test "passes extra class" do
      html = render_component(&H.render_glass_card/1, %{blur: "md", opacity: "medium", class: "extra-class"})
      assert html =~ "extra-class"
    end
  end

  # ---------------------------------------------------------------------------
  # glass_panel/1
  # ---------------------------------------------------------------------------

  describe "glass_panel/1" do
    test "renders rounded-2xl p-6" do
      html = render_component(&H.render_glass_panel/1, %{blur: "md", opacity: "medium", class: nil})
      assert html =~ "rounded-2xl"
      assert html =~ "p-6"
    end

    test "renders backdrop-blur" do
      html = render_component(&H.render_glass_panel/1, %{blur: "lg", opacity: "medium", class: nil})
      assert html =~ "backdrop-blur-lg"
    end

    test "renders content" do
      html = render_component(&H.render_glass_panel/1, %{blur: "md", opacity: "medium", class: nil})
      assert html =~ "content"
    end
  end

  # ---------------------------------------------------------------------------
  # acrylic_surface/1
  # ---------------------------------------------------------------------------

  describe "acrylic_surface/1" do
    test "renders backdrop-blur" do
      html = render_component(&H.render_acrylic/1, %{blur: "lg", class: nil})
      assert html =~ "backdrop-blur-lg"
    end

    test "renders bg-white/30" do
      html = render_component(&H.render_acrylic/1, %{blur: "lg", class: nil})
      assert html =~ "bg-white/30"
    end

    test "renders noise overlay" do
      html = render_component(&H.render_acrylic/1, %{blur: "lg", class: nil})
      assert html =~ "feTurbulence"
    end

    test "renders content in z-10 wrapper" do
      html = render_component(&H.render_acrylic/1, %{blur: "lg", class: nil})
      assert html =~ "relative z-10"
      assert html =~ "content"
    end
  end

  # ---------------------------------------------------------------------------
  # liquid_glass/1
  # ---------------------------------------------------------------------------

  describe "liquid_glass/1" do
    test "renders backdrop-blur-xl" do
      html = render_component(&H.render_liquid/1, %{class: nil})
      assert html =~ "backdrop-blur-xl"
    end

    test "renders prismatic gradient wrapper" do
      html = render_component(&H.render_liquid/1, %{class: nil})
      assert html =~ "bg-gradient-to-br"
      assert html =~ "from-white/40"
    end

    test "renders inset shadow" do
      html = render_component(&H.render_liquid/1, %{class: nil})
      assert html =~ "inset"
    end

    test "renders content" do
      html = render_component(&H.render_liquid/1, %{class: nil})
      assert html =~ "content"
    end
  end

  # ---------------------------------------------------------------------------
  # neon_glow_card/1
  # ---------------------------------------------------------------------------

  describe "neon_glow_card/1" do
    test "purple md renders box-shadow with rgb(168 85 247)" do
      html = render_component(&H.render_neon/1, %{color: "purple", intensity: "md", class: nil})
      assert html =~ "168 85 247"
      assert html =~ "box-shadow"
    end

    test "blue renders rgb(59 130 246)" do
      html = render_component(&H.render_neon/1, %{color: "blue", intensity: "md", class: nil})
      assert html =~ "59 130 246"
    end

    test "green renders rgb(34 197 94)" do
      html = render_component(&H.render_neon/1, %{color: "green", intensity: "sm", class: nil})
      assert html =~ "34 197 94"
    end

    test "intensity lg increases opacity values" do
      html_md = render_component(&H.render_neon/1, %{color: "purple", intensity: "md", class: nil})
      html_lg = render_component(&H.render_neon/1, %{color: "purple", intensity: "lg", class: nil})
      assert html_lg =~ "0.6"
      refute html_md =~ "0.6"
    end

    test "renders bg-card" do
      html = render_component(&H.render_neon/1, %{color: "purple", intensity: "md", class: nil})
      assert html =~ "bg-card"
    end

    test "renders content" do
      html = render_component(&H.render_neon/1, %{color: "cyan", intensity: "md", class: nil})
      assert html =~ "content"
    end
  end
end
