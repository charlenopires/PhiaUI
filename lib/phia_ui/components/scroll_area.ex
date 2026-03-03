defmodule PhiaUi.Components.ScrollArea do
  @moduledoc """
  ScrollArea component — a styled scrollable container. Zero JavaScript.

  Applies Tailwind utility classes for overflow control and thin, unobtrusive
  scrollbars using the `scrollbar-*` utility family (requires `tailwind-scrollbar`
  or equivalent plugin in the host project's Tailwind config).

  ## Orientations

  - `"vertical"` (default) — `overflow-y-auto h-full`
  - `"horizontal"` — `overflow-x-auto w-full`
  - `"both"` — `overflow-auto`

  ## Example

      <%# Default vertical scroll %>
      <.scroll_area class="max-h-64">
        <%= for item <- @items do %>
          <p>{item.name}</p>
        <% end %>
      </.scroll_area>

      <%# Horizontal scroll for a wide table %>
      <.scroll_area orientation="horizontal">
        <table>...</table>
      </.scroll_area>

      <%# Both axes %>
      <.scroll_area orientation="both" class="h-96 w-full">
        <div class="min-w-[800px]">...</div>
      </.scroll_area>

  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:orientation, :string,
    default: "vertical",
    values: ~w(vertical horizontal both),
    doc: "Scroll direction: vertical (default), horizontal, or both"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes (merged via cn/1)")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc """
  Renders a styled scrollable container.

  Scrollbar appearance is kept minimal using semantic Tailwind tokens so it
  looks consistent across light and dark modes without any custom CSS.
  """
  def scroll_area(assigns) do
    ~H"""
    <div
      class={cn([
        orientation_class(@orientation),
        "scrollbar-thin scrollbar-track-transparent scrollbar-thumb-muted-foreground/30",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp orientation_class("vertical"), do: "overflow-y-auto h-full"
  defp orientation_class("horizontal"), do: "overflow-x-auto w-full"
  defp orientation_class("both"), do: "overflow-auto"
end
