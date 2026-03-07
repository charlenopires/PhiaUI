defmodule PhiaUi.Components.ScatterChart do
  @moduledoc """
  XY scatter chart — pure SVG, zero JS.

  Renders data points as circles with staggered pop-in animation.

  ## Examples

      <.scatter_chart data={[
        %{x: 10, y: 30, label: "A"},
        %{x: 25, y: 80, label: "B"},
        %{x: 60, y: 50, label: "C"}
      ]} />

      <.scatter_chart
        data={[%{x: 1.5, y: 2.3}, %{x: 3.0, y: 5.1}, %{x: 4.5, y: 3.8}]}
        color="oklch(0.65 0.22 30)"
        dot_size={5}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartAxisHelpers

  @vw 400
  @vh 300
  @pl 44
  @pr 16
  @pt 16
  @pb 40
  @cw @vw - @pl - @pr
  @ch @vh - @pt - @pb

  attr :data, :list, required: true, doc: "List of `%{x, y}` (and optional `:label`)."
  attr :color, :string, default: nil, doc: "Dot fill color. Defaults to primary palette color."
  attr :dot_size, :integer, default: 4, doc: "Dot radius in px."
  attr :show_grid, :boolean, default: true
  attr :show_labels, :boolean, default: true
  attr :animate, :boolean, default: true
  attr :animation_duration, :integer, default: 600
  attr :class, :string, default: nil
  attr :rest, :global

  def scatter_chart(assigns) do
    color = assigns.color || "oklch(0.60 0.20 240)"

    {x_tick_entries, y_tick_entries, dots} = build_chart(assigns.data)

    assigns =
      assigns
      |> assign(:dots, dots)
      |> assign(:x_tick_entries, x_tick_entries)
      |> assign(:y_tick_entries, y_tick_entries)
      |> assign(:color, color)
      |> assign(:viewbox, "0 0 #{@vw} #{@vh}")
      |> assign(:grid_x1, @pl)
      |> assign(:grid_x2, @pl + @cw)
      |> assign(:grid_y1, @pt)
      |> assign(:grid_y2, @pt + @ch)

    ~H"""
    <div
      class={cn(["w-full", if(@animate, do: "phia-chart-animate", else: ""), @class])}
      {@rest}
    >
      <svg viewBox={@viewbox} aria-hidden="true" class="w-full h-full overflow-visible">
        <%!-- Grid --%>
        <g :if={@show_grid}>
          <line
            :for={t <- @y_tick_entries}
            x1={@grid_x1}
            y1={t.py}
            x2={@grid_x2}
            y2={t.py}
            stroke="currentColor"
            stroke-width="0.5"
            class="text-border"
          />
          <line
            :for={t <- @x_tick_entries}
            x1={t.px}
            y1={@grid_y1}
            x2={t.px}
            y2={@grid_y2}
            stroke="currentColor"
            stroke-width="0.5"
            class="text-border"
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
            font-size="9"
            class="fill-muted-foreground"
          >{t.label}</text>
        </g>

        <%!-- X labels --%>
        <g :if={@show_labels}>
          <text
            :for={t <- @x_tick_entries}
            x={t.px}
            y={@grid_y2 + 14}
            text-anchor="middle"
            font-size="9"
            class="fill-muted-foreground"
          >{t.label}</text>
        </g>

        <%!-- Dots --%>
        <circle
          :for={dot <- @dots}
          cx={dot.cx}
          cy={dot.cy}
          r={@dot_size}
          fill={@color}
          fill-opacity="0.85"
          style={
            if @animate do
              "transform-box: fill-box; transform-origin: center; animation: phia-dot-pop #{@animation_duration}ms ease-out #{dot.delay_ms}ms both"
            else
              ""
            end
          }
        />
      </svg>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp build_chart([]) do
    x_ticks = ChartAxisHelpers.nice_ticks(0, 10, 5)
    y_ticks = ChartAxisHelpers.nice_ticks(0, 10, 5)

    x_entries = Enum.map(x_ticks, fn t ->
      px = @pl + t / 10.0 * @cw
      %{px: Float.round(px, 2), label: ChartAxisHelpers.format_tick(t * 1.0)}
    end)

    y_entries = Enum.map(y_ticks, fn t ->
      py = @pt + @ch - t / 10.0 * @ch
      %{py: Float.round(py, 2), label: ChartAxisHelpers.format_tick(t * 1.0)}
    end)

    {x_entries, y_entries, []}
  end

  defp build_chart(data) do
    xs = Enum.map(data, & &1.x)
    ys = Enum.map(data, & &1.y)

    x_ticks = ChartAxisHelpers.nice_ticks(Enum.min(xs), Enum.max(xs), 5)
    y_ticks = ChartAxisHelpers.nice_ticks(Enum.min(ys), Enum.max(ys), 5)

    x_min_n = Enum.min(x_ticks)
    x_max_n = Enum.max(x_ticks)
    y_min_n = Enum.min(y_ticks)
    y_max_n = Enum.max(y_ticks)
    x_range = max(x_max_n - x_min_n, 1)
    y_range = max(y_max_n - y_min_n, 1)

    x_entries =
      Enum.map(x_ticks, fn t ->
        px = @pl + (t - x_min_n) / x_range * @cw
        %{px: Float.round(px, 2), label: ChartAxisHelpers.format_tick(t * 1.0)}
      end)

    y_entries =
      Enum.map(y_ticks, fn t ->
        py = @pt + @ch - (t - y_min_n) / y_range * @ch
        %{py: Float.round(py, 2), label: ChartAxisHelpers.format_tick(t * 1.0)}
      end)

    dots =
      data
      |> Enum.with_index()
      |> Enum.map(fn {pt, i} ->
        cx = @pl + (pt.x - x_min_n) / x_range * @cw
        cy = @pt + @ch - (pt.y - y_min_n) / y_range * @ch

        %{
          cx: Float.round(cx, 2),
          cy: Float.round(cy, 2),
          label: Map.get(pt, :label),
          delay_ms: i * 40
        }
      end)

    {x_entries, y_entries, dots}
  end
end
