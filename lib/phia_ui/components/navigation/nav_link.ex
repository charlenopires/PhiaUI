defmodule PhiaUi.Components.NavLink do
  @moduledoc """
  Versatile navigation link component (Mantine-style).

  Supports active/inactive states, multiple variants, optional icon sections,
  description text, and collapsible children via native `<details>/<summary>`.

  - `nav_link/1` — flexible link with optional children collapse
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # nav_link/1
  # ---------------------------------------------------------------------------

  attr(:href, :string, default: nil)
  attr(:active, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:variant, :atom, values: [:subtle, :light, :filled], default: :subtle)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, required: true, doc: "Label text")
  slot(:icon, doc: "Left icon section")
  slot(:right_section, doc: "Right content (e.g. badge or chevron)")
  slot(:description, doc: "Optional description text below the label")
  slot(:children, doc: "Nested nav_link components — renders a collapsible <details>")

  def nav_link(assigns) do
    ~H"""
    <%= if @children != [] do %>
      <details open={@active} class={cn(["mb-0.5", @class])}>
        <summary class={cn([
          "flex cursor-pointer list-none items-center gap-2 rounded-md px-3 py-2 text-sm font-medium transition-colors",
          nav_link_base_class(@variant, @active),
          @disabled && "pointer-events-none opacity-50"
        ])}>
          <span :if={@icon != []} class="shrink-0">{render_slot(@icon)}</span>
          <span class="flex-1 min-w-0">
            {render_slot(@inner_block)}
            <span :if={@description != []} class="block text-xs text-muted-foreground mt-0.5">
              {render_slot(@description)}
            </span>
          </span>
          <span :if={@right_section != []} class="shrink-0">{render_slot(@right_section)}</span>
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
        <div class="pl-6 mt-1 space-y-0.5">
          {render_slot(@children)}
        </div>
      </details>
    <% else %>
      <%= if @href do %>
        <a
          href={@href}
          aria-current={@active && "page"}
          class={cn([
            "flex items-center gap-2 rounded-md px-3 py-2 text-sm font-medium transition-colors",
            nav_link_base_class(@variant, @active),
            @disabled && "pointer-events-none opacity-50",
            @class
          ])}
          {@rest}
        >
          <span :if={@icon != []} class="shrink-0">{render_slot(@icon)}</span>
          <span class="flex-1 min-w-0">
            {render_slot(@inner_block)}
            <span :if={@description != []} class="block text-xs text-muted-foreground mt-0.5">
              {render_slot(@description)}
            </span>
          </span>
          <span :if={@right_section != []} class="shrink-0">{render_slot(@right_section)}</span>
        </a>
      <% else %>
        <button
          type="button"
          aria-current={@active && "page"}
          class={cn([
            "flex w-full items-center gap-2 rounded-md px-3 py-2 text-sm font-medium transition-colors",
            nav_link_base_class(@variant, @active),
            @disabled && "pointer-events-none opacity-50",
            @class
          ])}
          {@rest}
        >
          <span :if={@icon != []} class="shrink-0">{render_slot(@icon)}</span>
          <span class="flex-1 min-w-0 text-left">
            {render_slot(@inner_block)}
            <span :if={@description != []} class="block text-xs text-muted-foreground mt-0.5">
              {render_slot(@description)}
            </span>
          </span>
          <span :if={@right_section != []} class="shrink-0">{render_slot(@right_section)}</span>
        </button>
      <% end %>
    <% end %>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp nav_link_base_class(:subtle, true), do: "bg-accent text-accent-foreground"
  defp nav_link_base_class(:subtle, false), do: "text-muted-foreground hover:bg-accent/50 hover:text-accent-foreground"
  defp nav_link_base_class(:light, true), do: "bg-primary/10 text-primary"
  defp nav_link_base_class(:light, false), do: "text-muted-foreground hover:bg-primary/10 hover:text-primary"
  defp nav_link_base_class(:filled, true), do: "bg-primary text-primary-foreground"
  defp nav_link_base_class(:filled, false), do: "text-muted-foreground hover:bg-primary hover:text-primary-foreground"
end
