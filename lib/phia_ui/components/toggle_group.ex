defmodule PhiaUi.Components.ToggleGroup do
  @moduledoc """
  ToggleGroup component for PhiaUI.

  Groups multiple `toggle_group_item/1` buttons into a single-select or
  multi-select widget with `role="group"`. Items compute their `pressed`
  state automatically based on the group `:value`.

  Use `:type "single"` when only one item can be active at a time (e.g.
  text alignment: left / center / right). Use `:type "multiple"` when
  several items can be active simultaneously (e.g. bold + italic).

  ## Examples

      <%!-- Single — text alignment toolbar --%>
      <.toggle_group type="single" value={@align} phx-change="set_align">
        <.toggle_group_item value="left"><.icon name="align-left" /></.toggle_group_item>
        <.toggle_group_item value="center"><.icon name="align-center" /></.toggle_group_item>
        <.toggle_group_item value="right"><.icon name="align-right" /></.toggle_group_item>
      </.toggle_group>

      <%!-- Multiple — text formatting toolbar --%>
      <.toggle_group type="multiple" value={@formats} phx-change="set_format">
        <.toggle_group_item value="bold">B</.toggle_group_item>
        <.toggle_group_item value="italic">I</.toggle_group_item>
        <.toggle_group_item value="underline">U</.toggle_group_item>
      </.toggle_group>

  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:type, :string,
    default: "single",
    values: ~w(single multiple),
    doc: "Selection mode: \"single\" (one active at a time) or \"multiple\"."
  )

  attr(:value, :any,
    default: nil,
    doc: """
    Currently selected value(s).
    For `:type \"single\"` — a string or `nil`.
    For `:type \"multiple\"` — a list of strings.
    """
  )

  attr(:variant, :string,
    default: "default",
    values: ~w(default outline),
    doc: "Passed to each item's Toggle button. \"default\" or \"outline\"."
  )

  attr(:size, :string,
    default: "default",
    values: ~w(default sm lg),
    doc: "Passed to each item's Toggle button. \"default\", \"sm\", or \"lg\"."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the group container."
  )

  attr(:rest, :global, doc: "HTML attributes forwarded to the group div.")

  slot(:inner_block, required: true, doc: "One or more `toggle_group_item/1` components.")

  @doc """
  Renders a group container that coordinates a set of toggle items.

  Exposes group context via `:let` so items can compute their pressed state:

      <.toggle_group :let={group} type="single" value={@align}>
        <.toggle_group_item value="left" {group}>L</.toggle_group_item>
        <.toggle_group_item value="center" {group}>C</.toggle_group_item>
      </.toggle_group>

  """
  def toggle_group(assigns) do
    ~H"""
    <div role="group" class={cn(["flex items-center gap-1", @class])} {@rest}>
      {render_slot(@inner_block, %{group_value: @value, group_type: @type, variant: @variant, size: @size})}
    </div>
    """
  end

  attr(:value, :string,
    required: true,
    doc: "The value this item represents within the group."
  )

  attr(:group_value, :any,
    default: nil,
    doc: "The group's current selected value(s). Determines :pressed state."
  )

  attr(:group_type, :string,
    default: "single",
    values: ~w(single multiple),
    doc: "Mirrors the parent group's :type for pressed-state calculation."
  )

  attr(:variant, :string,
    default: "default",
    values: ~w(default outline),
    doc: "Visual style forwarded from the parent group."
  )

  attr(:size, :string,
    default: "default",
    values: ~w(default sm lg),
    doc: "Size forwarded from the parent group."
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "When `true`, disables the item."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the button."
  )

  attr(:rest, :global,
    include: ~w(phx-click phx-value),
    doc: "HTML attributes forwarded to the button."
  )

  slot(:inner_block, required: true, doc: "Item label or icon.")

  @doc """
  Renders a single pressable item within a `toggle_group/1`.

  The `:pressed` state is computed automatically from `:group_value` and
  `:group_type`. In templates, pass `group_value={@group_value}` and
  `group_type={@group_type}` from the parent slot context when composing
  manually; or let the parent `toggle_group/1` handle it when nesting.
  """
  def toggle_group_item(assigns) do
    assigns =
      assign(
        assigns,
        :pressed,
        item_pressed?(assigns.group_type, assigns.group_value, assigns.value)
      )

    ~H"""
    <button
      type="button"
      aria-pressed={to_string(@pressed)}
      disabled={@disabled}
      class={cn([item_base_class(), item_variant_class(@variant, @pressed), item_size_class(@size), @disabled && "opacity-50 pointer-events-none", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp item_pressed?("single", group_value, value), do: group_value == value
  defp item_pressed?("multiple", nil, _value), do: false

  defp item_pressed?("multiple", group_value, value) when is_list(group_value),
    do: value in group_value

  defp item_pressed?("multiple", _group_value, _value), do: false

  defp item_base_class do
    "inline-flex items-center justify-center rounded-md text-sm font-medium " <>
      "transition-colors focus-visible:outline-none focus-visible:ring-2 " <>
      "focus-visible:ring-ring focus-visible:ring-offset-2 " <>
      "disabled:pointer-events-none disabled:opacity-50"
  end

  defp item_variant_class("default", false),
    do: "bg-transparent hover:bg-muted hover:text-muted-foreground"

  defp item_variant_class("default", true), do: "bg-accent text-accent-foreground"

  defp item_variant_class("outline", false),
    do: "border border-input bg-transparent hover:bg-accent hover:text-accent-foreground"

  defp item_variant_class("outline", true),
    do: "border border-input bg-accent text-accent-foreground"

  defp item_size_class("default"), do: "h-10 px-3"
  defp item_size_class("sm"), do: "h-9 px-2.5 text-xs"
  defp item_size_class("lg"), do: "h-11 px-5"
end
