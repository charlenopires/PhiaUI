defmodule PhiaUi.Components.VerticalNav do
  @moduledoc """
  Vertical navigation component for sidebars and side panels.

  Provides four components:

  - `vertical_nav/1` — `<nav>` container
  - `vertical_nav_item/1` — `<a>` or `<button>` item with icon and badge
  - `vertical_nav_group/1` — collapsible `<details>` group with label
  - `vertical_nav_separator/1` — `<hr>` with optional text label
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # vertical_nav/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, required: true)

  def vertical_nav(assigns) do
    ~H"""
    <nav class={cn(["flex flex-col gap-1", @class])} {@rest}>
      {render_slot(@inner_block)}
    </nav>
    """
  end

  # ---------------------------------------------------------------------------
  # vertical_nav_item/1
  # ---------------------------------------------------------------------------

  attr(:href, :string, default: nil)
  attr(:on_click, :string, default: nil)
  attr(:active, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:badge, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, required: true)
  slot(:icon)

  def vertical_nav_item(assigns) do
    ~H"""
    <%= if @href do %>
      <a
        href={@href}
        aria-current={@active && "page"}
        class={cn([
          "flex items-center gap-2 rounded-md px-3 py-2 text-sm font-medium transition-colors w-full",
          "text-muted-foreground hover:bg-accent hover:text-accent-foreground",
          @active && "bg-accent text-accent-foreground",
          @disabled && "pointer-events-none opacity-50",
          @class
        ])}
        {@rest}
      >
        <span :if={@icon != []} class="shrink-0">{render_slot(@icon)}</span>
        <span class="flex-1">{render_slot(@inner_block)}</span>
        <span
          :if={@badge}
          class="ml-auto text-xs font-medium text-muted-foreground"
        >
          {@badge}
        </span>
      </a>
    <% else %>
      <button
        type="button"
        phx-click={@on_click}
        disabled={@disabled}
        aria-current={@active && "page"}
        class={cn([
          "flex items-center gap-2 rounded-md px-3 py-2 text-sm font-medium transition-colors w-full",
          "text-muted-foreground hover:bg-accent hover:text-accent-foreground",
          @active && "bg-accent text-accent-foreground",
          @disabled && "pointer-events-none opacity-50",
          @class
        ])}
        {@rest}
      >
        <span :if={@icon != []} class="shrink-0">{render_slot(@icon)}</span>
        <span class="flex-1 text-left">{render_slot(@inner_block)}</span>
        <span
          :if={@badge}
          class="ml-auto text-xs font-medium text-muted-foreground"
        >
          {@badge}
        </span>
      </button>
    <% end %>
    """
  end

  # ---------------------------------------------------------------------------
  # vertical_nav_group/1
  # ---------------------------------------------------------------------------

  attr(:label, :string, required: true)
  attr(:open, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:icon)
  slot(:inner_block, required: true)

  def vertical_nav_group(assigns) do
    ~H"""
    <details open={@open} class={cn(["", @class])} {@rest}>
      <summary class="flex cursor-pointer list-none items-center gap-2 rounded-md px-3 py-2 text-sm font-semibold text-muted-foreground hover:bg-accent hover:text-accent-foreground transition-colors">
        <span :if={@icon != []} class="shrink-0">{render_slot(@icon)}</span>
        <span class="flex-1">{@label}</span>
        <svg
          class="h-4 w-4 shrink-0 transition-transform details-open:rotate-90"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
        >
          <polyline points="9 18 15 12 9 6" />
        </svg>
      </summary>
      <div class="pl-4 mt-1 flex flex-col gap-1">
        {render_slot(@inner_block)}
      </div>
    </details>
    """
  end

  # ---------------------------------------------------------------------------
  # vertical_nav_separator/1
  # ---------------------------------------------------------------------------

  attr(:label, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def vertical_nav_separator(assigns) do
    ~H"""
    <div class={cn(["my-2", @class])} {@rest}>
      <%= if @label do %>
        <div class="relative flex items-center">
          <hr class="flex-1 border-t border-border" />
          <span class="mx-2 text-xs text-muted-foreground whitespace-nowrap">{@label}</span>
          <hr class="flex-1 border-t border-border" />
        </div>
      <% else %>
        <hr class="border-t border-border" />
      <% end %>
    </div>
    """
  end
end
