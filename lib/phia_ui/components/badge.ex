defmodule PhiaUi.Components.Badge do
  @moduledoc """
  Badge component for labels, status indicators and tags.

  Provides 4 semantic variants following the shadcn/ui Badge anatomy.
  Used internally by `StatCard` for trend indicators.

  ## Variants

  | Variant       | Use case                         |
  |---------------|----------------------------------|
  | `:default`    | Primary label / active state     |
  | `:secondary`  | Neutral / informational label    |
  | `:destructive`| Error / warning label            |
  | `:outline`    | Subtle / ghost label             |

  ## Examples

      <.badge>New</.badge>

      <.badge variant={:secondary}>Beta</.badge>

      <.badge variant={:destructive}>Error</.badge>

      <.badge variant={:outline}>Draft</.badge>

      <.badge class="uppercase tracking-wide">Custom</.badge>

      <.badge data-testid="status-badge">Active</.badge>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :variant, :atom,
    values: [:default, :secondary, :destructive, :outline],
    default: :default,
    doc: "Visual style variant"

  attr :class, :string,
    default: nil,
    doc: "Additional CSS classes (merged via cn/1)"

  attr :rest, :global,
    doc: "HTML attributes forwarded to the div element (data-*, aria-*, etc.)"

  slot :inner_block, required: true, doc: "Badge label content"

  @doc "Renders a Badge element."
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

  defp base_class do
    "inline-flex items-center rounded-md border px-2.5 py-0.5 text-xs font-semibold transition-colors"
  end

  defp variant_class(:default),
    do: "bg-primary text-primary-foreground hover:bg-primary/80"

  defp variant_class(:secondary),
    do: "bg-secondary text-secondary-foreground hover:bg-secondary/80"

  defp variant_class(:destructive),
    do: "bg-destructive text-destructive-foreground hover:bg-destructive/80"

  defp variant_class(:outline),
    do: "text-foreground"
end
