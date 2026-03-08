defmodule PhiaUi.Components.Data.ChartToolbox do
  @moduledoc """
  Chart utilities toolbar.

  Inspired by eCharts `toolbox` — provides a button group with common chart
  utilities: download SVG, reset zoom, toggle series visibility.

  Uses `Phoenix.LiveView.JS` for client-side interactions (no custom JS hooks).

  ## Examples

      <.chart_toolbox
        chart_id="my-chart"
        tools={[:download, :reset]}
      />

      <.chart_toolbox
        chart_id="revenue-chart"
        tools={[:toggle_series]}
        all_series={["Revenue", "Cost", "Profit"]}
        visible_series={["Revenue", "Cost"]}
        on_toggle_series="toggle-series"
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias Phoenix.LiveView.JS

  attr :chart_id, :string, required: true, doc: "ID of the target chart SVG container."

  attr :tools, :list,
    default: [:download, :reset, :toggle_series],
    doc: "List of tools to show. Options: :download, :reset, :toggle_series"

  attr :visible_series, :list, default: [], doc: "Currently visible series names."
  attr :all_series, :list, default: [], doc: "All available series names."
  attr :on_toggle_series, :string, default: nil, doc: "Event name for series toggle."
  attr :on_reset_zoom, :string, default: nil, doc: "Event name for zoom reset."
  attr :position, :atom, default: :top_right, values: [:top_right, :top_left, :bottom_right, :bottom_left], doc: "Toolbar position."
  attr :class, :string, default: nil
  attr :rest, :global

  def chart_toolbox(assigns) do
    position_class =
      case assigns.position do
        :top_right -> "top-0 right-0"
        :top_left -> "top-0 left-0"
        :bottom_right -> "bottom-0 right-0"
        :bottom_left -> "bottom-0 left-0"
      end

    assigns = assign(assigns, :position_class, position_class)

    ~H"""
    <div
      class={cn(["absolute flex items-center gap-0.5 z-10", @position_class, @class])}
      role="toolbar"
      aria-label="Chart tools"
      {@rest}
    >
      <%!-- Download SVG button --%>
      <button
        :if={:download in @tools}
        type="button"
        class="inline-flex items-center justify-center size-7 rounded-md text-muted-foreground hover:text-foreground hover:bg-muted/80 transition-colors"
        aria-label="Download chart"
        phx-click={JS.dispatch("phia:chart-download", to: "##{@chart_id}")}
        title="Download SVG"
      >
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="size-3.5">
          <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
          <polyline points="7 10 12 15 17 10" />
          <line x1="12" y1="15" x2="12" y2="3" />
        </svg>
      </button>

      <%!-- Reset zoom button --%>
      <button
        :if={:reset in @tools}
        type="button"
        class="inline-flex items-center justify-center size-7 rounded-md text-muted-foreground hover:text-foreground hover:bg-muted/80 transition-colors"
        aria-label="Reset zoom"
        phx-click={if @on_reset_zoom, do: @on_reset_zoom, else: JS.dispatch("phia:chart-reset", to: "##{@chart_id}")}
        title="Reset zoom"
      >
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="size-3.5">
          <path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8" />
          <path d="M3 3v5h5" />
        </svg>
      </button>

      <%!-- Toggle series buttons --%>
      <div :if={:toggle_series in @tools && @all_series != []} class="flex items-center gap-0.5 ml-1">
        <button
          :for={series_name <- @all_series}
          type="button"
          class={cn([
            "inline-flex items-center gap-1 px-1.5 py-0.5 rounded text-xs transition-colors",
            if(series_name in @visible_series,
              do: "text-foreground",
              else: "text-muted-foreground/50 line-through"
            )
          ])}
          aria-label={"Toggle #{series_name}"}
          aria-pressed={to_string(series_name in @visible_series)}
          phx-click={@on_toggle_series}
          phx-value-series={series_name}
          title={"Toggle #{series_name}"}
        >
          <span class="inline-block size-2 rounded-sm bg-current" />
          {series_name}
        </button>
      </div>
    </div>
    """
  end
end
