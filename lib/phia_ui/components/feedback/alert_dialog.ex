defmodule PhiaUi.Components.AlertDialog do
  @moduledoc """
  Alert Dialog component for critical confirmations requiring explicit user action.

  An alert dialog is a modal dialog that interrupts the user's workflow to
  communicate an important message and require a response. Unlike a standard
  `Dialog`, it uses `role="alertdialog"` per the WAI-ARIA specification, which
  signals to assistive technology that this requires immediate attention and
  an explicit decision.

  Use an alert dialog for **irreversible or high-impact actions** such as:
  - Deleting a record permanently
  - Revoking access or permissions
  - Cancelling an in-progress operation with unsaved work
  - Confirming payment or subscription changes

  Do not use an alert dialog for informational messages that require no decision
  — use `Alert` or `Toast` for those.

  ## JavaScript Hook

  Reuses the `PhiaDialog` JavaScript hook (shared with the standard `Dialog`
  component). The hook provides:
  - Focus trap — Tab/Shift+Tab cycle within the dialog
  - Escape key closes the dialog
  - Scroll locking — prevents the page behind from scrolling while open
  - Focus return — restores focus to the previously focused element on close

  ## Hook Registration

  Copy the hook via `mix phia.add alert_dialog`, then register it:

      # assets/js/app.js
      import PhiaDialog from "./hooks/dialog"

      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaDialog }
      })

  ## Sub-components

  | Function                     | Purpose                                            |
  |------------------------------|----------------------------------------------------|
  | `alert_dialog/1`             | Root modal with `role="alertdialog"`               |
  | `alert_dialog_header/1`      | Title + description layout container               |
  | `alert_dialog_title/1`       | `<h2>` heading — set `:id` for ARIA linkage        |
  | `alert_dialog_description/1` | `<p>` supporting text — set `:id` for ARIA         |
  | `alert_dialog_footer/1`      | Action row (cancel + confirm buttons)              |
  | `alert_dialog_action/1`      | Confirm button (default or destructive style)      |
  | `alert_dialog_cancel/1`      | Cancel button with outline style                   |

  ## Example — Delete Confirmation

  The most common pattern: confirm before permanently deleting a record.

      <.alert_dialog
        id="delete-confirm"
        open={@show_delete_confirm}
        aria-labelledby="delete-confirm-title"
        aria-describedby="delete-confirm-desc">
        <.alert_dialog_header>
          <.alert_dialog_title id="delete-confirm-title">
            Delete Project?
          </.alert_dialog_title>
          <.alert_dialog_description id="delete-confirm-desc">
            This will permanently delete "{@project.name}" and all its data.
            This action cannot be undone.
          </.alert_dialog_description>
        </.alert_dialog_header>
        <.alert_dialog_footer>
          <.alert_dialog_cancel phx-click="cancel_delete">
            Cancel
          </.alert_dialog_cancel>
          <.alert_dialog_action variant="destructive" phx-click="confirm_delete" phx-value-id={@project.id}>
            Delete Project
          </.alert_dialog_action>
        </.alert_dialog_footer>
      </.alert_dialog>

      # In the LiveView
      def handle_event("confirm_delete", %{"id" => id}, socket) do
        Projects.delete!(id)
        {:noreply,
         socket
         |> assign(:show_delete_confirm, false)
         |> push_event("phia-toast", %{title: "Project deleted", variant: "success"})}
      end

      def handle_event("cancel_delete", _params, socket) do
        {:noreply, assign(socket, :show_delete_confirm, false)}
      end

  ## Example — Permission Revocation

  Destructive actions that affect another user:

      <.alert_dialog
        id="revoke-access"
        open={@show_revoke}
        aria-labelledby="revoke-title"
        aria-describedby="revoke-desc">
        <.alert_dialog_header>
          <.alert_dialog_title id="revoke-title">
            Revoke Admin Access?
          </.alert_dialog_title>
          <.alert_dialog_description id="revoke-desc">
            {@selected_user.name} will immediately lose admin privileges.
            They will need to be re-invited to regain access.
          </.alert_dialog_description>
        </.alert_dialog_header>
        <.alert_dialog_footer>
          <.alert_dialog_cancel phx-click="cancel_revoke">Keep Access</.alert_dialog_cancel>
          <.alert_dialog_action variant="destructive" phx-click="confirm_revoke">
            Revoke Access
          </.alert_dialog_action>
        </.alert_dialog_footer>
      </.alert_dialog>

  ## Example — Unsaved Changes Warning

  Warn before discarding work-in-progress:

      <.alert_dialog id="unsaved-changes" open={@navigating_away and @form_dirty}>
        <.alert_dialog_header>
          <.alert_dialog_title>Unsaved Changes</.alert_dialog_title>
          <.alert_dialog_description>
            You have unsaved changes. If you leave now, they will be lost.
          </.alert_dialog_description>
        </.alert_dialog_header>
        <.alert_dialog_footer>
          <.alert_dialog_cancel phx-click="stay_on_page">Stay</.alert_dialog_cancel>
          <.alert_dialog_action phx-click="discard_and_navigate">Leave anyway</.alert_dialog_action>
        </.alert_dialog_footer>
      </.alert_dialog>

  ## Opening and Closing

  Control visibility via the `:open` boolean assign. Toggle it from your
  LiveView event handlers:

      # Open the dialog
      {:noreply, assign(socket, :show_confirm, true)}

      # Close the dialog
      {:noreply, assign(socket, :show_confirm, false)}

  ## ARIA Linkage

  Always set `aria-labelledby` and `aria-describedby` on `alert_dialog/1`
  pointing at the `id` values of `alert_dialog_title/1` and
  `alert_dialog_description/1` respectively. This is required by the
  WAI-ARIA `alertdialog` specification and enables screen readers to correctly
  announce the dialog's purpose when it opens.

  ## Accessibility

  - `role="alertdialog"` signals to assistive technology that focus should
    immediately move to the dialog when it opens (stronger than `role="dialog"`)
  - `aria-modal="true"` tells screen readers to restrict virtual cursor
    navigation to the dialog content
  - Cancel is visually first (on mobile, stacked below action) but users should
    be able to press `Escape` to cancel without moving the mouse
  - On desktop the action buttons render horizontally; on mobile they stack
    vertically (action on top, cancel below) for thumb accessibility
  - The default focus lands on the first focusable element — by convention,
    the Cancel button — so the safe action is immediately accessible
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # alert_dialog/1
  # ---------------------------------------------------------------------------

  @doc """
  Root container for the Alert Dialog modal.

  Renders a full-screen fixed overlay with `role="alertdialog"` and
  `aria-modal="true"`. Focus trap, Escape key handling, and scroll locking are
  provided by the `PhiaDialog` JavaScript hook.

  Set `aria-labelledby` to the `:id` of `alert_dialog_title/1` and
  `aria-describedby` to the `:id` of `alert_dialog_description/1` for
  correct ARIA linkage — screen readers announce the title when the dialog
  opens and the description when the user explores its contents.

  The dialog is shown when `open={true}` and hidden when `open={false}`.
  Toggle via a LiveView assign — the hook does not manage visibility state.
  """
  attr(:id, :string,
    required: true,
    doc: "Unique dialog ID — the `PhiaDialog` hook mount point"
  )

  attr(:open, :boolean,
    default: false,
    doc: """
    Whether the alert dialog is currently visible. When `false`, the outer
    container gets the `hidden` class. Toggle from your LiveView event handlers.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the dialog panel")

  attr(:rest, :global,
    doc: """
    Extra HTML attributes forwarded to the root element. Use this for required
    ARIA attributes: `aria-labelledby="{title-id}"` and
    `aria-describedby="{description-id}"`.
    """
  )

  slot(:inner_block, required: true, doc: "Alert dialog content: header, footer sub-components")

  def alert_dialog(assigns) do
    ~H"""
    <div
      id={@id}
      role="alertdialog"
      aria-modal="true"
      phx-hook="PhiaDialog"
      class={cn([
        "fixed inset-0 z-50",
        !@open && "hidden"
      ])}
      {@rest}
    >
      <%!-- Backdrop: semi-transparent blur overlay; aria-hidden because the dialog panel carries the content --%>
      <div
        class="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm"
        data-dialog-overlay
        aria-hidden="true"
      ></div>
      <%!-- Dialog panel: centered via translate-[-50%,-50%] from its own center --%>
      <div
        class={cn([
          "fixed left-[50%] top-[50%] z-50 grid w-full max-w-lg translate-x-[-50%] translate-y-[-50%]",
          "gap-4 border bg-background p-6 shadow-lg sm:rounded-lg",
          @class
        ])}
        data-dialog-panel
      >
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # alert_dialog_header/1
  # ---------------------------------------------------------------------------

  @doc """
  Layout container for the alert dialog title and description.

  Stacks title and description vertically with `space-y-2`. Text alignment is
  centered on mobile (`text-center`) and left-aligned on desktop (`sm:text-left`)
  for optimal readability across screen sizes.
  """
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the header `<div>`")

  slot(:inner_block,
    required: true,
    doc: "`alert_dialog_title/1` and `alert_dialog_description/1`"
  )

  def alert_dialog_header(assigns) do
    ~H"""
    <div class={cn(["flex flex-col space-y-2 text-center sm:text-left", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # alert_dialog_title/1
  # ---------------------------------------------------------------------------

  @doc """
  Alert dialog heading rendered as `<h2>`.

  Set `:id` and reference it via `aria-labelledby` on the parent
  `alert_dialog/1`. This is how screen readers know the dialog's name — they
  announce it when the dialog opens and whenever the user queries the current
  dialog context.

      <.alert_dialog aria-labelledby="delete-title" ...>
        <.alert_dialog_title id="delete-title">
          Permanently delete?
        </.alert_dialog_title>
      </.alert_dialog>

  Keep the title short and specific — it should clearly state what the dialog
  is about: "Delete Project?", "Revoke Access?", "Unsaved Changes".
  """
  attr(:id, :string,
    default: nil,
    doc: "Element ID referenced by `aria-labelledby` on the parent `alert_dialog/1`"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the `<h2>`")
  slot(:inner_block, required: true, doc: "Title text")

  def alert_dialog_title(assigns) do
    ~H"""
    <h2 id={@id} class={cn(["text-lg font-semibold", @class])} {@rest}>
      {render_slot(@inner_block)}
    </h2>
    """
  end

  # ---------------------------------------------------------------------------
  # alert_dialog_description/1
  # ---------------------------------------------------------------------------

  @doc """
  Supporting text below the alert dialog title.

  Set `:id` and reference it via `aria-describedby` on the parent
  `alert_dialog/1`. Screen readers announce this when the user explores the
  dialog, providing context about the consequences of the action.

      <.alert_dialog aria-describedby="delete-desc" ...>
        <.alert_dialog_description id="delete-desc">
          This action cannot be undone. The record will be permanently removed.
        </.alert_dialog_description>
      </.alert_dialog>

  Write descriptions that help users make an informed decision: explain
  consequences, mention what will be lost, and avoid technical jargon.
  """
  attr(:id, :string,
    default: nil,
    doc: "Element ID referenced by `aria-describedby` on the parent `alert_dialog/1`"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the `<p>`")

  slot(:inner_block,
    required: true,
    doc: "Description text — 1–3 sentences explaining consequences"
  )

  def alert_dialog_description(assigns) do
    ~H"""
    <p id={@id} class={cn(["text-sm text-muted-foreground", @class])} {@rest}>
      {render_slot(@inner_block)}
    </p>
    """
  end

  # ---------------------------------------------------------------------------
  # alert_dialog_footer/1
  # ---------------------------------------------------------------------------

  @doc """
  Action row at the bottom of the alert dialog.

  On mobile: buttons stack vertically (action on top, cancel below) for thumb
  reachability. On desktop: buttons render horizontally, right-aligned
  (`sm:flex-row sm:justify-end sm:space-x-2`).

  By convention, place `alert_dialog_cancel/1` before `alert_dialog_action/1`
  in the template — the flexbox reverse order handles the mobile layout.
  """
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the footer `<div>`")
  slot(:inner_block, required: true, doc: "`alert_dialog_cancel/1` and `alert_dialog_action/1`")

  def alert_dialog_footer(assigns) do
    ~H"""
    <div
      class={cn(["flex flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # alert_dialog_action/1
  # ---------------------------------------------------------------------------

  @doc """
  Confirm / action button for the alert dialog.

  This is the button that executes the critical action. Wire it with `phx-click`
  to handle the confirmed action in your LiveView. Pass any data via `phx-value-*`.

  Use `variant="destructive"` for irreversible actions (deletes, revocations):

      <.alert_dialog_action variant="destructive" phx-click="confirm_delete" phx-value-id={@id}>
        Delete permanently
      </.alert_dialog_action>

  Use `variant="default"` for confirmations without a destructive consequence:

      <.alert_dialog_action phx-click="confirm_publish">
        Publish now
      </.alert_dialog_action>
  """
  attr(:variant, :string,
    default: "default",
    values: ~w(default destructive),
    doc: """
    Visual style for the action button:
    - `"default"` — primary colour (blue/brand); use for confirmations with no data loss
    - `"destructive"` — danger red; use for deletes, revocations, irreversible changes
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the `<button>`")
  slot(:inner_block, required: true, doc: "Button label text")

  def alert_dialog_action(assigns) do
    ~H"""
    <button class={cn([action_classes(@variant), @class])} {@rest}>
      {render_slot(@inner_block)}
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # alert_dialog_cancel/1
  # ---------------------------------------------------------------------------

  @doc """
  Cancel button for the alert dialog.

  This button should close the dialog without performing any destructive action.
  Wire with `phx-click` to set your visibility assign to `false`:

      <.alert_dialog_cancel phx-click="cancel_delete">
        Cancel
      </.alert_dialog_cancel>

      # In the LiveView
      def handle_event("cancel_delete", _params, socket) do
        {:noreply, assign(socket, :show_confirm, false)}
      end

  The cancel button uses a neutral outline style so it reads as the "safe"
  option — users can always press `Escape` to cancel as well.
  """
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the `<button>`")
  slot(:inner_block, required: true, doc: "Button label text — typically 'Cancel' or 'Keep'")

  def alert_dialog_cancel(assigns) do
    ~H"""
    <button
      class={cn([
        "inline-flex items-center justify-center rounded-md border border-input bg-background",
        "px-4 py-2 text-sm font-medium shadow-sm transition-colors",
        "hover:bg-accent hover:text-accent-foreground",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
        "disabled:pointer-events-none disabled:opacity-50",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Returns button classes for the action button variant.
  # Kept as a private function (not a defp component) so `cn/1` in the caller
  # can merge the `:class` override on top of the base styles.
  defp action_classes("default") do
    "inline-flex items-center justify-center rounded-md bg-primary px-4 py-2 " <>
      "text-sm font-medium text-primary-foreground shadow transition-colors " <>
      "hover:bg-primary/90 focus-visible:outline-none focus-visible:ring-2 " <>
      "focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50"
  end

  defp action_classes("destructive") do
    "inline-flex items-center justify-center rounded-md bg-destructive px-4 py-2 " <>
      "text-sm font-medium text-destructive-foreground shadow transition-colors " <>
      "hover:bg-destructive/90 focus-visible:outline-none focus-visible:ring-2 " <>
      "focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50"
  end
end
