defmodule PhiaUi.Components.Dock do
  @moduledoc """
  macOS-style icon dock navigation component.

  Provides two components:

  - `dock/1` — icon dock container with orientation and variant options
  - `dock_item/1` — icon button with hover tooltip and scale animation
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # dock/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil)
  attr(:orientation, :atom, values: [:horizontal, :vertical], default: :horizontal)
  attr(:position, :atom, values: [:bottom, :top, :left, :right, :inline], default: :bottom)
  attr(:variant, :atom, values: [:default, :glass, :bordered], default: :default)
  attr(:rest, :global)

  slot(:inner_block, required: true)

  def dock(assigns) do
    ~H"""
    <div
      class={cn([
        "inline-flex items-center gap-1 rounded-2xl px-2 py-2 shadow-md",
        dock_orientation_class(@orientation),
        dock_position_class(@position),
        dock_variant_class(@variant),
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # dock_item/1
  # ---------------------------------------------------------------------------

  attr(:active, :boolean, default: false)
  attr(:href, :string, default: nil)
  attr(:on_click, :string, default: nil)
  attr(:label, :string, required: true)
  attr(:disabled, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:icon, required: true)
  slot(:badge)

  def dock_item(assigns) do
    ~H"""
    <span class="group relative">
      <%= if @href do %>
        <a
          href={@href}
          aria-label={@label}
          aria-current={@active && "page"}
          class={cn([
            "relative flex items-center justify-center size-10 rounded-xl transition-all",
            "hover:scale-110 hover:bg-accent active:scale-95",
            @active && "bg-accent",
            @disabled && "pointer-events-none opacity-50",
            @class
          ])}
          {@rest}
        >
          {render_slot(@icon)}
          <span :if={@badge != []} class="absolute -top-1 -right-1">
            {render_slot(@badge)}
          </span>
        </a>
      <% else %>
        <button
          type="button"
          phx-click={@on_click}
          disabled={@disabled}
          aria-label={@label}
          aria-current={@active && "page"}
          class={cn([
            "relative flex items-center justify-center size-10 rounded-xl transition-all",
            "hover:scale-110 hover:bg-accent active:scale-95",
            @active && "bg-accent",
            @disabled && "pointer-events-none opacity-50",
            @class
          ])}
          {@rest}
        >
          {render_slot(@icon)}
          <span :if={@badge != []} class="absolute -top-1 -right-1">
            {render_slot(@badge)}
          </span>
        </button>
      <% end %>
      <span class="pointer-events-none absolute -top-9 left-1/2 -translate-x-1/2 whitespace-nowrap rounded-md bg-foreground px-2 py-1 text-xs text-background opacity-0 group-hover:opacity-100 transition-opacity">
        {@label}
      </span>
    </span>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp dock_orientation_class(:horizontal), do: "flex-row"
  defp dock_orientation_class(:vertical), do: "flex-col"

  defp dock_position_class(:bottom), do: "fixed bottom-4 left-1/2 -translate-x-1/2 z-50"
  defp dock_position_class(:top), do: "fixed top-4 left-1/2 -translate-x-1/2 z-50"
  defp dock_position_class(:left), do: "fixed left-4 top-1/2 -translate-y-1/2 z-50"
  defp dock_position_class(:right), do: "fixed right-4 top-1/2 -translate-y-1/2 z-50"
  defp dock_position_class(:inline), do: ""

  defp dock_variant_class(:default), do: "border border-border bg-background"
  defp dock_variant_class(:glass), do: "border border-border/50 bg-background/60 backdrop-blur-xl"
  defp dock_variant_class(:bordered), do: "border-2 border-border bg-background"
end
