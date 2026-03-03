defmodule PhiaUi.Components.EmptyState do
  @moduledoc """
  Empty state component for displaying when there is no data.

  Pure HEEx — no JavaScript required. Composes naturally inside tables,
  lists, or any view area that may have no records to display.

  ## Slots

  - `:icon` — optional leading icon (any component or SVG)
  - `:title` — required heading for the empty state (required)
  - `:description` — optional supporting text
  - `:action` — optional call-to-action button or link

  ## Examples

      <.empty>
        <:icon><.icon name="inbox" size="lg" /></:icon>
        <:title>No items found</:title>
        <:description>Get started by creating a new item.</:description>
        <:action>
          <.button phx-click="new_item">Create Item</.button>
        </:action>
      </.empty>

      <%!-- Inside a table --%>
      <tr>
        <td colspan="5">
          <.empty>
            <:title>No records</:title>
            <:description>Try adjusting your filters.</:description>
          </.empty>
        </td>
      </tr>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the container")
  attr(:rest, :global, doc: "HTML attributes forwarded to root element")

  slot(:icon, doc: "Icon slot — accepts any icon component or SVG")

  slot(:title, required: true, doc: "Title text for the empty state")

  slot(:description, doc: "Optional description text")

  slot(:action, doc: "Optional action button or link")

  @doc """
  Renders an empty state component with optional icon, title, description, and action slots.

  Use this component wherever a list, table, or content area may have no data to display.
  All layout is pure CSS flex — no JavaScript needed.
  """
  def empty(assigns) do
    ~H"""
    <div
      class={cn(["flex flex-col items-center justify-center py-12 px-4 text-center", @class])}
      {@rest}
    >
      <div :if={@icon != []} class="mb-4 text-muted-foreground">
        {render_slot(@icon)}
      </div>
      <h3 class="text-lg font-semibold text-foreground mb-2">
        {render_slot(@title)}
      </h3>
      <p :if={@description != []} class="text-sm text-muted-foreground mb-6 max-w-sm">
        {render_slot(@description)}
      </p>
      <div :if={@action != []}>
        {render_slot(@action)}
      </div>
    </div>
    """
  end
end
