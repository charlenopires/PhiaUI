defmodule PhiaUi.Components.InlineEditTable do
  @moduledoc """
  Inline-editable table row components for in-place data editing.

  All state (which rows are in edit mode, saving state) lives in the LiveView.
  These components are purely presentational — they switch between a read view
  and an edit view based on `@editing` assigns.

  ## Sub-components

  | Function               | HTML element | Purpose                                     |
  |------------------------|--------------|---------------------------------------------|
  | `editable_cell/1`      | `<td>`       | Single cell toggling view ↔ edit mode       |
  | `editable_row/1`       | `<tr>`       | Row wrapper that applies edit-mode styling  |
  | `editable_row_actions/1`| `<td>`      | Save + Cancel action cell for editing rows  |

  ## Example

      defmodule MyAppWeb.ProductsLive do
        use MyAppWeb, :live_view

        def handle_event("start_edit", %{"id" => id}, socket) do
          {:noreply, assign(socket, editing_id: id)}
        end

        def handle_event("save_row", %{"id" => id}, socket) do
          # persist changes, then:
          {:noreply, assign(socket, editing_id: nil)}
        end

        def handle_event("cancel_edit", _params, socket) do
          {:noreply, assign(socket, editing_id: nil)}
        end

        def render(assigns) do
          ~H\"\"\"
          <.table>
            <.table_body>
              <%= for product <- @products do %>
                <% editing = to_string(product.id) == @editing_id %>
                <.editable_row editing={editing}>
                  <.editable_cell editing={editing}>
                    <:view>{product.name}</:view>
                    <:edit>
                      <input type="text" name="name" value={product.name}
                             class="h-8 w-full rounded border border-input px-2 text-sm" />
                    </:edit>
                  </.editable_cell>
                  <.editable_cell editing={editing}>
                    <:view>{product.price}</:view>
                    <:edit>
                      <input type="number" name="price" value={product.price}
                             class="h-8 w-24 rounded border border-input px-2 text-sm text-right" />
                    </:edit>
                  </.editable_cell>
                  <%= if editing do %>
                    <.editable_row_actions
                      row_id={to_string(product.id)}
                      on_save="save_row"
                      on_cancel="cancel_edit"
                    />
                  <% else %>
                    <.table_cell>
                      <.button variant={:ghost} size={:sm}
                               phx-click="start_edit"
                               phx-value-id={to_string(product.id)}>Edit</.button>
                    </.table_cell>
                  <% end %>
                </.editable_row>
              <% end %>
            </.table_body>
          </.table>
          \"\"\"
        end
      end
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # editable_cell/1
  # ---------------------------------------------------------------------------

  attr(:editing, :boolean,
    default: false,
    doc: """
    When `true`, the `:edit` slot is displayed and `:view` is hidden.
    When `false`, the `:view` slot is displayed and `:edit` is hidden.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the `<td>`")

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<td>` element")

  slot(:view,
    required: true,
    doc: "Content shown when the row is NOT in edit mode (read view)"
  )

  slot(:edit,
    required: true,
    doc: "Input or select shown when the row IS in edit mode (edit view)"
  )

  @doc """
  Renders a `<td>` that switches between a read view and an edit view.

  Only one slot is rendered at a time — determined by `@editing`. This keeps
  the server-rendered HTML minimal while making the transition seamless from
  the user's perspective.

  ## Example

      <.editable_cell editing={@editing_id == product.id}>
        <:view>{product.sku}</:view>
        <:edit>
          <input type="text" name="sku" value={product.sku}
                 class="h-8 w-full rounded border border-input px-2 text-sm" />
        </:edit>
      </.editable_cell>
  """
  def editable_cell(assigns) do
    ~H"""
    <td class={cn(["px-4 py-3 align-middle", @class])} {@rest}>
      <div :if={!@editing}>{render_slot(@view)}</div>
      <div :if={@editing}>{render_slot(@edit)}</div>
    </td>
    """
  end

  # ---------------------------------------------------------------------------
  # editable_row/1
  # ---------------------------------------------------------------------------

  attr(:editing, :boolean,
    default: false,
    doc: """
    When `true`, applies an edit-mode background tint and a primary ring
    outline to the row. Set to `false` for the default read view.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the `<tr>`")

  attr(:rest, :global, doc: "HTML attributes forwarded to the `<tr>` element (e.g. `id`)")

  slot(:inner_block,
    required: true,
    doc: "`editable_cell/1` and `editable_row_actions/1` children"
  )

  @doc """
  Renders a `<tr>` wrapper that applies edit-mode visual styling.

  When `editing={true}`:
  - Adds a subtle `bg-muted/20` background
  - Adds `ring-1 ring-inset ring-primary/30` to signal an active edit session
  - Sets `data-editing="true"` for CSS or JavaScript targeting

  ## Example

      <.editable_row editing={@editing_id == user.id}>
        <.editable_cell editing={@editing_id == user.id}>
          <:view>{user.name}</:view>
          <:edit><input ... /></:edit>
        </.editable_cell>
        <.editable_row_actions row_id={to_string(user.id)} />
      </.editable_row>
  """
  def editable_row(assigns) do
    ~H"""
    <tr
      data-editing={@editing && "true"}
      class={cn([
        "border-b transition-colors",
        @editing && "bg-muted/20 ring-1 ring-inset ring-primary/30",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </tr>
    """
  end

  # ---------------------------------------------------------------------------
  # editable_row_actions/1
  # ---------------------------------------------------------------------------

  attr(:on_save, :string,
    default: "save_row",
    doc: """
    `phx-click` event fired when the Save button is clicked. Receives
    `phx-value-id` set to `row_id`.
    """
  )

  attr(:on_cancel, :string,
    default: "cancel_edit",
    doc: """
    `phx-click` event fired when the Cancel button is clicked. Receives
    `phx-value-id` set to `row_id`.
    """
  )

  attr(:row_id, :string,
    required: true,
    doc: "Row identifier sent as `phx-value-id` on both Save and Cancel clicks"
  )

  attr(:saving, :boolean,
    default: false,
    doc: "When `true`, the Save button is dimmed and pointer-events are disabled"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the `<td>`")

  @doc """
  Renders a `<td>` containing Save and Cancel buttons for an editing row.

  The Save button is styled as a primary action. When `saving={true}` it
  becomes dimmed to signal an in-flight request. The Cancel button is a ghost
  action that discards changes.

  ## Example

      <.editable_row_actions
        row_id={to_string(user.id)}
        saving={@saving_id == user.id}
        on_save="save_row"
        on_cancel="cancel_edit"
      />
  """
  def editable_row_actions(assigns) do
    ~H"""
    <td class={cn(["px-4 py-3 align-middle", @class])}>
      <div class="flex items-center justify-end gap-2">
        <button
          type="button"
          aria-label="Save row"
          phx-click={@on_save}
          phx-value-id={@row_id}
          class={cn([
            "inline-flex h-7 items-center rounded-md bg-primary px-2.5 text-xs font-medium text-primary-foreground transition-opacity hover:opacity-90",
            @saving && "pointer-events-none opacity-60"
          ])}
        >
          Save
        </button>
        <button
          type="button"
          aria-label="Cancel edit"
          phx-click={@on_cancel}
          phx-value-id={@row_id}
          class="inline-flex h-7 items-center rounded-md px-2.5 text-xs font-medium text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
        >
          Cancel
        </button>
      </div>
    </td>
    """
  end
end
