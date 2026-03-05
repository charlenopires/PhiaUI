defmodule PhiaUi.Components.Popover do
  @moduledoc """
  Popover component powered by the `PhiaPopover` vanilla JavaScript hook.

  A popover is a floating panel anchored to a trigger element, revealed on
  click. Unlike a `Tooltip`, a popover can contain interactive elements such
  as forms, buttons, and links — it is essentially a lightweight modal panel
  anchored to an element rather than centered on the viewport.

  The `PhiaPopover` hook handles:
  - Click-to-toggle (open/close)
  - Focus trap — Tab and Shift+Tab cycle within the open panel
  - Escape key to close and return focus to the trigger
  - Click-outside-to-close
  - Smart viewport-edge positioning (flips or adjusts when near the edge)

  ## Sub-components

  | Function           | Element   | Purpose                                          |
  |--------------------|-----------|--------------------------------------------------|
  | `popover/1`        | `div`     | Root container — hook mount point                |
  | `popover_trigger/1`| `button`  | Toggle button with `aria-expanded`/`aria-controls` |
  | `popover_content/1`| `div`     | Floating panel with `role="dialog"`, `aria-modal` |

  ## Hook Setup

  Copy the hook via `mix phia.add popover`, then register it in `app.js`:

      # assets/js/app.js
      import PhiaPopover from "./hooks/popover"

      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaPopover }
      })

  ## Basic Example — Inline Settings Panel

  A common pattern: a settings button that opens a small panel with a form.

      <.popover id="display-settings">
        <.popover_trigger popover_id="display-settings">
          <.button variant="outline">
            <.icon name="settings" class="mr-2" />
            Display Settings
          </.button>
        </.popover_trigger>
        <.popover_content popover_id="display-settings" position={:bottom}>
          <h3 class="font-semibold mb-2">Display options</h3>
          <.form phx-change="update_display" phx-submit="save_display">
            <.select name="density" label="Row density" options={["compact", "normal", "comfortable"]} />
            <.button type="submit" class="mt-3 w-full">Apply</.button>
          </.form>
        </.popover_content>
      </.popover>

  ## Example — Column Visibility Picker

  A common data grid use case: show/hide table columns via a popover checklist.

      <.popover id="column-picker">
        <.popover_trigger popover_id="column-picker">
          <.button variant="outline" size="sm">Columns</.button>
        </.popover_trigger>
        <.popover_content popover_id="column-picker">
          <p class="text-sm font-medium mb-2">Toggle columns</p>
          <.scroll_area class="max-h-48">
            <.checkbox
              :for={col <- @columns}
              name="column_visibility"
              label={col.label}
              checked={col.visible}
              phx-change="toggle_column"
              phx-value-column={col.key} />
          </.scroll_area>
        </.popover_content>
      </.popover>

  ## Example — Date Picker Integration

  Popovers are used as the anchor panel in the `DatePicker` and
  `DateRangePicker` components. Here's the pattern:

      <.popover id="dob-picker">
        <.popover_trigger popover_id="dob-picker">
          <.button variant="outline">
            {if @date, do: Calendar.strftime(@date, "%B %d, %Y"), else: "Pick a date"}
          </.button>
        </.popover_trigger>
        <.popover_content popover_id="dob-picker" position={:bottom}>
          <.calendar id="dob-cal" phx-change="set_dob" />
        </.popover_content>
      </.popover>

  ## Position Values

  | Value      | Panel appears...                 |
  |------------|----------------------------------|
  | `:bottom`  | Below the trigger (default)      |
  | `:top`     | Above the trigger                |
  | `:left`    | To the left of the trigger       |
  | `:right`   | To the right of the trigger      |

  ## Differences from Tooltip and Dialog

  | Component   | Trigger   | Interactive content | Focus trap | Backdrop |
  |-------------|-----------|---------------------|------------|----------|
  | `Tooltip`   | Hover     | No                  | No         | No       |
  | `Popover`   | Click     | Yes                 | Yes        | No       |
  | `Dialog`    | Programmatic | Yes              | Yes        | Yes      |

  ## Accessibility

  - Trigger has `aria-expanded` (updated by hook) and `aria-controls` pointing
    at the content panel
  - Content panel has `role="dialog"` and `aria-modal="true"` — this tells
    assistive technology to confine navigation to the panel while it is open
  - Focus trap ensures keyboard users cannot accidentally navigate outside
    the popover while it is open
  - Escape key closes the panel and returns focus to the trigger
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # popover/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    required: true,
    doc: """
    Unique element ID — the hook mount point. `popover_trigger/1` and
    `popover_content/1` derive their IDs from this value. Must be unique on
    the page.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the container")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the root `<div>`")

  slot(:inner_block,
    required: true,
    doc: "Must contain one `popover_trigger/1` and one `popover_content/1`"
  )

  @doc """
  Renders the popover root container and attaches the `PhiaPopover` hook.

  The `relative inline-flex` positioning makes this the offset parent for the
  absolutely-positioned content panel. The hook attaches to this element to
  listen for trigger events and manage the open/closed state.
  """
  def popover(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaPopover"
      class={cn(["relative inline-flex", @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # popover_trigger/1
  # ---------------------------------------------------------------------------

  attr(:popover_id, :string,
    required: true,
    doc: "ID of the parent `popover/1` — used to build `aria-controls`"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the trigger button")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the `<button>`")

  slot(:inner_block, required: true, doc: "Trigger button content — text, icon, or both")

  @doc """
  Renders the trigger button that opens and closes the popover panel.

  Sets the WAI-ARIA attributes for a toggle button:
  - `aria-controls` — links the button to the panel it controls
  - `aria-expanded="false"` — initial state; the hook updates this when open

  The hook's click handler on `data-popover-trigger` toggles the panel's
  visibility and updates `aria-expanded` accordingly.
  """
  def popover_trigger(assigns) do
    ~H"""
    <button
      type="button"
      aria-controls={"#{@popover_id}-content"}
      aria-expanded="false"
      data-popover-trigger
      class={cn([@class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # popover_content/1
  # ---------------------------------------------------------------------------

  attr(:popover_id, :string,
    required: true,
    doc: "ID of the parent `popover/1` — used to build the panel's element `id`"
  )

  attr(:position, :atom,
    default: :bottom,
    values: [:top, :bottom, :left, :right],
    doc: """
    Preferred position of the floating panel relative to the trigger. The hook
    reads `data-position` and adjusts `top`/`left` CSS properties. It also
    flips the position to the opposite side if the panel would overflow the
    viewport.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the content panel")
  attr(:rest, :global, doc: "Extra HTML attributes forwarded to the panel `<div>`")

  slot(:inner_block,
    required: true,
    doc: """
    Popover body content. May contain interactive elements — forms, links,
    buttons, checkboxes. The hook's focus trap keeps Tab/Shift+Tab within this
    panel while it is open.
    """
  )

  @doc """
  Renders the floating popover content panel.

  Hidden by default via the `hidden` Tailwind class (`display: none`). The
  `PhiaPopover` hook removes this class and positions the panel via inline
  style when the trigger is clicked.

  Uses `role="dialog"` and `aria-modal="true"` rather than `role="tooltip"`
  because the panel can contain interactive elements. Screen readers will
  confine virtual cursor navigation to this panel while it is open.

  The `outline-none` class removes the default browser focus outline from
  the panel itself — focus is managed programmatically by the hook.
  """
  def popover_content(assigns) do
    ~H"""
    <div
      id={"#{@popover_id}-content"}
      role="dialog"
      aria-modal="true"
      data-position={@position}
      data-popover-content
      class={cn([
        "absolute z-50 rounded-md border border-border bg-popover text-popover-foreground",
        "p-4 shadow-md outline-none",
        "hidden",
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
