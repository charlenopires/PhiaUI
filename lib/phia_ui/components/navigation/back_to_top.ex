defmodule PhiaUi.Components.BackToTop do
  @moduledoc """
  Floating "back to top" button that appears after scrolling past a threshold.

  Reuses the `PhiaBackTop` hook from `priv/templates/js/hooks/back_top.js`.
  The hook reads `data-threshold` and `data-smooth`, and toggles `opacity-0` /
  `opacity-100` classes based on scroll position.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # back_to_top/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, default: "back-to-top", doc: "Required by phx-hook")
  attr(:threshold, :integer, default: 200, doc: "Scroll distance in px before the button appears")
  attr(:smooth, :boolean, default: true, doc: "Use smooth scroll when true")
  attr(:variant, :atom, values: [:circle, :pill], default: :circle)
  attr(:position, :atom, values: [:bottom_right, :bottom_left, :bottom_center], default: :bottom_right)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  @doc """
  Renders a floating scroll-to-top button controlled by the PhiaBackTop hook.

  The button starts hidden (`opacity-0`) and the hook toggles to `opacity-100`
  once the user has scrolled past the `threshold` value (default 200 px).
  """
  def back_to_top(assigns) do
    ~H"""
    <button
      id={@id}
      type="button"
      phx-hook="PhiaBackTop"
      data-threshold={@threshold}
      data-smooth={to_string(@smooth)}
      aria-label="Scroll to top"
      class={cn([
        "opacity-0 transition-opacity duration-300 z-50 fixed flex items-center justify-center",
        position_class(@position),
        variant_class(@variant),
        @class
      ])}
      {@rest}
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="20"
        height="20"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
        aria-hidden="true"
      >
        <line x1="12" y1="19" x2="12" y2="5" />
        <polyline points="5 12 12 5 19 12" />
      </svg>
      <span class="sr-only">Scroll to top</span>
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp position_class(:bottom_right), do: "bottom-6 right-6"
  defp position_class(:bottom_left), do: "bottom-6 left-6"
  defp position_class(:bottom_center), do: "bottom-6 left-1/2 -translate-x-1/2"

  defp variant_class(:circle),
    do: "h-10 w-10 rounded-full bg-primary text-primary-foreground shadow-md hover:bg-primary/90"

  defp variant_class(:pill),
    do: "h-10 rounded-full px-4 bg-primary text-primary-foreground shadow-md hover:bg-primary/90"
end
