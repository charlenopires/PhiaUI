defmodule PhiaUi.Components.FloatingNav do
  @moduledoc """
  Floating pill navigation bar — fixed or sticky pill anchored to the viewport.

  Provides two components:

  - `floating_nav/1` — pill container with positioning options
  - `floating_nav_item/1` — icon + optional label item
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # floating_nav/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil)
  attr(:position, :atom, values: [:fixed, :sticky], default: :fixed)
  attr(:placement, :atom, values: [:bottom, :top, :bottom_left, :bottom_right], default: :bottom)
  attr(:rest, :global)

  slot(:inner_block, required: true)

  def floating_nav(assigns) do
    ~H"""
    <nav
      class={cn([
        "z-50 flex items-center gap-1 rounded-full border border-border bg-background/80 backdrop-blur-md px-2 py-2 shadow-lg",
        floating_position_class(@position, @placement),
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </nav>
    """
  end

  # ---------------------------------------------------------------------------
  # floating_nav_item/1
  # ---------------------------------------------------------------------------

  attr(:active, :boolean, default: false)
  attr(:href, :string, default: nil)
  attr(:on_click, :string, default: nil)
  attr(:label, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:icon)

  def floating_nav_item(assigns) do
    ~H"""
    <%= if @href do %>
      <a
        href={@href}
        aria-label={@label}
        aria-current={@active && "page"}
        title={@label}
        class={cn([
          "relative flex flex-col items-center gap-0.5 rounded-full p-2 text-xs transition-colors",
          "hover:bg-accent",
          @active && "text-primary bg-accent",
          !@active && "text-muted-foreground",
          @class
        ])}
        {@rest}
      >
        <span :if={@icon != []} class="shrink-0">{render_slot(@icon)}</span>
        <span :if={@label}>{@label}</span>
      </a>
    <% else %>
      <button
        type="button"
        phx-click={@on_click}
        aria-label={@label}
        aria-current={@active && "page"}
        title={@label}
        class={cn([
          "relative flex flex-col items-center gap-0.5 rounded-full p-2 text-xs transition-colors",
          "hover:bg-accent",
          @active && "text-primary bg-accent",
          !@active && "text-muted-foreground",
          @class
        ])}
        {@rest}
      >
        <span :if={@icon != []} class="shrink-0">{render_slot(@icon)}</span>
        <span :if={@label}>{@label}</span>
      </button>
    <% end %>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp floating_position_class(:fixed, :bottom), do: "fixed bottom-6 left-1/2 -translate-x-1/2"
  defp floating_position_class(:fixed, :top), do: "fixed top-6 left-1/2 -translate-x-1/2"
  defp floating_position_class(:fixed, :bottom_left), do: "fixed bottom-6 left-6"
  defp floating_position_class(:fixed, :bottom_right), do: "fixed bottom-6 right-6"
  defp floating_position_class(:sticky, _), do: "sticky top-4 mx-auto w-fit"
end
