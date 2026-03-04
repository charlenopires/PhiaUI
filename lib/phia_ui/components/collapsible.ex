defmodule PhiaUi.Components.Collapsible do
  @moduledoc """
  Collapsible section component using exclusively `Phoenix.LiveView.JS` — no JS hooks required.

  A lightweight show/hide container with an accessible trigger button and a
  content panel. Unlike `Accordion`, `Collapsible` is a standalone primitive
  for a single expandable section — not a list. Use it for things like advanced
  filter panels, inline help text, expandable code blocks, or "show more" UI.

  All interactivity is expressed as `Phoenix.LiveView.JS` commands compiled
  directly into the `phx-click` attribute, so transitions execute without a
  server round-trip.

  ## Sub-components

  | Function                | Element  | Purpose                                          |
  |-------------------------|----------|--------------------------------------------------|
  | `collapsible/1`         | `div`    | Root container — requires a unique `:id`         |
  | `collapsible_trigger/1` | `button` | Toggle button with `aria-expanded`/`aria-controls` |
  | `collapsible_content/1` | `div`    | The show/hide panel                              |

  ## Example — Closed by Default

  The simplest case: a section that starts collapsed. A user clicks the trigger
  to reveal the content.

      <.collapsible id="advanced-options">
        <.collapsible_trigger collapsible_id="advanced-options" open={false}>
          <span>Advanced Options</span>
          <.icon name="chevron-down" />
        </.collapsible_trigger>
        <.collapsible_content id="advanced-options-content" open={false}>
          <.input name="timeout" label="Request timeout (ms)" value="5000" />
          <.input name="retries" label="Max retries" value="3" />
        </.collapsible_content>
      </.collapsible>

  ## Example — Open by Default

  Pass `open={true}` to start the panel expanded. Useful for sections that
  show important content that should be immediately visible.

      <.collapsible id="current-filters" open={true}>
        <.collapsible_trigger collapsible_id="current-filters" open={true}>
          Active Filters (3)
        </.collapsible_trigger>
        <.collapsible_content id="current-filters-content" open={true}>
          <.badge :for={f <- @active_filters}>{f.label}</.badge>
        </.collapsible_content>
      </.collapsible>

  ## Example — Server-Controlled State

  When you need the server to control expand/collapse (e.g. after a form
  submission reveals an error section), pass a LiveView assign to all three
  `:open` attrs. The server can push a re-render to change the state:

      # LiveView
      def handle_event("submit", params, socket) do
        case validate(params) do
          {:error, _} -> {:noreply, assign(socket, :show_errors, true)}
          {:ok, _}    -> {:noreply, assign(socket, :show_errors, false)}
        end
      end

      # Template
      <.collapsible id="error-panel" open={@show_errors}>
        <.collapsible_trigger collapsible_id="error-panel" open={@show_errors}>
          Validation Errors
        </.collapsible_trigger>
        <.collapsible_content id="error-panel-content" open={@show_errors}>
          <.alert variant="destructive">Fix the issues below.</.alert>
        </.collapsible_content>
      </.collapsible>

  ## Example — Inline Help Text

  A compact pattern for revealing contextual help without navigating away:

      <.collapsible id="help-webhook">
        <.collapsible_trigger collapsible_id="help-webhook" open={false}
          class="text-sm text-muted-foreground hover:text-foreground">
          What is a webhook URL?
        </.collapsible_trigger>
        <.collapsible_content id="help-webhook-content" open={false}>
          <p class="text-sm text-muted-foreground mt-2">
            A webhook URL is an HTTP endpoint that receives real-time event
            notifications from our system. See the docs for details.
          </p>
        </.collapsible_content>
      </.collapsible>

  ## Coordination Between Sub-components

  All three sub-components must agree on the `:open` value to keep the
  rendered HTML consistent with the `JS.toggle` client state:

  - `collapsible/1` receives `open` for any external styling based on state
  - `collapsible_trigger/1` uses `open` to set the initial `aria-expanded` value
  - `collapsible_content/1` uses `open` to set the initial `display` style

  After the first client-side toggle, the JS manages visibility without the
  server needing to know — unless you push a re-render.

  ## Accessibility

  - Trigger has `aria-expanded` (set from `:open`) and `aria-controls` pointing
    at the content panel ID
  - Screen readers announce the control relationship and current state
  - Keyboard: the trigger is a `<button>` — naturally focusable and activatable
    with `Enter` or `Space`
  """

  use Phoenix.Component

  alias Phoenix.LiveView.JS

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # collapsible/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    required: true,
    doc: """
    Unique ID for the root container. The trigger and content sub-components
    derive their IDs from this value, so it must be unique on the page.
    `collapsible_trigger/1` receives this as `:collapsible_id`.
    `collapsible_content/1` must be given `id="{this-id}-content"`.
    """
  )

  attr(:open, :boolean,
    default: false,
    doc: "Initial open state — only used for container-level styling; see trigger and content"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root `<div>`")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the root `<div>`")

  slot(:inner_block,
    required: true,
    doc: "`collapsible_trigger/1` and `collapsible_content/1` sub-components"
  )

  @doc """
  Renders the collapsible root container.

  The `:id` is the coordination point between the three sub-components.
  `collapsible_trigger/1` uses it to build `aria-controls` and the `JS.toggle`
  target (`\#{id}-content`). `collapsible_content/1` must be given the matching
  ID (`id="{collapsible_id}-content"`).
  """
  def collapsible(assigns) do
    ~H"""
    <div id={@id} class={cn([@class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # collapsible_trigger/1
  # ---------------------------------------------------------------------------

  attr(:collapsible_id, :string,
    required: true,
    doc: """
    ID of the parent `collapsible/1`. Used to:
    1. Build `aria-controls="{collapsible_id}-content"` for ARIA linkage
    2. Build the `JS.toggle` target `"\#{collapsible_id}-content"` for the click handler
    """
  )

  attr(:open, :boolean,
    default: false,
    doc: """
    Current open state. Controls the `aria-expanded` attribute on the button.
    Should match the `:open` value passed to `collapsible_content/1` so the
    ARIA state and visual state agree on initial render.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the trigger button")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the `<button>`")

  slot(:inner_block, required: true, doc: "Trigger button content — text, icon, or both")

  @doc """
  Renders the collapsible trigger button.

  On click, fires `Phoenix.LiveView.JS.toggle/1` targeting the content panel
  identified by `collapsible_id <> "-content"`. This executes client-side
  without a server round-trip.

  The trigger is a semantic `<button type="button">` so it is keyboard
  accessible out of the box: `Enter` and `Space` both fire the click handler.

  The `aria-expanded` attribute reflects the current open state so screen
  readers announce "expanded" or "collapsed" appropriately.
  """
  def collapsible_trigger(assigns) do
    ~H"""
    <button
      type="button"
      aria-expanded={to_string(@open)}
      aria-controls={"#{@collapsible_id}-content"}
      class={cn(["flex items-center justify-between w-full", @class])}
      phx-click={JS.toggle(to: "##{@collapsible_id}-content", display: "block")}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # collapsible_content/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    required: true,
    doc: """
    ID of the content panel. **Must follow the pattern `"{collapsible_id}-content"`**
    because `collapsible_trigger/1` targets this exact ID in its `JS.toggle` command
    and builds `aria-controls` from it.
    """
  )

  attr(:open, :boolean,
    default: false,
    doc: """
    Initial visibility state. When `false` (default), renders `style="display: none;"`.
    When `true`, renders without the style override so the element is visible.
    After the first client-side toggle the JS manages visibility — this only
    affects the server-rendered initial HTML.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the content panel")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the content `<div>`")

  slot(:inner_block, required: true, doc: "Content shown when the collapsible is open")

  @doc """
  Renders the collapsible content panel.

  Hidden by default via `style="display: none;"` when `open={false}`. Using an
  inline style rather than a Tailwind class is intentional — `JS.toggle` relies
  on toggling the element's `display` style property, so a CSS class like
  `hidden` would conflict if it sets `!important`.

  The `overflow-hidden` class prevents content from bleeding outside the bounds
  when the panel is partially hidden during future CSS transition enhancements.

  The ID must match `"{collapsible_id}-content"` exactly for the trigger's
  `JS.toggle` and `aria-controls` to work correctly.
  """
  def collapsible_content(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn(["overflow-hidden", @class])}
      style={unless @open, do: "display: none;"}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
