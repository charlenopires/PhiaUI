defmodule PhiaUi.Components.HeatmapCalendar do
  @moduledoc """
  Heatmap calendar grid component for PhiaUI.

  Renders a GitHub-style contribution heatmap where each cell represents
  the intensity of a metric at a given row/column position.
  Typical use: time-of-day × day-of-week, CPU/memory heat over time, etc.

  CSS-only — no JS hook required. Server-rendered.

  ## Intensity levels

  Values are bucketed into 5 levels (0–4). Add the following CSS to your
  stylesheet (or `priv/static/theme.css`) to style each level:

      .heatmap-0 { background-color: oklch(var(--muted)); }
      .heatmap-1 { background-color: oklch(var(--primary) / 0.2); }
      .heatmap-2 { background-color: oklch(var(--primary) / 0.4); }
      .heatmap-3 { background-color: oklch(var(--primary) / 0.65); }
      .heatmap-4 { background-color: oklch(var(--primary) / 0.9); }

  ## Sub-components

  - `heatmap_calendar/1` — the complete grid with optional labels and legend

  ## Examples

      <.heatmap_calendar
        data={@platform_events}
        rows={5}
        cols={24}
        row_labels={["container", "dckr_22", "cont_name", "dckr_511", "dckr_67"]}
        col_labels={["2 AM", "6 AM", "10 AM", "2 PM", "6 PM", "10 PM"]}
        max_value={50}
        show_legend={true}
      />

  Where `@platform_events` is a list of `%{col: integer, row: integer, value: integer}`.

  ## Accessibility

  The grid container carries `role="grid"`. Each cell carries `role="gridcell"`
  and an `aria-label` describing its position and value so screen readers can
  navigate the matrix.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # heatmap_calendar/1
  # ---------------------------------------------------------------------------

  attr(:data, :list,
    default: [],
    doc: "List of %{col: integer, row: integer, value: integer} maps"
  )

  attr(:rows, :integer,
    required: true,
    doc: "Number of rows in the grid"
  )

  attr(:cols, :integer,
    required: true,
    doc: "Number of columns in the grid"
  )

  attr(:max_value, :integer,
    default: 10,
    doc: "Maximum expected value — used to normalise intensities into 0–4 buckets"
  )

  attr(:col_labels, :list,
    default: nil,
    doc: "Optional list of column header strings (length should match cols)"
  )

  attr(:row_labels, :list,
    default: nil,
    doc: "Optional list of row label strings (length should match rows)"
  )

  attr(:show_legend, :boolean,
    default: false,
    doc: "Whether to render the intensity legend below the grid"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root wrapper")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root div")

  @doc """
  Renders a heatmap calendar grid.

  Builds a lookup map from the `data` list and iterates over rows × cols to
  produce a WAI-ARIA grid. Each cell gets a `heatmap-{0..4}` class and an
  `aria-label` combining its position and value.
  """
  def heatmap_calendar(assigns) do
    assigns = assign(assigns, :lookup, build_lookup(assigns.data))

    ~H"""
    <div class={cn(["overflow-x-auto", @class])} {@rest}>
      <%!-- Column labels --%>
      <div :if={@col_labels} class="mb-1 flex" style={"padding-left: #{if @row_labels, do: "6rem", else: "0"}"}>
        <span
          :for={label <- @col_labels}
          class="flex-1 text-center text-xs text-muted-foreground"
        >
          {label}
        </span>
      </div>

      <%!-- Grid --%>
      <div class="flex flex-col gap-1">
        <div
          :for={row <- 0..(@rows - 1)}
          class="flex items-center gap-1"
        >
          <%!-- Row label --%>
          <span
            :if={@row_labels}
            class="w-24 shrink-0 truncate text-right text-xs text-muted-foreground pr-2"
          >
            {Enum.at(@row_labels, row, "")}
          </span>

          <%!-- Grid row --%>
          <div role="grid" aria-label={"Row #{row + 1}"} class="flex flex-1 gap-1">
            <div
              :for={col <- 0..(@cols - 1)}
              role="gridcell"
              aria-label={"Col #{col + 1}, Row #{row + 1}: #{Map.get(@lookup, {col, row}, 0)}"}
              class={cn([
                "h-5 flex-1 rounded-sm",
                intensity_class(Map.get(@lookup, {col, row}, 0), @max_value)
              ])}
            />
          </div>
        </div>
      </div>

      <%!-- Legend --%>
      <div :if={@show_legend} class="heatmap-legend mt-3 flex items-center gap-2">
        <span class="text-xs text-muted-foreground">Less</span>
        <div :for={level <- 0..4} class={cn(["h-3 w-3 rounded-sm", "heatmap-#{level}"])} />
        <span class="text-xs text-muted-foreground">More</span>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp build_lookup(data) do
    Map.new(data, fn %{col: col, row: row, value: value} -> {{col, row}, value} end)
  end

  defp intensity_class(0, _max), do: "heatmap-0"

  defp intensity_class(value, max) when value > 0 do
    "heatmap-#{bucket(value, max)}"
  end

  defp bucket(_value, max) when max <= 0, do: 4

  defp bucket(value, max) do
    cond do
      value >= max -> 4
      value >= max * 3 / 4 -> 3
      value >= max / 2 -> 2
      value >= max / 4 -> 1
      true -> 1
    end
  end
end
