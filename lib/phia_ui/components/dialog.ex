defmodule PhiaUi.Components.Dialog do
  @moduledoc """
  Accessible Dialog (Modal) component following the WAI-ARIA Dialog pattern.

  Uses `Phoenix.LiveView.JS` for open/close transitions and the `PhiaDialog`
  JavaScript Hook for focus trap, keyboard navigation, and scroll locking.

  ## Registration in app.js

  After running `mix phia.add dialog`, register the hook in your LiveSocket:

      import PhiaDialog from "./phia_hooks/dialog.js"

      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaDialog, ...yourOtherHooks }
      })

  ## Example

      <.dialog id="confirm-delete">
        <.dialog_trigger for="confirm-delete">
          <.button variant={:destructive}>Delete</.button>
        </.dialog_trigger>

        <.dialog_content id="confirm-delete">
          <.dialog_header>
            <.dialog_title id="confirm-delete-title">Delete Item</.dialog_title>
            <.dialog_description id="confirm-delete-description">
              This action cannot be undone.
            </.dialog_description>
          </.dialog_header>
          <.dialog_footer>
            <.dialog_close for="confirm-delete">Cancel</.dialog_close>
            <.button variant={:destructive} phx-click="delete">Delete</.button>
          </.dialog_footer>
        </.dialog_content>
      </.dialog>

  ## Sub-components

  | Function              | Purpose                                      |
  |-----------------------|----------------------------------------------|
  | `dialog/1`            | Hook anchor, outer container                 |
  | `dialog_trigger/1`    | Opens the dialog via JS.show                 |
  | `dialog_content/1`    | Overlay + panel (hidden by default)          |
  | `dialog_header/1`     | Title + description layout container         |
  | `dialog_title/1`      | `<h2>` heading (set id for ARIA linkage)     |
  | `dialog_description/1`| `<p>` supporting text (set id for ARIA)      |
  | `dialog_footer/1`     | Action row (close button, confirmations)     |
  | `dialog_close/1`      | Closes the dialog via JS.hide                |
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias Phoenix.LiveView.JS

  # ---------------------------------------------------------------------------
  # dialog/1
  # ---------------------------------------------------------------------------

  @doc """
  Outer container for the Dialog. Binds the `PhiaDialog` JavaScript Hook.

  Must wrap both `dialog_trigger/1` and `dialog_content/1`.
  """
  attr :id, :string, required: true, doc: "Unique ID used as the hook anchor"
  attr :class, :string, default: nil, doc: "Additional CSS classes"
  slot :inner_block, required: true

  def dialog(assigns) do
    ~H"""
    <div id={@id} phx-hook="PhiaDialog" class={cn(["relative", @class])}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # dialog_trigger/1
  # ---------------------------------------------------------------------------

  @doc """
  Opens the dialog by calling `JS.show/1` on `#dialog-{for}`.
  """
  attr :for, :string, required: true, doc: "ID of the dialog to open (matches dialog/1's :id)"
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def dialog_trigger(assigns) do
    ~H"""
    <div
      phx-click={JS.show(to: "#dialog-#{@for}")}
      class={cn(["cursor-pointer inline-block", @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # dialog_content/1
  # ---------------------------------------------------------------------------

  @doc """
  The dialog surface: renders the overlay backdrop and the modal panel.

  Hidden by default. Shown by `dialog_trigger/1` via `JS.show/1`.

  The outer container id is `"dialog-{id}"` (prefixed) so that
  `dialog_trigger/1` and `dialog_close/1` can target it.
  """
  attr :id, :string, required: true, doc: "ID matching the parent dialog/1's :id"
  attr :class, :string, default: nil, doc: "Additional classes for the panel"
  slot :inner_block, required: true

  def dialog_content(assigns) do
    ~H"""
    <div id={"dialog-#{@id}"} class="fixed inset-0 z-50 hidden" data-dialog-content>
      <%!-- Overlay — fade-in via backdrop-blur and bg --%>
      <div
        class="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm"
        data-dialog-overlay
        aria-hidden="true"
      ></div>
      <%!-- Panel — scale-in transition from opacity-0 scale-95 to opacity-100 scale-100 --%>
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        class={cn([
          "fixed left-[50%] top-[50%] z-50 grid w-full max-w-lg translate-x-[-50%] translate-y-[-50%]",
          "gap-4 border bg-background p-6 shadow-lg sm:rounded-lg",
          "transition-all ease-out duration-300 opacity-0 scale-95",
          @class
        ])}
        data-dialog-panel
      >
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # dialog_header/1
  # ---------------------------------------------------------------------------

  @doc "Layout container for dialog title and description."
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def dialog_header(assigns) do
    ~H"""
    <div class={cn(["flex flex-col space-y-1.5 text-center sm:text-left", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # dialog_title/1
  # ---------------------------------------------------------------------------

  @doc """
  Dialog heading (`<h2>`). Set `:id` to `"{dialog-id}-title"` for ARIA linkage.
  """
  attr :id, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def dialog_title(assigns) do
    ~H"""
    <h2
      id={@id}
      class={cn(["text-lg font-semibold leading-none tracking-tight", @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </h2>
    """
  end

  # ---------------------------------------------------------------------------
  # dialog_description/1
  # ---------------------------------------------------------------------------

  @doc """
  Supporting text below the title. Set `:id` to `"{dialog-id}-description"` for ARIA linkage.
  """
  attr :id, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def dialog_description(assigns) do
    ~H"""
    <p id={@id} class={cn(["text-sm text-muted-foreground", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  # ---------------------------------------------------------------------------
  # dialog_footer/1
  # ---------------------------------------------------------------------------

  @doc "Action row at the bottom of the dialog (close button, confirmations)."
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def dialog_footer(assigns) do
    ~H"""
    <div
      class={cn(["flex flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2", @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # dialog_close/1
  # ---------------------------------------------------------------------------

  @doc """
  Closes the dialog via `JS.hide/1` on `#dialog-{for}`.
  The Escape key is also handled by the `PhiaDialog` JS Hook.
  """
  attr :for, :string, required: true, doc: "ID of the dialog to close (matches dialog/1's :id)"
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def dialog_close(assigns) do
    ~H"""
    <button
      type="button"
      phx-click={JS.hide(to: "#dialog-#{@for}")}
      class={cn([
        "inline-flex items-center justify-center rounded-md text-sm font-medium",
        "ring-offset-background transition-colors focus-visible:outline-none",
        "focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end
end
