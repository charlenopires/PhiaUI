defmodule PhiaUi.Components.Display.ActivityTimeline do
  @moduledoc """
  Vertical activity timeline for document edit history.

  Shows a chronological list of edit events grouped by day, with user avatars,
  action descriptions, and relative timestamps. Used in the editor activity panel.

  ## Examples

      <.activity_timeline
        id="doc-activity"
        events={@edit_events}
      />
  """

  use Phoenix.Component

  @doc """
  Renders a vertical timeline of edit events.

  ## Attributes

  * `id` — required unique DOM id
  * `events` — list of maps with keys: `id`, `user_id`, `action`, `section_name`,
    `metadata`, `inserted_at`, plus optional: `user_name`, `user_color`, `user_avatar_url`
  * `class` — optional extra CSS classes
  """
  attr :id, :string, required: true
  attr :events, :list, default: []
  attr :class, :string, default: nil

  def activity_timeline(assigns) do
    grouped = group_by_day(assigns.events)

    assigns = assign(assigns, :grouped, grouped)

    ~H"""
    <div id={@id} class={["space-y-4", @class]}>
      <div :if={@events == []} class="py-8 text-center text-sm text-gray-400">
        No activity yet
      </div>

      <div :for={{day_label, events} <- @grouped} class="space-y-1">
        <%!-- Day header --%>
        <h4 class="sticky top-0 z-10 bg-white/90 px-2 py-1 text-xs font-semibold text-gray-400 uppercase tracking-wider backdrop-blur-sm">
          {day_label}
        </h4>

        <%!-- Event entries --%>
        <div :for={event <- events} class="flex items-start gap-2.5 rounded-md px-2 py-1.5 hover:bg-gray-50 transition-colors">
          <%!-- Avatar --%>
          <div
            class="flex h-6 w-6 shrink-0 items-center justify-center rounded-full text-[10px] font-medium text-white"
            style={"background-color: #{event_color(event)}"}
          >
            {event_initial(event)}
          </div>

          <%!-- Content --%>
          <div class="min-w-0 flex-1">
            <p class="text-sm text-gray-700">
              <span class="font-medium">{event_user_name(event)}</span>
              <span class="text-gray-500"> {action_description(event)}</span>
            </p>
            <p :if={event_section(event)} class="text-xs text-gray-400 truncate">
              in {event_section(event)}
            </p>
          </div>

          <%!-- Timestamp --%>
          <time class="shrink-0 text-xs text-gray-400 tabular-nums" datetime={to_string(event.inserted_at)}>
            {relative_time(event.inserted_at)}
          </time>
        </div>
      </div>
    </div>
    """
  end

  # ── Helpers ──────────────────────────────────────────────────────────

  defp group_by_day(events) do
    events
    |> Enum.group_by(fn event ->
      date = DateTime.to_date(event.inserted_at)
      today = Date.utc_today()

      cond do
        date == today -> "Today"
        date == Date.add(today, -1) -> "Yesterday"
        true -> Calendar.strftime(date, "%B %d")
      end
    end)
    |> Enum.sort_by(
      fn {_label, [first | _]} -> first.inserted_at end,
      {:desc, DateTime}
    )
  end

  defp event_color(%{user_color: color}) when is_binary(color) and color != "", do: color
  defp event_color(%{user_id: uid}) when is_binary(uid) do
    colors = ["#E53E3E", "#3182CE", "#38A169", "#805AD5", "#DD6B20", "#D53F8C"]
    Enum.at(colors, :erlang.phash2(uid, length(colors)))
  end
  defp event_color(_), do: "#6B7280"

  defp event_initial(%{user_name: name}) when is_binary(name) and name != "" do
    name |> String.first() |> String.upcase()
  end
  defp event_initial(_), do: "?"

  defp event_user_name(%{user_name: name}) when is_binary(name) and name != "", do: name
  defp event_user_name(_), do: "Unknown"

  defp event_section(%{section_name: s}) when is_binary(s) and s != "", do: s
  defp event_section(_), do: nil

  defp action_description(%{action: "edit_content"}), do: "edited content"
  defp action_description(%{action: "edit_title"}), do: "changed the title"
  defp action_description(%{action: "add_comment"}), do: "added a comment"
  defp action_description(%{action: "resolve_comment"}), do: "resolved a comment"
  defp action_description(%{action: "restore_version"}), do: "restored a version"
  defp action_description(%{action: "share"}), do: "shared the document"
  defp action_description(%{action: action}) when is_binary(action), do: action
  defp action_description(_), do: "made a change"

  defp relative_time(datetime) do
    now = DateTime.utc_now()
    diff = DateTime.diff(now, datetime, :second)

    cond do
      diff < 60 -> "just now"
      diff < 3600 -> "#{div(diff, 60)}m ago"
      diff < 86400 -> "#{div(diff, 3600)}h ago"
      diff < 604_800 -> "#{div(diff, 86400)}d ago"
      true -> Calendar.strftime(datetime, "%b %d")
    end
  end
end
