defmodule PhiaUi.Components.Watermark do
  @moduledoc """
  Watermark — repeating text overlay using an inline SVG `<pattern>`.

  Inspired by Ant Design `Watermark`. Uses no JavaScript and no external URIs.
  Each instance generates a unique pattern ID via `:crypto` to avoid `<pattern>`
  ID collisions when multiple watermarks appear on the same page.

  ## Examples

      <.watermark content="CONFIDENTIAL">
        <img src="/report.png" class="w-full" />
      </.watermark>

      <.watermark content="Draft" opacity="0.08" rotate={-45} font_size="20px">
        <div class="p-8">Document content here</div>
      </.watermark>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:content, :string, required: true, doc: "Watermark text to repeat across the area.")
  attr(:gap, :integer, default: 100, doc: "Spacing between watermark tiles (px).")
  attr(:rotate, :integer, default: -30, doc: "Rotation angle in degrees.")
  attr(:opacity, :string, default: "0.12", doc: "CSS opacity value (0.0–1.0).")
  attr(:font_size, :string, default: "16px", doc: "CSS font size of the watermark text.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root element.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>`.")

  slot(:inner_block, required: true, doc: "Content to be watermarked.")

  def watermark(assigns) do
    pattern_id = "wm-" <> (:crypto.strong_rand_bytes(4) |> Base.encode16(case: :lower))
    tile = assigns.gap * 2

    assigns =
      assigns
      |> assign(:pattern_id, pattern_id)
      |> assign(:tile, tile)

    ~H"""
    <div class={cn(["relative overflow-hidden", @class])} {@rest}>
      {render_slot(@inner_block)}
      <%!-- SVG watermark overlay — pointer-events-none, aria-hidden --%>
      <svg
        aria-hidden="true"
        class="pointer-events-none absolute inset-0 h-full w-full"
        xmlns="http://www.w3.org/2000/svg"
        style={"opacity: #{@opacity}"}
      >
        <defs>
          <pattern
            id={@pattern_id}
            x="0"
            y="0"
            width={@tile}
            height={@tile}
            patternUnits="userSpaceOnUse"
          >
            <text
              x={div(@tile, 2)}
              y={div(@tile, 2)}
              text-anchor="middle"
              dominant-baseline="middle"
              fill="currentColor"
              font-size={@font_size}
              transform={"rotate(#{@rotate}, #{div(@tile, 2)}, #{div(@tile, 2)})"}
            >
              {@content}
            </text>
          </pattern>
        </defs>
        <rect width="100%" height="100%" fill={"url(##{@pattern_id})"} />
      </svg>
    </div>
    """
  end
end
