defmodule PhiaUi.Components.EmptyState do
  @moduledoc """
  Empty state component for displaying when a list, table, or view has no data.

  Use this component to replace empty tables, lists, or content areas with a
  helpful, visually consistent message that guides users toward a next action.
  Pure HEEx — no JavaScript required.

  ## Slots

  | Slot           | Required | Purpose                                               |
  |----------------|----------|-------------------------------------------------------|
  | `:icon`        | No       | Leading illustration icon (e.g. `<.icon name="inbox">`) |
  | `:title`       | Yes      | Primary heading for the empty state                   |
  | `:description` | No       | Supporting text with additional context               |
  | `:action`      | No       | Call-to-action button, link, or other control         |

  ## Basic example

      <.empty>
        <:icon><.icon name="inbox" size={:lg} /></:icon>
        <:title>No notifications</:title>
        <:description>You're all caught up! Check back later.</:description>
      </.empty>

  ## With a call-to-action

      <.empty>
        <:icon><.icon name="folder-open" size={:lg} /></:icon>
        <:title>No projects yet</:title>
        <:description>Get started by creating your first project.</:description>
        <:action>
          <.button phx-click="new_project">
            <.icon name="plus" size={:sm} />
            New Project
          </.button>
        </:action>
      </.empty>

  ## Inside a table (colspan)

  Replace the table body when there are no rows. Use `colspan` to span all
  columns so the empty state is centred across the full table width:

      <tbody>
        <%= if @posts == [] do %>
          <tr>
            <td colspan="5" class="p-0">
              <.empty>
                <:icon><.icon name="file-text" size={:lg} /></:icon>
                <:title>No posts published</:title>
                <:description>Publish your first post to see it here.</:description>
                <:action>
                  <.button phx-click="new_post">Write a post</.button>
                </:action>
              </.empty>
            </td>
          </tr>
        <% else %>
          <%= for post <- @posts do %>
            <tr>...</tr>
          <% end %>
        <% end %>
      </tbody>

  ## Search results with no matches

      <.empty>
        <:icon><.icon name="search-x" size={:lg} /></:icon>
        <:title>No results for "{@search_query}"</:title>
        <:description>Try a different search term or remove your filters.</:description>
        <:action>
          <.button variant={:outline} phx-click="clear_search">Clear search</.button>
        </:action>
      </.empty>

  ## Error / access denied state

      <.empty>
        <:icon><.icon name="shield-off" size={:lg} /></:icon>
        <:title>Access restricted</:title>
        <:description>You don't have permission to view this content.</:description>
        <:action>
          <.button navigate={~p"/dashboard"}>Go to Dashboard</.button>
        </:action>
      </.empty>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:class, :string, default: nil, doc: "Additional CSS classes applied to the outer container `<div>`. Use `min-h-[N]` to control minimum height.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<div>` element.")

  slot(:icon, doc: "Optional leading icon or illustration. Rendered in `text-muted-foreground` with bottom margin.")

  slot(:title, required: true, doc: "Primary heading text for the empty state. Rendered as a bold `<h3>`.")

  slot(:description, doc: "Optional supporting text with additional context. Rendered in muted small type, max width constrained for readability.")

  slot(:action, doc: "Optional call-to-action area. Place a button, link, or any interactive element here.")

  @doc """
  Renders a centred empty state with optional icon, title, description, and action.

  All slots are purely optional except `:title`. The layout is a vertical
  flex column centred both horizontally and vertically inside the container.
  """
  def empty(assigns) do
    ~H"""
    <div
      class={cn(["flex flex-col items-center justify-center py-12 px-4 text-center", @class])}
      {@rest}
    >
      <%!-- Icon slot: only rendered when provided; muted colour blends into the background --%>
      <div :if={@icon != []} class="mb-4 text-muted-foreground">
        {render_slot(@icon)}
      </div>

      <%!-- Title is always present — it is the primary signal to the user --%>
      <h3 class="text-lg font-semibold text-foreground mb-2">
        {render_slot(@title)}
      </h3>

      <%!-- Description: max-w-sm prevents very long lines on wide screens --%>
      <p :if={@description != []} class="text-sm text-muted-foreground mb-6 max-w-sm">
        {render_slot(@description)}
      </p>

      <%!-- Action: no wrapper styling — allow the slot content to control its own appearance --%>
      <div :if={@action != []}>
        {render_slot(@action)}
      </div>
    </div>
    """
  end
end
