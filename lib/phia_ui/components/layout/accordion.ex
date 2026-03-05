defmodule PhiaUi.Components.Accordion do
  @moduledoc """
  Accordion component using exclusively `Phoenix.LiveView.JS` — no JS hooks required.

  An accordion presents a list of items where each item can expand to reveal
  its content. This implementation is zero-JavaScript-bundle: all toggle
  logic is expressed as `Phoenix.LiveView.JS` commands compiled into HTML
  `phx-click` attributes, so transitions execute without a server round-trip.

  ## Interaction Modes

  | Mode         | Behaviour                                                   |
  |--------------|-------------------------------------------------------------|
  | `:single`    | Only one item can be open at a time. Opening a new item     |
  |              | automatically closes the previously open one.              |
  | `:multiple`  | Any number of items can be open simultaneously.            |

  ## Sub-components

  | Function              | Element  | Purpose                                       |
  |-----------------------|----------|-----------------------------------------------|
  | `accordion/1`         | `div`    | Root container                                |
  | `accordion_item/1`    | `div`    | Per-item wrapper with border and spacing      |
  | `accordion_trigger/1` | `button` | Toggle button with animated chevron + ARIA    |
  | `accordion_content/1` | `div`    | Collapsible content panel                     |

  ## Example — FAQ (single mode)

  The most common use case: a list of questions where only one answer is
  visible at a time, reducing cognitive load.

      <.accordion id="faq" type={:single}>
        <.accordion_item value="q1" type={:single} accordion_id="faq">
          <.accordion_trigger value="q1" type={:single} accordion_id="faq">
            What is PhiaUI?
          </.accordion_trigger>
          <.accordion_content value="q1">
            A Phoenix LiveView UI component library inspired by shadcn/ui.
          </.accordion_content>
        </.accordion_item>

        <.accordion_item value="q2" type={:single} accordion_id="faq">
          <.accordion_trigger value="q2" type={:single} accordion_id="faq">
            Do I need to install any JavaScript packages?
          </.accordion_trigger>
          <.accordion_content value="q2">
            No. The accordion uses only Phoenix.LiveView.JS for all interactions.
          </.accordion_content>
        </.accordion_item>
      </.accordion>

  ## Example — Settings Panel (multiple mode)

  Use `:multiple` when independent sections can all be open at once, such as
  a settings page with distinct categories.

      <.accordion id="settings" type={:multiple}>
        <.accordion_item value="profile" type={:multiple} accordion_id="settings">
          <.accordion_trigger value="profile" type={:multiple} accordion_id="settings">
            Profile Settings
          </.accordion_trigger>
          <.accordion_content value="profile">
            <.input name="name" label="Display Name" value={@user.name} />
          </.accordion_content>
        </.accordion_item>

        <.accordion_item value="notifications" type={:multiple} accordion_id="settings">
          <.accordion_trigger value="notifications" type={:multiple} accordion_id="settings">
            Notification Preferences
          </.accordion_trigger>
          <.accordion_content value="notifications">
            <.checkbox name="email_notifs" label="Email notifications" />
          </.accordion_content>
        </.accordion_item>
      </.accordion>

  ## Opening an Item by Default

  Pass `open={true}` to both the trigger and the content to render a specific
  item expanded on first load. This is the recommended way to implement
  `default_value` behaviour:

      <%# Open the item whose value matches the initial default %>
      <.accordion_trigger value="q1" ... open={"q1" == @default_open}>
      <.accordion_content value="q1" ... open={"q1" == @default_open}>

  ## Collapsible Single Mode

  By default in `:single` mode, clicking the currently open item does nothing
  (the item stays open). Pass `collapsible={true}` to the trigger to allow
  re-clicking an open item to close it:

      <.accordion_trigger value="q1" type={:single} accordion_id="faq" collapsible={true}>

  ## Disabled Items

  Prevent interaction on specific items using the `:disabled` attribute on
  `accordion_item/1`. The item renders with `opacity-50` and `pointer-events-none`:

      <.accordion_item value="premium" type={:single} accordion_id="faq" disabled={!@user.premium}>

  ## Accessibility

  - Trigger buttons use `aria-expanded` (toggled via `JS.set_attribute`) and
    `aria-controls` pointing at the content panel ID
  - Content panels use stable IDs (`accordion-content-{value}`) referenced by
    `aria-controls`
  - The chevron icon carries `aria-hidden="true"` so screen readers ignore it
  - Disabled items get `aria-disabled="true"` on the wrapper div
  """

  use Phoenix.Component

  alias Phoenix.LiveView.JS

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # accordion/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    default: nil,
    doc: """
    Unique ID for the root container. **Required for `:single` mode** — the
    `accordion_trigger/1` uses this ID to target all sibling items via CSS
    selectors like `#faq [data-accordion-content]` when closing others.
    """
  )

  attr(:type, :atom,
    values: [:single, :multiple],
    default: :single,
    doc: "Interaction mode: `:single` allows one open item, `:multiple` allows many"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the root `<div>`")

  slot(:inner_block, required: true, doc: "`accordion_item/1` sub-components")

  @doc """
  Renders the accordion root container.

  The `id` is the coordination point for `:single` mode — all child triggers
  reference it to close sibling items when a new one is opened.
  """
  def accordion(assigns) do
    ~H"""
    <div id={@id} class={cn(["w-full", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # accordion_item/1
  # ---------------------------------------------------------------------------

  attr(:value, :string,
    required: true,
    doc: """
    Unique string identifier for this item within the accordion. Used to build
    stable DOM IDs: `accordion-trigger-{value}` and `accordion-content-{value}`.
    Must be unique across all items in the same accordion instance.
    """
  )

  attr(:type, :atom,
    values: [:single, :multiple],
    default: :single,
    doc: "Inherited from the parent `accordion/1` — controls toggle behaviour"
  )

  attr(:accordion_id, :string,
    default: nil,
    doc: "ID of the parent `accordion/1` — required for `:single` exclusivity"
  )

  attr(:disabled, :boolean,
    default: false,
    doc: """
    When `true`, prevents interaction with this item. Applies `pointer-events-none`
    and `opacity-50` via CSS, and sets `aria-disabled="true"` for screen readers.
    Use this to indicate that a feature is unavailable (e.g. behind a paywall).
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the wrapper `<div>`")

  slot(:inner_block,
    required: true,
    doc: "`accordion_trigger/1` and `accordion_content/1` sub-components"
  )

  @doc """
  Renders an accordion item wrapper.

  Each item has a bottom border by default to visually separate it from its
  neighbours. The border is part of the item — not the root container — so
  there is no double-border at the top of the first item.
  """
  def accordion_item(assigns) do
    ~H"""
    <div
      aria-disabled={@disabled && "true"}
      class={cn(["border-b", @disabled && "pointer-events-none opacity-50", @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # accordion_trigger/1
  # ---------------------------------------------------------------------------

  attr(:value, :string,
    required: true,
    doc: "Must match the `:value` of the parent `accordion_item/1`"
  )

  attr(:type, :atom,
    values: [:single, :multiple],
    default: :single,
    doc: "Inherited from the parent `accordion/1` — controls the JS toggle strategy"
  )

  attr(:accordion_id, :string,
    default: nil,
    doc: "ID of the parent `accordion/1` — required for `:single` mode to close siblings"
  )

  attr(:collapsible, :boolean,
    default: false,
    doc: """
    When `true` in `:single` mode, clicking the currently open item closes it.
    When `false` (default), the open item cannot be closed by clicking its trigger —
    exactly one item is always open once any item has been opened.
    Only effective in `:single` mode with `accordion_id` set.
    """
  )

  attr(:open, :boolean,
    default: false,
    doc: """
    When `true`, the item starts in the expanded state. This controls the
    initial `aria-expanded` attribute and the chevron rotation. Pair with
    `open={true}` on the corresponding `accordion_content/1`.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the `<button>`")

  slot(:inner_block, required: true, doc: "Trigger label — question text, section name, etc.")

  @doc """
  Renders the accordion trigger button with `Phoenix.LiveView.JS`-powered toggle.

  The toggle JS command is computed at render time by `build_toggle_js/4` and
  embedded into the `phx-click` attribute. This means the client executes the
  animation directly without a server round-trip.

  The animated chevron rotates 180° when the item is open. It is driven by
  the `rotate-180` Tailwind class toggled by the JS command, and uses
  `transition-transform` for a smooth animation.

  ## ARIA attributes

  - `aria-expanded` — reflects current open state; updated by the JS command
  - `aria-controls` — points to the `accordion-content-{value}` panel ID so
    screen readers can announce "controls this region"
  """
  def accordion_trigger(assigns) do
    assigns =
      assign(
        assigns,
        :on_click,
        build_toggle_js(assigns.type, assigns.value, assigns.accordion_id, assigns.collapsible)
      )

    ~H"""
    <button
      id={"accordion-trigger-#{@value}"}
      type="button"
      aria-expanded={to_string(@open)}
      aria-controls={"accordion-content-#{@value}"}
      phx-click={@on_click}
      data-accordion-trigger
      class={cn([
        "flex flex-1 w-full items-center justify-between py-4 font-medium",
        "transition-all hover:underline text-left",
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
      <%!-- Chevron: rotates 180° when the item is open; aria-hidden so screen readers ignore it --%>
      <svg
        id={"chevron-#{@value}"}
        xmlns="http://www.w3.org/2000/svg"
        width="24"
        height="24"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
        class={cn([
          "h-4 w-4 shrink-0 transition-transform duration-200",
          @open && "rotate-180"
        ])}
        data-chevron
        aria-hidden="true"
      >
        <path d="m6 9 6 6 6-6" />
      </svg>
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # accordion_content/1
  # ---------------------------------------------------------------------------

  attr(:value, :string,
    required: true,
    doc: "Must match the `:value` of the parent `accordion_item/1`"
  )

  attr(:open, :boolean,
    default: false,
    doc: """
    When `true`, the content starts visible (rendered with `display: block`).
    Pair with `open={true}` on the corresponding `accordion_trigger/1` to
    render an item expanded on first load.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the content `<div>`")

  slot(:inner_block, required: true, doc: "Content shown when the item is expanded")

  @doc """
  Renders the collapsible accordion content panel.

  The panel ID (`accordion-content-{value}`) is the coordination point:
  - `accordion_trigger/1` references it via `aria-controls`
  - The JS toggle commands target it by ID

  By default the panel starts hidden (`display: none`). The inner `pb-4 pt-0`
  wrapper provides consistent padding without affecting the transition.

  ## Default Open

  To render an item expanded on initial page load, pass `open={true}` to both
  the trigger and its corresponding content:

      <.accordion_trigger value="welcome" ... open={@default_open == "welcome"}>
        Welcome
      </.accordion_trigger>
      <.accordion_content value="welcome" open={@default_open == "welcome"}>
        Content here.
      </.accordion_content>
  """
  def accordion_content(assigns) do
    ~H"""
    <div
      id={"accordion-content-#{@value}"}
      style={if @open, do: "display: block;", else: "display: none;"}
      class={cn(["overflow-hidden transition-all duration-200", @class])}
      data-accordion-content
      {@rest}
    >
      <div class="pb-4 pt-0">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Single non-collapsible: hide ALL content panels in this accordion, then show only
  # the clicked one. Also resets all chevrons and aria-expanded across siblings.
  # The `:single` (non-collapsible) contract is: one item is always open once any is opened.
  defp build_toggle_js(:single, value, accordion_id, false) when not is_nil(accordion_id) do
    JS.hide(to: "##{accordion_id} [data-accordion-content]")
    |> JS.show(to: "#accordion-content-#{value}")
    |> JS.set_attribute({"aria-expanded", "false"},
      to: "##{accordion_id} [data-accordion-trigger]"
    )
    |> JS.set_attribute({"aria-expanded", "true"},
      to: "#accordion-trigger-#{value}"
    )
    |> JS.remove_class("rotate-180",
      to: "##{accordion_id} [data-chevron]"
    )
    |> JS.add_class("rotate-180", to: "#chevron-#{value}")
  end

  # Single collapsible: close all OTHER items first (using `:not()` selectors to
  # exclude the clicked item), then toggle the clicked item itself.
  # This allows the clicked item to act as a toggle: open→closed or closed→open.
  defp build_toggle_js(:single, value, accordion_id, true) when not is_nil(accordion_id) do
    JS.hide(to: "##{accordion_id} [data-accordion-content]:not(#accordion-content-#{value})")
    |> JS.set_attribute({"aria-expanded", "false"},
      to: "##{accordion_id} [data-accordion-trigger]:not(#accordion-trigger-#{value})"
    )
    |> JS.remove_class("rotate-180",
      to: "##{accordion_id} [data-chevron]:not(#chevron-#{value})"
    )
    |> JS.toggle(to: "#accordion-content-#{value}")
    |> JS.toggle_class("rotate-180", to: "#chevron-#{value}")
  end

  # Multiple mode (or single without accordion_id): simply toggle the individual item.
  # No sibling coordination needed — each item operates independently.
  defp build_toggle_js(_type, value, _accordion_id, _collapsible) do
    JS.toggle(to: "#accordion-content-#{value}")
    |> JS.toggle_class("rotate-180", to: "#chevron-#{value}")
  end
end
