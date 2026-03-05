defmodule PhiaUi.Components.AspectRatio do
  @moduledoc """
  Utility component that maintains a fixed aspect ratio for any child content.

  Use this component to display images, videos, maps, iframes, or any embed
  that must maintain a predictable width-to-height ratio regardless of its
  container width. Zero JavaScript — pure CSS.

  ## How it works

  The outer `<div>` uses the **padding-top trick** to enforce the aspect ratio:

      padding-top: calc(1 / ratio * 100%)

  Because padding percentages in CSS are calculated relative to the element's
  **width**, setting `padding-top` to `1/ratio * 100%` creates a box whose
  height is always proportional to its width. The inner `<div>` is then
  absolutely positioned with `inset: 0` to fill this space.

  | Ratio  | Float   | Resulting padding-top |
  |--------|---------|-----------------------|
  | 16:9   | 16/9    | ~56.25%               |
  | 4:3    | 4/3     | ~75%                  |
  | 1:1    | 1.0     | 100%                  |
  | 21:9   | 21/9    | ~42.86%               |
  | 9:16   | 9/16    | ~177.78% (portrait)   |
  | 3:2    | 3/2     | ~66.67%               |

  ## Examples

  ### Responsive hero image (16:9)

      <.aspect_ratio ratio={16 / 9}>
        <img src="/images/hero.jpg" alt="Mountain landscape" class="object-cover w-full h-full" />
      </.aspect_ratio>

  ### Product gallery card (4:3)

      <.aspect_ratio ratio={4 / 3} class="rounded-lg overflow-hidden">
        <img src={@product.thumbnail} alt={@product.name} class="object-cover w-full h-full" />
      </.aspect_ratio>

  ### Embedded YouTube video (16:9)

      <.aspect_ratio ratio={16 / 9}>
        <iframe
          src="https://www.youtube.com/embed/dQw4w9WgXcQ"
          title="Video player"
          frameborder="0"
          allow="autoplay; encrypted-media"
          allowfullscreen
          class="w-full h-full"
        />
      </.aspect_ratio>

  ### Square avatar or profile image (1:1)

      <.aspect_ratio ratio={1.0} class="rounded-full overflow-hidden w-32">
        <img src={@user.photo} alt={@user.name} class="object-cover w-full h-full" />
      </.aspect_ratio>

  ### Portrait social card (9:16)

      <.aspect_ratio ratio={9 / 16} class="max-w-xs">
        <div class="w-full h-full bg-gradient-to-b from-primary to-primary/80 p-6 flex flex-col">
          ...
        </div>
      </.aspect_ratio>

  ### Interactive map embed

      <.aspect_ratio ratio={16 / 9} class="rounded-lg overflow-hidden border">
        <iframe
          src="https://maps.google.com/maps?q=New+York&output=embed"
          title="Location map"
          class="w-full h-full"
        />
      </.aspect_ratio>

  ## Notes

  - Always set `class="w-full h-full object-cover"` (or similar) on child
    `<img>` elements so they fill the constrained box without distortion.
  - The outer `<div>` is `position: relative w-full` — add width constraints
    via `class` (e.g. `class="max-w-sm"`) to limit the component's width.
  - `overflow-hidden` must be on the outer container (via `:class`) for
    rounded corners to clip the child content.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:ratio, :float,
    default: 1.0,
    doc:
      "Aspect ratio expressed as `width / height`. Default `1.0` (square). Common values: `16/9`, `4/3`, `21/9`, `9/16`."
  )

  attr(:class, :string,
    default: nil,
    doc:
      "Additional CSS classes applied to the outer wrapper `<div>`. Use `max-w-N`, `rounded-*`, and `overflow-hidden` here."
  )

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the outer `<div>` (e.g. `data-*`, `aria-*`)."
  )

  slot(:inner_block,
    required: true,
    doc:
      "Content to render inside the aspect-ratio-constrained space. Set `class=\"w-full h-full\"` on child elements to fill the box."
  )

  @doc """
  Renders a container that maintains a fixed aspect ratio.

  The outer `<div>` uses `padding-top` to lock the ratio; the inner `<div>`
  uses `position: absolute; inset: 0` so child content fills the full space.

  ## Example

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
      <%!-- Absolute fill layer: child content always fills the padded space --%>
      <div class="absolute inset-0">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end
end
