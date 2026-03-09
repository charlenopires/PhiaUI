defmodule PhiaUi.Components.Lightbox do
  @moduledoc """
  Modal image/video gallery with keyboard navigation and touch swipe.

  The lightbox renders a grid of clickable thumbnails. When an item is
  clicked, the `PhiaLightbox` JS hook opens a full-screen overlay showing
  the full-resolution media with prev/next navigation.

  ## Examples

      <.lightbox id="gallery">
        <.lightbox_item src="/images/photo1.jpg" caption="Sunset" />
        <.lightbox_item src="/images/photo2.jpg" caption="Mountains" />
        <.lightbox_item src="/images/photo3.jpg" thumb_src="/images/photo3-thumb.jpg" />
      </.lightbox>

  ## Video items

      <.lightbox id="media">
        <.lightbox_item src="/images/photo.jpg" />
        <.lightbox_item src="/videos/clip.mp4" type={:video} caption="Demo video" />
      </.lightbox>

  ## JS Hook: PhiaLightbox

  The hook manages the overlay lifecycle:
  - Click items to open at the correct index
  - Escape key or click backdrop to close
  - Arrow keys and swipe for prev/next navigation
  - Body scroll lock while open
  - `prefers-reduced-motion` disables transitions
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # lightbox/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "Required ID for hook binding.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes on the grid.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the container.")

  slot(:inner_block, required: true, doc: "lightbox_item children.")

  @doc "Renders a lightbox gallery container with JS hook binding."
  def lightbox(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaLightbox"
      class={cn(["grid grid-cols-2 gap-2 sm:grid-cols-3 md:grid-cols-4", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # lightbox_item/1
  # ---------------------------------------------------------------------------

  attr(:src, :string, required: true, doc: "Full-resolution media URL.")
  attr(:thumb_src, :string, default: nil, doc: "Thumbnail URL (falls back to src).")
  attr(:alt, :string, default: "", doc: "Image alt text.")
  attr(:caption, :string, default: nil, doc: "Caption shown in overlay.")
  attr(:type, :atom, default: :image, values: [:image, :video], doc: "Media type.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the item element.")

  @doc "Renders a single lightbox gallery item trigger with thumbnail."
  def lightbox_item(assigns) do
    assigns = assign_new(assigns, :display_src, fn -> assigns.thumb_src || assigns.src end)

    ~H"""
    <button
      type="button"
      class={cn([
        "group relative overflow-hidden rounded-md cursor-pointer",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
        "aspect-square",
        @class
      ])}
      data-lightbox-src={@src}
      data-lightbox-type={Atom.to_string(@type)}
      data-lightbox-alt={@alt}
      data-lightbox-caption={@caption}
      {@rest}
    >
      <img
        :if={@type == :image}
        src={@display_src}
        alt={@alt}
        class="size-full object-cover transition-transform duration-200 group-hover:scale-105"
        loading="lazy"
      />
      <div :if={@type == :video} class="size-full bg-muted flex items-center justify-center">
        <svg class="size-10 text-muted-foreground" fill="currentColor" viewBox="0 0 24 24">
          <path d="M8 5v14l11-7z" />
        </svg>
      </div>
      <div
        :if={@caption}
        class="absolute inset-x-0 bottom-0 bg-black/60 px-2 py-1 text-xs text-white opacity-0 transition-opacity group-hover:opacity-100"
      >
        {@caption}
      </div>
    </button>
    """
  end
end
