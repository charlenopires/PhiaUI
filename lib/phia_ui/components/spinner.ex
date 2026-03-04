defmodule PhiaUi.Components.Spinner do
  @moduledoc """
  Animated loading spinner component.

  A circular SVG spinner that inherits color from `currentColor` (i.e. the
  surrounding text color). Use Tailwind color utilities on the spinner itself
  or any ancestor element to control the spinner color.

  ## Sizes

  | Size       | Dimensions |
  |------------|------------|
  | `:xs`      | h-3 w-3    |
  | `:sm`      | h-4 w-4    |
  | `:default` | h-6 w-6    |
  | `:lg`      | h-8 w-8    |
  | `:xl`      | h-12 w-12  |

  ## Examples

      <%!-- Default spinner with "Loading" screen-reader label --%>
      <.spinner />

      <%!-- Large spinner --%>
      <.spinner size={:lg} />

      <%!-- Spinner with custom color via text utility --%>
      <.spinner class="text-primary" />

      <%!-- Spinner with custom accessible label --%>
      <.spinner label="Loading data..." />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:size, :atom,
    values: [:xs, :sm, :default, :lg, :xl],
    default: :default,
    doc: "Controls the width and height of the spinner SVG"
  )

  attr(:label, :string,
    default: "Loading",
    doc: "Accessible label — rendered as aria-label and as sr-only text inside the spinner"
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged onto the SVG element via cn/1"
  )

  @doc """
  Renders an animated SVG circular spinner.

  The spinner uses `role="status"`, `aria-live="polite"`, and an
  `aria-label` attribute for full screen-reader support. A `<span
  class="sr-only">` containing the label text is also rendered inside the
  wrapper so screen readers that do not announce `aria-label` on non-focusable
  elements still receive the label.

  Color is inherited from `currentColor`, so wrapping the spinner in a
  `text-*` utility class (or placing the spinner inside an already-colored
  element) is the recommended way to control the spinner color.

  ## Examples

      <.spinner />

      <.spinner size={:xl} label="Uploading file..." class="text-primary" />
  """
  def spinner(assigns) do
    ~H"""
    <div role="status" aria-label={@label} aria-live="polite">
      <svg
        class={cn(["animate-spin", size_class(@size), @class])}
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
      >
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
        <path
          class="opacity-75"
          fill="currentColor"
          d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
        />
      </svg>
      <span class="sr-only">{@label}</span>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private class helpers — pattern matching, no case/cond
  # ---------------------------------------------------------------------------

  defp size_class(:xs), do: "h-3 w-3"
  defp size_class(:sm), do: "h-4 w-4"
  defp size_class(:default), do: "h-6 w-6"
  defp size_class(:lg), do: "h-8 w-8"
  defp size_class(:xl), do: "h-12 w-12"
end
