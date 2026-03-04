defmodule PhiaUi.Components.Avatar do
  @moduledoc """
  Circular user avatar with automatic image-fallback to initials.

  Follows the shadcn/ui Avatar anatomy: a composable set of sub-components
  that work together to display a profile image with a graceful fallback.
  The fallback mechanism is powered by an inline `onerror` attribute on the
  `<img>` tag — no JavaScript hook is required.

  ## Sub-components

  | Component         | Element  | Purpose                                                  |
  |-------------------|----------|----------------------------------------------------------|
  | `avatar/1`        | `<span>` | Circular clipping container with configurable size       |
  | `avatar_image/1`  | `<img>`  | Profile image; hides itself and reveals fallback on error|
  | `avatar_fallback/1`| `<span>`| Initials or custom content shown when image is absent    |
  | `avatar_group/1`  | `<div>`  | Overlapping stack of avatars with negative margin        |

  ## Sizes

  | Value       | Dimensions       | Tailwind classes |
  |-------------|------------------|-----------------|
  | `"sm"`      | 24 × 24 px       | `h-6 w-6`       |
  | `"default"` | 40 × 40 px       | `h-10 w-10`     |
  | `"lg"`      | 56 × 56 px       | `h-14 w-14`     |
  | `"xl"`      | 72 × 72 px       | `h-18 w-18`     |

  ## Image with automatic fallback

  The most common pattern. When the image URL is valid, the photo is shown.
  When the image fails to load (broken URL, network error, 404), the
  `onerror` handler hides the `<img>` and reveals `avatar_fallback/1`:

      <.avatar>
        <.avatar_image src={@user.avatar_url} alt={@user.name} />
        <.avatar_fallback name={@user.name} />
      </.avatar>

  ## Fallback only (no image available)

  When you know ahead of time that there is no image — for example when the
  user has not uploaded one yet — omit `avatar_image/1`:

      <.avatar size="lg">
        <.avatar_fallback name="Jane Smith" />
      </.avatar>

  ## Icon placeholder

  Supply a custom inner block to `avatar_fallback/1` instead of using the
  `:name` prop:

      <.avatar>
        <.avatar_fallback>
          <.icon name="user" size={:xs} />
        </.avatar_fallback>
      </.avatar>

  ## Team member list with AvatarGroup

  Use `avatar_group/1` to render an overlapping cluster of avatars, common
  in "assigned to" or "members" widgets. Apply `ring-2 ring-background` to
  individual avatars to create a visible separation between overlapping items:

      <%!-- Shows up to 4 avatars then a +N overflow badge --%>
      <div class="flex items-center gap-2">
        <.avatar_group>
          <%= for member <- Enum.take(@team.members, 4) do %>
            <.avatar class="ring-2 ring-background" size="sm">
              <.avatar_image src={member.avatar_url} alt={member.name} />
              <.avatar_fallback name={member.name} />
            </.avatar>
          <% end %>
        </.avatar_group>
        <%= if length(@team.members) > 4 do %>
          <span class="text-sm text-muted-foreground">
            +{length(@team.members) - 4} more
          </span>
        <% end %>
      </div>

  ## Comment thread with avatars

      <%= for comment <- @comments do %>
        <div class="flex gap-3">
          <.avatar size="sm">
            <.avatar_image src={comment.author.avatar_url} alt={comment.author.name} />
            <.avatar_fallback name={comment.author.name} />
          </.avatar>
          <div>
            <p class="text-sm font-medium">{comment.author.name}</p>
            <p class="text-sm text-muted-foreground">{comment.body}</p>
          </div>
        </div>
      <% end %>

  ## How the onerror fallback works

  The `avatar_image/1` component attaches an inline `onerror` JavaScript
  handler directly to the `<img>` element:

      onerror="this.style.display='none';
               var fb=this.parentElement.querySelector('[data-avatar-fallback]');
               if(fb)fb.style.display='flex';"

  When the browser fails to load the image source it fires the `onerror`
  event synchronously. The handler:
  1. Hides the `<img>` (`display: none`).
  2. Queries the parent for a `[data-avatar-fallback]` sibling.
  3. Reveals it by setting `display: flex`.

  `avatar_fallback/1` carries `data-avatar-fallback` to serve as the target.
  This keeps the mechanism entirely CSS/HTML — no Phoenix hook needed.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # avatar/1 — circular clipping container
  # ---------------------------------------------------------------------------

  attr(:size, :string,
    default: "default",
    values: ~w(sm default lg xl),
    doc: "Avatar size. One of `\"sm\"` (24px), `\"default\"` (40px), `\"lg\"` (56px), `\"xl\"` (72px)."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged via `cn/1`. Useful for adding `ring-2 ring-background` in avatar groups."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<span>` element.")

  slot(:inner_block, required: true, doc: "`avatar_image/1` and/or `avatar_fallback/1` sub-components.")

  @doc """
  Renders a circular avatar container.

  The container is a `<span>` with `overflow-hidden rounded-full` so any
  child — whether an image or initials fallback — is always clipped to a
  perfect circle regardless of the source aspect ratio.

  ## Example

      <.avatar size="lg">
        <.avatar_image src="/avatars/jane.jpg" alt="Jane Smith" />
        <.avatar_fallback name="Jane Smith" />
      </.avatar>
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

  # ---------------------------------------------------------------------------
  # avatar_image/1 — <img> with onerror fallback
  # ---------------------------------------------------------------------------

  attr(:src, :string, required: true, doc: "The image URL. When the URL fails to load, the `avatar_fallback/1` sibling is revealed automatically.")
  attr(:alt, :string, default: "", doc: "Accessible alt text. Use the user's full name for proper screen reader support.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via `cn/1`.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the `<img>` element (e.g. `loading=\"lazy\"`).")

  @doc """
  Renders the avatar image with an automatic fallback on load error.

  When the image loads successfully, it fills the avatar container using
  `object-cover` to maintain the circular crop without distortion.

  When the image **fails** to load (broken URL, 404, network error), the
  inline `onerror` handler:
  1. Hides this `<img>` element.
  2. Finds and reveals the sibling `avatar_fallback/1` (identified by
     `data-avatar-fallback`).

  This happens synchronously in the browser — no LiveView round-trip needed.

  ## Example

      <.avatar_image src={@user.photo_url} alt={@user.name} loading="lazy" />
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

  # ---------------------------------------------------------------------------
  # avatar_fallback/1 — initials or custom content
  # ---------------------------------------------------------------------------

  attr(:name, :string,
    default: nil,
    doc: "Full name from which up to two initials are derived. `\"Jane Smith\"` → `\"JS\"`, `\"Alice\"` → `\"A\"`. Ignored when an inner block is provided."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via `cn/1`.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<span>` element.")

  slot(:inner_block,
    doc: "Custom fallback content. When provided, overrides the `:name` initials. Useful for icon placeholders."
  )

  @doc """
  Renders the avatar fallback displayed when no image is available or loading fails.

  There are two ways to supply content:

  1. **`:name` attribute** — pass the user's full name; up to two initials
     are extracted and uppercased automatically (`"Jane Smith"` → `"JS"`).

  2. **Inner block** — provide any content (e.g. an icon). When an inner
     block is present, `:name` is ignored.

  The element carries `data-avatar-fallback` so that `avatar_image/1`'s
  `onerror` handler can locate and reveal it after an image load failure.

  ## Examples

      <%!-- Auto initials --%>
      <.avatar_fallback name="Carlos Mendoza" />

      <%!-- Custom icon --%>
      <.avatar_fallback>
        <.icon name="user" size={:xs} />
      </.avatar_fallback>
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
      <%!-- Prefer slot content over derived initials when both are provided --%>
      {if @inner_block != [], do: render_slot(@inner_block), else: initials(@name)}
    </span>
    """
  end

  # ---------------------------------------------------------------------------
  # avatar_group/1 — overlapping stack
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via `cn/1`.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>` element.")

  slot(:inner_block, required: true, doc: "`avatar/1` components to display as an overlapping group.")

  @doc """
  Renders a horizontal group of overlapping avatars.

  Uses `-space-x-2` (negative left margin) so each subsequent avatar
  overlaps its predecessor by 8px. Apply `ring-2 ring-background` on each
  individual `avatar/1` to create a visible border between overlapping items.

  ## Example

      <.avatar_group>
        <.avatar class="ring-2 ring-background">
          <.avatar_fallback name="Alice Adams" />
        </.avatar>
        <.avatar class="ring-2 ring-background">
          <.avatar_fallback name="Bob Baker" />
        </.avatar>
        <.avatar class="ring-2 ring-background">
          <.avatar_fallback name="Carl Chen" />
        </.avatar>
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

  # Each size maps directly to a Tailwind size pair. Using pattern-matched
  # defp heads keeps the logic declarative and avoids runtime conditionals.
  defp size_class("sm"), do: "h-6 w-6"
  defp size_class("default"), do: "h-10 w-10"
  defp size_class("lg"), do: "h-14 w-14"
  defp size_class("xl"), do: "h-18 w-18"

  # Guard against nil name (user has no name set)
  defp initials(nil), do: ""

  defp initials(name) do
    name
    # Split on whitespace to get individual name parts
    |> String.split()
    # Take at most 2 parts (first + last name)
    |> Enum.take(2)
    # Extract only the first character of each part
    |> Enum.map_join(&String.first/1)
    # Normalise to uppercase for consistent appearance
    |> String.upcase()
  end
end
