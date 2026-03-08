defmodule PhiaUi.Components.Data.DeltaBar do
  @moduledoc """
  Horizontal bar showing positive/negative delta from a center point.

  Inspired by Tremor's DeltaBar component. The bar is split in half with
  a center divider. Positive values extend right, negative extend left.
  Color changes based on whether increase is considered positive.

  ## Examples

      <.delta_bar value={25} />
      <.delta_bar value={-15} is_increase_positive={false} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :value, :any, required: true, doc: "Delta value (-100 to 100)."

  attr :is_increase_positive, :boolean,
    default: true,
    doc: "If true, positive values are green; if false, positive values are red."

  attr :show_animation, :boolean, default: false, doc: "Animate the bar width."
  attr :tooltip, :string, default: nil, doc: "Tooltip text."
  attr :class, :string, default: nil
  attr :rest, :global

  def delta_bar(assigns) do
    value = assigns.value || 0
    clamped = max(-100, min(100, value))
    is_positive = clamped >= 0

    color_class =
      cond do
        assigns.is_increase_positive && is_positive -> "bg-emerald-500"
        assigns.is_increase_positive && !is_positive -> "bg-rose-500"
        !assigns.is_increase_positive && is_positive -> "bg-rose-500"
        true -> "bg-emerald-500"
      end

    bar_width = abs(clamped)
    transition = if assigns.show_animation, do: "transition-all duration-500", else: ""

    assigns =
      assigns
      |> assign(:is_positive, is_positive)
      |> assign(:color_class, color_class)
      |> assign(:bar_width, bar_width)
      |> assign(:transition, transition)

    ~H"""
    <div
      class={cn([
        "relative flex items-center w-full rounded-full h-2",
        "bg-muted",
        @class
      ])}
      title={@tooltip}
      {@rest}
    >
      <div class="flex justify-end h-full w-1/2">
        <div
          :if={!@is_positive}
          class={cn(["rounded-l-full h-full", @color_class, @transition])}
          style={"width: #{@bar_width}%"}
        />
      </div>
      <div class={cn([
        "ring-2 z-10 rounded-full h-4 w-1",
        "ring-background bg-foreground"
      ])} />
      <div class="flex justify-start h-full w-1/2">
        <div
          :if={@is_positive}
          class={cn(["rounded-r-full h-full", @color_class, @transition])}
          style={"width: #{@bar_width}%"}
        />
      </div>
    </div>
    """
  end
end
