defmodule PhiaUi.Components.ProductCardTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.ProductCard

    attr :title, :string, default: "Wireless Headphones"
    attr :price, :string, default: "$79.99"
    attr :original_price, :string, default: nil
    attr :src, :string, default: nil
    attr :alt, :string, default: ""
    attr :rating, :float, default: nil
    attr :review_count, :integer, default: nil
    attr :badge, :string, default: nil
    attr :badge_variant, :atom, default: :default
    attr :sold_out, :boolean, default: false
    attr :href, :string, default: nil
    attr :on_add_to_cart, :string, default: nil
    attr :class, :string, default: nil

    def render_product_card(assigns) do
      ~H"""
      <.product_card
        title={@title}
        price={@price}
        original_price={@original_price}
        src={@src}
        alt={@alt}
        rating={@rating}
        review_count={@review_count}
        badge={@badge}
        badge_variant={@badge_variant}
        sold_out={@sold_out}
        href={@href}
        on_add_to_cart={@on_add_to_cart}
        class={@class}
      />
      """
    end

    def render_with_actions(assigns) do
      ~H"""
      <.product_card title="Widget" price="$9.99">
        <:actions>
          <button class="custom-action-btn">Buy now</button>
        </:actions>
      </.product_card>
      """
    end
  end

  defp render_product_card(attrs \\ %{}) do
    render_component(&H.render_product_card/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # Basic rendering
  # ---------------------------------------------------------------------------

  describe "product_card/1 basic rendering" do
    test "renders without errors" do
      html = render_product_card()
      assert html =~ "<div"
    end

    test "renders product title" do
      html = render_product_card(%{title: "Noise Cancelling Buds"})
      assert html =~ "Noise Cancelling Buds"
    end

    test "renders current price" do
      html = render_product_card(%{price: "$49.99"})
      assert html =~ "$49.99"
    end

    test "title has font-semibold styling" do
      html = render_product_card(%{title: "Widget"})
      assert html =~ "font-semibold"
    end

    test "price has font-bold styling" do
      html = render_product_card(%{price: "$19.99"})
      assert html =~ "font-bold"
    end
  end

  # ---------------------------------------------------------------------------
  # Original price / strikethrough
  # ---------------------------------------------------------------------------

  describe "product_card/1 original_price" do
    test "renders original price when provided" do
      html = render_product_card(%{price: "$49.99", original_price: "$79.99"})
      assert html =~ "$79.99"
    end

    test "original price has line-through styling" do
      html = render_product_card(%{price: "$49.99", original_price: "$79.99"})
      assert html =~ "line-through"
    end

    test "does not render original price element when nil" do
      html = render_product_card(%{price: "$49.99", original_price: nil})
      refute html =~ "line-through"
    end
  end

  # ---------------------------------------------------------------------------
  # Star rating
  # ---------------------------------------------------------------------------

  describe "product_card/1 rating stars" do
    test "renders 5 filled stars for rating 5.0" do
      html = render_product_card(%{rating: 5.0})
      assert html =~ "★★★★★"
    end

    test "renders 4 filled stars for rating 4.0" do
      html = render_product_card(%{rating: 4.0})
      assert html =~ "★★★★☆"
    end

    test "renders 3 filled stars for rating 3.0" do
      html = render_product_card(%{rating: 3.0})
      assert html =~ "★★★☆☆"
    end

    test "rounds 3.5 to 4 stars" do
      html = render_product_card(%{rating: 3.5})
      assert html =~ "★★★★☆"
    end

    test "rounds 4.4 to 4 stars" do
      html = render_product_card(%{rating: 4.4})
      assert html =~ "★★★★☆"
    end

    test "rounds 4.5 to 5 stars" do
      html = render_product_card(%{rating: 4.5})
      assert html =~ "★★★★★"
    end

    test "renders empty stars for 0.0 rating" do
      html = render_product_card(%{rating: 0.0})
      assert html =~ "☆☆☆☆☆"
    end

    test "renders review count when provided" do
      html = render_product_card(%{rating: 4.0, review_count: 128})
      assert html =~ "(128)"
    end

    test "review count has muted-foreground styling" do
      html = render_product_card(%{rating: 4.0, review_count: 42})
      assert html =~ "text-muted-foreground"
    end

    test "does not render rating section when rating is nil" do
      html = render_product_card(%{rating: nil})
      refute html =~ "★"
      refute html =~ "☆"
    end
  end

  # ---------------------------------------------------------------------------
  # Sold out
  # ---------------------------------------------------------------------------

  describe "product_card/1 sold_out" do
    test "shows Sold Out badge when sold_out=true" do
      html = render_product_card(%{sold_out: true})
      assert html =~ "Sold Out"
    end

    test "button is disabled when sold_out=true" do
      html = render_product_card(%{sold_out: true})
      assert html =~ "disabled"
    end

    test "does not show Sold Out badge when sold_out=false" do
      html = render_product_card(%{sold_out: false})
      refute html =~ "Sold Out"
    end
  end

  # ---------------------------------------------------------------------------
  # Badge overlay
  # ---------------------------------------------------------------------------

  describe "product_card/1 badge" do
    test "renders badge label when provided" do
      html = render_product_card(%{badge: "New"})
      assert html =~ "New"
    end

    test "does not render badge when nil" do
      html = render_product_card(%{badge: nil})
      # Check that no badge overlay element appears (button has bg-primary but badge label should not)
      refute html =~ "absolute top-2 left-2"
    end
  end

  # ---------------------------------------------------------------------------
  # Actions slot
  # ---------------------------------------------------------------------------

  describe "product_card/1 :actions slot" do
    test "renders custom actions slot content" do
      html = render_component(&H.render_with_actions/1, %{})
      assert html =~ "Buy now"
      assert html =~ "custom-action-btn"
    end

    test "renders default Add to cart button when no actions slot" do
      html = render_product_card()
      assert html =~ "Add to cart"
    end

    test "default button is absent when actions slot is provided" do
      html = render_component(&H.render_with_actions/1, %{})
      refute html =~ "Add to cart"
    end
  end

  # ---------------------------------------------------------------------------
  # Image and href
  # ---------------------------------------------------------------------------

  describe "product_card/1 image and href" do
    test "renders image when src provided" do
      html = render_product_card(%{src: "/images/product.jpg", alt: "Headphones"})
      assert html =~ ~s(src="/images/product.jpg")
      assert html =~ ~s(alt="Headphones")
    end

    test "wraps image in anchor when href provided" do
      html = render_product_card(%{href: "/products/1"})
      assert html =~ ~s(href="/products/1")
    end
  end

  # ---------------------------------------------------------------------------
  # Class forwarding
  # ---------------------------------------------------------------------------

  describe "product_card/1 class forwarding" do
    test "accepts custom class" do
      html = render_product_card(%{class: "my-product"})
      assert html =~ "my-product"
    end
  end
end
