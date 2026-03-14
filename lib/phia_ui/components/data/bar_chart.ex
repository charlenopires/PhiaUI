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
  alias PhiaUi.Components.Data.ChartViewport
  alias PhiaUi.Components.Data.ChartTheme

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
  attr :border_radius, :integer, default: 2, doc: "Corner radius for bars in pixels (0–12)."
  attr :theme, :map, default: %{}, doc: "Chart theme overrides (see ChartTheme)."
  attr :show_totals, :boolean, default: false, doc: "Show sum labels on stacked bars."
  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def bar_chart(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"
    series = ChartHelpers.normalize_series(assigns.data, assigns.series)
    vp = ChartViewport.build()
    theme = ChartTheme.merge(assigns.theme)
    n_series = length(series)
    first_data = series |> List.first(%{data: []}) |> Map.get(:data, [])
    n_groups = length(first_data)
    x_labels = Enum.map(first_data, & &1.label)

    {y_ticks, y_max_nice} =
      if assigns.variant == :stacked do
        ChartHelpers.compute_stacked_y_domain(series)
      else
        {ticks, _min, max_n} = ChartHelpers.compute_y_domain(series)
        {ticks, max_n}
      end
    bars = build_bars(series, assigns.variant, assigns.colors, n_series, n_groups, y_max_nice, vp)

    # Precompute tick rendering data
    tick_lines =
      Enum.map(y_ticks, fn tick ->
        py = Float.round(vp.pt + vp.ch - tick / max(y_max_nice, 1) * vp.ch, 2)
        %{tick: tick, py: py, label: ChartAxisHelpers.format_tick(tick * 1.0)}
      end)

    x_label_entries =
      x_labels
      |> Enum.with_index()
      |> Enum.map(fn {label, i} ->
        px = vp.pl + (i + 0.5) * (vp.cw / max(n_groups, 1))
        py = vp.pt + vp.ch + 14
        %{label: label, px: Float.round(px, 2), py: py}
      end)

    h_label_entries =
      x_labels
      |> Enum.with_index()
      |> Enum.map(fn {label, i} ->
        py = vp.pt + (i + 0.5) * (vp.ch / max(n_groups, 1))
        %{label: label, px: vp.pl - 4, py: Float.round(py, 2)}
      end)

    bar_totals =
      if assigns.show_totals && assigns.variant == :stacked do
        compute_bar_totals(series, n_groups, y_max_nice, vp)
      else
        []
      end

    assigns =
      assigns
      |> assign(:bars, bars)
      |> assign(:tick_lines, tick_lines)
      |> assign(:x_label_entries, x_label_entries)
      |> assign(:h_label_entries, h_label_entries)
      |> assign(:bar_totals, bar_totals)
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
        <%!-- Y-axis grid + labels (vertical variants) --%>
        <g :if={@show_grid && @variant != :horizontal}>
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
        <g :if={@show_labels && @variant != :horizontal}>
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

        <%!-- X-axis labels (vertical variants) --%>
        <g :if={@show_labels && @variant != :horizontal}>
          <text
            :for={e <- @x_label_entries}
            x={e.px}
            y={e.py}
            text-anchor="middle"
            font-size={@theme.axis.font_size}
            class={@theme.axis.label_class}
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
            font-size={@theme.axis.font_size}
            class={@theme.axis.label_class}
          >{e.label}</text>
        </g>

        <%!-- Bars --%>
        <rect
          :for={bar <- @bars}
          x={bar.x}
          y={bar.y}
          width={bar.w}
          height={bar.h}
          rx={@border_radius}
          fill={bar.color}
          style={bar_anim_style(@animate, @variant, @animation_duration, bar.delay_ms)}
        />

        <%!-- Bar totals (stacked only) --%>
        <g :if={@show_totals && @variant == :stacked}>
          <text
            :for={total <- @bar_totals}
            x={total.x}
            y={total.y}
            text-anchor="middle"
            font-size={@theme.axis.font_size}
            class={@theme.axis.label_class}
          >{total.label}</text>
        </g>
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

  defp build_bars(series, :grouped, colors, n_series, n_groups, y_max, vp) do
    group_w = vp.cw / max(n_groups, 1)
    bar_w = group_w * 0.8 / max(n_series, 1)
    group_offset = group_w * 0.1

    for {s, si} <- Enum.with_index(series),
        {item, gi} <- Enum.with_index(s.data) do
      h = max(item.value / max(y_max, 1) * vp.ch, 1.0)
      x = vp.pl + gi * group_w + group_offset + si * bar_w
      y = vp.pt + vp.ch - h

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

  defp build_bars(series, :stacked, colors, _n_series, n_groups, y_max, vp) do
    group_w = vp.cw / max(n_groups, 1)
    bar_w = group_w * 0.6
    group_offset = group_w * 0.2

    for gi <- 0..(max(n_groups - 1, 0)) do
      {bars, _} =
        series
        |> Enum.with_index()
        |> Enum.map_reduce(vp.pt + vp.ch, fn {s, si}, y_stack ->
          item = Enum.at(s.data, gi)
          v = if item, do: item.value, else: 0
          h = max(v / max(y_max, 1) * vp.ch, 0.0)
          actual_h = max(h, if(v > 0, do: 1.0, else: 0.0))
          y = y_stack - actual_h
          x = vp.pl + gi * group_w + group_offset

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

  defp build_bars(series, :horizontal, colors, _n_series, n_groups, y_max, vp) do
    group_h = vp.ch / max(n_groups, 1)
    bar_h = group_h * 0.6
    group_offset_v = group_h * 0.2
    first = List.first(series, %{data: []})

    for {_s, si} <- Enum.with_index(series),
        {item, gi} <- Enum.with_index(first.data) do
      w = max(item.value / max(y_max, 1) * vp.cw, 1.0)

      %{
        x: vp.pl * 1.0,
        y: Float.round(vp.pt + gi * group_h + group_offset_v + si * bar_h, 2),
        w: Float.round(w, 2),
        h: Float.round(bar_h, 2),
        color: ChartHelpers.chart_color(si, colors),
        delay_ms: gi * 60
      }
    end
  end

  defp compute_bar_totals(series, n_groups, y_max, vp) do
    group_w = vp.cw / max(n_groups, 1)

    Enum.map(0..max(n_groups - 1, 0), fn gi ->
      sum =
        Enum.reduce(series, 0, fn s, acc ->
          item = Enum.at(s.data, gi)
          acc + if(item, do: item.value, else: 0)
        end)

      x = vp.pl + (gi + 0.5) * group_w
      y = vp.pt + vp.ch - sum / max(y_max, 1) * vp.ch - 6

      %{
        x: Float.round(x, 2),
        y: Float.round(y, 2),
        label: ChartAxisHelpers.format_tick(sum * 1.0)
      }
    end)
  end
end
