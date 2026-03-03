defmodule PhiaUi.Components.AspectRatio do
  @moduledoc """
  Utility component that maintains a fixed aspect ratio for any child content.

  Uses the padding-top CSS trick to enforce the aspect ratio:
  `padding-top: calc(1 / ratio * 100%)`. The inner content uses
  `position: absolute; inset: 0` to fill the space.

  Zero JavaScript — pure CSS/HEEx.

  ## Supported ratios

  | Ratio | Float | Padding-top |
  |-------|-------|-------------|
  | 16:9  | 16/9  | ~56.25%     |
  | 4:3   | 4/3   | ~75%        |
  | 1:1   | 1.0   | 100%        |
  | 21:9  | 21/9  | ~42.86%     |
  | 9:16  | 9/16  | ~177.78%    |

  ## Examples

      <.aspect_ratio ratio={16 / 9}>
        <img src="/hero.jpg" alt="Hero" class="object-cover w-full h-full" />
      </.aspect_ratio>

      <.aspect_ratio ratio={1.0} class="rounded-lg overflow-hidden">
        <video src="/promo.mp4" controls class="w-full h-full" />
      </.aspect_ratio>

  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:ratio, :float, default: 1.0, doc: "Aspect ratio (width/height). Default: 1.0 (square)")

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes for the outer wrapper (merged via cn/1)"
  )

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the root element (data-*, aria-*, etc.)"
  )

  slot(:inner_block, required: true, doc: "Content to display within the aspect ratio container")

  @doc """
  Renders a container that maintains a fixed aspect ratio.

  The outer `<div>` uses `padding-top` to enforce the ratio; the inner `<div>`
  uses `position: absolute; inset: 0` so the child content fills the space.

  ## Examples

      <.aspect_ratio ratio={16 / 9}>
        <img src="/poster.jpg" alt="Movie poster" class="h-full w-full object-cover" />
      </.aspect_ratio>

  """
  def aspect_ratio(assigns) do
    ~H"""
    <div
      class={cn(["relative w-full", @class])}
      style={"padding-top: #{Float.round(1.0 / @ratio * 100, 4)}%"}
      {@rest}
    >
      <div class="absolute inset-0">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end
end
