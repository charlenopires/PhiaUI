defmodule PhiaUi.Components.Data.ChartNoData do
  @moduledoc """
  Empty state placeholder for charts — displays when no data is available.

  Inspired by Tremor's NoData component. Renders a dashed border container
  with a centered message.

  ## Examples

      <.chart_no_data />
      <.chart_no_data text="No results found" class="h-80" />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :text, :string, default: "No data", doc: "Message to display."
  attr :class, :string, default: nil
  attr :rest, :global

  def chart_no_data(assigns) do
    ~H"""
    <div
      class={cn([
        "flex items-center justify-center w-full h-full",
        "border border-dashed rounded-lg",
        "border-border",
        @class
      ])}
      {@rest}
    >
      <p class="text-sm text-muted-foreground">{@text}</p>
    </div>
    """
  end
end
