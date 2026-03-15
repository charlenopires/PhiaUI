defmodule PhiaUi.Components.WordCloudChart do
  @moduledoc """
  Word cloud chart — pure SVG, zero JS.

  Text elements with varied font sizes arranged via Archimedean
  spiral placement. Font size scales linearly with word value.
  Optionally rotates some words -90 degrees for visual variety.

  ## Examples

      <.word_cloud_chart data={[
        %{text: "Elixir", value: 90},
        %{text: "Phoenix", value: 75},
        %{text: "LiveView", value: 60},
        %{text: "OTP", value: 45},
        %{text: "Erlang", value: 40},
        %{text: "GenServer", value: 30}
      ]} />

      <.word_cloud_chart
        data={[%{text: "Hello", value: 50}, %{text: "World", value: 30}]}
        colors={["oklch(0.60 0.20 240)", "oklch(0.65 0.22 30)"]}
      />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartMathHelpers
  alias PhiaUi.Components.Data.ChartTheme

  attr :data, :list, default: [], doc: "Word data: `[%{text, value}]`."
  attr :colors, :list, default: [], doc: "Override default palette. CSS color strings."
  attr :animate, :boolean, default: true, doc: "Enable entrance animations."
  attr :animation_duration, :integer, default: 800, doc: "Animation duration in ms."
  attr :theme, :map, default: %{}, doc: "Chart theme overrides (see ChartTheme)."
  attr :id, :string, default: nil, doc: "Unique ID for the chart (auto-generated if not provided)."
  attr :title, :string, default: nil, doc: "Chart title rendered above the visualization."
  attr :description, :string, default: nil, doc: "Chart description for context (rendered below title)."
  attr :class, :string, default: nil
  attr :rest, :global

  def word_cloud_chart(assigns) do
    chart_id = assigns.id || "chart-#{System.unique_integer([:positive])}"
    theme = ChartTheme.merge(assigns.theme)
    width = 400
    height = 300

    words =
      if assigns.data != [] do
        ChartMathHelpers.word_cloud_layout(assigns.data, %{width: width, height: height})
      else
        []
      end

    colored_words =
      words
      |> Enum.with_index()
      |> Enum.map(fn {word, i} ->
        word
        |> Map.put(:color, ChartHelpers.chart_color(i, assigns.colors))
        |> Map.put(:delay, i * 30)
        |> Map.put(:transform_attr, build_transform(word))
      end)

    assigns =
      assigns
      |> assign(:chart_id, chart_id)
      |> assign(:viewbox, "0 0 #{width} #{height}")
      |> assign(:words, colored_words)
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
        <text
          :for={word <- @words}
          x={word.x}
          y={word.y}
          text-anchor="middle"
          dominant-baseline="middle"
          font-size={word.font_size}
          fill={word.color}
          transform={word.transform_attr}
          style={
            if @animate,
              do:
                "animation: phia-fade-in #{@animation_duration}ms ease-out #{word.delay}ms both",
              else: ""
          }
        >
          {word.text}
        </text>
      </svg>
    </div>
    """
  end

  defp build_transform(%{rotation: rotation, x: x, y: y}) when rotation != 0 do
    "rotate(#{rotation}, #{x}, #{y})"
  end

  defp build_transform(_word), do: nil
end
