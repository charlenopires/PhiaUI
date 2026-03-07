defmodule PhiaUi.Components.BarChart do
  @moduledoc """
  Vertical grouped / stacked / horizontal bar chart — pure SVG, zero JS.

  Bars animate in with a `scaleY` grow effect (or `scaleX` for horizontal).
  Stagger delay is applied per-group.

  ## Variants
  - `:grouped` — bars side-by-side within each group (default)
  - `:stacked` — bars stacked vertically per group
  - `:horizontal` — horizontal bars (single or multi-series)

  ## Examples

      <.bar_chart data={[
        %{label: "Jan", value: 120},
        %{label: "Feb", value: 80},
        %{label: "Mar", value: 150}
      ]} />

      <.bar_chart
        series={[
          %{name: "Revenue", data: [%{label: "Q1", value: 200}, %{label: "Q2", value: 280}]},
          %{name: "Cost",    data: [%{label: "Q1", value: 100}, %{label: "Q2", value: 130}]}
        ]}
        variant={:grouped}
        colors={["oklch(0.60 0.20 240)", "oklch(0.65 0.22 30)"]}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartAxisHelpers

  # SVG viewport constants (compile-time)
  @vw 400
  @vh 300
  @pl 44
  @pr 16
  @pt 16
  @pb 40
  @cw @vw - @pl - @pr
  @ch @vh - @pt - @pb

  attr :data, :list, default: [], doc: "Single-series shorthand: `[%{label, value}]`."

  attr :series, :list,
    default: [],
    doc: "Multi-series: `[%{name, data: [%{label, value}]}]`. Overrides `:data` when present."

  attr :variant, :atom,
    default: :grouped,
    values: [:grouped, :stacked, :horizontal],
    doc: "Bar layout variant."

  attr :colors, :list, default: [], doc: "Override default palette. CSS color strings."
  attr :show_grid, :boolean, default: true, doc: "Show Y-axis grid lines."
  attr :show_labels, :boolean, default: true, doc: "Show axis tick labels."
  attr :animate, :boolean, default: true, doc: "Enable entrance animations."
  attr :animation_duration, :integer, default: 600, doc: "Animation duration in ms."
  attr :class, :string, default: nil
  attr :rest, :global

  def bar_chart(assigns) do
    series = ChartHelpers.normalize_series(assigns.data, assigns.series)
    n_series = length(series)
    first_data = series |> List.first(%{data: []}) |> Map.get(:data, [])
    n_groups = length(first_data)
    x_labels = Enum.map(first_data, & &1.label)

    {y_ticks, y_max_nice} = compute_y_axis(series, assigns.variant)
    bars = build_bars(series, assigns.variant, assigns.colors, n_series, n_groups, y_max_nice)

    # Precompute tick rendering data
    tick_lines =
      Enum.map(y_ticks, fn tick ->
        py = Float.round(@pt + @ch - tick / max(y_max_nice, 1) * @ch, 2)
        %{tick: tick, py: py, label: ChartAxisHelpers.format_tick(tick * 1.0)}
      end)

    x_label_entries =
      x_labels
      |> Enum.with_index()
      |> Enum.map(fn {label, i} ->
        px = @pl + (i + 0.5) * (@cw / max(n_groups, 1))
        py = @pt + @ch + 14
        %{label: label, px: Float.round(px, 2), py: py}
      end)

    h_label_entries =
      x_labels
      |> Enum.with_index()
      |> Enum.map(fn {label, i} ->
        py = @pt + (i + 0.5) * (@ch / max(n_groups, 1))
        %{label: label, px: @pl - 4, py: Float.round(py, 2)}
      end)

    assigns =
      assigns
      |> assign(:bars, bars)
      |> assign(:tick_lines, tick_lines)
      |> assign(:x_label_entries, x_label_entries)
      |> assign(:h_label_entries, h_label_entries)
      |> assign(:viewbox, "0 0 #{@vw} #{@vh}")
      |> assign(:grid_x1, @pl)
      |> assign(:grid_x2, @pl + @cw)

    ~H"""
    <div
      class={cn(["w-full", if(@animate, do: "phia-chart-animate", else: ""), @class])}
      {@rest}
    >
      <svg
        viewBox={@viewbox}
        aria-hidden="true"
        class="w-full h-full overflow-visible"
        style={"--phia-chart-dur: #{@animation_duration}ms"}
      >
        <%!-- Y-axis grid + labels (vertical variants) --%>
        <g :if={@show_grid && @variant != :horizontal}>
          <line
            :for={t <- @tick_lines}
            x1={@grid_x1}
            y1={t.py}
            x2={@grid_x2}
            y2={t.py}
            stroke="currentColor"
            stroke-width="0.5"
            class="text-border"
          />
        </g>
        <g :if={@show_labels && @variant != :horizontal}>
          <text
            :for={t <- @tick_lines}
            x={@grid_x1 - 4}
            y={t.py}
            text-anchor="end"
            dominant-baseline="middle"
            font-size="9"
            class="fill-muted-foreground"
          >{t.label}</text>
        </g>

        <%!-- X-axis labels (vertical variants) --%>
        <g :if={@show_labels && @variant != :horizontal}>
          <text
            :for={e <- @x_label_entries}
            x={e.px}
            y={e.py}
            text-anchor="middle"
            font-size="9"
            class="fill-muted-foreground"
          >{e.label}</text>
        </g>

        <%!-- Label axis for horizontal variant --%>
        <g :if={@show_labels && @variant == :horizontal}>
          <text
            :for={e <- @h_label_entries}
            x={e.px}
            y={e.py}
            text-anchor="end"
            dominant-baseline="middle"
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
          style={bar_anim_style(@animate, @variant, @animation_duration, bar.delay_ms)}
        />
      </svg>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp bar_anim_style(false, _variant, _dur, _delay), do: ""

  defp bar_anim_style(true, :horizontal, dur, delay),
    do:
      "transform-box: fill-box; transform-origin: left; animation: phia-bar-grow-x #{dur}ms ease-out #{delay}ms both"

  defp bar_anim_style(true, _vertical, dur, delay),
    do:
      "transform-box: fill-box; transform-origin: bottom; animation: phia-bar-grow #{dur}ms ease-out #{delay}ms both"

  defp compute_y_axis(series, :stacked) do
    n_groups = series |> List.first(%{data: []}) |> Map.get(:data, []) |> length()

    sums =
      Enum.map(0..(max(n_groups - 1, 0)), fn g ->
        Enum.reduce(series, 0, fn s, acc ->
          v = s.data |> Enum.at(g) |> then(&if(&1, do: &1.value, else: 0))
          acc + v
        end)
      end)

    y_max = if sums == [], do: 10, else: Enum.max(sums)
    ticks = ChartAxisHelpers.nice_ticks(0, max(y_max, 1), 5)
    {ticks, Enum.max(ticks)}
  end

  defp compute_y_axis(series, _variant) do
    all_values = series |> Enum.flat_map(fn s -> Enum.map(s.data, & &1.value) end)
    y_max = if all_values == [], do: 10, else: Enum.max(all_values)
    ticks = ChartAxisHelpers.nice_ticks(0, max(y_max, 1), 5)
    {ticks, Enum.max(ticks)}
  end

  defp build_bars(series, :grouped, colors, n_series, n_groups, y_max) do
    group_w = @cw / max(n_groups, 1)
    bar_w = group_w * 0.8 / max(n_series, 1)
    group_offset = group_w * 0.1

    for {s, si} <- Enum.with_index(series),
        {item, gi} <- Enum.with_index(s.data) do
      h = max(item.value / max(y_max, 1) * @ch, 1.0)
      x = @pl + gi * group_w + group_offset + si * bar_w
      y = @pt + @ch - h

      %{
        x: Float.round(x, 2),
        y: Float.round(y, 2),
        w: Float.round(bar_w, 2),
        h: Float.round(h, 2),
        color: ChartHelpers.chart_color(si, colors),
        delay_ms: gi * 60
      }
    end
  end

  defp build_bars(series, :stacked, colors, _n_series, n_groups, y_max) do
    group_w = @cw / max(n_groups, 1)
    bar_w = group_w * 0.6
    group_offset = group_w * 0.2

    for gi <- 0..(max(n_groups - 1, 0)) do
      {bars, _} =
        series
        |> Enum.with_index()
        |> Enum.map_reduce(@pt + @ch, fn {s, si}, y_stack ->
          item = Enum.at(s.data, gi)
          v = if item, do: item.value, else: 0
          h = max(v / max(y_max, 1) * @ch, 0.0)
          actual_h = max(h, if(v > 0, do: 1.0, else: 0.0))
          y = y_stack - actual_h
          x = @pl + gi * group_w + group_offset

          bar = %{
            x: Float.round(x, 2),
            y: Float.round(y, 2),
            w: Float.round(bar_w, 2),
            h: Float.round(actual_h, 2),
            color: ChartHelpers.chart_color(si, colors),
            delay_ms: gi * 60
          }

          {bar, y}
        end)

      bars
    end
    |> List.flatten()
  end

  defp build_bars(series, :horizontal, colors, _n_series, n_groups, y_max) do
    group_h = @ch / max(n_groups, 1)
    bar_h = group_h * 0.6
    group_offset_v = group_h * 0.2
    first = List.first(series, %{data: []})

    for {_s, si} <- Enum.with_index(series),
        {item, gi} <- Enum.with_index(first.data) do
      w = max(item.value / max(y_max, 1) * @cw, 1.0)

      %{
        x: @pl * 1.0,
        y: Float.round(@pt + gi * group_h + group_offset_v + si * bar_h, 2),
        w: Float.round(w, 2),
        h: Float.round(bar_h, 2),
        color: ChartHelpers.chart_color(si, colors),
        delay_ms: gi * 60
      }
    end
  end
end
