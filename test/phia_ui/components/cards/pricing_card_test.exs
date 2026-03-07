defmodule PhiaUi.Components.PricingCardTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.PricingCard

    attr :plan, :string, default: "Pro"
    attr :price, :string, default: "$29"
    attr :period, :string, default: "/month"
    attr :description, :string, default: nil
    attr :features, :list, default: []
    attr :highlighted, :boolean, default: false
    attr :badge, :string, default: nil
    attr :cta_label, :string, default: "Get started"
    attr :cta_href, :string, default: nil
    attr :disabled, :boolean, default: false
    attr :class, :string, default: nil

    def render_pricing_card(assigns) do
      ~H"""
      <.pricing_card
        plan={@plan}
        price={@price}
        period={@period}
        description={@description}
        features={@features}
        highlighted={@highlighted}
        badge={@badge}
        cta_label={@cta_label}
        cta_href={@cta_href}
        disabled={@disabled}
        class={@class}
      />
      """
    end

    def render_with_header_extra(assigns) do
      ~H"""
      <.pricing_card plan="Pro" price="$29">
        <:header_extra>
          <span class="trial-note">14-day free trial</span>
        </:header_extra>
      </.pricing_card>
      """
    end

    def render_with_footer(assigns) do
      ~H"""
      <.pricing_card plan="Pro" price="$29">
        <:footer>
          <span class="footer-note">No credit card required</span>
        </:footer>
      </.pricing_card>
      """
    end
  end

  defp render_pricing_card(attrs \\ %{}) do
    render_component(&H.render_pricing_card/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # Basic rendering
  # ---------------------------------------------------------------------------

  describe "pricing_card/1 basic rendering" do
    test "renders without errors" do
      html = render_pricing_card()
      assert html =~ "<div"
    end

    test "renders plan name" do
      html = render_pricing_card(%{plan: "Enterprise"})
      assert html =~ "Enterprise"
    end

    test "renders price" do
      html = render_pricing_card(%{price: "$99"})
      assert html =~ "$99"
    end

    test "renders period" do
      html = render_pricing_card(%{period: "/year"})
      assert html =~ "/year"
    end

    test "default period is /month" do
      html = render_pricing_card()
      assert html =~ "/month"
    end

    test "price is displayed with text-4xl font-bold" do
      html = render_pricing_card(%{price: "$29"})
      assert html =~ "text-4xl"
      assert html =~ "font-bold"
    end

    test "renders description when provided" do
      html = render_pricing_card(%{description: "For growing teams"})
      assert html =~ "For growing teams"
    end

    test "does not render description element when nil" do
      html = render_pricing_card(%{description: nil})
      refute html =~ "For growing teams"
    end
  end

  # ---------------------------------------------------------------------------
  # Highlighted
  # ---------------------------------------------------------------------------

  describe "pricing_card/1 highlighted" do
    test "applies ring-2 ring-primary when highlighted=true" do
      html = render_pricing_card(%{highlighted: true})
      assert html =~ "ring-2"
      assert html =~ "ring-primary"
    end

    test "applies bg-primary/5 when highlighted=true" do
      html = render_pricing_card(%{highlighted: true})
      assert html =~ "bg-primary/5"
    end

    test "does not apply ring classes when highlighted=false" do
      html = render_pricing_card(%{highlighted: false})
      # ring-2 ring-primary is the highlighted combo; button has focus-visible:ring-2 which is different
      refute html =~ "ring-2 ring-primary"
    end
  end

  # ---------------------------------------------------------------------------
  # Features list
  # ---------------------------------------------------------------------------

  describe "pricing_card/1 features list" do
    test "renders available feature text" do
      html = render_pricing_card(%{features: ["Unlimited projects"]})
      assert html =~ "Unlimited projects"
    end

    test "renders check-circle icon for available features" do
      html = render_pricing_card(%{features: ["API access"]})
      assert html =~ "icon-check-circle"
    end

    test "renders multiple features" do
      html = render_pricing_card(%{features: ["Feature A", "Feature B", "Feature C"]})
      assert html =~ "Feature A"
      assert html =~ "Feature B"
      assert html =~ "Feature C"
    end

    test "renders unavailable feature with — prefix" do
      html = render_pricing_card(%{features: ["— Priority support"]})
      assert html =~ "Priority support"
    end

    test "strips — prefix from unavailable feature text" do
      html = render_pricing_card(%{features: ["— Custom domain"]})
      refute html =~ "— Custom domain"
      assert html =~ "Custom domain"
    end

    test "unavailable feature does not show check-circle icon" do
      html = render_pricing_card(%{features: ["— Advanced analytics"]})
      # The check-circle icon is inside a :if={feature_available(feature)} span
      # We can check that the icon-check-circle is absent when only unavailable features
      refute html =~ "icon-check-circle"
    end

    test "mixed available and unavailable features" do
      html = render_pricing_card(%{features: ["Included feature", "— Excluded feature"]})
      assert html =~ "Included feature"
      assert html =~ "Excluded feature"
      assert html =~ "icon-check-circle"
    end

    test "renders empty features list" do
      html = render_pricing_card(%{features: []})
      assert html =~ "<ul"
    end
  end

  # ---------------------------------------------------------------------------
  # Badge
  # ---------------------------------------------------------------------------

  describe "pricing_card/1 badge" do
    test "renders badge when provided" do
      html = render_pricing_card(%{badge: "Most Popular"})
      assert html =~ "Most Popular"
    end

    test "does not render badge element when nil" do
      html = render_pricing_card(%{badge: nil})
      refute html =~ "Most Popular"
    end
  end

  # ---------------------------------------------------------------------------
  # CTA button
  # ---------------------------------------------------------------------------

  describe "pricing_card/1 CTA" do
    test "renders default CTA label" do
      html = render_pricing_card()
      assert html =~ "Get started"
    end

    test "renders custom CTA label" do
      html = render_pricing_card(%{cta_label: "Start free trial"})
      assert html =~ "Start free trial"
    end

    test "wraps button in anchor when cta_href provided" do
      html = render_pricing_card(%{cta_href: "/signup"})
      assert html =~ ~s(href="/signup")
    end

    test "does not render anchor when cta_href is nil" do
      html = render_pricing_card(%{cta_href: nil})
      refute html =~ ~s(href=)
    end

    test "disabled button when disabled=true" do
      html = render_pricing_card(%{disabled: true})
      assert html =~ "disabled"
    end
  end

  # ---------------------------------------------------------------------------
  # Slots
  # ---------------------------------------------------------------------------

  describe "pricing_card/1 :header_extra slot" do
    test "renders header_extra slot content" do
      html = render_component(&H.render_with_header_extra/1, %{})
      assert html =~ "14-day free trial"
      assert html =~ "trial-note"
    end
  end

  describe "pricing_card/1 :footer slot" do
    test "renders footer slot content" do
      html = render_component(&H.render_with_footer/1, %{})
      assert html =~ "No credit card required"
      assert html =~ "footer-note"
    end
  end

  # ---------------------------------------------------------------------------
  # Class forwarding
  # ---------------------------------------------------------------------------

  describe "pricing_card/1 class forwarding" do
    test "accepts custom class" do
      html = render_pricing_card(%{class: "my-pricing-card"})
      assert html =~ "my-pricing-card"
    end
  end
end
