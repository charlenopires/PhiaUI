defmodule PhiaUi.Components.CtaCardTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.CtaCard

    attr :title, :string, default: "Get Started"
    attr :description, :string, default: nil
    attr :variant, :atom, default: :default
    attr :align, :atom, default: :center
    attr :class, :string, default: nil

    def render_cta_card(assigns) do
      ~H"""
      <.cta_card
        title={@title}
        description={@description}
        variant={@variant}
        align={@align}
        class={@class}
      />
      """
    end

    attr :title, :string, default: "Upgrade Now"

    def render_with_illustration(assigns) do
      ~H"""
      <.cta_card title={@title}>
        <:illustration><span data-illustration>*</span></:illustration>
      </.cta_card>
      """
    end

    attr :title, :string, default: "Sign Up"

    def render_with_actions(assigns) do
      ~H"""
      <.cta_card title={@title}>
        <:actions><button data-action>Click me</button></:actions>
      </.cta_card>
      """
    end

    attr :title, :string, default: "Subscribe"

    def render_with_footer(assigns) do
      ~H"""
      <.cta_card title={@title}>
        <:footer><span data-footer>No credit card required</span></:footer>
      </.cta_card>
      """
    end
  end

  defp render_cta_card(attrs \\ %{}) do
    render_component(&H.render_cta_card/1, attrs)
  end

  describe "cta_card/1 basic rendering" do
    test "renders the title" do
      assert render_cta_card(%{title: "Get Started"}) =~ "Get Started"
    end

    test "renders description when provided" do
      assert render_cta_card(%{description: "Sign up today"}) =~ "Sign up today"
    end

    test "does not render description when nil" do
      html = render_cta_card()
      refute html =~ "text-muted-foreground"
    end

    test "accepts custom class" do
      assert render_cta_card(%{class: "my-custom"}) =~ "my-custom"
    end

    test "title has font-semibold" do
      assert render_cta_card() =~ "font-semibold"
    end
  end

  describe "cta_card/1 variants" do
    test ":default applies border and shadow-sm and bg-card" do
      html = render_cta_card(%{variant: :default})
      assert html =~ "border"
      assert html =~ "shadow-sm"
      assert html =~ "bg-card"
    end

    test ":bordered applies border-2 and bg-card" do
      html = render_cta_card(%{variant: :bordered})
      assert html =~ "border-2"
      assert html =~ "bg-card"
    end

    test ":bordered does not apply shadow-sm" do
      html = render_cta_card(%{variant: :bordered})
      refute html =~ "shadow-sm"
    end

    test ":filled applies bg-muted" do
      html = render_cta_card(%{variant: :filled})
      assert html =~ "bg-muted"
    end

    test ":minimal uses a plain div (no bg-card)" do
      html = render_cta_card(%{variant: :minimal})
      refute html =~ "bg-card"
    end

    test ":minimal still renders the title" do
      html = render_cta_card(%{variant: :minimal, title: "Go minimal"})
      assert html =~ "Go minimal"
    end
  end

  describe "cta_card/1 alignment" do
    test ":center applies text-center and items-center" do
      html = render_cta_card(%{align: :center})
      assert html =~ "text-center"
      assert html =~ "items-center"
    end

    test ":start applies text-start and items-start" do
      html = render_cta_card(%{align: :start})
      assert html =~ "text-start"
      assert html =~ "items-start"
    end
  end

  describe "cta_card/1 slots" do
    test "renders illustration slot" do
      html = render_component(&H.render_with_illustration/1, %{})
      assert html =~ "data-illustration"
    end

    test "renders actions slot" do
      html = render_component(&H.render_with_actions/1, %{})
      assert html =~ "data-action"
      assert html =~ "Click me"
    end

    test "renders footer slot" do
      html = render_component(&H.render_with_footer/1, %{})
      assert html =~ "data-footer"
      assert html =~ "No credit card required"
    end

    test "does not render illustration wrapper when slot is empty" do
      html = render_cta_card()
      refute html =~ "data-illustration"
    end

    test "does not render actions wrapper when slot is empty" do
      html = render_cta_card()
      refute html =~ "data-action"
    end

    test "does not render footer wrapper when slot is empty" do
      html = render_cta_card()
      refute html =~ "data-footer"
    end
  end
end
