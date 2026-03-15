defmodule PhiaUi.Components.ParliamentChart do
  @moduledoc """
  Parliament chart — pure SVG, zero JS.

  Semicircle of dots representing parliamentary seats.
  Seats are distributed in concentric semicircular rows from inner
  to outer arc. Each party fills seats sequentially so the
  semicircle is visually grouped by faction.

  ## Examples

      <.parliament_chart data={[
        %{label: "Party A", value: 120},
        %{label: "Party B", value: 80},
        %{label: "Party C", value: 30},
        %{label: "Independent", value: 10}
      ]} />

      <.parliament_chart
        data={[%{label: "Yes", value: 60}, %{label: "No", value: 40}]}
        colors={["oklch(0.60 0.20 240)", "oklch(0.60 0.25 0)"]}
        seat_radius={4}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartTheme

  attr :data, :list, default: [], doc: "Party data: `[%{label, value}]` where value = seat count."
  attr :colors, :list, default: [], doc: "Override default palette. CSS color strings."
  attr :seat_radius, :integer, default: 5, doc: "Radius of each seat dot in pixels."
  attr :animate, :boolean, default: true, doc: "Enable entrance animations."
  attr :animation_duration, :integer, default: 600, doc: "Animation duration in ms."
  attr :theme, :map, default: %{}, doc: "Chart theme overrides (see ChartTheme)."
  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def parliament_chart(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"
    theme = ChartTheme.merge(assigns.theme)
    total_seats = assigns.data |> Enum.map(& &1.value) |> Enum.sum() |> max(1)
    width = 300
    height = 170
    center_x = width / 2.0
    center_y = height - 10.0
    max_r = min(center_x - 10, center_y - 10)

    # Lay out seats in concentric semicircular rows
    all_seat_positions = compute_rows(total_seats, max_r, assigns.seat_radius, center_x, center_y)

    # Assign party colors to seats
    {colored_seats, _} =
      assigns.data
      |> Enum.with_index()
      |> Enum.map_reduce(0, fn {item, i}, used ->
        color = ChartHelpers.chart_color(i, assigns.colors)
        count = item.value

        seats =
          Enum.map(used..(used + count - 1)//1, fn idx ->
            seat = Enum.at(all_seat_positions, idx)

            if seat do
              %{cx: f(seat.cx), cy: f(seat.cy), color: color, delay: idx * 5}
            end
          end)
          |> Enum.reject(&is_nil/1)

        {seats, used + count}
      end)

    all_seats = List.flatten(colored_seats)

    legend_items =
      assigns.data
      |> Enum.with_index()
      |> Enum.map(fn {item, i} ->
        %{label: "#{item.label} (#{item.value})", color: ChartHelpers.chart_color(i, assigns.colors)}
      end)

    assigns =
      assigns
      |> assign(:chart_id, chart_id)
      |> assign(:viewbox, "0 0 #{width} #{height}")
      |> assign(:seats, all_seats)
      |> assign(:legend_items, legend_items)
      |> assign(:theme, theme)

    ~H"""
    <div class={cn(["w-full", if(@animate, do: "phia-chart-animate", else: ""), @class])} {@rest}>
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
        <circle
          :for={seat <- @seats}
          cx={seat.cx}
          cy={seat.cy}
          r={@seat_radius}
          fill={seat.color}
          style={
            if @animate,
              do:
                "transform-box: fill-box; transform-origin: center; animation: phia-dot-pop #{@animation_duration}ms ease-out #{seat.delay}ms both",
              else: ""
          }
        />
      </svg>
      <div :if={@legend_items != []} class="flex flex-wrap gap-3 justify-center mt-2 text-xs">
        <div :for={item <- @legend_items} class="flex items-center gap-1.5">
          <span
            class="inline-block size-2.5 rounded-full shrink-0"
            style={"background-color: #{item.color}"}
          />
          <span class="text-muted-foreground">{item.label}</span>
        </div>
      </div>
    </div>
    """
  end

  # Generates seat positions in concentric semicircular rows, inner to outer.
  # Returns a flat list of `%{cx, cy}` maps, total count >= `total_seats`.
  defp compute_rows(total, max_r, seat_r, center_x, center_y) do
    spacing = seat_r * 2.5
    n_rows = max(trunc(max_r / spacing), 1)

    rows =
      Enum.flat_map(1..n_rows, fn row ->
        r = max_r - (n_rows - row) * spacing

        if r < seat_r * 2 do
          []
        else
          generate_row(r, seat_r, center_x, center_y)
        end
      end)

    Enum.take(rows, total)
  end

  # Places seats evenly along a semicircular arc of radius `r` centered at `(cx, cy)`.
  defp generate_row(r, seat_r, cx, cy) do
    circumference = :math.pi() * r
    n_seats = max(trunc(circumference / (seat_r * 2.5)), 1)

    Enum.map(0..(n_seats - 1), fn i ->
      angle =
        if n_seats <= 1 do
          :math.pi() * 1.5
        else
          :math.pi() + i / (n_seats - 1) * :math.pi()
        end

      x = cx + r * :math.cos(angle)
      y = cy + r * :math.sin(angle)
      %{cx: x, cy: y}
    end)
  end

  defp f(v), do: Float.round(v * 1.0, 2)
end
