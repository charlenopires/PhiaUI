defmodule PhiaUi.Components.InputGroup do
  @moduledoc """
  Horizontal group of connected inputs sharing a unified border.

  Provides `input_group/1` — a flex container that visually joins two or more
  inputs (or a mix of inputs and addons) into a single compound control. Middle
  dividers are handled by the bordered children; the outer wrapper provides the
  shared focus ring and rounded corners.

  ## When to use

  Use `input_group/1` to logically group related fields side by side:

  - First name + Last name on the same row
  - City + State + Zip code
  - Min price + Max price range
  - Date from + Date to
  - Amount + Currency unit

  For prefix/suffix decorators on a single input, use `input_addon/1` instead.

  ## Basic usage

      <%!-- First + Last name --%>
      <.input_group label="Full name">
        <:item>
          <input type="text" name="first_name" placeholder="First" />
        </:item>
        <:item>
          <input type="text" name="last_name" placeholder="Last" />
        </:item>
      </.input_group>

      <%!-- Price range --%>
      <.input_group label="Price range">
        <:item label="Min">
          <input type="number" name="price_min" placeholder="0" />
        </:item>
        <:item label="Max">
          <input type="number" name="price_max" placeholder="9999" />
        </:item>
      </.input_group>

      <%!-- City / State / Zip --%>
      <.input_group>
        <:item>
          <input type="text" name="city" placeholder="City" class="flex-[2]" />
        </:item>
        <:item>
          <input type="text" name="state" placeholder="State" />
        </:item>
        <:item>
          <input type="text" name="zip" placeholder="Zip" />
        </:item>
      </.input_group>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # input_group/1
  # ---------------------------------------------------------------------------

  attr(:label, :string,
    default: nil,
    doc: "Group-level label rendered above the connected inputs."
  )

  attr(:description, :string,
    default: nil,
    doc: "Helper text rendered below the label."
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "When true, renders the wrapper as visually disabled."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged into the outer wrapper."
  )

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the wrapper element."
  )

  slot(:item,
    required: true,
    doc: "Each individual input in the group. Use the `:label` field for per-item labels."
  ) do
    attr(:label, :string, doc: "Optional micro-label above this specific input.")
  end

  @doc """
  Renders two or more inputs joined into a single compound control.

  Each `<:item>` slot renders a child in a flex row. The outer wrapper provides:
  - A shared rounded border (`rounded-md border border-input`)
  - `focus-within:ring-2` focus ring at the group level
  - Middle dividers via `border-l border-input` on items after the first

  Items must contain a native `<input>` with no outer border:
  pass `class="border-0 focus:ring-0 w-full bg-transparent ..."` on the input,
  or use `<.phia_input>` stripped to its inner element.

  ## Example

      <.input_group label="Shipping address">
        <:item label="Street">
          <input type="text" name="street" placeholder="123 Main St"
                 class="h-10 w-full border-0 bg-transparent px-3 text-sm focus:outline-none" />
        </:item>
        <:item label="Apt / Suite">
          <input type="text" name="apt" placeholder="Apt 4B"
                 class="h-10 w-full border-0 bg-transparent px-3 text-sm focus:outline-none" />
        </:item>
      </.input_group>
  """
  def input_group(assigns) do
    ~H"""
    <div class={cn(["space-y-2", @class])} {@rest}>
      <label :if={@label} class="text-sm font-medium leading-none">
        {@label}
      </label>
      <p :if={@description} class="text-sm text-muted-foreground">{@description}</p>

      <div class={cn([
        "flex w-full overflow-hidden rounded-md border border-input bg-background",
        "focus-within:ring-2 focus-within:ring-ring focus-within:ring-offset-2",
        @disabled && "cursor-not-allowed opacity-50"
      ])}>
        <%= for {item, idx} <- Enum.with_index(@item) do %>
          <div class={cn([
            "flex flex-col flex-1 min-w-0",
            idx > 0 && "border-l border-input"
          ])}>
            <span
              :if={Map.get(item, :label)}
              class="px-3 pt-1.5 text-[10px] font-medium text-muted-foreground uppercase tracking-wide leading-none"
            >
              {Map.get(item, :label)}
            </span>
            <div class="flex-1 flex items-center">
              {render_slot(item)}
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
