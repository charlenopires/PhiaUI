defmodule PhiaUi.Components.Data.ChartActiveShape do
  @moduledoc """
  Hover-expanding shape component for chart elements.

  Inspired by Recharts' `activeShape` — provides hover state transitions
  for dots, bars, and sectors using pure CSS `:hover` on SVG `<g>`.

  ## Examples

      <.chart_active_shape type={:dot} cx={100} cy={50} r={4} active_r={8} color="blue" />

      <.chart_active_shape type={:bar} x={10} y={20} width={30} height={60} color="red" />

      <.chart_active_shape type={:sector} path={normal_path} active_path={expanded_path} color="green" />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :type, :atom, default: :dot, values: [:dot, :bar, :sector], doc: "Shape type."

  # Dot attrs
  attr :cx, :any, default: 0, doc: "Circle center X."
  attr :cy, :any, default: 0, doc: "Circle center Y."
  attr :r, :any, default: 4, doc: "Normal radius."
  attr :active_r, :any, default: 8, doc: "Hover radius."

  # Bar attrs
  attr :x, :any, default: 0, doc: "Bar X position."
  attr :y, :any, default: 0, doc: "Bar Y position."
  attr :width, :any, default: 0, doc: "Bar width."
  attr :height, :any, default: 0, doc: "Bar height."

  # Sector attrs
  attr :path, :string, default: nil, doc: "Normal sector SVG path."
  attr :active_path, :string, default: nil, doc: "Expanded sector SVG path for hover."

  # Common
  attr :color, :string, default: "currentColor", doc: "Fill color."
  attr :active_color, :string, default: nil, doc: "Hover fill color override."
  attr :opacity, :any, default: 1, doc: "Normal opacity."
  attr :active_opacity, :any, default: 1, doc: "Hover opacity."
  attr :class, :string, default: nil
  attr :rest, :global

  def chart_active_shape(%{type: :dot} = assigns) do
    ~H"""
    <g
      class={cn(["cursor-pointer group/active-shape", @class])}
      {@rest}
    >
      <%!-- Invisible hit area --%>
      <circle
        cx={@cx}
        cy={@cy}
        r={@active_r}
        fill="transparent"
        class="pointer-events-auto"
      />
      <%!-- Normal dot --%>
      <circle
        cx={@cx}
        cy={@cy}
        r={@r}
        fill={@color}
        opacity={@opacity}
        class="transition-all duration-200 group-hover/active-shape:hidden"
      />
      <%!-- Active dot --%>
      <circle
        cx={@cx}
        cy={@cy}
        r={@active_r}
        fill={@active_color || @color}
        opacity={@active_opacity}
        class="hidden transition-all duration-200 group-hover/active-shape:block"
        style="animation: phia-active-shape-grow 200ms ease-out"
      />
    </g>
    """
  end

  def chart_active_shape(%{type: :bar} = assigns) do
    ~H"""
    <g
      class={cn(["cursor-pointer group/active-shape", @class])}
      {@rest}
    >
      <rect
        x={@x}
        y={@y}
        width={@width}
        height={@height}
        rx="2"
        fill={@color}
        opacity={@opacity}
        class="transition-all duration-200 group-hover/active-shape:opacity-80"
        style={"--active-color: #{@active_color || @color}"}
      />
    </g>
    """
  end

  def chart_active_shape(%{type: :sector} = assigns) do
    ~H"""
    <g
      class={cn(["cursor-pointer group/active-shape", @class])}
      {@rest}
    >
      <%!-- Normal sector --%>
      <path
        d={@path}
        fill={@color}
        opacity={@opacity}
        class="transition-all duration-200 group-hover/active-shape:hidden"
      />
      <%!-- Active sector (expanded) --%>
      <path
        d={@active_path || @path}
        fill={@active_color || @color}
        opacity={@active_opacity}
        class="hidden transition-all duration-200 group-hover/active-shape:block"
        style="animation: phia-active-shape-grow 200ms ease-out"
      />
    </g>
    """
  end
end
