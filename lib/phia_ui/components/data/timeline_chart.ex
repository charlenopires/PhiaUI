defmodule PhiaUi.Components.TimelineChart do
  @moduledoc """
  Horizontal event timeline — pure SVG, zero JS.

  Renders events as labeled markers on a horizontal axis. Events animate
  in with staggered pop-in.

  ## Examples

      <.timeline_chart events={[
        %{label: "Kickoff",  date: "Jan 2024", description: "Project started"},
        %{label: "Beta",     date: "Mar 2024", description: "First beta release"},
        %{label: "Launch",   date: "Jun 2024", description: "Public launch"}
      ]} />

      <.timeline_chart
        events={[
          %{label: "v1.0", date: "Q1", color: "oklch(0.60 0.20 240)"},
          %{label: "v2.0", date: "Q3", color: "oklch(0.70 0.18 145)"}
        ]}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers

  @vw 420
  @vh 160
  @pl 20
  @pr 20
  @axis_y 80

  attr :events, :list, required: true, doc: "List of `%{label, date}` (and optional `:description`, `:color`)."
  attr :colors, :list, default: [], doc: "Override default palette."
  attr :animate, :boolean, default: true
  attr :animation_duration, :integer, default: 500
  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def timeline_chart(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"

    n = length(assigns.events)
    chart_w = @vw - @pl - @pr

    event_markers =
      assigns.events
      |> Enum.with_index()
      |> Enum.map(fn {ev, i} ->
        x = @pl + i / max(n - 1, 1) * chart_w
        color = Map.get(ev, :color) || ChartHelpers.chart_color(i, assigns.colors)

        # Alternate labels above/below axis
        above? = rem(i, 2) == 0
        label_y = if above?, do: @axis_y - 32, else: @axis_y + 32

        %{
          x: Float.round(x, 2),
          label: ev.label,
          date: ev.date,
          description: Map.get(ev, :description),
          color: color,
          above: above?,
          label_y: label_y,
          delay_ms: i * 80
        }
      end)

    assigns =
      assigns
      |> assign(:event_markers, event_markers)
      |> assign(:axis_y, @axis_y)
      |> assign(:axis_x1, @pl)
      |> assign(:axis_x2, @pl + chart_w)
      |> assign(:chart_id, chart_id)
      |> assign(:viewbox, "0 0 #{@vw} #{@vh}")

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
        <%!-- Axis line --%>
        <line
          x1={@axis_x1}
          y1={@axis_y}
          x2={@axis_x2}
          y2={@axis_y}
          stroke="currentColor"
          stroke-width="1.5"
          class="text-border"
        />

        <%!-- Event markers --%>
        <g :for={ev <- @event_markers}>
          <%!-- Connector line --%>
          <line
            x1={ev.x}
            y1={@axis_y}
            x2={ev.x}
            y2={ev.label_y + if(ev.above, do: 20, else: -20)}
            stroke={ev.color}
            stroke-width="1"
            stroke-dasharray="3 3"
            style={
              if @animate do
                "animation: phia-fade-in #{@animation_duration}ms ease-out #{ev.delay_ms}ms both"
              else
                ""
              end
            }
          />

          <%!-- Circle marker on axis --%>
          <circle
            cx={ev.x}
            cy={@axis_y}
            r="5"
            fill={ev.color}
            style={
              if @animate do
                "transform-box: fill-box; transform-origin: center; animation: phia-dot-pop #{@animation_duration}ms ease-out #{ev.delay_ms}ms both"
              else
                ""
              end
            }
          />

          <%!-- Date label --%>
          <text
            x={ev.x}
            y={@axis_y + if(ev.above, do: 14, else: -14)}
            text-anchor="middle"
            font-size="8"
            class="fill-muted-foreground"
          >{ev.date}</text>

          <%!-- Event label --%>
          <text
            x={ev.x}
            y={ev.label_y}
            text-anchor="middle"
            dominant-baseline={if ev.above, do: "auto", else: "hanging"}
            font-size="9"
            font-weight="600"
            class="fill-foreground"
          >{ev.label}</text>

          <%!-- Description --%>
          <text
            :if={ev.description}
            x={ev.x}
            y={ev.label_y + if(ev.above, do: -12, else: 12)}
            text-anchor="middle"
            dominant-baseline={if ev.above, do: "auto", else: "hanging"}
            font-size="7.5"
            class="fill-muted-foreground"
          >{ev.description}</text>
        </g>
      </svg>
    </div>
    """
  end
end
