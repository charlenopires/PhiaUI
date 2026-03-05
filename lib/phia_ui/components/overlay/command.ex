defmodule PhiaUi.Components.Command do
  @moduledoc """
  Command palette component powered by the `PhiaCommand` vanilla JavaScript hook.

  A command palette is a modal search interface — popularised by tools like VS
  Code, Linear, and Notion — that lets users quickly navigate and trigger
  actions by typing. It is activated globally via `Ctrl+K` / `Cmd+K` and closed
  with `Escape`.

  Search filtering is **server-side** via `phx-change` on `command_input/1`,
  giving you full access to your LiveView's data and LiveView Streams for
  efficient DOM updates.

  ## Architecture

  The component provides two top-level container options:

  - `command/1` — inline modal with a simple dark backdrop; good for embedded
    palettes within a specific page section
  - `command_dialog/1` — centered modal with `backdrop-blur-sm`; the standard
    choice for a global application-wide command palette

  Both use `phx-hook="PhiaCommand"` and the same keyboard behaviour.

  ## Sub-components

  | Function            | Purpose                                                   |
  |---------------------|-----------------------------------------------------------|
  | `command/1`         | Modal overlay with backdrop (inline variant)              |
  | `command_dialog/1`  | Centered modal with blur backdrop (global palette variant)|
  | `command_input/1`   | Search input (`role="combobox"`, drives `phx-change`)     |
  | `command_list/1`    | Results container (`role="listbox"`)                      |
  | `command_empty/1`   | Empty state message shown when results are empty          |
  | `command_group/1`   | Labeled category section for related results              |
  | `command_item/1`    | Selectable result item (`role="option"`)                  |
  | `command_separator/1` | Visual divider between groups                           |
  | `command_shortcut/1`| Right-aligned keyboard shortcut badge                     |

  ## Hook Setup

  Copy the hook via `mix phia.add command`, then register it in `app.js`:

      # assets/js/app.js
      import PhiaCommand from "./hooks/command"

      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaCommand }
      })

  ## Full Example — Global Command Palette

  A common pattern: render the palette once in your app layout, use a LiveView
  assign for search results, and navigate on item selection.

      <%# In root.html.heex or app.html.heex, or in a persistent LiveView %>
      <.command_dialog id="global-cmd" title="Command Palette">
        <.command_input id="global-cmd-input" on_change="cmd_search" placeholder="Search pages and actions..." />
        <.command_list id="global-cmd-list">
          <%= if @cmd_results == [] do %>
            <.command_empty>No results for "{@cmd_query}".</.command_empty>
          <% else %>
            <.command_group :if={@cmd_results[:pages] != []} label="Pages">
              <.command_item
                :for={page <- @cmd_results[:pages]}
                on_click="navigate"
                value={page.path}>
                <.icon name="file" class="mr-2 h-4 w-4" />
                {page.title}
                <.command_shortcut :if={page.shortcut}>{page.shortcut}</.command_shortcut>
              </.command_item>
            </.command_group>
            <.command_separator :if={@cmd_results[:pages] != [] and @cmd_results[:actions] != []} />
            <.command_group :if={@cmd_results[:actions] != []} label="Actions">
              <.command_item
                :for={action <- @cmd_results[:actions]}
                on_click={action.event}
                value={action.value}>
                <.icon name={action.icon} class="mr-2 h-4 w-4" />
                {action.label}
              </.command_item>
            </.command_group>
          <% end %>
        </.command_list>
      </.command_dialog>

      # LiveView
      def handle_event("cmd_search", %{"value" => query}, socket) do
        results = MyApp.Search.command_palette(query)
        {:noreply, assign(socket, cmd_query: query, cmd_results: results)}
      end

      def handle_event("navigate", %{"value" => path}, socket) do
        {:noreply, push_navigate(socket, to: path)}
      end

  ## Example — Scoped Palette (No Dialog Chrome)

  Use `command/1` when you want the palette to be scoped to a section and
  triggered by something other than `Ctrl+K`:

      <.button phx-click={JS.show(to: "#local-cmd")}>Open Command</.button>

      <.command id="local-cmd">
        <.command_input id="local-cmd-input" on_change="filter_items" />
        <.command_list id="local-cmd-list">
          <.command_group label="Recent Files">
            <.command_item :for={f <- @filtered_files} on_click="open_file" value={f.id}>
              {f.name}
            </.command_item>
          </.command_group>
        </.command_list>
      </.command>

  ## Keyboard Navigation

  The `PhiaCommand` hook provides full WAI-ARIA keyboard support:
  - `Ctrl+K` / `Cmd+K` — opens the palette globally (any element focused)
  - `ArrowDown` / `ArrowUp` — moves focus between `command_item/1` elements
  - `Enter` — activates the focused item (fires its `phx-click` event)
  - `Escape` — closes the palette, clears the input, returns focus
  - `Tab` — wraps focus within the list (does not close)

  ## Server-Side Filtering

  Unlike client-side filtering (which is fast but limited to pre-loaded data),
  PhiaUI's command palette uses `phx-change` to send every keystroke to the
  LiveView. This enables:
  - Searching across the full database rather than a pre-loaded list
  - Permission-filtered results (only show actions the user can perform)
  - LiveView Streams for efficient DOM patching when results change
  - Async searches with `Task.async` and `handle_info` for heavy queries

  ## Accessibility

  - The palette uses `role="dialog"` and `aria-modal="true"` — screen readers
    treat it as a modal and restrict virtual cursor navigation to the palette
  - `command_input/1` has `role="combobox"` and `aria-autocomplete="list"`
    to declare the search+results relationship
  - `command_list/1` has `role="listbox"` and items have `role="option"`
  - Selected items are indicated via `aria-selected` and `data-[selected]` CSS
  - The `aria-label` on `command_dialog/1` provides a name for the dialog
    announced when it opens
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # command/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    required: true,
    doc: "Unique ID for the command modal element — the hook mount point"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the root `<div>`")

  slot(:inner_block,
    required: true,
    doc: "`command_input/1`, `command_list/1` and related sub-components"
  )

  @doc """
  Renders an inline command palette modal overlay.

  Hidden by default. The `PhiaCommand` hook shows it on `Ctrl+K` / `Cmd+K`
  and hides it on `Escape`. The backdrop is a semi-transparent black overlay;
  clicking it closes the palette.

  Use `command_dialog/1` for the more common centered, blur-backdrop variant.
  Use `command/1` when you want a simpler overlay or need custom positioning.
  """
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
      <%!-- Backdrop: click to close is handled by the hook on this element --%>
      <div class="fixed inset-0 bg-black/50" data-command-backdrop></div>
      <%!-- Panel: centered horizontally, appears at 20% from the top --%>
      <div class="fixed left-1/2 top-[20%] -translate-x-1/2 w-full max-w-lg px-4">
        <div class="overflow-hidden rounded-lg border border-border bg-popover shadow-lg">
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # command_dialog/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    required: true,
    doc: "Unique ID for the command dialog element — the hook mount point"
  )

  attr(:title, :string,
    default: "Command Palette",
    doc:
      "Accessible label used as `aria-label` for the dialog. Screen readers announce this when the dialog opens."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the root `<div>`")

  slot(:inner_block,
    required: true,
    doc: "`command_input/1`, `command_list/1` and related sub-components"
  )

  @doc """
  Renders the standard command palette modal — centered on the viewport with
  a blurred backdrop.

  This is the recommended component for a global application command palette.
  It differs from `command/1` in:
  - Vertically centered (not at 20% from top)
  - `backdrop-blur-sm` on the backdrop for a modern frosted-glass appearance
  - `aria-label` for the dialog name

  The hook registers `Ctrl+K` / `Cmd+K` globally — no separate trigger button
  is needed (though you can also trigger it programmatically).

  ## Example

      <.command_dialog id="app-cmd" title="Application commands">
        <.command_input id="app-cmd-input" on_change="search" />
        <.command_list id="app-cmd-list">
          <.command_group label="Navigation">
            <.command_item on_click="goto" value="/dashboard">Dashboard</.command_item>
            <.command_item on_click="goto" value="/settings">Settings</.command_item>
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
      <%!-- Backdrop: blur creates the frosted-glass depth cue that dims the background --%>
      <div class="fixed inset-0 bg-black/80 backdrop-blur-sm" data-command-backdrop></div>
      <%!-- Panel: perfectly centered using translate-[-50%,-50%] from center origin --%>
      <div class="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-full max-w-lg px-4">
        <div class="overflow-hidden rounded-lg border border-border bg-popover shadow-xl">
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # command_input/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    required: true,
    doc: "Input element ID — used by the hook for `aria-activedescendant` management"
  )

  attr(:placeholder, :string,
    default: "Type a command or search...",
    doc: "Placeholder text shown when the input is empty"
  )

  attr(:on_change, :string,
    required: true,
    doc: """
    LiveView event name sent via `phx-change` on every keystroke. Your handler
    should update `@results` (or equivalent assign) with filtered items.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the `<input>`")

  @doc """
  Renders the command palette search input.

  Uses `role="combobox"` and `aria-autocomplete="list"` to declare the ARIA
  relationship between the input and the results list. The hook manages
  `aria-activedescendant` to point at the currently highlighted item.

  The `phx-change` sends a LiveView event on every keystroke — use debouncing
  in your handler or a `phx-debounce` attribute for expensive searches:

      <.command_input id="cmd-input" on_change="search" phx-debounce="200" />

  `autocomplete="off"` and `spellcheck="false"` prevent browser autocomplete
  dropdowns and red underlines from cluttering the search UI.
  """
  def command_input(assigns) do
    ~H"""
    <input
      id={@id}
      type="text"
      role="combobox"
      aria-expanded="false"
      aria-autocomplete="list"
      aria-controls={"#{@id}-list"}
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

  # ---------------------------------------------------------------------------
  # command_list/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    required: true,
    doc: "Element ID for the results list — the hook links the input's `aria-controls` here"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the list `<div>`")

  slot(:inner_block,
    required: true,
    doc: "`command_empty/1`, `command_group/1`, `command_separator/1` sub-components"
  )

  @doc """
  Renders the command results container.

  Uses `role="listbox"` to form the ARIA combobox pair with the `command_input/1`
  that has `role="combobox"`. Screen readers announce this as the list of
  available results when the input is focused.

  The `max-h-72 overflow-y-auto` limits the visible height and enables
  scrolling for long result lists, keeping the palette compact.
  """
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

  # ---------------------------------------------------------------------------
  # command_empty/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the empty state `<div>`")

  slot(:inner_block, required: true, doc: "Empty state message text")

  @doc """
  Renders an empty state message when no command items match the search query.

  Show this when the results list is empty. A good empty state is specific
  about what is missing:

      <%= if @cmd_results == [] do %>
        <.command_empty>No results for "{@cmd_query}".</.command_empty>
      <% end %>

  Avoid generic messages like "No results" — tell users what they searched for
  so they can refine their query.
  """
  def command_empty(assigns) do
    ~H"""
    <div
      role="status"
      aria-live="polite"
      aria-atomic="true"
      class={cn(["py-6 text-center text-sm text-muted-foreground", @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # command_group/1
  # ---------------------------------------------------------------------------

  attr(:label, :string,
    required: true,
    doc: "Group heading label — describes the category of results in this section"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the group `<div>`")

  slot(:inner_block, required: true, doc: "`command_item/1` sub-components")

  @doc """
  Renders a labeled group of command items.

  Use groups to organize results into meaningful categories — "Pages",
  "Actions", "Recent", "Settings". Groups make large result sets easier to
  scan quickly.

      <.command_group label="Pages">
        <.command_item on_click="navigate" value="/dashboard">Dashboard</.command_item>
        <.command_item on_click="navigate" value="/reports">Reports</.command_item>
      </.command_group>
      <.command_separator />
      <.command_group label="Actions">
        <.command_item on_click="create_record" value="new">New Record</.command_item>
      </.command_group>

  The group heading is `text-xs font-medium text-muted-foreground` — visible
  but not competing with the item content.
  """
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

  # ---------------------------------------------------------------------------
  # command_item/1
  # ---------------------------------------------------------------------------

  attr(:on_click, :string,
    required: true,
    doc: "LiveView event name sent via `phx-click` when the item is selected"
  )

  attr(:value, :string,
    required: true,
    doc: "Item value sent as `phx-value-value` — use to pass page paths, IDs, or action keys"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the item `<div>`")

  slot(:inner_block,
    required: true,
    doc: "Item content — icon + label + optional `command_shortcut/1`"
  )

  @doc """
  Renders a selectable command palette item.

  Uses `role="option"` to pair with the `command_list/1`'s `role="listbox"`.
  The hook manages `aria-selected` and the `data-selected` attribute for the
  currently highlighted item (driven by `ArrowUp`/`ArrowDown`).

  When the user presses `Enter` or clicks the item, `phx-click={@on_click}`
  fires with `phx-value-value={@value}`. Your LiveView handler receives:

      def handle_event("navigate", %{"value" => "/dashboard"}, socket) do
        {:noreply, push_navigate(socket, to: "/dashboard")}
      end

  Add `command_shortcut/1` as the last child to show a keyboard hint:

      <.command_item on_click="navigate" value="/settings">
        <.icon name="settings" class="mr-2 h-4 w-4" />
        Settings
        <.command_shortcut>⌘,</.command_shortcut>
      </.command_item>
  """
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

  # ---------------------------------------------------------------------------
  # command_separator/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the separator `<div>`")

  @doc """
  Renders a visual divider between command groups.

  Use separators to create clear boundaries between unrelated categories in
  the results list. Typically placed between `command_group/1` elements:

      <.command_group label="Navigation">...</.command_group>
      <.command_separator />
      <.command_group label="Actions">...</.command_group>
  """
  def command_separator(assigns) do
    ~H"""
    <div
      data-command-separator
      class={cn(["-mx-1 my-1 h-px bg-border", @class])}
      {@rest}
    />
    """
  end

  # ---------------------------------------------------------------------------
  # command_shortcut/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the `<span>`")

  slot(:inner_block,
    required: true,
    doc: "Shortcut text — e.g. `⌘K`, `Ctrl+P`, `⌘,`. Use platform-specific symbols."
  )

  @doc """
  Renders a right-aligned keyboard shortcut badge inside a command item.

  This is presentational only — the shortcut hint does not register any
  keyboard listener. The shortcut should match an actual global shortcut
  registered in your application JavaScript.

      <.command_item on_click="navigate" value="/preferences">
        <.icon name="sliders" class="mr-2 h-4 w-4" />
        Preferences
        <.command_shortcut>⌘,</.command_shortcut>
      </.command_item>

  The `ml-auto` class pushes the shortcut to the far right of the flex
  container, aligned opposite the item label and icon.
  """
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
