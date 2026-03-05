defmodule PhiaUi.Components.Sonner do
  @moduledoc """
  Sonner-style toast notification component powered by the `PhiaSonner` vanilla
  JavaScript hook.

  Sonner is an opinionated, beautifully designed toast component that stacks
  notifications in a compact list — expanding them on hover. Unlike the basic
  `Toast` component which is positioned with a static layout, `Sonner` supports
  six viewport positions and offers richer visual feedback through optional
  `rich_colors` mode.

  ## Architecture

  The component renders a single fixed container div. The `PhiaSonner` hook
  mounts here and listens for `push_event/3` calls from the server under the
  event name `"phia-sonner"`.

  ## Setup

  ### 1. Add the viewport to your root layout

      <%# lib/my_app_web/components/layouts/root.html.heex %>
      <!DOCTYPE html>
      <html>
        <body>
          <%= @inner_content %>
          <.sonner id="phia-sonner-viewport" />
        </body>
      </html>

  ### 2. Register the hook in app.js

      import PhiaSonner from "./hooks/sonner"

      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaSonner }
      })

  ### 3. Push sonner events from your LiveView

      push_event(socket, "phia-sonner", %{
        title: "File saved",
        description: "All changes have been persisted.",
        variant: "success",
        duration_ms: 4000
      })

  ## push_event Payload

  | Key            | Type    | Required | Description                                              |
  |----------------|---------|----------|----------------------------------------------------------|
  | `title`        | string  | yes      | Short heading displayed prominently                      |
  | `description`  | string  | no       | Supporting detail text                                   |
  | `variant`      | string  | no       | `"default"`, `"success"`, `"error"`, `"warning"`, `"info"` |
  | `duration_ms`  | integer | no       | Auto-dismiss delay in ms (default 4000, 0 = persistent) |

  ## Positions

  | Value             | Placement                               |
  |-------------------|-----------------------------------------|
  | `"top-left"`      | Top-left corner of the viewport         |
  | `"top-center"`    | Top edge, horizontally centred          |
  | `"top-right"`     | Top-right corner of the viewport        |
  | `"bottom-left"`   | Bottom-left corner of the viewport      |
  | `"bottom-center"` | Bottom edge, horizontally centred       |
  | `"bottom-right"`  | Bottom-right corner (default)           |

  ## Options

  | Attr          | Default        | Description                                             |
  |---------------|----------------|---------------------------------------------------------|
  | `position`    | `"bottom-right"` | Where the stack is anchored on the viewport           |
  | `expand`      | `false`        | Always show toasts expanded (skip the collapsed stack) |
  | `rich_colors` | `false`        | Apply vivid background colours per variant             |
  | `max_visible` | `3`            | Maximum toasts visible simultaneously                  |

  ## Accessibility

  The container has `role="status"` and `aria-live="polite"` so screen readers
  announce new toasts without interrupting what they are currently reading.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:id, :string,
    required: true,
    doc: "Unique ID for the sonner viewport — use a stable value like \"phia-sonner-viewport\""
  )

  attr(:position, :string,
    default: "bottom-right",
    values: [
      "top-left",
      "top-center",
      "top-right",
      "bottom-left",
      "bottom-center",
      "bottom-right"
    ],
    doc: "Viewport anchor position for the toast stack"
  )

  attr(:expand, :boolean,
    default: false,
    doc: "When true the stack is always fully expanded; hover-to-expand is disabled"
  )

  attr(:rich_colors, :boolean,
    default: false,
    doc: "When true each variant (success, error, warning, info) uses a vivid background colour"
  )

  attr(:max_visible, :integer,
    default: 3,
    doc:
      "Maximum number of toasts visible at once; older ones are removed when the limit is reached"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged onto the container div")

  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the container `<div>`")

  @doc """
  Renders the fixed Sonner toast viewport container.

  Place this **once** in your root layout inside `<body>`. The `PhiaSonner` hook
  mounts here and inserts toast nodes whenever `push_event(socket, "phia-sonner",
  payload)` is called from any LiveView.

  ## Examples

      <.sonner id="phia-sonner-viewport" />

      <.sonner id="phia-sonner-viewport" position="top-center" rich_colors={true} />

      <.sonner id="phia-sonner-viewport" position="top-right" expand={true} max_visible={5} />
  """
  def sonner(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaSonner"
      role="status"
      aria-live="polite"
      data-position={@position}
      data-expand={@expand}
      data-rich-colors={@rich_colors}
      data-max-visible={@max_visible}
      class={cn([
        position_class(@position),
        "fixed z-50 flex flex-col gap-2 w-[380px] max-w-[calc(100vw-2rem)]",
        @class
      ])}
      {@rest}
    >
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private class helpers — pattern matching, no case/cond
  # ---------------------------------------------------------------------------

  defp position_class("top-left"), do: "top-4 left-4"
  defp position_class("top-center"), do: "top-4 left-1/2 -translate-x-1/2"
  defp position_class("top-right"), do: "top-4 right-4"
  defp position_class("bottom-left"), do: "bottom-4 left-4"
  defp position_class("bottom-center"), do: "bottom-4 left-1/2 -translate-x-1/2"
  defp position_class("bottom-right"), do: "bottom-4 right-4"
  defp position_class(_), do: "bottom-4 right-4"
end
