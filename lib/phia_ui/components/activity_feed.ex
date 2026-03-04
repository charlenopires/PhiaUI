defmodule PhiaUi.Components.ActivityFeed do
  @moduledoc """
  Activity feed / activity log component for PhiaUI.

  Renders a chronological activity log grouped by date, with per-event type icons,
  optional avatars, timestamps, and an optional comment input footer.

  CSS-only — no JS hook required. Server-rendered and streams-compatible.

  ## Sub-components

  - `activity_feed/1` — root container (`role="log"`, `aria-live="polite"`)
  - `activity_group/1` — date group with a visible label (Today / Yesterday / date)
  - `activity_item/1` — individual event row with colored icon, optional avatar, text, timestamp

  ## Activity item types

  | Type       | Icon         | Color                  |
  |-----------|-------------|------------------------|
  | `mention`  | at-sign      | Orange                 |
  | `file`     | file         | Violet                 |
  | `call`     | phone        | Green                  |
  | `task`     | check-square | Blue                   |
  | `reaction` | heart        | Pink                   |
  | `system`   | bell         | Muted (semantic token) |

  ## Examples

      <.activity_feed id="activity-log">
        <.activity_group label="Today">
          <.activity_item type="mention" timestamp="9:12 AM">
            <:avatar>
              <.avatar size="sm"><.avatar_fallback name="Jason Carter" /></.avatar>
            </:avatar>
            <span>
              <strong>Jason Carter</strong> mentioned
              <span class="font-medium text-primary">@you</span>
              in thread <strong>#Lead Follow-up</strong>.
            </span>
          </.activity_item>

          <.activity_item type="file" timestamp="9:46 AM">
            New file uploaded: <strong>Q3_Sales_Targets_v2.xlsx</strong>
          </.activity_item>
        </.activity_group>

        <.activity_group label="Yesterday">
          <.activity_item type="task" timestamp="09:18 AM">
            Task assigned: <strong>Pitch Deck</strong>
          </.activity_item>
        </.activity_group>

        <:footer>
          <form phx-submit="send_comment" class="flex gap-2">
            <input
              name="comment"
              placeholder={~s(Comment or type "c" for comments)}
              class="flex-1 rounded-md border border-input bg-background px-3 py-2 text-sm"
            />
          </form>
        </:footer>
      </.activity_feed>

  ## Streams compatibility

  The `id` attribute on `activity_feed/1` enables LiveView streams to diff-patch
  individual `activity_item/1` items without re-rendering the full feed. Each item
  should carry its own `id` for optimal stream performance:

      <.activity_item :for={{dom_id, item} <- @streams.activities} id={dom_id} type={item.type}>
        {item.text}
      </.activity_item>

  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  # ---------------------------------------------------------------------------
  # activity_feed/1
  # ---------------------------------------------------------------------------

  attr(:id, :string, default: nil, doc: "Optional DOM id — required for LiveView streams")
  attr(:class, :string, default: nil, doc: "Additional CSS classes for the feed container")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root div")

  slot(:inner_block, required: true, doc: "activity_group and/or activity_item children")

  slot(:footer,
    doc: "Optional footer slot — typically a comment form with phx-submit"
  )

  @doc """
  Renders the activity feed container.

  Sets `role="log"` and `aria-live="polite"` so screen readers announce new
  activity items pushed via LiveView without interrupting the user.
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
    doc: "Date group label: \"Today\", \"Yesterday\", or a date string"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the group wrapper")
  attr(:rest, :global, doc: "HTML attributes forwarded to the section element")

  slot(:inner_block, required: true, doc: "activity_item children")

  @doc """
  Renders a date-grouped section of activity items.

  The `:label` is rendered as a small muted badge above the items (e.g. "Today",
  "Yesterday", "Mar 3, 2026"). Place `activity_item/1` components inside.
  """
  def activity_group(assigns) do
    ~H"""
    <section class={cn(["mb-4", @class])} {@rest}>
      <div class="mb-2 flex items-center gap-2">
        <span class="rounded-full border border-border bg-muted px-2.5 py-0.5 text-xs font-medium text-muted-foreground">
          {@label}
        </span>
        <span class="h-px flex-1 bg-border" aria-hidden="true" />
      </div>
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
    doc: "Activity type — controls icon and icon color"
  )

  attr(:timestamp, :string, default: nil, doc: "Optional timestamp label (e.g. \"9:12 AM\")")
  attr(:class, :string, default: nil, doc: "Additional CSS classes for the item")
  attr(:rest, :global, doc: "HTML attributes forwarded to the li element")

  slot(:avatar, doc: "Optional Avatar component displayed beside the event text")
  slot(:inner_block, required: true, doc: "Event text content (may include inline markup)")

  @doc """
  Renders a single activity event row.

  The `:type` attr selects the icon and color scheme. Supply an `avatar` slot to
  display a user avatar beside the text. The `:timestamp` attr renders a small
  muted label at the end of the row.
  """
  def activity_item(assigns) do
    ~H"""
    <li class={cn(["flex items-start gap-3", @class])} {@rest}>
      <%!-- Type icon circle --%>
      <span
        data-activity-type={@type}
        class={cn(["mt-0.5 flex h-7 w-7 shrink-0 items-center justify-center rounded-full", item_icon_bg(@type)])}
        aria-hidden="true"
      >
        <.icon name={item_icon_name(@type)} size={:xs} class={item_icon_color(@type)} />
      </span>

      <%!-- Optional avatar --%>
      <span :if={@avatar != []} class="mt-0.5 shrink-0">
        {render_slot(@avatar)}
      </span>

      <%!-- Content + timestamp --%>
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
  # Private helpers — pattern matching only
  # ---------------------------------------------------------------------------

  defp item_icon_name("mention"), do: "at-sign"
  defp item_icon_name("file"), do: "file"
  defp item_icon_name("call"), do: "phone"
  defp item_icon_name("task"), do: "check-square"
  defp item_icon_name("reaction"), do: "heart"
  defp item_icon_name("system"), do: "bell"

  defp item_icon_bg("mention"), do: "bg-orange-100 dark:bg-orange-900/30"
  defp item_icon_bg("file"), do: "bg-violet-100 dark:bg-violet-900/30"
  defp item_icon_bg("call"), do: "bg-green-100 dark:bg-green-900/30"
  defp item_icon_bg("task"), do: "bg-blue-100 dark:bg-blue-900/30"
  defp item_icon_bg("reaction"), do: "bg-pink-100 dark:bg-pink-900/30"
  defp item_icon_bg("system"), do: "bg-muted"

  defp item_icon_color("mention"), do: "text-orange-600 dark:text-orange-400"
  defp item_icon_color("file"), do: "text-violet-600 dark:text-violet-400"
  defp item_icon_color("call"), do: "text-green-600 dark:text-green-400"
  defp item_icon_color("task"), do: "text-blue-600 dark:text-blue-400"
  defp item_icon_color("reaction"), do: "text-pink-600 dark:text-pink-400"
  defp item_icon_color("system"), do: "text-muted-foreground"
end
