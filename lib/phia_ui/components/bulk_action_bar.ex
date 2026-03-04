defmodule PhiaUi.Components.BulkActionBar do
  @moduledoc """
  BulkActionBar component for PhiaUI.

  A contextual toolbar that appears when one or more rows are selected in a
  table or list. Displays the selection count, a clear button, and a slot
  for action buttons. Hidden automatically when `count` is zero.

  ## Sub-components

  - `bulk_action_bar/1` — root toolbar (hidden when `count == 0`)
  - `bulk_action/1` — individual action button with optional icon and variant

  ## Example

      <.bulk_action_bar
        count={@selected_count}
        label="items selected"
        on_clear="clear_selection"
      >
        <.bulk_action label="Delete" on_click="bulk_delete" variant="destructive" icon="trash" />
        <.bulk_action label="Archive" on_click="bulk_archive" icon="archive" />
        <.bulk_action label="Export" on_click="bulk_export" icon="download" />
      </.bulk_action_bar>

  ## LiveView handlers

      def handle_event("clear_selection", _params, socket) do
        {:noreply, assign(socket, selected_ids: [], selected_count: 0)}
      end

      def handle_event("bulk_delete", _params, socket) do
        # delete all selected_ids
        {:noreply, socket}
      end
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # bulk_action_bar/1
  # ---------------------------------------------------------------------------

  attr(:count, :integer, required: true, doc: "Number of selected items; bar is hidden when 0")

  attr(:label, :string,
    default: "selected",
    doc: "Label displayed after the count (e.g. 'selected' → '3 selected')"
  )

  attr(:on_clear, :string, required: true, doc: "phx-click event to clear the selection")
  attr(:class, :string, default: nil, doc: "Additional CSS classes for the toolbar")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root div")

  slot(:inner_block, required: true, doc: "bulk_action/1 children")

  @doc """
  Renders the bulk action toolbar.

  The toolbar is hidden when `count` is zero. When visible it shows:
  - Selection count + label on the left
  - A clear (×) button to deselect all
  - Action buttons from the `:inner_block` slot on the right

  Uses `role="toolbar"` for proper ARIA semantics.
  """
  def bulk_action_bar(%{count: 0} = assigns) do
    ~H"""
    """
  end

  def bulk_action_bar(assigns) do
    ~H"""
    <div
      role="toolbar"
      aria-label={"#{@count} #{@label}"}
      class={cn([
        "flex items-center gap-3 rounded-lg border border-border",
        "bg-background/95 px-4 py-2.5 shadow-md backdrop-blur-sm",
        @class
      ])}
      {@rest}
    >
      <%!-- Selection count + label --%>
      <span class="text-sm font-medium text-foreground">
        {@count} {@label}
      </span>

      <%!-- Clear button --%>
      <button
        type="button"
        phx-click={@on_clear}
        aria-label="Clear selection"
        class={cn([
          "rounded p-0.5 text-muted-foreground",
          "hover:bg-muted hover:text-foreground transition-colors",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
        ])}
      >
        <.icon name="x" size={:xs} />
      </button>

      <%!-- Divider --%>
      <div class="h-4 w-px bg-border" aria-hidden="true" />

      <%!-- Action buttons --%>
      <div class="flex items-center gap-1.5">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # bulk_action/1
  # ---------------------------------------------------------------------------

  attr(:label, :string, required: true, doc: "Button label text")

  attr(:on_click, :string,
    required: true,
    doc: "phx-click event fired when the button is pressed"
  )

  attr(:variant, :string,
    default: "default",
    values: ~w(default destructive),
    doc: "Visual variant: default | destructive"
  )

  attr(:icon, :string,
    default: nil,
    doc: "Optional icon name (Lucide) displayed before the label"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, include: ~w(phx-value-id phx-value-type disabled), doc: "Forwarded attrs")

  @doc """
  Renders a single bulk action button.

  Place inside a `bulk_action_bar/1` slot. Use `variant="destructive"` for
  dangerous operations like delete. Optionally include an icon name for visual clarity.
  """
  def bulk_action(assigns) do
    ~H"""
    <button
      type="button"
      phx-click={@on_click}
      class={cn([bulk_action_class(@variant), @class])}
      {@rest}
    >
      <.icon :if={@icon} name={@icon} size={:xs} />
      {@label}
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp bulk_action_class("destructive") do
    cn([
      "inline-flex items-center gap-1.5 rounded-md px-3 py-1.5 text-sm font-medium",
      "text-destructive hover:bg-destructive/10 transition-colors",
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
    ])
  end

  defp bulk_action_class(_default) do
    cn([
      "inline-flex items-center gap-1.5 rounded-md px-3 py-1.5 text-sm font-medium",
      "text-foreground hover:bg-muted transition-colors",
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
    ])
  end
end
