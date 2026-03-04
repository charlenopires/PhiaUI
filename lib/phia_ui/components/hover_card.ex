defmodule PhiaUi.Components.HoverCard do
  @moduledoc """
  HoverCard component — a rich floating panel revealed on hover with configurable delays.

  A HoverCard is used to show a preview or supplementary information about a
  linked element when the user hovers over it. It is more powerful than a
  `Tooltip` because it can contain structured content — avatars, dates,
  descriptions, action links — and it has independent open and close delays
  so users can move into the panel without it disappearing.

  Unlike a `Popover`, a HoverCard is triggered by hover (not click) and
  carries `role="tooltip"` semantics — it is supplementary information, not
  a required step in a workflow.

  ## Typical Use Cases

  - User profile previews on `@mention` links in chat or comments
  - Repository/project summaries on hover in a dashboard list
  - Link preview cards (URL, title, description) in rich text
  - Product card previews in an e-commerce catalogue

  The `PhiaHoverCard` hook manages:
  - Configurable open delay (prevents flash on quick cursor movement)
  - Configurable close delay (allows the user to move cursor into the card)
  - Smart viewport positioning and edge flipping
  - Mouse and focus event handling

  ## Sub-components

  | Function               | Element | Purpose                                              |
  |------------------------|---------|------------------------------------------------------|
  | `hover_card/1`         | `div`   | Root container — hook mount point with delay attrs   |
  | `hover_card_trigger/1` | `span`  | Hover area with `aria-describedby`                   |
  | `hover_card_content/1` | `div`   | Floating panel with `role="tooltip"`                 |

  ## Hook Setup

  Copy the hook via `mix phia.add hover_card`, then register it in `app.js`:

      # assets/js/app.js
      import PhiaHoverCard from "./hooks/hover_card"

      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaHoverCard }
      })

  ## Basic Example — User Profile Preview

  The canonical use case: hovering a username shows a brief profile card.

      <.hover_card id="user-card-42">
        <.hover_card_trigger hover_card_id="user-card-42">
          <.link href="/users/janedoe" class="font-medium hover:underline">
            @janedoe
          </.link>
        </.hover_card_trigger>
        <.hover_card_content hover_card_id="user-card-42">
          <div class="flex gap-3">
            <.avatar src={@user.avatar_url} alt={@user.name} />
            <div>
              <p class="font-semibold">{@user.name}</p>
              <p class="text-sm text-muted-foreground">@{@user.handle}</p>
              <p class="text-sm text-muted-foreground mt-1">
                Joined {Calendar.strftime(@user.joined_at, "%B %Y")}
              </p>
            </div>
          </div>
          <p class="mt-3 text-sm">{@user.bio}</p>
        </.hover_card_content>
      </.hover_card>

  ## Example — Repository Preview

  Show project metadata on hover in a list view:

      <.hover_card id="repo-card-phiaui" open_delay={400} close_delay={150}>
        <.hover_card_trigger hover_card_id="repo-card-phiaui">
          <.link href="/repos/phiaui">{@repo.name}</.link>
        </.hover_card_trigger>
        <.hover_card_content hover_card_id="repo-card-phiaui" side="right">
          <p class="font-semibold">{@repo.name}</p>
          <p class="text-sm text-muted-foreground">{@repo.description}</p>
          <div class="flex gap-4 mt-2 text-xs text-muted-foreground">
            <span>⭐ {@repo.stars}</span>
            <span>🍴 {@repo.forks}</span>
            <span>{@repo.language}</span>
          </div>
        </.hover_card_content>
      </.hover_card>

  ## Example — Custom Positioning

  Use `side="top"` when the trigger is near the bottom of the viewport:

      <.hover_card id="bottom-card" side="top" open_delay={200} close_delay={100}>
        <.hover_card_trigger hover_card_id="bottom-card">
          <span class="cursor-help underline decoration-dotted">Learn more</span>
        </.hover_card_trigger>
        <.hover_card_content hover_card_id="bottom-card" side="top">
          <p class="text-sm">Detailed explanation of this feature.</p>
        </.hover_card_content>
      </.hover_card>

  ## Side Values

  | Value      | Panel appears...                      |
  |------------|---------------------------------------|
  | `"bottom"` | Below the trigger (default)           |
  | `"top"`    | Above the trigger                     |
  | `"left"`   | To the left of the trigger            |
  | `"right"`  | To the right of the trigger           |

  The hook may flip to the opposite side if the preferred side would overflow
  the viewport.

  ## Delay Tuning

  | Use Case                               | Recommended Delays                |
  |----------------------------------------|-----------------------------------|
  | Dense lists, quick scanning            | `open_delay={500} close_delay={150}` |
  | Important previews (profile cards)     | `open_delay={300} close_delay={200}` |
  | Instant feedback (tight interaction)   | `open_delay={100} close_delay={100}` |

  ## Accessibility

  - `hover_card_trigger/1` sets `aria-describedby` pointing at the content
    panel, so screen readers announce the card content when focus lands on
    the trigger (keyboard users receive the same information as mouse users)
  - `hover_card_content/1` uses `role="tooltip"` — supplementary, non-interactive
  - If your card contains interactive elements (links, buttons), consider using
    `popover/1` instead, which has `role="dialog"` and a proper focus trap
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # hover_card/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    required: true,
    doc: """
    Unique element ID — the hook mount point. Sub-components derive their IDs
    from this value. Use a unique value per card instance when rendering in
    a list (e.g. `"user-card-\#{user.id}"`).
    """
  )

  attr(:open_delay, :integer,
    default: 300,
    doc: """
    Milliseconds to wait after `mouseenter` before showing the card.
    A moderate delay (300–500ms) avoids flashing the card as the user's cursor
    passes through the trigger on the way to something else. Set lower for
    tighter interactions.
    """
  )

  attr(:close_delay, :integer,
    default: 200,
    doc: """
    Milliseconds to wait after `mouseleave` before hiding the card.
    A close delay (150–300ms) gives the user time to move their cursor from
    the trigger into the floating card without it disappearing mid-movement.
    """
  )

  attr(:side, :string,
    default: "bottom",
    values: ~w(top bottom left right),
    doc: "Preferred side for the floating panel. The hook may flip this if needed."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the container")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the root `<div>`")

  slot(:inner_block,
    required: true,
    doc: "`hover_card_trigger/1` and `hover_card_content/1` sub-components"
  )

  @doc """
  Renders the hover card root container and attaches the `PhiaHoverCard` hook.

  The `data-trigger="hover"`, `data-open-delay`, `data-close-delay`, and
  `data-side` attributes pass configuration to the JS hook. The hook reads
  these on mount to configure its event listeners and positioning logic.
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

  # ---------------------------------------------------------------------------
  # hover_card_trigger/1
  # ---------------------------------------------------------------------------

  attr(:hover_card_id, :string,
    required: true,
    doc: "ID of the parent `hover_card/1` — used to build `aria-describedby`"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the wrapper `<span>`")

  slot(:inner_block,
    required: true,
    doc: """
    The element that reveals the hover card. Typically an `<a>` link, a user
    handle, or any inline element. The hook attaches `mouseenter`/`mouseleave`
    listeners to `data-hover-card-trigger`.
    """
  )

  @doc """
  Renders the hover trigger wrapper.

  Sets `aria-describedby` pointing at `"{hover_card_id}-content"`. Screen
  readers will announce the card content when the user focuses the trigger —
  keyboard users receive the same information as mouse users.

  The `data-hover-card-trigger` attribute is the hook's selector for attaching
  mouse and focus event listeners.
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

  # ---------------------------------------------------------------------------
  # hover_card_content/1
  # ---------------------------------------------------------------------------

  attr(:hover_card_id, :string,
    required: true,
    doc: "ID of the parent `hover_card/1` — used to build the panel's element `id`"
  )

  attr(:side, :string,
    default: "bottom",
    values: ~w(top bottom left right),
    doc: """
    Preferred display side for this content panel. Takes precedence over the
    `side` set on the parent `hover_card/1`. Use this override when the
    container and content panel should logically have different preferred sides.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the content panel")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the panel `<div>`")

  slot(:inner_block,
    required: true,
    doc: """
    Hover card body. Can contain structured content — avatars, descriptions,
    stats, inline links. Keep the layout compact and relevant.
    Note: if you need the user to interact with buttons or forms in the card,
    use `popover/1` instead, which has a focus trap.
    """
  )

  @doc """
  Renders the floating hover card content panel.

  Hidden by default via `display: none` (the `hidden` class). The `PhiaHoverCard`
  hook removes this class after the `open_delay` elapses and positions the
  panel relative to the trigger using `getBoundingClientRect`.

  Uses semantic Tailwind tokens (`bg-popover`, `text-popover-foreground`,
  `border-border`) so the panel automatically respects dark mode and custom
  theme presets without any additional CSS.

  The `data-hover-card-content` attribute is the hook's selector for the
  element to show/hide. The `data-side` attribute tells the hook which edge
  to compute the initial offset from.
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
