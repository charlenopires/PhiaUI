defmodule PhiaUi.Components.Layout.MasonryGrid do
  @moduledoc """
  CSS `columns` masonry grid — items flow top-to-bottom in columns like a
  Pinterest board or photo wall.

  Unlike CSS Grid, items fill columns from top to bottom, so shorter items
  pack into gaps left by taller items. Use `break-inside-avoid` on children
  to prevent items from splitting across columns.

  All layout attributes accept either a plain value (backward compatible) or a
  responsive map like `%{base: 1, md: 3}` for per-breakpoint control.

  ## Examples

      <%!-- 3-column masonry --%>
      <.masonry_grid cols={3} gap={4}>
        <%= for card <- @cards do %>
          <div class="break-inside-avoid mb-4">
            <.card>{card.content}</.card>
          </div>
        <% end %>
      </.masonry_grid>

      <%!-- Responsive masonry: 1 col on mobile, 2 from md, 3 from lg --%>
      <.masonry_grid cols={%{base: 1, md: 2, lg: 3}} gap={%{base: 2, md: 4}}>
        ...
      </.masonry_grid>

      <%!-- 2-column narrow layout --%>
      <.masonry_grid cols={2} gap={3}>
        ...
      </.masonry_grid>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.ResponsiveHelpers, only: [resolve_responsive: 2]

  attr(:cols, :any,
    default: 3,
    doc: "Number of columns (1–5) → `columns-N`. Accepts integer or responsive map."
  )

  attr(:gap, :any, default: 4, doc: "Gap between columns (0–12) → `gap-N`. Accepts integer or responsive map.")

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element.")

  slot(:inner_block, required: true, doc: "Masonry children (use `break-inside-avoid` on each).")

  @doc "Renders a CSS columns masonry grid."
  def masonry_grid(assigns) do
    ~H"""
    <div
      class={cn([
        responsive(@cols, &cols_class/1),
        responsive(@gap, &gap_class/1),
        @class
      ])}
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

  defp cols_class(1), do: "columns-1"
  defp cols_class(2), do: "columns-2"
  defp cols_class(3), do: "columns-3"
  defp cols_class(4), do: "columns-4"
  defp cols_class(5), do: "columns-5"
  defp cols_class(n), do: "columns-#{n}"

  defp gap_class(nil), do: nil
  defp gap_class(n), do: "gap-#{n}"
end
