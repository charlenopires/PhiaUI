defmodule PhiaUi.Components.Drawer do
  @moduledoc """
  Drawer component — a sliding panel that enters from the edge of the screen.

  Uses the `PhiaDrawer` JavaScript Hook for focus trap, keyboard navigation
  (Escape to close), backdrop click dismissal, and CSS transform animations.

  ## Registration in app.js

  After running `mix phia.add drawer`, register the hook in your LiveSocket:

      import PhiaDrawer from "./phia_hooks/drawer.js"

      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaDrawer, ...yourOtherHooks }
      })

  ## Example

      <.drawer id="settings-drawer">
        <.drawer_trigger drawer_id="settings-drawer">
          <.button>Open Settings</.button>
        </.drawer_trigger>

        <.drawer_content id="settings-content" open={@show_drawer} direction="right">
          <.drawer_header>
            <h2 id="settings-title">Settings</h2>
          </.drawer_header>
          <.drawer_close />
          <div class="p-6">
            <p>Drawer body content goes here.</p>
          </div>
          <.drawer_footer>
            <button phx-click="save">Save</button>
          </.drawer_footer>
        </.drawer_content>
      </.drawer>

  ## Sub-components

  | Function           | Purpose                                        |
  |--------------------|------------------------------------------------|
  | `drawer/1`         | Root container, wraps trigger + content        |
  | `drawer_trigger/1` | Button that opens the drawer                   |
  | `drawer_content/1` | Sliding panel + backdrop (hook anchor)         |
  | `drawer_header/1`  | Title and description layout container         |
  | `drawer_footer/1`  | Action row at the bottom                       |
  | `drawer_close/1`   | × close button in the top-right corner         |

  ## Directions

  | Value      | Slides from    | Panel sizing             |
  |------------|----------------|--------------------------|
  | `"bottom"` | bottom edge    | full width, max-h 85vh   |
  | `"top"`    | top edge       | full width, max-h 85vh   |
  | `"left"`   | left edge      | full height, w-3/4 max-w-sm |
  | `"right"`  | right edge     | full height, w-3/4 max-w-sm |
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # drawer/1
  # ---------------------------------------------------------------------------

  @doc """
  Root container for the Drawer. Wraps both `drawer_trigger/1` and
  `drawer_content/1`.
  """
  attr(:id, :string, required: true, doc: "Unique drawer ID")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes")
  slot(:inner_block, required: true, doc: "Drawer trigger and content")

  def drawer(assigns) do
    ~H"""
    <div id={@id} class={cn(["relative", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # drawer_trigger/1
  # ---------------------------------------------------------------------------

  @doc """
  Opens the drawer. The `PhiaDrawer` JS hook listens for clicks on elements
  with `data-drawer-trigger` and shows the matching drawer content.
  """
  attr(:drawer_id, :string, required: true, doc: "ID of the parent drawer to open")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes")
  slot(:inner_block, required: true, doc: "Trigger button content")

  def drawer_trigger(assigns) do
    ~H"""
    <button
      type="button"
      data-drawer-trigger={@drawer_id}
      class={cn([@class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # drawer_content/1
  # ---------------------------------------------------------------------------

  @doc """
  The drawer surface: renders the semi-transparent backdrop and the sliding
  panel. Hidden by default when `open={false}`.

  The `PhiaDrawer` hook (bound via `phx-hook`) handles:
  - CSS transform animation (translate in/out)
  - Focus trap (Tab / Shift+Tab cycle)
  - Escape key to close
  - Backdrop click to close
  - Focus return to trigger on close
  """
  attr(:id, :string, required: true, doc: "Content element ID (hook anchor)")

  attr(:open, :boolean,
    default: false,
    doc: "Whether the drawer is open (controls hidden class)"
  )

  attr(:direction, :string,
    default: "bottom",
    values: ~w(bottom top left right),
    doc: "Direction the drawer slides in from"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the panel")
  attr(:rest, :global, doc: "HTML attributes")
  slot(:inner_block, required: true, doc: "Drawer panel content")

  def drawer_content(assigns) do
    ~H"""
    <div
      id={@id}
      role="dialog"
      aria-modal="true"
      aria-labelledby={"#{@id}-title"}
      phx-hook="PhiaDrawer"
      data-direction={@direction}
      class={cn([
        "fixed inset-0 z-50",
        !@open && "hidden"
      ])}
      {@rest}
    >
      <%!-- Backdrop --%>
      <div
        data-drawer-backdrop
        class="fixed inset-0 bg-black/80 transition-opacity"
        aria-hidden="true"
      >
      </div>
      <%!-- Sliding panel --%>
      <div
        data-drawer-panel
        class={cn([
          "fixed bg-background shadow-lg",
          "transition-transform duration-300 ease-out",
          panel_position_classes(@direction),
          @class
        ])}
      >
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # drawer_header/1
  # ---------------------------------------------------------------------------

  @doc "Layout container for the drawer title and optional description."
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes")
  slot(:inner_block, required: true, doc: "Header content")

  def drawer_header(assigns) do
    ~H"""
    <div class={cn(["flex flex-col space-y-1.5 p-6", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # drawer_footer/1
  # ---------------------------------------------------------------------------

  @doc "Action row at the bottom of the drawer (save, cancel, etc.)."
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes")
  slot(:inner_block, required: true, doc: "Footer content")

  def drawer_footer(assigns) do
    ~H"""
    <div
      class={cn([
        "flex flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2 p-6 pt-0",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # drawer_close/1
  # ---------------------------------------------------------------------------

  @doc """
  The × close button rendered in the top-right corner of the panel.
  The `PhiaDrawer` JS hook handles the actual close behavior.
  """
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes")

  def drawer_close(assigns) do
    ~H"""
    <button
      type="button"
      data-drawer-close
      aria-label="Close drawer"
      class={cn([
        "absolute right-4 top-4 rounded-sm opacity-70 ring-offset-background",
        "transition-opacity hover:opacity-100",
        "focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2",
        @class
      ])}
      {@rest}
    >
      <svg
        class="h-4 w-4"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
        aria-hidden="true"
      >
        <path d="M18 6 6 18M6 6l12 12" />
      </svg>
      <span class="sr-only">Close</span>
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp panel_position_classes("bottom"),
    do: "inset-x-0 bottom-0 border-t max-h-[85vh] overflow-y-auto rounded-t-lg"

  defp panel_position_classes("top"),
    do: "inset-x-0 top-0 border-b max-h-[85vh] overflow-y-auto rounded-b-lg"

  defp panel_position_classes("left"),
    do: "inset-y-0 left-0 border-r h-full w-3/4 max-w-sm overflow-y-auto"

  defp panel_position_classes("right"),
    do: "inset-y-0 right-0 border-l h-full w-3/4 max-w-sm overflow-y-auto"
end
