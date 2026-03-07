defmodule PhiaUi.Components.GlobalMessage do
  @moduledoc """
  Global message component for top-center auto-dismissing feedback messages.

  Inspired by Ant Design `message`, Mantine notifications, and the global
  feedback pattern used in major SaaS products (Linear, Vercel, Notion).

  Unlike `Toast` (which stacks in the corner), global messages appear at the
  **top center** of the viewport and are used for brief, non-intrusive feedback
  about the result of a user action. They auto-dismiss after a configurable
  duration.

  ## Architecture

  The component has a single part:

  - **`global_message/1`** — the fixed viewport container rendered once in your
    root layout. The `PhiaGlobalMessage` JS hook listens for `push_event/3`
    from any LiveView and renders message nodes dynamically.

  ## Setup

  ### 1. Add the viewport once in your root layout

      <%!-- lib/my_app_web/components/layouts/root.html.heex --%>
      <body>
        <.global_message id="phia-global-message" />
        <%= @inner_content %>
      </body>

  ### 2. Register the hook in app.js

      import PhiaGlobalMessage from "./hooks/global_message"

      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaGlobalMessage }
      })

  ### 3. Push messages from any LiveView

      push_event(socket, "phia-message", %{
        content: "Settings saved.",
        type: "success",
        duration_ms: 3000
      })

      push_event(socket, "phia-message", %{
        content: "Failed to save. Please try again.",
        type: "error"
      })

  ## push_event Payload

  | Key           | Type    | Required | Default | Description                              |
  |---------------|---------|----------|---------|------------------------------------------|
  | `content`     | string  | yes      | —       | Message text shown to the user           |
  | `type`        | string  | no       | `"info"`| One of `"info"`, `"success"`, `"error"`, `"warning"`, `"loading"` |
  | `duration_ms` | integer | no       | `3000`  | Auto-dismiss delay in ms (0 = no dismiss)|

  ## Message Types

  | Type        | Icon     | Color  | Use case                                    |
  |-------------|----------|--------|---------------------------------------------|
  | `"info"`    | ℹ        | Blue   | Neutral info, page transitions              |
  | `"success"` | ✓        | Green  | Saved, created, published, completed        |
  | `"error"`   | ✗        | Red    | Failed, invalid, permission denied          |
  | `"warning"` | ⚠        | Amber  | Caution, rate limit approaching             |
  | `"loading"` | spinner  | Muted  | Long-running background operation started   |

  ## Accessibility

  - Container has `role="status"` and `aria-live="polite"` so screen readers
    announce messages as they appear.
  - `aria-atomic="false"` allows individual messages to be announced as added.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # global_message/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    required: true,
    doc: "Unique ID — hook mount point and push_event target."
  )

  attr(:max_messages, :integer,
    default: 5,
    doc: "Maximum number of messages visible at once."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the container.")
  attr(:rest, :global, doc: "HTML attrs forwarded to the container `<div>`.")

  @doc """
  Renders the global message viewport container.

  Place **once** in your root layout. Messages appear centered at the top of
  the viewport and auto-dismiss after their configured duration.

  ## Example

      <.global_message id="phia-global-message" />
  """
  def global_message(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaGlobalMessage"
      role="status"
      aria-live="polite"
      aria-atomic="false"
      data-max-messages={@max_messages}
      class={cn([
        "fixed top-4 left-1/2 -translate-x-1/2 z-[200]",
        "flex flex-col items-center gap-2 pointer-events-none",
        @class
      ])}
      {@rest}
    >
    </div>
    """
  end
end
