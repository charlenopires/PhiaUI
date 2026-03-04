defmodule PhiaUi.Components.HeatmapCalendar do
  @moduledoc """
  Heatmap calendar grid component for PhiaUI.

  Renders a GitHub-style contribution heatmap — a 2-D grid where each cell's
  colour intensity represents the magnitude of a metric at that position.

  CSS-only — no JS hook required. Fully server-rendered.

  ## When to use

  Common use cases for heatmap grids:

  - **GitHub contribution graph** — activity over 52 weeks × 7 days
  - **Site traffic heatmap** — hour-of-day vs. day-of-week (24 × 7)
  - **Server load matrix** — CPU/memory over time buckets
  - **Sales frequency grid** — products vs. months
  - **Error rate map** — services vs. deployment environments

  ## Intensity levels

  Values are bucketed into 5 levels (0–4) relative to `max_value`.
  Add the following CSS to your stylesheet or `priv/static/theme.css` to apply
  colours (these use the primary token so they respect the active theme):

      .heatmap-0 { background-color: oklch(var(--muted)); }
      .heatmap-1 { background-color: oklch(var(--primary) / 0.2); }
      .heatmap-2 { background-color: oklch(var(--primary) / 0.4); }
      .heatmap-3 { background-color: oklch(var(--primary) / 0.65); }
      .heatmap-4 { background-color: oklch(var(--primary) / 0.9); }

  ## Data format

  Pass a flat list of `%{col: integer, row: integer, value: integer}` maps.
  Positions not present in `data` are treated as value `0` (level 0, empty).

  ## Example — GitHub-style contribution heatmap

      # Build 52 weeks × 7 days of contribution data from the database:
      data =
        Contributions.last_year(user_id)
        |> Enum.map(fn c -> %{col: c.week, row: c.day_of_week, value: c.count} end)

      <.heatmap_calendar
        data={data}
        rows={7}
        cols={52}
        row_labels={~w[Sun Mon Tue Wed Thu Fri Sat]}
        max_value={10}
        show_legend={true}
      />

  ## Example — hourly traffic heatmap (24 hours × 7 days)

      <.heatmap_calendar
        data={@traffic_data}
        rows={7}
        cols={24}
        row_labels={~w[Mon Tue Wed Thu Fri Sat Sun]}
        col_labels={~w[0h 3h 6h 9h 12h 15h 18h 21h]}
        max_value={@peak_traffic}
        show_legend={true}
      />

  ## Accessibility

  The grid uses `role="grid"` on each row container. Each cell uses
  `role="gridcell"` and an `aria-label` describing its position and raw value
  so keyboard users and screen readers can navigate the matrix.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # heatmap_calendar/1
  # ---------------------------------------------------------------------------

  attr(:data, :list,
    default: [],
    doc: """
    List of `%{col: integer, row: integer, value: integer}` maps.
    `col` and `row` are 0-based indices. Positions absent from the list are
    treated as `value: 0` (rendered at intensity level 0).
    """
  )

  attr(:rows, :integer,
    required: true,
    doc: "Number of rows in the grid (e.g. `7` for days of the week)"
  )

  attr(:cols, :integer,
    required: true,
    doc: "Number of columns in the grid (e.g. `52` for weeks in a year, `24` for hours)"
  )

  attr(:max_value, :integer,
    default: 10,
    doc: """
    Maximum expected value used to normalise raw values into intensity buckets 0–4.
    Values at or above `max_value` are clamped to level 4.
    Set this to your 95th-percentile value to avoid a single outlier washing out the rest.
    """
  )

  attr(:col_labels, :list,
    default: nil,
    doc: """
    Optional list of column header strings. For readability, pass a subset —
    not every column needs a label. Length need not match `cols`.
    Example: `~w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec]` for monthly buckets.
    """
  )

  attr(:row_labels, :list,
    default: nil,
    doc: """
    Optional list of row label strings. Length should match `rows`.
    Example: `~w[Sun Mon Tue Wed Thu Fri Sat]` for day-of-week rows.
    """
  )

  attr(:show_legend, :boolean,
    default: false,
    doc: """
    When `true`, renders a small \"Less → More\" intensity legend below the grid.
    Recommended when the colour scale is not self-evident from context.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root wrapper")

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the root div"
  )

  @doc """
  Renders a heatmap calendar grid.

  Builds a `{col, row} => value` lookup map from the `data` list at render time,
  then iterates `rows × cols` to produce a WAI-ARIA grid. Each cell receives
  a `heatmap-{0..4}` CSS class derived from the bucketed intensity.

  The outer `overflow-x-auto` wrapper allows wide grids (e.g. 52 columns) to
  scroll horizontally on narrow screens without breaking the page layout.
  """
  def heatmap_calendar(assigns) do
    # Build a lookup map once up-front so each cell render is O(1).
    # Without this, the inner loop would be O(n) per cell (O(n²) total).
    assigns = assign(assigns, :lookup, build_lookup(assigns.data))

    ~H"""
    <div class={cn(["overflow-x-auto", @class])} {@rest}>
      <%!-- Column labels (optional) — offset left to align with data cells --%>
      <div :if={@col_labels} class="mb-1 flex" style={"padding-left: #{if @row_labels, do: "6rem", else: "0"}"}>
        <span
          :for={label <- @col_labels}
          class="flex-1 text-center text-xs text-muted-foreground"
        >
          {label}
        </span>
      </div>

      <%!-- Grid body --%>
      <div class="flex flex-col gap-1">
        <div
          :for={row <- 0..(@rows - 1)}
          class="flex items-center gap-1"
        >
          <%!-- Row label — fixed width, right-aligned, truncated for long names --%>
          <span
            :if={@row_labels}
            class="w-24 shrink-0 truncate text-right text-xs text-muted-foreground pr-2"
          >
            {Enum.at(@row_labels, row, "")}
          </span>

          <%!-- Data cells for this row --%>
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

      <%!-- Intensity legend — "Less ○○○○○ More" --%>
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

  # Convert the flat list of data points into a {col, row} => value map.
  # This O(n) pass avoids O(n) lookups inside the O(rows*cols) render loop,
  # making the total complexity O(n + rows*cols) instead of O(n * rows*cols).
  defp build_lookup(data) do
    Map.new(data, fn %{col: col, row: row, value: value} -> {{col, row}, value} end)
  end

  # Value of exactly 0 is always level 0 (empty cell), regardless of max_value.
  defp intensity_class(0, _max), do: "heatmap-0"

  # Positive values are bucketed relative to max_value.
  defp intensity_class(value, max) when value > 0 do
    "heatmap-#{bucket(value, max)}"
  end

  # Degenerate case: if max_value is 0 or negative, treat everything as max.
  defp bucket(_value, max) when max <= 0, do: 4

  # Normalise to one of four non-zero buckets (1..4).
  # The thresholds are 25%, 50%, 75%, and 100% of max_value.
  # Values in the bottom quartile still get level 1 (not 0) to stay visible.
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
