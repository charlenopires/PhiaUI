defmodule PhiaUi.Components.Editable do
  @moduledoc """
  Inline-editable field component — click to edit, Enter to submit, Escape to cancel.

  Follows the shadcn/ui "Editable" pattern adapted for Phoenix LiveView. The component
  renders in two modes controlled entirely by the `PhiaEditable` JavaScript hook:

  - **Preview mode** — shows slot content (or placeholder). A click or keyboard
    activation switches to edit mode.
  - **Edit mode** — shows the `:input` slot (an `<input>` or `<textarea>`). `Enter`
    submits the value via `pushEvent/3`; `Escape` cancels without saving. Clicking
    outside the element also cancels.

  Zero external JS dependencies — the hook is vanilla JS.

  ## Usage

      <.editable id="title-edit" value={@title} on_submit="update_title" placeholder="Click to edit">
        <:preview>{@title}</:preview>
        <:input>
          <input type="text" id="title-edit-input" name="title" value={@title}
                 class="w-full border rounded px-2 py-1" />
        </:input>
      </.editable>

  In your LiveView, handle the submitted value:

      def handle_event("update_title", %{"value" => value}, socket) do
        {:noreply, assign(socket, title: value)}
      end

  ## Attributes

  | Attribute     | Type     | Default           | Description                                  |
  |---------------|----------|-------------------|----------------------------------------------|
  | `id`          | string   | **required**      | Unique element ID (required by the hook)     |
  | `value`       | string   | `nil`             | Current value (for reference; not rendered)  |
  | `placeholder` | string   | `"Click to edit"` | Text shown when preview slot is empty        |
  | `on_submit`   | string   | `nil`             | LiveView event pushed when user submits       |
  | `class`       | string   | `nil`             | Extra classes merged onto the container div  |

  ## Slots

  | Slot      | Required | Description                                         |
  |-----------|----------|-----------------------------------------------------|
  | `preview` | yes      | Content rendered in preview (read) mode             |
  | `input`   | yes      | Content rendered in edit mode (typically `<input>`) |

  ## Accessibility

  - The preview div has `role="button"` and `tabindex="0"` so keyboard users can
    activate it with `Enter` or `Space`.
  - `aria-label="Click to edit"` provides a descriptive accessible name.
  - The edit-mode input receives focus automatically on activation.

  ## JS Hook: `PhiaEditable`

  Register the hook exported from `priv/templates/js/hooks/editable.js`:

      import PhiaEditable from "../../../deps/phia_ui/priv/templates/js/hooks/editable"

      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaEditable }
      })
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:id, :string,
    required: true,
    doc: "Unique element ID required by the PhiaEditable hook."
  )

  attr(:value, :string,
    default: nil,
    doc: "Current value of the field. Passed to the component for reference."
  )

  attr(:placeholder, :string,
    default: "Click to edit",
    doc: "Placeholder text shown when the preview slot renders no content."
  )

  attr(:on_submit, :string,
    default: nil,
    doc:
      "LiveView event name pushed when the user submits the new value. Omit to disable submission."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged onto the container div via `cn/1`."
  )

  slot(:preview,
    required: true,
    doc: "Content displayed in preview (read) mode. May be plain text or rich HTML."
  )

  slot(:input,
    required: true,
    doc: "Content displayed in edit mode. Should contain an `<input>` or `<textarea>`."
  )

  @doc """
  Renders an inline-editable field.

  The component shows the `:preview` slot by default. Clicking (or pressing
  `Enter`/`Space`) on the preview activates edit mode and shows the `:input`
  slot. The `PhiaEditable` JS hook manages the mode toggle, focus, keyboard
  handling, and event dispatch.

  ## Example

      <.editable id="bio-edit" value={@bio} on_submit="update_bio" placeholder="Add a bio…">
        <:preview>{@bio}</:preview>
        <:input>
          <textarea id="bio-edit-input" name="bio" rows="3"
                    class="w-full border rounded px-2 py-1"><%= @bio %></textarea>
        </:input>
      </.editable>
  """
  def editable(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaEditable"
      data-on-submit={@on_submit}
      data-placeholder={@placeholder}
      class={cn(["relative w-full", @class])}
    >
      <%!-- Preview mode: visible by default --%>
      <div
        data-editable-preview
        role="button"
        tabindex="0"
        aria-label="Click to edit"
        class="cursor-pointer rounded px-2 py-1 hover:bg-muted min-h-[2rem] flex items-center"
      >
        {render_slot(@preview) || @placeholder}
      </div>

      <%!-- Edit mode: hidden by default; hook toggles the hidden class --%>
      <div data-editable-input class="hidden">
        {render_slot(@input)}
      </div>
    </div>
    """
  end
end
