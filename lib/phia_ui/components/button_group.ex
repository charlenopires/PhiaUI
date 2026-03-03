defmodule PhiaUi.Components.ButtonGroup do
  @moduledoc """
  Groups multiple buttons into a unified bar with shared borders.

  Renders a wrapper `<div>` that applies CSS child-selectors to unify adjacent
  buttons visually: shared borders without duplication and rounded corners only
  on the outermost edges of the group.

  Supports horizontal (default) and vertical orientations. Works with any
  `PhiaUi.Components.Button` variant as well as plain `<button>` elements.

  ## Orientations

  | Orientation  | Layout         | Border trick |
  |--------------|----------------|--------------|
  | `horizontal` | `inline-flex`  | `-ml-px` on non-first children |
  | `vertical`   | `flex-col`     | `-mt-px` on non-first children |

  ## Examples

      <.button_group>
        <.button>Cut</.button>
        <.button>Copy</.button>
        <.button>Paste</.button>
      </.button_group>

      <.button_group orientation="vertical">
        <.button variant={:outline}>Top</.button>
        <.button variant={:outline}>Bottom</.button>
      </.button_group>

      <.button_group class="w-full">
        <.button class="flex-1">Left</.button>
        <.button class="flex-1">Right</.button>
      </.button_group>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:orientation, :string,
    default: "horizontal",
    values: ~w(horizontal vertical),
    doc: "Group orientation: 'horizontal' (default) or 'vertical'"
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged via cn/1"
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the root <div> element")

  slot(:inner_block, required: true, doc: "Button components to group")

  @doc """
  Renders a button group container that unifies multiple buttons visually.

  Child buttons share borders without duplication. Border-radius is applied
  only on the outermost corners, giving the group a unified pill-strip
  appearance. All Button variants and sizes remain fully functional inside
  the group.
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

  defp group_classes("horizontal") do
    "inline-flex " <>
      "[&>*:not(:first-child)]:-ml-px " <>
      "[&>*:first-child]:rounded-r-none " <>
      "[&>*:last-child]:rounded-l-none " <>
      "[&>*:not(:first-child):not(:last-child)]:rounded-none"
  end

  defp group_classes("vertical") do
    "inline-flex flex-col " <>
      "[&>*:not(:first-child)]:-mt-px " <>
      "[&>*:first-child]:rounded-b-none " <>
      "[&>*:last-child]:rounded-t-none " <>
      "[&>*:not(:first-child):not(:last-child)]:rounded-none"
  end
end
