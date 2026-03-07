defmodule PhiaUi.Components.TableState do
  @moduledoc """
  Loading skeleton, empty state, and error state for table components.

  These three components cover the three non-data states a table can be in:
  loading (skeleton shimmer), empty (no rows match), and error (fetch failed).

  ## Sub-components

  | Function         | Purpose                                        |
  |------------------|------------------------------------------------|
  | `table_skeleton/1` | Animated shimmer rows while data loads       |
  | `table_empty/1`    | Empty state with icon, title, and CTA        |
  | `table_error/1`    | Error state with retry action slot           |

  ## Usage

      <%# Loading state %>
      <%= if @loading do %>
        <.table_skeleton rows={5} cols={4} />
      <% end %>

      <%# Empty state (inside a tbody) %>
      <%= if @rows == [] do %>
        <.table_empty title="No users found" description="Try adjusting your search filters.">
          <:action>
            <.button phx-click="clear_filters" variant={:outline} size={:sm}>Clear filters</.button>
          </:action>
        </.table_empty>
      <% end %>

      <%# Error state (inside a tbody) %>
      <%= if @error do %>
        <.table_error message="Failed to load users.">
          <:action>
            <.button phx-click="retry" size={:sm}>Retry</.button>
          </:action>
        </.table_error>
      <% end %>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # table_skeleton/1
  # ---------------------------------------------------------------------------

  attr(:rows, :integer, default: 5, doc: "Number of skeleton rows to render")

  attr(:cols, :integer, default: 4, doc: "Number of skeleton columns to render")

  attr(:show_header, :boolean,
    default: true,
    doc: "Whether to render a skeleton thead with shimmer header cells"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the outer wrapper div")

  @doc """
  Renders an animated shimmer table skeleton while data is loading.

  All cells use `motion-safe:animate-pulse` so users who prefer reduced motion
  see static placeholder blocks instead of animation.

  ## Example

      <.table_skeleton rows={5} cols={4} />

      <%# Wider skeleton with no header %>
      <.table_skeleton rows={8} cols={6} show_header={false} />
  """
  def table_skeleton(assigns) do
    ~H"""
    <div class={cn(["w-full overflow-auto", @class])}>
      <table class="w-full caption-bottom text-sm">
        <thead :if={@show_header} class="[&_tr]:border-b">
          <tr>
            <th :for={_c <- 1..@cols} class="h-11 px-4 text-left align-middle">
              <div class="h-4 w-24 rounded bg-muted motion-safe:animate-pulse"></div>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr :for={_r <- 1..@rows} class="border-b">
            <td :for={_c <- 1..@cols} class="px-4 py-3">
              <div class="h-4 w-full rounded bg-muted motion-safe:animate-pulse"></div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # table_empty/1
  # ---------------------------------------------------------------------------

  attr(:title, :string, default: "No results", doc: "Primary heading of the empty state")

  attr(:description, :string,
    default: nil,
    doc: "Optional secondary text beneath the title"
  )

  attr(:icon, :string,
    default: "inbox",
    doc: "Lucide icon name for the decorative icon (e.g. `\"search\"`, `\"filter\"`, `\"inbox\"`)"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the `<tr>`")

  slot(:action,
    doc: "Optional CTA placed below the description — typically a button or link"
  )

  @doc """
  Renders an empty-state row suitable for use inside a `<tbody>`.

  The `<td colspan="100">` trick spans all columns regardless of how many
  columns the table has. Works as a drop-in inside any `<tbody>`.

  ## Example

      <.table_empty
        title="No invoices found"
        description="Create your first invoice to get started."
        icon="file-text"
      >
        <:action>
          <.button phx-click="new_invoice" size={:sm}>New Invoice</.button>
        </:action>
      </.table_empty>
  """
  def table_empty(assigns) do
    ~H"""
    <tr class={@class}>
      <td colspan="100">
        <div class="flex flex-col items-center justify-center py-12 text-center">
          <div class="mb-4 rounded-full bg-muted p-3 text-muted-foreground">
            <.icon name={@icon} size={:lg} />
          </div>
          <p class="text-sm font-medium text-foreground">{@title}</p>
          <p :if={@description} class="mt-1 text-sm text-muted-foreground">{@description}</p>
          <div :if={@action != []} class="mt-4">
            {render_slot(@action)}
          </div>
        </div>
      </td>
    </tr>
    """
  end

  # ---------------------------------------------------------------------------
  # table_error/1
  # ---------------------------------------------------------------------------

  attr(:message, :string,
    default: "Failed to load data",
    doc: "Error message shown in the error state"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the `<tr>`")

  slot(:action,
    doc: "Optional retry button or recovery action placed below the error message"
  )

  @doc """
  Renders an error-state row suitable for use inside a `<tbody>`.

  Uses destructive colour tokens to make the error visually distinct from the
  empty state. Provide a `retry` action slot to let users recover inline.

  ## Example

      <.table_error message="Failed to load users. Please try again.">
        <:action>
          <.button phx-click="retry" variant={:outline} size={:sm}>Retry</.button>
        </:action>
      </.table_error>
  """
  def table_error(assigns) do
    ~H"""
    <tr class={@class}>
      <td colspan="100">
        <div class="flex flex-col items-center justify-center py-12 text-center">
          <div class="mb-4 rounded-full bg-destructive/10 p-3 text-destructive">
            <.icon name="circle-x" size={:lg} />
          </div>
          <p class="text-sm font-medium text-destructive">{@message}</p>
          <div :if={@action != []} class="mt-4">
            {render_slot(@action)}
          </div>
        </div>
      </td>
    </tr>
    """
  end
end
