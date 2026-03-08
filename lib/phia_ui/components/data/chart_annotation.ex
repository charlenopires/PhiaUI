defmodule PhiaUi.Components.Data.ChartAnnotation do
  @moduledoc """
  SVG annotation overlays for charts — reference lines, bands, and point markers.

  All components render as SVG `<g>` groups. Place them inside the chart `<svg>`
  after the data layer for proper z-ordering.

  ## Examples

      <svg viewBox="0 0 400 300">
        <%!-- ... chart data ... --%>
        <.chart_annotation_line value={75} axis={:y} scale={y_scale} x={44} width={340} label="Target" />
        <.chart_annotation_band from={40} to={60} axis={:y} scale={y_scale} x={44} width={340} />
      </svg>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # Annotation Line
  # ---------------------------------------------------------------------------

  @doc """
  Renders a horizontal or vertical reference line with optional label.
  """
  attr :value, :any, required: true, doc: "Data value where the line is drawn."
  attr :axis, :atom, default: :y, values: [:x, :y], doc: "Which axis the value belongs to."
  attr :scale, :any, required: true, doc: "Scale function `fn(value) -> pixel`."
  attr :x, :any, default: 0, doc: "Left edge (for :y axis lines)."
  attr :y, :any, default: 0, doc: "Top edge (for :x axis lines)."
  attr :width, :any, default: 0, doc: "Line width (for :y axis lines)."
  attr :height, :any, default: 0, doc: "Line height (for :x axis lines)."
  attr :label, :string, default: nil
  attr :color, :string, default: "oklch(0.65 0.22 30)"
  attr :dash_array, :string, default: "4 3", doc: "SVG stroke-dasharray."
  attr :class, :string, default: nil

  def chart_annotation_line(assigns) do
    pixel = assigns.scale.(assigns.value)

    coords =
      case assigns.axis do
        :y -> %{x1: assigns.x, y1: pixel, x2: assigns.x + assigns.width, y2: pixel}
        :x -> %{x1: pixel, y1: assigns.y, x2: pixel, y2: assigns.y + assigns.height}
      end

    label_pos =
      case assigns.axis do
        :y -> %{lx: assigns.x + assigns.width + 4, ly: pixel, anchor: "start", baseline: "middle"}
        :x -> %{lx: pixel, ly: assigns.y - 4, anchor: "middle", baseline: "auto"}
      end

    assigns =
      assigns
      |> assign(:coords, coords)
      |> assign(:label_pos, label_pos)
      |> assign(:pixel, pixel)

    ~H"""
    <g class={cn(["phia-annotation-line", @class])}>
      <line
        x1={@coords.x1}
        y1={@coords.y1}
        x2={@coords.x2}
        y2={@coords.y2}
        stroke={@color}
        stroke-width="1"
        stroke-dasharray={@dash_array}
      />
      <text
        :if={@label}
        x={@label_pos.lx}
        y={@label_pos.ly}
        text-anchor={@label_pos.anchor}
        dominant-baseline={@label_pos.baseline}
        font-size="9"
        fill={@color}
        font-weight="500"
      >{@label}</text>
    </g>
    """
  end

  # ---------------------------------------------------------------------------
  # Annotation Band
  # ---------------------------------------------------------------------------

  @doc """
  Renders a shaded rectangular region between two values.
  """
  attr :from, :any, required: true, doc: "Start value."
  attr :to, :any, required: true, doc: "End value."
  attr :axis, :atom, default: :y, values: [:x, :y]
  attr :scale, :any, required: true
  attr :x, :any, default: 0
  attr :y, :any, default: 0
  attr :width, :any, default: 0
  attr :height, :any, default: 0
  attr :label, :string, default: nil
  attr :color, :string, default: "oklch(0.60 0.20 240 / 0.1)"
  attr :class, :string, default: nil

  def chart_annotation_band(assigns) do
    px_from = assigns.scale.(assigns.from)
    px_to = assigns.scale.(assigns.to)

    rect =
      case assigns.axis do
        :y ->
          top = min(px_from, px_to)
          h = abs(px_to - px_from)
          %{rx: assigns.x, ry: top, rw: assigns.width, rh: h}

        :x ->
          left = min(px_from, px_to)
          w = abs(px_to - px_from)
          %{rx: left, ry: assigns.y, rw: w, rh: assigns.height}
      end

    label_pos =
      case assigns.axis do
        :y -> %{lx: assigns.x + assigns.width / 2, ly: (px_from + px_to) / 2}
        :x -> %{lx: (px_from + px_to) / 2, ly: assigns.y + assigns.height / 2}
      end

    assigns =
      assigns
      |> assign(:rect, rect)
      |> assign(:label_pos, label_pos)

    ~H"""
    <g class={cn(["phia-annotation-band", @class])}>
      <rect
        x={@rect.rx}
        y={@rect.ry}
        width={@rect.rw}
        height={@rect.rh}
        fill={@color}
      />
      <text
        :if={@label}
        x={@label_pos.lx}
        y={@label_pos.ly}
        text-anchor="middle"
        dominant-baseline="middle"
        font-size="9"
        class="fill-muted-foreground"
      >{@label}</text>
    </g>
    """
  end

  # ---------------------------------------------------------------------------
  # Annotation Point
  # ---------------------------------------------------------------------------

  @doc """
  Renders a circle marker with label at a specific (x, y) data coordinate.
  """
  attr :x_value, :any, required: true, doc: "Data x value."
  attr :y_value, :any, required: true, doc: "Data y value."
  attr :x_scale, :any, required: true, doc: "X scale function."
  attr :y_scale, :any, required: true, doc: "Y scale function."
  attr :label, :string, default: nil
  attr :color, :string, default: "oklch(0.65 0.22 30)"
  attr :radius, :integer, default: 4, doc: "Circle radius in px."
  attr :class, :string, default: nil

  def chart_annotation_point(assigns) do
    px = assigns.x_scale.(assigns.x_value)
    py = assigns.y_scale.(assigns.y_value)

    assigns =
      assigns
      |> assign(:px, Float.round(px * 1.0, 2))
      |> assign(:py, Float.round(py * 1.0, 2))

    ~H"""
    <g class={cn(["phia-annotation-point", @class])}>
      <circle cx={@px} cy={@py} r={@radius} fill={@color} />
      <text
        :if={@label}
        x={@px}
        y={@py - @radius - 4}
        text-anchor="middle"
        font-size="9"
        fill={@color}
        font-weight="500"
      >{@label}</text>
    </g>
    """
  end
end
