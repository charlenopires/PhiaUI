defmodule PhiaUi.Components.HoverCard do
  @moduledoc """
  HoverCard component — a floating content panel revealed on hover.

  Uses the `PhiaHoverCard` vanilla JS hook (extends PhiaPopover hover behavior)
  for open/close delays, smart viewport positioning, and accessible markup.

  ## Sub-components

  - `hover_card/1` — root container with `phx-hook="PhiaHoverCard"`, delay attrs
  - `hover_card_trigger/1` — trigger wrapper with `aria-describedby`
  - `hover_card_content/1` — floating panel with `role="tooltip"`, semantic tokens

  ## Examples

      <.hover_card id="user-card">
        <.hover_card_trigger hover_card_id="user-card">
          @alice
        </.hover_card_trigger>
        <.hover_card_content hover_card_id="user-card">
          <p class="font-semibold">Alice</p>
          <p class="text-sm text-muted-foreground">Joined January 2024</p>
        </.hover_card_content>
      </.hover_card>

      <%# Custom delays and side %>
      <.hover_card id="info-card" open_delay={500} close_delay={100} side="top">
        <.hover_card_trigger hover_card_id="info-card">
          Info
        </.hover_card_trigger>
        <.hover_card_content hover_card_id="info-card" side="top">
          Tooltip-like info panel
        </.hover_card_content>
      </.hover_card>

  ## Hook setup

      import PhiaHoverCard from "./hooks/hover_card"
      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaHoverCard }
      })

  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:id, :string, required: true, doc: "Unique ID used for aria coordination")

  attr(:open_delay, :integer,
    default: 300,
    doc: "Milliseconds to wait before opening the card on hover (default 300)"
  )

  attr(:close_delay, :integer,
    default: 200,
    doc: "Milliseconds to wait before closing the card after hover ends (default 200)"
  )

  attr(:side, :string,
    default: "bottom",
    values: ~w(top bottom left right),
    doc: "Preferred side for the floating panel (default bottom)"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the container")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc """
  Renders the hover card container.

  Attaches `phx-hook="PhiaHoverCard"` for open/close delay management,
  smart viewport positioning, and mouse/focus event handling.
  """
  def hover_card(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaHoverCard"
      data-trigger="hover"
      data-open-delay={@open_delay}
      data-close-delay={@close_delay}
      data-side={@side}
      class={cn(["relative inline-flex", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr(:hover_card_id, :string, required: true, doc: "ID of the parent hover_card container")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc """
  Renders the hover trigger wrapper.

  Sets `aria-describedby` pointing at the content panel id so screen readers
  announce the hover card when focus lands on the trigger.
  """
  def hover_card_trigger(assigns) do
    ~H"""
    <span
      aria-describedby={"#{@hover_card_id}-content"}
      data-hover-card-trigger
      class={cn([@class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end

  attr(:hover_card_id, :string, required: true, doc: "ID of the parent hover_card container")

  attr(:side, :string,
    default: "bottom",
    values: ~w(top bottom left right),
    doc: "Preferred display side — overrides the container's side for this panel"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc """
  Renders the floating hover card content panel.

  Hidden by default; the `PhiaHoverCard` hook toggles visibility after the
  `open_delay` elapses. Uses only semantic Tailwind tokens so dark mode works
  automatically.
  """
  def hover_card_content(assigns) do
    ~H"""
    <div
      id={"#{@hover_card_id}-content"}
      role="tooltip"
      data-hover-card-content
      data-side={@side}
      class={cn([
        "absolute z-50 rounded-md border border-border",
        "bg-popover text-popover-foreground",
        "shadow-md p-4 outline-none",
        "hidden",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
