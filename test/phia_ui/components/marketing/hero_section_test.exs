defmodule PhiaUi.Components.Marketing.HeroSectionTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Marketing.HeroSection

    def render_hero(assigns) do
      ~H"""
      <.hero_section
        title={assigns[:title] || "Welcome"}
        description={assigns[:description]}
        align={assigns[:align] || :center}
        layout={assigns[:layout] || :stacked}
        size={assigns[:size] || :default}
        class={assigns[:class]}
      >
        <:badge :if={assigns[:badge_text]}>{assigns[:badge_text]}</:badge>
        <:actions :if={assigns[:actions_text]}>{assigns[:actions_text]}</:actions>
        <:media :if={assigns[:media_text]}>{assigns[:media_text]}</:media>
        {assigns[:content]}
      </.hero_section>
      """
    end
  end

  defp render_hero(attrs \\ %{}), do: render_component(&H.render_hero/1, attrs)

  describe "hero_section/1" do
    test "renders title text" do
      html = render_hero(%{title: "Build Faster"})
      assert html =~ "Build Faster"
      assert html =~ "<h1"
    end

    test "renders description when provided" do
      html = render_hero(%{description: "829 components ready."})
      assert html =~ "829 components ready."
      assert html =~ "text-muted-foreground"
    end

    test "does not render description paragraph when nil" do
      html = render_hero(%{description: nil})
      refute html =~ "text-muted-foreground"
    end

    test "default layout stacked renders flex-col" do
      html = render_hero()
      assert html =~ "flex"
      assert html =~ "flex-col"
    end

    test "split layout renders grid with lg:grid-cols-2" do
      html = render_hero(%{layout: :split})
      assert html =~ "grid"
      assert html =~ "lg:grid-cols-2"
    end

    test "center align renders text-center" do
      html = render_hero(%{align: :center})
      assert html =~ "text-center"
    end

    test "start align renders text-left" do
      html = render_hero(%{align: :start})
      assert html =~ "text-left"
    end

    test "actions slot renders content" do
      html = render_hero(%{actions_text: "Get Started"})
      assert html =~ "Get Started"
      assert html =~ "flex-wrap"
    end

    test "media slot renders content" do
      html = render_hero(%{media_text: "Hero image"})
      assert html =~ "Hero image"
    end

    test "badge slot renders content" do
      html = render_hero(%{badge_text: "New Release"})
      assert html =~ "New Release"
    end

    test "custom class is applied" do
      assert render_hero(%{class: "my-hero"}) =~ "my-hero"
    end

    test "size sm renders text-3xl" do
      assert render_hero(%{size: :sm}) =~ "text-3xl"
    end

    test "size lg renders text-5xl" do
      assert render_hero(%{size: :lg}) =~ "text-5xl"
    end

    test "renders section element" do
      assert render_hero() =~ "<section"
    end
  end
end
