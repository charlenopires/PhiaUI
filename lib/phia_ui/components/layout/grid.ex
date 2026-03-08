defmodule PhiaUi.Components.Layout.Grid do
  @moduledoc """
  CSS Grid container with column, row, gap and auto-flow control.

  All layout attributes accept either a plain value (backward compatible) or a
  responsive map like `%{base: 1, md: 3}` for per-breakpoint control.

  ## Examples

      <%!-- 3-column grid with gap --%>
      <.grid cols={3} gap={4}>
        <.card>A</.card>
        <.card>B</.card>
        <.card>C</.card>
      </.grid>

      <%!-- Responsive columns: 1 on mobile, 2 from md, 4 from lg --%>
      <.grid cols={%{base: 1, md: 2, lg: 4}} gap={%{base: 2, md: 4}}>
        <.card>A</.card>
        <.card>B</.card>
        <.card>C</.card>
        <.card>D</.card>
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
  import PhiaUi.ResponsiveHelpers, only: [resolve_responsive: 2]

  attr(:cols, :any, default: nil, doc: "Number of columns (1–12) → `grid-cols-N`. Accepts integer or responsive map.")
  attr(:rows, :any, default: nil, doc: "Number of rows (1–6) → `grid-rows-N`. Accepts integer or responsive map.")
  attr(:gap, :any, default: nil, doc: "Uniform gap (0–12) → `gap-N`. Accepts integer or responsive map.")
  attr(:gap_x, :any, default: nil, doc: "Horizontal gap → `gap-x-N`. Accepts integer or responsive map.")
  attr(:gap_y, :any, default: nil, doc: "Vertical gap → `gap-y-N`. Accepts integer or responsive map.")

  attr(:flow, :any,
    default: nil,
    doc: "Grid auto-flow direction. Accepts atom or responsive map."
  )

  attr(:align, :any,
    default: nil,
    doc: "align-items value. Accepts atom or responsive map."
  )

  attr(:justify, :any,
    default: nil,
    doc: "justify-items value. Accepts atom or responsive map."
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
        responsive(@cols, &cols_class/1),
        responsive(@rows, &rows_class/1),
        responsive(@gap, &gap_class/1),
        responsive(@gap_x, &gap_x_class/1),
        responsive(@gap_y, &gap_y_class/1),
        responsive(@flow, &flow_class/1),
        responsive(@align, &align_class/1),
        responsive(@justify, &justify_class/1),
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp responsive(value, mapper) do
    resolve_responsive(value, mapper)
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
    |> case do
      "" -> nil
      s -> s
    end
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
