defmodule PhiaUi.Components.Data.SparkChart do
  @moduledoc """
  Minimal inline chart components for sparkline visualizations.

  Inspired by Tremor's spark-elements. These are compact charts designed
  for inline use — no axes, no legend, no tooltip. Pure SVG rendering.

  ## Components

  - `spark_line_chart` — mini line chart
  - `spark_area_chart` — mini area chart with gradient fill
  - `spark_bar_chart` — mini vertical bar chart

  ## Examples

      <.spark_line_chart data={[4, 7, 5, 10, 3, 8]} />
      <.spark_area_chart data={[4, 7, 5, 10, 3, 8]} color="oklch(0.60 0.20 240)" />
      <.spark_bar_chart data={[4, 7, 5, 10, 3, 8]} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartMathHelpers

  # ---------------------------------------------------------------------------
  # Spark Line Chart
  # ---------------------------------------------------------------------------

  @doc """
  Minimal line chart for inline sparkline use.

  ## Attrs
  - `data` — list of numbers
  - `color` — line stroke color
  - `curve` — interpolation mode (:linear, :smooth, :monotone)
  - `stroke_width` — line width in px
  """
  attr :data, :list, required: true, doc: "List of numeric values."
  attr :color, :string, default: "oklch(0.60 0.20 240)", doc: "Line stroke color."
  attr :curve, :atom, default: :linear, values: [:linear, :smooth, :monotone], doc: "Interpolation."
  attr :stroke_width, :any, default: 2, doc: "Stroke width."
  attr :show_animation, :boolean, default: false, doc: "Enable draw animation."
  attr :animate_duration, :integer, default: 900, doc: "Animation duration in ms."
  attr :class, :string, default: nil
  attr :rest, :global

  def spark_line_chart(assigns) do
    data = assigns.data || []

    if data == [] do
      ~H"""
      <div class={cn(["w-28 h-12", @class])} {@rest} />
      """
    else
      {path, path_len} = build_spark_path(data, 112, 48, 2, assigns.curve)

      anim_style =
        if assigns.show_animation do
          "stroke-dasharray: #{path_len}; stroke-dashoffset: #{path_len}; animation: phia-line-draw #{assigns.animate_duration}ms ease-out forwards"
        else
          nil
        end

      assigns =
        assigns
        |> assign(:path, path)
        |> assign(:anim_style, anim_style)

      ~H"""
      <div class={cn(["w-28 h-12", @class])} {@rest}>
        <svg viewBox="0 0 112 48" class="w-full h-full overflow-visible" preserveAspectRatio="none">
          <path
            d={@path}
            fill="none"
            stroke={@color}
            stroke-width={@stroke_width}
            stroke-linecap="round"
            stroke-linejoin="round"
            style={@anim_style}
          />
        </svg>
      </div>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # Spark Area Chart
  # ---------------------------------------------------------------------------

  @doc """
  Minimal area chart for inline sparkline use with gradient fill.
  """
  attr :data, :list, required: true, doc: "List of numeric values."
  attr :color, :string, default: "oklch(0.60 0.20 240)", doc: "Fill/stroke color."
  attr :curve, :atom, default: :linear, values: [:linear, :smooth, :monotone], doc: "Interpolation."
  attr :show_gradient, :boolean, default: true, doc: "Apply gradient fill."
  attr :stroke_width, :any, default: 2, doc: "Stroke width."
  attr :show_animation, :boolean, default: false, doc: "Enable fade animation."
  attr :animate_duration, :integer, default: 900, doc: "Animation duration in ms."
  attr :class, :string, default: nil
  attr :rest, :global

  def spark_area_chart(assigns) do
    data = assigns.data || []

    if data == [] do
      ~H"""
      <div class={cn(["w-28 h-12", @class])} {@rest} />
      """
    else
      w = 112
      h = 48
      pad = 2
      {line_path, _path_len} = build_spark_path(data, w, h, pad, assigns.curve)
      area_path = build_spark_area_path(data, w, h, pad, assigns.curve)
      gradient_id = "spark-grad-#{System.unique_integer([:positive])}"

      stop_opacity_top = if assigns.show_gradient, do: "0.4", else: "0.3"
      stop_opacity_bot = if assigns.show_gradient, do: "0", else: "0.3"

      anim_style =
        if assigns.show_animation do
          "animation: phia-fade-in #{assigns.animate_duration}ms ease-out both"
        else
          nil
        end

      assigns =
        assigns
        |> assign(:line_path, line_path)
        |> assign(:area_path, area_path)
        |> assign(:gradient_id, gradient_id)
        |> assign(:stop_opacity_top, stop_opacity_top)
        |> assign(:stop_opacity_bot, stop_opacity_bot)
        |> assign(:anim_style, anim_style)

      ~H"""
      <div class={cn(["w-28 h-12", @class])} {@rest}>
        <svg viewBox="0 0 112 48" class="w-full h-full overflow-visible" preserveAspectRatio="none">
          <defs>
            <linearGradient id={@gradient_id} x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%" stop-color={@color} stop-opacity={@stop_opacity_top} />
              <stop offset="95%" stop-color={@color} stop-opacity={@stop_opacity_bot} />
            </linearGradient>
          </defs>
          <path
            d={@area_path}
            fill={"url(##{@gradient_id})"}
            stroke="none"
            style={@anim_style}
          />
          <path
            d={@line_path}
            fill="none"
            stroke={@color}
            stroke-width={@stroke_width}
            stroke-linecap="round"
            stroke-linejoin="round"
          />
        </svg>
      </div>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # Spark Bar Chart
  # ---------------------------------------------------------------------------

  @doc """
  Minimal bar chart for inline sparkline use.
  """
  attr :data, :list, required: true, doc: "List of numeric values."
  attr :color, :string, default: "oklch(0.60 0.20 240)", doc: "Bar fill color."
  attr :show_animation, :boolean, default: false, doc: "Enable grow animation."
  attr :animate_duration, :integer, default: 900, doc: "Animation duration in ms."
  attr :class, :string, default: nil
  attr :rest, :global

  def spark_bar_chart(assigns) do
    data = assigns.data || []

    if data == [] do
      ~H"""
      <div class={cn(["w-28 h-12", @class])} {@rest} />
      """
    else
      bars = build_spark_bars(data, 112, 48)

      assigns = assign(assigns, :bars, bars)

      ~H"""
      <div class={cn(["w-28 h-12", @class])} {@rest}>
        <svg viewBox="0 0 112 48" class="w-full h-full overflow-visible" preserveAspectRatio="none">
          <rect
            :for={{bar, idx} <- Enum.with_index(@bars)}
            x={bar.x}
            y={bar.y}
            width={bar.w}
            height={bar.h}
            rx="1"
            fill={@color}
            style={if @show_animation, do: "animation: phia-bar-grow #{@animate_duration}ms ease-out #{idx * 40}ms both; transform-origin: bottom", else: nil}
          />
        </svg>
      </div>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp build_spark_path(data, w, h, pad, curve) do
    count = length(data)
    min_v = Enum.min(data)
    max_v = Enum.max(data)
    y_range = max(max_v - min_v, 1)

    points =
      data
      |> Enum.with_index()
      |> Enum.map(fn {val, i} ->
        px_x = pad + i / max(count - 1, 1) * (w - 2 * pad)
        px_y = pad + (1 - (val - min_v) / y_range) * (h - 2 * pad)
        %{x: Float.round(px_x * 1.0, 2), y: Float.round(px_y * 1.0, 2)}
      end)

    path =
      case curve do
        :linear ->
          [first | rest] = points
          move = "M #{ff(first.x)} #{ff(first.y)}"
          lines = Enum.map_join(rest, " ", fn pt -> "L #{ff(pt.x)} #{ff(pt.y)}" end)
          "#{move} #{lines}"

        :smooth ->
          ChartMathHelpers.smooth_path(points, :smooth)

        :monotone ->
          ChartMathHelpers.smooth_path(points, :monotone)
      end

    path_len = ChartHelpers.path_length(path)
    {path, path_len}
  end

  defp build_spark_area_path(data, w, h, pad, curve) do
    count = length(data)
    min_v = Enum.min(data)
    max_v = Enum.max(data)
    y_range = max(max_v - min_v, 1)
    bottom = h - pad

    points =
      data
      |> Enum.with_index()
      |> Enum.map(fn {val, i} ->
        px_x = pad + i / max(count - 1, 1) * (w - 2 * pad)
        px_y = pad + (1 - (val - min_v) / y_range) * (h - 2 * pad)
        %{x: Float.round(px_x * 1.0, 2), y: Float.round(px_y * 1.0, 2)}
      end)

    first = List.first(points)
    last = List.last(points)

    case curve do
      :linear ->
        line_part = Enum.map_join(points, " L ", fn pt -> "#{ff(pt.x)} #{ff(pt.y)}" end)
        "M #{ff(first.x)} #{ff(bottom)} L #{line_part} L #{ff(last.x)} #{ff(bottom)} Z"

      mode when mode in [:smooth, :monotone] ->
        ChartMathHelpers.smooth_area_path(points, mode, bottom)
    end
  end

  defp build_spark_bars(data, w, h) do
    count = length(data)
    min_v = min(Enum.min(data), 0)
    max_v = Enum.max(data)
    y_range = max(max_v - min_v, 1)
    gap = 2
    bar_w = max((w - gap * (count + 1)) / count, 1)

    data
    |> Enum.with_index()
    |> Enum.map(fn {val, i} ->
      x = gap + i * (bar_w + gap)
      bar_h = max((val - min_v) / y_range * (h - 2), 1)
      y = h - bar_h

      %{
        x: Float.round(x * 1.0, 2),
        y: Float.round(y * 1.0, 2),
        w: Float.round(bar_w * 1.0, 2),
        h: Float.round(bar_h * 1.0, 2)
      }
    end)
  end

  defp ff(v), do: Float.round(v * 1.0, 2)
end
