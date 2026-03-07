defmodule PhiaUi.Components.Layout.Grid do
  @moduledoc """
  CSS Grid container with column, row, gap and auto-flow control.

  ## Examples

      <%!-- 3-column grid with gap --%>
      <.grid cols={3} gap={4}>
        <.card>A</.card>
        <.card>B</.card>
        <.card>C</.card>
      </.grid>

      <%!-- 12-column layout grid --%>
      <.grid cols={12} gap={4}>
        <div class="col-span-8">Main</div>
        <div class="col-span-4">Sidebar</div>
      </.grid>

      <%!-- Dense auto-flow --%>
      <.grid cols={4} gap={3} flow={:dense}>
        <%= for item <- @items do %>
          <.card>{item.title}</.card>
        <% end %>
      </.grid>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:cols, :integer, default: nil, doc: "Number of columns (1–12) → `grid-cols-N`.")
  attr(:rows, :integer, default: nil, doc: "Number of rows (1–6) → `grid-rows-N`.")
  attr(:gap, :integer, default: nil, doc: "Uniform gap (0–12) → `gap-N`.")
  attr(:gap_x, :integer, default: nil, doc: "Horizontal gap → `gap-x-N`.")
  attr(:gap_y, :integer, default: nil, doc: "Vertical gap → `gap-y-N`.")

  attr(:flow, :atom,
    default: nil,
    values: [nil, :row, :col, :dense, :row_dense, :col_dense],
    doc: "Grid auto-flow direction."
  )

  attr(:align, :atom,
    default: nil,
    values: [nil, :start, :center, :end, :stretch],
    doc: "align-items value."
  )

  attr(:justify, :atom,
    default: nil,
    values: [nil, :start, :center, :end, :between, :around, :evenly],
    doc: "justify-items value."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element.")

  slot(:inner_block, required: true, doc: "Grid children.")

  @doc "Renders a CSS Grid container."
  def grid(assigns) do
    ~H"""
    <div
      class={cn([
        "grid",
        cols_class(@cols),
        rows_class(@rows),
        gap_class(@gap),
        gap_x_class(@gap_x),
        gap_y_class(@gap_y),
        flow_class(@flow),
        align_class(@align),
        justify_class(@justify),
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp cols_class(nil), do: nil
  defp cols_class(n), do: "grid-cols-#{n}"

  defp rows_class(nil), do: nil
  defp rows_class(n), do: "grid-rows-#{n}"

  defp gap_class(nil), do: nil
  defp gap_class(n), do: "gap-#{n}"

  defp gap_x_class(nil), do: nil
  defp gap_x_class(n), do: "gap-x-#{n}"

  defp gap_y_class(nil), do: nil
  defp gap_y_class(n), do: "gap-y-#{n}"

  defp flow_class(nil), do: nil
  defp flow_class(:row), do: "grid-flow-row"
  defp flow_class(:col), do: "grid-flow-col"
  defp flow_class(:dense), do: "grid-flow-dense"
  defp flow_class(:row_dense), do: "grid-flow-row-dense"
  defp flow_class(:col_dense), do: "grid-flow-col-dense"

  defp align_class(nil), do: nil
  defp align_class(:start), do: "items-start"
  defp align_class(:center), do: "items-center"
  defp align_class(:end), do: "items-end"
  defp align_class(:stretch), do: "items-stretch"

  defp justify_class(nil), do: nil
  defp justify_class(:start), do: "justify-items-start"
  defp justify_class(:center), do: "justify-items-center"
  defp justify_class(:end), do: "justify-items-end"
  defp justify_class(:between), do: "justify-items-stretch"
  defp justify_class(:around), do: "justify-items-stretch"
  defp justify_class(:evenly), do: "justify-items-stretch"
end
