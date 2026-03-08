defmodule PhiaUi.Components.Data.MarkLine do
  @moduledoc """
  Statistical reference line component for charts.

  Renders dashed horizontal or vertical lines at statistical positions
  (average, median, min, max) or custom values. Auto-computes position
  from data using `ChartPipeline.stats/1`.

  Inspired by eCharts `markLine`.

  ## Examples

      <.mark_line
        data={[100, 200, 150, 300, 250]}
        type={:average}
        y_pos={120.5}
        width={340}
        label="Avg"
      />

      <.mark_line
        type={:custom}
        value={200}
        y_pos={80.0}
        width={340}
        label="Target"
        color="oklch(0.60 0.25 0)"
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartPipeline

  attr :data, :list, default: [], doc: "List of numeric values for auto-computing line position."

  attr :type, :atom,
    default: :average,
    values: [:average, :median, :min, :max, :custom],
    doc: "Type of reference line."

  attr :value, :any, default: nil, doc: "Custom value (used when type is :custom)."

  attr :axis, :atom,
    default: :y,
    values: [:x, :y],
    doc: "Which axis the line crosses. :y = horizontal line, :x = vertical line."

  attr :scale, :any, default: nil, doc: "Scale function to convert data value to pixel position."
  attr :x, :any, default: 0, doc: "X offset for horizontal lines (left edge of chart area)."
  attr :y_pos, :any, default: nil, doc: "Pre-computed Y pixel position (overrides scale computation)."
  attr :width, :any, default: 340, doc: "Line width in pixels."
  attr :height, :any, default: nil, doc: "Line height for vertical lines."
  attr :label, :any, default: nil, doc: "Label text displayed at line end."
  attr :show_value, :boolean, default: true, doc: "Show the numeric value in the label."
  attr :color, :string, default: "oklch(0.60 0.25 0)", doc: "Line and label color."
  attr :dash_array, :string, default: "4 3", doc: "SVG stroke-dasharray pattern."
  attr :class, :string, default: nil
  attr :rest, :global

  def mark_line(assigns) do
    stat_value = compute_stat_value(assigns.data, assigns.type, assigns.value)

    pixel_pos =
      cond do
        assigns.y_pos != nil -> assigns.y_pos * 1.0
        assigns.scale != nil and stat_value != nil -> assigns.scale.(stat_value) * 1.0
        true -> nil
      end

    display_value =
      if stat_value != nil do
        if is_float(stat_value), do: Float.round(stat_value, 1), else: stat_value
      end

    label_text =
      cond do
        assigns.label != nil and assigns.show_value and display_value != nil ->
          "#{assigns.label}: #{display_value}"
        assigns.label != nil ->
          assigns.label
        assigns.show_value and display_value != nil ->
          "#{display_value}"
        true ->
          nil
      end

    assigns =
      assigns
      |> assign(:pixel_pos, pixel_pos)
      |> assign(:stat_value, stat_value)
      |> assign(:label_text, label_text)

    ~H"""
    <g :if={@pixel_pos != nil} class={cn([@class])} {@rest}>
      <%= if @axis == :y do %>
        <%!-- Horizontal reference line --%>
        <line
          x1={@x}
          y1={Float.round(@pixel_pos, 2)}
          x2={@x + @width}
          y2={Float.round(@pixel_pos, 2)}
          stroke={@color}
          stroke-width="1"
          stroke-dasharray={@dash_array}
          opacity="0.8"
        />

        <%!-- Label at right end --%>
        <text
          :if={@label_text}
          x={@x + @width + 4}
          y={Float.round(@pixel_pos, 2)}
          font-size="8"
          fill={@color}
          dominant-baseline="middle"
          class="select-none"
        >{@label_text}</text>
      <% else %>
        <%!-- Vertical reference line --%>
        <line
          x1={Float.round(@pixel_pos, 2)}
          y1={0}
          x2={Float.round(@pixel_pos, 2)}
          y2={@height || 244}
          stroke={@color}
          stroke-width="1"
          stroke-dasharray={@dash_array}
          opacity="0.8"
        />

        <%!-- Label at top --%>
        <text
          :if={@label_text}
          x={Float.round(@pixel_pos, 2)}
          y={-4}
          font-size="8"
          fill={@color}
          text-anchor="middle"
          class="select-none"
        >{@label_text}</text>
      <% end %>
    </g>
    """
  end

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------

  defp compute_stat_value([], :custom, value), do: value
  defp compute_stat_value([], _type, _value), do: nil

  defp compute_stat_value(data, type, value) do
    case type do
      :custom -> value
      _ ->
        s = ChartPipeline.stats(data)
        case type do
          :average -> s.mean
          :median -> s.median
          :min -> s.min
          :max -> s.max
          _ -> nil
        end
    end
  end
end
