defmodule PhiaUi.Components.ButtonGroup do
  @moduledoc """
  Groups multiple buttons into a unified bar with shared borders.

  Renders a wrapper `<div>` that uses Tailwind CSS child-selectors (`[&>*]`)
  to unify adjacent buttons visually: borders are shared without duplication,
  and rounded corners are applied only to the outermost edges of the group.

  Works with any `PhiaUi.Components.Button` variant as well as plain
  `<button>` elements.

  ## Orientations

  | Orientation   | Layout        | Negative margin trick              |
  |---------------|---------------|------------------------------------|
  | `"horizontal"`| `inline-flex` | `-ml-px` collapses adjacent borders|
  | `"vertical"`  | `flex-col`    | `-mt-px` collapses adjacent borders|

  ## How border collapsing works

  Without the group, each button has a full border (4 sides). When placed
  side-by-side, adjacent borders double up to 2px visually. The group
  solves this with CSS child selectors:

  - `[&>*:not(:first-child)]:-ml-px` — shifts all buttons except the first
    1px to the left, collapsing the shared border to a single pixel.
  - `[&>*:first-child]:rounded-r-none` — removes the right radius of the
    first button so it connects flush with its neighbour.
  - `[&>*:last-child]:rounded-l-none` — removes the left radius of the last.
  - `[&>*:not(:first-child):not(:last-child)]:rounded-none` — removes all
    radius from middle buttons.

  ## Examples

  ### Toolbar with text actions

      <.button_group>
        <.button variant={:outline}>
          <.icon name="bold" size={:sm} />
        </.button>
        <.button variant={:outline}>
          <.icon name="italic" size={:sm} />
        </.button>
        <.button variant={:outline}>
          <.icon name="underline" size={:sm} />
        </.button>
      </.button_group>

  ### Clipboard actions (cut / copy / paste)

      <.button_group>
        <.button>Cut</.button>
        <.button>Copy</.button>
        <.button>Paste</.button>
      </.button_group>

  ### View toggle (vertical)

      <.button_group orientation="vertical">
        <.button variant={:outline}>List view</.button>
        <.button variant={:outline}>Grid view</.button>
        <.button variant={:outline}>Board view</.button>
      </.button_group>

  ### Full-width two-column split

      <.button_group class="w-full">
        <.button variant={:outline} class="flex-1">Cancel</.button>
        <.button class="flex-1">Confirm</.button>
      </.button_group>

  ### Binary toggle (e.g. show/hide password)

      <.button_group>
        <.button variant={if @show_raw, do: :default, else: :outline} phx-click="toggle_view" phx-value-view="raw">
          Raw
        </.button>
        <.button variant={if @show_raw, do: :outline, else: :default} phx-click="toggle_view" phx-value-view="preview">
          Preview
        </.button>
      </.button_group>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:orientation, :string,
    default: "horizontal",
    values: ~w(horizontal vertical),
    doc: "Group layout direction: `\"horizontal\"` (default, side-by-side) or `\"vertical\"` (stacked)."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged via `cn/1`. Use `w-full` to stretch the group to full width."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>` element.")

  slot(:inner_block, required: true, doc: "Button components to group. Any `PhiaUi.Components.Button` variant or plain `<button>` works.")

  @doc """
  Renders a button group container that unifies multiple buttons visually.

  Child buttons share borders without duplication. Border-radius is applied
  only on the outermost corners, giving the group a single unified pill-strip
  appearance. All Button variants and sizes remain fully functional inside
  the group.

  The CSS `[&>*]` selector targets direct children only, so nested content
  inside each button is unaffected.
  """
  def button_group(assigns) do
    ~H"""
    <div class={cn([group_classes(@orientation), @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private class helpers — pattern matching, never case/cond
  # ---------------------------------------------------------------------------

  # Horizontal: buttons sit side-by-side. The -ml-px trick collapses the
  # shared right/left border between adjacent buttons to a single pixel.
  defp group_classes("horizontal") do
    "inline-flex " <>
      "[&>*:not(:first-child)]:-ml-px " <>
      "[&>*:first-child]:rounded-r-none " <>
      "[&>*:last-child]:rounded-l-none " <>
      "[&>*:not(:first-child):not(:last-child)]:rounded-none"
  end

  # Vertical: buttons stack top-to-bottom. The -mt-px trick collapses the
  # shared bottom/top border between stacked buttons.
  defp group_classes("vertical") do
    "inline-flex flex-col " <>
      "[&>*:not(:first-child)]:-mt-px " <>
      "[&>*:first-child]:rounded-b-none " <>
      "[&>*:last-child]:rounded-t-none " <>
      "[&>*:not(:first-child):not(:last-child)]:rounded-none"
  end
end
