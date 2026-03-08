defmodule PhiaUi.Components.Layout.SimpleGrid do
  @moduledoc """
  Auto-responsive equal-width grid — no manual breakpoints required.

  Two operating modes:

  1. **`cols` preset** — sets responsive breakpoints automatically:
     `grid-cols-1 sm:grid-cols-2 md:grid-cols-N lg:grid-cols-N`

  2. **`min_child_width` (CSS auto-fit)** — uses inline style with
     `repeat(auto-fit, minmax(min(Xpx, 100%), 1fr))` so columns form and dissolve
     automatically as the container resizes. The `min()` wrapper prevents overflow
     when the container is narrower than `min_child_width`.

  When `container_query` is enabled, the grid uses `@container` query classes
  (`@sm:`, `@md:`, etc.) instead of viewport breakpoints, so columns respond to
  the container width rather than the viewport.

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

      <%!-- Container-query mode: responds to parent width --%>
      <.simple_grid cols={3} gap={4} container_query>
        <.card>A</.card>
        <.card>B</.card>
        <.card>C</.card>
      </.simple_grid>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.ResponsiveHelpers, only: [resolve_responsive: 2, container_classes: 2]

  attr(:cols, :integer,
    default: nil,
    doc: "Preset column count (1–6). Sets responsive `sm/md/lg` breakpoints automatically."
  )

  attr(:min_child_width, :string,
    default: nil,
    doc: "CSS width (e.g. `\"200px\"`) for `auto-fit minmax`. Takes priority over `cols`."
  )

  attr(:gap, :any, default: 4, doc: "Uniform gap (0–12) → `gap-N`. Accepts integer or responsive map.")

  attr(:container_query, :boolean,
    default: false,
    doc: "Use `@container` query classes instead of viewport breakpoints."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element.")

  slot(:inner_block, required: true, doc: "Grid children.")

  @doc "Renders an auto-responsive equal-width grid."
  def simple_grid(assigns) do
    ~H"""
    <div
      class={cn([
        "grid",
        responsive(@gap, &gap_class/1),
        grid_cols_class(@cols, @min_child_width, @container_query),
        @container_query && "@container",
        @class
      ])}
      style={grid_style(@min_child_width)}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp responsive(value, mapper) do
    resolve_responsive(value, mapper)
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
    |> case do
      "" -> nil
      s -> s
    end
  end

  defp gap_class(nil), do: nil
  defp gap_class(n), do: "gap-#{n}"

  defp grid_cols_class(_cols, min_child_width, _cq) when is_binary(min_child_width), do: nil
  defp grid_cols_class(nil, _, _cq), do: "grid-cols-1"

  defp grid_cols_class(n, _, true) do
    container_classes(responsive_preset(n), &cols_mapper/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
    |> case do
      "" -> nil
      s -> s
    end
  end

  defp grid_cols_class(1, _, false), do: "grid-cols-1"
  defp grid_cols_class(2, _, false), do: "grid-cols-1 sm:grid-cols-2"
  defp grid_cols_class(3, _, false), do: "grid-cols-1 sm:grid-cols-2 md:grid-cols-3"
  defp grid_cols_class(4, _, false), do: "grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4"
  defp grid_cols_class(5, _, false), do: "grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-5"
  defp grid_cols_class(6, _, false), do: "grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-6"
  defp grid_cols_class(n, _, false), do: "grid-cols-#{n}"

  # Converts a cols count into a responsive breakpoint map for container queries.
  defp responsive_preset(1), do: %{base: 1}
  defp responsive_preset(2), do: %{base: 1, sm: 2}
  defp responsive_preset(3), do: %{base: 1, sm: 2, md: 3}
  defp responsive_preset(4), do: %{base: 1, sm: 2, md: 3, lg: 4}
  defp responsive_preset(5), do: %{base: 1, sm: 2, md: 3, lg: 5}
  defp responsive_preset(6), do: %{base: 1, sm: 2, md: 3, lg: 6}
  defp responsive_preset(n), do: %{base: n}

  defp cols_mapper(n), do: "grid-cols-#{n}"

  defp grid_style(nil), do: nil

  defp grid_style(min_w) do
    "grid-template-columns: repeat(auto-fit, minmax(min(#{min_w}, 100%), 1fr))"
  end
end
