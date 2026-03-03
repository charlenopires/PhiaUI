defmodule PhiaUi.Components.Separator do
  @moduledoc """
  Separator component for PhiaUI.

  Renders a thin horizontal or vertical divider line using semantic Tailwind
  tokens. Zero JavaScript — purely CSS via `bg-border`.

  When `:decorative` is `true` (default), the separator is hidden from
  assistive technologies (`role="none"`). Set `:decorative` to `false` for
  structural separators (e.g. dividing nav regions) — this adds
  `role="separator"` and `aria-orientation`.

  ## Examples

      <%!-- Horizontal (default) --%>
      <.separator />

      <%!-- With spacing --%>
      <.separator class="my-4" />

      <%!-- Vertical (inside a flex container) --%>
      <div class="flex h-8 items-center gap-2">
        <span>Left</span>
        <.separator orientation="vertical" />
        <span>Right</span>
      </div>

      <%!-- Structural separator (visible to screen readers) --%>
      <.separator decorative={false} />

  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:orientation, :string,
    default: "horizontal",
    values: ~w(horizontal vertical),
    doc: "Direction of the separator: \"horizontal\" (default) or \"vertical\"."
  )

  attr(:decorative, :boolean,
    default: true,
    doc: """
    When `true` (default), the separator is purely visual (`role=\"none\"`).
    When `false`, it is meaningful to assistive technologies (`role=\"separator\"`
    with `aria-orientation`).
    """
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the element."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element.")

  @doc """
  Renders a visual or structural separator line.
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

  defp separator_role(true), do: "none"
  defp separator_role(false), do: "separator"

  defp separator_aria_orientation(true, _orientation), do: nil
  defp separator_aria_orientation(false, orientation), do: orientation

  defp separator_class("horizontal"), do: "h-px w-full bg-border"
  defp separator_class("vertical"), do: "w-px h-full bg-border"
end
