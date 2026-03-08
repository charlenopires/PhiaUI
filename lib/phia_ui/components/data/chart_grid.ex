defmodule PhiaUi.Components.Data.ChartGrid do
  @moduledoc """
  Composable SVG grid components for charts.

  Render horizontal, vertical, or polar grid lines as background guides.
  Accept scale functions and tick values for positioning.

  ## Examples

      <svg viewBox="0 0 400 300">
        <.y_grid ticks={[0, 50, 100]} scale={y_scale} x={44} width={340} />
        <.x_grid ticks={["Jan", "Feb", "Mar"]} scale={x_scale} y={16} height={244} />
      </svg>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # X Grid (vertical lines)
  # ---------------------------------------------------------------------------

  @doc """
  Renders vertical grid lines at each tick position.
  """
  attr :ticks, :list, required: true, doc: "List of tick values."
  attr :scale, :any, required: true, doc: "Scale function `fn(value) -> pixel_x`."
  attr :y, :any, required: true, doc: "Top Y position."
  attr :height, :any, required: true, doc: "Height of grid lines."
  attr :dash_array, :string, default: nil, doc: "SVG stroke-dasharray (e.g. \"4 2\")."
  attr :class, :string, default: nil

  def x_grid(assigns) do
    grid_lines =
      Enum.map(assigns.ticks, fn tick ->
        px = assigns.scale.(tick)
        %{px: Float.round(px * 1.0, 2)}
      end)

    assigns = assign(assigns, :grid_lines, grid_lines)

    ~H"""
    <g class={cn(["phia-x-grid", @class])}>
      <line
        :for={line <- @grid_lines}
        x1={line.px}
        y1={@y}
        x2={line.px}
        y2={@y + @height}
        stroke="currentColor"
        stroke-width="0.5"
        stroke-dasharray={@dash_array}
        class="text-border"
      />
    </g>
    """
  end

  # ---------------------------------------------------------------------------
  # Y Grid (horizontal lines)
  # ---------------------------------------------------------------------------

  @doc """
  Renders horizontal grid lines at each tick position.
  """
  attr :ticks, :list, required: true
  attr :scale, :any, required: true, doc: "Scale function `fn(value) -> pixel_y`."
  attr :x, :any, required: true, doc: "Left X position."
  attr :width, :any, required: true, doc: "Width of grid lines."
  attr :dash_array, :string, default: nil
  attr :class, :string, default: nil

  def y_grid(assigns) do
    grid_lines =
      Enum.map(assigns.ticks, fn tick ->
        py = assigns.scale.(tick)
        %{py: Float.round(py * 1.0, 2)}
      end)

    assigns = assign(assigns, :grid_lines, grid_lines)

    ~H"""
    <g class={cn(["phia-y-grid", @class])}>
      <line
        :for={line <- @grid_lines}
        x1={@x}
        y1={line.py}
        x2={@x + @width}
        y2={line.py}
        stroke="currentColor"
        stroke-width="0.5"
        stroke-dasharray={@dash_array}
        class="text-border"
      />
    </g>
    """
  end

  # ---------------------------------------------------------------------------
  # Polar Grid (concentric circles + radial lines)
  # ---------------------------------------------------------------------------

  @doc """
  Renders concentric circles and optional radial spoke lines for polar charts.
  """
  attr :rings, :list, required: true, doc: "List of radius values in pixels."
  attr :spokes, :integer, default: 0, doc: "Number of radial lines (0 = none)."
  attr :cx, :any, required: true
  attr :cy, :any, required: true
  attr :dash_array, :string, default: nil
  attr :class, :string, default: nil

  def polar_grid(assigns) do
    max_r = if assigns.rings == [], do: 0, else: Enum.max(assigns.rings)

    spoke_lines =
      if assigns.spokes > 0 do
        Enum.map(0..(assigns.spokes - 1), fn i ->
          angle = -:math.pi() / 2 + i / assigns.spokes * 2 * :math.pi()
          ex = assigns.cx + max_r * :math.cos(angle)
          ey = assigns.cy + max_r * :math.sin(angle)
          %{x2: Float.round(ex * 1.0, 2), y2: Float.round(ey * 1.0, 2)}
        end)
      else
        []
      end

    assigns =
      assigns
      |> assign(:spoke_lines, spoke_lines)

    ~H"""
    <g class={cn(["phia-polar-grid", @class])}>
      <%!-- Concentric circles --%>
      <circle
        :for={r <- @rings}
        cx={@cx}
        cy={@cy}
        r={r}
        fill="none"
        stroke="currentColor"
        stroke-width="0.5"
        stroke-dasharray={@dash_array}
        class="text-border"
      />
      <%!-- Radial spokes --%>
      <line
        :for={spoke <- @spoke_lines}
        x1={@cx}
        y1={@cy}
        x2={spoke.x2}
        y2={spoke.y2}
        stroke="currentColor"
        stroke-width="0.5"
        stroke-dasharray={@dash_array}
        class="text-border"
      />
    </g>
    """
  end
end
