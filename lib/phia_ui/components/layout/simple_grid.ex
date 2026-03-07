defmodule PhiaUi.Components.Layout.SimpleGrid do
  @moduledoc """
  Auto-responsive equal-width grid — no manual breakpoints required.

  Two operating modes:

  1. **`cols` preset** — sets responsive breakpoints automatically:
     `grid-cols-1 sm:grid-cols-2 md:grid-cols-N lg:grid-cols-N`

  2. **`min_child_width` (CSS auto-fit)** — uses inline style with
     `repeat(auto-fit, minmax(Xpx, 1fr))` so columns form and dissolve
     automatically as the container resizes.

  ## Examples

      <%!-- 3-col responsive with preset breakpoints --%>
      <.simple_grid cols={3} gap={4}>
        <.card>A</.card>
        <.card>B</.card>
        <.card>C</.card>
        <.card>D</.card>
      </.simple_grid>

      <%!-- Auto-fit: any number of cols from 200px children --%>
      <.simple_grid min_child_width="200px" gap={4}>
        <%= for item <- @items do %>
          <.card>{item}</.card>
        <% end %>
      </.simple_grid>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:cols, :integer,
    default: nil,
    doc: "Preset column count (1–6). Sets responsive `sm/md/lg` breakpoints automatically."
  )

  attr(:min_child_width, :string,
    default: nil,
    doc: "CSS width (e.g. `\"200px\"`) for `auto-fit minmax`. Takes priority over `cols`."
  )

  attr(:gap, :integer, default: 4, doc: "Uniform gap (0–12) → `gap-N`.")

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element.")

  slot(:inner_block, required: true, doc: "Grid children.")

  @doc "Renders an auto-responsive equal-width grid."
  def simple_grid(assigns) do
    ~H"""
    <div
      class={cn(["grid", "gap-#{@gap}", grid_cols_class(@cols, @min_child_width), @class])}
      style={grid_style(@min_child_width)}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp grid_cols_class(_cols, min_child_width) when is_binary(min_child_width), do: nil
  defp grid_cols_class(nil, _), do: "grid-cols-1"
  defp grid_cols_class(1, _), do: "grid-cols-1"
  defp grid_cols_class(2, _), do: "grid-cols-1 sm:grid-cols-2"
  defp grid_cols_class(3, _), do: "grid-cols-1 sm:grid-cols-2 md:grid-cols-3"
  defp grid_cols_class(4, _), do: "grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4"
  defp grid_cols_class(5, _), do: "grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-5"
  defp grid_cols_class(6, _), do: "grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-6"
  defp grid_cols_class(n, _), do: "grid-cols-#{n}"

  defp grid_style(nil), do: nil
  defp grid_style(min_w), do: "grid-template-columns: repeat(auto-fit, minmax(#{min_w}, 1fr))"
end
