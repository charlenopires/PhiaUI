defmodule PhiaUi.Components.Layout.SplitLayout do
  @moduledoc """
  Two-column layout: a fixed-width pane alongside flexible main content.

  Simpler than `page_layout` — no header/footer slots, just a pane and main
  content area. Ideal for list-detail, settings panels, and inspector UIs.

  ## Examples

      <%!-- List-detail pattern --%>
      <.split_layout>
        <:pane>
          <ul>
            <%= for item <- @items do %>
              <li phx-click="select" phx-value-id={item.id}>{item.name}</li>
            <% end %>
          </ul>
        </:pane>
        <div class="p-6">
          <%= if @selected do %>
            <h1>{@selected.name}</h1>
          <% end %>
        </div>
      </.split_layout>

      <%!-- Right pane inspector --%>
      <.split_layout pane_position={:end} pane_width={:md}>
        <:pane><aside class="p-4">Properties</aside></:pane>
        <div class="p-6">Canvas area</div>
      </.split_layout>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:pane_position, :atom,
    default: :start,
    values: [:start, :end],
    doc: "Pane position: `:start` (left) or `:end` (right)."
  )

  attr(:pane_width, :atom,
    default: :sm,
    values: [:xs, :sm, :md, :lg],
    doc: "Fixed width of the pane."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element.")

  slot(:pane, required: true, doc: "Fixed-width secondary panel.")
  slot(:inner_block, required: true, doc: "Flexible main content area.")

  @doc "Renders a two-column split layout."
  def split_layout(assigns) do
    ~H"""
    <div class={cn(["flex min-h-0", pane_order_class(@pane_position), @class])} {@rest}>
      <div class={cn(["shrink-0 border-r border-border overflow-y-auto", pane_width_class(@pane_width)])}>
        <%= render_slot(@pane) %>
      </div>
      <main class="flex-1 min-w-0 overflow-y-auto">
        <%= render_slot(@inner_block) %>
      </main>
    </div>
    """
  end

  defp pane_order_class(:start), do: nil
  defp pane_order_class(:end), do: "flex-row-reverse"

  defp pane_width_class(:xs), do: "w-48"
  defp pane_width_class(:sm), do: "w-64"
  defp pane_width_class(:md), do: "w-80"
  defp pane_width_class(:lg), do: "w-96"
end
