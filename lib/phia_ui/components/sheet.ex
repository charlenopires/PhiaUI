defmodule PhiaUi.Components.Sheet do
  @moduledoc """
  Sheet component — a sliding panel that enters from an edge of the screen.

  Unlike `Drawer`, `Sheet` has richer semantic sub-components (`sheet_title/1`,
  `sheet_description/1`) and a size system (`sm/md/lg/xl/full`) that controls
  the width or height of the panel depending on the side it slides in from.

  Reuses the `PhiaDialog` JavaScript Hook for focus trap, Escape key handling,
  and scroll locking — no additional hook registration is required beyond the
  standard `PhiaDialog` import.

  ## Registration in app.js

  After running `mix phia.add sheet`, register the hook in your LiveSocket.
  Sheet reuses the existing `PhiaDialog` hook:

      import PhiaDialog from "./phia_hooks/dialog.js"

      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaDialog, ...yourOtherHooks }
      })

  ## Example

      <.sheet id="settings-sheet" open={@show_sheet} side="right">
        <.sheet_header>
          <.sheet_title id="settings-sheet-title">Settings</.sheet_title>
          <.sheet_description id="settings-sheet-description">
            Manage your account preferences.
          </.sheet_description>
        </.sheet_header>
        <div class="p-6">
          <p>Sheet body content goes here.</p>
        </div>
        <.sheet_footer>
          <button phx-click="save">Save</button>
        </.sheet_footer>
        <.sheet_close />
      </.sheet>

  ## Sub-components

  | Function               | Purpose                                      |
  |------------------------|----------------------------------------------|
  | `sheet/1`              | Root container with hook anchor              |
  | `sheet_header/1`       | Title and description layout container       |
  | `sheet_title/1`        | `<h2>` heading (set id for ARIA linkage)     |
  | `sheet_description/1`  | `<p>` supporting text (set id for ARIA)      |
  | `sheet_footer/1`       | Action row at the bottom                     |
  | `sheet_close/1`        | × close button                               |

  ## Sides

  | Value      | Slides from    | Panel sizing                   |
  |------------|----------------|--------------------------------|
  | `"right"`  | right edge     | full height, configurable width |
  | `"left"`   | left edge      | full height, configurable width |
  | `"top"`    | top edge       | full width, configurable height |
  | `"bottom"` | bottom edge    | full width, configurable height |

  ## Sizes

  | Value    | Width (right/left)  | Height (top/bottom) |
  |----------|---------------------|---------------------|
  | `"sm"`   | `w-64`              | `h-64`              |
  | `"md"`   | `w-96` (default)    | `h-96`              |
  | `"lg"`   | `max-w-lg`          | `max-h-64`          |
  | `"xl"`   | `max-w-xl`          | `max-h-96`          |
  | `"full"` | `max-w-full`        | `max-h-full`        |
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias Phoenix.LiveView.JS

  # ---------------------------------------------------------------------------
  # sheet/1
  # ---------------------------------------------------------------------------

  @doc """
  Root Sheet container. Binds the `PhiaDialog` JS Hook for focus trap and
  keyboard handling (Escape to close, Tab to cycle focus).

  The `open` boolean controls visibility via a `hidden` CSS class on the
  outer container. The `side` attribute controls which edge the panel slides
  in from. The `size` attribute controls the panel's cross-axis dimension.
  """
  attr(:id, :string, required: true, doc: "Unique sheet ID, used as the hook anchor")

  attr(:open, :boolean,
    default: false,
    doc: "Whether the sheet is currently open"
  )

  attr(:side, :string,
    default: "right",
    values: ~w(top right bottom left),
    doc: "Edge the panel slides in from"
  )

  attr(:size, :string,
    default: "md",
    values: ~w(sm md lg xl full),
    doc: "Width (for left/right) or height (for top/bottom) of the panel"
  )

  attr(:on_close, JS, default: nil, doc: "JS command to execute when the close button is clicked")
  attr(:class, :string, default: nil, doc: "Additional CSS classes for the panel")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root element")
  slot(:inner_block, required: true, doc: "Sheet content: header, body, footer, close")

  def sheet(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaDialog"
      class={cn(["fixed inset-0 z-50", !@open && "hidden"])}
      {@rest}
    >
      <%!-- Backdrop --%>
      <div
        data-sheet-backdrop
        data-dialog-overlay
        class="fixed inset-0 bg-black/80 transition-opacity"
        aria-hidden="true"
        phx-click={@on_close}
      >
      </div>
      <%!-- Sliding panel --%>
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby={"#{@id}-title"}
        data-sheet-panel
        data-dialog-panel
        data-side={@side}
        class={cn([
          "fixed bg-background shadow-lg overflow-y-auto",
          "transition-transform duration-300 ease-in-out",
          panel_position_classes(@side),
          panel_size_classes(@side, @size),
          @class
        ])}
      >
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # sheet_header/1
  # ---------------------------------------------------------------------------

  @doc "Layout container for the sheet title and optional description."
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes")
  slot(:inner_block, required: true, doc: "Header content")

  def sheet_header(assigns) do
    ~H"""
    <div class={cn(["flex flex-col space-y-1.5 p-6", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # sheet_title/1
  # ---------------------------------------------------------------------------

  @doc """
  Sheet heading (`<h2>`). Set `:id` to `"{sheet-id}-title"` so that the
  `sheet/1` container's `aria-labelledby` resolves correctly.
  """
  attr(:id, :string, default: nil, doc: "Element ID for ARIA linkage")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes")
  slot(:inner_block, required: true, doc: "Title text")

  def sheet_title(assigns) do
    ~H"""
    <h2
      id={@id}
      class={cn(["text-lg font-semibold leading-none tracking-tight", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </h2>
    """
  end

  # ---------------------------------------------------------------------------
  # sheet_description/1
  # ---------------------------------------------------------------------------

  @doc """
  Supporting text below the sheet title. Set `:id` to `"{sheet-id}-description"`
  and reference it from `sheet/1`'s `aria-describedby` if needed.
  """
  attr(:id, :string, default: nil, doc: "Element ID for ARIA linkage")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes")
  slot(:inner_block, required: true, doc: "Description text")

  def sheet_description(assigns) do
    ~H"""
    <p id={@id} class={cn(["text-sm text-muted-foreground", @class])} {@rest}>
      {render_slot(@inner_block)}
    </p>
    """
  end

  # ---------------------------------------------------------------------------
  # sheet_footer/1
  # ---------------------------------------------------------------------------

  @doc "Action row at the bottom of the sheet (save, cancel, confirm, etc.)."
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes")
  slot(:inner_block, required: true, doc: "Footer content")

  def sheet_footer(assigns) do
    ~H"""
    <div
      class={cn([
        "flex flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2 p-6 pt-0",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # sheet_close/1
  # ---------------------------------------------------------------------------

  @doc """
  The × close button rendered in the top-right corner of the sheet panel.
  The `PhiaDialog` JS hook handles the actual close behavior (adds `hidden`
  class and returns focus to the previously-focused element).
  """
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes")

  def sheet_close(assigns) do
    ~H"""
    <button
      type="button"
      data-sheet-close
      aria-label="Close sheet"
      class={cn([
        "absolute right-4 top-4 rounded-sm opacity-70 ring-offset-background",
        "transition-opacity hover:opacity-100",
        "focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2",
        @class
      ])}
      {@rest}
    >
      <svg
        class="h-4 w-4"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
        aria-hidden="true"
      >
        <path d="M18 6 6 18M6 6l12 12" />
      </svg>
      <span class="sr-only">Close</span>
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp panel_position_classes("right"), do: "inset-y-0 right-0 h-full border-l"
  defp panel_position_classes("left"), do: "inset-y-0 left-0 h-full border-r"
  defp panel_position_classes("top"), do: "inset-x-0 top-0 w-full border-b"
  defp panel_position_classes("bottom"), do: "inset-x-0 bottom-0 w-full border-t"

  defp panel_size_classes(side, size) when side in ~w(right left) do
    case size do
      "sm" -> "w-64"
      "md" -> "w-96"
      "lg" -> "w-full max-w-lg"
      "xl" -> "w-full max-w-xl"
      "full" -> "w-full max-w-full"
    end
  end

  defp panel_size_classes(side, size) when side in ~w(top bottom) do
    case size do
      "sm" -> "h-64"
      "md" -> "h-96"
      "lg" -> "max-h-64"
      "xl" -> "max-h-96"
      "full" -> "max-h-full"
    end
  end
end
