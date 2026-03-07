defmodule PhiaUi.Components.CommandPalette do
  @moduledoc """
  Command palette (Cmd+K) overlay component.

  Reuses the existing `PhiaCommand` hook from `priv/templates/js/hooks/command.js`.
  The hook manages show/hide by toggling the `hidden` class on the root element,
  filters items by the search input value, and highlights items via keyboard.

  ## Markup contract (required by PhiaCommand hook)

  - Root element: `phx-hook="PhiaCommand"` + `role="dialog"` — starts hidden via `hidden` class
  - `[data-command-backdrop]` — clicking this closes the palette
  - `[data-command-input]` + `role="combobox"` — the search input
  - `[data-command-list]` — the results list container
  - `[data-command-item]` — individual items (must have `id` for aria-activedescendant)

  ## Four components

  - `command_palette/1` — the root dialog overlay
  - `command_palette_group/1` — groups items under a heading
  - `command_palette_item/1` — a single command item
  - `command_palette_empty/1` — empty state shown when no results match
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # command_palette/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "Required for phx-hook and aria-activedescendant")
  attr(:placeholder, :string, default: "Search...")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true, doc: "groups/items/empty state")

  @doc """
  Renders the command palette overlay dialog.

  Open programmatically by dispatching the custom event or setting the hook
  trigger. The hook registers keyboard shortcuts (Cmd+K / Ctrl+K) and Escape
  to close.
  """
  def command_palette(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaCommand"
      role="dialog"
      aria-modal="true"
      aria-label="Command palette"
      class={cn(["hidden fixed inset-0 z-50", @class])}
      {@rest}
    >
      <%!-- Backdrop --%>
      <div
        data-command-backdrop
        class="absolute inset-0 bg-background/80 backdrop-blur-sm"
      />
      <%!-- Panel --%>
      <div class="relative z-10 mx-auto mt-20 max-w-xl overflow-hidden rounded-xl border border-border bg-popover shadow-xl">
        <input
          data-command-input
          role="combobox"
          aria-expanded="false"
          aria-autocomplete="list"
          aria-controls={"#{@id}-list"}
          placeholder={@placeholder}
          class="w-full border-0 border-b border-border bg-transparent px-4 py-3 text-sm placeholder:text-muted-foreground focus:outline-none"
        />
        <div
          id={"#{@id}-list"}
          data-command-list
          class="max-h-80 overflow-y-auto p-1"
        >
          {render_slot(@inner_block)}
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # command_palette_group/1
  # ---------------------------------------------------------------------------

  attr(:heading, :string, required: true)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc "Renders a labeled group of command palette items."
  def command_palette_group(assigns) do
    ~H"""
    <div class={cn(["pb-1", @class])} {@rest}>
      <p class="px-2 py-1.5 text-xs font-medium text-muted-foreground">{@heading}</p>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # command_palette_item/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "Required for aria-activedescendant targeting")
  attr(:on_select, :string, default: nil, doc: "phx-click event name")
  attr(:value, :any, default: nil, doc: "phx-value-value sent with on_select")
  attr(:disabled, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:icon, doc: "Optional leading icon")
  slot(:inner_block, required: true, doc: "Label text")

  @doc "Renders a single command item inside a command palette."
  def command_palette_item(assigns) do
    ~H"""
    <button
      id={@id}
      data-command-item
      role="option"
      aria-selected="false"
      type="button"
      phx-click={@on_select}
      phx-value-value={@value}
      disabled={@disabled}
      class={cn([
        "flex w-full items-center gap-2 rounded-sm px-2 py-1.5 text-sm text-left",
        "hover:bg-accent hover:text-accent-foreground",
        "data-[selected]:bg-accent data-[selected]:text-accent-foreground",
        "focus:bg-accent focus:text-accent-foreground focus:outline-none",
        @disabled && "pointer-events-none opacity-50",
        @class
      ])}
      {@rest}
    >
      <%= if @icon != [] do %>
        <span class="shrink-0 text-muted-foreground">{render_slot(@icon)}</span>
      <% end %>
      {render_slot(@inner_block)}
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # command_palette_empty/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, doc: "Custom empty state content")

  @doc "Renders an empty state inside the command palette when no results match."
  def command_palette_empty(assigns) do
    ~H"""
    <div
      class={cn(["px-4 py-8 text-center text-sm text-muted-foreground", @class])}
      {@rest}
    >
      <%= if @inner_block != [] do %>
        {render_slot(@inner_block)}
      <% else %>
        No results found.
      <% end %>
    </div>
    """
  end
end
