defmodule PhiaUi.Components.BackTop do
  @moduledoc """
  BackTop component — a floating "scroll to top" button.

  Rendered as a fixed circular button in the bottom-right corner of the
  viewport. It starts invisible (`opacity-0`) and becomes visible
  (`opacity-100`) once the user has scrolled past the configured threshold.
  Scrolling behaviour is handled by the `PhiaBackTop` LiveView hook defined
  in `priv/templates/js/hooks/back_top.js`.

  ## Examples

      <%!-- Default: shows after 200 px, smooth scroll --%>
      <.back_top />

      <%!-- Custom threshold and label --%>
      <.back_top threshold={400} aria_label="Back to top" />

      <%!-- Disable smooth scroll --%>
      <.back_top smooth={false} />

      <%!-- Additional CSS classes --%>
      <.back_top class="z-50" />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:id, :string,
    default: "back-top",
    doc: "HTML id for the button element"
  )

  attr(:threshold, :integer,
    default: 200,
    doc: "Scroll distance in pixels before the button becomes visible"
  )

  attr(:smooth, :boolean,
    default: true,
    doc: "When true, scrolls smoothly to the top; false uses instant jump"
  )

  attr(:aria_label, :string,
    default: "Scroll to top",
    doc: "Accessible label for the button"
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged via cn/1"
  )

  @doc """
  Renders a fixed floating button that scrolls the page to the top.

  The button starts invisible and is shown by the `PhiaBackTop` JS hook
  once the page scroll exceeds `threshold` pixels. Clicking the button
  scrolls to the top using the browser's native `scrollTo` API.

  ## Examples

      <.back_top />

      <.back_top threshold={300} smooth={false} aria_label="Go to top" />

      <.back_top class="z-50" />
  """
  def back_top(assigns) do
    ~H"""
    <button
      id={@id}
      type="button"
      phx-hook="PhiaBackTop"
      data-threshold={@threshold}
      data-smooth={to_string(@smooth)}
      aria-label={@aria_label}
      class={cn([
        "fixed bottom-6 right-6 h-10 w-10 rounded-full",
        "bg-primary text-primary-foreground shadow-lg",
        "flex items-center justify-center",
        "opacity-0 transition-opacity",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
        @class
      ])}
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        class="h-5 w-5"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        aria-hidden="true"
      >
        <polyline points="18 15 12 9 6 15" />
      </svg>
      <span class="sr-only">{@aria_label}</span>
    </button>
    """
  end
end
