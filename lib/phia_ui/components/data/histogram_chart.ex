defmodule PhiaUi.Components.HistogramChart do
  @moduledoc """
  Frequency distribution histogram — pure SVG, zero JS.

  Accepts a flat list of numbers and bins them into `bins` equal-width
  buckets. Bars animate in on entrance.

  ## Examples

      <.histogram_chart data={[2, 5, 7, 3, 9, 1, 4, 8, 6, 3, 5, 7, 2, 6]} />

      <.histogram_chart
        data={Enum.map(1..200, fn _ -> :rand.uniform(100) end)}
        bins={15}
        color="oklch(0.70 0.18 145)"
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartAxisHelpers

  @vw 400
  @vh 300
  @pl 44
  @pr 16
  @pt 16
  @pb 40
  @cw @vw - @pl - @pr
  @ch @vh - @pt - @pb

  attr :data, :list, required: true, doc: "Flat list of numeric values."
  attr :bins, :integer, default: 10, doc: "Number of histogram bins."
  attr :color, :string, default: nil, doc: "Bar fill color."
  attr :show_grid, :boolean, default: true
  attr :show_labels, :boolean, default: true
  attr :animate, :boolean, default: true
  attr :animation_duration, :integer, default: 600
  attr :class, :string, default: nil
  attr :rest, :global

  def histogram_chart(assigns) do
    color = assigns.color || "oklch(0.60 0.20 240)"
    binned = ChartHelpers.histogram_bins(assigns.data, assigns.bins)

    y_max_raw = binned |> Enum.map(& &1.value) |> Enum.max(fn -> 0 end)
    y_ticks = ChartAxisHelpers.nice_ticks(0, max(y_max_raw, 1), 5)
    y_max_nice = Enum.max(y_ticks)

    n = length(binned)
    bar_w = @cw / max(n, 1)

    bars =
      binned
      |> Enum.with_index()
      |> Enum.map(fn {bin, i} ->
        h = max(bin.value / max(y_max_nice, 1) * @ch, if(bin.value > 0, do: 1.0, else: 0.0))
        x = @pl + i * bar_w
        y = @pt + @ch - h

        %{
          x: Float.round(x, 2),
          y: Float.round(y, 2),
          w: Float.round(bar_w - 1, 2),
          h: Float.round(h, 2),
          label: bin.label,
          delay_ms: i * 40
        }
      end)

    tick_entries =
      Enum.map(y_ticks, fn tick ->
        py = Float.round(@pt + @ch - tick / max(y_max_nice, 1) * @ch, 2)
        %{py: py, label: ChartAxisHelpers.format_tick(tick * 1.0)}
      end)

    x_label_entries =
      binned
      |> Enum.with_index()
      |> Enum.take_every(max(div(n, 5), 1))
      |> Enum.map(fn {bin, i} ->
        px = @pl + (i + 0.5) * bar_w
        %{label: bin.label, px: Float.round(px, 2), py: @pt + @ch + 14}
      end)

    assigns =
      assigns
      |> assign(:bars, bars)
      |> assign(:tick_entries, tick_entries)
      |> assign(:x_label_entries, x_label_entries)
      |> assign(:color, color)
      |> assign(:viewbox, "0 0 #{@vw} #{@vh}")
      |> assign(:grid_x1, @pl)
      |> assign(:grid_x2, @pl + @cw)

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

        <%!-- X bin labels (sparse) --%>
        <g :if={@show_labels}>
          <text
            :for={e <- @x_label_entries}
            x={e.px}
            y={e.py}
            text-anchor="middle"
            font-size="7"
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
          fill={@color}
          fill-opacity="0.85"
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
end
