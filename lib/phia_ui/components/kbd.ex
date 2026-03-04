defmodule PhiaUi.Components.Kbd do
  @moduledoc """
  Keyboard shortcut display component.

  Renders a semantic `<kbd>` HTML element styled to resemble a physical
  keyboard key. Use it in tooltips, help overlays, command menus, and
  instructional UI text to communicate keyboard shortcuts clearly.

  The `<kbd>` element is part of HTML5 and carries semantic meaning:
  screen readers may announce it with a distinct tone, and it appears
  in the accessibility tree as a keyboard input element.

  ## Examples

  ### Single key

      <p>Press <.kbd>Enter</.kbd> to submit.</p>

  ### Modifier + key combination

  Render individual `<kbd>` elements for each key in the combination,
  separated by a `+` character or within a flex container:

      <span class="flex items-center gap-1">
        <.kbd>⌘</.kbd>
        <span class="text-muted-foreground text-xs">+</span>
        <.kbd>K</.kbd>
      </span>

  ### Common modifier symbols

  Use Unicode characters for standard modifier keys:
  - `⌘` — Command (macOS)
  - `⌃` — Control
  - `⌥` — Option / Alt
  - `⇧` — Shift
  - `⌫` — Backspace / Delete

  ### In a command menu (Command+K shortcut hint)

      <div class="flex items-center justify-between">
        <span class="text-sm">Search</span>
        <span class="flex items-center gap-0.5">
          <.kbd>⌘</.kbd>
          <.kbd>K</.kbd>
        </span>
      </div>

  ### In a tooltip

      <.tooltip>
        <:trigger>
          <.button variant={:ghost} size={:icon}>
            <.icon name="save" />
          </.button>
        </:trigger>
        <:content>
          Save
          <span class="ml-2 flex items-center gap-0.5">
            <.kbd>⌘</.kbd><.kbd>S</.kbd>
          </span>
        </:content>
      </.tooltip>

  ### In a help table

      <table>
        <tbody>
          <tr>
            <td>Open search</td>
            <td class="flex gap-1"><.kbd>⌘</.kbd><.kbd>K</.kbd></td>
          </tr>
          <tr>
            <td>Close dialog</td>
            <td><.kbd>Esc</.kbd></td>
          </tr>
          <tr>
            <td>Submit form</td>
            <td><.kbd>Enter</.kbd></td>
          </tr>
        </tbody>
      </table>

  ### Custom size

      <%!-- Smaller kbd for dense UI --%>
      <.kbd class="text-[9px] h-4">Tab</.kbd>

  ## Accessibility

  The `<kbd>` element is natively understood by screen readers. Wrap
  combinations in a `<span aria-label="Command K">` when you need to
  ensure the full shortcut is announced as a unit rather than individual
  characters.
  """

  use Phoenix.Component
  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via `cn/1`. Use `text-[N]` to override font size or `h-N` to change height.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the `<kbd>` element.")
  slot(:inner_block, required: true, doc: "Key label, symbol, or text. Use Unicode modifier symbols (⌘, ⌃, ⌥, ⇧) for macOS, or text labels (Ctrl, Alt, Shift) for cross-platform display.")

  @doc """
  Renders a styled `<kbd>` element representing a keyboard key or shortcut.

  Applies a border, subtle shadow, and monospace font to mimic the
  appearance of a physical keyboard key. The `select-none` utility prevents
  accidental text selection when clicking shortcut hints.

  Inherits semantic meaning from the HTML `<kbd>` element — screen readers
  may announce keyboard input context for the contained text.

  ## Example

      <p>Press <.kbd>Escape</.kbd> to cancel.</p>
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

  # Base visual style: compact pill, monospace font, subtle border+shadow.
  # `select-none` prevents the user from accidentally selecting the key label
  # as text when clicking a UI element that contains a kbd hint.
  defp base_class do
    "inline-flex h-5 select-none items-center gap-1 rounded border " <>
      "border-border bg-muted px-1.5 font-mono text-[10px] font-medium " <>
      "text-muted-foreground shadow-sm"
  end
end
