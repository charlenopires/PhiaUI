defmodule PhiaUi.Components.CardTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helper — renders each Card sub-component via wrapper functions
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Card

    def render_card(assigns) do
      ~H"""
      <.card class={@class}>Content</.card>
      """
    end

    def render_card_header(assigns) do
      ~H"""
      <.card_header class={@class}>Header</.card_header>
      """
    end

    def render_card_title(assigns) do
      ~H"""
      <.card_title class={@class}>Title</.card_title>
      """
    end

    def render_card_description(assigns) do
      ~H"""
      <.card_description class={@class}>Description</.card_description>
      """
    end

    def render_card_content(assigns) do
      ~H"""
      <.card_content class={@class}>Content</.card_content>
      """
    end

    def render_card_footer(assigns) do
      ~H"""
      <.card_footer class={@class}>Footer</.card_footer>
      """
    end

    def render_composition(assigns) do
      ~H"""
      <.card>
        <.card_header>
          <.card_title>Account Balance</.card_title>
          <.card_description>Your current balance</.card_description>
        </.card_header>
        <.card_content>
          <p>$12,340.00</p>
        </.card_content>
        <.card_footer>
          <span>Last updated: today</span>
        </.card_footer>
      </.card>
      """
    end

    def render_card_with_rest(assigns) do
      ~H"""
      <.card data-testid="my-card">Content</.card>
      """
    end

    def render_card_sm(assigns) do
      ~H"""
      <.card size="sm">Content</.card>
      """
    end

    def render_card_action(assigns) do
      ~H"""
      <.card>
        <.card_header>
          <.card_title>Title</.card_title>
          <.card_action>
            <button>Edit</button>
          </.card_action>
        </.card_header>
      </.card>
      """
    end

    def render_card_action_with_class(assigns) do
      ~H"""
      <.card>
        <.card_header>
          <.card_action class="custom-action">Edit</.card_action>
        </.card_header>
      </.card>
      """
    end
  end

  defp render_sub(fun, attrs \\ %{class: nil}) do
    render_component(fun, attrs)
  end

  # ---------------------------------------------------------------------------
  # card/1
  # ---------------------------------------------------------------------------

  describe "card/1" do
    test "renders a div element" do
      html = render_sub(&H.render_card/1)
      assert html =~ "<div"
    end

    test "has rounded-lg" do
      html = render_sub(&H.render_card/1)
      assert html =~ "rounded-lg"
    end

    test "has border" do
      html = render_sub(&H.render_card/1)
      assert html =~ "border"
    end

    test "has bg-card" do
      html = render_sub(&H.render_card/1)
      assert html =~ "bg-card"
    end

    test "has text-card-foreground" do
      html = render_sub(&H.render_card/1)
      assert html =~ "text-card-foreground"
    end

    test "has shadow" do
      html = render_sub(&H.render_card/1)
      assert html =~ "shadow"
    end

    test "renders inner content" do
      html = render_sub(&H.render_card/1)
      assert html =~ "Content"
    end

    test "accepts custom class" do
      html = render_sub(&H.render_card/1, %{class: "my-custom"})
      assert html =~ "my-custom"
    end

    test "passes @rest attributes" do
      html = render_component(&H.render_card_with_rest/1, %{})
      assert html =~ ~s(data-testid="my-card")
    end
  end

  # ---------------------------------------------------------------------------
  # card_header/1
  # ---------------------------------------------------------------------------

  describe "card_header/1" do
    test "renders a div element" do
      html = render_sub(&H.render_card_header/1)
      assert html =~ "<div"
    end

    test "has flex flex-col" do
      html = render_sub(&H.render_card_header/1)
      assert html =~ "flex"
      assert html =~ "flex-col"
    end

    test "has space-y-1.5" do
      html = render_sub(&H.render_card_header/1)
      assert html =~ "space-y-1.5"
    end

    test "has p-6" do
      html = render_sub(&H.render_card_header/1)
      assert html =~ "p-6"
    end

    test "accepts custom class" do
      html = render_sub(&H.render_card_header/1, %{class: "extra"})
      assert html =~ "extra"
    end
  end

  # ---------------------------------------------------------------------------
  # card_title/1
  # ---------------------------------------------------------------------------

  describe "card_title/1" do
    test "renders an h3 element" do
      html = render_sub(&H.render_card_title/1)
      assert html =~ "<h3"
    end

    test "has font-semibold" do
      html = render_sub(&H.render_card_title/1)
      assert html =~ "font-semibold"
    end

    test "has leading-none" do
      html = render_sub(&H.render_card_title/1)
      assert html =~ "leading-none"
    end

    test "has tracking-tight" do
      html = render_sub(&H.render_card_title/1)
      assert html =~ "tracking-tight"
    end

    test "accepts custom class" do
      html = render_sub(&H.render_card_title/1, %{class: "text-xl"})
      assert html =~ "text-xl"
    end
  end

  # ---------------------------------------------------------------------------
  # card_description/1
  # ---------------------------------------------------------------------------

  describe "card_description/1" do
    test "renders a p element" do
      html = render_sub(&H.render_card_description/1)
      assert html =~ "<p"
    end

    test "has text-sm" do
      html = render_sub(&H.render_card_description/1)
      assert html =~ "text-sm"
    end

    test "has text-muted-foreground" do
      html = render_sub(&H.render_card_description/1)
      assert html =~ "text-muted-foreground"
    end

    test "accepts custom class" do
      html = render_sub(&H.render_card_description/1, %{class: "italic"})
      assert html =~ "italic"
    end
  end

  # ---------------------------------------------------------------------------
  # card_content/1
  # ---------------------------------------------------------------------------

  describe "card_content/1" do
    test "renders a div element" do
      html = render_sub(&H.render_card_content/1)
      assert html =~ "<div"
    end

    test "has p-6" do
      html = render_sub(&H.render_card_content/1)
      assert html =~ "p-6"
    end

    test "has pt-0" do
      html = render_sub(&H.render_card_content/1)
      assert html =~ "pt-0"
    end

    test "accepts custom class" do
      html = render_sub(&H.render_card_content/1, %{class: "overflow-auto"})
      assert html =~ "overflow-auto"
    end
  end

  # ---------------------------------------------------------------------------
  # card_footer/1
  # ---------------------------------------------------------------------------

  describe "card_footer/1" do
    test "renders a div element" do
      html = render_sub(&H.render_card_footer/1)
      assert html =~ "<div"
    end

    test "has flex items-center" do
      html = render_sub(&H.render_card_footer/1)
      assert html =~ "flex"
      assert html =~ "items-center"
    end

    test "has p-6 pt-0" do
      html = render_sub(&H.render_card_footer/1)
      assert html =~ "p-6"
      assert html =~ "pt-0"
    end

    test "accepts custom class" do
      html = render_sub(&H.render_card_footer/1, %{class: "justify-between"})
      assert html =~ "justify-between"
    end
  end

  # ---------------------------------------------------------------------------
  # card/1 — size variant
  # ---------------------------------------------------------------------------

  describe "card/1 — size variant" do
    test "default size renders without max-w-sm constraint" do
      html = render_sub(&H.render_card/1)
      refute html =~ "max-w-sm"
    end

    test "size='sm' adds max-w-sm class" do
      html = render_component(&H.render_card_sm/1, %{})
      assert html =~ "max-w-sm"
    end

    test "size='sm' still renders content" do
      html = render_component(&H.render_card_sm/1, %{})
      assert html =~ "Content"
    end
  end

  # ---------------------------------------------------------------------------
  # card_action/1
  # ---------------------------------------------------------------------------

  describe "card_action/1" do
    test "card_action/1 is exported" do
      assert function_exported?(PhiaUi.Components.Card, :card_action, 1)
    end

    test "renders a div element" do
      html = render_component(&H.render_card_action/1, %{})
      assert html =~ "<div"
    end

    test "is positioned absolutely" do
      html = render_component(&H.render_card_action/1, %{})
      assert html =~ "absolute"
    end

    test "is anchored to top-right" do
      html = render_component(&H.render_card_action/1, %{})
      assert html =~ "right-"
      assert html =~ "top-"
    end

    test "renders inner content" do
      html = render_component(&H.render_card_action/1, %{})
      assert html =~ "Edit"
    end

    test "accepts :class override" do
      html = render_component(&H.render_card_action_with_class/1, %{})
      assert html =~ "custom-action"
    end
  end

  # ---------------------------------------------------------------------------
  # card_header/1 — relative positioning for card_action anchor
  # ---------------------------------------------------------------------------

  describe "card_header/1 — relative for card_action" do
    test "card_header has relative class" do
      html = render_sub(&H.render_card_header/1)
      assert html =~ "relative"
    end
  end

  # ---------------------------------------------------------------------------
  # Composition
  # ---------------------------------------------------------------------------

  describe "composition" do
    test "all 6 sub-components compose correctly" do
      html = render_component(&H.render_composition/1, %{})
      assert html =~ "Account Balance"
      assert html =~ "Your current balance"
      assert html =~ "$12,340.00"
      assert html =~ "Last updated: today"
      assert html =~ "bg-card"
      assert html =~ "font-semibold"
      assert html =~ "text-muted-foreground"
    end
  end
end
