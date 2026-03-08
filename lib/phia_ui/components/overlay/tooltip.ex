defmodule PhiaUi.Components.Tooltip do
  @moduledoc """
  Tooltip component powered by the `PhiaTooltip` vanilla JavaScript hook.

  Tooltips provide short, supplementary information about an element when a
  user hovers over or focuses it. They are ideal for clarifying icon buttons,
  keyboard shortcuts, truncated text, or form field guidance.

  The `PhiaTooltip` hook manages:
  - Show/hide on `mouseenter`/`mouseleave` and `focus`/`blur` events
  - Configurable delay before showing (avoids flash on quick mouse movement)
  - Smart viewport-edge flipping (repositions to the opposite side if the
    tooltip would overflow the viewport)
  - CSS opacity transition for a smooth reveal

  ## Sub-components

  | Function           | Element | Purpose                                              |
  |--------------------|---------|------------------------------------------------------|
  | `tooltip/1`        | `div`   | Root container — hook mount point                    |
  | `tooltip_trigger/1`| `span`  | Trigger wrapper with `aria-describedby`              |
  | `tooltip_content/1`| `div`   | Floating panel with `role="tooltip"`                 |

  ## Hook Setup

  Copy the hook file via `mix phia.add tooltip`, then register it in `app.js`:

      # assets/js/app.js
      import PhiaTooltip from "./hooks/tooltip"

      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaTooltip }
      })

  ## Basic Example — Icon Button Tooltip

  The most common use case: explaining what an unlabelled icon button does.

      <.tooltip id="delete-btn-tip" delay_ms={300}>
        <.tooltip_trigger tooltip_id="delete-btn-tip">
          <button phx-click="delete_record" aria-label="Delete record">
            <.icon name="trash" />
          </button>
        </.tooltip_trigger>
        <.tooltip_content tooltip_id="delete-btn-tip" position={:top}>
          Delete this record permanently
        </.tooltip_content>
      </.tooltip>

  ## Example — Keyboard Shortcut Hint

  Show keyboard shortcuts for actions the user might not discover otherwise:

      <.tooltip id="save-shortcut" delay_ms={500}>
        <.tooltip_trigger tooltip_id="save-shortcut">
          <.button phx-click="save">Save</.button>
        </.tooltip_trigger>
        <.tooltip_content tooltip_id="save-shortcut" position={:bottom}>
          Save changes (⌘S)
        </.tooltip_content>
      </.tooltip>

  ## Example — Truncated Text Explanation

  When table cells or list items may be truncated, a tooltip can show the full
  text on hover (use a unique id per row, e.g. `"name-tip-\#{item.id}"`):

      <.tooltip id="name-tip-42" delay_ms={200}>
        <.tooltip_trigger tooltip_id="name-tip-42">
          <span class="truncate max-w-xs block">{@item.long_name}</span>
        </.tooltip_trigger>
        <.tooltip_content tooltip_id="name-tip-42" position={:right}>
          {@item.long_name}
        </.tooltip_content>
      </.tooltip>

  ## Position Values

  | Value     | Panel appears...                 |
  |-----------|----------------------------------|
  | `:top`    | Above the trigger (default)      |
  | `:bottom` | Below the trigger                |
  | `:left`   | To the left of the trigger       |
  | `:right`  | To the right of the trigger      |

  The hook reads `data-position` and adjusts the absolute CSS offset. It also
  checks viewport boundaries and flips to the opposite side when needed.

  ## Accessibility

  - `tooltip_trigger/1` wraps the trigger with `aria-describedby` pointing at
    the tooltip content's `id`. This causes screen readers to announce the
    tooltip text when focus lands on the trigger element.
  - `tooltip_content/1` uses `role="tooltip"` per the WAI-ARIA specification.
  - The tooltip is `pointer-events-none` so it does not interfere with mouse
    events on elements below it.
  - The hook also shows the tooltip on `focus` (keyboard) and hides it on
    `blur`, so keyboard-only users receive the same information.
  - Do not put interactive elements (links, buttons) inside a tooltip — use a
    `popover/1` instead.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # tooltip/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    required: true,
    doc: """
    Unique element ID. This ID is the coordination point: `tooltip_trigger/1`
    and `tooltip_content/1` both derive their IDs from it via the pattern
    `"{id}-content"`. Must be unique on the page.
    """
  )

  attr(:delay_ms, :integer,
    default: 200,
    doc: """
    Milliseconds to wait after `mouseenter` before showing the tooltip.
    A short delay (200–400ms) prevents the tooltip from flashing when the
    user's cursor merely passes over the element. Set to `0` for instant
    reveal (not recommended for most cases).
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the container")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the root `<div>`")

  slot(:inner_block,
    required: true,
    doc: "`tooltip_trigger/1` and `tooltip_content/1` sub-components"
  )

  @doc """
  Renders the tooltip root container and attaches the `PhiaTooltip` hook.

  The container is `relative inline-flex` so the absolutely-positioned content
  panel is offset relative to this element. The `data-delay` attribute passes
  the delay to the JS hook.
  """
  def tooltip(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaTooltip"
      data-delay={@delay_ms}
      class={cn(["relative inline-flex z-50", @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # tooltip_trigger/1
  # ---------------------------------------------------------------------------

  attr(:tooltip_id, :string,
    required: true,
    doc: "ID of the parent `tooltip/1` container — used to build `aria-describedby`"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the wrapper `<span>`")

  slot(:inner_block,
    required: true,
    doc: """
    The element that triggers the tooltip — typically a `<button>`, link, or
    any focusable element. Wrap your trigger here rather than placing event
    handlers on the outer tooltip container.
    """
  )

  @doc """
  Renders the tooltip trigger wrapper.

  Sets `aria-describedby` pointing at `"{tooltip_id}-content"`. This ARIA
  relationship ensures screen readers announce the tooltip text when the user
  focuses or hovers the trigger — even if the tooltip is not visually shown
  yet (screen readers read `aria-describedby` regardless of visual state).

  The `data-tooltip-trigger` attribute is the hook's selector to attach
  `mouseenter`, `mouseleave`, `focus`, and `blur` event listeners.
  """
  def tooltip_trigger(assigns) do
    ~H"""
    <span
      aria-describedby={"#{@tooltip_id}-content"}
      data-tooltip-trigger
      class={cn([@class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  # ---------------------------------------------------------------------------
  # tooltip_content/1
  # ---------------------------------------------------------------------------

  attr(:tooltip_id, :string,
    required: true,
    doc: "ID of the parent `tooltip/1` container — used to build the panel's `id`"
  )

  attr(:position, :atom,
    default: :top,
    values: [:top, :bottom, :left, :right],
    doc: """
    Preferred position of the tooltip panel relative to the trigger.
    The hook reads `data-position` and may flip to the opposite side if the
    panel would overflow the viewport edge.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the tooltip panel `<div>`")

  slot(:inner_block, required: true, doc: "Tooltip text or content — keep it brief")

  @doc """
  Renders the floating tooltip content panel.

  Starts invisible via `opacity-0 invisible` (not `display: none`) so that
  CSS opacity transitions work smoothly. The hook adds/removes Tailwind
  visibility classes to reveal and hide the panel.

  `pointer-events-none` prevents the panel from capturing mouse events, which
  would interfere with the `mouseleave` detection on the trigger.

  The `role="tooltip"` attribute, combined with the trigger's `aria-describedby`,
  satisfies the WAI-ARIA tooltip pattern. The content must be short and
  supplementary — not critical or interactive.
  """
  def tooltip_content(assigns) do
    ~H"""
    <div
      id={"#{@tooltip_id}-content"}
      role="tooltip"
      data-position={@position}
      data-tooltip-content
      class={cn([
        "absolute z-50 rounded-md bg-popover text-popover-foreground",
        "px-3 py-1.5 text-sm shadow-md",
        "opacity-0 invisible pointer-events-none transition-opacity duration-150",
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
