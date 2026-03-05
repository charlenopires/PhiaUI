defmodule PhiaUi.Components.Separator do
  @moduledoc """
  Thin divider line for separating content regions.

  Renders a horizontal or vertical separator using `bg-border` — the
  semantic Tailwind token that adapts to light and dark mode automatically.
  Zero JavaScript — purely CSS.

  ## Decorative vs structural separators

  The `:decorative` attribute controls ARIA semantics:

  | `decorative` | `role`        | Screen reader behaviour                  |
  |-------------|---------------|------------------------------------------|
  | `true` (default) | `"none"` | Hidden from assistive technologies       |
  | `false`     | `"separator"` | Announced as a structural boundary + orientation |

  Use `decorative: false` when the separator meaningfully divides distinct
  content regions (e.g. between a nav and main content area). Use the
  default `decorative: true` for purely visual spacing.

  ## Horizontal separator (default)

  The standard use case — divides stacked content sections:

      <.separator />

      <%!-- With vertical breathing room --%>
      <.separator class="my-4" />

  ## Vertical separator

  Must be inside a flex container with a defined height to be visible:

      <div class="flex h-8 items-center gap-4">
        <span>Cut</span>
        <.separator orientation="vertical" />
        <span>Copy</span>
        <.separator orientation="vertical" />
        <span>Paste</span>
      </div>

  ## In a card header

      <.card>
        <.card_header>
          <.card_title>Account Settings</.card_title>
        </.card_header>
        <.separator />
        <.card_content>
          ...
        </.card_content>
      </.card>

  ## Structural separator (accessible)

  When the separator represents a meaningful boundary between landmark
  regions, disable decorative mode so screen readers announce it:

      <.separator decorative={false} />

  ## In a command/shortcut list

      <.separator class="my-1" />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:orientation, :string,
    default: "horizontal",
    values: ~w(horizontal vertical),
    doc:
      "Direction of the separator: `\"horizontal\"` (default, full width, 1px tall) or `\"vertical\"` (full height, 1px wide). Vertical separators must be inside a flex container with a defined height."
  )

  attr(:decorative, :boolean,
    default: true,
    doc: """
    Controls ARIA visibility.
    - `true` (default): purely visual (`role="none"`, hidden from screen readers).
    - `false`: structural boundary (`role="separator"` with `aria-orientation`).
    """
  )

  attr(:class, :string,
    default: nil,
    doc:
      "Additional CSS classes. Use `my-N` for horizontal spacing, or pass custom width/height overrides."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element.")

  @doc """
  Renders a visual or structural separator line.

  The separator is a single-pixel `<div>` coloured with the `bg-border`
  semantic token. On horizontal orientation it spans full width (`w-full`).
  On vertical orientation it spans full height (`h-full`), requiring the
  parent to have a fixed or flex-constrained height.
  """
  def separator(assigns) do
    ~H"""
    <div
      role={separator_role(@decorative)}
      aria-orientation={separator_aria_orientation(@decorative, @orientation)}
      class={cn([separator_class(@orientation), @class])}
      {@rest}
    >
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Decorative separators use role="none" to remove them from the
  # accessibility tree entirely — they are purely visual.
  defp separator_role(true), do: "none"
  # Structural separators use role="separator" so AT announces the boundary.
  defp separator_role(false), do: "separator"

  # aria-orientation is only meaningful for role="separator"; omit it for
  # decorative separators to keep the DOM clean.
  defp separator_aria_orientation(true, _orientation), do: nil
  defp separator_aria_orientation(false, orientation), do: orientation

  # Horizontal: 1px height, full width — the classic horizontal rule
  defp separator_class("horizontal"), do: "h-px w-full bg-border"
  # Vertical: 1px width, full height — for use inside flex containers
  defp separator_class("vertical"), do: "w-px h-full bg-border"
end
