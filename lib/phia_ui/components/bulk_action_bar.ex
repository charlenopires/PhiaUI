defmodule PhiaUi.Components.BulkActionBar do
  @moduledoc """
  BulkActionBar component for PhiaUI.

  A contextual action toolbar that appears when one or more rows are selected
  in a table or list. Displays the selection count, a clear-selection button,
  and a slot for action buttons.

  The toolbar is hidden automatically when `count` is zero — implemented as two
  function heads on `bulk_action_bar/1`: the `count: 0` head renders an empty
  fragment so the DOM element is completely absent, while any non-zero count
  renders the full toolbar. This avoids CSS `display:none` tricks and keeps
  the DOM clean.

  ## When to use

  Use `BulkActionBar` in data table or list views wherever you want to let users
  select multiple rows and act on them collectively — for example:

  - Delete multiple records at once
  - Archive or restore a batch of items
  - Export selected rows to CSV
  - Assign multiple tasks to a team member
  - Approve / reject a group of requests

  ## Anatomy

  | Component          | Element   | Purpose                                             |
  |--------------------|-----------|-----------------------------------------------------|
  | `bulk_action_bar/1`| `div`     | Root toolbar (`role="toolbar"`) — hidden when count=0 |
  | `bulk_action/1`    | `button`  | Individual action button with optional icon and variant |

  ## Example — table with bulk actions

      <%!-- Toolbar sits above (or below) the table and shows when rows are selected --%>
      <.bulk_action_bar
        count={@selected_count}
        label="contacts selected"
        on_clear="clear_selection"
      >
        <.bulk_action label="Send email" on_click="bulk_email" icon="mail" />
        <.bulk_action label="Export CSV"  on_click="bulk_export"  icon="download" />
        <.bulk_action label="Archive"     on_click="bulk_archive" icon="archive" />
        <.bulk_action label="Delete"      on_click="bulk_delete"  icon="trash" variant="destructive" />
      </.bulk_action_bar>

      <.data_grid rows={@contacts} columns={@columns} />

  ## LiveView handlers

      def handle_event("clear_selection", _params, socket) do
        {:noreply, assign(socket, selected_ids: MapSet.new(), selected_count: 0)}
      end

      def handle_event("bulk_delete", _params, socket) do
        ids = MapSet.to_list(socket.assigns.selected_ids)
        Repo.delete_all(from c in Contact, where: c.id in ^ids)
        {:noreply,
         socket
         |> assign(selected_ids: MapSet.new(), selected_count: 0)
         |> stream(:contacts, Repo.all(Contact))}
      end

      def handle_event("bulk_export", _params, socket) do
        ids = MapSet.to_list(socket.assigns.selected_ids)
        csv = Contacts.export_csv(ids)
        {:noreply, push_event(socket, "download", %{filename: "contacts.csv", content: csv})}
      end

  ## Why two function heads instead of CSS `display:none`?

  When `count` is 0, `bulk_action_bar/1` renders `~H""` — an empty HEEx
  fragment. This means the DOM element does not exist at all, which:

  - Prevents screen readers from announcing the toolbar when it is inactive
  - Avoids accidental tab focus landing on hidden buttons
  - Keeps the DOM tree small for large data tables
  - Makes `role="toolbar"` semantics correct (toolbars should not be present
    in the accessibility tree when they have no applicable context)
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # bulk_action_bar/1
  # ---------------------------------------------------------------------------

  attr(:count, :integer,
    required: true,
    doc: """
    Number of currently selected items.
    When `0`, the entire toolbar is removed from the DOM.
    When positive, the toolbar renders with `count` displayed prominently.
    """
  )

  attr(:label, :string,
    default: "selected",
    doc: """
    Label appended after the count, e.g. `"selected"` → "3 selected",
    or `"contacts selected"` → "5 contacts selected".
    """
  )

  attr(:on_clear, :string,
    required: true,
    doc: """
    `phx-click` event name for the clear-selection button.
    The handler should reset selected IDs and count to zero.
    """
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes for the toolbar container"
  )

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the root div"
  )

  slot(:inner_block,
    required: true,
    doc: "`bulk_action/1` children — the action buttons for this toolbar"
  )

  @doc """
  Renders the bulk action toolbar.

  **When `count` is 0**, renders an empty HEEx fragment (`~H""`), meaning no
  DOM element is present. This is preferable to CSS visibility toggling for
  accessibility and DOM cleanliness.

  **When `count > 0`**, renders a glass-morphism toolbar with:
  - Selection count + label on the left
  - A clear (×) button to deselect all rows
  - A vertical divider
  - Action buttons from the `:inner_block` slot on the right

  Uses `role="toolbar"` for correct ARIA semantics and includes a dynamic
  `aria-label` that reads the count aloud to screen readers.
  """
  # count=0 — render nothing; the DOM element is completely absent
  def bulk_action_bar(%{count: 0} = assigns) do
    ~H"""
    """
  end

  # count > 0 — render the full toolbar
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

      <%!-- Clear selection button — deselects all rows --%>
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

      <%!-- Visual divider separating count from action buttons --%>
      <div class="h-4 w-px bg-border" aria-hidden="true" />

      <%!-- Action buttons slot --%>
      <div class="flex items-center gap-1.5">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # bulk_action/1
  # ---------------------------------------------------------------------------

  attr(:label, :string, required: true, doc: "Button label text (e.g. \"Delete\", \"Archive\")")

  attr(:on_click, :string,
    required: true,
    doc: """
    `phx-click` event name fired when the button is pressed.
    The handler should act on all currently selected IDs and then clear the selection.
    """
  )

  attr(:variant, :string,
    default: "default",
    values: ~w(default destructive),
    doc: """
    Visual variant:
    - `default` — muted text with hover background (for safe operations)
    - `destructive` — red `text-destructive` with red hover (for delete/irreversible actions)
    """
  )

  attr(:icon, :string,
    default: nil,
    doc: """
    Optional Lucide icon name displayed before the label.
    Recommended for quick recognition: `"trash"`, `"archive"`, `"download"`, `"mail"`.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the button")

  attr(:rest, :global,
    include: ~w(phx-value-id phx-value-type disabled),
    doc: """
    HTML attributes forwarded to the `<button>` element.
    Use `disabled={@processing}` to prevent double-submits during async operations.
    """
  )

  @doc """
  Renders a single bulk action button.

  Place inside a `bulk_action_bar/1` slot. Use `variant="destructive"` for
  irreversible operations (delete, purge) so users visually distinguish them
  from safe operations (export, archive).

  ## Example

      <.bulk_action label="Delete selected" on_click="bulk_delete" icon="trash" variant="destructive" />
      <.bulk_action label="Export"          on_click="bulk_export" icon="download" />
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

  # Destructive actions (delete, purge) use red text to signal danger.
  # The /10 opacity background on hover avoids a jarring full red background.
  defp bulk_action_class("destructive") do
    cn([
      "inline-flex items-center gap-1.5 rounded-md px-3 py-1.5 text-sm font-medium",
      "text-destructive hover:bg-destructive/10 transition-colors",
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
    ])
  end

  # Default (safe) actions use standard foreground colour.
  defp bulk_action_class(_default) do
    cn([
      "inline-flex items-center gap-1.5 rounded-md px-3 py-1.5 text-sm font-medium",
      "text-foreground hover:bg-muted transition-colors",
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
    ])
  end
end
