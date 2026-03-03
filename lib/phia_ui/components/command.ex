defmodule PhiaUi.Components.Command do
  @moduledoc """
  Command palette component with PhiaCommand vanilla JS hook.

  Global Ctrl+K / Cmd+K opens a modal command palette. Search is server-side
  via `phx-change` on `command_input/1`. Keyboard: Arrow Up/Down navigates
  items, Enter selects, Escape closes.

  ## Sub-components

  - `command/1` — modal overlay with `phx-hook="PhiaCommand"`
  - `command_dialog/1` — Dialog + Command composition (centered, backdrop-blur)
  - `command_input/1` — search input (`role="combobox"`, `phx-change`)
  - `command_list/1` — results container
  - `command_empty/1` — empty state message
  - `command_group/1` — labeled category section
  - `command_item/1` — selectable item with `phx-click`
  - `command_separator/1` — visual divider between groups
  - `command_shortcut/1` — keyboard hint badge (e.g. `⌘K`)

  ## Example

      <.command id="global-cmd">
        <.command_input id="global-cmd-input" on_change="search" />
        <.command_list id="global-cmd-list">
          <%= if @results == [] do %>
            <.command_empty>No results found.</.command_empty>
          <% else %>
            <.command_group label="Pages">
              <.command_item :for={item <- @results} on_click="navigate" value={item.path}>
                <%= item.label %>
                <.command_shortcut><%= item.shortcut %></.command_shortcut>
              </.command_item>
            </.command_group>
          <% end %>
        </.command_list>
      </.command>

  ## Hook setup

      import PhiaCommand from "./hooks/command"
      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaCommand }
      })

  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:id, :string, required: true, doc: "Unique ID for the command modal")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc "Renders the command palette modal overlay."
  def command(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaCommand"
      role="dialog"
      aria-modal="true"
      data-command-modal
      class={cn(["fixed inset-0 z-50 hidden", @class])}
      {@rest}
    >
      <div class="fixed inset-0 bg-black/50" data-command-backdrop></div>
      <div class="fixed left-1/2 top-[20%] -translate-x-1/2 w-full max-w-lg px-4">
        <div class="overflow-hidden rounded-lg border border-border bg-popover shadow-lg">
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end

  attr(:id, :string, required: true, doc: "Unique ID for the command dialog")

  attr(:title, :string,
    default: "Command Palette",
    doc: "Accessible label (aria-label) for the dialog"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc """
  Combined Dialog + Command component for a modal command palette.

  Renders a Dialog-style overlay (with backdrop-blur, centered panel) that
  wraps `command_input/1`, `command_list/1` and related sub-components.
  Uses `phx-hook="PhiaCommand"` for Ctrl+K / Cmd+K keyboard trigger and
  Escape to close.

  ## Example

      <.command_dialog id="global-search">
        <.command_input id="global-search-input" on_change="search" />
        <.command_list id="global-search-list">
          <.command_group label="Pages">
            <.command_item on_click="nav" value="home">Home</.command_item>
          </.command_group>
        </.command_list>
      </.command_dialog>
  """
  def command_dialog(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaCommand"
      role="dialog"
      aria-modal="true"
      aria-label={@title}
      data-command-modal
      class={cn(["fixed inset-0 z-50 hidden", @class])}
      {@rest}
    >
      <div class="fixed inset-0 bg-black/80 backdrop-blur-sm" data-command-backdrop></div>
      <div class="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-full max-w-lg px-4">
        <div class="overflow-hidden rounded-lg border border-border bg-popover shadow-xl">
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end

  attr(:id, :string, required: true, doc: "Input element ID (used for aria-activedescendant)")
  attr(:placeholder, :string, default: "Type a command or search...")
  attr(:on_change, :string, required: true, doc: "phx-change event name for search")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)

  @doc "Renders the command palette search input."
  def command_input(assigns) do
    ~H"""
    <input
      id={@id}
      type="text"
      role="combobox"
      aria-expanded="false"
      aria-autocomplete="list"
      autocomplete="off"
      spellcheck="false"
      placeholder={@placeholder}
      phx-change={@on_change}
      data-command-input
      class={cn([
        "flex h-11 w-full border-0 border-b border-border bg-transparent",
        "px-4 py-3 text-sm outline-none placeholder:text-muted-foreground",
        "disabled:cursor-not-allowed disabled:opacity-50",
        @class
      ])}
      {@rest}
    />
    """
  end

  attr(:id, :string, required: true, doc: "List element ID for aria coordination")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc "Renders the command results container."
  def command_list(assigns) do
    ~H"""
    <div
      id={@id}
      role="listbox"
      data-command-list
      class={cn([
        "max-h-72 overflow-y-auto overflow-x-hidden py-1",
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc "Renders an empty state message when no command items match."
  def command_empty(assigns) do
    ~H"""
    <div
      class={cn(["py-6 text-center text-sm text-muted-foreground", @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr(:label, :string, required: true, doc: "Group heading label")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc "Renders a labeled group of command items."
  def command_group(assigns) do
    ~H"""
    <div role="group" class={cn([@class])} {@rest}>
      <div class="px-2 py-1.5 text-xs font-medium text-muted-foreground">
        <%= @label %>
      </div>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr(:on_click, :string, required: true, doc: "phx-click event name")
  attr(:value, :string, required: true, doc: "Item value sent as phx-value-value")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc "Renders a selectable command item."
  def command_item(assigns) do
    ~H"""
    <div
      role="option"
      aria-selected="false"
      phx-click={@on_click}
      phx-value-value={@value}
      data-command-item
      class={cn([
        "relative flex cursor-pointer select-none items-center justify-between",
        "rounded-sm px-2 py-1.5 text-sm outline-none",
        "hover:bg-accent hover:text-accent-foreground",
        "data-[selected]:bg-accent data-[selected]:text-accent-foreground",
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)

  @doc "Renders a visual divider between command groups."
  def command_separator(assigns) do
    ~H"""
    <div
      data-command-separator
      class={cn(["-mx-1 my-1 h-px bg-border", @class])}
      {@rest}
    />
    """
  end

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc "Renders a keyboard shortcut hint badge."
  def command_shortcut(assigns) do
    ~H"""
    <span
      class={cn([
        "ml-auto text-xs tracking-widest text-muted-foreground",
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </span>
    """
  end
end
