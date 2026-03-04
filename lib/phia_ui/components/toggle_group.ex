defmodule PhiaUi.Components.ToggleGroup do
  @moduledoc """
  Coordinated group of toggle buttons for single or multi-select interactions.

  `toggle_group/1` groups multiple `toggle_group_item/1` buttons into a widget
  with `role="group"`. Items compute their `aria-pressed` state automatically
  based on the group's current `:value`, so you never need to pass `pressed`
  manually to each item.

  ## Sub-components

  | Function            | Purpose                                                      |
  |---------------------|--------------------------------------------------------------|
  | `toggle_group/1`    | Container with `role="group"`, coordinates item state        |
  | `toggle_group_item/1` | Individual button whose pressed state is derived from group value |

  ## Selection modes

  ### Single select (`type="single"`)

  Only one item can be active at a time. The group value is a string (or `nil`
  for no selection). Use for mutually exclusive choices like text alignment,
  view mode, or sort direction:

      <.toggle_group type="single" value={@align} phx-change="set_align">
        <.toggle_group_item value="left">
          <.icon name="align-left" size="sm" />
        </.toggle_group_item>
        <.toggle_group_item value="center">
          <.icon name="align-center" size="sm" />
        </.toggle_group_item>
        <.toggle_group_item value="right">
          <.icon name="align-right" size="sm" />
        </.toggle_group_item>
      </.toggle_group>

  ### Multi-select (`type="multiple"`)

  Multiple items can be active simultaneously. The group value is a list of
  strings. Use for text formatting (bold + italic), filter chips, or feature
  flags:

      <.toggle_group type="multiple" value={@formats} phx-change="set_format">
        <.toggle_group_item value="bold">B</.toggle_group_item>
        <.toggle_group_item value="italic">I</.toggle_group_item>
        <.toggle_group_item value="underline">U</.toggle_group_item>
        <.toggle_group_item value="strikethrough">S</.toggle_group_item>
      </.toggle_group>

  ## Using `:let` context

  When nesting items inside the group slot, the parent passes context via
  `:let`. Items use `{group}` spread to receive `group_value`, `group_type`,
  `variant`, and `size` from the parent automatically:

      <.toggle_group :let={group} type="single" value={@view_mode} variant="outline">
        <.toggle_group_item value="grid"  {group}><.icon name="grid" /></.toggle_group_item>
        <.toggle_group_item value="list"  {group}><.icon name="list" /></.toggle_group_item>
        <.toggle_group_item value="table" {group}><.icon name="table" /></.toggle_group_item>
      </.toggle_group>

  ## View mode switcher example

      defmodule MyAppWeb.ProductsLive do
        use MyAppWeb, :live_view

        def mount(_params, _session, socket) do
          {:ok, assign(socket, view_mode: "grid", filters: [])}
        end

        def handle_event("set_view", %{"value" => mode}, socket) do
          {:noreply, assign(socket, view_mode: mode)}
        end

        def handle_event("set_filter", %{"value" => filters}, socket) do
          {:noreply, assign(socket, filters: filters)}
        end
      end

      <%!-- In the template --%>
      <.toggle_group type="single" value={@view_mode} phx-change="set_view" variant="outline">
        <.toggle_group_item value="grid">Grid</.toggle_group_item>
        <.toggle_group_item value="list">List</.toggle_group_item>
      </.toggle_group>

  ## Text formatting toolbar (multi-select)

      <.toggle_group type="multiple" value={@active_formats} phx-change="set_format" size="sm">
        <.toggle_group_item value="bold"          aria-label="Bold">B</.toggle_group_item>
        <.toggle_group_item value="italic"        aria-label="Italic">I</.toggle_group_item>
        <.toggle_group_item value="underline"     aria-label="Underline">U</.toggle_group_item>
        <.toggle_group_item value="strikethrough" aria-label="Strikethrough">S</.toggle_group_item>
      </.toggle_group>

  ## Variants and sizes

  Both the `toggle_group/1` and `toggle_group_item/1` accept `:variant` and
  `:size`. Setting them on the group propagates to all items via the `:let`
  context — no need to set them on every item individually.

  - **Variants**: `"default"` (ghost-like), `"outline"` (bordered)
  - **Sizes**: `"sm"`, `"default"`, `"lg"`
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # toggle_group/1 — container
  # ---------------------------------------------------------------------------

  attr(:type, :string,
    default: "single",
    values: ~w(single multiple),
    doc: """
    Selection mode:
    - `"single"` — only one item can be active; `:value` is a string or `nil`
    - `"multiple"` — several items can be active; `:value` is a list of strings
    """
  )

  attr(:value, :any,
    default: nil,
    doc: """
    Currently selected value(s). Type depends on `:type`:
    - For `"single"`: a string matching one item's `:value`, or `nil` for no selection
    - For `"multiple"`: a list of strings, e.g. `["bold", "italic"]`

    This is passed down to each item via the slot context so items can compute
    their own `pressed` state.
    """
  )

  attr(:variant, :string,
    default: "default",
    values: ~w(default outline),
    doc: """
    Visual style propagated to all items:
    - `"default"` — ghost-like, transparent background
    - `"outline"` — bordered with `border-input`
    """
  )

  attr(:size, :string,
    default: "default",
    values: ~w(default sm lg),
    doc: """
    Button size propagated to all items:
    - `"sm"` — `h-9 px-2.5 text-xs` (compact toolbars)
    - `"default"` — `h-10 px-3`
    - `"lg"` — `h-11 px-5`
    """
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the group container `<div>`."
  )

  attr(:rest, :global,
    doc: """
    HTML attributes forwarded to the group `<div>`. Typically used for
    `phx-change` to notify the LiveView when the selection changes.
    """
  )

  slot(:inner_block,
    required: true,
    doc: """
    One or more `toggle_group_item/1` components. Use `:let={group}` on the
    parent to capture the context map, then spread `{group}` onto each item
    to propagate `group_value`, `group_type`, `variant`, and `size`.
    """
  )

  @doc """
  Renders a group container that coordinates a set of toggle items.

  Exposes group context via `:let` so items can compute their `pressed` state
  and inherit `variant`/`size` without repeating those attributes on each item:

      <.toggle_group :let={group} type="single" value={@align} variant="outline">
        <.toggle_group_item value="left"   {group}><.icon name="align-left" /></.toggle_group_item>
        <.toggle_group_item value="center" {group}><.icon name="align-center" /></.toggle_group_item>
        <.toggle_group_item value="right"  {group}><.icon name="align-right" /></.toggle_group_item>
      </.toggle_group>

  The `{group}` spread is equivalent to passing:
  `group_value={group.group_value} group_type={group.group_type} variant={group.variant} size={group.size}`

  ## Examples

      <%!-- Single select — text alignment --%>
      <.toggle_group type="single" value={@align} phx-change="set_align">
        <.toggle_group_item value="left">Left</.toggle_group_item>
        <.toggle_group_item value="center">Center</.toggle_group_item>
        <.toggle_group_item value="right">Right</.toggle_group_item>
      </.toggle_group>

      <%!-- Multi-select — active filters --%>
      <.toggle_group type="multiple" value={@active_filters} phx-change="toggle_filter" size="sm" variant="outline">
        <.toggle_group_item value="in_stock">In stock</.toggle_group_item>
        <.toggle_group_item value="on_sale">On sale</.toggle_group_item>
        <.toggle_group_item value="new_arrivals">New arrivals</.toggle_group_item>
      </.toggle_group>
  """
  def toggle_group(assigns) do
    ~H"""
    <div role="group" class={cn(["flex items-center gap-1", @class])} {@rest}>
      {render_slot(@inner_block, %{group_value: @value, group_type: @type, variant: @variant, size: @size})}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # toggle_group_item/1 — individual item
  # ---------------------------------------------------------------------------

  attr(:value, :string,
    required: true,
    doc: """
    The value this item represents within the group. For `type="single"`, this
    string is compared against the group value. For `type="multiple"`, membership
    in the group value list is checked.
    """
  )

  attr(:group_value, :any,
    default: nil,
    doc: """
    The group's current selected value(s). Used to compute this item's `pressed`
    state. In typical usage, this is passed via the `{group}` spread from the
    parent's `:let` context — you do not need to set it manually.
    """
  )

  attr(:group_type, :string,
    default: "single",
    values: ~w(single multiple),
    doc: """
    The parent group's selection type. Used for the `pressed` calculation:
    - `"single"`: pressed when `group_value == value`
    - `"multiple"`: pressed when `value in group_value`
    Inherited from the group context via `{group}` spread in typical usage.
    """
  )

  attr(:variant, :string,
    default: "default",
    values: ~w(default outline),
    doc: """
    Visual style of the button. Normally inherited from the group via `{group}` spread.
    Override per-item only when you need a different style than the group default.
    """
  )

  attr(:size, :string,
    default: "default",
    values: ~w(default sm lg),
    doc: """
    Button size. Normally inherited from the group via `{group}` spread.
    Override per-item only when individual sizing is needed.
    """
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "When `true`, disables this item. It becomes non-interactive and renders at 50% opacity."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes applied to the `<button>` element via `cn/1`."
  )

  attr(:rest, :global,
    include: ~w(phx-click phx-value),
    doc: """
    HTML attributes forwarded to the `<button>` element. Typically used for
    per-item `phx-click` handlers when items need individual event handling
    rather than a group-level `phx-change`.
    """
  )

  slot(:inner_block,
    required: true,
    doc: "Item content — typically a short text label or an icon component."
  )

  @doc """
  Renders a single pressable item within a `toggle_group/1`.

  The `:pressed` state is computed at render time from `:group_type` and
  `:group_value`, so the template stays declarative. In normal usage, pass
  context from the parent via `{group}` spread:

      <.toggle_group :let={group} type="multiple" value={@formats}>
        <.toggle_group_item value="bold"   {group}>B</.toggle_group_item>
        <.toggle_group_item value="italic" {group}>I</.toggle_group_item>
      </.toggle_group>

  ## Examples

      <%!-- Inside a single-select group --%>
      <.toggle_group :let={g} type="single" value={@mode}>
        <.toggle_group_item value="grid"  {g}><.icon name="grid" /></.toggle_group_item>
        <.toggle_group_item value="list"  {g}><.icon name="list" /></.toggle_group_item>
      </.toggle_group>

      <%!-- Manual usage (no group context) --%>
      <.toggle_group_item
        value="bold"
        group_value={@active_formats}
        group_type="multiple"
      >
        Bold
      </.toggle_group_item>

      <%!-- Disabled item within a group --%>
      <.toggle_group :let={g} type="single" value={@mode}>
        <.toggle_group_item value="grid" {g}>Grid</.toggle_group_item>
        <.toggle_group_item value="table" {g} disabled>Table (coming soon)</.toggle_group_item>
      </.toggle_group>
  """
  def toggle_group_item(assigns) do
    assigns =
      assign(
        assigns,
        :pressed,
        # Compute pressed at assign time to keep the ~H template clean.
        # The calculation delegates to item_pressed?/3 which handles both
        # single (string equality) and multiple (list membership) modes.
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

  # Single mode: simple string equality.
  defp item_pressed?("single", group_value, value), do: group_value == value

  # Multiple mode: guard against nil before calling `in` (which requires an enumerable).
  defp item_pressed?("multiple", nil, _value), do: false

  # Multiple mode: standard list membership check.
  defp item_pressed?("multiple", group_value, value) when is_list(group_value),
    do: value in group_value

  # Multiple mode: catch-all for unexpected non-list group_value in multiple mode.
  # Fails gracefully (returns false) rather than raising a runtime error.
  defp item_pressed?("multiple", _group_value, _value), do: false

  # Shared structural classes for all items, regardless of variant or size.
  defp item_base_class do
    "inline-flex items-center justify-center rounded-md text-sm font-medium " <>
      "transition-colors focus-visible:outline-none focus-visible:ring-2 " <>
      "focus-visible:ring-ring focus-visible:ring-offset-2 " <>
      "disabled:pointer-events-none disabled:opacity-50"
  end

  # Four-clause match for variant × pressed combinations.
  # Each clause returns a self-contained set of classes for clarity.
  defp item_variant_class("default", false),
    do: "bg-transparent hover:bg-muted hover:text-muted-foreground"

  defp item_variant_class("default", true), do: "bg-accent text-accent-foreground"

  defp item_variant_class("outline", false),
    do: "border border-input bg-transparent hover:bg-accent hover:text-accent-foreground"

  defp item_variant_class("outline", true),
    do: "border border-input bg-accent text-accent-foreground"

  # Size mapping mirrors shadcn/ui conventions for consistency.
  defp item_size_class("default"), do: "h-10 px-3"
  defp item_size_class("sm"), do: "h-9 px-2.5 text-xs"
  defp item_size_class("lg"), do: "h-11 px-5"
end
