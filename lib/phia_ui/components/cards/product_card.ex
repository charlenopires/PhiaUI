defmodule PhiaUi.Components.ProductCard do
  @moduledoc """
  E-commerce product card with image, rating, pricing, and add-to-cart action.

  Renders a `Card` with an optional product image (square aspect ratio),
  an optional badge overlay (top-left), product title, price row, star
  rating, and action buttons.

  ## Image handling

  - When `src` is provided, renders an `<img>` with `aspect-square object-cover`.
  - When `src` is `nil`, renders a muted placeholder box.
  - Both the image and title are wrapped in an `<a>` link when `href` is provided.

  ## Badge overlay

  Set `badge` to show a label over the top-left corner of the image
  (e.g. `"Sale"`, `"New"`). The badge is hidden when `sold_out={true}`;
  instead a `"Sold Out"` secondary badge is shown automatically.

  ## Star rating

  Pass a `rating` float between `0.0` and `5.0` to render a star row
  style. Provide `review_count` to append the count in parentheses.

  ## Sold-out state

  When `sold_out={true}`, a `"Sold Out"` badge overlay is shown and the
  add-to-cart button is disabled.

  ## Custom actions slot

  Override the default add-to-cart button via the `:actions` slot when you
  need a different CTA (e.g. "View details" or "Add to wishlist"):

      <.product_card title="Widget" price="$9" src="/img/widget.jpg">
        <:actions>
          <.button variant={:outline} class="w-full">View details</.button>
        </:actions>
      </.product_card>
  """

  use Phoenix.Component

  import PhiaUi.Components.Card
  import PhiaUi.Components.Badge
  import PhiaUi.Components.Button, only: [button: 1]
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:title, :string, required: true, doc: "Product title")
  attr(:price, :string, required: true, doc: "Current price string")
  attr(:original_price, :string, default: nil, doc: "Original/strikethrough price")
  attr(:src, :string, default: nil, doc: "Product image URL")
  attr(:alt, :string, default: "", doc: "Image alt text")
  attr(:rating, :float, default: nil, doc: "Star rating 0.0–5.0")
  attr(:review_count, :integer, default: nil, doc: "Number of reviews")
  attr(:badge, :string, default: nil, doc: "Optional badge label on image")

  attr(:badge_variant, :atom,
    default: :default,
    values: [:default, :destructive, :secondary, :outline],
    doc: "Badge color variant"
  )

  attr(:sold_out, :boolean, default: false, doc: "Show sold-out overlay and disable button")
  attr(:href, :string, default: nil, doc: "Optional link for image and title")
  attr(:on_add_to_cart, :string, default: nil, doc: "phx-click event for add-to-cart button")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the card element")

  slot(:actions, doc: "Override the default add-to-cart button")

  @doc "Renders a product card."
  def product_card(assigns) do
    ~H"""
    <.card class={cn(["overflow-hidden", @class])} {@rest}>
      <%!-- Image block --%>
      <div class="relative">
        <a :if={@href} href={@href}>
          <img
            :if={@src}
            src={@src}
            alt={@alt}
            class="w-full aspect-square object-cover"
          />
          <div :if={!@src} class="w-full aspect-square bg-muted flex items-center justify-center">
            <span class="text-muted-foreground text-sm">No image</span>
          </div>
        </a>
        <div :if={!@href}>
          <img
            :if={@src}
            src={@src}
            alt={@alt}
            class="w-full aspect-square object-cover"
          />
          <div :if={!@src} class="w-full aspect-square bg-muted flex items-center justify-center">
            <span class="text-muted-foreground text-sm">No image</span>
          </div>
        </div>

        <%!-- Badge overlay top-left --%>
        <div :if={@badge && !@sold_out} class="absolute top-2 left-2">
          <.badge variant={@badge_variant}>{@badge}</.badge>
        </div>

        <%!-- Sold out overlay --%>
        <div :if={@sold_out} class="absolute top-2 left-2">
          <.badge variant={:secondary}>Sold Out</.badge>
        </div>
      </div>

      <.card_content class="p-4 pt-3">
        <%!-- Title --%>
        <a :if={@href} href={@href} class="hover:underline">
          <p class="text-base font-semibold line-clamp-2">{@title}</p>
        </a>
        <p :if={!@href} class="text-base font-semibold line-clamp-2">{@title}</p>

        <%!-- Price row --%>
        <div class="flex items-baseline gap-1 mt-1">
          <span class="font-bold">{@price}</span>
          <span :if={@original_price} class="text-sm line-through text-muted-foreground ml-2">
            {@original_price}
          </span>
        </div>

        <%!-- Star rating --%>
        <div :if={@rating} class="flex items-center gap-1 mt-1">
          <span class="text-amber-400 text-sm">{star_string(@rating)}</span>
          <span :if={@review_count} class="text-xs text-muted-foreground">
            ({@review_count})
          </span>
        </div>

        <%!-- Actions --%>
        <div class="mt-3">
          <div :if={@actions != []}>
            {render_slot(@actions)}
          </div>
          <.button
            :if={@actions == []}
            class="w-full"
            disabled={@sold_out}
            phx-click={@on_add_to_cart}
          >
            Add to cart
          </.button>
        </div>
      </.card_content>
    </.card>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp star_string(rating) when is_float(rating) do
    filled = trunc(rating + 0.5)
    filled = min(filled, 5)
    String.duplicate("★", filled) <> String.duplicate("☆", 5 - filled)
  end

  defp star_string(rating) when is_integer(rating) do
    star_string(rating / 1)
  end
end
