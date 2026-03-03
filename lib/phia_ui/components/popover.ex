defmodule PhiaUi.Components.Popover do
  @moduledoc """
  Popover component with PhiaPopover vanilla JS hook.

  Click-to-open floating panel with focus trap, Escape-to-close,
  click-outside-to-close, and smart viewport-edge positioning.

  ## Sub-components

  - `popover/1` — wrapper div with `phx-hook="PhiaPopover"`
  - `popover_trigger/1` — trigger button with `aria-expanded`/`aria-controls`
  - `popover_content/1` — floating panel with `role="dialog"`, `aria-modal`

  ## Example

      <.popover id="settings-pop">
        <.popover_trigger popover_id="settings-pop">
          Settings
        </.popover_trigger>
        <.popover_content popover_id="settings-pop" position={:bottom}>
          <input type="text" name="name" placeholder="Your name" />
          <button type="submit">Save</button>
        </.popover_content>
      </.popover>

  ## Hook setup

      import PhiaPopover from "./hooks/popover"
      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaPopover }
      })

  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :id, :string, required: true, doc: "Unique ID for aria coordination"
  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global
  slot :inner_block, required: true

  @doc "Renders the popover wrapper with PhiaPopover hook."
  def popover(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaPopover"
      class={cn(["relative inline-flex", @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :popover_id, :string, required: true, doc: "ID of the parent popover wrapper"
  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global
  slot :inner_block, required: true

  @doc "Renders the trigger button that opens/closes the popover."
  def popover_trigger(assigns) do
    ~H"""
    <button
      type="button"
      aria-controls={"#{@popover_id}-content"}
      aria-expanded="false"
      data-popover-trigger
      class={cn([@class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  attr :popover_id, :string, required: true, doc: "ID of the parent popover wrapper"
  attr :position, :atom,
    default: :bottom,
    values: [:top, :bottom, :left, :right],
    doc: "Preferred position of the floating panel"
  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Renders the floating popover content panel.

  Hidden by default. The PhiaPopover hook toggles visibility on trigger click.
  Includes focus trap (Tab/Shift+Tab), Escape-to-close, and click-outside-to-close.
  """
  def popover_content(assigns) do
    ~H"""
    <div
      id={"#{@popover_id}-content"}
      role="dialog"
      aria-modal="true"
      data-position={@position}
      data-popover-content
      class={cn([
        "absolute z-50 rounded-md border border-border bg-popover text-popover-foreground",
        "p-4 shadow-md outline-none",
        "hidden",
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
