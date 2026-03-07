defmodule PhiaUi.Components.Leaderboard do
  @moduledoc """
  Leaderboard — ranked list with medals, avatars, metrics, and delta badges.

  Inspired by Ant Design Statistics + custom patterns, Mantine leaderboard blocks.
  Ranks 1-3 receive gold/silver/bronze medal styling. Higher ranks use a muted badge.
  Avatar image is shown when `:avatar_src` is present; initials fallback otherwise.
  Delta is rendered via `BadgeDelta` when both `:delta` and `:delta_type` are provided.

  ## Examples

      <.leaderboard items={[
        %{rank: 1, name: "Alice",   metric: "9,842 pts", delta: "+12%", delta_type: :increase},
        %{rank: 2, name: "Bob",     metric: "8,120 pts", delta: "-3%",  delta_type: :decrease},
        %{rank: 3, name: "Charlie", metric: "7,654 pts"},
      ]} />

      <.leaderboard items={@top_users} size={:sm} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.BadgeDelta, only: [badge_delta: 1]

  attr(:items, :list,
    required: true,
    doc: """
    List of maps with:
    - `:rank` (integer, required)
    - `:name` (string, required)
    - `:metric` (string, required)
    - `:delta` (string, optional) — shown as `BadgeDelta` when `:delta_type` also present
    - `:delta_type` (atom, optional) — see `BadgeDelta` for values
    - `:avatar_src` (string, optional) — image URL; shows initials when absent
    """
  )

  attr(:size, :atom,
    default: :default,
    values: [:sm, :default],
    doc: "Controls row height and text size."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the root element.")
  attr(:rest, :global, doc: "HTML attributes forwarded to the root `<ol>`.")

  def leaderboard(assigns) do
    ~H"""
    <ol role="list" class={cn(["w-full space-y-2", @class])} {@rest}>
      <li
        :for={item <- @items}
        class={cn([
          "flex items-center gap-3 rounded-lg border border-border bg-card px-3",
          row_padding(@size)
        ])}
      >
        <%!-- Rank badge --%>
        <span
          class={cn([
            "inline-flex h-7 w-7 shrink-0 items-center justify-center rounded-full text-xs font-bold",
            rank_style(item.rank)
          ])}
        >
          {item.rank}
        </span>

        <%!-- Avatar --%>
        <div class="shrink-0">
          <img
            :if={Map.get(item, :avatar_src)}
            src={item.avatar_src}
            alt={item.name}
            class="h-8 w-8 rounded-full object-cover"
          />
          <span
            :if={!Map.get(item, :avatar_src)}
            class="inline-flex h-8 w-8 items-center justify-center rounded-full bg-muted text-sm font-medium text-muted-foreground"
          >
            {String.first(item.name)}
          </span>
        </div>

        <%!-- Name --%>
        <span class={cn(["flex-1 font-medium truncate", name_size(@size)])}>
          {item.name}
        </span>

        <%!-- Metric --%>
        <span class="text-sm font-semibold text-foreground shrink-0">
          {item.metric}
        </span>

        <%!-- Delta badge (only when both delta and delta_type present) --%>
        <.badge_delta
          :if={Map.get(item, :delta) && Map.get(item, :delta_type)}
          value={Map.get(item, :delta, "")}
          delta_type={Map.get(item, :delta_type, :unchanged)}
          size={:xs}
        />
      </li>
    </ol>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers — pattern-matched, no case/cond
  # ---------------------------------------------------------------------------

  defp rank_style(1), do: "bg-yellow-400 text-yellow-900"
  defp rank_style(2), do: "bg-gray-300 text-gray-700"
  defp rank_style(3), do: "bg-amber-600 text-white"
  defp rank_style(_), do: "bg-muted text-muted-foreground"

  defp row_padding(:sm), do: "py-2"
  defp row_padding(:default), do: "py-3"

  defp name_size(:sm), do: "text-sm"
  defp name_size(:default), do: "text-base"
end
