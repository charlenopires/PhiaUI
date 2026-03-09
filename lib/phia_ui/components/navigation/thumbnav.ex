defmodule PhiaUi.Components.Thumbnav do
  @moduledoc """
  Thumbnail navigation strip for image galleries and slideshows.

  Renders a row (or column) of clickable thumbnail images. The active
  item is highlighted with a ring. Commonly paired with a carousel or
  lightbox component.

  ## Examples

      <.thumbnav>
        <.thumbnav_item src="/images/photo1-thumb.jpg" active={true} on_click="select_slide" value="0" />
        <.thumbnav_item src="/images/photo2-thumb.jpg" on_click="select_slide" value="1" />
        <.thumbnav_item src="/images/photo3-thumb.jpg" on_click="select_slide" value="2" />
      </.thumbnav>

  ## Vertical orientation

      <.thumbnav orientation={:vertical}>
        <.thumbnav_item src="/img/1.jpg" active={true} />
        <.thumbnav_item src="/img/2.jpg" />
      </.thumbnav>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # thumbnav/1
  # ---------------------------------------------------------------------------

  attr(:orientation, :atom,
    default: :horizontal,
    values: [:horizontal, :vertical],
    doc: "Layout direction."
  )

  attr(:gap, :atom,
    default: :md,
    values: [:sm, :md, :lg],
    doc: "Gap between thumbnails."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the `<nav>` element.")

  slot(:inner_block, required: true, doc: "thumbnav_item children.")

  @doc "Renders a thumbnail navigation strip container."
  def thumbnav(assigns) do
    ~H"""
    <nav
      class={cn([
        "flex",
        orientation_class(@orientation),
        gap_class(@gap),
        @class
      ])}
      role="tablist"
      {@rest}
    >
      {render_slot(@inner_block)}
    </nav>
    """
  end

  # ---------------------------------------------------------------------------
  # thumbnav_item/1
  # ---------------------------------------------------------------------------

  attr(:src, :string, required: true, doc: "Thumbnail image URL.")
  attr(:alt, :string, default: "", doc: "Image alt text.")
  attr(:active, :boolean, default: false, doc: "Whether this item is selected.")
  attr(:href, :string, default: nil, doc: "Optional link URL.")
  attr(:on_click, :string, default: nil, doc: "phx-click event name.")
  attr(:value, :string, default: nil, doc: "phx-value-index or similar.")
  attr(:width, :string, default: "w-16", doc: "Thumbnail width class.")
  attr(:height, :string, default: "h-16", doc: "Thumbnail height class.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the item element.")

  @doc "Renders a single thumbnail navigation item."
  def thumbnav_item(assigns) do
    ~H"""
    <button
      :if={!@href}
      type="button"
      role="tab"
      aria-selected={"#{@active}"}
      class={cn([
        "overflow-hidden rounded-md transition-all",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
        @width,
        @height,
        if(@active, do: "ring-2 ring-primary opacity-100", else: "opacity-70 hover:opacity-100"),
        @class
      ])}
      phx-click={@on_click}
      phx-value-index={@value}
      {@rest}
    >
      <img src={@src} alt={@alt} class="size-full object-cover" loading="lazy" />
    </button>
    <a
      :if={@href}
      href={@href}
      role="tab"
      aria-selected={"#{@active}"}
      class={cn([
        "overflow-hidden rounded-md transition-all block",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
        @width,
        @height,
        if(@active, do: "ring-2 ring-primary opacity-100", else: "opacity-70 hover:opacity-100"),
        @class
      ])}
      {@rest}
    >
      <img src={@src} alt={@alt} class="size-full object-cover" loading="lazy" />
    </a>
    """
  end

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  defp orientation_class(:horizontal), do: "flex-row items-center"
  defp orientation_class(:vertical), do: "flex-col items-start"

  defp gap_class(:sm), do: "gap-1"
  defp gap_class(:md), do: "gap-2"
  defp gap_class(:lg), do: "gap-4"
end
