defmodule PhiaUi.Components.CandlestickChart do
  @moduledoc """
  Candlestick chart for financial OHLC data — pure SVG, zero JS.

  Each candle has a vertical wick (high-low range) and a body (open-close range).
  Bullish candles (close >= open) are rendered in green; bearish candles (close < open)
  are rendered in red. Bullish bodies use a stroke-only style, while bearish bodies
  are filled solid.

  ## Examples

      <.candlestick_chart data={[
        %{label: "Mon", open: 100, high: 110, low: 95, close: 108},
        %{label: "Tue", open: 108, high: 115, low: 105, close: 103},
        %{label: "Wed", open: 103, high: 112, low: 100, close: 111}
      ]} />

      <.candlestick_chart
        data={ohlc_data}
        bullish_color="oklch(0.70 0.18 145)"
        bearish_color="oklch(0.60 0.25 0)"
        animate={true}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartAxisHelpers
  alias PhiaUi.Components.Data.ChartViewport
  alias PhiaUi.Components.Data.ChartTheme

  attr :data, :list, default: [], doc: "OHLC data: `[%{label, open, high, low, close}]`."
  attr :colors, :list, default: [], doc: "Override default palette (unused for candlestick, use bullish/bearish_color)."
  attr :bullish_color, :string, default: "oklch(0.70 0.18 145)", doc: "Color for bullish candles (close >= open)."
  attr :bearish_color, :string, default: "oklch(0.60 0.25 0)", doc: "Color for bearish candles (close < open)."
  attr :body_width, :any, default: nil, doc: "Override candle body width in px (auto-sized if nil)."
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

  def candlestick_chart(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"
    vp = ChartViewport.build()
    theme = ChartTheme.merge(assigns.theme)
    data = assigns.data
    n = length(data)

    # Compute Y domain from all high/low values
    {y_ticks, y_min, y_max} =
      if n == 0 do
        ticks = ChartAxisHelpers.nice_ticks(0, 10, 5)
        {ticks, Enum.min(ticks), Enum.max(ticks)}
      else
        all_lows = Enum.map(data, & &1.low)
        all_highs = Enum.map(data, & &1.high)
        min_v = Enum.min(all_lows)
        max_v = Enum.max(all_highs)
        ticks = ChartAxisHelpers.nice_ticks(min_v, max_v, 5)
        {ticks, Enum.min(ticks), Enum.max(ticks)}
      end

    y_range = max(y_max - y_min, 1)

    # Auto-compute body width
    body_w =
      if assigns.body_width do
        assigns.body_width * 1.0
      else
        if n > 0, do: vp.cw / n * 0.5, else: 10.0
      end

    # Build candle render data
    candles =
      data
      |> Enum.with_index()
      |> Enum.map(fn {item, i} ->
        cx = vp.pl + (i + 0.5) * (vp.cw / max(n, 1))
        bullish = item.close >= item.open

        # Wick: low to high
        wick_y1 = vp.pt + vp.ch - (item.high - y_min) / y_range * vp.ch
        wick_y2 = vp.pt + vp.ch - (item.low - y_min) / y_range * vp.ch

        # Body: open to close
        body_top_val = if bullish, do: item.close, else: item.open
        body_bot_val = if bullish, do: item.open, else: item.close
        body_y = vp.pt + vp.ch - (body_top_val - y_min) / y_range * vp.ch
        body_h = max((body_top_val - body_bot_val) / y_range * vp.ch, 1.0)

        %{
          cx: f(cx),
          wick_y1: f(wick_y1),
          wick_y2: f(wick_y2),
          body_x: f(cx - body_w / 2),
          body_y: f(body_y),
          body_w: f(body_w),
          body_h: f(body_h),
          bullish: bullish,
          color: if(bullish, do: assigns.bullish_color, else: assigns.bearish_color),
          delay_ms: i * 60,
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
        px = vp.pl + (i + 0.5) * (vp.cw / max(n, 1))
        %{label: item.label, px: f(px), py: vp.pt + vp.ch + 14}
      end)

    assigns =
      assigns
      |> assign(:candles, candles)
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

        <%!-- Candle wicks (high-low lines) --%>
        <line
          :for={c <- @candles}
          x1={c.cx}
          y1={c.wick_y1}
          x2={c.cx}
          y2={c.wick_y2}
          stroke={c.color}
          stroke-width="1"
          style={candle_anim_style(@animate, @animation_duration, c.delay_ms)}
        />

        <%!-- Candle bodies (open-close rects) --%>
        <rect
          :for={c <- @candles}
          x={c.body_x}
          y={c.body_y}
          width={c.body_w}
          height={c.body_h}
          rx="1"
          fill={if(c.bullish, do: "none", else: c.color)}
          stroke={c.color}
          stroke-width={if(c.bullish, do: "1.5", else: "0")}
          style={candle_anim_style(@animate, @animation_duration, c.delay_ms)}
        />
      </svg>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp candle_anim_style(false, _dur, _delay), do: ""

  defp candle_anim_style(true, dur, delay),
    do:
      "transform-box: fill-box; transform-origin: center; animation: phia-candle-grow #{dur}ms ease-out #{delay}ms both"

  defp f(v), do: Float.round(v * 1.0, 2)
end
