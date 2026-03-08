defmodule PhiaUi.Components.Data.VisualMap do
  @moduledoc """
  Color scale legend component for charts.

  Renders an SVG gradient bar with min/max labels, showing the color mapping
  for a continuous data range. Inspired by eCharts `visualMap` UI control.

  ## Examples

      <.visual_map
        min={0}
        max={100}
        colors={["oklch(0.95 0.05 240)", "oklch(0.55 0.22 240)"]}
      />

      <.visual_map
        min={0}
        max={500}
        colors={["oklch(0.95 0.05 120)", "oklch(0.70 0.15 60)", "oklch(0.50 0.25 0)"]}
        orientation={:vertical}
        width={20}
        height={200}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :min, :any, default: 0, doc: "Minimum data value."
  attr :max, :any, default: 100, doc: "Maximum data value."

  attr :colors, :list,
    default: ["oklch(0.95 0.05 240)", "oklch(0.55 0.22 240)"],
    doc: "List of OKLCH color strings for the gradient (min → max)."

  attr :orientation, :atom,
    default: :horizontal,
    values: [:horizontal, :vertical],
    doc: "Gradient orientation."

  attr :width, :any, default: nil, doc: "Width in pixels. Defaults based on orientation."
  attr :height, :any, default: nil, doc: "Height in pixels. Defaults based on orientation."
  attr :show_labels, :boolean, default: true, doc: "Show min/max labels."
  attr :label_format, :any, default: nil, doc: "Optional format function for labels."
  attr :class, :string, default: nil
  attr :rest, :global

  def visual_map(assigns) do
    w = assigns.width || if(assigns.orientation == :horizontal, do: 200, else: 20)
    h = assigns.height || if(assigns.orientation == :horizontal, do: 20, else: 200)
    grad_id = "vmap-#{System.unique_integer([:positive])}"

    stops = build_stops(assigns.colors)
    min_label = format_label(assigns.min, assigns.label_format)
    max_label = format_label(assigns.max, assigns.label_format)

    assigns =
      assigns
      |> assign(:w, w)
      |> assign(:h, h)
      |> assign(:grad_id, grad_id)
      |> assign(:stops, stops)
      |> assign(:min_label, min_label)
      |> assign(:max_label, max_label)

    ~H"""
    <div
      class={cn(["inline-flex items-center gap-2", if(@orientation == :vertical, do: "flex-col", else: ""), @class])}
      role="img"
      aria-label={"Color scale from #{@min_label} to #{@max_label}"}
      {@rest}
    >
      <%!-- Min label --%>
      <span :if={@show_labels} class="text-xs text-muted-foreground shrink-0">
        {@min_label}
      </span>

      <%!-- Gradient bar --%>
      <svg
        width={@w}
        height={@h}
        viewBox={"0 0 #{@w} #{@h}"}
        aria-hidden="true"
      >
        <defs>
          <linearGradient
            id={@grad_id}
            x1={if(@orientation == :horizontal, do: "0%", else: "0%")}
            y1={if(@orientation == :horizontal, do: "0%", else: "100%")}
            x2={if(@orientation == :horizontal, do: "100%", else: "0%")}
            y2={if(@orientation == :horizontal, do: "0%", else: "0%")}
          >
            <stop
              :for={stop <- @stops}
              offset={stop.offset}
              stop-color={stop.color}
            />
          </linearGradient>
        </defs>
        <rect
          x="0"
          y="0"
          width={@w}
          height={@h}
          rx="2"
          fill={"url(##{@grad_id})"}
        />
      </svg>

      <%!-- Max label --%>
      <span :if={@show_labels} class="text-xs text-muted-foreground shrink-0">
        {@max_label}
      </span>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------

  defp build_stops(colors) when is_list(colors) do
    n = length(colors)

    if n <= 1 do
      color = List.first(colors) || "currentColor"
      [%{offset: "0%", color: color}, %{offset: "100%", color: color}]
    else
      colors
      |> Enum.with_index()
      |> Enum.map(fn {color, i} ->
        pct = Float.round(i / (n - 1) * 100, 1)
        %{offset: "#{pct}%", color: color}
      end)
    end
  end

  defp format_label(value, nil) when is_float(value), do: Float.round(value, 1) |> to_string()
  defp format_label(value, nil), do: to_string(value)
  defp format_label(value, func) when is_function(func, 1), do: func.(value)
end
