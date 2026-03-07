defmodule PhiaUi.Components.ColorSwatchCardTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ColorSwatchCard

    attr :name, :string, default: "Ocean Blue"
    attr :hex, :string, default: "#1E90FF"
    attr :rgb, :string, default: nil
    attr :hsl, :string, default: nil
    attr :copyable, :boolean, default: true
    attr :size, :atom, default: :md
    attr :class, :string, default: nil

    def render_color_swatch_card(assigns) do
      ~H"""
      <.color_swatch_card
        name={@name}
        hex={@hex}
        rgb={@rgb}
        hsl={@hsl}
        copyable={@copyable}
        size={@size}
        class={@class}
      />
      """
    end

    attr :name, :string, default: "Forest Green"
    attr :hex, :string, default: "#228B22"

    def render_with_tags(assigns) do
      ~H"""
      <.color_swatch_card name={@name} hex={@hex}>
        <:tags><span data-tag>nature</span></:tags>
      </.color_swatch_card>
      """
    end
  end

  defp render_color_swatch_card(attrs \\ %{}) do
    render_component(&H.render_color_swatch_card/1, attrs)
  end

  describe "color_swatch_card/1 basic rendering" do
    test "renders the color name" do
      assert render_color_swatch_card(%{name: "Ocean Blue"}) =~ "Ocean Blue"
    end

    test "renders the hex value" do
      assert render_color_swatch_card(%{hex: "#1E90FF"}) =~ "#1E90FF"
    end

    test "applies background color via inline style" do
      html = render_color_swatch_card(%{hex: "#1E90FF"})
      assert html =~ "background-color: #1E90FF"
    end

    test "has rounded-lg border overflow-hidden wrapper" do
      html = render_color_swatch_card()
      assert html =~ "rounded-lg"
      assert html =~ "border"
      assert html =~ "overflow-hidden"
    end

    test "accepts custom class" do
      assert render_color_swatch_card(%{class: "my-custom"}) =~ "my-custom"
    end

    test "name has text-sm font-medium" do
      html = render_color_swatch_card()
      assert html =~ "text-sm"
      assert html =~ "font-medium"
    end
  end

  describe "color_swatch_card/1 sizes" do
    test ":sm applies h-16" do
      assert render_color_swatch_card(%{size: :sm}) =~ "h-16"
    end

    test ":md applies h-24" do
      assert render_color_swatch_card(%{size: :md}) =~ "h-24"
    end

    test ":lg applies h-32" do
      assert render_color_swatch_card(%{size: :lg}) =~ "h-32"
    end
  end

  describe "color_swatch_card/1 copyable" do
    test "shows copy button when copyable is true" do
      html = render_color_swatch_card(%{copyable: true})
      assert html =~ "PhiaCopyButton"
    end

    test "hides copy button when copyable is false" do
      html = render_color_swatch_card(%{copyable: false})
      refute html =~ "PhiaCopyButton"
    end
  end

  describe "color_swatch_card/1 optional attrs" do
    test "renders rgb when provided" do
      html = render_color_swatch_card(%{rgb: "rgb(30, 144, 255)"})
      assert html =~ "rgb(30, 144, 255)"
    end

    test "does not render rgb element when nil" do
      html = render_color_swatch_card(%{rgb: nil})
      refute html =~ "rgb("
    end

    test "renders hsl when provided" do
      html = render_color_swatch_card(%{hsl: "hsl(210, 100%, 56%)"})
      assert html =~ "hsl(210, 100%, 56%)"
    end

    test "does not render hsl element when nil" do
      html = render_color_swatch_card(%{hsl: nil})
      refute html =~ "hsl("
    end
  end

  describe "color_swatch_card/1 tags slot" do
    test "renders tags slot content" do
      html = render_component(&H.render_with_tags/1, %{})
      assert html =~ "data-tag"
      assert html =~ "nature"
    end
  end
end
