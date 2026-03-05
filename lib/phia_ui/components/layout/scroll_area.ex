defmodule PhiaUi.Components.ScrollArea do
  @moduledoc """
  ScrollArea component — a styled, accessible scrollable container. Zero JavaScript.

  `scroll_area/1` wraps any content in a div with controlled overflow and
  styled scrollbars. It uses the `tailwind-scrollbar` plugin (or equivalent)
  to apply thin, unobtrusive scrollbar styles that look consistent in both
  light and dark mode using semantic Tailwind tokens.

  The component is a pure CSS primitive — no JS hook, no event handlers. All
  behaviour is handled by the browser's native scroll engine.

  ## Scrollbar Plugin

  The `scrollbar-*` utility classes require the `tailwindcss-scrollbar` package
  in the host project's Tailwind config:

      # In your host project
      # Install: npm install --save-dev tailwindcss-scrollbar
      # tailwind.config.js
      module.exports = {
        plugins: [require("tailwindcss-scrollbar")]
      }

  Without the plugin, the component still functions — scrolling works — but the
  native platform scrollbars are displayed rather than the thin styled versions.

  ## Orientations

  | Value          | CSS Applied                | Best For                            |
  |----------------|----------------------------|-------------------------------------|
  | `"vertical"`   | `overflow-y-auto h-full`   | Tall content lists, sidebars, feeds |
  | `"horizontal"` | `overflow-x-auto w-full`   | Wide tables, code blocks, timelines |
  | `"both"`       | `overflow-auto`            | 2D content: maps, large diagrams    |

  ## Example — Vertical Scroll (Default)

  The most common use: a fixed-height container that scrolls when content
  exceeds the available height.

      <%# Sidebar navigation with many items %>
      <.scroll_area class="h-[calc(100vh-64px)]">
        <nav>
          <.sidebar_item :for={item <- @nav_items} href={item.path}>
            {item.label}
          </.sidebar_item>
        </nav>
      </.scroll_area>

      <%# Message feed in a chat panel %>
      <.scroll_area class="flex-1 min-h-0">
        <div class="p-4 space-y-3">
          <.chat_message :for={msg <- @messages} message={msg} />
        </div>
      </.scroll_area>

  ## Example — Limited Height List

  Show at most a certain height of content and scroll for the rest:

      <.scroll_area class="max-h-64">
        <ul class="space-y-1">
          <li :for={item <- @items} class="px-3 py-2 hover:bg-muted rounded-md">
            {item.label}
          </li>
        </ul>
      </.scroll_area>

  ## Example — Horizontal Scroll for Wide Tables

  Prevent layout breaking on small screens by wrapping wide tables:

      <.scroll_area orientation="horizontal">
        <table class="min-w-[800px] w-full">
          <thead>...</thead>
          <tbody>...</tbody>
        </table>
      </.scroll_area>

  ## Example — Both Axes (2D Content)

  For content that may exceed bounds in both dimensions:

      <.scroll_area orientation="both" class="h-96 w-full max-w-2xl border rounded">
        <div class="min-w-[1200px] min-h-[600px]">
          <%# Large diagram, map, or canvas-like content %>
        </div>
      </.scroll_area>

  ## Example — Inside a Popover or Sheet

  `scroll_area/1` is commonly used inside `popover_content/1` or `sheet/1` to
  constrain long lists in confined spaces:

      <.popover id="assignee-picker">
        <.popover_trigger popover_id="assignee-picker">Assign</.popover_trigger>
        <.popover_content popover_id="assignee-picker">
          <p class="text-sm font-medium mb-2">Select assignee</p>
          <.scroll_area class="max-h-48">
            <.command_item :for={user <- @users} on_click="assign" value={user.id}>
              <.avatar src={user.avatar} alt={user.name} size={:xs} />
              {user.name}
            </.command_item>
          </.scroll_area>
        </.popover_content>
      </.popover>

  ## Sizing

  `scroll_area/1` alone does not restrict height or width — you must provide
  a size constraint via the `:class` attribute:

  - `class="h-64"` — fixed height of 256px
  - `class="max-h-64"` — grows up to 256px, then scrolls
  - `class="h-full"` — fills parent container height (parent must have height)
  - `class="flex-1 min-h-0"` — fills remaining flex space (flex parent required)

  The default `h-full` from `orientation_class/1` assumes the parent has a
  defined height. Override with `class="max-h-{n}"` for most use cases.

  ## Accessibility

  - The div itself is not focusable or interactive — it is purely a scroll
    container. Screen reader users navigate the content inside normally.
  - If the scrollable region contains interactive content, ensure keyboard
    users can reach all items within (Tab order works through the content).
  - For very long lists, consider adding a skip link or grouping mechanism
    so keyboard users can navigate efficiently.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # scroll_area/1
  # ---------------------------------------------------------------------------

  attr(:orientation, :string,
    default: "vertical",
    values: ~w(vertical horizontal both),
    doc: """
    Scroll direction(s):
    - `"vertical"` (default) — `overflow-y-auto h-full`; use for lists, feeds, sidebars
    - `"horizontal"` — `overflow-x-auto w-full`; use for wide tables, code blocks
    - `"both"` — `overflow-auto`; use for 2D content (maps, large diagrams)
    """
  )

  attr(:class, :string,
    default: nil,
    doc: """
    Additional CSS classes merged via `cn/1`. Use this to set a height or width
    constraint — the component does not restrict dimensions on its own:
    - `class="h-64"` for a fixed 256px height
    - `class="max-h-64"` to grow up to 256px and then scroll
    - `class="h-full"` to fill the parent container (parent must have height)
    """
  )

  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the scroll container `<div>`")

  slot(:inner_block, required: true, doc: "Scrollable content")

  @doc """
  Renders a styled scrollable container.

  Scrollbar appearance is controlled by the `scrollbar-thin`,
  `scrollbar-track-transparent`, and `scrollbar-thumb-muted-foreground/30`
  Tailwind classes. These use semantic color tokens so the scrollbar
  automatically adapts to dark mode and custom theme presets.

  The `overflow-*` class and the primary dimension class (`h-full` or `w-full`)
  are determined by `orientation_class/1` based on the `:orientation` attribute.
  Your `:class` override is appended last (via `cn/1`) so it wins in any
  conflict.
  """
  def scroll_area(assigns) do
    ~H"""
    <div
      class={cn([
        orientation_class(@orientation),
        "scrollbar-thin scrollbar-track-transparent scrollbar-thumb-muted-foreground/30",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Each orientation maps to a pair of CSS classes:
  # - The overflow class controls which axis scrolls
  # - The dimension class provides a fallback size that the parent can override
  #   (h-full / w-full require the parent to have a defined dimension)
  defp orientation_class("vertical"), do: "overflow-y-auto h-full"
  defp orientation_class("horizontal"), do: "overflow-x-auto w-full"
  defp orientation_class("both"), do: "overflow-auto"
end
