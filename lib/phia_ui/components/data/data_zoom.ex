defmodule PhiaUi.Components.Data.DataZoom do
  @moduledoc """
  Range slider for chart data zooming.

  Inspired by eCharts `dataZoom` slider — provides a draggable range control
  below a chart for selecting a data subset. Sends `phx-change` events with
  normalized `%{"start" => 0.0, "end" => 1.0}` values.

  ## Examples

      <.data_zoom
        id="zoom-1"
        start={0.2}
        end_val={0.8}
        on_change="zoom-changed"
      />

      <.data_zoom
        id="zoom-2"
        show_minimap={true}
        minimap_data={[10, 25, 30, 15, 40, 35, 20]}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :id, :string, required: true, doc: "Required for phx-hook."
  attr :start, :float, default: 0.0, doc: "Initial start position (0.0–1.0)."
  attr :end_val, :float, default: 1.0, doc: "Initial end position (0.0–1.0)."
  attr :height, :integer, default: 40, doc: "Height of the zoom slider in pixels."
  attr :show_minimap, :boolean, default: false, doc: "Show minimap sparkline in background."
  attr :minimap_data, :list, default: [], doc: "List of numeric values for minimap."
  attr :minimap_color, :string, default: "oklch(0.60 0.20 240)", doc: "Minimap area fill color."
  attr :on_change, :string, default: nil, doc: "Event name to send on range change."
  attr :class, :string, default: nil
  attr :rest, :global

  def data_zoom(assigns) do
    minimap_path = build_minimap_path(assigns.minimap_data, assigns.height)

    assigns =
      assigns
      |> assign(:minimap_path, minimap_path)

    ~H"""
    <div
      id={@id}
      phx-hook="PhiaDataZoom"
      data-start={@start}
      data-end={@end_val}
      data-event={@on_change}
      class={cn(["relative w-full select-none", @class])}
      style={"height: #{@height}px"}
      role="slider"
      aria-label="Data zoom range"
      aria-valuemin="0"
      aria-valuemax="100"
      {@rest}
    >
      <%!-- Background track --%>
      <div class="absolute inset-0 rounded bg-muted/50 overflow-hidden">
        <%!-- Minimap sparkline --%>
        <svg
          :if={@show_minimap && @minimap_data != []}
          viewBox={"0 0 100 #{@height}"}
          preserveAspectRatio="none"
          class="absolute inset-0 w-full h-full"
          aria-hidden="true"
        >
          <path
            d={@minimap_path}
            fill={@minimap_color}
            opacity="0.2"
          />
        </svg>
      </div>

      <%!-- Selected range window --%>
      <div
        class="absolute top-0 bottom-0 bg-primary/10 border-x-2 border-primary/40 cursor-grab active:cursor-grabbing"
        data-role="window"
        style={"left: #{@start * 100}%; right: #{(1 - @end_val) * 100}%"}
      />

      <%!-- Left handle --%>
      <div
        class="absolute top-0 bottom-0 w-2 -ml-1 cursor-ew-resize z-10 flex items-center justify-center"
        data-role="handle-start"
        style={"left: #{@start * 100}%"}
      >
        <div class="w-0.5 h-3 rounded-full bg-primary" />
      </div>

      <%!-- Right handle --%>
      <div
        class="absolute top-0 bottom-0 w-2 -ml-1 cursor-ew-resize z-10 flex items-center justify-center"
        data-role="handle-end"
        style={"left: #{@end_val * 100}%"}
      >
        <div class="w-0.5 h-3 rounded-full bg-primary" />
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------

  defp build_minimap_path([], _h), do: ""

  defp build_minimap_path(data, height) do
    n = length(data)
    max_val = Enum.max(data) |> max(1)

    points =
      data
      |> Enum.with_index()
      |> Enum.map(fn {v, i} ->
        x = i / max(n - 1, 1) * 100
        y = height - v / max_val * height
        "#{Float.round(x * 1.0, 2)} #{Float.round(y * 1.0, 2)}"
      end)

    line = Enum.join(points, " L ")
    first_x = 0
    last_x = 100
    "M #{first_x} #{height} L #{line} L #{last_x} #{height} Z"
  end
end
