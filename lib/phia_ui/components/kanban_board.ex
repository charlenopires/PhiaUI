defmodule PhiaUi.Components.KanbanBoard do
  @moduledoc """
  Kanban board component for PhiaUI.

  Renders a horizontal kanban workflow with columns and draggable cards.
  Composable anatomy following shadcn/ui conventions adapted for Phoenix LiveView.

  CSS-only layout; drag-and-drop behaviour is provided by the `PhiaKanban`
  JavaScript hook. Cards and columns support LiveView streams for efficient
  real-time updates.

  ## Sub-components

  - `kanban_board/1` — horizontal scroll container for all columns
  - `kanban_column/1` — a single workflow stage with a label and item count
  - `kanban_card/1` — an individual task/item card with priority, tags, footer,
    and avatar slots

  ## Priority levels

  | Value      | Colour token                     |
  |-----------|----------------------------------|
  | `critical` | `text-destructive` (red)         |
  | `high`     | `text-orange-600` (orange)       |
  | `medium`   | `text-yellow-600` (yellow)       |
  | `low`      | `text-muted-foreground` (muted)  |

  ## Examples

      <.kanban_board id="project-board">
        <.kanban_column id="col-todo" label="To Do" count={@todo_count}>
          <.kanban_card
            :for={{dom_id, card} <- @streams.todo}
            id={dom_id}
            title={card.title}
            priority={card.priority}
          >
            <:tags>
              <.badge :for={tag <- card.tags} variant="secondary">{tag}</.badge>
            </:tags>
            <:footer>
              <span class="text-xs text-muted-foreground">{card.due_date}</span>
            </:footer>
          </.kanban_card>
        </.kanban_column>
      </.kanban_board>

  ## Hook setup (optional drag-and-drop)

      import PhiaKanban from "./hooks/kanban"
      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaKanban }
      })

  The board works without the hook — cards are static server-rendered items.
  Add `phx-hook="PhiaKanban"` to `kanban_board/1` to enable drag reordering.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # kanban_board/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "DOM id for the board — required for LiveView streams")

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the board container")

  attr(:rest, :global,
    include: ~w(phx-hook data-on-move),
    doc: "HTML attributes forwarded to the root element (e.g. phx-hook=\"PhiaKanban\")"
  )

  slot(:inner_block, required: true, doc: "kanban_column children")

  @doc """
  Renders the kanban board container.

  All `kanban_column/1` components go inside. The board scrolls horizontally
  on overflow so that many columns remain accessible on small screens.
  """
  def kanban_board(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn([
        "flex gap-4 overflow-x-auto pb-4",
        @class
      ])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # kanban_column/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "DOM id for the column")
  attr(:label, :string, required: true, doc: "Column heading (e.g. \"To Do\", \"In Progress\")")

  attr(:count, :integer,
    default: nil,
    doc: "Optional item count displayed beside the label"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the column wrapper")
  attr(:rest, :global, doc: "HTML attributes forwarded to the column div")

  slot(:inner_block, required: true, doc: "kanban_card children")

  @doc """
  Renders a single kanban workflow column.

  Place `kanban_card/1` components inside. A count badge next to the label
  shows how many items are in the column.
  """
  def kanban_column(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn([
        "flex w-64 shrink-0 flex-col gap-3 rounded-lg bg-muted/50 p-3",
        @class
      ])}
      {@rest}
    >
      <%!-- Column header --%>
      <div class="flex items-center justify-between">
        <h3 class="text-sm font-semibold text-foreground">{@label}</h3>
        <span
          :if={@count != nil}
          data-count={@count}
          class="rounded-full bg-background px-2 py-0.5 text-xs font-medium text-muted-foreground ring-1 ring-border"
        >
          {@count}
        </span>
      </div>

      <%!-- Cards list --%>
      <ol class="flex flex-col gap-2">
        {render_slot(@inner_block)}
      </ol>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # kanban_card/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, required: true, doc: "DOM id for the card — required for LiveView streams")
  attr(:title, :string, required: true, doc: "Card title / task name")

  attr(:priority, :string,
    default: "medium",
    values: ~w(critical high medium low),
    doc: "Priority level — controls the priority indicator colour"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the card")

  attr(:rest, :global,
    include: ~w(phx-click phx-value-id draggable),
    doc: "HTML attributes forwarded to the card li element"
  )

  slot(:avatar, doc: "Optional avatar or avatar_group for assignees")
  slot(:tags, doc: "Optional tag/badge row rendered below the title")
  slot(:footer, doc: "Optional footer row — due dates, metadata, etc.")

  @doc """
  Renders a single kanban card (task item).

  Supports `:avatar`, `:tags`, and `:footer` slots for rich content.
  The `:priority` attr colours a small left-border indicator.
  """
  def kanban_card(assigns) do
    ~H"""
    <li
      id={@id}
      data-priority={@priority}
      class={cn([
        "group relative rounded-md border border-border bg-background p-3 shadow-sm",
        "cursor-pointer hover:shadow-md transition-shadow",
        priority_border(@priority),
        @class
      ])}
      {@rest}
    >
      <%!-- Header: title + avatar --%>
      <div class="flex items-start justify-between gap-2">
        <p class="text-sm font-medium text-foreground leading-snug">{@title}</p>
        <span :if={@avatar != []} class="shrink-0">
          {render_slot(@avatar)}
        </span>
      </div>

      <%!-- Tags row --%>
      <div :if={@tags != []} class="mt-2 flex flex-wrap gap-1">
        {render_slot(@tags)}
      </div>

      <%!-- Footer row --%>
      <div :if={@footer != []} class="mt-2 flex items-center gap-2 text-xs text-muted-foreground">
        {render_slot(@footer)}
      </div>
    </li>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers — pattern matching only
  # ---------------------------------------------------------------------------

  defp priority_border("critical"), do: "border-l-2 border-l-destructive"
  defp priority_border("high"), do: "border-l-2 border-l-orange-500"
  defp priority_border("medium"), do: "border-l-2 border-l-yellow-500"
  defp priority_border("low"), do: "border-l-2 border-l-muted-foreground/40"
end
