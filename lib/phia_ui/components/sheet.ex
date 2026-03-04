defmodule PhiaUi.Components.Sheet do
  @moduledoc """
  Sheet component — a sliding side panel that enters from any edge of the screen.

  A sheet is a modal panel that slides in from a screen edge, covering a portion
  of the page. It is ideal for secondary workflows that don't need a full page —
  edit forms, settings panels, filter builders, detail views, and navigation
  drawers in mobile layouts.

  Unlike `Drawer`, `Sheet` has a richer semantic sub-component set including
  `sheet_title/1` and `sheet_description/1` for proper ARIA labelling, and a
  size system (`sm`/`md`/`lg`/`xl`/`full`) to control the panel's dimension.

  Reuses the `PhiaDialog` JavaScript hook — no additional hook registration
  beyond what `Dialog` already requires.

  ## Hook Registration

  Copy the hook via `mix phia.add sheet` (or `mix phia.add dialog`), then
  register in `app.js`:

      # assets/js/app.js
      import PhiaDialog from "./hooks/dialog"

      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaDialog }
      })

  ## Sub-components

  | Function              | Purpose                                                  |
  |-----------------------|----------------------------------------------------------|
  | `sheet/1`             | Root container — hook mount point                        |
  | `sheet_header/1`      | Title + description layout container                     |
  | `sheet_title/1`       | `<h2>` heading — set `:id` for ARIA linkage              |
  | `sheet_description/1` | `<p>` supporting text — set `:id` for ARIA               |
  | `sheet_footer/1`      | Action row at the bottom (save, cancel)                  |
  | `sheet_close/1`       | × close button in the top-right corner                   |

  ## Sides

  | Value      | Slides from | Panel sizing                              |
  |------------|-------------|-------------------------------------------|
  | `"right"`  | right edge  | Full height, configurable width (default) |
  | `"left"`   | left edge   | Full height, configurable width           |
  | `"top"`    | top edge    | Full width, configurable height           |
  | `"bottom"` | bottom edge | Full width, configurable height           |

  ## Sizes

  | Value    | Width (right/left) | Height (top/bottom) | Best For                    |
  |----------|--------------------|---------------------|-----------------------------|
  | `"sm"`   | `w-64` (256px)     | `h-64`              | Simple notifications, tips  |
  | `"md"`   | `w-96` (384px)     | `h-96` (default)    | Short forms, quick edits    |
  | `"lg"`   | `max-w-lg`         | `max-h-64`          | Medium forms, settings      |
  | `"xl"`   | `max-w-xl`         | `max-h-96`          | Complex forms, rich content |
  | `"full"` | `max-w-full`       | `max-h-full`        | Full-width panels, mobile   |

  ## Example — Edit Record Form (right side)

  The most common use case: a form to edit a record without leaving the page.

      <.sheet id="edit-user-sheet" open={@show_edit} side="right" size="lg">
        <.sheet_header>
          <.sheet_title id="edit-user-sheet-title">
            Edit User
          </.sheet_title>
          <.sheet_description id="edit-user-sheet-description">
            Update the user's profile information below.
          </.sheet_description>
        </.sheet_header>
        <div class="p-6">
          <.form for={@changeset} phx-submit="save_user" phx-change="validate_user">
            <.input name="name" label="Full Name" value={@changeset.data.name} />
            <.input name="email" label="Email" value={@changeset.data.email} />
            <.input name="role" label="Role" value={@changeset.data.role} />
          </.form>
        </div>
        <.sheet_footer>
          <.sheet_close />
          <button phx-click="cancel_edit" class="...">Cancel</button>
          <button phx-click="save_user" class="...">Save changes</button>
        </.sheet_footer>
        <.sheet_close />
      </.sheet>

  ## Example — Filter Panel (left side)

  A filter sidebar that slides in from the left:

      <.sheet id="filter-sheet" open={@show_filters} side="left" size="md">
        <.sheet_header>
          <.sheet_title id="filter-sheet-title">Filters</.sheet_title>
        </.sheet_header>
        <div class="p-6 space-y-4">
          <.select name="status" label="Status" options={@status_options} />
          <.select name="category" label="Category" options={@category_options} />
          <.input type="date" name="from" label="From date" />
          <.input type="date" name="to" label="To date" />
        </div>
        <.sheet_footer>
          <button phx-click="clear_filters">Clear all</button>
          <button phx-click="apply_filters">Apply</button>
        </.sheet_footer>
        <.sheet_close />
      </.sheet>

  ## Example — Mobile Navigation Drawer (bottom side)

  A mobile-friendly navigation menu that slides up from the bottom:

      <.sheet id="mobile-nav" open={@show_mobile_nav} side="bottom" size="full">
        <.sheet_header>
          <.sheet_title id="mobile-nav-title">Navigation</.sheet_title>
        </.sheet_header>
        <nav class="p-4 grid grid-cols-2 gap-2">
          <.link navigate="~p"/dashboard"" phx-click="close_mobile_nav" class="...">
            Dashboard
          </.link>
          <.link navigate={~p"/reports"} phx-click="close_mobile_nav" class="...">
            Reports
          </.link>
        </nav>
        <.sheet_close />
      </.sheet>

  ## Controlling Visibility

  Control the sheet via the `:open` assign. Toggle from event handlers:

      # Open the sheet
      def handle_event("edit_user", %{"id" => id}, socket) do
        user = Accounts.get_user!(id)
        {:noreply, socket |> assign(:editing_user, user) |> assign(:show_edit, true)}
      end

      # Close the sheet (cancel or save)
      def handle_event("cancel_edit", _params, socket) do
        {:noreply, assign(socket, :show_edit, false)}
      end

  ## ARIA

  Always set `aria-labelledby` pointing to `sheet_title/1`'s `:id`. This is
  automatically handled if you use the convention `id="{sheet-id}-title"`.
  The `sheet/1` container already includes `aria-labelledby="{id}-title"`.

  ## Accessibility

  - `role="dialog"` and `aria-modal="true"` on the sliding panel
  - `aria-labelledby` on the panel references the title for screen reader context
  - Focus trap: Tab/Shift+Tab stay within the open sheet
  - Escape key closes the sheet and returns focus to the triggering element
  - Backdrop click closes the sheet when `on_close` is wired up
  - The × close button has `aria-label="Close sheet"` and is always
    in the Tab order for keyboard users
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias Phoenix.LiveView.JS

  # ---------------------------------------------------------------------------
  # sheet/1
  # ---------------------------------------------------------------------------

  @doc """
  Root Sheet container. Binds the `PhiaDialog` JS hook for focus trap and
  keyboard handling (Escape to close, Tab to cycle focus within the panel).

  The `open` boolean controls visibility via the `hidden` CSS class on the
  outer container. The `side` attribute controls which edge the panel slides
  from. The `size` attribute controls the panel's cross-axis dimension.

  The `on_close` attr wires a `Phoenix.LiveView.JS` command to the backdrop
  click — typically used to update the visibility assign:

      <.sheet id="settings" open={@show_settings}
        on_close={JS.push("close_settings")}>

  Or using `phx-click` directly:

      <.sheet id="settings" open={@show_settings}
        on_close={JS.push("close_settings") |> JS.hide(to: "#settings")}>
  """
  attr(:id, :string, required: true, doc: "Unique sheet ID — the `PhiaDialog` hook mount point")

  attr(:open, :boolean,
    default: false,
    doc: "Whether the sheet is currently visible. Toggle via LiveView assigns."
  )

  attr(:side, :string,
    default: "right",
    values: ~w(top right bottom left),
    doc: "Screen edge the panel slides in from"
  )

  attr(:size, :string,
    default: "md",
    values: ~w(sm md lg xl full),
    doc: "Width for left/right sides, or height for top/bottom sides"
  )

  attr(:on_close, JS,
    default: nil,
    doc: """
    `Phoenix.LiveView.JS` command executed when the backdrop is clicked. Use to
    update your visibility assign:

        on_close={JS.push("close_sheet")}
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the sliding panel")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the root element")

  slot(:inner_block,
    required: true,
    doc: "Sheet content: `sheet_header/1`, body div, `sheet_footer/1`, `sheet_close/1`"
  )

  def sheet(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaDialog"
      class={cn(["fixed inset-0 z-50", !@open && "hidden"])}
      {@rest}
    >
      <%!-- Backdrop: clicking it fires on_close if provided, giving a natural dismiss gesture --%>
      <div
        data-sheet-backdrop
        data-dialog-overlay
        class="fixed inset-0 bg-black/80 transition-opacity"
        aria-hidden="true"
        phx-click={@on_close}
      >
      </div>
      <%!-- Sliding panel: pinned to the chosen edge, sized by side + size combination --%>
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby={"#{@id}-title"}
        data-sheet-panel
        data-dialog-panel
        data-side={@side}
        class={cn([
          "fixed bg-background shadow-lg overflow-y-auto",
          "transition-transform duration-300 ease-in-out",
          panel_position_classes(@side),
          panel_size_classes(@side, @size),
          @class
        ])}
      >
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # sheet_header/1
  # ---------------------------------------------------------------------------

  @doc """
  Layout container for the sheet title and optional description.

  Provides consistent padding and vertical spacing. Always place this at the
  top of the sheet content, before the scrollable body area.
  """
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes")
  slot(:inner_block, required: true, doc: "`sheet_title/1` and optionally `sheet_description/1`")

  def sheet_header(assigns) do
    ~H"""
    <div class={cn(["flex flex-col space-y-1.5 p-6", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # sheet_title/1
  # ---------------------------------------------------------------------------

  @doc """
  Sheet heading rendered as `<h2>`.

  Set `:id` to `"{sheet-id}-title"` — the parent `sheet/1` includes
  `aria-labelledby="{id}-title"` by default. This ensures screen readers
  announce the sheet's purpose when it opens.

      <.sheet id="edit-profile" ...>
        <.sheet_title id="edit-profile-title">Edit Profile</.sheet_title>
      </.sheet>
  """
  attr(:id, :string,
    default: nil,
    doc: """
    Element ID for ARIA linkage. Set to `"{sheet-id}-title"` so the sheet's
    built-in `aria-labelledby` resolves correctly.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes")
  slot(:inner_block, required: true, doc: "Title text")

  def sheet_title(assigns) do
    ~H"""
    <h2
      id={@id}
      class={cn(["text-lg font-semibold leading-none tracking-tight", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </h2>
    """
  end

  # ---------------------------------------------------------------------------
  # sheet_description/1
  # ---------------------------------------------------------------------------

  @doc """
  Supporting text below the sheet title.

  Use to provide context about what the sheet is for or what the user should
  do. Set `:id` if you want to also wire `aria-describedby` on the sheet
  container for richer screen reader support.

      <.sheet id="settings" aria-describedby="settings-description">
        <.sheet_description id="settings-description">
          Changes take effect immediately and sync across all devices.
        </.sheet_description>
      </.sheet>
  """
  attr(:id, :string,
    default: nil,
    doc: "Element ID for `aria-describedby` linkage from the sheet container"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes")
  slot(:inner_block, required: true, doc: "Description text")

  def sheet_description(assigns) do
    ~H"""
    <p id={@id} class={cn(["text-sm text-muted-foreground", @class])} {@rest}>
      {render_slot(@inner_block)}
    </p>
    """
  end

  # ---------------------------------------------------------------------------
  # sheet_footer/1
  # ---------------------------------------------------------------------------

  @doc """
  Action row at the bottom of the sheet.

  Renders a `flex` row of buttons, right-aligned on desktop and stacked
  vertically (reversed) on mobile. Place the primary action button last in
  the template for natural desktop order.

      <.sheet_footer>
        <button phx-click="cancel">Cancel</button>
        <button phx-click="save" class="...">Save changes</button>
      </.sheet_footer>
  """
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes")
  slot(:inner_block, required: true, doc: "Footer content — typically cancel + confirm buttons")

  def sheet_footer(assigns) do
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
  # sheet_close/1
  # ---------------------------------------------------------------------------

  @doc """
  The × close button rendered in the top-right corner of the sheet panel.

  The `PhiaDialog` JS hook listens for clicks on `data-sheet-close` and:
  1. Adds the `hidden` class to the root sheet element
  2. Returns focus to the element that was focused before the sheet opened

  This button is always visible (unlike the toast close button). Keyboard
  users can Tab to it or press `Escape` to close.
  """
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes")

  def sheet_close(assigns) do
    ~H"""
    <button
      type="button"
      data-sheet-close
      aria-label="Close sheet"
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

  # Pin the panel to the appropriate screen edge and give it the correct
  # border (visible separator between panel and the dimmed page behind).
  defp panel_position_classes("right"), do: "inset-y-0 right-0 h-full border-l"
  defp panel_position_classes("left"), do: "inset-y-0 left-0 h-full border-r"
  defp panel_position_classes("top"), do: "inset-x-0 top-0 w-full border-b"
  defp panel_position_classes("bottom"), do: "inset-x-0 bottom-0 w-full border-t"

  # Map the size value to a Tailwind width (right/left) or height (top/bottom) class.
  # Using case here (not pattern matching function heads) because both side and size
  # parameters are needed together to decide the class — separate function heads
  # would require 4 × 5 = 20 clauses.
  defp panel_size_classes(side, size) when side in ~w(right left) do
    case size do
      "sm" -> "w-64"
      "md" -> "w-96"
      "lg" -> "w-full max-w-lg"
      "xl" -> "w-full max-w-xl"
      "full" -> "w-full max-w-full"
    end
  end

  defp panel_size_classes(side, size) when side in ~w(top bottom) do
    case size do
      "sm" -> "h-64"
      "md" -> "h-96"
      "lg" -> "max-h-64"
      "xl" -> "max-h-96"
      "full" -> "max-h-full"
    end
  end
end
