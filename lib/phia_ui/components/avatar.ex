defmodule PhiaUi.Components.Avatar do
  @moduledoc """
  Avatar component for displaying user profile images with initials fallback.

  Provides a circular profile image container following the shadcn/ui Avatar anatomy.
  Pure HEEx — no external JS hook required. Fallback is shown via an inline `onerror`
  handler on the `<img>` tag.

  ## Sub-components

  - `avatar/1` — circular wrapper with configurable size
  - `avatar_image/1` — `<img>` tag with automatic fallback on load error
  - `avatar_fallback/1` — initials or custom content shown when image is absent/fails
  - `avatar_group/1` — overlapping stack of avatars with negative spacing

  ## Sizes

  | Size      | Dimensions |
  |-----------|------------|
  | `"sm"`    | 24px (h-6 w-6)  |
  | `"default"` | 40px (h-10 w-10) |
  | `"lg"`    | 56px (h-14 w-14) |
  | `"xl"`    | 72px (h-18 w-18) |

  ## Examples

      <%!-- Image with initials fallback --%>
      <.avatar>
        <.avatar_image src={@user.avatar_url} alt={@user.name} />
        <.avatar_fallback name={@user.name} />
      </.avatar>

      <%!-- Fallback only --%>
      <.avatar size="lg">
        <.avatar_fallback name="Jane Smith" />
      </.avatar>

      <%!-- Custom fallback content (icon) --%>
      <.avatar>
        <.avatar_fallback>
          <.icon name="user" size="xs" />
        </.avatar_fallback>
      </.avatar>

      <%!-- Overlapping group --%>
      <.avatar_group>
        <.avatar><.avatar_fallback name="Alice A" /></.avatar>
        <.avatar><.avatar_fallback name="Bob B" /></.avatar>
        <.avatar><.avatar_fallback name="Carl C" /></.avatar>
      </.avatar_group>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:size, :string,
    default: "default",
    values: ~w(sm default lg xl),
    doc: "Avatar size: sm (24px), default (40px), lg (56px), xl (72px)"
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged via cn/1"
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the root span element")

  slot(:inner_block, required: true, doc: "avatar_image and/or avatar_fallback sub-components")

  @doc """
  Renders a circular avatar container.

  Wraps `avatar_image/1` and/or `avatar_fallback/1`. The container is a `<span>`
  with `overflow-hidden` and `rounded-full` so the image or fallback is always
  clipped to a circle.
  """
  def avatar(assigns) do
    ~H"""
    <span
      class={cn(["relative flex shrink-0 overflow-hidden rounded-full", size_class(@size), @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end

  attr(:src, :string, required: true, doc: "Image URL")
  attr(:alt, :string, default: "", doc: "Accessible alt text for the image")
  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1")
  attr(:rest, :global, doc: "HTML attributes forwarded to the img element")

  @doc """
  Renders the avatar image.

  When the image fails to load the inline `onerror` handler hides the `<img>` and
  reveals any sibling element that carries `data-avatar-fallback` — typically an
  `avatar_fallback/1` rendered inside the same `avatar/1` wrapper.
  """
  def avatar_image(assigns) do
    ~H"""
    <img
      src={@src}
      alt={@alt}
      class={cn(["aspect-square h-full w-full object-cover", @class])}
      onerror="this.style.display='none';var fb=this.parentElement.querySelector('[data-avatar-fallback]');if(fb)fb.style.display='flex';"
      {@rest}
    />
    """
  end

  attr(:name, :string,
    default: nil,
    doc: "Full name used to derive up to two initials (e.g. 'Jane Smith' → 'JS')"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root span element")

  slot(:inner_block,
    doc: "Custom fallback content. When provided, overrides the :name initials."
  )

  @doc """
  Renders the avatar fallback displayed when no image is available or it fails.

  Pass `:name` to auto-derive initials (up to two words, uppercased). Alternatively,
  supply any content via the inner slot — useful for an icon placeholder.

  The element carries `data-avatar-fallback` so `avatar_image/1`'s `onerror` handler
  can locate and reveal it after an image load failure.
  """
  def avatar_fallback(assigns) do
    ~H"""
    <span
      data-avatar-fallback
      class={cn([
        "flex h-full w-full items-center justify-center rounded-full",
        "bg-muted text-muted-foreground text-sm font-medium",
        @class
      ])}
      {@rest}
    >
      {if @inner_block != [], do: render_slot(@inner_block), else: initials(@name)}
    </span>
    """
  end

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root div element")

  slot(:inner_block, required: true, doc: "Avatar components to display as a group")

  @doc """
  Renders a horizontal group of overlapping avatars.

  Uses `-space-x-2` (negative margin) so each avatar overlaps its predecessor.
  Wrap `avatar/1` components inside to form the group. Apply `ring-2 ring-background`
  on individual avatars to produce the border separation effect.

  ## Example

      <.avatar_group>
        <.avatar class="ring-2 ring-background"><.avatar_fallback name="Alice A" /></.avatar>
        <.avatar class="ring-2 ring-background"><.avatar_fallback name="Bob B" /></.avatar>
      </.avatar_group>
  """
  def avatar_group(assigns) do
    ~H"""
    <div class={cn(["flex -space-x-2", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers — pattern matching only, no case/cond
  # ---------------------------------------------------------------------------

  defp size_class("sm"), do: "h-6 w-6"
  defp size_class("default"), do: "h-10 w-10"
  defp size_class("lg"), do: "h-14 w-14"
  defp size_class("xl"), do: "h-18 w-18"

  defp initials(nil), do: ""

  defp initials(name) do
    name
    |> String.split()
    |> Enum.take(2)
    |> Enum.map_join(&String.first/1)
    |> String.upcase()
  end
end
