defmodule PhiaUi.Components.ImageCard do
  @moduledoc "Hero image (top-cover) + card content below."

  use Phoenix.Component

  import PhiaUi.Components.Card
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :src, :string, required: true, doc: "Image URL"
  attr :alt, :string, default: "", doc: "Alt text for the image"
  attr :aspect, :atom, default: :video, values: [:video, :square, :wide, :tall], doc: "Aspect ratio of the image wrapper"
  attr :overlay, :boolean, default: false, doc: "Whether to apply a gradient overlay on the image"
  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global, doc: "HTML attributes forwarded to the card element"

  slot :inner_block, required: true, doc: "Card body content"
  slot :badge, doc: "Optional badge overlaid on image (top-left)"

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
