defmodule PhiaUi.Components.ImageCard do
  @moduledoc """
  Hero image (top-cover) + card content below.

  Renders a `Card` with a full-width image at the top (aspect-ratio configurable)
  followed by a `card_content` area for arbitrary content.

  ## Aspect ratios

  | `:aspect`   | CSS applied           | Typical use                    |
  |-------------|-----------------------|--------------------------------|
  | `:video`    | `aspect-video` (16:9) | Blog covers, product previews  |
  | `:square`   | `aspect-square` (1:1) | Avatar-style covers            |
  | `:wide`     | `aspect-[2/1]`        | Landscape banners              |
  | `:tall`     | `aspect-[3/4]`        | Portrait / book covers         |

  ## Overlay gradient

  Set `overlay={true}` to apply a semi-transparent `from-black/60` gradient
  from the bottom of the image. Useful when overlaying text or badges on top
  of the image in a LiveView layout.

  ## Badge slot

  The `:badge` slot is overlaid at the top-left corner of the image above the
  gradient (z-index 10). Use it for labels like `"NEW"`, `"–20%"`, or a
  `PhiaUi.Components.Badge` component.

  ## Examples

      <%!-- Simple product image card --%>
      <.image_card src="/images/product.jpg" alt="Wireless headphones">
        <h3 class="font-semibold">Wireless Headphones</h3>
        <p class="text-sm text-muted-foreground">Premium sound quality.</p>
      </.image_card>

      <%!-- Wide banner with gradient overlay and badge --%>
      <.image_card src="/images/banner.jpg" alt="Summer sale" aspect={:wide} overlay={true}>
        <:badge>
          <.badge variant={:destructive}>Sale</.badge>
        </:badge>
        <p class="font-semibold">Summer Sale — up to 50% off</p>
      </.image_card>

      <%!-- Square avatar-style card --%>
      <.image_card src="/images/avatar.jpg" alt="Jane Doe" aspect={:square}>
        <p class="text-center font-medium">Jane Doe</p>
      </.image_card>
  """

  use Phoenix.Component

  import PhiaUi.Components.Card
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:src, :string, required: true, doc: "Image URL")
  attr(:alt, :string, default: "", doc: "Alt text for the image")

  attr(:aspect, :atom,
    default: :video,
    values: [:video, :square, :wide, :tall],
    doc: "Aspect ratio of the image wrapper"
  )

  attr(:overlay, :boolean,
    default: false,
    doc: "Whether to apply a gradient overlay on the image"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the card element")

  slot(:inner_block, required: true, doc: "Card body content")
  slot(:badge, doc: "Optional badge overlaid on image (top-left)")

  @doc """
  Renders a card with a hero image at the top followed by card content.

  ## Examples

      <.image_card src="/hero.jpg" alt="Product photo" aspect={:video}>
        <p>Product description here</p>
      </.image_card>

      <.image_card src="/banner.jpg" overlay={true}>
        <:badge><span class="text-xs text-white font-semibold">NEW</span></:badge>
        <p>Card content</p>
      </.image_card>
  """
  def image_card(assigns) do
    ~H"""
    <.card class={cn(["overflow-hidden", @class])} {@rest}>
      <div class={cn(["relative", aspect_class(@aspect), @overlay && "after:absolute after:inset-0 after:bg-gradient-to-t after:from-black/60"])}>
        <img src={@src} alt={@alt} class="w-full h-full object-cover" />
        <div :if={@badge != []} class="absolute top-2 left-2 z-10">
          {render_slot(@badge)}
        </div>
      </div>
      <.card_content class="p-4">
        {render_slot(@inner_block)}
      </.card_content>
    </.card>
    """
  end

  defp aspect_class(:video), do: "aspect-video"
  defp aspect_class(:square), do: "aspect-square"
  defp aspect_class(:wide), do: "aspect-[2/1]"
  defp aspect_class(:tall), do: "aspect-[3/4]"
end
