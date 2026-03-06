defmodule PhiaUi.Components.Drawer do
  @moduledoc """
  Drawer component — a sliding panel that enters from any edge of the screen.

  A drawer provides access to supplementary content or actions without leaving
  the current page. Unlike `Sheet`, the `Drawer` is designed for content-heavy
  panels and uses its own dedicated `PhiaDrawer` JavaScript hook (rather than
  sharing `PhiaDialog`) with CSS transform animations for the enter/exit motion.

  ## When to use Drawer vs Sheet

  | Aspect           | Drawer                          | Sheet                           |
  |------------------|---------------------------------|---------------------------------|
  | JS Hook          | `PhiaDrawer` (dedicated)        | `PhiaDialog` (shared)           |
  | Panel anatomy    | Simple (header/footer/close)    | Rich (title/description/close)  |
  | Trigger          | `drawer_trigger/1` button       | Controlled by `:open` assign    |
  | Animation        | CSS transform slide             | CSS transform slide             |
  | Use case         | Side nav, detail views, step forms | Edit forms, filter panels   |

  Use `Drawer` when you want a dedicated trigger button colocated with the
  content and a simpler, content-driven panel. Use `Sheet` when state from
  the server controls open/close or when you need the richer ARIA sub-components.

  ## Hook Registration

  Copy the hook via `mix phia.add drawer`, then register it in `app.js`:

      # assets/js/app.js
      import PhiaDrawer from "./hooks/drawer"

      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaDrawer }
      })

  ## Sub-components

  | Function           | Purpose                                          |
  |--------------------|--------------------------------------------------|
  | `drawer/1`         | Root container — wraps trigger and content       |
  | `drawer_trigger/1` | Button that opens the drawer                     |
  | `drawer_content/1` | Sliding panel + backdrop — the hook mount point  |
  | `drawer_header/1`  | Title and description layout container           |
  | `drawer_footer/1`  | Action row at the bottom                         |
  | `drawer_close/1`   | × close button in the top-right corner           |

  ## Directions

  | Value      | Slides from | Default panel dimensions                    |
  |------------|-------------|---------------------------------------------|
  | `"bottom"` | bottom edge | Full width, max 85vh, rounded top corners   |
  | `"top"`    | top edge    | Full width, max 85vh, rounded bottom corners|
  | `"left"`   | left edge   | 75% width, max `sm`, full height            |
  | `"right"`  | right edge  | 75% width, max `sm`, full height            |

  ## Example — Settings Drawer (right)

  The canonical drawer pattern: a button triggers a right-side panel.

      <.drawer id="settings-drawer">
        <.drawer_trigger drawer_id="settings-drawer">
          <.button>
            <.icon name="settings" class="mr-2" />
            Settings
          </.button>
        </.drawer_trigger>

        <.drawer_content id="settings-drawer-content" direction="right">
          <.drawer_header>
            <h2 id="settings-drawer-content-title" class="text-lg font-semibold">
              Settings
            </h2>
            <p class="text-sm text-muted-foreground">
              Manage your account preferences.
            </p>
          </.drawer_header>
          <.drawer_close />
          <div class="p-6 space-y-4">
            <.input name="display_name" label="Display name" value={@user.name} />
            <.select name="timezone" label="Timezone" options={@timezones} />
            <.switch name="email_notifications" label="Email notifications" checked={@user.email_notifs} />
          </div>
          <.drawer_footer>
            <button phx-click="cancel_settings">Cancel</button>
            <button phx-click="save_settings" class="...">Save</.button>
          </.drawer_footer>
        </.drawer_content>
      </.drawer>

  ## Example — Mobile Bottom Sheet

  A bottom drawer is the mobile-native pattern for action sheets:

      <.drawer id="actions-drawer">
        <.drawer_trigger drawer_id="actions-drawer" class="md:hidden">
          <.button variant="outline">Actions</.button>
        </.drawer_trigger>

        <.drawer_content id="actions-drawer-content" direction="bottom">
          <.drawer_header>
            <h2 id="actions-drawer-content-title" class="text-sm font-medium">
              Item Actions
            </h2>
          </.drawer_header>
          <.drawer_close />
          <div class="p-4 pb-8 space-y-2">
            <button phx-click="edit_item" class="w-full text-left px-4 py-3 rounded-md hover:bg-muted">
              Edit
            </button>
            <button phx-click="duplicate_item" class="w-full text-left px-4 py-3 rounded-md hover:bg-muted">
              Duplicate
            </button>
            <button phx-click="delete_item" class="w-full text-left px-4 py-3 rounded-md text-destructive hover:bg-destructive/10">
              Delete
            </button>
          </div>
        </.drawer_content>
      </.drawer>

  ## Example — Step-by-Step Form (left drawer)

  Multi-step forms work well in a left drawer that feels like an overlay wizard:

      <.drawer id="onboarding">
        <.drawer_trigger drawer_id="onboarding">
          <.button>Start Setup</.button>
        </.drawer_trigger>

        <.drawer_content id="onboarding-content" direction="left" open={@show_onboarding}>
          <.drawer_header>
            <h2 id="onboarding-content-title" class="text-lg font-semibold">
              Setup Wizard — Step {@step} of 3
            </h2>
          </.drawer_header>
          <.drawer_close />
          <div class="p-6">
            <%= render_step(@step) %>
          </div>
          <.drawer_footer>
            <button phx-click="prev_step" disabled={@step == 1}>Back</button>
            <button phx-click="next_step">
              {if @step == 3, do: "Finish", else: "Next"}
            </button>
          </.drawer_footer>
        </.drawer_content>
      </.drawer>

  ## Server-Controlled Open State

  Pass `open={@show_drawer}` to `drawer_content/1` to control visibility from
  the server (e.g. after a navigation event or background task completion):

      <.drawer_content id="notif-content" direction="right" open={@show_notifications}>
        ...
      </.drawer_content>

      # Push from LiveView
      {:noreply, assign(socket, :show_notifications, true)}

  ## Hook Behaviour

  The `PhiaDrawer` hook (mounted on `drawer_content/1`) handles:
  - CSS `transform` animation (slide in/out) on open/close
  - Focus trap — Tab / Shift+Tab cycle within the open panel
  - `Escape` key closes the panel and returns focus to the trigger
  - Backdrop click closes the panel
  - Focus return — restores focus to `drawer_trigger/1` (or last focused element)
    when the drawer closes

  ## Accessibility

  - `drawer_content/1` has `role="dialog"` and `aria-modal="true"`
  - `aria-labelledby="{id}-title"` is auto-set — give your title heading
    the id `"{drawer-content-id}-title"` for the link to resolve
  - `drawer_close/1` has `aria-label="Close drawer"` for screen reader users
  - Keyboard: focus automatically moves to the first focusable element on open
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # drawer/1
  # ---------------------------------------------------------------------------

  @doc """
  Root container for the Drawer. Wraps both `drawer_trigger/1` and
  `drawer_content/1`. Provides the `relative` positioning context and a
  shared ID namespace.

  The root is purely a layout wrapper — no hook attaches here. The hook
  mounts on `drawer_content/1`.
  """
  attr(:id, :string, required: true, doc: "Unique drawer ID used as a namespace for child IDs")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the root `<div>`")

  slot(:inner_block, required: true, doc: "`drawer_trigger/1` and `drawer_content/1`")

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
  Wrapper that opens the drawer when any element inside it is clicked.

  Renders a `<div>` (not a `<button>`) so you can place any trigger content
  inside — including a `<.button>` — without creating invalid nested-button
  HTML. The `PhiaDrawer` hook intercepts clicks on `[data-drawer-trigger]`
  anywhere in the document via event delegation, so the wrapper element type
  does not need to be focusable itself.

  ## Example

      <.drawer_trigger drawer_id="settings-drawer">
        <.button variant="outline">
          <.icon name="settings" class="mr-2" />
          Open Settings
        </.button>
      </.drawer_trigger>
  """
  attr(:drawer_id, :string,
    required: true,
    doc: """
    ID that matches the target `drawer_content/1`'s `id` attribute.
    The hook looks for `[data-drawer-trigger]` whose value equals the
    `drawer_content/1` element's `id`.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the wrapper `<div>`")

  slot(:inner_block, required: true, doc: "Trigger content — any element, typically a `<.button>`")

  def drawer_trigger(assigns) do
    ~H"""
    <div
      data-drawer-trigger={@drawer_id}
      class={cn(["inline-flex", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # drawer_content/1
  # ---------------------------------------------------------------------------

  @doc """
  The drawer surface — renders the semi-transparent backdrop and the sliding
  panel. This is the `PhiaDrawer` hook mount point.

  The outer element is `fixed inset-0` and starts hidden when `open={false}`.
  It contains two children:
  - `data-drawer-backdrop` — the full-screen dark overlay (click to close)
  - `data-drawer-panel` — the sliding panel itself

  The hook applies CSS `transform: translate*` to the panel to create the
  slide-in animation, then removes the `hidden` class from the container.

  ## The `aria-labelledby` convention

  The `aria-labelledby` is auto-set to `"{id}-title"`. Give your title heading
  this exact ID so the reference resolves:

      <.drawer_content id="settings-content" direction="right">
        <.drawer_header>
          <h2 id="settings-content-title">Settings</h2>
        </.drawer_header>
      </.drawer_content>
  """
  attr(:id, :string,
    required: true,
    doc:
      "Content element ID — the `PhiaDrawer` hook mount point. By convention: \"{drawer_id}-content\""
  )

  attr(:open, :boolean,
    default: false,
    doc: """
    Whether the drawer is open on initial render. When `false` (default), the
    outer container has the `hidden` class. Pass `open={@show_drawer}` to
    control visibility from the server after the initial render.
    """
  )

  attr(:direction, :string,
    default: "bottom",
    values: ~w(bottom top left right),
    doc: "Direction the drawer panel slides in from"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the sliding panel")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the outer container `<div>`")

  slot(:inner_block, required: true, doc: "Drawer panel content: header, body, footer, close")

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
      <%!-- Backdrop: full-screen overlay; clicking it closes the drawer (handled by hook) --%>
      <div
        data-drawer-backdrop
        class="fixed inset-0 bg-black/80 transition-opacity"
        aria-hidden="true"
      >
      </div>
      <%!-- Sliding panel: positioned by direction classes, animated by the hook's transform --%>
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

  @doc """
  Layout container for the drawer title and optional description.

  Provides `p-6` padding and vertical `space-y-1.5` between title and
  description. Always place at the top of the drawer content, before the
  scrollable body.
  """
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes")
  slot(:inner_block, required: true, doc: "Drawer heading and optional description paragraph")

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

  @doc """
  Action row at the bottom of the drawer.

  Renders buttons in a flex row, right-aligned on desktop and stacked
  vertically (reversed order) on mobile for thumb accessibility. Use
  `pt-0` to align naturally below the last content section.

      <.drawer_footer>
        <button phx-click="cancel">Cancel</button>
        <button phx-click="save" class="...">Save</.button>
      </.drawer_footer>
  """
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes")
  slot(:inner_block, required: true, doc: "Footer content — typically cancel + action buttons")

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
  The × close button rendered in the top-right corner of the drawer panel.

  The `PhiaDrawer` JS hook listens for clicks on `data-drawer-close` and:
  1. Reverses the CSS transform animation (slides the panel out)
  2. Adds the `hidden` class to the root container after the animation
  3. Returns focus to the `drawer_trigger/1` that opened the drawer

  The `opacity-70` default with `hover:opacity-100` keeps the button
  present but unobtrusive, becoming fully visible on hover.
  """
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes")

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

  # Each direction maps to a set of Tailwind classes that:
  # 1. Pin the panel to the correct screen edge (inset-x-0/inset-y-0)
  # 2. Apply a max dimension (85vh for top/bottom prevents full-screen overlap)
  # 3. Add overflow scroll so tall content stays accessible within the panel
  # 4. Round the corners facing inward (away from the edge) for visual polish
  defp panel_position_classes("bottom"),
    do: "inset-x-0 bottom-0 border-t max-h-[85vh] overflow-y-auto rounded-t-lg"

  defp panel_position_classes("top"),
    do: "inset-x-0 top-0 border-b max-h-[85vh] overflow-y-auto rounded-b-lg"

  defp panel_position_classes("left"),
    do: "inset-y-0 left-0 border-r h-full w-3/4 max-w-sm overflow-y-auto"

  defp panel_position_classes("right"),
    do: "inset-y-0 right-0 border-l h-full w-3/4 max-w-sm overflow-y-auto"
end
