defmodule PhiaUi.Components.Data.MarkPoint do
  @moduledoc """
  Data point marker component for charts.

  Marks statistical points (max, min, average) on a chart with a symbol
  and optional label. Auto-detects position from data using `ChartPipeline.stats/1`.

  Inspired by eCharts `markPoint`.

  ## Examples

      <.mark_point
        data={[%{label: "Q1", value: 100}, %{label: "Q2", value: 200}, %{label: "Q3", value: 150}]}
        types={[:max, :min]}
        x_scale={x_scale_fn}
        y_scale={y_scale_fn}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartPipeline

  attr :data, :list, default: [], doc: "List of `%{label, value}` data points."

  attr :types, :list,
    default: [:max, :min],
    doc: "List of mark types to show. Options: :max, :min, :average"

  attr :x_scale, :any, default: nil, doc: "X scale function (label → px)."
  attr :y_scale, :any, default: nil, doc: "Y scale function (value → py)."
  attr :color, :string, default: "oklch(0.60 0.25 0)", doc: "Marker color."

  attr :symbol, :atom,
    default: :circle,
    values: [:circle, :diamond, :triangle],
    doc: "Marker symbol shape."

  attr :symbol_size, :any, default: 12, doc: "Symbol size in pixels."
  attr :show_label, :boolean, default: true, doc: "Show value label on markers."
  attr :animate, :boolean, default: true, doc: "Enable entrance animation."
  attr :class, :string, default: nil
  attr :rest, :global

  def mark_point(assigns) do
    markers = compute_markers(assigns.data, assigns.types, assigns.x_scale, assigns.y_scale)

    assigns = assign(assigns, :markers, markers)

    ~H"""
    <g :if={@markers != []} class={cn([@class])} {@rest}>
      <g :for={{marker, idx} <- Enum.with_index(@markers)}>
        <%!-- Symbol --%>
        <%= case @symbol do %>
          <% :circle -> %>
            <circle
              cx={marker.px}
              cy={marker.py}
              r={@symbol_size / 2}
              fill={@color}
              stroke="white"
              stroke-width="1.5"
              style={mark_anim(@animate, idx)}
            />
          <% :diamond -> %>
            <rect
              x={marker.px - @symbol_size / 2}
              y={marker.py - @symbol_size / 2}
              width={@symbol_size}
              height={@symbol_size}
              fill={@color}
              stroke="white"
              stroke-width="1.5"
              transform={"rotate(45 #{marker.px} #{marker.py})"}
              style={mark_anim(@animate, idx)}
            />
          <% :triangle -> %>
            <polygon
              points={triangle_points(marker.px, marker.py, @symbol_size)}
              fill={@color}
              stroke="white"
              stroke-width="1.5"
              style={mark_anim(@animate, idx)}
            />
        <% end %>

        <%!-- Label --%>
        <text
          :if={@show_label}
          x={marker.px}
          y={marker.py - @symbol_size / 2 - 4}
          font-size="8"
          fill={@color}
          text-anchor="middle"
          class="select-none"
          style={mark_anim(@animate, idx)}
        >{marker.display}</text>
      </g>
    </g>
    """
  end

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------

  defp compute_markers([], _types, _x_scale, _y_scale), do: []
  defp compute_markers(_data, _types, nil, _y_scale), do: []
  defp compute_markers(_data, _types, _x_scale, nil), do: []

  defp compute_markers(data, types, x_scale, y_scale) do
    values = Enum.map(data, & &1.value)
    stats = ChartPipeline.stats(values)

    Enum.flat_map(types, fn type ->
      target_value =
        case type do
          :max -> stats.max
          :min -> stats.min
          :average -> stats.mean
        end

      # Find the data point closest to the target value
      point = find_closest_point(data, target_value, type)

      if point do
        px = x_scale.(point.label)
        py = y_scale.(point.value)
        display = format_value(target_value)

        [%{
          type: type,
          px: Float.round(px * 1.0, 2),
          py: Float.round(py * 1.0, 2),
          value: target_value,
          display: display,
          label: point.label
        }]
      else
        []
      end
    end)
  end

  defp find_closest_point(data, target, type) when type in [:max, :min] do
    Enum.find(data, fn d -> d.value == target end)
  end

  defp find_closest_point(data, target, :average) do
    Enum.min_by(data, fn d -> abs(d.value - target) end, fn -> nil end)
  end

  defp triangle_points(cx, cy, size) do
    half = size / 2
    top_y = cy - half
    bot_y = cy + half * 0.6
    left_x = cx - half
    right_x = cx + half

    "#{Float.round(cx * 1.0, 2)},#{Float.round(top_y * 1.0, 2)} #{Float.round(right_x * 1.0, 2)},#{Float.round(bot_y * 1.0, 2)} #{Float.round(left_x * 1.0, 2)},#{Float.round(bot_y * 1.0, 2)}"
  end

  defp format_value(v) when is_float(v), do: Float.round(v, 1) |> to_string()
  defp format_value(v), do: to_string(v)

  defp mark_anim(false, _idx), do: ""
  defp mark_anim(true, idx), do: "animation: phia-mark-bounce 400ms ease-out #{idx * 100}ms both"
end
