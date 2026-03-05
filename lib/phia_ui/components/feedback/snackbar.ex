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

  def snackbar(assigns) do
    ~H"""
    <div
      :if={@visible}
      class={
        cn([
          "fixed bottom-6 left-1/2 -translate-x-1/2 z-50",
          "flex items-center gap-3 px-4 py-3",
          "rounded-xl border border-border bg-card shadow-lg",
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
