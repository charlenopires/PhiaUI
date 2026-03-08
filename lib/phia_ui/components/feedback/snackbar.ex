defmodule PhiaUi.Components.Snackbar do
  @moduledoc """
  Floating bottom action bar for bulk-selection feedback.

  Appears at the bottom-center of the screen when items are selected,
  showing a count/message and action buttons (assign, delete, archive…).
  Common in Gmail, Notion, Figma, Linear.

  Distinct from `Toast` (which is a passive notification). The Snackbar is
  explicitly triggered by selection state and contains interactive actions.

  Visibility is controlled server-side via the `:visible` attr — pair it
  with a LiveView assign to show/hide on selection changes.

  Zero JavaScript — visibility via `:if`.

  ## Examples

      <.snackbar visible={length(@selected) > 0}>
        <:label>{length(@selected)} contacts selected</:label>
        <:actions>
          <.button size="sm" phx-click="assign_selected">Assign</.button>
          <.button size="sm" variant="destructive" phx-click="delete_selected">Delete</.button>
        </:actions>
      </.snackbar>

      <%!-- With icon --%>
      <.snackbar visible={@selection_active}>
        <:icon><.avatar size="sm" src={@current_user.avatar} /></:icon>
        <:label>{@selected_count} items</:label>
        <:actions><.button size="sm">Move</.button></:actions>
      </.snackbar>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # Attributes
  # ---------------------------------------------------------------------------

  attr(:visible, :boolean, default: true, doc: "When `false`, the snackbar is not rendered.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root element.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>` element.")

  slot(:icon, doc: "Optional icon or avatar on the left side.")
  slot(:label, required: true, doc: "Primary message text (e.g. '3 items selected').")
  slot(:actions, doc: "Action buttons or links on the right side.")

  # ---------------------------------------------------------------------------
  # Component
  # ---------------------------------------------------------------------------

  @doc """
  Renders a floating bottom action bar for bulk-selection feedback.

  The bar slides up from the bottom center of the viewport using `phx-mounted`
  and `phx-remove` JS transitions (no JavaScript hook needed). Visibility is
  driven by the `visible` attribute — pair it with a LiveView assign to
  react to selection changes.

  The bar layout (left to right):
  - **Icon** (optional `:icon` slot) — avatar or custom icon
  - **Label** (required `:label` slot) — short message like "3 items selected"
  - **Actions** (optional `:actions` slot) — buttons on the right

  The bar uses `role="status"` and `aria-live="polite"` so screen readers
  announce the count change each time it appears or the count updates.

  ## Integration with LiveView selection state

      # LiveView handle_event
      def handle_event("toggle_select", %{"id" => id}, socket) do
        selected = toggle_id(socket.assigns.selected, id)
        {:noreply, assign(socket, selected: selected)}
      end

  ## Examples

      <%!-- Contact table with bulk actions --%>
      <.snackbar visible={length(@selected_ids) > 0}>
        <:label>{length(@selected_ids)} contacts selected</:label>
        <:actions>
          <.button size={:sm} phx-click="assign_selected">Assign</.button>
          <.button size={:sm} variant={:destructive} phx-click="delete_selected">Delete</.button>
        </:actions>
      </.snackbar>

      <%!-- File manager with move/copy/delete --%>
      <.snackbar visible={@selection_active}>
        <:icon><.icon name="file" class="text-muted-foreground" /></:icon>
        <:label>{@selected_count} items</:label>
        <:actions>
          <.button size={:sm} variant={:outline} phx-click="move_files">Move</.button>
          <.button size={:sm} variant={:outline} phx-click="copy_files">Copy</.button>
          <.button size={:sm} variant={:destructive} phx-click="delete_files">Delete</.button>
        </:actions>
      </.snackbar>
  """
  def snackbar(assigns) do
    ~H"""
    <div
      :if={@visible}
      phx-mounted={
        Phoenix.LiveView.JS.transition(
          {"transition-all ease-out duration-300",
           "opacity-0 translate-y-3 scale-95",
           "opacity-100 translate-y-0 scale-100"},
          time: 300
        )
      }
      phx-remove={
        Phoenix.LiveView.JS.transition(
          {"transition-all ease-in duration-200",
           "opacity-100 translate-y-0 scale-100",
           "opacity-0 translate-y-3 scale-95"},
          time: 200
        )
      }
      class={
        cn([
          "fixed bottom-6 left-1/2 -translate-x-1/2 z-50",
          "flex items-center gap-3 px-4 py-3",
          "rounded-xl border border-border bg-card shadow-xl",
          "min-w-[280px] max-w-lg",
          @class
        ])
      }
      role="status"
      aria-live="polite"
      {@rest}
    >
      <%!-- Optional icon / avatar --%>
      <div :if={@icon != []} class="shrink-0">
        {render_slot(@icon)}
      </div>

      <%!-- Label --%>
      <div class="flex-1 text-sm font-medium text-foreground">
        {render_slot(@label)}
      </div>

      <%!-- Action buttons --%>
      <div :if={@actions != []} class="flex items-center gap-2 shrink-0">
        {render_slot(@actions)}
      </div>
    </div>
    """
  end
end
