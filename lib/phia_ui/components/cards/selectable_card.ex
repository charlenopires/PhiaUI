defmodule PhiaUi.Components.SelectableCard do
  @moduledoc """
  SelectableCard component — a card that acts as a radio button for visually rich option selection.

  Renders each option as a styled card with `role="radio"` and `aria-checked`. Wrap multiple
  cards in `selectable_card_group/1` (which carries `role="radiogroup"`) to form an accessible
  radio group. Zero JavaScript — all selection state is managed server-side via LiveView.

  ## Variants

  | Variant      | Description                          |
  |--------------|--------------------------------------|
  | `:default`   | Standard card with p-4 padding       |
  | `:compact`   | Tighter card with p-3 padding        |

  ## Examples

      <%!-- Simple plan picker --%>
      <.selectable_card_group>
        <.selectable_card selected={@plan == "free"} on_click="choose_plan" value="free">
          <:title>Free Plan</:title>
          <:description>Up to 3 projects</:description>
        </.selectable_card>
        <.selectable_card selected={@plan == "pro"} on_click="choose_plan" value="pro">
          <:icon>★</:icon>
          <:title>Pro Plan</:title>
          <:description>Unlimited projects</:description>
        </.selectable_card>
      </.selectable_card_group>

      <%!-- Compact variant --%>
      <.selectable_card variant={:compact} selected={true}>
        <:title>Compact</:title>
      </.selectable_card>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:value, :string, default: nil, doc: "Value sent as phx-value-value when clicked")

  attr(:selected, :boolean,
    default: false,
    doc: "Whether this card is the currently selected option"
  )

  attr(:on_click, :string,
    default: nil,
    doc: "LiveView event dispatched via phx-click"
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "Disables the card and prevents interaction"
  )

  attr(:variant, :atom,
    values: [:default, :compact],
    default: :default,
    doc: "Visual density — :default (p-4) or :compact (p-3)"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1")

  attr(:rest, :global,
    include: ~w(phx-click phx-value-value),
    doc: "HTML attributes forwarded to the root button element"
  )

  slot(:icon, doc: "Optional icon rendered to the left of the text content")
  slot(:title, required: true, doc: "Primary label for the option")
  slot(:description, doc: "Secondary supporting text rendered below the title")

  @doc """
  Renders a single selectable card option.

  ## Examples

      <.selectable_card selected={@choice == "a"} on_click="pick" value="a">
        <:title>Option A</:title>
        <:description>The first option</:description>
      </.selectable_card>
  """
  def selectable_card(assigns) do
    ~H"""
    <button
      type="button"
      role="radio"
      aria-checked={to_string(@selected)}
      phx-click={@on_click}
      phx-value-value={@value}
      disabled={@disabled}
      class={cn([
        "relative flex w-full cursor-pointer rounded-lg border p-4 text-left transition-colors",
        "focus:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
        @selected && "border-primary bg-primary/5 ring-2 ring-primary",
        !@selected && "border-border hover:border-primary/50 hover:bg-muted/50",
        @disabled && "cursor-not-allowed opacity-50 pointer-events-none",
        @variant == :compact && "p-3",
        @class
      ])}
      {@rest}
    >
      <div class={cn(["flex items-start", @icon != [] && "gap-3"])}>
        <div :if={@icon != []} class="shrink-0 text-lg leading-none">
          {render_slot(@icon)}
        </div>
        <div class="flex-1 min-w-0">
          <div class="text-sm font-medium text-foreground">
            {render_slot(@title)}
          </div>
          <div :if={@description != []} class="mt-1 text-sm text-muted-foreground">
            {render_slot(@description)}
          </div>
        </div>
      </div>
    </button>
    """
  end

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root div element")
  slot(:inner_block, required: true, doc: "Selectable card items")

  @doc """
  Renders a `role="radiogroup"` container that wraps multiple `selectable_card/1` components.

  ## Examples

      <.selectable_card_group>
        <.selectable_card selected={true}><:title>A</:title></.selectable_card>
        <.selectable_card><:title>B</:title></.selectable_card>
      </.selectable_card_group>
  """
  def selectable_card_group(assigns) do
    ~H"""
    <div role="radiogroup" class={cn(["grid gap-4", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
