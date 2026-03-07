defmodule PhiaUi.Components.DataTable do
  @moduledoc """
  All-in-one declarative table — define columns once, render everything.

  Unlike the composable `Table` primitive (where you manually write thead/tbody
  rows), `DataTable` generates the full table structure from a `:rows` list and
  named `:column` slots. This makes common tables fast to build with minimal
  boilerplate.

  For advanced use cases (streams, row selection, pagination, column toggle)
  use `DataGrid` instead.

  ## Sub-components

  | Function            | Used as           | Purpose                            |
  |---------------------|-------------------|------------------------------------|
  | `data_table/1`      | Component         | Outer table + header + body        |
  | `:column` slot      | `<:column>`       | Column definition with inner_block |

  ## Example

      <.data_table
        rows={@users}
        sort_key={@sort_key}
        sort_dir={@sort_dir}
        on_sort="sort"
        striped
      >
        <:column key="name" label="Name" sortable :let={user}>
          <span class="font-medium">{user.name}</span>
        </:column>
        <:column key="email" label="Email" sortable :let={user}>
          {user.email}
        </:column>
        <:column key="role" label="Role" align={:center} :let={user}>
          <.badge variant={:secondary}>{user.role}</.badge>
        </:column>
        <:action :let={user}>
          <.button variant={:ghost} size={:sm} phx-click="edit" phx-value-id={user.id}>
            Edit
          </.button>
        </:action>
      </.data_table>

  ## Sort events

  Sortable column headers fire the `on_sort` event with `phx-value-key` and
  `phx-value-dir` (the **next** direction: `"asc"`, `"desc"`, or `"none"`):

      def handle_event("sort", %{"key" => key, "dir" => dir}, socket) do
        {:noreply, assign(socket, sort_key: key, sort_dir: String.to_existing_atom(dir))}
      end
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # data_table/1
  # ---------------------------------------------------------------------------

  attr(:rows, :list,
    required: true,
    doc: "List of maps or structs to render — one row per element"
  )

  attr(:row_id, :any,
    default: nil,
    doc: """
    Optional function `fn row -> id end` to extract a stable row identifier.
    Not used directly in the render but available for LiveView stream integration.
    """
  )

  attr(:sort_key, :string,
    default: nil,
    doc: "Key of the currently sorted column. Matches the `key` attr on `:column` slots."
  )

  attr(:sort_dir, :atom,
    default: :none,
    values: [:none, :asc, :desc],
    doc: "Current sort direction. `:none` shows the unsorted double-chevron icon."
  )

  attr(:on_sort, :string,
    default: "sort",
    doc: """
    `phx-click` event fired when a sortable column header is clicked. Receives
    `phx-value-key` (column key) and `phx-value-dir` (next direction string).
    """
  )

  attr(:striped, :boolean,
    default: false,
    doc: "When `true`, alternating rows receive a subtle `bg-muted/30` background"
  )

  attr(:empty_message, :string,
    default: "No data",
    doc: "Text displayed when `rows` is an empty list"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the outer wrapper div")

  slot :column do
    attr(:key, :string, required: true)
    attr(:label, :string, required: true)
    attr(:sortable, :boolean)
    attr(:align, :atom, values: [:left, :right, :center])
    attr(:width, :string)
  end

  slot(:action,
    doc: """
    Optional per-row action cell appended as the last column. The slot
    receives each row via `:let`:

        <:action :let={user}>
          <.button phx-click="delete" phx-value-id={user.id}>Delete</.button>
        </:action>
    """
  )

  @doc """
  Renders a complete table from `rows` and `:column` slot definitions.

  Column headers are generated from `:column` slot attrs (`label`, `sortable`,
  `align`). Each body row is built by iterating `rows` and calling
  `render_slot(col, row)` for each column — the slot's `:let` binding receives
  the row map/struct.

  ## Example

      <.data_table rows={@products} empty_message="No products yet">
        <:column key="name" label="Product" :let={p}>{p.name}</:column>
        <:column key="price" label="Price" align={:right} :let={p}>
          ${p.price}
        </:column>
      </.data_table>
  """
  def data_table(assigns) do
    ~H"""
    <div class={cn(["w-full overflow-auto", @class])}>
      <table class="w-full caption-bottom text-sm">
        <thead class="[&_tr]:border-b">
          <tr>
            <th
              :for={col <- @column}
              class={cn([
                "h-11 px-4 align-middle text-xs font-medium text-muted-foreground uppercase tracking-wider",
                dt_align_class(Map.get(col, :align, :left))
              ])}
              style={if Map.get(col, :width), do: "width:#{Map.get(col, :width)}"}
            >
              <%= if Map.get(col, :sortable) do %>
                <button
                  type="button"
                  phx-click={@on_sort}
                  phx-value-key={col.key}
                  phx-value-dir={dt_next_dir(if @sort_key == col.key, do: @sort_dir, else: :none)}
                  class="inline-flex items-center gap-1 hover:text-foreground transition-colors"
                >
                  {col.label}
                  <.dt_sort_icon dir={if @sort_key == col.key, do: @sort_dir, else: :none} />
                </button>
              <% else %>
                {col.label}
              <% end %>
            </th>
            <th
              :if={@action != []}
              class="h-11 px-4 align-middle text-xs font-medium text-muted-foreground uppercase tracking-wider text-right"
            >
            </th>
          </tr>
        </thead>
        <tbody
          class={cn([
            "[&_tr:last-child]:border-0",
            @striped && "[&_tr:nth-child(even)]:bg-muted/30"
          ])}
        >
          <%= if @rows == [] do %>
            <tr>
              <td
                colspan="100"
                class="px-4 py-12 text-center text-sm text-muted-foreground"
              >
                {@empty_message}
              </td>
            </tr>
          <% else %>
            <tr
              :for={row <- @rows}
              class="border-b transition-colors hover:bg-muted/50"
            >
              <td
                :for={col <- @column}
                class={cn(["px-4 py-3 align-middle", dt_align_class(Map.get(col, :align, :left))])}
              >
                {render_slot(col, row)}
              </td>
              <td :if={@action != []} class="px-4 py-3 align-middle text-right">
                <div class="flex items-center justify-end gap-2">
                  {render_slot(@action, row)}
                </div>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp dt_align_class(:left), do: "text-left"
  defp dt_align_class(:right), do: "text-right"
  defp dt_align_class(:center), do: "text-center"
  defp dt_align_class(_), do: "text-left"

  # Returns the NEXT direction as a string (for phx-value round-trip)
  defp dt_next_dir(:none), do: "asc"
  defp dt_next_dir(:asc), do: "desc"
  defp dt_next_dir(:desc), do: "none"

  attr(:dir, :atom, required: true, values: [:none, :asc, :desc])

  defp dt_sort_icon(%{dir: :none} = assigns) do
    ~H"""
    <.icon name="chevrons-up-down" size={:xs} />
    """
  end

  defp dt_sort_icon(%{dir: :asc} = assigns) do
    ~H"""
    <.icon name="chevron-up" size={:xs} />
    """
  end

  defp dt_sort_icon(%{dir: :desc} = assigns) do
    ~H"""
    <.icon name="chevron-down" size={:xs} />
    """
  end
end
