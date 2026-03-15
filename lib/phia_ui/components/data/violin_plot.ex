defmodule PhiaUi.Components.ViolinPlot do
  @moduledoc """
  Violin plot showing kernel density estimation distributions — pure SVG, zero JS.

  Each violin is a mirrored KDE curve rendered as an SVG path. An optional inner
  box plot overlay shows median, Q1, and Q3. The density curve is computed using
  a Gaussian kernel with Silverman's rule of thumb for bandwidth selection.

  ## Examples

      <.violin_plot data={[
        %{label: "Group A", values: [12, 15, 18, 22, 25, 28, 30, 35, 45]},
        %{label: "Group B", values: [5, 10, 15, 20, 25, 30, 35, 40]}
      ]} />

      <.violin_plot
        data={violin_data}
        show_box={true}
        resolution={80}
        bandwidth={2.5}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartAxisHelpers
  alias PhiaUi.Components.Data.ChartMathHelpers
  alias PhiaUi.Components.Data.ChartViewport
  alias PhiaUi.Components.Data.ChartTheme

  attr :data, :list, default: [], doc: "Distribution data: `[%{label, values: [numbers]}]`."
  attr :colors, :list, default: [], doc: "Override default palette. CSS color strings."
  attr :bandwidth, :any, default: nil, doc: "Override KDE bandwidth (Silverman default if nil)."
  attr :show_box, :boolean, default: true, doc: "Show inner box plot overlay (median + Q1-Q3 rect)."
  attr :resolution, :integer, default: 50, doc: "Number of KDE evaluation points."
  attr :show_grid, :boolean, default: true, doc: "Show Y-axis grid lines."
  attr :show_labels, :boolean, default: true, doc: "Show axis tick labels."
  attr :animate, :boolean, default: true, doc: "Enable entrance animations."
  attr :animation_duration, :integer, default: 600, doc: "Animation duration in ms."
  attr :theme, :map, default: %{}, doc: "Chart theme overrides (see ChartTheme)."
  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def violin_plot(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"
    vp = ChartViewport.build()
    theme = ChartTheme.merge(assigns.theme)
    data = assigns.data
    n = length(data)
    resolution = assigns.resolution

    # Compute all values for Y domain
    all_values = Enum.flat_map(data, fn item -> item.values end)

    {y_ticks, y_min, y_max} =
      if all_values == [] do
        ticks = ChartAxisHelpers.nice_ticks(0, 10, 5)
        {ticks, Enum.min(ticks), Enum.max(ticks)}
      else
        min_v = Enum.min(all_values)
        max_v = Enum.max(all_values)
        ticks = ChartAxisHelpers.nice_ticks(min_v, max_v, 5)
        {ticks, Enum.min(ticks), Enum.max(ticks)}
      end

    y_range = max(y_max - y_min, 1)

    # Band width per group in pixels
    band_w = vp.cw / max(n, 1)
    half_band = band_w * 0.4

    # Build violin render data
    violins =
      data
      |> Enum.with_index()
      |> Enum.map(fn {item, i} ->
        cx = vp.pl + (i + 0.5) * band_w
        color = ChartHelpers.chart_color(i, assigns.colors)

        # Compute KDE
        kde_points = ChartMathHelpers.kernel_density(item.values, resolution, assigns.bandwidth)

        # Find max density for scaling
        max_density = kde_points |> Enum.map(& &1.y) |> Enum.max(fn -> 1.0 end)

        # Build mirrored violin path
        # Left side (negative x direction) + right side (positive x direction)
        violin_path = build_violin_path(kde_points, cx, half_band, max_density, y_min, y_range, vp)

        # Compute box plot overlay if enabled
        box_overlay =
          if assigns.show_box do
            qs = ChartMathHelpers.quartiles(item.values)
            q1_y = vp.pt + vp.ch - (qs.q1 - y_min) / y_range * vp.ch
            q3_y = vp.pt + vp.ch - (qs.q3 - y_min) / y_range * vp.ch
            median_y = vp.pt + vp.ch - (qs.median - y_min) / y_range * vp.ch
            inner_w = half_band * 0.15

            %{
              box_x: f(cx - inner_w),
              box_y: f(q3_y),
              box_w: f(inner_w * 2),
              box_h: f(max(q1_y - q3_y, 1.0)),
              median_y: f(median_y),
              median_x1: f(cx - inner_w * 1.5),
              median_x2: f(cx + inner_w * 1.5)
            }
          else
            nil
          end

        %{
          path: violin_path,
          color: color,
          box: box_overlay,
          cx: f(cx),
          delay_ms: i * 80,
          label: item.label
        }
      end)

    # Tick rendering data
    tick_lines =
      Enum.map(y_ticks, fn tick ->
        py = vp.pt + vp.ch - (tick - y_min) / y_range * vp.ch
        %{tick: tick, py: f(py), label: ChartAxisHelpers.format_tick(tick * 1.0)}
      end)

    x_label_entries =
      data
      |> Enum.with_index()
      |> Enum.map(fn {item, i} ->
        px = vp.pl + (i + 0.5) * band_w
        %{label: item.label, px: f(px), py: vp.pt + vp.ch + 14}
      end)

    assigns =
      assigns
      |> assign(:violins, violins)
      |> assign(:tick_lines, tick_lines)
      |> assign(:x_label_entries, x_label_entries)
      |> assign(:viewbox, ChartViewport.viewbox(vp))
      |> assign(:grid_x1, vp.pl)
      |> assign(:grid_x2, vp.pl + vp.cw)
      |> assign(:theme, theme)
      |> assign(:chart_id, chart_id)

    ~H"""
    <div
      class={cn(["w-full", if(@animate, do: "phia-chart-animate", else: ""), @class])}
      {@rest}
    >
      <div :if={@title} class="mb-2">
        <h3 class="text-sm font-medium text-foreground">{@title}</h3>
        <p :if={@description} class="text-xs text-muted-foreground">{@description}</p>
      </div>
      <svg
        viewBox={@viewbox}
        role={if(@title, do: "img", else: nil)}
        aria-label={@title}
        aria-describedby={if(@description, do: "#{@chart_id}-desc", else: nil)}
        aria-hidden={if(@title, do: nil, else: "true")}
        class="w-full h-full overflow-visible"
        style={"--phia-chart-dur: #{@animation_duration}ms"}
      >
        <title :if={@title}>{@title}</title>
        <desc :if={@description} id={"#{@chart_id}-desc"}>{@description}</desc>

        <%!-- Y-axis grid lines --%>
        <g :if={@show_grid} aria-hidden="true">
          <line
            :for={t <- @tick_lines}
            x1={@grid_x1}
            y1={t.py}
            x2={@grid_x2}
            y2={t.py}
            stroke="currentColor"
            stroke-width={@theme.grid.stroke_width}
            class={@theme.grid.stroke_class}
          />
        </g>

        <%!-- Y-axis labels --%>
        <g :if={@show_labels}>
          <text
            :for={t <- @tick_lines}
            x={@grid_x1 - 4}
            y={t.py}
            text-anchor="end"
            dominant-baseline="middle"
            font-size={@theme.axis.font_size}
            class={@theme.axis.label_class}
          >{t.label}</text>
        </g>

        <%!-- X-axis labels --%>
        <g :if={@show_labels}>
          <text
            :for={e <- @x_label_entries}
            x={e.px}
            y={e.py}
            text-anchor="middle"
            font-size={@theme.axis.font_size}
            class={@theme.axis.label_class}
          >{e.label}</text>
        </g>

        <%!-- Violins --%>
        <g :for={v <- @violins}>
          <%!-- Violin shape (mirrored KDE path) --%>
          <path
            d={v.path}
            fill={v.color}
            fill-opacity="0.25"
            stroke={v.color}
            stroke-width="1.5"
            style={violin_anim_style(@animate, @animation_duration, v.delay_ms)}
          />

          <%!-- Inner box plot overlay --%>
          <g :if={v.box != nil}>
            <rect
              x={v.box.box_x}
              y={v.box.box_y}
              width={v.box.box_w}
              height={v.box.box_h}
              rx="1"
              fill={v.color}
              fill-opacity="0.5"
              style={violin_anim_style(@animate, @animation_duration, v.delay_ms)}
            />
            <line
              x1={v.box.median_x1}
              y1={v.box.median_y}
              x2={v.box.median_x2}
              y2={v.box.median_y}
              stroke="white"
              stroke-width="2"
              style={violin_anim_style(@animate, @animation_duration, v.delay_ms)}
            />
          </g>
        </g>
      </svg>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp build_violin_path([], _cx, _half_band, _max_d, _y_min, _y_range, _vp), do: ""

  defp build_violin_path(kde_points, cx, half_band, max_density, y_min, y_range, vp) do
    max_d = max(max_density, 1.0e-10)

    # Right side points (top to bottom)
    right_points =
      Enum.map(kde_points, fn pt ->
        y_px = vp.pt + vp.ch - (pt.x - y_min) / y_range * vp.ch
        x_offset = pt.y / max_d * half_band
        {f(cx + x_offset), f(y_px)}
      end)

    # Left side points (bottom to top, mirrored)
    left_points =
      kde_points
      |> Enum.reverse()
      |> Enum.map(fn pt ->
        y_px = vp.pt + vp.ch - (pt.x - y_min) / y_range * vp.ch
        x_offset = pt.y / max_d * half_band
        {f(cx - x_offset), f(y_px)}
      end)

    all_points = right_points ++ left_points

    case all_points do
      [] ->
        ""

      [{x0, y0} | rest] ->
        move = "M #{x0} #{y0}"
        lines = Enum.map_join(rest, " ", fn {x, y} -> "L #{x} #{y}" end)
        "#{move} #{lines} Z"
    end
  end

  defp violin_anim_style(false, _dur, _delay), do: ""

  defp violin_anim_style(true, dur, delay),
    do:
      "transform-box: fill-box; transform-origin: center; animation: phia-violin-draw #{dur}ms ease-out #{delay}ms both"

  defp f(v), do: Float.round(v * 1.0, 2)
end
