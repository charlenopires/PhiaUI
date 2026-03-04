defmodule PhiaUi.Components.ActivityFeed do
  @moduledoc """
  Activity feed / audit log component for PhiaUI.

  Renders a chronological, date-grouped list of events — the kind of
  "What happened?" sidebar you see in CRMs, project trackers, ticketing
  systems, and collaboration tools.

  CSS-only — no JS hook required. Fully server-rendered and compatible with
  LiveView streams for real-time event delivery.

  ## When to use

  - CRM contact timeline: calls, emails, tasks, notes
  - GitHub-style issue/PR activity stream
  - Audit log: "Alice archived this ticket at 9:12 AM"
  - Notification center: mentions, reactions, system alerts

  ## Anatomy

  | Component         | Element   | Purpose                                             |
  |-------------------|-----------|-----------------------------------------------------|
  | `activity_feed/1`  | `div`    | Root container (`role="log"`, `aria-live="polite"`) |
  | `activity_group/1` | `section`| Date-grouped section with a visible date label      |
  | `activity_item/1`  | `li`     | One event row: type icon, optional avatar, text, time |

  ## Activity item types

  | Type       | Icon         | Background / colour        |
  |-----------|-------------|----------------------------|
  | `mention`  | at-sign      | Orange                     |
  | `file`     | file         | Violet                     |
  | `call`     | phone        | Green                      |
  | `task`     | check-square | Blue                       |
  | `reaction` | heart        | Pink                       |
  | `system`   | bell         | Muted (semantic token)     |

  ## Basic example

      <.activity_feed id="crm-activity">
        <.activity_group label="Today">
          <.activity_item type="mention" timestamp="9:12 AM">
            <:avatar>
              <.avatar size="sm">
                <.avatar_fallback name="Jason Carter" />
              </.avatar>
            </:avatar>
            <span>
              <strong>Jason Carter</strong> mentioned
              <span class="font-medium text-primary">@you</span>
              in <strong>#Lead Follow-up</strong>.
            </span>
          </.activity_item>

          <.activity_item type="file" timestamp="9:46 AM">
            New file uploaded: <strong>Q3_Sales_Targets_v2.xlsx</strong>
          </.activity_item>
        </.activity_group>

        <.activity_group label="Yesterday">
          <.activity_item type="task" timestamp="09:18 AM">
            Task <strong>Pitch Deck</strong> was assigned to you.
          </.activity_item>
        </.activity_group>

        <:footer>
          <form phx-submit="send_comment" class="flex gap-2">
            <input
              name="comment"
              placeholder="Add a comment..."
              class="flex-1 rounded-md border border-input bg-background px-3 py-2 text-sm"
            />
            <button type="submit" class="btn btn-primary text-sm">Post</button>
          </form>
        </:footer>
      </.activity_feed>

  ## LiveView streams for real-time delivery

  `role="log"` + `aria-live="polite"` means new items pushed via streams will be
  announced by screen readers without interrupting the user's current focus.

      # In the LiveView handle_info for a PubSub broadcast:
      def handle_info({:new_activity, activity}, socket) do
        {:noreply, stream_insert(socket, :activities, activity, at: 0)}
      end

      # In the template:
      <.activity_feed id="live-feed">
        <.activity_group label="Recent">
          <.activity_item
            :for={{dom_id, item} <- @streams.activities}
            id={dom_id}
            type={item.type}
            timestamp={item.formatted_time}
          >
            {item.text}
          </.activity_item>
        </.activity_group>
      </.activity_feed>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # activity_feed/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    default: nil,
    doc: """
    Optional DOM id. Required when using LiveView streams so the DOM diffing
    engine can locate and patch individual items efficiently.
    """
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the feed container")

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the root div (e.g. `phx-update=\"stream\"`)"
  )

  slot(:inner_block,
    required: true,
    doc: "`activity_group/1` and/or `activity_item/1` children"
  )

  slot(:footer,
    doc: """
    Optional footer slot rendered below the event list — typically a comment
    form with `phx-submit`. Separated from the event stream by a top border.
    """
  )

  @doc """
  Renders the activity feed root container.

  Sets `role="log"` and `aria-live="polite"` so assistive technologies
  automatically announce new events inserted via LiveView streams without
  interrupting the user.
  """
  def activity_feed(assigns) do
    ~H"""
    <div
      id={@id}
      role="log"
      aria-live="polite"
      class={cn(["flex flex-col gap-0", @class])}
      {@rest}
    >
      <div class="flex-1">
        {render_slot(@inner_block)}
      </div>
      <%!-- Footer (e.g. comment form) separated by a top border --%>
      <div :if={@footer != []} class="mt-4 border-t border-border pt-3">
        {render_slot(@footer)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # activity_group/1
  # ---------------------------------------------------------------------------

  attr(:label, :string,
    required: true,
    doc: ~s(Date label for this group of events. Use "Today", "Yesterday", or a date string like "Mar 3, 2026".)
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the group wrapper")

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the `<section>` element"
  )

  slot(:inner_block, required: true, doc: "`activity_item/1` children")

  @doc """
  Renders a date-grouped section of activity events.

  The label is displayed as a pill-shaped muted badge with a horizontal
  rule extending to the right, visually separating date groups.

  ## Example

      <.activity_group label="Mar 1, 2026">
        <.activity_item type="call" timestamp="10:00 AM">
          Call with <strong>Acme Corp</strong> lasted 32 minutes.
        </.activity_item>
      </.activity_group>
  """
  def activity_group(assigns) do
    ~H"""
    <section class={cn(["mb-4", @class])} {@rest}>
      <%!-- Date pill + horizontal rule — visually anchors the group in time --%>
      <div class="mb-2 flex items-center gap-2">
        <span class="rounded-full border border-border bg-muted px-2.5 py-0.5 text-xs font-medium text-muted-foreground">
          {@label}
        </span>
        <span class="h-px flex-1 bg-border" aria-hidden="true" />
      </div>
      <%!-- Ordered list because chronological order of events is semantically meaningful --%>
      <ol class="space-y-3">
        {render_slot(@inner_block)}
      </ol>
    </section>
    """
  end

  # ---------------------------------------------------------------------------
  # activity_item/1
  # ---------------------------------------------------------------------------

  attr(:type, :string,
    default: "system",
    values: ~w(mention file call task reaction system),
    doc: """
    Event type — controls the icon and icon background colour:
    - `mention`  — orange at-sign (someone tagged you or another user)
    - `file`     — violet file icon (document uploaded or shared)
    - `call`     — green phone icon (phone/video call logged)
    - `task`     — blue check-square (task created, completed, or assigned)
    - `reaction` — pink heart (emoji reaction or like)
    - `system`   — muted bell (automated notification, status change, etc.)
    """
  )

  attr(:timestamp, :string,
    default: nil,
    doc: ~s(Optional time label rendered at the end of the row, e.g. "9:12 AM" or "2 hours ago".)
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the item row")

  attr(:rest, :global,
    doc: "HTML attributes forwarded to the `<li>` element (e.g. `id` for streams)"
  )

  slot(:avatar,
    doc: """
    Optional `avatar/1` component displayed between the type icon and the event
    text. Use for user-initiated events where showing who acted is important.
    """
  )

  slot(:inner_block,
    required: true,
    doc: """
    Event description text. May include inline HTML markup (`<strong>`, `<span>`,
    links, etc.) for rich formatting.
    """
  )

  @doc """
  Renders a single activity event row.

  The `:type` attr selects the icon and colour scheme for the type indicator
  circle. Pass an `:avatar` slot to show who performed the action. Use
  `:timestamp` for the time label on the right.

  ## Example — user-initiated mention event

      <.activity_item type="mention" timestamp="Just now">
        <:avatar>
          <.avatar size="sm"><.avatar_fallback name="Sarah Lin" /></.avatar>
        </:avatar>
        <strong>Sarah Lin</strong> mentioned you in
        <a href="/tickets/42" class="font-medium text-primary hover:underline">Ticket #42</a>.
      </.activity_item>

  ## Example — system event (no avatar)

      <.activity_item type="system" timestamp="03:00 AM">
        Daily digest email sent to 1,204 subscribers.
      </.activity_item>
  """
  def activity_item(assigns) do
    ~H"""
    <li class={cn(["flex items-start gap-3", @class])} {@rest}>
      <%!-- Coloured type icon circle — visually encodes the event category --%>
      <span
        data-activity-type={@type}
        class={cn(["mt-0.5 flex h-7 w-7 shrink-0 items-center justify-center rounded-full", item_icon_bg(@type)])}
        aria-hidden="true"
      >
        <.icon name={item_icon_name(@type)} size={:xs} class={item_icon_color(@type)} />
      </span>

      <%!-- Optional user avatar — shown between the type icon and the event text --%>
      <span :if={@avatar != []} class="mt-0.5 shrink-0">
        {render_slot(@avatar)}
      </span>

      <%!-- Event description + optional right-aligned timestamp --%>
      <span class="flex min-w-0 flex-1 flex-wrap items-baseline gap-x-1 text-sm text-foreground">
        {render_slot(@inner_block)}
        <span :if={@timestamp} class="ml-auto shrink-0 text-xs text-muted-foreground">
          {@timestamp}
        </span>
      </span>
    </li>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers — pure pattern-matched functions
  # ---------------------------------------------------------------------------

  # Icon name for each activity type (Lucide icon names).
  # Pattern-matched functions keep Tailwind class strings statically visible.
  defp item_icon_name("mention"), do: "at-sign"
  defp item_icon_name("file"), do: "file"
  defp item_icon_name("call"), do: "phone"
  defp item_icon_name("task"), do: "check-square"
  defp item_icon_name("reaction"), do: "heart"
  defp item_icon_name("system"), do: "bell"

  # Soft-coloured background for the icon circle.
  # Using /30 opacity variants for dark mode so the colour remains visible but
  # does not clash with the dark background.
  defp item_icon_bg("mention"), do: "bg-orange-100 dark:bg-orange-900/30"
  defp item_icon_bg("file"), do: "bg-violet-100 dark:bg-violet-900/30"
  defp item_icon_bg("call"), do: "bg-green-100 dark:bg-green-900/30"
  defp item_icon_bg("task"), do: "bg-blue-100 dark:bg-blue-900/30"
  defp item_icon_bg("reaction"), do: "bg-pink-100 dark:bg-pink-900/30"
  defp item_icon_bg("system"), do: "bg-muted"

  # Icon fill/stroke colour — darker shade than the background for contrast.
  defp item_icon_color("mention"), do: "text-orange-600 dark:text-orange-400"
  defp item_icon_color("file"), do: "text-violet-600 dark:text-violet-400"
  defp item_icon_color("call"), do: "text-green-600 dark:text-green-400"
  defp item_icon_color("task"), do: "text-blue-600 dark:text-blue-400"
  defp item_icon_color("reaction"), do: "text-pink-600 dark:text-pink-400"
  defp item_icon_color("system"), do: "text-muted-foreground"
end
