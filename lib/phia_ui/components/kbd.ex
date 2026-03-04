defmodule PhiaUi.Components.Kbd do
  @moduledoc """
  Keyboard shortcut display component for PhiaUI.

  Renders a semantic `<kbd>` HTML element styled to look like a physical
  keyboard key. Use it to display keyboard shortcuts, hotkeys, and modifier
  keys in UI text, tooltips, or help overlays.

  ## Examples

      <%!-- Single key --%>
      <.kbd>Enter</.kbd>

      <%!-- Modifier combination --%>
      <span class="flex items-center gap-1">
        <.kbd>⌘</.kbd>
        <.kbd>K</.kbd>
      </span>

      <%!-- In context --%>
      <p>Press <.kbd>Escape</.kbd> to close.</p>

      <%!-- Custom size --%>
      <.kbd class="text-xs">Tab</.kbd>
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the kbd element")
  slot(:inner_block, required: true, doc: "Key label or symbol")

  @doc """
  Renders a styled `<kbd>` element representing a keyboard key or shortcut.

  Styled with a subtle border and shadow to mimic a physical key appearance.
  Inherits semantic meaning from the HTML `<kbd>` element for screen readers.
  """
  def kbd(assigns) do
    ~H"""
    <kbd class={cn([base_class(), @class])} {@rest}>
      {render_slot(@inner_block)}
    </kbd>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp base_class do
    "inline-flex h-5 select-none items-center gap-1 rounded border " <>
      "border-border bg-muted px-1.5 font-mono text-[10px] font-medium " <>
      "text-muted-foreground shadow-sm"
  end
end
