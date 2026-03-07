defmodule PhiaUi.Components.Background do
  @moduledoc """
  Background pattern and decoration components for PhiaUI.

  15 components covering CSS-only patterns, SVG patterns, and canvas-based
  animated backgrounds. All are tier `:animation`.

  Canvas-based components require JS hooks and respect `prefers-reduced-motion`.

  ## Components

  | Component              | Technique                        | Hook            |
  |------------------------|----------------------------------|-----------------|
  | `gradient_mesh`        | JS-animated blob divs            | `PhiaMeshBg`    |
  | `noise_bg`             | SVG feTurbulence filter          | none            |
  | `animated_gradient_bg` | CSS animated gradient            | none            |
  | `retro_grid`           | Perspective-transformed grid     | none            |
  | `wave_bg`              | SVG wave paths with animation    | none            |
  | `hex_pattern`          | SVG hexagon tile                 | none            |
  | `stripe_pattern`       | CSS repeating-linear-gradient    | none            |
  | `checker_pattern`      | CSS repeating-conic-gradient     | none            |
  | `dot_grid`             | CSS radial-gradient tiling       | none            |
  | `bokeh_bg`             | CSS-animated blurred blobs       | none            |
  | `conic_gradient_bg`    | Animated conic-gradient          | none            |
  | `flicker_grid`         | Canvas flicker dots              | `PhiaFlickerGrid`|
  | `beam_bg`              | CSS beam sweep animation         | none            |
  | `warp_grid`            | Perspective dot grid             | none            |
  | `flowing_lines`        | SVG stroke-dashoffset lines      | none            |
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # gradient_mesh/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "Unique ID (required for phx-hook)")
  attr(:colors, :list,
    default: ["#ff6b6b", "#4ecdc4", "#45b7d1", "#96c93d"],
    doc: "List of hex colors for the mesh blobs"
  )
  attr(:blob_count, :integer, default: 4, doc: "Number of animated blobs")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  @doc """
  Renders an animated mesh gradient background using JS-driven blobs.

  Requires the `PhiaMeshBg` JS hook. Each blob is an absolutely-positioned
  div that shifts position via `requestAnimationFrame`. Respects
  `prefers-reduced-motion` (disables animation in the hook).

  ## Example

      <div class="relative h-96 overflow-hidden rounded-xl">
        <.gradient_mesh id="hero-mesh" colors={["#f093fb", "#f5576c", "#4facfe"]} />
        <div class="relative z-10 p-8">Content over gradient</div>
      </div>
  """
  def gradient_mesh(assigns) do
    colors_json = Jason.encode!(assigns.colors)
    assigns = assign(assigns, :colors_json, colors_json)

    ~H"""
    <div
      id={@id}
      phx-hook="PhiaMeshBg"
      data-colors={@colors_json}
      data-blob-count={to_string(@blob_count)}
      class={cn(["phia-mesh-bg absolute inset-0 overflow-hidden", @class])}
      aria-hidden="true"
      {@rest}
    >
      <div class="absolute inset-0 backdrop-blur-3xl"></div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # noise_bg/1
  # ---------------------------------------------------------------------------

  attr(:opacity, :any, default: 0.3, doc: "Noise overlay opacity (0–1)")
  attr(:base_frequency, :any, default: 0.65, doc: "SVG feTurbulence baseFrequency")
  attr(:num_octaves, :integer, default: 3, doc: "feTurbulence numOctaves")
  attr(:color, :string, default: "currentColor", doc: "Filter color applied via feColorMatrix")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  @doc """
  Renders a grainy noise texture background using SVG `feTurbulence`.

  The noise is applied as an absolutely-positioned overlay. Place inside a
  `relative` container. Use `opacity` to control the texture intensity.

  ## Example

      <div class="relative h-64 bg-gradient-to-br from-violet-500 to-purple-900 rounded-xl">
        <.noise_bg opacity={0.15} />
        <div class="relative z-10 p-6">Content</div>
      </div>
  """
  def noise_bg(assigns) do
    filter_id = "phia-noise-#{:erlang.unique_integer([:positive])}"
    assigns = assign(assigns, :filter_id, filter_id)

    ~H"""
    <div
      class={cn(["absolute inset-0 overflow-hidden pointer-events-none", @class])}
      aria-hidden="true"
      {@rest}
    >
      <svg class="absolute inset-0 w-full h-full" xmlns="http://www.w3.org/2000/svg">
        <defs>
          <filter id={@filter_id} x="0%" y="0%" width="100%" height="100%">
            <feTurbulence
              type="fractalNoise"
              baseFrequency={to_string(@base_frequency)}
              numOctaves={to_string(@num_octaves)}
              stitchTiles="stitch"
            />
            <feColorMatrix type="saturate" values="0" />
          </filter>
        </defs>
        <rect
          width="100%"
          height="100%"
          filter={"url(##{@filter_id})"}
          opacity={to_string(@opacity)}
          style="mix-blend-mode: overlay;"
        />
      </svg>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # animated_gradient_bg/1
  # ---------------------------------------------------------------------------

  attr(:from, :string, default: "#667eea", doc: "Gradient start color")
  attr(:via, :string, default: "#764ba2", doc: "Gradient middle color")
  attr(:to, :string, default: "#f64f59", doc: "Gradient end color")
  attr(:duration, :integer, default: 8, doc: "Animation duration in seconds")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  @doc """
  Renders a smoothly animated gradient background.

  Uses CSS `background-position` animation (same mechanism as aurora).
  Colors are passed as CSS variables for smooth interpolation.

  ## Example

      <div class="relative h-96 rounded-xl overflow-hidden">
        <.animated_gradient_bg from="#667eea" via="#764ba2" to="#f64f59" />
        <div class="relative z-10 p-8">Content</div>
      </div>
  """
  def animated_gradient_bg(assigns) do
    ~H"""
    <div
      class={cn(["absolute inset-0 pointer-events-none", @class])}
      style={
        "background: linear-gradient(-45deg, #{@from}, #{@via}, #{@to}, #{@from}); " <>
          "background-size: 400% 400%; " <>
          "animation: aurora #{@duration}s ease infinite;"
      }
      aria-hidden="true"
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # retro_grid/1
  # ---------------------------------------------------------------------------

  attr(:color, :string, default: "rgba(100,100,100,0.3)", doc: "Grid line color")
  attr(:cell_size, :integer, default: 40, doc: "Grid cell size in pixels")
  attr(:perspective, :integer, default: 500, doc: "CSS perspective value in pixels")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  @doc """
  Renders a retro perspective-transformed grid background.

  Creates a 3D floor-plane illusion via CSS `perspective` and `rotateX`.
  The grid is rendered using CSS `background-image: linear-gradient`.

  ## Example

      <div class="relative h-64 overflow-hidden rounded-xl bg-black">
        <.retro_grid color="rgba(0,255,0,0.2)" cell_size={32} />
        <div class="relative z-10 p-6 text-white">Retro terminal</div>
      </div>
  """
  def retro_grid(assigns) do
    ~H"""
    <div
      class={cn(["absolute inset-0 overflow-hidden pointer-events-none", @class])}
      aria-hidden="true"
      {@rest}
    >
      <div
        style={
          "position: absolute; inset: -50% -50% -50% -50%; " <>
            "transform: perspective(#{@perspective}px) rotateX(40deg) scale(2); " <>
            "transform-origin: center center; " <>
            "background-image: " <>
            "linear-gradient(#{@color} 1px, transparent 1px), " <>
            "linear-gradient(90deg, #{@color} 1px, transparent 1px); " <>
            "background-size: #{@cell_size}px #{@cell_size}px;"
        }
      >
      </div>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # wave_bg/1
  # ---------------------------------------------------------------------------

  attr(:color, :string, default: "rgba(99,102,241,0.15)", doc: "Wave fill color (rgba)")
  attr(:color2, :string, default: "rgba(139,92,246,0.1)", doc: "Second wave fill color")
  attr(:duration, :integer, default: 8, doc: "Wave animation duration in seconds")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  @doc """
  Renders a horizontally scrolling SVG wave background.

  Two overlapping SVG waves animate at slightly different speeds for depth.
  Uses `phia-wave-scroll` keyframe.

  ## Example

      <div class="relative h-48 overflow-hidden rounded-xl bg-white">
        <.wave_bg color="rgba(99,102,241,0.2)" />
        <div class="relative z-10 p-6">Wave content</div>
      </div>
  """
  def wave_bg(assigns) do
    ~H"""
    <div
      class={cn(["phia-wave-bg absolute inset-0 overflow-hidden pointer-events-none", @class])}
      aria-hidden="true"
      {@rest}
    >
      <div style={"animation: phia-wave-scroll #{@duration}s linear infinite; width: 200%; height: 100%;"}>
        <svg
          viewBox="0 0 1440 120"
          xmlns="http://www.w3.org/2000/svg"
          preserveAspectRatio="none"
          style="width: 50%; height: 100%; float: left; position: absolute; bottom: 0;"
        >
          <path
            fill={@color}
            d="M0,40 C180,80 360,0 540,40 C720,80 900,0 1080,40 C1260,80 1440,0 1440,40 L1440,120 L0,120 Z"
          />
        </svg>
        <svg
          viewBox="0 0 1440 120"
          xmlns="http://www.w3.org/2000/svg"
          preserveAspectRatio="none"
          style="width: 50%; height: 100%; float: left; position: absolute; bottom: 0; left: 50%;"
        >
          <path
            fill={@color}
            d="M0,40 C180,80 360,0 540,40 C720,80 900,0 1080,40 C1260,80 1440,0 1440,40 L1440,120 L0,120 Z"
          />
        </svg>
      </div>
      <div style={"animation: phia-wave-scroll #{@duration + 3}s linear infinite; width: 200%; height: 100%; position: absolute; bottom: 0;"}>
        <svg
          viewBox="0 0 1440 120"
          xmlns="http://www.w3.org/2000/svg"
          preserveAspectRatio="none"
          style="width: 50%; height: 100%; float: left; position: absolute; bottom: 0;"
        >
          <path
            fill={@color2}
            d="M0,60 C200,20 400,100 600,60 C800,20 1000,100 1200,60 C1400,20 1440,80 1440,60 L1440,120 L0,120 Z"
          />
        </svg>
        <svg
          viewBox="0 0 1440 120"
          xmlns="http://www.w3.org/2000/svg"
          preserveAspectRatio="none"
          style="width: 50%; height: 100%; float: left; position: absolute; bottom: 0; left: 50%;"
        >
          <path
            fill={@color2}
            d="M0,60 C200,20 400,100 600,60 C800,20 1000,100 1200,60 C1400,20 1440,80 1440,60 L1440,120 L0,120 Z"
          />
        </svg>
      </div>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # hex_pattern/1
  # ---------------------------------------------------------------------------

  attr(:color, :string, default: "rgba(100,100,100,0.15)", doc: "Hexagon stroke color")
  attr(:size, :integer, default: 30, doc: "Hexagon radius in pixels")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  @doc """
  Renders an SVG hexagon tile pattern background.

  Uses SVG `<pattern>` with a `<polygon>` hexagon shape.

  ## Example

      <div class="relative h-64 overflow-hidden rounded-xl bg-slate-50">
        <.hex_pattern color="rgba(99,102,241,0.2)" size={24} />
        <div class="relative z-10 p-6">Hex grid content</div>
      </div>
  """
  def hex_pattern(assigns) do
    id = "phia-hex-#{:erlang.unique_integer([:positive])}"
    # Compute hexagon geometry
    s = assigns.size
    w = round(s * 2)
    h = round(:math.sqrt(3) * s)
    # Hexagon points (flat-top)
    pts =
      [0, 1, 2, 3, 4, 5]
      |> Enum.map(fn i ->
        angle = :math.pi() / 180 * (60 * i)
        x = s + round(s * :math.cos(angle))
        y = div(h, 2) + round(s * :math.sin(angle))
        "#{x},#{y}"
      end)
      |> Enum.join(" ")

    assigns = assign(assigns, id: id, hex_w: w, hex_h: h, pts: pts)

    ~H"""
    <div
      class={cn(["absolute inset-0 pointer-events-none overflow-hidden", @class])}
      aria-hidden="true"
      {@rest}
    >
      <svg class="absolute inset-0 w-full h-full" xmlns="http://www.w3.org/2000/svg">
        <defs>
          <pattern
            id={@id}
            x="0"
            y="0"
            width={to_string(@hex_w)}
            height={to_string(@hex_h)}
            patternUnits="userSpaceOnUse"
          >
            <polygon
              points={@pts}
              fill="none"
              stroke={@color}
              stroke-width="1"
            />
          </pattern>
        </defs>
        <rect width="100%" height="100%" fill={"url(##{@id})"} />
      </svg>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # stripe_pattern/1
  # ---------------------------------------------------------------------------

  attr(:color, :string, default: "rgba(100,100,100,0.1)", doc: "Stripe color")
  attr(:width, :integer, default: 20, doc: "Stripe width in pixels")
  attr(:direction, :atom,
    default: :diagonal,
    values: [:diagonal, :horizontal, :vertical],
    doc: "Stripe direction"
  )
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  @doc """
  Renders a CSS stripe pattern background.

  Uses `repeating-linear-gradient`. Directions: `:diagonal` (45°),
  `:horizontal`, `:vertical`.

  ## Example

      <div class="relative h-48 bg-slate-100 rounded-xl overflow-hidden">
        <.stripe_pattern color="rgba(99,102,241,0.1)" direction={:diagonal} width={16} />
        <div class="relative z-10 p-6">Striped content</div>
      </div>
  """
  def stripe_pattern(assigns) do
    ~H"""
    <div
      class={cn(["absolute inset-0 pointer-events-none", @class])}
      style={stripe_style(@direction, @color, @width)}
      aria-hidden="true"
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp stripe_style(:diagonal, color, w) do
    "background-image: repeating-linear-gradient(45deg, #{color}, #{color} #{w}px, transparent #{w}px, transparent #{w * 2}px);"
  end

  defp stripe_style(:horizontal, color, w) do
    "background-image: repeating-linear-gradient(0deg, #{color}, #{color} #{div(w, 2)}px, transparent #{div(w, 2)}px, transparent #{w}px);"
  end

  defp stripe_style(:vertical, color, w) do
    "background-image: repeating-linear-gradient(90deg, #{color}, #{color} #{div(w, 2)}px, transparent #{div(w, 2)}px, transparent #{w}px);"
  end

  # ---------------------------------------------------------------------------
  # checker_pattern/1
  # ---------------------------------------------------------------------------

  attr(:color, :string, default: "rgba(100,100,100,0.1)", doc: "Checker square color")
  attr(:size, :integer, default: 24, doc: "Checker square size in pixels")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  @doc """
  Renders a CSS checkerboard pattern background.

  Uses `repeating-conic-gradient` for efficient CSS-only rendering.

  ## Example

      <div class="relative h-48 bg-white rounded-xl overflow-hidden">
        <.checker_pattern color="rgba(0,0,0,0.05)" size={20} />
      </div>
  """
  def checker_pattern(assigns) do
    ~H"""
    <div
      class={cn(["absolute inset-0 pointer-events-none", @class])}
      style={"background-image: repeating-conic-gradient(#{@color} 0% 25%, transparent 0% 50%); background-size: #{@size}px #{@size}px;"}
      aria-hidden="true"
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # dot_grid/1
  # ---------------------------------------------------------------------------

  attr(:color, :string, default: "rgba(100,100,100,0.3)", doc: "Dot color")
  attr(:dot_size, :integer, default: 2, doc: "Dot radius in pixels")
  attr(:spacing, :integer, default: 24, doc: "Grid spacing in pixels")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  @doc """
  Renders a CSS dot grid background using `radial-gradient` tiling.

  Distinct from the existing `dot_pattern` (which uses an SVG mask).
  This uses pure CSS for maximum performance.

  ## Example

      <div class="relative h-48 bg-white rounded-xl overflow-hidden">
        <.dot_grid dot_size={3} spacing={20} />
        <div class="relative z-10 p-6">Content on dots</div>
      </div>
  """
  def dot_grid(assigns) do
    ~H"""
    <div
      class={cn(["absolute inset-0 pointer-events-none", @class])}
      style={
        "background-image: radial-gradient(circle, #{@color} #{@dot_size}px, transparent #{@dot_size}px); " <>
          "background-size: #{@spacing}px #{@spacing}px;"
      }
      aria-hidden="true"
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # bokeh_bg/1
  # ---------------------------------------------------------------------------

  attr(:colors, :list,
    default: ["#ff6b6b", "#4ecdc4", "#45b7d1", "#96c93d", "#f7dc6f"],
    doc: "Blob colors"
  )
  attr(:count, :integer, default: 5, doc: "Number of bokeh blobs")
  attr(:blur, :string, default: "blur-3xl", doc: "Tailwind blur class for blobs")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  @doc """
  Renders a set of soft blurred bokeh-style blobs as a background.

  Blobs are positioned using deterministic offsets from `:erlang.unique_integer`.
  Each blob animates with `phia-bokeh-drift` at slightly different speeds.

  ## Example

      <div class="relative h-96 overflow-hidden rounded-xl">
        <.bokeh_bg colors={["#f59e0b", "#10b981", "#6366f1"]} count={4} />
        <div class="relative z-10 p-8">Content</div>
      </div>
  """
  def bokeh_bg(assigns) do
    n = assigns.count
    colors = assigns.colors

    blobs =
      Enum.map(0..(n - 1), fn i ->
        seed = :erlang.unique_integer([:positive])
        color = Enum.at(colors, rem(i, length(colors)))
        left = rem(seed, 80)
        top = rem(seed * 3 + 17, 80)
        size = 150 + rem(seed * 7, 200)
        dur = 6 + rem(i, 4)
        bx = rem(seed * 5, 40) - 20
        by = rem(seed * 3, 30) - 15
        bx2 = rem(seed * 7, 40) - 20
        by2 = rem(seed * 11, 30) - 15
        %{color: color, left: left, top: top, size: size, dur: dur, bx: bx, by: by, bx2: bx2, by2: by2}
      end)

    assigns = assign(assigns, :blobs, blobs)

    ~H"""
    <div
      class={cn(["phia-bokeh-bg absolute inset-0 overflow-hidden pointer-events-none", @class])}
      aria-hidden="true"
      {@rest}
    >
      <div
        :for={blob <- @blobs}
        class={cn(["absolute rounded-full opacity-30", @blur])}
        style={
          "background-color: #{blob.color}; " <>
            "left: #{blob.left}%; top: #{blob.top}%; " <>
            "width: #{blob.size}px; height: #{blob.size}px; " <>
            "animation: phia-bokeh-drift #{blob.dur}s ease-in-out infinite; " <>
            "--bx: #{blob.bx}px; --by: #{blob.by}px; " <>
            "--bx2: #{blob.bx2}px; --by2: #{blob.by2}px;"
        }
      >
      </div>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # conic_gradient_bg/1
  # ---------------------------------------------------------------------------

  attr(:from_color, :string, default: "#f43f5e", doc: "Start color of conic gradient")
  attr(:to_color, :string, default: "#6366f1", doc: "End color of conic gradient")
  attr(:duration, :integer, default: 6, doc: "Spin animation duration in seconds")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  @doc """
  Renders a rotating conic gradient background.

  Uses `@property --phia-conic-angle` for smooth CSS angle animation.
  Add the required `@property` declaration from `theme.css` for full support.

  ## Example

      <div class="relative h-64 overflow-hidden rounded-xl">
        <.conic_gradient_bg from_color="#f43f5e" to_color="#6366f1" />
        <div class="relative z-10 p-6">Conic gradient content</div>
      </div>
  """
  def conic_gradient_bg(assigns) do
    ~H"""
    <div
      class={cn(["absolute inset-0 pointer-events-none", @class])}
      style={
        "background: conic-gradient(from var(--phia-conic-angle, 0deg), #{@from_color}, #{@to_color}, #{@from_color}); " <>
          "animation: phia-conic-spin #{@duration}s linear infinite;"
      }
      aria-hidden="true"
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # flicker_grid/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "Unique ID (required for phx-hook)")
  attr(:color, :string, default: "rgba(99,102,241,0.5)", doc: "Dot color")
  attr(:dot_size, :integer, default: 3, doc: "Dot radius in pixels")
  attr(:gap, :integer, default: 20, doc: "Grid spacing in pixels")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  @doc """
  Renders a canvas-based flickering grid background.

  Each dot in a grid independently flickers at random opacity.
  Requires the `PhiaFlickerGrid` JS hook. Respects `prefers-reduced-motion`.

  ## Example

      <div class="relative h-64 rounded-xl overflow-hidden bg-slate-900">
        <.flicker_grid id="flicker-hero" color="rgba(99,102,241,0.6)" />
        <div class="relative z-10 p-6 text-white">Content</div>
      </div>
  """
  def flicker_grid(assigns) do
    ~H"""
    <canvas
      id={@id}
      phx-hook="PhiaFlickerGrid"
      data-color={@color}
      data-dot-size={to_string(@dot_size)}
      data-gap={to_string(@gap)}
      class={cn(["absolute inset-0 w-full h-full pointer-events-none", @class])}
      aria-hidden="true"
      {@rest}
    >
    </canvas>
    """
  end

  # ---------------------------------------------------------------------------
  # beam_bg/1
  # ---------------------------------------------------------------------------

  attr(:color, :string, default: "rgba(99,102,241,0.5)", doc: "Beam color (rgba)")
  attr(:width, :string, default: "w-1/3", doc: "Tailwind width class for the beam")
  attr(:duration, :integer, default: 4, doc: "Sweep animation duration in seconds")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  @doc """
  Renders a sweeping light beam animation background.

  A gradient beam sweeps from left to right on a loop using `phia-beam-sweep`.
  Place inside a `relative overflow-hidden` container.

  ## Example

      <div class="relative h-48 overflow-hidden rounded-xl bg-slate-950">
        <.beam_bg color="rgba(139,92,246,0.4)" width="w-1/4" />
        <div class="relative z-10 p-6 text-white">Beam content</div>
      </div>
  """
  def beam_bg(assigns) do
    ~H"""
    <div
      class={cn(["absolute inset-0 overflow-hidden pointer-events-none", @class])}
      aria-hidden="true"
      {@rest}
    >
      <div
        class={cn(["absolute inset-y-0", @width])}
        style={
          "background: linear-gradient(90deg, transparent, #{@color}, transparent); " <>
            "animation: phia-beam-sweep #{@duration}s ease-in-out infinite;"
        }
      >
      </div>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # warp_grid/1
  # ---------------------------------------------------------------------------

  attr(:color, :string, default: "rgba(100,100,100,0.2)", doc: "Grid line color")
  attr(:cell_size, :integer, default: 32, doc: "Grid cell size in pixels")
  attr(:perspective, :integer, default: 400, doc: "CSS perspective in pixels")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  @doc """
  Renders a perspective-warped dot grid background.

  Combines a dot grid (`radial-gradient`) with a perspective transform
  to create a floor-plane depth effect.

  ## Example

      <div class="relative h-64 overflow-hidden rounded-xl bg-white">
        <.warp_grid color="rgba(99,102,241,0.25)" />
        <div class="relative z-10 p-6">Warp grid</div>
      </div>
  """
  def warp_grid(assigns) do
    ~H"""
    <div
      class={cn(["absolute inset-0 overflow-hidden pointer-events-none", @class])}
      aria-hidden="true"
      {@rest}
    >
      <div
        style={
          "position: absolute; inset: -50%; width: 200%; height: 200%; " <>
            "transform: perspective(#{@perspective}px) rotateX(45deg); " <>
            "transform-origin: center 60%; " <>
            "background-image: radial-gradient(circle, #{@color} 1.5px, transparent 1.5px); " <>
            "background-size: #{@cell_size}px #{@cell_size}px;"
        }
      >
      </div>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # flowing_lines/1
  # ---------------------------------------------------------------------------

  attr(:color, :string, default: "rgba(99,102,241,0.4)", doc: "Line stroke color")
  attr(:count, :integer, default: 5, doc: "Number of flowing lines")
  attr(:stroke_width, :any, default: 1.5, doc: "SVG stroke-width")
  attr(:duration, :integer, default: 3, doc: "Base animation duration in seconds")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  @doc """
  Renders animated SVG flowing lines using `stroke-dashoffset` animation.

  Reuses the `phia-line-draw` keyframe. Each line has a staggered delay.

  ## Example

      <div class="relative h-48 overflow-hidden rounded-xl bg-white">
        <.flowing_lines color="rgba(99,102,241,0.3)" count={6} />
        <div class="relative z-10 p-6">Flowing lines</div>
      </div>
  """
  def flowing_lines(assigns) do
    n = assigns.count

    lines =
      Enum.map(0..(n - 1), fn i ->
        seed = :erlang.unique_integer([:positive])
        y1 = rem(seed, 80) + 10
        y2 = rem(seed * 3 + 13, 80) + 10
        delay = i * 0.4
        len = 1000
        %{i: i, y1: y1, y2: y2, delay: delay, len: len}
      end)

    assigns = assign(assigns, :lines, lines)

    ~H"""
    <div
      class={cn(["absolute inset-0 overflow-hidden pointer-events-none", @class])}
      aria-hidden="true"
      {@rest}
    >
      <svg
        class="absolute inset-0 w-full h-full"
        xmlns="http://www.w3.org/2000/svg"
        preserveAspectRatio="none"
        viewBox="0 0 100 100"
      >
        <path
          :for={line <- @lines}
          d={"M0,#{line.y1} Q50,#{line.y2 + 10} 100,#{line.y2}"}
          fill="none"
          stroke={@color}
          stroke-width={to_string(@stroke_width)}
          stroke-dasharray={to_string(line.len)}
          stroke-dashoffset={to_string(line.len)}
          style={"animation: phia-line-draw #{@duration}s ease forwards; animation-delay: #{line.delay}s; animation-fill-mode: both;"}
        />
      </svg>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
