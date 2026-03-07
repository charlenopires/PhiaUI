defmodule PhiaUi.Components.WaterfallChart do
  @moduledoc """
  Waterfall chart — cumulative positive/negative bars — pure SVG, zero JS.

  Each bar floats at the cumulative total of previous bars. Positive steps
  use `positive_color`, negative steps use `negative_color`. An optional
  final bar rendered in `total_color` shows the aggregate sum.

  ## Examples

      <.waterfall_chart data={[
        %{label: "Revenue",   value: 500},
        %{label: "COGS",      value: -200},
        %{label: "Gross",     value: 0, total: true},
        %{label: "OpEx",      value: -120},
        %{label: "EBIT",      value: 0, total: true}
      ]} />
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

  attr :data, :list,
    required: true,
    doc: """
    List of `%{label, value}`. Optional `:total` boolean marks a bar that
    resets to the running sum (shown in `total_color`).
    """

  attr :positive_color, :string, default: "oklch(0.70 0.18 145)", doc: "Color for gains."
  attr :negative_color, :string, default: "oklch(0.60 0.25 0)", doc: "Color for losses."
  attr :total_color, :string, default: "oklch(0.60 0.20 240)", doc: "Color for total bars."
  attr :show_grid, :boolean, default: true
  attr :show_labels, :boolean, default: true
  attr :animate, :boolean, default: true
  attr :animation_duration, :integer, default: 600
  attr :class, :string, default: nil
  attr :rest, :global

  def waterfall_chart(assigns) do
    {bars, y_min_raw, y_max_raw} = build_waterfall(assigns.data)

    y_range = max(y_max_raw - y_min_raw, 1)
    y_ticks = ChartAxisHelpers.nice_ticks(y_min_raw, y_max_raw, 5)
    y_min_nice = Enum.min(y_ticks)
    y_max_nice = Enum.max(y_ticks)
    y_range_nice = max(y_max_nice - y_min_nice, 1)

    n = length(bars)
    bar_group_w = @cw / max(n, 1)
    bar_w = bar_group_w * 0.6

    rendered_bars =
      bars
      |> Enum.with_index()
      |> Enum.map(fn {bar, i} ->
        h = abs(bar.value) / y_range_nice * @ch
        h = max(h, if(bar.value != 0, do: 1.0, else: 0.0))

        y =
          if bar.value >= 0 do
            @pt + @ch - (bar.base + bar.value - y_min_nice) / y_range_nice * @ch
          else
            @pt + @ch - (bar.base - y_min_nice) / y_range_nice * @ch
          end

        x = @pl + i * bar_group_w + bar_group_w * 0.2

        color =
          cond do
            bar.total -> assigns.total_color
            bar.value >= 0 -> assigns.positive_color
            true -> assigns.negative_color
          end

        %{
          x: Float.round(x, 2),
          y: Float.round(y, 2),
          w: Float.round(bar_w, 2),
          h: Float.round(h, 2),
          color: color,
          label: bar.label,
          value: bar.value,
          delay_ms: i * 60
        }
      end)
      |> tap(fn _ -> _ = y_range end)

    tick_entries =
      Enum.map(y_ticks, fn tick ->
        py = Float.round(@pt + @ch - (tick - y_min_nice) / y_range_nice * @ch, 2)
        %{py: py, label: ChartAxisHelpers.format_tick(tick * 1.0)}
      end)

    x_label_entries =
      bars
      |> Enum.with_index()
      |> Enum.map(fn {bar, i} ->
        px = @pl + (i + 0.5) * bar_group_w
        %{label: bar.label, px: Float.round(px, 2), py: @pt + @ch + 14}
      end)

    assigns =
      assigns
      |> assign(:bars, rendered_bars)
      |> assign(:tick_entries, tick_entries)
      |> assign(:x_label_entries, x_label_entries)
      |> assign(:viewbox, "0 0 #{@vw} #{@vh}")
      |> assign(:grid_x1, @pl)
      |> assign(:grid_x2, @pl + @cw)
      |> assign(:zero_y, Float.round(@pt + @ch - (0 - y_min_nice) / y_range_nice * @ch, 2))

    ~H"""
    <div
      class={cn(["w-full", if(@animate, do: "phia-chart-animate", else: ""), @class])}
      {@rest}
    >
      <svg viewBox={@viewbox} aria-hidden="true" class="w-full h-full overflow-visible">
        <%!-- Grid --%>
        <g :if={@show_grid}>
          <line
            :for={t <- @tick_entries}
            x1={@grid_x1}
            y1={t.py}
            x2={@grid_x2}
            y2={t.py}
            stroke="currentColor"
            stroke-width="0.5"
            class="text-border"
          />
        </g>

        <%!-- Zero line --%>
        <line
          x1={@grid_x1}
          y1={@zero_y}
          x2={@grid_x2}
          y2={@zero_y}
          stroke="currentColor"
          stroke-width="1"
          class="text-muted-foreground"
        />

        <%!-- Y labels --%>
        <g :if={@show_labels}>
          <text
            :for={t <- @tick_entries}
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
            :for={e <- @x_label_entries}
            x={e.px}
            y={e.py}
            text-anchor="middle"
            font-size="9"
            class="fill-muted-foreground"
          >{e.label}</text>
        </g>

        <%!-- Bars --%>
        <rect
          :for={bar <- @bars}
          x={bar.x}
          y={bar.y}
          width={bar.w}
          height={bar.h}
          rx="2"
          fill={bar.color}
          style={
            if @animate do
              "transform-box: fill-box; transform-origin: bottom; animation: phia-bar-grow #{@animation_duration}ms ease-out #{bar.delay_ms}ms both"
            else
              ""
            end
          }
        />
      </svg>
    </div>
    """
  end

  defp build_waterfall(data) do
    {bars, _running, y_min, y_max} =
      Enum.reduce(data, {[], 0, 0, 0}, fn item, {bars, running, y_min, y_max} ->
        total? = Map.get(item, :total, false)

        {base, new_running} =
          if total? do
            {0, running}
          else
            {running, running + item.value}
          end

        bar = %{
          label: item.label,
          value: if(total?, do: running, else: item.value),
          base: base,
          total: total?
        }

        high = if total?, do: running, else: running + item.value
        low = if total?, do: 0, else: min(running, running + item.value)

        {[bar | bars], new_running, min(y_min, low), max(y_max, high)}
      end)

    {Enum.reverse(bars), y_min, y_max}
  end
end
