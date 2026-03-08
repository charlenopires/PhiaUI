defmodule PhiaUi.Components.Data.ChartLabel do
  @moduledoc """
  Flexible SVG text label component with 13 positioning modes.

  Inspired by Recharts' `<Label>` — positions text relative to a bounding box
  using intuitive position atoms.

  ## Examples

      <.chart_label
        value="42"
        position={:top}
        x={100}
        y={50}
        width={80}
        height={30}
      />

      <.chart_label value="Max" position={:inside_top_right} x={10} y={10} width={200} height={100} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :value, :any, required: true, doc: "Label text content."

  attr :position, :atom,
    default: :top,
    values: [
      :top,
      :bottom,
      :left,
      :right,
      :center,
      :inside_top,
      :inside_bottom,
      :inside_left,
      :inside_right,
      :inside_top_left,
      :inside_top_right,
      :inside_bottom_left,
      :inside_bottom_right
    ],
    doc: "Label position relative to the bounding box."

  attr :x, :any, default: 0, doc: "Bounding box X origin."
  attr :y, :any, default: 0, doc: "Bounding box Y origin."
  attr :width, :any, default: 0, doc: "Bounding box width."
  attr :height, :any, default: 0, doc: "Bounding box height."
  attr :offset, :integer, default: 5, doc: "Offset from edge in px."
  attr :font_size, :string, default: "9", doc: "Font size for the label."
  attr :color, :string, default: nil, doc: "Fill color override."
  attr :class, :string, default: nil
  attr :rest, :global

  def chart_label(assigns) do
    x = to_number(assigns.x)
    y = to_number(assigns.y)
    w = to_number(assigns.width)
    h = to_number(assigns.height)
    offset = assigns.offset

    {text_x, text_y, anchor, baseline} =
      compute_position(assigns.position, x, y, w, h, offset)

    assigns =
      assigns
      |> assign(:text_x, Float.round(text_x * 1.0, 2))
      |> assign(:text_y, Float.round(text_y * 1.0, 2))
      |> assign(:anchor, anchor)
      |> assign(:baseline, baseline)

    ~H"""
    <text
      x={@text_x}
      y={@text_y}
      text-anchor={@anchor}
      dominant-baseline={@baseline}
      font-size={@font_size}
      fill={@color}
      class={cn(["fill-muted-foreground", @class])}
      {@rest}
    >{@value}</text>
    """
  end

  # ---------------------------------------------------------------------------
  # Position computation
  # ---------------------------------------------------------------------------

  defp compute_position(:top, x, y, w, _h, offset),
    do: {x + w / 2, y - offset, "middle", "auto"}

  defp compute_position(:bottom, x, y, w, h, offset),
    do: {x + w / 2, y + h + offset, "middle", "hanging"}

  defp compute_position(:left, x, y, _w, h, offset),
    do: {x - offset, y + h / 2, "end", "middle"}

  defp compute_position(:right, x, y, w, h, offset),
    do: {x + w + offset, y + h / 2, "start", "middle"}

  defp compute_position(:center, x, y, w, h, _offset),
    do: {x + w / 2, y + h / 2, "middle", "middle"}

  defp compute_position(:inside_top, x, y, w, _h, offset),
    do: {x + w / 2, y + offset, "middle", "hanging"}

  defp compute_position(:inside_bottom, x, y, w, h, offset),
    do: {x + w / 2, y + h - offset, "middle", "auto"}

  defp compute_position(:inside_left, x, y, _w, h, offset),
    do: {x + offset, y + h / 2, "start", "middle"}

  defp compute_position(:inside_right, x, y, w, h, offset),
    do: {x + w - offset, y + h / 2, "end", "middle"}

  defp compute_position(:inside_top_left, x, y, _w, _h, offset),
    do: {x + offset, y + offset, "start", "hanging"}

  defp compute_position(:inside_top_right, x, y, w, _h, offset),
    do: {x + w - offset, y + offset, "end", "hanging"}

  defp compute_position(:inside_bottom_left, x, y, _w, h, offset),
    do: {x + offset, y + h - offset, "start", "auto"}

  defp compute_position(:inside_bottom_right, x, y, w, h, offset),
    do: {x + w - offset, y + h - offset, "end", "auto"}

  defp to_number(v) when is_integer(v), do: v * 1.0
  defp to_number(v) when is_float(v), do: v
  defp to_number(v) when is_binary(v) do
    case Float.parse(v) do
      {f, _} -> f
      :error -> 0.0
    end
  end
  defp to_number(_), do: 0.0
end
