defmodule PhiaUi.Components.Layout.Cover do
  @moduledoc """
  Full-bleed image or video background with content overlay.

  Creates a hero section or banner with a background media element and
  centered content on top. Supports image and video backgrounds with
  configurable overlay darkness and content positioning.

  ## Examples

      <.cover src="/images/hero.jpg" height={:full}>
        <h1 class="text-4xl font-bold text-white">Welcome</h1>
      </.cover>

      <.cover video_src="/videos/bg.mp4" overlay={:gradient} height={:viewport}>
        <div class="text-center text-white">
          <h2 class="text-5xl font-bold">Watch the demo</h2>
        </div>
      </.cover>

  ## Height presets

  | Height      | CSS                |
  |-------------|--------------------|
  | `:sm`       | `h-48`             |
  | `:md`       | `h-64`             |
  | `:lg`       | `h-96`             |
  | `:full`     | `h-full`           |
  | `:viewport` | `min-h-dvh`        |
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:src, :string, default: nil, doc: "Background image URL.")
  attr(:video_src, :string, default: nil, doc: "Background video URL.")
  attr(:video_type, :string, default: "video/mp4", doc: "Video MIME type.")

  attr(:height, :atom,
    default: :lg,
    values: [:sm, :md, :lg, :full, :viewport],
    doc: "Height preset."
  )

  attr(:overlay, :atom,
    default: :dark,
    values: [:none, :light, :dark, :gradient],
    doc: "Overlay style over the background media."
  )

  attr(:overlay_opacity, :atom,
    default: :md,
    values: [:sm, :md, :lg],
    doc: "Overlay opacity level."
  )

  attr(:position, :atom,
    default: :center,
    values: [:top, :center, :bottom],
    doc: "Vertical alignment of the content."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root element.")

  slot(:inner_block, required: true, doc: "Content overlaid on the background.")

  @doc "Renders a full-bleed cover section with background media and overlay."
  def cover(assigns) do
    ~H"""
    <div class={cn(["relative overflow-hidden", height_class(@height), @class])} {@rest}>
      <img
        :if={@src}
        src={@src}
        alt=""
        class="absolute inset-0 size-full object-cover"
        loading="lazy"
      />
      <video
        :if={@video_src}
        autoplay
        muted
        loop
        playsinline
        class="absolute inset-0 size-full object-cover"
      >
        <source src={@video_src} type={@video_type} />
      </video>
      <div
        :if={@overlay != :none}
        class={cn(["absolute inset-0", overlay_class(@overlay), opacity_class(@overlay_opacity)])}
      />
      <div class={cn(["relative z-10 flex h-full w-full", position_class(@position)])}>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  defp height_class(:sm), do: "h-48"
  defp height_class(:md), do: "h-64"
  defp height_class(:lg), do: "h-96"
  defp height_class(:full), do: "h-full"
  defp height_class(:viewport), do: "min-h-dvh"

  defp overlay_class(:light), do: "bg-white"
  defp overlay_class(:dark), do: "bg-black"
  defp overlay_class(:gradient), do: "bg-gradient-to-t from-black to-transparent"
  defp overlay_class(_), do: nil

  defp opacity_class(:sm), do: "opacity-30"
  defp opacity_class(:md), do: "opacity-50"
  defp opacity_class(:lg), do: "opacity-70"

  defp position_class(:top), do: "items-start justify-center pt-8"
  defp position_class(:center), do: "items-center justify-center"
  defp position_class(:bottom), do: "items-end justify-center pb-8"
end
