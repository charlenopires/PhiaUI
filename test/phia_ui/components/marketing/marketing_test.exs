defmodule PhiaUi.Components.MarketingTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Marketing

    # ── pricing_table ──────────────────────────────────────────────────────────

    def render_pricing_table(assigns) do
      ~H"""
      <.pricing_table
        title={assigns[:title]}
        description={assigns[:description]}
        columns={assigns[:columns] || 3}
        class={assigns[:class]}
      >
        <:toggle :if={assigns[:toggle_text]}>{assigns[:toggle_text]}</:toggle>
        {assigns[:content] || "Tier cards"}
        <:footer :if={assigns[:footer_text]}>{assigns[:footer_text]}</:footer>
      </.pricing_table>
      """
    end

    # ── cta_section ────────────────────────────────────────────────────────────

    def render_cta_section(assigns) do
      ~H"""
      <.cta_section
        title={assigns[:title] || "Get Started"}
        description={assigns[:description]}
        variant={assigns[:variant] || :default}
        align={assigns[:align] || :center}
        class={assigns[:class]}
      >
        <:actions :if={assigns[:actions_text]}>{assigns[:actions_text]}</:actions>
        <:media :if={assigns[:media_text]}>{assigns[:media_text]}</:media>
      </.cta_section>
      """
    end

    # ── newsletter_cta ─────────────────────────────────────────────────────────

    def render_newsletter_cta(assigns) do
      ~H"""
      <.newsletter_cta
        title={assigns[:title]}
        description={assigns[:description]}
        placeholder={assigns[:placeholder] || "Enter your email"}
        button_label={assigns[:button_label] || "Subscribe"}
        on_submit={assigns[:on_submit] || "subscribe"}
        input_name={assigns[:input_name] || "email"}
        layout={assigns[:layout] || :inline}
        class={assigns[:class]}
      >
        <:disclaimer :if={assigns[:disclaimer_text]}>{assigns[:disclaimer_text]}</:disclaimer>
      </.newsletter_cta>
      """
    end

    # ── logo_cloud ─────────────────────────────────────────────────────────────

    def render_logo_cloud(assigns) do
      ~H"""
      <.logo_cloud
        title={assigns[:title]}
        layout={assigns[:layout] || :inline}
        columns={assigns[:columns] || 5}
        grayscale={assigns[:grayscale] || false}
        class={assigns[:class]}
      >
        {assigns[:content] || "Logo images"}
      </.logo_cloud>
      """
    end

    # ── site_footer ────────────────────────────────────────────────────────────

    def render_site_footer(assigns) do
      ~H"""
      <.site_footer class={assigns[:class]}>
        <:logo :if={assigns[:logo_text]}>{assigns[:logo_text]}</:logo>
        <:columns :if={assigns[:col1_title]} title={assigns[:col1_title]}>
          {assigns[:col1_content] || "Links"}
        </:columns>
        <:columns :if={assigns[:col2_title]} title={assigns[:col2_title]}>
          {assigns[:col2_content] || "More links"}
        </:columns>
        <:social :if={assigns[:social_text]}>{assigns[:social_text]}</:social>
        <:bottom :if={assigns[:bottom_text]}>{assigns[:bottom_text]}</:bottom>
      </.site_footer>
      """
    end
  end

  # ── Helper shortcuts ───────────────────────────────────────────────────────

  defp render_pricing_table(attrs \\ %{}), do: render_component(&H.render_pricing_table/1, attrs)
  defp render_cta_section(attrs \\ %{}), do: render_component(&H.render_cta_section/1, attrs)
  defp render_newsletter_cta(attrs \\ %{}), do: render_component(&H.render_newsletter_cta/1, attrs)
  defp render_logo_cloud(attrs \\ %{}), do: render_component(&H.render_logo_cloud/1, attrs)
  defp render_site_footer(attrs \\ %{}), do: render_component(&H.render_site_footer/1, attrs)

  # =========================================================================
  # pricing_table/1
  # =========================================================================

  describe "pricing_table/1" do
    test "renders inner_block content" do
      html = render_pricing_table(%{content: "Pro Plan"})
      assert html =~ "Pro Plan"
    end

    test "renders title when provided" do
      html = render_pricing_table(%{title: "Pricing"})
      assert html =~ "Pricing"
      assert html =~ "<h2"
    end

    test "renders description when provided" do
      html = render_pricing_table(%{description: "Choose a plan."})
      assert html =~ "Choose a plan."
      assert html =~ "text-muted-foreground"
    end

    test "does not render header when no title or description" do
      html = render_pricing_table(%{title: nil, description: nil})
      refute html =~ "mb-10"
    end

    test "toggle slot renders" do
      html = render_pricing_table(%{toggle_text: "Monthly / Yearly"})
      assert html =~ "Monthly / Yearly"
      assert html =~ "justify-center"
    end

    test "footer slot renders" do
      html = render_pricing_table(%{footer_text: "All plans include support."})
      assert html =~ "All plans include support."
      assert html =~ "mt-12"
    end

    test "default 3 columns renders lg:grid-cols-3" do
      assert render_pricing_table() =~ "lg:grid-cols-3"
    end

    test "2 columns renders md:grid-cols-2" do
      html = render_pricing_table(%{columns: 2})
      assert html =~ "md:grid-cols-2"
      assert html =~ "max-w-4xl"
    end

    test "custom class is applied" do
      assert render_pricing_table(%{class: "my-pricing"}) =~ "my-pricing"
    end

    test "renders section element" do
      assert render_pricing_table() =~ "<section"
    end
  end

  # =========================================================================
  # cta_section/1
  # =========================================================================

  describe "cta_section/1" do
    test "renders title" do
      html = render_cta_section(%{title: "Join Now"})
      assert html =~ "Join Now"
      assert html =~ "<h2"
    end

    test "renders description when provided" do
      html = render_cta_section(%{description: "Start for free."})
      assert html =~ "Start for free."
    end

    test "does not render description when nil" do
      html = render_cta_section(%{description: nil})
      refute html =~ "mt-4 text-lg"
    end

    test "default variant has border and bg-card" do
      html = render_cta_section(%{variant: :default})
      assert html =~ "border-border"
      assert html =~ "bg-card"
    end

    test "filled variant uses bg-primary" do
      assert render_cta_section(%{variant: :filled}) =~ "bg-primary"
    end

    test "gradient variant uses bg-gradient-to-br" do
      assert render_cta_section(%{variant: :gradient}) =~ "bg-gradient-to-br"
    end

    test "filled variant title uses text-primary-foreground" do
      assert render_cta_section(%{variant: :filled}) =~ "text-primary-foreground"
    end

    test "center align renders text-center" do
      assert render_cta_section(%{align: :center}) =~ "text-center"
    end

    test "split align renders grid with lg:grid-cols-2" do
      html = render_cta_section(%{align: :split})
      assert html =~ "grid"
      assert html =~ "lg:grid-cols-2"
    end

    test "actions slot renders" do
      html = render_cta_section(%{actions_text: "Sign Up"})
      assert html =~ "Sign Up"
    end

    test "media slot renders" do
      html = render_cta_section(%{media_text: "CTA image"})
      assert html =~ "CTA image"
    end

    test "custom class is applied" do
      assert render_cta_section(%{class: "my-cta"}) =~ "my-cta"
    end

    test "renders section element with rounded-xl" do
      html = render_cta_section()
      assert html =~ "<section"
      assert html =~ "rounded-xl"
    end
  end

  # =========================================================================
  # newsletter_cta/1
  # =========================================================================

  describe "newsletter_cta/1" do
    test "renders email input" do
      html = render_newsletter_cta()
      assert html =~ "<input"
      assert html =~ ~s(type="email")
    end

    test "renders submit button with default label" do
      html = render_newsletter_cta()
      assert html =~ "Subscribe"
      assert html =~ ~s(type="submit")
    end

    test "custom button label renders" do
      assert render_newsletter_cta(%{button_label: "Join"}) =~ "Join"
    end

    test "renders title when provided" do
      html = render_newsletter_cta(%{title: "Stay Updated"})
      assert html =~ "Stay Updated"
      assert html =~ "<h3"
    end

    test "renders description when provided" do
      html = render_newsletter_cta(%{description: "Weekly digest."})
      assert html =~ "Weekly digest."
    end

    test "default placeholder renders" do
      assert render_newsletter_cta() =~ "Enter your email"
    end

    test "custom placeholder renders" do
      assert render_newsletter_cta(%{placeholder: "you@example.com"}) =~ "you@example.com"
    end

    test "inline layout renders flex" do
      html = render_newsletter_cta(%{layout: :inline})
      assert html =~ "flex gap-2"
    end

    test "stacked layout renders flex-col" do
      html = render_newsletter_cta(%{layout: :stacked})
      assert html =~ "flex-col"
    end

    test "disclaimer slot renders" do
      html = render_newsletter_cta(%{disclaimer_text: "No spam."})
      assert html =~ "No spam."
      assert html =~ "text-xs"
    end

    test "form has phx-submit" do
      assert render_newsletter_cta(%{on_submit: "do_subscribe"}) =~ "do_subscribe"
    end

    test "custom input_name renders" do
      assert render_newsletter_cta(%{input_name: "user_email"}) =~ "user_email"
    end

    test "custom class is applied" do
      assert render_newsletter_cta(%{class: "my-newsletter"}) =~ "my-newsletter"
    end

    test "renders section element" do
      assert render_newsletter_cta() =~ "<section"
    end
  end

  # =========================================================================
  # logo_cloud/1
  # =========================================================================

  describe "logo_cloud/1" do
    test "renders inner_block content" do
      html = render_logo_cloud(%{content: "Acme Logo"})
      assert html =~ "Acme Logo"
    end

    test "renders title when provided" do
      html = render_logo_cloud(%{title: "Trusted by"})
      assert html =~ "Trusted by"
      assert html =~ "text-muted-foreground"
    end

    test "does not render title when nil" do
      html = render_logo_cloud(%{title: nil})
      refute html =~ "mb-8"
    end

    test "inline layout renders flex" do
      html = render_logo_cloud(%{layout: :inline})
      assert html =~ "flex"
      assert html =~ "flex-wrap"
    end

    test "grid layout renders grid" do
      html = render_logo_cloud(%{layout: :grid})
      assert html =~ "grid"
    end

    test "grayscale applies grayscale class" do
      assert render_logo_cloud(%{grayscale: true}) =~ "grayscale"
    end

    test "no grayscale by default" do
      refute render_logo_cloud() =~ "grayscale"
    end

    test "custom class is applied" do
      assert render_logo_cloud(%{class: "my-logos"}) =~ "my-logos"
    end

    test "renders section element" do
      assert render_logo_cloud() =~ "<section"
    end
  end

  # =========================================================================
  # site_footer/1
  # =========================================================================

  describe "site_footer/1" do
    test "renders footer element" do
      assert render_site_footer() =~ "<footer"
    end

    test "has border-t" do
      assert render_site_footer() =~ "border-t"
    end

    test "logo slot renders" do
      html = render_site_footer(%{logo_text: "PhiaUI"})
      assert html =~ "PhiaUI"
    end

    test "columns render with titles" do
      html = render_site_footer(%{col1_title: "Product", col2_title: "Company"})
      assert html =~ "Product"
      assert html =~ "Company"
      assert html =~ "<h4"
    end

    test "columns render content" do
      html = render_site_footer(%{col1_title: "Product", col1_content: "Features link"})
      assert html =~ "Features link"
    end

    test "social slot renders" do
      html = render_site_footer(%{social_text: "Twitter icon"})
      assert html =~ "Twitter icon"
    end

    test "bottom slot renders with border-t" do
      html = render_site_footer(%{bottom_text: "2026 Acme Inc."})
      assert html =~ "2026 Acme Inc."
    end

    test "custom class is applied" do
      assert render_site_footer(%{class: "my-footer"}) =~ "my-footer"
    end

    test "column count affects grid columns" do
      html = render_site_footer(%{col1_title: "A", col2_title: "B"})
      assert html =~ "grid-cols-2"
    end

    test "renders without any slots" do
      html = render_site_footer()
      assert html =~ "<footer"
      assert html =~ "border-border"
    end
  end
end
