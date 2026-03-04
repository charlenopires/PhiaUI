defmodule PhiaUi.Components.KanbanBoard do
  @moduledoc """
  Kanban board component for PhiaUI.

  Renders a horizontal workflow board composed of named columns and draggable
  task cards. The layout is CSS-only; drag-and-drop reordering is provided by
  the optional `PhiaKanban` vanilla-JS hook.

  ## When to use

  Use `KanbanBoard` whenever you need a multi-stage workflow visualisation with
  discrete status columns — project management, recruitment pipelines, support
  ticket queues, content-approval workflows, etc.

  ## Anatomy

  | Component       | Element | Purpose                                         |
  |-----------------|---------|--------------------------------------------------|
  | `kanban_board/1`  | `div`   | Horizontal scroll container for all columns     |
  | `kanban_column/1` | `div`   | A single workflow stage (label + optional count)|
  | `kanban_card/1`   | `li`    | An individual task card with slots              |

  ## Priority levels

  | Value      | Left-border colour                |
  |------------|----------------------------------|
  | `critical` | `border-l-destructive` (red)     |
  | `high`     | `border-l-orange-500` (orange)   |
  | `medium`   | `border-l-yellow-500` (yellow)   |
  | `low`      | `border-l-muted-foreground/40`   |

  ## Minimal example

      <.kanban_board id="project-board">
        <.kanban_column id="col-todo" label="To Do" count={length(@todo_cards)}>
          <.kanban_card
            :for={card <- @todo_cards}
            id={"card-\#{card.id}"}
            title={card.title}
            priority={card.priority}
          />
        </.kanban_column>
      </.kanban_board>

  ## Full project-management board with LiveView streams

  LiveView streams keep DOM diffing minimal — only changed cards are patched,
  not the entire column.

      <.kanban_board id="pm-board" phx-hook="PhiaKanban" data-on-move="card_moved">
        <.kanban_column id="col-backlog" label="Backlog" count={@backlog_count}>
          <.kanban_card
            :for={{dom_id, card} <- @streams.backlog}
            id={dom_id}
            title={card.title}
            priority={card.priority}
            phx-click="open_card"
            phx-value-id={card.id}
          >
            <:avatar>
              <.avatar size="xs">
                <.avatar_image src={card.assignee_avatar} />
                <.avatar_fallback name={card.assignee_name} />
              </.avatar>
            </:avatar>
            <:tags>
              <.badge :for={label <- card.labels} variant="secondary" size="sm">
                {label}
              </.badge>
            </:tags>
            <:footer>
              <.icon name="calendar" size={:xs} />
              <span>{card.due_date}</span>
              <.icon name="message-square" size={:xs} class="ml-auto" />
              <span>{card.comment_count}</span>
            </:footer>
          </.kanban_card>
        </.kanban_column>

        <.kanban_column id="col-in-progress" label="In Progress" count={@in_progress_count}>
          <%!-- ... --%>
        </.kanban_column>

        <.kanban_column id="col-done" label="Done" count={@done_count}>
          <%!-- ... --%>
        </.kanban_column>
      </.kanban_board>

  ## Drag-and-drop setup (optional)

  The board works without the hook — cards are static server-rendered items.
  Add `phx-hook="PhiaKanban"` to `kanban_board/1` to enable drag-and-drop
  reordering. The hook emits a `push_event("phx:card_moved", %{id, from, to, index})`
  on every successful drop.

      # app.js
      import PhiaKanban from "./hooks/kanban"
      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaKanban }
      })

      # LiveView handler
      def handle_event("card_moved", %{"id" => id, "from" => from, "to" => to, "index" => idx}, socket) do
        # Update the card's column and position in your database
        {:noreply, socket}
      end
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # kanban_board/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    required: true,
    doc: "DOM id for the board element. Required for LiveView streams and the PhiaKanban hook."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the board container")

  attr(:rest, :global,
    include: ~w(phx-hook data-on-move),
    doc: """
    HTML attributes forwarded to the root element.
    Use `phx-hook="PhiaKanban"` to enable drag-and-drop reordering.
    Use `data-on-move` to specify the LiveView event name for card moves.
    """
  )

  slot(:inner_block, required: true, doc: "`kanban_column/1` children")

  @doc """
  Renders the kanban board root container.

  All `kanban_column/1` components go inside. The board overflows horizontally
  on narrow screens so every column remains accessible without horizontal
  viewport scrolling that would break the page layout.

  ## Example

      <.kanban_board id="sales-pipeline">
        <.kanban_column id="col-lead" label="Lead" count={12}>
          ...
        </.kanban_column>
        <.kanban_column id="col-qualified" label="Qualified" count={5}>
          ...
        </.kanban_column>
      </.kanban_board>
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

  attr(:id, :string,
    required: true,
    doc: "DOM id for the column. Required for the PhiaKanban hook to identify drop zones."
  )

  attr(:label, :string,
    required: true,
    doc: ~s(Column heading for the workflow stage, e.g. "To Do", "In Progress", "Done".)
  )

  attr(:count, :integer,
    default: nil,
    doc: """
    Optional item count displayed as a badge beside the label.
    Useful for at-a-glance capacity monitoring.
    Pass `nil` to omit the badge.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the column wrapper")

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the column div (e.g. `data-column-id` for the hook)"
  )

  slot(:inner_block, required: true, doc: "`kanban_card/1` children")

  @doc """
  Renders a single kanban workflow column.

  Each column has a fixed width of `w-64` (256 px) and does not shrink, which
  ensures consistent column widths regardless of card content. The count badge
  helps teams see at a glance whether a stage has become a bottleneck.

  ## Example

      <.kanban_column id="col-review" label="In Review" count={@review_count}>
        <.kanban_card
          :for={{dom_id, card} <- @streams.review}
          id={dom_id}
          title={card.title}
          priority={card.priority}
        />
      </.kanban_column>
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
      <%!-- Column header: label + optional item count badge --%>
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

      <%!-- Cards list — semantic <ol> because the order of cards is meaningful --%>
      <ol class="flex flex-col gap-2">
        {render_slot(@inner_block)}
      </ol>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # kanban_card/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    required: true,
    doc: "DOM id for the card element. Required for LiveView streams (`dom_id` from stream)."
  )

  attr(:title, :string, required: true, doc: "Card title — the task or item name.")

  attr(:priority, :string,
    default: "medium",
    values: ~w(critical high medium low),
    doc: """
    Priority level. Controls the left-border accent colour:
    - `critical` — red (destructive)
    - `high`     — orange
    - `medium`   — yellow
    - `low`      — muted
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the card")

  attr(:rest, :global,
    include: ~w(phx-click phx-value-id draggable),
    doc: """
    HTML attributes forwarded to the `<li>` card element.
    Add `phx-click="open_card" phx-value-id={card.id}` to make cards clickable.
    The PhiaKanban hook sets `draggable="true"` automatically when enabled.
    """
  )

  slot(:avatar,
    doc: """
    Optional avatar or `avatar_group/1` for assignees.
    Rendered in the top-right of the card header.
    """
  )

  slot(:tags,
    doc: """
    Optional tag / badge row rendered below the title.
    Use `badge/1` components with `variant="secondary"`.
    """
  )

  slot(:footer,
    doc: """
    Optional footer row for metadata such as due dates, comment counts, or
    story-point estimates. Content is rendered at `text-xs text-muted-foreground`.
    """
  )

  @doc """
  Renders a single kanban task card.

  Cards are `<li>` elements inside the column's `<ol>`, which preserves
  correct document semantics for ordered task lists.

  The priority-coloured left border gives a quick visual signal without
  requiring team members to read each card individually.

  ## Example — full card with all slots

      <.kanban_card
        id={"card-\#{task.id}"}
        title={task.title}
        priority={task.priority}
        phx-click="open_task"
        phx-value-id={task.id}
      >
        <:avatar>
          <.avatar size="xs">
            <.avatar_image src={task.assignee.avatar_url} />
            <.avatar_fallback name={task.assignee.name} />
          </.avatar>
        </:avatar>
        <:tags>
          <.badge :for={label <- task.labels} variant="secondary" size="sm">
            {label.name}
          </.badge>
        </:tags>
        <:footer>
          <.icon name="calendar" size={:xs} />
          <span>Due {task.due_date}</span>
        </:footer>
      </.kanban_card>
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
      <%!-- Header: title on the left, optional avatar on the right --%>
      <div class="flex items-start justify-between gap-2">
        <p class="text-sm font-medium text-foreground leading-snug">{@title}</p>
        <span :if={@avatar != []} class="shrink-0">
          {render_slot(@avatar)}
        </span>
      </div>

      <%!-- Tags row — only rendered when the slot has content --%>
      <div :if={@tags != []} class="mt-2 flex flex-wrap gap-1">
        {render_slot(@tags)}
      </div>

      <%!-- Footer row — due dates, comment counts, story points, etc. --%>
      <div :if={@footer != []} class="mt-2 flex items-center gap-2 text-xs text-muted-foreground">
        {render_slot(@footer)}
      </div>
    </li>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Each priority maps to a specific left-border Tailwind class.
  # Using pattern-matched functions instead of a map or case ensures the class
  # strings are statically discoverable by Tailwind's JIT scanner.
  defp priority_border("critical"), do: "border-l-2 border-l-destructive"
  defp priority_border("high"), do: "border-l-2 border-l-orange-500"
  defp priority_border("medium"), do: "border-l-2 border-l-yellow-500"
  defp priority_border("low"), do: "border-l-2 border-l-muted-foreground/40"
end
