defmodule PhiaUi.Components.MetricGrid do
  @moduledoc """
  Responsive grid wrapper for multiple `stat_card/1` widgets.

  Automatically adjusts column count across breakpoints so dashboards
  look great on every screen size without custom CSS.

  ## Column breakpoints

  | `:cols` | Mobile (< sm) | Tablet (sm) | Desktop (lg) |
  |---------|--------------|-------------|-------------|
  | `1`     | 1            | 1           | 1           |
  | `2`     | 1            | 2           | 2           |
  | `3`     | 1            | 2           | 3           |
  | `4`     | 1            | 2           | 4           |

  ## Example

      <.metric_grid cols={4}>
        <.stat_card title="Revenue" value="$12,345" trend={:up} trend_value="+8%" />
        <.stat_card title="Users" value="1,024" trend={:up} trend_value="+3%" />
        <.stat_card title="Churn" value="2.1%" trend={:down} trend_value="-0.4%" />
        <.stat_card title="NPS" value="62" trend={:neutral} trend_value="→" />
      </.metric_grid>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr :cols, :integer,
    values: [1, 2, 3, 4],
    default: 4,
    doc: "Number of columns in the grid (1–4). Responsive breakpoints applied automatically."

  attr :class, :string, default: nil, doc: "Additional CSS classes for the grid wrapper"

  attr :rest, :global, doc: "HTML attributes forwarded to the wrapper div"

  slot :inner_block, required: true, doc: "stat_card children to render inside the grid"

  @doc "Renders a responsive CSS Grid wrapper for dashboard stat cards."
  def metric_grid(assigns) do
    ~H"""
    <div class={cn(["grid gap-4", grid_class(@cols), @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers — pattern matching, never case/cond
  # ---------------------------------------------------------------------------

  defp grid_class(1), do: "grid-cols-1"
  defp grid_class(2), do: "grid-cols-1 sm:grid-cols-2"
  defp grid_class(3), do: "grid-cols-1 sm:grid-cols-2 lg:grid-cols-3"
  defp grid_class(4), do: "grid-cols-1 sm:grid-cols-2 lg:grid-cols-4"
end
