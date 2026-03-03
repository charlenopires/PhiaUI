defmodule PhiaUi.Components.Tooltip do
  @moduledoc """
  Tooltip component with PhiaTooltip vanilla JS hook.

  Pure composable HEEx sub-components. The hook handles show/hide on
  mouseenter/mouseleave and focus/blur, with configurable delay and
  smart viewport-edge flipping.

  ## Sub-components

  - `tooltip/1` — wrapper div with `phx-hook="PhiaTooltip"` and `data-delay`
  - `tooltip_trigger/1` — trigger element with `aria-describedby`
  - `tooltip_content/1` — floating panel with `role="tooltip"` and position

  ## Example

      <.tooltip id="user-tip" delay_ms={200}>
        <.tooltip_trigger tooltip_id="user-tip">
          <button>Hover me</button>
        </.tooltip_trigger>
        <.tooltip_content tooltip_id="user-tip" position={:top}>
          This is helpful context.
        </.tooltip_content>
      </.tooltip>

  ## Hook setup

  Copy `priv/templates/js/hooks/tooltip.js` to your project via:

      mix phia.add tooltip

  Then register in your `app.js`:

      import PhiaTooltip from "./hooks/tooltip"
      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaTooltip }
      })

  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :id, :string, required: true, doc: "Unique ID for aria coordination"
  attr :delay_ms, :integer, default: 200, doc: "Hover delay before showing tooltip (ms)"
  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global
  slot :inner_block, required: true

  @doc "Renders the tooltip wrapper with PhiaTooltip hook."
  def tooltip(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaTooltip"
      data-delay={@delay_ms}
      class={cn(["relative inline-flex", @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :tooltip_id, :string, required: true, doc: "ID of the parent tooltip wrapper"
  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global
  slot :inner_block, required: true

  @doc "Renders the tooltip trigger element."
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

  attr :tooltip_id, :string, required: true, doc: "ID of the parent tooltip wrapper"
  attr :position, :atom,
    default: :top,
    values: [:top, :bottom, :left, :right],
    doc: "Preferred position of the tooltip panel"
  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Renders the floating tooltip content panel.

  Hidden by default (`opacity-0 invisible`). The PhiaTooltip hook
  toggles visibility on trigger events. Position is communicated via
  `data-position` for the hook's `getBoundingClientRect()` logic.
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
