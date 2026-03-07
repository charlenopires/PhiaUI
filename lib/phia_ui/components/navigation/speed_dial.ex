defmodule PhiaUi.Components.SpeedDial do
  @moduledoc """
  Floating Action Button (FAB) speed dial component.

  Requires the `PhiaSpeedDial` JavaScript hook registered in `app.js`.

  Provides two components:

  - `speed_dial/1` — fixed FAB container with directional expansion
  - `speed_dial_item/1` — individual action button with label tooltip
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # speed_dial/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true)
  attr(:class, :string, default: nil)
  attr(:position, :atom, values: [:bottom_right, :bottom_left, :top_right, :top_left], default: :bottom_right)
  attr(:direction, :atom, values: [:up, :down, :left, :right], default: :up)
  attr(:rest, :global)

  slot(:inner_block, required: true)
  slot(:trigger, doc: "Custom FAB trigger button — defaults to + icon if not provided")

  def speed_dial(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaSpeedDial"
      data-direction={@direction}
      class={cn([
        "fixed z-50",
        speed_dial_position_class(@position),
        @class
      ])}
      {@rest}
    >
      <div
        data-speed-dial-items
        class={cn([
          "flex items-center gap-3 mb-3",
          speed_dial_direction_class(@direction)
        ])}
      >
        {render_slot(@inner_block)}
      </div>
      <%= if @trigger != [] do %>
        {render_slot(@trigger)}
      <% else %>
        <button
          type="button"
          data-speed-dial-fab
          aria-label="Open actions"
          aria-expanded="false"
          class="size-14 rounded-full bg-primary text-primary-foreground shadow-lg hover:shadow-xl flex items-center justify-center transition-all hover:scale-105 active:scale-95"
        >
          <svg
            class="h-6 w-6 transition-transform"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <line x1="12" y1="5" x2="12" y2="19" />
            <line x1="5" y1="12" x2="19" y2="12" />
          </svg>
        </button>
      <% end %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # speed_dial_item/1
  # ---------------------------------------------------------------------------

  attr(:label, :string, required: true)
  attr(:on_click, :string, default: nil)
  attr(:href, :string, default: nil)
  attr(:disabled, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:icon, required: true)

  def speed_dial_item(assigns) do
    ~H"""
    <div
      data-speed-dial-item
      class={cn([
        "flex items-center gap-2",
        "opacity-0 translate-y-4 transition-all pointer-events-none",
        @class
      ])}
    >
      <span class="whitespace-nowrap rounded-md bg-foreground/90 px-2 py-1 text-xs text-background">
        {@label}
      </span>
      <%= if @href do %>
        <a
          href={@href}
          aria-label={@label}
          class={cn([
            "size-10 rounded-full bg-background border border-border shadow-md flex items-center justify-center hover:bg-accent transition-colors",
            @disabled && "pointer-events-none opacity-50"
          ])}
          {@rest}
        >
          {render_slot(@icon)}
        </a>
      <% else %>
        <button
          type="button"
          phx-click={@on_click}
          disabled={@disabled}
          aria-label={@label}
          class="size-10 rounded-full bg-background border border-border shadow-md flex items-center justify-center hover:bg-accent transition-colors disabled:pointer-events-none disabled:opacity-50"
          {@rest}
        >
          {render_slot(@icon)}
        </button>
      <% end %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp speed_dial_position_class(:bottom_right), do: "right-6 bottom-6"
  defp speed_dial_position_class(:bottom_left), do: "left-6 bottom-6"
  defp speed_dial_position_class(:top_right), do: "right-6 top-6"
  defp speed_dial_position_class(:top_left), do: "left-6 top-6"

  defp speed_dial_direction_class(:up), do: "flex-col-reverse"
  defp speed_dial_direction_class(:down), do: "flex-col"
  defp speed_dial_direction_class(:left), do: "flex-row-reverse"
  defp speed_dial_direction_class(:right), do: "flex-row"
end
