defmodule PhiaUi.Components.Layout.MasonryGrid do
  @moduledoc """
  CSS `columns` masonry grid — items flow top-to-bottom in columns like a
  Pinterest board or photo wall.

  Unlike CSS Grid, items fill columns from top to bottom, so shorter items
  pack into gaps left by taller items. Use `break-inside-avoid` on children
  to prevent items from splitting across columns.

  ## Examples

      <%!-- 3-column masonry --%>
      <.masonry_grid cols={3} gap={4}>
        <%= for card <- @cards do %>
          <div class="break-inside-avoid mb-4">
            <.card>{card.content}</.card>
          </div>
        <% end %>
      </.masonry_grid>

      <%!-- 2-column narrow layout --%>
      <.masonry_grid cols={2} gap={3}>
        ...
      </.masonry_grid>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:cols, :integer,
    default: 3,
    doc: "Number of columns (1–5) → `columns-N`."
  )

  attr(:gap, :integer, default: 4, doc: "Gap between columns (0–12) → `gap-N`.")

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element.")

  slot(:inner_block, required: true, doc: "Masonry children (use `break-inside-avoid` on each).")

  @doc "Renders a CSS columns masonry grid."
  def masonry_grid(assigns) do
    ~H"""
    <div class={cn([cols_class(@cols), "gap-#{@gap}", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp cols_class(1), do: "columns-1"
  defp cols_class(2), do: "columns-2"
  defp cols_class(3), do: "columns-3"
  defp cols_class(4), do: "columns-4"
  defp cols_class(5), do: "columns-5"
  defp cols_class(n), do: "columns-#{n}"
end
