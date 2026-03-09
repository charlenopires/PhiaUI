defmodule PhiaUi.Components.BadgeGroup do
  @moduledoc """
  Badge + text description combo component.

  Renders a pill-shaped container with a badge element on the left and
  description text on the right, separated by a subtle visual boundary.
  Commonly seen in marketing UIs as "New feature — Check out our latest update".

  ## Variants

  | Variant     | Visual                                    |
  |-------------|-------------------------------------------|
  | `:default`  | Muted background with subtle border       |
  | `:outline`  | Border only, transparent background       |
  | `:ghost`    | No border, subtle background              |

  ## Examples

      <.badge_group>
        <:badge>New</:badge>
        Check out our latest feature
      </.badge_group>

      <.badge_group variant={:outline} size={:lg}>
        <:badge>v2.0</:badge>
        Major release with breaking changes
      </.badge_group>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :variant, :atom, values: [:default, :outline, :ghost], default: :default
  attr :size, :atom, values: [:sm, :default, :lg], default: :default
  attr :class, :string, default: nil
  attr :rest, :global

  slot :badge, required: true, doc: "Badge pill content (left side)"
  slot :inner_block, required: true, doc: "Description text (right side)"

  def badge_group(assigns) do
    ~H"""
    <div
      class={cn([
        "inline-flex items-center rounded-full",
        variant_class(@variant),
        size_class(@size),
        @class
      ])}
      {@rest}
    >
      <span class={cn(["shrink-0 rounded-full font-semibold", badge_class(@variant), badge_size(@size)])}>
        {render_slot(@badge)}
      </span>
      <span class={cn(["truncate", text_size(@size)])}>
        {render_slot(@inner_block)}
      </span>
    </div>
    """
  end

  defp variant_class(:default), do: "border border-border bg-muted/50"
  defp variant_class(:outline), do: "border border-border bg-transparent"
  defp variant_class(:ghost), do: "bg-muted/30"

  defp size_class(:sm), do: "gap-2 py-0.5 pr-2.5"
  defp size_class(:default), do: "gap-2.5 py-1 pr-3"
  defp size_class(:lg), do: "gap-3 py-1 pr-4"

  defp badge_class(:default), do: "bg-primary text-primary-foreground"
  defp badge_class(:outline), do: "bg-primary text-primary-foreground"
  defp badge_class(:ghost), do: "bg-primary text-primary-foreground"

  defp badge_size(:sm), do: "ml-0.5 px-2 py-0.5 text-xs"
  defp badge_size(:default), do: "ml-1 px-2.5 py-0.5 text-xs"
  defp badge_size(:lg), do: "ml-1 px-3 py-1 text-sm"

  defp text_size(:sm), do: "text-xs text-muted-foreground"
  defp text_size(:default), do: "text-sm text-muted-foreground"
  defp text_size(:lg), do: "text-sm text-foreground"
end
