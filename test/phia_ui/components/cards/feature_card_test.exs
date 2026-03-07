defmodule PhiaUi.Components.FeatureCardTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.FeatureCard

    attr :title, :string, default: "Fast Performance"
    attr :description, :string, default: nil
    attr :variant, :atom, default: :default
    attr :icon_position, :atom, default: :top
    attr :class, :string, default: nil

    def render_feature_card(assigns) do
      ~H"""
      <.feature_card
        title={@title}
        description={@description}
        variant={@variant}
        icon_position={@icon_position}
        class={@class}
      />
      """
    end

    attr :title, :string, default: "Secure"

    def render_with_icon(assigns) do
      ~H"""
      <.feature_card title={@title}>
        <:icon><span data-icon>*</span></:icon>
      </.feature_card>
      """
    end

    attr :title, :string, default: "Scalable"

    def render_with_inner_block(assigns) do
      ~H"""
      <.feature_card title={@title}>
        <p data-extra>Extra content</p>
      </.feature_card>
      """
    end
  end

  defp render_feature_card(attrs \\ %{}) do
    render_component(&H.render_feature_card/1, attrs)
  end

  describe "feature_card/1 basic rendering" do
    test "renders the title" do
      assert render_feature_card(%{title: "Fast Performance"}) =~ "Fast Performance"
    end

    test "renders description when provided" do
      assert render_feature_card(%{description: "Blazing fast"}) =~ "Blazing fast"
    end

    test "does not render description element when nil" do
      html = render_feature_card()
      refute html =~ "text-muted-foreground"
    end

    test "accepts custom class" do
      assert render_feature_card(%{class: "my-custom"}) =~ "my-custom"
    end

    test "title has semibold styling" do
      assert render_feature_card() =~ "font-semibold"
    end
  end

  describe "feature_card/1 variants" do
    test ":default applies border and shadow-sm" do
      html = render_feature_card(%{variant: :default})
      assert html =~ "border"
      assert html =~ "shadow-sm"
    end

    test ":bordered applies border-2" do
      html = render_feature_card(%{variant: :bordered})
      assert html =~ "border-2"
    end

    test ":bordered does not apply shadow-sm" do
      html = render_feature_card(%{variant: :bordered})
      refute html =~ "shadow-sm"
    end

    test ":ghost applies no border or shadow" do
      html = render_feature_card(%{variant: :ghost})
      assert html =~ "border-0"
      assert html =~ "shadow-none"
    end

    test ":ghost renders a plain div instead of a card" do
      html = render_feature_card(%{variant: :ghost})
      # Ghost should not have card-specific classes like bg-card
      refute html =~ "bg-card"
    end
  end

  describe "feature_card/1 icon_position" do
    test ":top uses flex-col layout" do
      html = render_feature_card(%{icon_position: :top})
      assert html =~ "flex-col"
    end

    test ":left uses flex-row layout" do
      html = render_feature_card(%{icon_position: :left})
      assert html =~ "flex-row"
    end
  end

  describe "feature_card/1 icon slot" do
    test "renders icon slot content" do
      html = render_component(&H.render_with_icon/1, %{})
      assert html =~ "data-icon"
    end

    test "icon is not rendered when slot is empty" do
      html = render_feature_card()
      refute html =~ "data-icon"
    end
  end

  describe "feature_card/1 inner_block slot" do
    test "renders extra content via inner_block" do
      html = render_component(&H.render_with_inner_block/1, %{})
      assert html =~ "Extra content"
    end
  end
end
