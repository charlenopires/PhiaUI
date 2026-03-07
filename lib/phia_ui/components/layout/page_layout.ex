defmodule PhiaUi.Components.Layout.PageLayout do
  @moduledoc """
  Full-page layout composition: header / pane (sidebar) / main / footer slots.

  Renders as a `flex flex-col min-h-screen` outer container. The header and
  footer are optional; if omitted those slots are simply not rendered. The
  pane (sidebar) can be positioned at `:start` (left) or `:end` (right).

  ## Examples

      <.page_layout>
        <:header>
          <header class="h-16 border-b px-4 flex items-center">Logo</header>
        </:header>
        <:pane>
          <nav class="p-4">Sidebar nav</nav>
        </:pane>
        <div class="p-6">
          <h1>Main content</h1>
        </div>
      </.page_layout>

      <%!-- Right pane --%>
      <.page_layout pane_position={:end} pane_width={:md}>
        <:pane><aside>Details panel</aside></:pane>
        <div>Content</div>
      </.page_layout>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:pane_position, :atom,
    default: :start,
    values: [:start, :end],
    doc: "Sidebar position: `:start` (left) or `:end` (right)."
  )

  attr(:pane_width, :atom,
    default: :sm,
    values: [:xs, :sm, :md, :lg],
    doc: "Fixed width of the pane."
  )

  attr(:padding, :atom,
    default: :normal,
    values: [:none, :condensed, :normal],
    doc: "Inner padding applied to the main content area."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element.")

  slot(:header, doc: "Optional top bar (full width, above the pane+main row).")
  slot(:pane, doc: "Optional sidebar/secondary panel.")
  slot(:footer, doc: "Optional bottom bar (full width, below the pane+main row).")
  slot(:inner_block, required: true, doc: "Main content area.")

  @doc "Renders a full-page layout with optional header, pane, and footer."
  def page_layout(assigns) do
    ~H"""
    <div class={cn(["flex flex-col min-h-screen", @class])} {@rest}>
      <%= if @header != [] do %>
        <div class="shrink-0">
          <%= render_slot(@header) %>
        </div>
      <% end %>

      <div class={cn(["flex flex-1 min-h-0", pane_order_class(@pane_position)])}>
        <%= if @pane != [] do %>
          <div class={cn(["shrink-0 border-r border-border overflow-y-auto", pane_width_class(@pane_width)])}>
            <%= render_slot(@pane) %>
          </div>
        <% end %>
        <main class={cn(["flex-1 min-w-0 overflow-y-auto", padding_class(@padding)])}>
          <%= render_slot(@inner_block) %>
        </main>
      </div>

      <%= if @footer != [] do %>
        <div class="shrink-0">
          <%= render_slot(@footer) %>
        </div>
      <% end %>
    </div>
    """
  end

  defp pane_order_class(:start), do: nil
  defp pane_order_class(:end), do: "flex-row-reverse"

  defp pane_width_class(:xs), do: "w-48"
  defp pane_width_class(:sm), do: "w-64"
  defp pane_width_class(:md), do: "w-80"
  defp pane_width_class(:lg), do: "w-96"

  defp padding_class(:none), do: nil
  defp padding_class(:condensed), do: "p-4"
  defp padding_class(:normal), do: "p-6"
end
