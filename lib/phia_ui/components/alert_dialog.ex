defmodule PhiaUi.Components.AlertDialog do
  @moduledoc """
  Alert Dialog component for critical action confirmations.

  Derived from the Dialog component but uses `role="alertdialog"` per the
  WAI-ARIA Alert and Message Dialogs pattern. Reuses the `PhiaDialog`
  JavaScript hook for focus trap, Escape key handling, and scroll locking.

  ## Registration in app.js

  After running `mix phia.add alert_dialog`, register the hook in your LiveSocket.
  The `PhiaDialog` hook is shared with the Dialog component:

      import PhiaDialog from "./phia_hooks/dialog.js"

      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaDialog, ...yourOtherHooks }
      })

  ## Example

      <.alert_dialog
        id="confirm-delete"
        open={@show_confirm}
        aria-labelledby="confirm-delete-title"
        aria-describedby="confirm-delete-desc"
      >
        <.alert_dialog_header>
          <.alert_dialog_title id="confirm-delete-title">
            Delete Item
          </.alert_dialog_title>
          <.alert_dialog_description id="confirm-delete-desc">
            This action cannot be undone. The item will be permanently removed.
          </.alert_dialog_description>
        </.alert_dialog_header>
        <.alert_dialog_footer>
          <.alert_dialog_cancel phx-click="cancel_delete">Cancel</.alert_dialog_cancel>
          <.alert_dialog_action variant="destructive" phx-click="confirm_delete">
            Delete
          </.alert_dialog_action>
        </.alert_dialog_footer>
      </.alert_dialog>

  ## Sub-components

  | Function                    | Purpose                                        |
  |-----------------------------|------------------------------------------------|
  | `alert_dialog/1`            | Root modal with `role="alertdialog"`           |
  | `alert_dialog_header/1`     | Title + description layout container           |
  | `alert_dialog_title/1`      | `<h2>` heading (set id for ARIA linkage)       |
  | `alert_dialog_description/1`| `<p>` supporting text (set id for ARIA)        |
  | `alert_dialog_footer/1`     | Action row (cancel + confirm buttons)          |
  | `alert_dialog_action/1`     | Confirm button (default or destructive)        |
  | `alert_dialog_cancel/1`     | Cancel button with outline styling             |
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # alert_dialog/1
  # ---------------------------------------------------------------------------

  @doc """
  Root container for the Alert Dialog modal.

  Renders a modal overlay with `role="alertdialog"` and `aria-modal="true"`,
  following the WAI-ARIA Alert Dialog pattern. Focus trap, Escape key handling,
  and scroll locking are provided by the `PhiaDialog` JavaScript hook.

  Set `aria-labelledby` to the `:id` of the `alert_dialog_title/1` and
  `aria-describedby` to the `:id` of the `alert_dialog_description/1`.
  """
  attr(:id, :string, required: true, doc: "Unique dialog ID, used as the hook anchor")
  attr(:open, :boolean, default: false, doc: "Whether the alert dialog is visible")
  attr(:class, :string, default: nil, doc: "Additional CSS classes for the panel")

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the root element (e.g. aria-labelledby)"
  )

  slot(:inner_block, required: true, doc: "Alert dialog content")

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
      <%!-- Backdrop overlay --%>
      <div
        class="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm"
        data-dialog-overlay
        aria-hidden="true"
      ></div>
      <%!-- Dialog panel --%>
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

  @doc "Layout container for the alert dialog title and description."
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes")
  slot(:inner_block, required: true, doc: "Header content")

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
  Alert dialog heading (`<h2>`).

  Set `:id` to reference in the parent `alert_dialog/1`'s `aria-labelledby`
  attribute for correct ARIA linkage.
  """
  attr(:id, :string, default: nil, doc: "ID for aria-labelledby linkage")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes")
  slot(:inner_block, required: true, doc: "Title content")

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

  Set `:id` to reference in the parent `alert_dialog/1`'s `aria-describedby`
  attribute for correct ARIA linkage.
  """
  attr(:id, :string, default: nil, doc: "ID for aria-describedby linkage")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes")
  slot(:inner_block, required: true, doc: "Description content")

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

  @doc "Action row at the bottom of the alert dialog (cancel + confirm buttons)."
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes")
  slot(:inner_block, required: true, doc: "Footer content")

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
  Confirm/action button for the alert dialog.

  Use `:variant="destructive"` for irreversible actions such as deletes.
  Wire up with `phx-click` to handle the confirmed action in your LiveView.
  """
  attr(:variant, :string,
    default: "default",
    values: ~w(default destructive),
    doc: "Visual style — \"default\" (primary) or \"destructive\" (danger)"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes")
  slot(:inner_block, required: true, doc: "Button label content")

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

  Styled as an outlined button. Wire up with `phx-click` to dismiss the dialog
  in your LiveView event handler.
  """
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes")
  slot(:inner_block, required: true, doc: "Button label content")

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
