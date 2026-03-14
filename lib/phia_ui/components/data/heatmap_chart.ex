defmodule PhiaUi.Components.HeatmapChart do
  @moduledoc """
  Two-dimensional color-coded grid heatmap — pure SVG, zero JS.

  Cells fade in with staggered animation. Color intensity is mapped
  linearly from the minimum to maximum value in the dataset.

  ## Examples

      <.heatmap_chart
        data={[[10, 20, 5], [30, 15, 25], [8, 40, 12]]}
        row_labels={["Mon", "Tue", "Wed"]}
        col_labels={["AM", "PM", "Night"]}
      />

      <.heatmap_chart
        data={[[1, 2, 3], [4, 5, 6]]}
        color_scale={["oklch(0.95 0.05 240)", "oklch(0.55 0.22 240)"]}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartViewport
  alias PhiaUi.Components.Data.ChartTheme

  attr :data, :list, required: true, doc: "2D list of numbers: `[[row_vals...], ...]`."
  attr :row_labels, :list, default: [], doc: "Labels for each row (left side)."
  attr :col_labels, :list, default: [], doc: "Labels for each column (top)."

  attr :color_scale, :list,
    default: ["oklch(0.95 0.05 240)", "oklch(0.55 0.22 240)"],
    doc: "Two-element list: `[low_color, high_color]`."

  attr :animate, :boolean, default: true
  attr :animation_duration, :integer, default: 500
  attr :theme, :map, default: %{}, doc: "Chart theme overrides."
  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def heatmap_chart(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"
    vp = ChartViewport.build(vw: 420, pl: 48, pt: 24, pb: 16)
    theme = ChartTheme.merge(assigns.theme)

    data = assigns.data
    n_rows = length(data)
    n_cols = data |> List.first([]) |> length()

    all_vals = List.flatten(data)
    val_min = if all_vals == [], do: 0, else: Enum.min(all_vals)
    val_max = if all_vals == [], do: 1, else: Enum.max(all_vals)
    val_range = max(val_max - val_min, 1)

    cell_w = vp.cw / max(n_cols, 1)
    cell_h = vp.ch / max(n_rows, 1)
    gap = 2

    cells =
      data
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, ri} ->
        row
        |> Enum.with_index()
        |> Enum.map(fn {val, ci} ->
          x = vp.pl + ci * cell_w
          y = vp.pt + ri * cell_h
          intensity = (val - val_min) / val_range
          idx = ri * max(n_cols, 1) + ci

          %{
            x: Float.round(x + gap / 2, 2),
            y: Float.round(y + gap / 2, 2),
            w: Float.round(cell_w - gap, 2),
            h: Float.round(cell_h - gap, 2),
            intensity: intensity,
            val: val,
            delay_ms: idx * 20
          }
        end)
      end)

    row_label_entries =
      assigns.row_labels
      |> Enum.with_index()
      |> Enum.map(fn {lbl, i} ->
        py = vp.pt + (i + 0.5) * cell_h
        %{label: lbl, px: vp.pl - 4, py: Float.round(py, 2)}
      end)

    col_label_entries =
      assigns.col_labels
      |> Enum.with_index()
      |> Enum.map(fn {lbl, i} ->
        px = vp.pl + (i + 0.5) * cell_w
        %{label: lbl, px: Float.round(px, 2), py: vp.pt - 6}
      end)

    [low_color, high_color] =
      case assigns.color_scale do
        [l, h | _] -> [l, h]
        [l] -> [l, l]
        [] -> ["oklch(0.95 0.05 240)", "oklch(0.55 0.22 240)"]
      end

    assigns =
      assigns
      |> assign(:cells, cells)
      |> assign(:row_label_entries, row_label_entries)
      |> assign(:col_label_entries, col_label_entries)
      |> assign(:low_color, low_color)
      |> assign(:high_color, high_color)
      |> assign(:viewbox, ChartViewport.viewbox(vp))
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
      >
        <title :if={@title}>{@title}</title>
        <desc :if={@description} id={"#{@chart_id}-desc"}>{@description}</desc>
        <%!-- Row labels --%>
        <text
          :for={e <- @row_label_entries}
          x={e.px}
          y={e.py}
          text-anchor="end"
          dominant-baseline="middle"
          font-size={@theme.axis.font_size}
          class={@theme.axis.label_class}
        >{e.label}</text>

        <%!-- Column labels --%>
        <text
          :for={e <- @col_label_entries}
          x={e.px}
          y={e.py}
          text-anchor="middle"
          dominant-baseline="auto"
          font-size={@theme.axis.font_size}
          class={@theme.axis.label_class}
        >{e.label}</text>

        <%!-- Cells --%>
        <%!-- Color is interpolated inline via CSS color-mix or just use low/high with opacity --%>
        <rect
          :for={cell <- @cells}
          x={cell.x}
          y={cell.y}
          width={cell.w}
          height={cell.h}
          rx="2"
          fill={if cell.intensity > 0.5, do: @high_color, else: @low_color}
          fill-opacity={Float.round(0.15 + cell.intensity * 0.85, 3)}
          style={
            if @animate do
              "animation: phia-fade-in #{@animation_duration}ms ease-out #{cell.delay_ms}ms both"
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
