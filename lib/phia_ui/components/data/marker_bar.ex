defmodule PhiaUi.Components.Data.MarkerBar do
  @moduledoc """
  Progress bar with a positioned marker indicator.

  Inspired by Tremor's MarkerBar component. Renders a horizontal bar with
  a vertical marker at a specific position. Useful for showing current value
  against a range.

  ## Examples

      <.marker_bar value={62} />
      <.marker_bar value={80} color="oklch(0.60 0.20 240)" show_animation />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :value, :any, required: true, doc: "Marker position (0-100)."
  attr :color, :string, default: nil, doc: "Marker color. Defaults to primary."
  attr :show_animation, :boolean, default: false, doc: "Animate the marker position."
  attr :tooltip, :string, default: nil, doc: "Tooltip text."
  attr :class, :string, default: nil
  attr :rest, :global

  def marker_bar(assigns) do
    clamped = max(0, min(100, assigns.value || 0))
    transition = if assigns.show_animation, do: "transition-all duration-1000", else: ""

    assigns =
      assigns
      |> assign(:clamped, clamped)
      |> assign(:transition, transition)

    ~H"""
    <div
      class={cn([
        "relative w-full rounded-full h-2",
        "bg-muted",
        @class
      ])}
      title={@tooltip}
      {@rest}
    >
      <div
        class={cn([
          "absolute right-1/2 -translate-x-1/2 w-5",
          @transition
        ])}
        style={"left: #{@clamped}%"}
      >
        <div
          class={cn([
            "ring-2 mx-auto rounded-full h-4 w-1",
            "ring-background"
          ])}
          style={if @color, do: "background-color: #{@color}", else: nil}
        >
          <div
            :if={!@color}
            class="w-full h-full rounded-full bg-primary"
          />
        </div>
      </div>
    </div>
    """
  end
end
