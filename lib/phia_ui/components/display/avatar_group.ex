defmodule PhiaUi.Components.AvatarGroup do
  @moduledoc """
  AvatarGroup — an overlapping stack of avatars with built-in overflow badge.

  Accepts named slot items declaratively so callers do not need to manage
  the visible/overflow split themselves. The component slices the item list
  at `max`, renders each visible avatar with `ring-2 ring-background` for
  separation, then appends a "+N" badge when there are hidden items.

  ## Sizes

  | Value       | Dimensions   | Tailwind classes |
  |-------------|--------------|-----------------|
  | `"sm"`      | 24 × 24 px   | `h-6 w-6`       |
  | `"default"` | 40 × 40 px   | `h-10 w-10`     |
  | `"lg"`      | 56 × 56 px   | `h-14 w-14`     |
  | `"xl"`      | 72 × 72 px   | `h-18 w-18`     |

  ## Basic usage

      <.avatar_group>
        <:item src="/avatars/alice.jpg" name="Alice Adams" />
        <:item src="/avatars/bob.jpg"   name="Bob Baker" />
        <:item src="/avatars/carol.jpg" name="Carol Chen" />
      </.avatar_group>

  ## Limit visible count (overflow badge)

      <.avatar_group max={3}>
        <:item src="/a.jpg" name="Alice" />
        <:item src="/b.jpg" name="Bob" />
        <:item src="/c.jpg" name="Carol" />
        <:item src="/d.jpg" name="Dave" />
        <:item src="/e.jpg" name="Eve" />
      </.avatar_group>
      <%!-- Renders 3 avatars + "+2" overflow badge --%>

  ## Sizes

      <.avatar_group size="sm" max={4}>
        <:item src="/a.jpg" name="Alice" />
        <:item name="Bob" />
      </.avatar_group>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Avatar

  attr(:max, :integer,
    default: 5,
    doc: "Maximum number of avatars to display before showing the overflow '+N' badge."
  )

  attr(:size, :string,
    default: "default",
    values: ~w(sm default lg xl),
    doc:
      "Size applied to every avatar and the overflow badge. One of `\"sm\"`, `\"default\"`, `\"lg\"`, `\"xl\"`."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged via `cn/1` and applied to the container div."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>` element.")

  slot :item,
    doc:
      "One avatar item. Supports `src` (image URL) and `name` (full name for initials fallback)." do
    attr(:src, :string, doc: "Avatar image URL. Omit to show initials-only fallback.")
    attr(:name, :string, doc: "Full name used both for the alt text and the initials fallback.")
  end

  @doc """
  Renders an overlapping group of avatars with an optional overflow count badge.

  Items that exceed `max` are hidden; a `+N` badge is appended automatically
  when `N > 0`. All avatars receive `ring-2 ring-background` so each circle
  is visually separated from its neighbour.

  ## Example

      <.avatar_group max={3} size="sm">
        <:item src="/a.jpg" name="Alice" />
        <:item src="/b.jpg" name="Bob" />
        <:item src="/c.jpg" name="Carol" />
        <:item src="/d.jpg" name="Dave" />
      </.avatar_group>
  """
  def avatar_group(assigns) do
    overflow = max(length(assigns.item) - assigns.max, 0)
    visible_items = Enum.take(assigns.item, assigns.max)

    assigns =
      assigns
      |> assign(:overflow, overflow)
      |> assign(:visible_items, visible_items)

    ~H"""
    <div role="list" class={cn(["flex items-center -space-x-2", @class])} {@rest}>
      <div :for={item <- @visible_items} role="listitem">
        <.avatar size={@size} class="ring-2 ring-background">
          <.avatar_image
            :if={Map.get(item, :src)}
            src={Map.get(item, :src)}
            alt={Map.get(item, :name, "")}
          />
          <.avatar_fallback name={Map.get(item, :name)} />
        </.avatar>
      </div>

      <div :if={@overflow > 0} role="listitem">
        <div class={cn([
          "relative flex shrink-0 items-center justify-center rounded-full",
          "ring-2 ring-background bg-muted text-muted-foreground font-medium",
          overflow_size_class(@size)
        ])}>
          +{@overflow}
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers — pattern matching only, no case/cond
  # ---------------------------------------------------------------------------

  defp overflow_size_class("sm"), do: "h-6 w-6 text-xs"
  defp overflow_size_class("default"), do: "h-10 w-10 text-sm"
  defp overflow_size_class("lg"), do: "h-14 w-14 text-sm"
  defp overflow_size_class("xl"), do: "h-18 w-18 text-base"
end
