defmodule PhiaUi.Components.Data.BarTotals do
  @moduledoc """
  Sum labels rendered above stacked bar groups — pure SVG, zero JS.

  Inspired by Nivo's BarTotals layer. Renders `<text>` elements showing
  the total value at the top of each stacked bar group.

  Designed to be composed inside a bar chart or xy_chart SVG.

  ## Examples

      <.bar_totals totals={[
        %{x: 72.0, y: 20.0, label: "350"},
        %{x: 152.0, y: 30.0, label: "280"}
      ]} />
  """

  use Phoenix.Component

  alias PhiaUi.Components.Data.ChartTheme

  attr :totals, :list, required: true, doc: "List of `%{x, y, label}` for each group total."
  attr :font_size, :string, default: nil, doc: "Override font size (defaults to theme)."
  attr :offset, :integer, default: 6, doc: "Pixels above bar top."
  attr :theme, :map, default: %{}, doc: "Chart theme overrides."
  attr :class, :string, default: nil
  attr :rest, :global

  def bar_totals(assigns) do
    theme = ChartTheme.merge(assigns.theme)
    font_size = assigns.font_size || theme.axis.font_size

    assigns =
      assigns
      |> assign(:resolved_font_size, font_size)
      |> assign(:resolved_class, assigns.class || theme.axis.label_class)

    ~H"""
    <g {@rest}>
      <text
        :for={total <- @totals}
        x={total.x}
        y={total.y - @offset}
        text-anchor="middle"
        dominant-baseline="auto"
        font-size={@resolved_font_size}
        class={@resolved_class}
      >{total.label}</text>
    </g>
    """
  end
end
