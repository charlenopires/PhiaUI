defmodule PhiaUi.Components.Chart do
  @moduledoc """
  Chart integration component powered by the `PhiaChart` vanilla JS hook.

  `phia_chart/1` renders a container `<div>` wired to the `PhiaChart` hook,
  which initialises **Apache ECharts** (or **Chart.js** as a fallback) in the
  browser. Chart options and series data are passed as JSON via `data-config`
  and `data-series` HTML attributes — the component itself is pure server-side
  HEEx with zero client-side Elixir knowledge.

  ## Architecture

  The hook detects which library is loaded:

      window.echarts   → uses Apache ECharts
      window.Chart     → falls back to Chart.js

  Chart configuration is split into two attributes:

  - `data-config` — ECharts option object (axes, tooltip, series type). Built
    server-side from `:type` and `:labels` by `build_config/2`.
  - `data-series` — array of series objects `[%{name: ..., data: [...]}]`.
    Passed as-is via `Jason.encode!/1`.

  This split allows the hook to merge updated series data without replacing
  the entire chart configuration on `push_event`.

  ## Chart types

  | `:type`  | ECharts series type | Notes                                      |
  |----------|---------------------|--------------------------------------------|
  | `:line`  | `"line"`            | Standard line chart                        |
  | `:bar`   | `"bar"`             | Vertical bar / column chart                |
  | `:area`  | `"line"` + area     | Line chart with `areaStyle: {}` fill       |
  | `:pie`   | `"pie"`             | Pie/donut; labels become data point names  |

  ## Basic example

      <.phia_chart
        id="revenue-chart"
        type={:area}
        title="Monthly Revenue"
        description="Last 12 months"
        series={[%{name: "MRR", data: [10_000, 12_500, 11_800, 14_200, 15_600]}]}
        labels={["Jan", "Feb", "Mar", "Apr", "May"]}
        height="350px"
      />

  ## Without ChartShell wrapper

  Omit `:title` and `:description` to render only the raw chart canvas, useful
  when embedding inside an existing card or layout:

      <.phia_chart
        id="sparkline"
        type={:line}
        series={[%{name: "Sessions", data: @daily_sessions}]}
        labels={@day_labels}
        height="80px"
        class="w-full"
      />

  ## Multiple series

      <.phia_chart
        id="acquisition-chart"
        type={:bar}
        title="User Acquisition"
        series={[
          %{name: "Organic",  data: [120, 145, 132, 178, 201]},
          %{name: "Paid",     data: [80,  95,  110, 88,  130]},
          %{name: "Referral", data: [30,  28,  45,  52,  40]}
        ]}
        labels={["Jan", "Feb", "Mar", "Apr", "May"]}
        height="400px"
      />

  ## Pie chart

  For pie charts, `labels` become the data point names and `series` should
  provide a single series whose `data` values correspond positionally to labels:

      <.phia_chart
        id="traffic-sources"
        type={:pie}
        title="Traffic Sources"
        series={[%{name: "Sources", data: [45, 30, 15, 10]}]}
        labels={["Organic", "Direct", "Referral", "Social"]}
        height="300px"
      />

  ## Live updates via push_event

  Send updated series data from the server without a full re-render. The hook
  listens for `"update-chart-{id}"` events:

      # In your LiveView handle_info or handle_event:
      socket = push_event(socket, "update-chart-revenue-chart", %{
        series: [%{name: "MRR", data: [50_000, 55_000, 62_000]}]
      })

  The hook calls `chart.setOption/1` with a merge, so static configuration
  (colors, axis formatting, tooltip) is preserved.

  ## Dark mode

  PhiaChart listens for the `phia:theme-changed` custom DOM event (fired by
  the `PhiaDarkMode` hook). When the event fires, the hook re-initialises the
  chart with ECharts' dark theme applied automatically.

  ## Setup

  1. Copy the hook with `mix phia.add chart` (or copy manually from
     `priv/templates/js/hooks/chart.js`).

  2. Register the hook in your `app.js`:

         import PhiaChart from "./hooks/chart"
         let liveSocket = new LiveSocket("/live", Socket, {
           hooks: { PhiaChart }
         })

  3. Install ECharts (recommended):

         npm install echarts

     Or load from CDN in `root.html.heex`:

         <script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.ChartShell, only: [chart_shell: 1]

  attr(:id, :string,
    required: true,
    doc: """
    Unique element ID for the chart container. Also used as the suffix for
    `push_event` targeting: to update this chart from the server, send
    `push_event(socket, "update-chart-{id}", %{series: [...]})`.
    """
  )

  attr(:type, :atom,
    default: :line,
    values: [:line, :bar, :pie, :area],
    doc: """
    Chart type. Controls the ECharts series type and the base config generated
    by `build_config/2`. See the module docs for the full type matrix.
    """
  )

  attr(:series, :list,
    default: [],
    doc: """
    List of series maps. Each map must have at least a `"data"` key (list of
    values). A `"name"` key is recommended for tooltips and legends:

        [%{name: "Revenue", data: [100, 200, 150]},
         %{name: "Costs",   data: [80, 120, 90]}]

    For pie charts, `data` values correspond positionally to `labels`.
    """
  )

  attr(:labels, :list,
    default: [],
    doc: """
    X-axis category labels (or pie slice names for `:pie` charts). Must match
    the length of each series' `data` list:

        labels={["Jan", "Feb", "Mar", "Apr", "May"]}
    """
  )

  attr(:height, :string,
    default: "300px",
    doc: """
    CSS height of the chart container. Accepts any CSS length: `"300px"`,
    `"20rem"`, `"50vh"`. The chart hook reads this from the container's
    computed style to size the ECharts instance correctly.
    """
  )

  attr(:title, :string,
    default: nil,
    doc: """
    When provided, wraps the chart in a `chart_shell/1` card with this title
    in the header. When `nil`, renders only the raw chart canvas (no card wrapper).
    """
  )

  attr(:description, :string,
    default: nil,
    doc: """
    Optional description shown in the `chart_shell` header below the title.
    Only relevant when `:title` is also provided. Ignored when `:title` is nil.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the chart container")

  attr(:rest, :global, doc: "HTML attributes forwarded to the chart container or card element")

  @doc """
  Renders a chart container wired to the `PhiaChart` hook.

  If `:title` is provided, the chart is wrapped in a `chart_shell/1` card.
  Otherwise, the raw `<div phx-hook="PhiaChart">` is rendered directly.

  Chart options are encoded to JSON at render time via `Jason.encode!/1` and
  stored in `data-config` and `data-series` attributes. The hook reads these
  attributes on mount to initialise the chart.

  ## Example (with card shell)

      <.phia_chart
        id="mrr"
        type={:area}
        title="MRR"
        series={[%{name: "Revenue", data: @mrr_data}]}
        labels={@month_labels}
        height="350px"
      />

  ## Example (raw canvas)

      <.phia_chart
        id="sparkline-mrr"
        type={:line}
        series={[%{name: "MRR", data: @sparkline}]}
        labels={@sparkline_labels}
        height="60px"
      />
  """
  def phia_chart(assigns) do
    # Encode chart configuration server-side to avoid sending Elixir terms to
    # the hook. Jason is available as a transitive Phoenix dependency (>= 1.4).
    assigns =
      assigns
      |> assign(:config_json, Jason.encode!(build_config(assigns.type, assigns.labels)))
      |> assign(:series_json, Jason.encode!(assigns.series))

    ~H"""
    <%= if @title do %>
      <%!-- Wrap in ChartShell card when a title is provided --%>
      <.chart_shell title={@title} description={@description} min_height={@height} class={@class} {@rest}>
        <.chart_canvas id={@id} config_json={@config_json} series_json={@series_json} height={@height} />
      </.chart_shell>
    <% else %>
      <%!-- No title = raw canvas only, no card wrapper — useful for sparklines or embedded charts --%>
      <.chart_canvas id={@id} config_json={@config_json} series_json={@series_json} height={@height} description={@description} class={@class} {@rest} />
    <% end %>
    """
  end

  # ---------------------------------------------------------------------------
  # Private: chart canvas sub-component
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true)
  attr(:config_json, :string, required: true)
  attr(:series_json, :string, required: true)
  attr(:height, :string, required: true)
  attr(:description, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  # Renders the actual hook target element.  The hook reads:
  #   data-config  → base ECharts option (axes, tooltip, series type)
  #   data-series  → array of {name, data} objects merged into the config
  # Height is set via inline style so the ECharts instance can read the
  # container's clientHeight on mount without a layout thrash.
  defp chart_canvas(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaChart"
      data-config={@config_json}
      data-series={@series_json}
      data-chart-placeholder="Loading chart…"
      role="img"
      class={cn(["w-full", @class])}
      style={"height: #{@height}"}
      {@rest}
    >
      <p :if={@description} class="sr-only">{@description}</p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers: build ECharts option from type + labels
  # ---------------------------------------------------------------------------

  # Pie charts have a completely different config structure: no xAxis/yAxis,
  # a legend at the bottom, and data embedded directly in the series rather
  # than referenced from xAxis categories. Labels become slice names.
  defp build_config(:pie, labels) do
    %{
      "tooltip" => %{"trigger" => "item"},
      "legend" => %{"orient" => "horizontal", "bottom" => "bottom"},
      "series" => [
        %{
          "type" => "pie",
          "radius" => "60%",
          # Pre-populate data with zero values so the hook can merge real data
          # without needing to reconstruct the label list client-side
          "data" => Enum.map(labels, &%{"name" => &1, "value" => 0})
        }
      ]
    }
  end

  # Line, bar, and area charts share the same xAxis/yAxis/tooltip structure.
  # The only difference is the series type (and areaStyle for :area).
  defp build_config(type, labels) do
    series_type = chart_type_str(type)

    # Area charts are ECharts "line" type with areaStyle: {} to fill below the line
    series_config =
      case type do
        :area -> %{"type" => series_type, "areaStyle" => %{}}
        _ -> %{"type" => series_type}
      end

    %{
      "tooltip" => %{"trigger" => "axis"},
      "xAxis" => %{"type" => "category", "data" => labels},
      "yAxis" => %{"type" => "value"},
      # Placeholder series — the hook replaces this with the real series data
      "series" => [series_config]
    }
  end

  # Map PhiaUI chart type atoms to ECharts series type strings.
  # :area maps to "line" because ECharts uses the same series type with
  # an areaStyle property to fill the region below the line.
  defp chart_type_str(:line), do: "line"
  defp chart_type_str(:bar), do: "bar"
  defp chart_type_str(:area), do: "line"
end
