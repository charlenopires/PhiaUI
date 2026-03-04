defmodule PhiaUi.Components.Toast do
  @moduledoc """
  Toast notification component powered by the `PhiaToast` vanilla JavaScript hook.

  Toasts are brief, non-blocking notifications that appear at the corner of the
  viewport to inform users about the result of an action — a file saved, an
  error encountered, a background task completed. They auto-dismiss after a
  configurable duration and stack when multiple arrive in quick succession.

  ## Architecture

  The component has two distinct parts:

  1. **The viewport container** (`toast/1`) — rendered once in your root layout,
     fixed to the viewport corner. The `PhiaToast` hook mounts here and listens
     for `push_event/3` calls from the server.

  2. **The item sub-components** (`toast_title/1`, `toast_description/1`,
     `toast_action/1`, `toast_close/1`) — used when composing static toast
     markup in the template, or as building blocks for the hook's template
     generation.

  ## Setup

  ### 1. Add the viewport to your root layout

  Place `<.toast>` once inside `<body>` in `root.html.heex`. All toasts from any
  LiveView on the page will appear here:

      <%# lib/my_app_web/components/layouts/root.html.heex %>
      <!DOCTYPE html>
      <html>
        <body>
          <%= @inner_content %>
          <.toast id="phia-toast-viewport" />
        </body>
      </html>

  ### 2. Register the hook in app.js

      # assets/js/app.js
      import PhiaToast from "./hooks/toast"

      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaToast }
      })

  ### 3. Push toast events from your LiveView

      # Simple success toast
      def handle_event("save", params, socket) do
        case save_record(params) do
          {:ok, _record} ->
            socket =
              push_event(socket, "phia-toast", %{
                title: "Saved",
                description: "Your changes have been saved.",
                variant: "success",
                duration_ms: 4000
              })
            {:noreply, socket}

          {:error, changeset} ->
            socket =
              push_event(socket, "phia-toast", %{
                title: "Error",
                description: "Could not save. Please check the form.",
                variant: "destructive",
                duration_ms: 6000
              })
            {:noreply, assign(socket, :changeset, changeset)}
        end
      end

  ## push_event Payload

  | Key            | Type    | Required | Description                                       |
  |----------------|---------|----------|---------------------------------------------------|
  | `title`        | string  | yes      | Short heading displayed prominently               |
  | `description`  | string  | no       | Supporting detail text                            |
  | `variant`      | string  | no       | `"default"`, `"success"`, `"destructive"`, `"warning"` |
  | `duration_ms`  | integer | no       | Auto-dismiss delay in ms (default 4000)           |
  | `action_label` | string  | no       | Label for an optional action button               |
  | `action_event` | string  | no       | `phx-click` event name for the action button      |

  ## Sub-components

  | Function              | Purpose                                                 |
  |-----------------------|---------------------------------------------------------|
  | `toast/1`             | Fixed viewport container and hook mount point           |
  | `toast_title/1`       | Toast heading (`text-sm font-semibold`)                 |
  | `toast_description/1` | Body text (`text-sm opacity-90`)                        |
  | `toast_action/1`      | Optional action button (e.g. "Undo", "View")            |
  | `toast_close/1`       | Dismiss (×) button                                      |

  ## Variants

  | Variant        | Use Case                                             |
  |----------------|------------------------------------------------------|
  | `"default"`    | Neutral information (page loaded, preference saved)  |
  | `"success"`    | Operation succeeded (file uploaded, record created)  |
  | `"destructive"`| Error or failure (network error, validation failed)  |
  | `"warning"`    | Non-blocking warning (session expiring soon)         |

  ## Stacking Behaviour

  When multiple toasts arrive before the first auto-dismisses, they stack.
  `max_toasts` controls the maximum visible at once — older toasts are
  removed when the limit is reached. Toasts stack from the bottom up on
  desktop (newest at top) and from the top down on mobile.

  ## Accessibility

  - The viewport container has `role="status"` and `aria-live="polite"` so
    screen readers announce new toasts without interrupting the current task
  - `aria-atomic="false"` allows screen readers to announce individual toasts
    as they arrive rather than reading the entire container each time
  - The close button has `aria-label="Close"` for screen reader users
  - Toasts should not be the sole means of conveying critical information —
    errors that require user action should also be shown inline in the form
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # toast/1 — viewport container
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    required: true,
    doc: """
    Unique ID for the toast viewport. Use a consistent ID like
    `"phia-toast-viewport"` — the hook uses this as its mount point and
    LiveView push events target this specific element.
    """
  )

  attr(:max_toasts, :integer,
    default: 5,
    doc: """
    Maximum number of toasts visible simultaneously. When a new toast arrives
    and the limit is reached, the oldest toast is removed to make room.
    Recommended: 3–5 for most applications.
    """
  )

  attr(:variant, :atom,
    default: :default,
    values: [:default, :success, :destructive, :warning],
    doc: """
    Default variant applied to toasts that do not specify their own variant
    in the `push_event` payload. Individual toasts can override this.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the viewport container")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the container `<div>`")

  @doc """
  Renders the fixed toast viewport container.

  Place this **once** in your root layout (`root.html.heex`) inside `<body>`.
  The `PhiaToast` hook mounts here and dynamically inserts toast DOM nodes
  when `push_event(socket, "phia-toast", payload)` is called from any LiveView.

  The viewport is positioned `fixed bottom-0 right-0` on desktop, stacking
  toasts upward. On small screens, `flex-col` reverses to stack downward from
  the top.

  The `aria-live="polite"` attribute ensures screen readers announce new toasts
  without interrupting whatever they are currently reading. `aria-atomic="false"`
  means individual toast nodes are announced as they are added — not the entire
  container.
  """
  def toast(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaToast"
      role="status"
      aria-live="polite"
      aria-atomic="false"
      data-max-toasts={@max_toasts}
      data-variant={@variant}
      class={cn([
        "fixed bottom-0 right-0 z-[100] flex max-h-screen flex-col-reverse gap-2 p-4",
        "sm:flex-col md:max-w-[420px]",
        @class
      ])}
      {@rest}
    >
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # toast_title/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the title `<div>`")

  slot(:inner_block, required: true, doc: "Toast heading — keep it short (2–5 words)")

  @doc """
  Renders the toast heading.

  The title is the most prominent text in a toast. Keep it short and specific:
  prefer "File saved" over "Success" and "Payment failed" over "Error".

      <.toast_title>Changes saved</.toast_title>
      <.toast_title>Upload failed</.toast_title>
  """
  def toast_title(assigns) do
    ~H"""
    <div class={cn(["text-sm font-semibold", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # toast_description/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the description `<div>`")

  slot(:inner_block, required: true, doc: "Supporting detail text")

  @doc """
  Renders the toast body text.

  Use descriptions for additional context that helps users understand what
  happened and what (if anything) they should do next. Keep descriptions to
  one or two sentences.

      <.toast_description>
        Your profile photo has been updated across all devices.
      </.toast_description>

      <.toast_description>
        The payment processor returned error code 4012. Please check your card details.
      </.toast_description>
  """
  def toast_description(assigns) do
    ~H"""
    <div class={cn(["text-sm opacity-90", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # toast_action/1
  # ---------------------------------------------------------------------------

  attr(:on_click, :string,
    required: true,
    doc: "LiveView event name sent via `phx-click` when the action button is clicked"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the `<button>`")

  slot(:inner_block, required: true, doc: "Action button label — e.g. \"Undo\", \"View\", \"Retry\"")

  @doc """
  Renders an action button inside a toast notification.

  Use action buttons for quick, reversible operations directly from the toast —
  the classic example is "Undo" after a delete. Keep the label short (one word
  or two at most).

      <.toast_title>Item deleted</.toast_title>
      <.toast_action on_click="undo_delete">Undo</.toast_action>

  Wire the event in your LiveView:

      def handle_event("undo_delete", _params, socket) do
        # restore the deleted record
        {:noreply, socket}
      end

  For complex workflows triggered from a toast (e.g. "View order"), prefer
  navigating to a full page rather than doing the work in the event handler.
  """
  def toast_action(assigns) do
    ~H"""
    <button
      type="button"
      phx-click={@on_click}
      class={cn([
        "inline-flex h-8 shrink-0 items-center justify-center rounded-md border",
        "bg-transparent px-3 text-sm font-medium transition-colors",
        "hover:bg-secondary focus:outline-none focus:ring-1",
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # toast_close/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the close `<button>`")

  @doc """
  Renders the dismiss (×) close button for a toast notification.

  The `PhiaToast` hook listens for clicks on `data-toast-close` and removes
  the toast immediately, bypassing the auto-dismiss timer. This gives users
  explicit control to clear notifications before they auto-dismiss.

  The button starts `opacity-0` and transitions to full opacity on hover or
  focus, keeping the UI clean while still discoverable.
  """
  def toast_close(assigns) do
    ~H"""
    <button
      type="button"
      aria-label="Close"
      data-toast-close
      class={cn([
        "absolute right-1 top-1 rounded-md p-1 opacity-0 transition-opacity",
        "hover:opacity-100 focus:opacity-100 focus:outline-none",
        @class
      ])}
      {@rest}
    >
      <.icon name="x" size={:sm} />
    </button>
    """
  end
end
