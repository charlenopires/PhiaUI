defmodule PhiaUi.Components.TimelineTable do
  @moduledoc """
  Timeline / activity log display component.

  Renders an ordered list of events with icon dots, timestamps, actors, and
  optional metadata and expandable detail slots. Uses `<ul>/<li>` semantics
  rather than `<table>` — a better semantic match for chronological event feeds.

  ## Sub-components

  | Function              | HTML element | Purpose                                  |
  |-----------------------|--------------|------------------------------------------|
  | `timeline_table/1`    | `<ul>`       | Outer container for the event feed       |
  | `timeline_table_row/1`| `<li>`       | Single timeline event with icon + content|

  ## Example

      <.timeline_table>
        <.timeline_table_row
          title="Invoice #1042 paid"
          timestamp="2 hours ago"
          icon="circle-check"
          icon_color={:success}
          user="Alice Johnson"
          description="Payment received via Stripe"
        >
          <:meta>
            <.badge variant={:secondary}>$1,200.00</.badge>
          </:meta>
        </.timeline_table_row>

        <.timeline_table_row
          title="Order #889 shipped"
          timestamp="Yesterday"
          icon="truck"
          icon_color={:primary}
        >
          <:detail>
            <div class="text-sm text-muted-foreground">
              Tracking: 1Z999AA10123456784
            </div>
          </:detail>
        </.timeline_table_row>

        <.timeline_table_row
          title="Payment failed"
          timestamp="3 days ago"
          icon="circle-x"
          icon_color={:destructive}
          description="Card ending in 4242 was declined."
        />
      </.timeline_table>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # timeline_table/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the outer wrapper")

  slot(:inner_block,
    required: true,
    doc: "`timeline_table_row/1` children"
  )

  @doc """
  Renders the outer timeline container.

  Uses `flow-root` to contain floats and `divide-y divide-border` to draw
  subtle separators between events. Wraps all `timeline_table_row/1` children.

  ## Example

      <.timeline_table>
        <.timeline_table_row title="Event A" timestamp="now" />
        <.timeline_table_row title="Event B" timestamp="1h ago" />
      </.timeline_table>
  """
  def timeline_table(assigns) do
    ~H"""
    <div class={cn(["flow-root", @class])}>
      <ul role="list" class="divide-y divide-border">
        {render_slot(@inner_block)}
      </ul>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # timeline_table_row/1
  # ---------------------------------------------------------------------------

  attr(:timestamp, :string,
    required: true,
    doc: "Formatted timestamp string (e.g. `\"2 hours ago\"`, `\"Mar 5, 2026\"`)"
  )

  attr(:icon, :string,
    default: "circle",
    doc: "Lucide icon name for the event dot (e.g. `\"check\"`, `\"truck\"`, `\"circle-x\"`)"
  )

  attr(:icon_color, :atom,
    default: :default,
    values: [:default, :primary, :success, :warning, :destructive],
    doc: """
    Colour preset for the icon dot background and icon colour:
    - `:default` — muted background, muted-foreground icon
    - `:primary` — primary-tinted background, primary icon
    - `:success` — green background and icon
    - `:warning` — amber background and icon
    - `:destructive` — destructive/red background and icon
    """
  )

  attr(:title, :string,
    required: true,
    doc: "Primary event label (e.g. `\"Invoice paid\"`, `\"Order shipped\"`)"
  )

  attr(:description, :string,
    default: nil,
    doc: "Optional one-line detail beneath the title"
  )

  attr(:user, :string,
    default: nil,
    doc: "Optional actor name displayed as `by <user>` below the description"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the `<li>`")

  slot(:meta,
    doc: "Optional metadata badges or chips displayed below the description"
  )

  slot(:detail,
    doc: "Optional expanded detail block (nested table, code, etc.) below the main content"
  )

  @doc """
  Renders a single timeline event row.

  The layout is a two-column flex row: icon dot on the left, content on the
  right. The timestamp floats to the top-right of the content column.

  ## Example

      <.timeline_table_row
        title="Deployment succeeded"
        timestamp="5 min ago"
        icon="rocket"
        icon_color={:success}
        user="CI/CD Bot"
        description="v2.4.1 deployed to production"
      >
        <:meta>
          <.badge>v2.4.1</.badge>
          <.badge variant={:outline}>production</.badge>
        </:meta>
      </.timeline_table_row>
  """
  def timeline_table_row(assigns) do
    ~H"""
    <li class={cn(["flex gap-4 px-2 py-4", @class])}>
      <%!-- Icon dot --%>
      <div class="flex-shrink-0">
        <div class={cn(["flex h-8 w-8 items-center justify-center rounded-full", ttr_icon_color_class(@icon_color)])}>
          <.icon name={@icon} size={:sm} />
        </div>
      </div>
      <%!-- Content --%>
      <div class="min-w-0 flex-1">
        <div class="flex items-start justify-between gap-2">
          <div class="min-w-0 flex-1">
            <p class="text-sm font-medium text-foreground">{@title}</p>
            <p :if={@description} class="mt-0.5 text-sm text-muted-foreground">{@description}</p>
            <p :if={@user} class="mt-0.5 text-xs text-muted-foreground">by {@user}</p>
            <div :if={@meta != []} class="mt-1.5 flex flex-wrap items-center gap-1">
              {render_slot(@meta)}
            </div>
          </div>
          <time class="flex-shrink-0 whitespace-nowrap text-xs text-muted-foreground">
            {@timestamp}
          </time>
        </div>
        <div :if={@detail != []} class="mt-3">
          {render_slot(@detail)}
        </div>
      </div>
    </li>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp ttr_icon_color_class(:default), do: "bg-muted text-muted-foreground"
  defp ttr_icon_color_class(:primary), do: "bg-primary/10 text-primary"
  defp ttr_icon_color_class(:success), do: "bg-green-500/10 text-green-600"
  defp ttr_icon_color_class(:warning), do: "bg-amber-500/10 text-amber-600"
  defp ttr_icon_color_class(:destructive), do: "bg-destructive/10 text-destructive"
end
