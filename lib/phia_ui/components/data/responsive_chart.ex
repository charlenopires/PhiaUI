defmodule PhiaUi.Components.Data.ResponsiveChart do
  @moduledoc """
  CSS aspect-ratio wrapper for responsive charts — zero JS.

  Inspired by Nivo's ResponsiveWrapper. Wraps chart content in a container
  that maintains a fixed aspect ratio while scaling to fill available width.

  ## Examples

      <.responsive_chart>
        <.bar_chart data={data} />
      </.responsive_chart>

      <.responsive_chart aspect_ratio="16/9" min_height="300px">
        <.line_chart series={series} />
      </.responsive_chart>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :aspect_ratio, :string, default: "4/3", doc: "CSS aspect-ratio value."
  attr :min_height, :string, default: "200px", doc: "Minimum container height."

  attr :breakpoints, :map,
    default: %{},
    doc: """
    CSS container-query-based responsive rules.
    Map of breakpoint name → style overrides: `%{sm: %{aspect_ratio: "1/1"}, lg: %{aspect_ratio: "16/9"}}`.
    Supported keys: :sm (320px), :md (480px), :lg (640px), :xl (800px).
    """

  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  @breakpoint_sizes %{sm: "320px", md: "480px", lg: "640px", xl: "800px"}

  def responsive_chart(assigns) do
    container_style = build_container_style(assigns.breakpoints)
    assigns = assign(assigns, :container_style, container_style)

    ~H"""
    <div
      class={cn(["w-full", if(@breakpoints != %{}, do: "phia-responsive-chart-container"), @class])}
      style={"aspect-ratio: #{@aspect_ratio}; min-height: #{@min_height}; container-type: inline-size;#{@container_style}"}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp build_container_style(breakpoints) when breakpoints == %{}, do: ""

  defp build_container_style(breakpoints) do
    # Container queries are rendered as CSS custom properties that can be used
    # by child components. The actual container queries need to be in CSS.
    breakpoints
    |> Enum.map(fn {bp, opts} ->
      size = Map.get(@breakpoint_sizes, bp, "480px")
      ratio = Map.get(opts, :aspect_ratio, nil)
      if ratio, do: " --phia-bp-#{bp}: #{size}; --phia-bp-#{bp}-ratio: #{ratio};", else: ""
    end)
    |> Enum.join("")
  end
end
