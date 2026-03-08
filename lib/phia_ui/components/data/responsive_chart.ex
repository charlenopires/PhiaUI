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
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  def responsive_chart(assigns) do
    ~H"""
    <div
      class={cn(["w-full", @class])}
      style={"aspect-ratio: #{@aspect_ratio}; min-height: #{@min_height}"}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
