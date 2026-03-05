defmodule PhiaUi.Components.Badge do
  @moduledoc """
  Compact inline label for status indicators, tags, version numbers, and counts.

  Provides 6 semantic variants following the shadcn/ui Badge anatomy. Badges
  are purely presentational — they are `<div>` elements, not `<button>` or
  `<a>`. For clickable or dismissible badges, compose a badge with a button.

  ## Variants

  | Variant        | Visual                                        | Typical use cases                          |
  |----------------|-----------------------------------------------|--------------------------------------------|
  | `:default`     | Solid primary background                      | Active state, current plan, primary label  |
  | `:secondary`   | Muted secondary background                    | Neutral tag, informational, version number |
  | `:destructive` | Red/destructive background                    | Error, overdue, critical, danger           |
  | `:outline`     | Border only, transparent background           | Draft, subtle metadata, low-emphasis tag   |
  | `:ghost`       | Transparent, accent on hover                  | Inline tags, chip lists with hover effect  |
  | `:link`        | Primary colour with underline on hover        | Clickable tag acting as a link             |

  ## Basic usage

      <.badge>New</.badge>

      <.badge variant={:secondary}>Beta</.badge>

      <.badge variant={:destructive}>Overdue</.badge>

      <.badge variant={:outline}>Draft</.badge>

  ## Status indicators

  Use badges to show record status in tables and cards:

      <.badge variant={status_variant(@order.status)}>
        {String.capitalize(@order.status)}
      </.badge>

  Where `status_variant/1` maps domain values to badge variants:

      defp status_variant("active"),    do: :default
      defp status_variant("draft"),     do: :outline
      defp status_variant("overdue"),   do: :destructive
      defp status_variant(_other),      do: :secondary

  ## Trend indicators in stat cards

  The `StatCard` component uses badges internally for trend labels. You can
  compose the same pattern directly:

      <div class="flex items-center gap-2">
        <span class="text-2xl font-bold">$42,800</span>
        <.badge variant={:default} class="gap-1">
          <.icon name="trending-up" size={:xs} />
          +12.5%
        </.badge>
      </div>

  ## Count / notification badge

  Overlay a count badge on an icon:

      <div class="relative inline-flex">
        <.icon name="bell" size={:md} />
        <.badge class="absolute -top-1 -right-1 h-4 w-4 p-0 flex items-center justify-center text-[10px]">
          {min(@unread_count, 99)}
        </.badge>
      </div>

  ## Plan or tier labels

      <.badge variant={:outline} class="uppercase tracking-wide text-[10px]">
        Pro
      </.badge>

  ## Tag list

      <div class="flex flex-wrap gap-1">
        <%= for tag <- @post.tags do %>
          <.badge variant={:secondary}>{tag}</.badge>
        <% end %>
      </div>

  ## Combining with a close button (dismissible tag)

      <%= for skill <- @skills do %>
        <div class="inline-flex items-center gap-1">
          <.badge variant={:secondary}>{skill}</.badge>
          <button
            phx-click="remove_skill"
            phx-value-skill={skill}
            class="ml-0.5 rounded-full p-0.5 hover:bg-muted"
            aria-label={"Remove \#{skill}"}
          >
            <.icon name="x" size={:xs} />
          </button>
        </div>
      <% end %>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:variant, :atom,
    values: [:default, :secondary, :destructive, :outline, :ghost, :link],
    default: :default,
    doc:
      "Visual style variant. Controls background, text colour, and hover state. Default: `:default` (solid primary)."
  )

  attr(:class, :string,
    default: nil,
    doc:
      "Additional CSS classes merged via `cn/1`. Use `uppercase tracking-wide` for label-style badges, or `gap-1` to add an icon."
  )

  attr(:rest, :global,
    doc:
      "HTML attributes forwarded to the root `<div>` element (e.g. `data-testid`, `aria-label`)."
  )

  slot(:inner_block,
    required: true,
    doc:
      "Badge content. Typically a short text label (1–3 words), count, or an icon + text combination."
  )

  @doc """
  Renders an inline `<div>` styled as a badge.

  Badges are display-only elements — they have no interactive behaviour by
  default. To make a badge interactive, wrap it in a `<button>` or `<a>` or
  compose it with a close/remove button beside it.

  The `:default` variant uses the primary brand colour for high-visibility
  labels. `:outline` and `:ghost` are appropriate for lower-emphasis metadata.
  `:destructive` should be reserved for genuine error or danger states.

  ## Example

      <.badge variant={:destructive}>
        <.icon name="alert-triangle" size={:xs} />
        Critical
      </.badge>
  """
  def badge(assigns) do
    ~H"""
    <div class={cn([base_class(), variant_class(@variant), @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers — pattern matching only, no case/cond
  # ---------------------------------------------------------------------------

  # Shared layout: compact pill shape, small font, semibold for legibility
  defp base_class do
    "inline-flex items-center rounded-md border px-2.5 py-0.5 text-xs font-semibold transition-colors"
  end

  # Default: primary brand colour — used for "active", "new", featured states
  defp variant_class(:default),
    do: "bg-primary text-primary-foreground hover:bg-primary/80"

  # Secondary: muted background — used for neutral tags, version numbers
  defp variant_class(:secondary),
    do: "bg-secondary text-secondary-foreground hover:bg-secondary/80"

  # Destructive: red — reserved for errors, overdue, critical states
  defp variant_class(:destructive),
    do: "bg-destructive text-destructive-foreground hover:bg-destructive/80"

  # Outline: border only, no fill — for draft, low-emphasis, ghost tags
  defp variant_class(:outline),
    do: "text-foreground"

  # Ghost: no border, accent on hover — for interactive tag chips
  defp variant_class(:ghost),
    do: "hover:bg-accent hover:text-accent-foreground"

  # Link: primary text with underline on hover — for linked/clickable tags
  defp variant_class(:link),
    do: "text-primary underline-offset-4 hover:underline"
end
