defmodule PhiaUi.Components.BubbleChart do
  @moduledoc """
  XY bubble chart with variable-radius circles — pure SVG, zero JS.

  Like scatter chart but the `:size` field on each data point controls
  the rendered bubble radius (scaled relative to the maximum `:size`).

  ## Examples

      <.bubble_chart data={[
        %{x: 10, y: 30, size: 20, label: "A"},
        %{x: 40, y: 60, size: 80, label: "B"},
        %{x: 70, y: 45, size: 40, label: "C"}
      ]} />

      <.bubble_chart
        data={[%{x: 5, y: 2, size: 10}, %{x: 30, y: 50, size: 100}]}
        color="oklch(0.65 0.22 30)"
        max_bubble_size={24}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartAxisHelpers
  alias PhiaUi.Components.Data.ChartViewport
  alias PhiaUi.Components.Data.ChartTheme

  attr :data, :list, required: true, doc: "List of `%{x, y, size}` (and optional `:label`)."
  attr :color, :string, default: nil, doc: "Bubble fill color."
  attr :max_bubble_size, :integer, default: 20, doc: "Maximum rendered bubble radius in px."
  attr :show_grid, :boolean, default: true
  attr :show_labels, :boolean, default: true
  attr :animate, :boolean, default: true
  attr :animation_duration, :integer, default: 600
  attr :theme, :map, default: %{}, doc: "Chart theme overrides."
  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def bubble_chart(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"
    vp = ChartViewport.build(pt: 24)
    theme = ChartTheme.merge(assigns.theme)
    color = assigns.color || "oklch(0.60 0.20 240)"

    {x_tick_entries, y_tick_entries, bubbles} =
      build_chart(assigns.data, assigns.max_bubble_size, vp)

    assigns =
      assigns
      |> assign(:bubbles, bubbles)
      |> assign(:x_tick_entries, x_tick_entries)
      |> assign(:y_tick_entries, y_tick_entries)
      |> assign(:color, color)
      |> assign(:theme, theme)
      |> assign(:viewbox, ChartViewport.viewbox(vp))
      |> assign(:grid_x1, vp.pl)
      |> assign(:grid_x2, vp.pl + vp.cw)
      |> assign(:grid_y1, vp.pt)
      |> assign(:grid_y2, vp.pt + vp.ch)
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
      >
        <title :if={@title}>{@title}</title>
        <desc :if={@description} id={"#{@chart_id}-desc"}>{@description}</desc>
        <%!-- Grid --%>
        <g :if={@show_grid}>
          <line
            :for={t <- @y_tick_entries}
            x1={@grid_x1}
            y1={t.py}
            x2={@grid_x2}
            y2={t.py}
            stroke="currentColor"
            stroke-width={@theme.grid.stroke_width}
            class={@theme.grid.stroke_class}
          />
        </g>

        <%!-- Y labels --%>
        <g :if={@show_labels}>
          <text
            :for={t <- @y_tick_entries}
            x={@grid_x1 - 4}
            y={t.py}
            text-anchor="end"
            dominant-baseline="middle"
            font-size={@theme.axis.font_size}
            class={@theme.axis.label_class}
          >{t.label}</text>
        </g>

        <%!-- X labels --%>
        <g :if={@show_labels}>
          <text
            :for={t <- @x_tick_entries}
            x={t.px}
            y={@grid_y2 + 14}
            text-anchor="middle"
            font-size={@theme.axis.font_size}
            class={@theme.axis.label_class}
          >{t.label}</text>
        </g>

        <%!-- Bubbles (render largest first so small ones appear on top) --%>
        <circle
          :for={b <- @bubbles}
          cx={b.cx}
          cy={b.cy}
          r={b.r}
          fill={@color}
          fill-opacity="0.55"
          stroke={@color}
          stroke-width="1"
          stroke-opacity="0.8"
          style={
            if @animate do
              "transform-box: fill-box; transform-origin: center; animation: phia-dot-pop #{@animation_duration}ms ease-out #{b.delay_ms}ms both"
            else
              ""
            end
          }
        />
      </svg>
    </div>
    """
  end

  defp build_chart([], _max_r, vp) do
    ticks = ChartAxisHelpers.nice_ticks(0, 10, 5)
    entries = Enum.map(ticks, fn t ->
      %{px: Float.round(vp.pl + t / 10.0 * vp.cw, 2), py: Float.round(vp.pt + vp.ch - t / 10.0 * vp.ch, 2),
        label: ChartAxisHelpers.format_tick(t * 1.0)}
    end)
    {entries, entries, []}
  end

  defp build_chart(data, max_r, vp) do
    xs = Enum.map(data, & &1.x)
    ys = Enum.map(data, & &1.y)
    sizes = Enum.map(data, & &1.size)

    x_ticks = ChartAxisHelpers.nice_ticks(Enum.min(xs), Enum.max(xs), 5)
    y_ticks = ChartAxisHelpers.nice_ticks(Enum.min(ys), Enum.max(ys), 5)

    x_min_n = Enum.min(x_ticks)
    x_max_n = Enum.max(x_ticks)
    y_min_n = Enum.min(y_ticks)
    y_max_n = Enum.max(y_ticks)
    size_max = Enum.max(sizes) |> max(1)

    x_range = max(x_max_n - x_min_n, 1)
    y_range = max(y_max_n - y_min_n, 1)

    x_entries =
      Enum.map(x_ticks, fn t ->
        px = vp.pl + (t - x_min_n) / x_range * vp.cw
        %{px: Float.round(px, 2), label: ChartAxisHelpers.format_tick(t * 1.0)}
      end)

    y_entries =
      Enum.map(y_ticks, fn t ->
        py = vp.pt + vp.ch - (t - y_min_n) / y_range * vp.ch
        %{py: Float.round(py, 2), label: ChartAxisHelpers.format_tick(t * 1.0)}
      end)

    bubbles =
      data
      |> Enum.with_index()
      |> Enum.map(fn {pt, i} ->
        cx = vp.pl + (pt.x - x_min_n) / x_range * vp.cw
        cy = vp.pt + vp.ch - (pt.y - y_min_n) / y_range * vp.ch
        r = max_r * :math.sqrt(pt.size / size_max)

        %{
          cx: Float.round(cx, 2),
          cy: Float.round(cy, 2),
          r: Float.round(r, 2),
          delay_ms: i * 50
        }
      end)
      |> Enum.sort_by(& &1.r, :desc)

    {x_entries, y_entries, bubbles}
  end
end
