defmodule PhiaUi.Components.PageProgress do
  @moduledoc """
  Reading progress bar fixed at the top or bottom of the page.

  Uses the `PhiaPageProgress` hook from `priv/templates/js/hooks/page_progress.js`.
  The hook listens to scroll events and updates `this.el.style.width` and
  `aria-valuenow` based on the percentage of the page scrolled.

  The element starts with `w-0` — the hook drives all width changes via inline style.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # page_progress/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, default: "page-progress", doc: "Required for phx-hook")
  attr(:variant, :atom, values: [:default, :gradient, :thin], default: :default)
  attr(:position, :atom, values: [:top, :bottom], default: :top)
  attr(:color, :any, default: nil, doc: "Optional inline background color override")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  @doc """
  Renders a reading progress bar fixed to the top or bottom of the page.

  The bar starts at `w-0` and grows to full width as the user scrolls.
  The PhiaPageProgress hook drives width changes via inline style updates.
  """
  def page_progress(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaPageProgress"
      role="progressbar"
      aria-label="Reading progress"
      aria-valuemin="0"
      aria-valuemax="100"
      aria-valuenow="0"
      style={@color && "background: #{@color}"}
      class={cn([
        position_class(@position),
        variant_class(@variant),
        @class
      ])}
      {@rest}
    />
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp position_class(:top),
    do: "fixed top-0 left-0 z-50 w-0 transition-[width] duration-100"

  defp position_class(:bottom),
    do: "fixed bottom-0 left-0 z-50 w-0 transition-[width] duration-100"

  defp variant_class(:default), do: "h-1 bg-primary"
  defp variant_class(:gradient), do: "h-1 bg-gradient-to-r from-primary to-accent"
  defp variant_class(:thin), do: "h-0.5 bg-primary"
end
