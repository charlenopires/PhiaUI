defmodule PhiaUi.Components.Data.ChartSvgDefs do
  @moduledoc """
  Reusable SVG `<defs>` building blocks for chart gradients, patterns, and clip paths.

  All components render inside `<defs>` — the caller wraps them in
  `<svg><defs>...</defs>...</svg>` and references definitions via `url(#id)`.

  ## Examples

      <svg viewBox="0 0 400 300">
        <defs>
          <.chart_linear_gradient
            id="revenue-gradient"
            stops={[
              %{offset: "0%", color: "oklch(0.60 0.20 240)"},
              %{offset: "100%", color: "oklch(0.60 0.20 240 / 0.1)"}
            ]}
          />
          <.chart_clip_path id="chart-clip" x={44} y={16} width={340} height={244} />
        </defs>
        <rect fill="url(#revenue-gradient)" clip-path="url(#chart-clip)" ... />
      </svg>
  """

  use Phoenix.Component

  # ---------------------------------------------------------------------------
  # Linear Gradient
  # ---------------------------------------------------------------------------

  @doc """
  Renders an SVG `<linearGradient>` with configurable stops.

  ## Attrs
  - `id` — unique identifier (referenced via `url(#id)`)
  - `stops` — list of `%{offset, color}` or `%{offset, color, opacity}` maps
  - `x1`, `y1`, `x2`, `y2` — gradient direction (default: vertical top-to-bottom)
  """
  attr :id, :string, required: true
  attr :stops, :list, required: true, doc: "List of `%{offset, color}` maps."
  attr :x1, :string, default: "0%"
  attr :y1, :string, default: "0%"
  attr :x2, :string, default: "0%"
  attr :y2, :string, default: "100%"

  def chart_linear_gradient(assigns) do
    ~H"""
    <linearGradient id={@id} x1={@x1} y1={@y1} x2={@x2} y2={@y2}>
      <stop
        :for={stop <- @stops}
        offset={stop.offset}
        stop-color={stop.color}
        stop-opacity={Map.get(stop, :opacity, "1")}
      />
    </linearGradient>
    """
  end

  # ---------------------------------------------------------------------------
  # Radial Gradient
  # ---------------------------------------------------------------------------

  @doc """
  Renders an SVG `<radialGradient>` with configurable stops.

  ## Attrs
  - `id` — unique identifier
  - `stops` — list of `%{offset, color}` or `%{offset, color, opacity}` maps
  - `cx`, `cy` — center of the gradient (default: "50%")
  - `r` — radius (default: "50%")
  """
  attr :id, :string, required: true
  attr :stops, :list, required: true
  attr :cx, :string, default: "50%"
  attr :cy, :string, default: "50%"
  attr :r, :string, default: "50%"

  def chart_radial_gradient(assigns) do
    ~H"""
    <radialGradient id={@id} cx={@cx} cy={@cy} r={@r}>
      <stop
        :for={stop <- @stops}
        offset={stop.offset}
        stop-color={stop.color}
        stop-opacity={Map.get(stop, :opacity, "1")}
      />
    </radialGradient>
    """
  end

  # ---------------------------------------------------------------------------
  # Pattern
  # ---------------------------------------------------------------------------

  @doc """
  Renders an SVG `<pattern>` definition for fills.

  Built-in types: `:dots`, `:lines`, `:crosshatch`, `:diagonal`.

  ## Attrs
  - `id` — unique identifier
  - `type` — pattern type atom
  - `size` — pattern tile size in px (default 8)
  - `color` — stroke/fill color (default "currentColor")
  - `opacity` — pattern opacity (default "0.2")
  """
  attr :id, :string, required: true

  attr :type, :atom,
    default: :dots,
    values: [:dots, :lines, :crosshatch, :diagonal]

  attr :size, :integer, default: 8
  attr :color, :string, default: "currentColor"
  attr :opacity, :string, default: "0.2"

  def chart_pattern(assigns) do
    ~H"""
    <pattern id={@id} width={@size} height={@size} patternUnits="userSpaceOnUse">
      <g opacity={@opacity}>
        <%= case @type do %>
          <% :dots -> %>
            <circle cx={@size / 2} cy={@size / 2} r="1" fill={@color} />
          <% :lines -> %>
            <line x1="0" y1={@size / 2} x2={@size} y2={@size / 2} stroke={@color} stroke-width="0.5" />
          <% :crosshatch -> %>
            <line x1="0" y1={@size / 2} x2={@size} y2={@size / 2} stroke={@color} stroke-width="0.5" />
            <line x1={@size / 2} y1="0" x2={@size / 2} y2={@size} stroke={@color} stroke-width="0.5" />
          <% :diagonal -> %>
            <line x1="0" y1={@size} x2={@size} y2="0" stroke={@color} stroke-width="0.5" />
        <% end %>
      </g>
    </pattern>
    """
  end

  # ---------------------------------------------------------------------------
  # Clip Path
  # ---------------------------------------------------------------------------

  @doc """
  Renders an SVG `<clipPath>` with a rectangular clipping region.

  Use to clip chart content to the viewport area.

  ## Attrs
  - `id` — unique identifier (referenced via `clip-path="url(#id)"`)
  - `x`, `y`, `width`, `height` — clip rectangle dimensions
  """
  attr :id, :string, required: true
  attr :x, :any, default: 0
  attr :y, :any, default: 0
  attr :width, :any, required: true
  attr :height, :any, required: true

  def chart_clip_path(assigns) do
    ~H"""
    <clipPath id={@id}>
      <rect x={@x} y={@y} width={@width} height={@height} />
    </clipPath>
    """
  end
end
