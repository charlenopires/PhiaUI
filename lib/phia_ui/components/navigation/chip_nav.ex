defmodule PhiaUi.Components.ChipNav do
  @moduledoc """
  Chip-style filter/tag navigation component.

  Provides two components:

  - `chip_nav/1` — horizontally-scrollable chip container
  - `chip_nav_item/1` — pill-shaped item rendered as `<a>` or `<button>`
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # chip_nav/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil)
  attr(:scrollable, :boolean, default: true)
  attr(:gap, :atom, values: [:sm, :md], default: :md)
  attr(:rest, :global)

  slot(:inner_block, required: true)

  def chip_nav(assigns) do
    ~H"""
    <div
      class={cn([
        "flex items-center pb-1",
        @scrollable && "overflow-x-auto scrollbar-none",
        chip_nav_gap_class(@gap),
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # chip_nav_item/1
  # ---------------------------------------------------------------------------

  attr(:active, :boolean, default: false)
  attr(:href, :string, default: nil)
  attr(:on_click, :string, default: nil)
  attr(:disabled, :boolean, default: false)
  attr(:variant, :atom, values: [:default, :outline, :ghost], default: :default)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, required: true)
  slot(:icon)

  def chip_nav_item(assigns) do
    ~H"""
    <%= if @href do %>
      <a
        href={@href}
        aria-current={@active && "page"}
        class={cn([
          "inline-flex items-center gap-1.5 rounded-full px-3 py-1.5 text-sm font-medium whitespace-nowrap transition-colors",
          chip_item_variant_class(@variant, @active),
          @disabled && "pointer-events-none opacity-50",
          @class
        ])}
        {@rest}
      >
        <span :if={@icon != []} class="shrink-0">{render_slot(@icon)}</span>
        {render_slot(@inner_block)}
      </a>
    <% else %>
      <button
        type="button"
        phx-click={@on_click}
        disabled={@disabled}
        aria-current={@active && "page"}
        class={cn([
          "inline-flex items-center gap-1.5 rounded-full px-3 py-1.5 text-sm font-medium whitespace-nowrap transition-colors",
          chip_item_variant_class(@variant, @active),
          @disabled && "pointer-events-none opacity-50",
          @class
        ])}
        {@rest}
      >
        <span :if={@icon != []} class="shrink-0">{render_slot(@icon)}</span>
        {render_slot(@inner_block)}
      </button>
    <% end %>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp chip_nav_gap_class(:sm), do: "gap-1"
  defp chip_nav_gap_class(:md), do: "gap-2"

  defp chip_item_variant_class(:default, true), do: "bg-primary text-primary-foreground"
  defp chip_item_variant_class(:default, false), do: "bg-secondary text-secondary-foreground hover:bg-secondary/80"
  defp chip_item_variant_class(:outline, true), do: "border border-border bg-transparent text-foreground"
  defp chip_item_variant_class(:outline, false), do: "border border-border bg-transparent hover:bg-accent"
  defp chip_item_variant_class(:ghost, true), do: "bg-accent text-accent-foreground"
  defp chip_item_variant_class(:ghost, false), do: "bg-transparent hover:bg-accent"
end
