defmodule PhiaUi.Components.Data.ChartAxis do
  @moduledoc """
  Composable SVG axis components for charts.

  Each axis renders ticks, labels, and an optional title as SVG `<g>` groups.
  They accept scale functions (from `ChartScales`) and tick values to position
  elements — working both standalone and inside `xy_chart`.

  ## Examples

      <svg viewBox="0 0 400 300">
        <.x_axis ticks={[0, 25, 50, 75, 100]} scale={scale_fn} y={260} width={340} />
        <.y_axis ticks={[0, 50, 100]} scale={scale_fn} x={44} height={244} />
      </svg>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartAxisHelpers

  # ---------------------------------------------------------------------------
  # X Axis
  # ---------------------------------------------------------------------------

  @doc """
  Horizontal axis with ticks, labels, and optional title.

  Renders a baseline, tick marks, and text labels at positions determined
  by the scale function.
  """
  attr :ticks, :list, required: true, doc: "List of tick values."
  attr :scale, :any, required: true, doc: "Scale function `fn(value) -> pixel_x`."
  attr :y, :any, required: true, doc: "Y position of the axis line."
  attr :width, :any, required: true, doc: "Width of the axis line."
  attr :x_offset, :any, default: 0, doc: "X offset for the axis start."
  attr :tick_size, :integer, default: 5, doc: "Length of tick marks in px."
  attr :label_format, :any, default: nil, doc: "Optional `fn(value) -> string` for labels."
  attr :title, :string, default: nil, doc: "Optional axis title."
  attr :position, :atom, default: :bottom, values: [:top, :bottom]
  attr :class, :string, default: nil

  def x_axis(assigns) do
    tick_dir = if assigns.position == :top, do: -1, else: 1
    label_dy = if assigns.position == :top, do: -10, else: 14
    title_dy = if assigns.position == :top, do: -28, else: 32

    fmt = assigns.label_format || (&ChartAxisHelpers.format_tick(&1 * 1.0))

    tick_entries =
      Enum.map(assigns.ticks, fn tick ->
        px = assigns.scale.(tick)
        %{px: px, label: fmt.(tick), tick: tick}
      end)

    assigns =
      assigns
      |> assign(:tick_entries, tick_entries)
      |> assign(:tick_dir, tick_dir)
      |> assign(:label_dy, label_dy)
      |> assign(:title_dy, title_dy)

    ~H"""
    <g class={cn(["phia-x-axis", @class])}>
      <%!-- Baseline --%>
      <line
        x1={@x_offset}
        y1={@y}
        x2={@x_offset + @width}
        y2={@y}
        stroke="currentColor"
        stroke-width="1"
        class="text-border"
      />
      <%!-- Ticks + labels --%>
      <g :for={t <- @tick_entries}>
        <line
          x1={t.px}
          y1={@y}
          x2={t.px}
          y2={@y + @tick_size * @tick_dir}
          stroke="currentColor"
          stroke-width="1"
          class="text-border"
        />
        <text
          x={t.px}
          y={@y + @label_dy}
          text-anchor="middle"
          font-size="9"
          class="fill-muted-foreground"
        >{t.label}</text>
      </g>
      <%!-- Title --%>
      <text
        :if={@title}
        x={@x_offset + @width / 2}
        y={@y + @title_dy}
        text-anchor="middle"
        font-size="10"
        class="fill-muted-foreground font-medium"
      >{@title}</text>
    </g>
    """
  end

  # ---------------------------------------------------------------------------
  # Y Axis
  # ---------------------------------------------------------------------------

  @doc """
  Vertical axis with ticks, labels, and optional title.
  """
  attr :ticks, :list, required: true
  attr :scale, :any, required: true, doc: "Scale function `fn(value) -> pixel_y`."
  attr :x, :any, required: true, doc: "X position of the axis line."
  attr :height, :any, required: true, doc: "Height of the axis line."
  attr :y_offset, :any, default: 0, doc: "Y offset for the axis start."
  attr :tick_size, :integer, default: 5
  attr :label_format, :any, default: nil
  attr :title, :string, default: nil
  attr :position, :atom, default: :left, values: [:left, :right]
  attr :class, :string, default: nil

  def y_axis(assigns) do
    tick_dir = if assigns.position == :left, do: -1, else: 1
    label_dx = if assigns.position == :left, do: -8, else: 8
    anchor = if assigns.position == :left, do: "end", else: "start"

    fmt = assigns.label_format || (&ChartAxisHelpers.format_tick(&1 * 1.0))

    tick_entries =
      Enum.map(assigns.ticks, fn tick ->
        py = assigns.scale.(tick)
        %{py: py, label: fmt.(tick), tick: tick}
      end)

    assigns =
      assigns
      |> assign(:tick_entries, tick_entries)
      |> assign(:tick_dir, tick_dir)
      |> assign(:label_dx, label_dx)
      |> assign(:anchor, anchor)

    ~H"""
    <g class={cn(["phia-y-axis", @class])}>
      <%!-- Baseline --%>
      <line
        x1={@x}
        y1={@y_offset}
        x2={@x}
        y2={@y_offset + @height}
        stroke="currentColor"
        stroke-width="1"
        class="text-border"
      />
      <%!-- Ticks + labels --%>
      <g :for={t <- @tick_entries}>
        <line
          x1={@x}
          y1={t.py}
          x2={@x + @tick_size * @tick_dir}
          y2={t.py}
          stroke="currentColor"
          stroke-width="1"
          class="text-border"
        />
        <text
          x={@x + @label_dx}
          y={t.py}
          text-anchor={@anchor}
          dominant-baseline="middle"
          font-size="9"
          class="fill-muted-foreground"
        >{t.label}</text>
      </g>
      <%!-- Title (rotated for vertical axis) --%>
      <text
        :if={@title}
        x={@x + if(@position == :left, do: -32, else: 32)}
        y={@y_offset + @height / 2}
        text-anchor="middle"
        font-size="10"
        transform={"rotate(-90, #{@x + if(@position == :left, do: -32, else: 32)}, #{@y_offset + @height / 2})"}
        class="fill-muted-foreground font-medium"
      >{@title}</text>
    </g>
    """
  end

  # ---------------------------------------------------------------------------
  # Radial Axis
  # ---------------------------------------------------------------------------

  @doc """
  Angular axis for polar/radar charts — renders labels around a circle.
  """
  attr :labels, :list, required: true, doc: "List of category labels."
  attr :cx, :any, required: true, doc: "Center X."
  attr :cy, :any, required: true, doc: "Center Y."
  attr :radius, :any, required: true, doc: "Radius for label placement."
  attr :class, :string, default: nil

  def radial_axis(assigns) do
    n = length(assigns.labels)
    start = -:math.pi() / 2

    label_entries =
      assigns.labels
      |> Enum.with_index()
      |> Enum.map(fn {label, i} ->
        angle = start + i / max(n, 1) * 2 * :math.pi()
        lx = assigns.cx + (assigns.radius + 12) * :math.cos(angle)
        ly = assigns.cy + (assigns.radius + 12) * :math.sin(angle)

        anchor =
          cond do
            abs(:math.cos(angle)) < 0.1 -> "middle"
            :math.cos(angle) > 0 -> "start"
            true -> "end"
          end

        %{label: label, x: Float.round(lx * 1.0, 2), y: Float.round(ly * 1.0, 2), anchor: anchor}
      end)

    assigns = assign(assigns, :label_entries, label_entries)

    ~H"""
    <g class={cn(["phia-radial-axis", @class])}>
      <text
        :for={e <- @label_entries}
        x={e.x}
        y={e.y}
        text-anchor={e.anchor}
        dominant-baseline="middle"
        font-size="9"
        class="fill-muted-foreground"
      >{e.label}</text>
    </g>
    """
  end

  # ---------------------------------------------------------------------------
  # Angle Axis
  # ---------------------------------------------------------------------------

  @doc """
  Concentric circles axis for polar charts — renders value rings.
  """
  attr :ticks, :list, required: true, doc: "List of radial tick values."
  attr :scale, :any, required: true, doc: "Scale function `fn(value) -> radius_px`."
  attr :cx, :any, required: true
  attr :cy, :any, required: true
  attr :label_format, :any, default: nil
  attr :class, :string, default: nil

  def angle_axis(assigns) do
    fmt = assigns.label_format || (&ChartAxisHelpers.format_tick(&1 * 1.0))

    ring_entries =
      Enum.map(assigns.ticks, fn tick ->
        r = assigns.scale.(tick)
        %{r: Float.round(r * 1.0, 2), label: fmt.(tick), tick: tick}
      end)

    assigns = assign(assigns, :ring_entries, ring_entries)

    ~H"""
    <g class={cn(["phia-angle-axis", @class])}>
      <circle
        :for={ring <- @ring_entries}
        cx={@cx}
        cy={@cy}
        r={ring.r}
        fill="none"
        stroke="currentColor"
        stroke-width="0.5"
        class="text-border"
      />
      <text
        :for={ring <- @ring_entries}
        x={@cx + 4}
        y={@cy - ring.r - 2}
        font-size="8"
        class="fill-muted-foreground"
      >{ring.label}</text>
    </g>
    """
  end
end
