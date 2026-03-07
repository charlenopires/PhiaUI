defmodule PhiaUi.Components.PivotTable do
  @moduledoc """
  Cross-tabulation (pivot) table — rows × columns matrix display.

  Renders a data matrix where row headers and column headers define the axes,
  and `data` provides the values at each intersection. Supports optional
  heatmap coloring, value formatting, and row/column totals.

  ## Sub-components

  | Function           | HTML element | Purpose                                    |
  |--------------------|--------------|---------------------------------------------|
  | `pivot_table/1`    | `<table>`    | Full matrix table with optional totals      |
  | `pivot_cell/1`     | `<td>`       | Data cell with optional heatmap background  |
  | `pivot_row_header/1`| `<th>`      | Sticky first-column row label               |

  ## Data format

  The `data` attr accepts either:

  - **Map** keyed by `{row_key, col_key}` tuples:
    ```elixir
    %{
      {"north", "q1"} => 1200,
      {"north", "q2"} => 1450,
      {"south", "q1"} => 980,
    }
    ```

  - **Function** `fn row_key, col_key -> value end`:
    ```elixir
    fn region, quarter -> Stats.revenue(region, quarter) end
    ```

  Missing keys return `0` for maps or `nil` for functions.

  ## Example

      <.pivot_table
        row_headers={[
          %{key: "north", label: "North"},
          %{key: "south", label: "South"},
          %{key: "east", label: "East"},
        ]}
        col_headers={[
          %{key: "q1", label: "Q1"},
          %{key: "q2", label: "Q2"},
          %{key: "q3", label: "Q3"},
          %{key: "q4", label: "Q4"},
        ]}
        data={@revenue_map}
        format={:currency}
        heatmap
        row_totals
        col_totals
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # pivot_table/1
  # ---------------------------------------------------------------------------

  attr(:row_headers, :list,
    required: true,
    doc: "List of `%{key: any, label: string}` maps defining the row axis"
  )

  attr(:col_headers, :list,
    required: true,
    doc: "List of `%{key: any, label: string}` maps defining the column axis"
  )

  attr(:data, :any,
    required: true,
    doc: """
    Data source. Either a map keyed by `{row_key, col_key}` tuples, or a
    function `fn row_key, col_key -> value end`.
    """
  )

  attr(:heatmap, :boolean,
    default: false,
    doc: """
    When `true`, cells are coloured with a `primary` intensity scale based on
    their relative value within the min–max range of all cells.
    """
  )

  attr(:format, :atom,
    default: :default,
    values: [:default, :percent, :currency, :number],
    doc: """
    Value formatting:
    - `:default` — `to_string/1`
    - `:number` — plain numeric string
    - `:percent` — appends `%` with one decimal place
    - `:currency` — prepends `$` with two decimal places
    """
  )

  attr(:row_totals, :boolean,
    default: false,
    doc: "When `true`, appends a totals column on the right"
  )

  attr(:col_totals, :boolean,
    default: false,
    doc: "When `true`, appends a totals row at the bottom"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the outer wrapper div")

  @doc """
  Renders a full cross-tabulation matrix table.

  The first column (`pivot_row_header/1`) is `position: sticky; left: 0` so
  it stays visible when the table scrolls horizontally. All cells use
  `tabular-nums` for aligned numeric values.

  ## Example

      <.pivot_table
        row_headers={@regions}
        col_headers={@quarters}
        data={@revenue_map}
        format={:currency}
        heatmap
        row_totals
      />
  """
  def pivot_table(assigns) do
    assigns = pt_assign_heatmap_bounds(assigns)

    ~H"""
    <div class={cn(["overflow-auto", @class])}>
      <table class="w-full caption-bottom text-sm border-collapse">
        <thead>
          <tr>
            <%!-- Empty corner cell --%>
            <th class="sticky left-0 z-20 bg-background px-4 py-3 text-left text-xs font-medium text-muted-foreground uppercase tracking-wider border-b border-r border-border">
            </th>
            <th
              :for={col <- @col_headers}
              class="px-4 py-3 text-right text-xs font-medium text-muted-foreground uppercase tracking-wider border-b border-border whitespace-nowrap"
            >
              {col.label}
            </th>
            <th
              :if={@row_totals}
              class="px-4 py-3 text-right text-xs font-medium text-muted-foreground uppercase tracking-wider border-b border-l border-border"
            >
              Total
            </th>
          </tr>
        </thead>
        <tbody>
          <tr :for={row <- @row_headers} class="border-b border-border hover:bg-muted/30 transition-colors">
            <.pivot_row_header label={row.label} />
            <.pivot_cell
              :for={col <- @col_headers}
              value={pt_cell_value(@data, row.key, col.key)}
              formatted={pt_format_value(pt_cell_value(@data, row.key, col.key), @format)}
              heatmap_class={
                if @heatmap,
                  do: pt_heatmap_class(pt_cell_value(@data, row.key, col.key), @min_val, @max_val),
                  else: nil
              }
            />
            <.pivot_cell
              :if={@row_totals}
              value={pt_row_total(@data, row.key, @col_headers)}
              formatted={pt_format_value(pt_row_total(@data, row.key, @col_headers), @format)}
              heatmap_class={nil}
              class="border-l border-border font-medium"
            />
          </tr>
          <%!-- Column totals row --%>
          <tr :if={@col_totals} class="border-t-2 border-border bg-muted/20 font-medium">
            <th
              scope="row"
              class="sticky left-0 bg-muted/20 px-4 py-3 text-left text-sm font-medium text-foreground"
            >
              Total
            </th>
            <.pivot_cell
              :for={col <- @col_headers}
              value={pt_col_total(@data, col.key, @row_headers)}
              formatted={pt_format_value(pt_col_total(@data, col.key, @row_headers), @format)}
              heatmap_class={nil}
              class="font-medium"
            />
            <.pivot_cell
              :if={@row_totals}
              value={pt_grand_total(@data, @row_headers, @col_headers)}
              formatted={pt_format_value(pt_grand_total(@data, @row_headers, @col_headers), @format)}
              heatmap_class={nil}
              class="border-l border-border font-semibold"
            />
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # pivot_cell/1
  # ---------------------------------------------------------------------------

  attr(:value, :any, required: true, doc: "Raw cell value (number, string, or nil)")

  attr(:formatted, :string,
    default: nil,
    doc: "Pre-formatted display string. If `nil`, falls back to `to_string(@value)`."
  )

  attr(:heatmap_class, :any,
    default: nil,
    doc: "Optional Tailwind background class for heatmap intensity (e.g. `\"bg-primary/40\"`)"
  )

  attr(:align, :atom,
    default: :right,
    values: [:left, :right, :center],
    doc: "Text alignment — defaults to `:right` for numeric data"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the `<td>`")

  @doc """
  Renders a single pivot table data cell.

  Uses `tabular-nums` font variant for aligned numeric values. Accepts an
  optional `heatmap_class` for background intensity colouring.

  ## Example

      <.pivot_cell
        value={1450}
        formatted="$1,450"
        heatmap_class="bg-primary/40"
      />
  """
  def pivot_cell(assigns) do
    ~H"""
    <td
      class={cn([
        "px-4 py-3 align-middle tabular-nums",
        pt_align_class(@align),
        @heatmap_class,
        @class
      ])}
    >
      {@formatted || to_string(@value || "")}
    </td>
    """
  end

  # ---------------------------------------------------------------------------
  # pivot_row_header/1
  # ---------------------------------------------------------------------------

  attr(:label, :string, required: true, doc: "Row label text for the sticky first column")

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the `<th>`")

  @doc """
  Renders the sticky first-column row header cell.

  Uses `position: sticky; left: 0` via Tailwind's `sticky left-0` utilities,
  with `bg-background` to cover scrolled content. `whitespace-nowrap` prevents
  label wrapping that would grow the column unpredictably.

  ## Example

      <.pivot_row_header label="North America" />
  """
  def pivot_row_header(assigns) do
    ~H"""
    <th
      scope="row"
      class={cn([
        "sticky left-0 bg-background px-4 py-3 text-left text-sm font-medium text-foreground whitespace-nowrap border-r border-border",
        @class
      ])}
    >
      {@label}
    </th>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp pt_align_class(:right), do: "text-right"
  defp pt_align_class(:left), do: "text-left"
  defp pt_align_class(:center), do: "text-center"
  defp pt_align_class(_), do: "text-right"

  defp pt_cell_value(data, row_key, col_key) when is_function(data, 2),
    do: data.(row_key, col_key)

  defp pt_cell_value(data, row_key, col_key) when is_map(data),
    do: Map.get(data, {row_key, col_key}, 0)

  defp pt_cell_value(_data, _row_key, _col_key), do: nil

  defp pt_format_value(nil, _format), do: "-"
  defp pt_format_value(val, :default), do: to_string(val)
  defp pt_format_value(val, :number) when is_number(val), do: to_string(val)

  defp pt_format_value(val, :percent) when is_number(val) do
    "#{Float.round(val * 1.0, 1)}%"
  end

  defp pt_format_value(val, :currency) when is_number(val) do
    "$#{Float.round(val * 1.0, 2)}"
  end

  defp pt_format_value(val, _format), do: to_string(val)

  defp pt_heatmap_class(nil, _min, _max), do: nil
  defp pt_heatmap_class(_val, min, max) when min == max, do: "bg-primary/20"

  defp pt_heatmap_class(val, min, max) when is_number(val) do
    pct = (val - min) / (max - min)

    cond do
      pct < 0.2 -> "bg-primary/10"
      pct < 0.4 -> "bg-primary/20"
      pct < 0.6 -> "bg-primary/40"
      pct < 0.8 -> "bg-primary/60"
      true -> "bg-primary/80 text-primary-foreground"
    end
  end

  defp pt_heatmap_class(_val, _min, _max), do: nil

  defp pt_assign_heatmap_bounds(%{heatmap: true} = assigns) do
    all_vals =
      for r <- assigns.row_headers, c <- assigns.col_headers do
        pt_cell_value(assigns.data, r.key, c.key)
      end

    nums = Enum.filter(all_vals, &is_number/1)
    min_val = if nums == [], do: 0, else: Enum.min(nums)
    max_val = if nums == [], do: 0, else: Enum.max(nums)
    assign(assigns, min_val: min_val, max_val: max_val)
  end

  defp pt_assign_heatmap_bounds(assigns),
    do: assign(assigns, min_val: 0, max_val: 0)

  defp pt_row_total(data, row_key, col_headers) do
    Enum.reduce(col_headers, 0, fn col, acc ->
      val = pt_cell_value(data, row_key, col.key)
      if is_number(val), do: acc + val, else: acc
    end)
  end

  defp pt_col_total(data, col_key, row_headers) do
    Enum.reduce(row_headers, 0, fn row, acc ->
      val = pt_cell_value(data, row.key, col_key)
      if is_number(val), do: acc + val, else: acc
    end)
  end

  defp pt_grand_total(data, row_headers, col_headers) do
    Enum.reduce(row_headers, 0, fn row, acc ->
      acc + pt_row_total(data, row.key, col_headers)
    end)
  end
end
