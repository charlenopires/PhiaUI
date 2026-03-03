defmodule PhiaUi.Components.Chart do
  @moduledoc """
  Chart integration component with PhiaChart vanilla JS hook.

  Renders a container div wired to the `PhiaChart` hook, which initialises
  Apache ECharts (or Chart.js as fallback) in the browser. Chart options are
  passed as JSON via `data-config` and `data-series` HTML attributes so the
  component itself is pure server-side HEEx.

  ## Example

      <.phia_chart
        id="revenue-chart"
        type={:area}
        title="Revenue"
        description="Last 12 months"
        series={[%{name: "MRR", data: [10, 20, 30, 25, 40]}]}
        labels={["Jan", "Feb", "Mar", "Apr", "May"]}
        height="350px"
      />

  ## LiveView update

      push_event(socket, "update-chart-revenue-chart", %{
        series: [%{name: "MRR", data: [50, 60, 70]}]
      })

  ## Setup

  Copy the hook with `mix phia.add chart` and register it:

      import PhiaChart from "./hooks/chart"
      let liveSocket = new LiveSocket("/live", Socket, {hooks: {PhiaChart}})

  Install ECharts: `npm install echarts` or load from CDN.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.ChartShell, only: [chart_shell: 1]

  attr :id, :string, required: true, doc: "Unique ID — also used for push_event targeting"

  attr :type, :atom,
    default: :line,
    values: [:line, :bar, :pie, :area],
    doc: "Chart type"

  attr :series, :list, default: [], doc: "List of series maps, e.g. [%{name: ..., data: [...]}]"
  attr :labels, :list, default: [], doc: "X-axis category labels"
  attr :height, :string, default: "300px", doc: "CSS height of the chart container"
  attr :title, :string, default: nil, doc: "When set, wraps the chart in a ChartShell card"
  attr :description, :string, default: nil, doc: "Description shown in ChartShell header"
  attr :class, :string, default: nil, doc: "Additional CSS classes"
  attr :rest, :global

  @doc "Renders a chart container wired to the PhiaChart hook."
  def phia_chart(assigns) do
    assigns =
      assigns
      |> assign(:config_json, Jason.encode!(build_config(assigns.type, assigns.labels)))
      |> assign(:series_json, Jason.encode!(assigns.series))

    ~H"""
    <%= if @title do %>
      <.chart_shell title={@title} description={@description} min_height={@height} class={@class} {@rest}>
        <.chart_canvas id={@id} config_json={@config_json} series_json={@series_json} height={@height} />
      </.chart_shell>
    <% else %>
      <.chart_canvas id={@id} config_json={@config_json} series_json={@series_json} height={@height} class={@class} {@rest} />
    <% end %>
    """
  end

  # ---------------------------------------------------------------------------
  # Private: chart canvas sub-component
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :config_json, :string, required: true
  attr :series_json, :string, required: true
  attr :height, :string, required: true
  attr :class, :string, default: nil
  attr :rest, :global

  defp chart_canvas(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaChart"
      data-config={@config_json}
      data-series={@series_json}
      data-chart-placeholder="Loading chart…"
      class={cn(["w-full", @class])}
      style={"height: #{@height}"}
      {@rest}
    >
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers: build ECharts config from type + labels
  # ---------------------------------------------------------------------------

  defp build_config(:pie, labels) do
    %{
      "tooltip" => %{"trigger" => "item"},
      "legend" => %{"orient" => "horizontal", "bottom" => "bottom"},
      "series" => [
        %{
          "type" => "pie",
          "radius" => "60%",
          "data" => Enum.map(labels, &%{"name" => &1, "value" => 0})
        }
      ]
    }
  end

  defp build_config(type, labels) do
    series_type = chart_type_str(type)

    series_config =
      case type do
        :area -> %{"type" => series_type, "areaStyle" => %{}}
        _ -> %{"type" => series_type}
      end

    %{
      "tooltip" => %{"trigger" => "axis"},
      "xAxis" => %{"type" => "category", "data" => labels},
      "yAxis" => %{"type" => "value"},
      "series" => [series_config]
    }
  end

  defp chart_type_str(:line), do: "line"
  defp chart_type_str(:bar), do: "bar"
  defp chart_type_str(:area), do: "line"
end
