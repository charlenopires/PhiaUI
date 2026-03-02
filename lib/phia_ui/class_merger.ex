defmodule PhiaUi.ClassMerger do
  @moduledoc """
  Native Tailwind CSS class merger for PhiaUi.

  Provides `cn/1` — the primary utility for composing and merging
  Tailwind class strings. Designed to be imported in component modules:

      import PhiaUi.ClassMerger, only: [cn: 1]

  ## Behaviour

  - Accepts a list of class strings, `nil`, or `false` values.
  - Falsy values (`nil`, `false`) are silently discarded.
  - Individual strings may contain multiple space-separated tokens.
  - Exact duplicate tokens are deduplicated; the **last** occurrence wins,
    matching the standard CSS cascade convention.
  - Results are memoised in `PhiaUi.ClassMerger.Cache` for zero-cost
    repeated calls with the same inputs.

  ## Example

      iex> PhiaUi.ClassMerger.cn(["px-4 py-2", "font-semibold", nil, "px-4"])
      "py-2 font-semibold px-4"
  """

  alias PhiaUi.ClassMerger.Cache
  alias PhiaUi.ClassMerger.Groups

  @doc """
  Merges a list of class values into a single class string.

  Accepts `String.t()`, `nil`, or `false` elements. Returns `""` for an
  empty or fully-falsy list.
  """
  @spec cn([String.t() | nil | false]) :: String.t()
  def cn(classes) when is_list(classes) do
    case Cache.get(classes) do
      nil ->
        result = resolve(classes)
        Cache.put(classes, result)
        result

      cached ->
        cached
    end
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp resolve(classes) do
    classes
    |> Enum.flat_map(&tokenise/1)
    |> dedup_last_wins()
    |> Enum.join(" ")
  end

  # Convert a single item to a list of trimmed, non-empty tokens.
  defp tokenise(nil), do: []
  defp tokenise(false), do: []

  defp tokenise(class) when is_binary(class) do
    String.split(class, ~r/\s+/, trim: true)
  end

  # Deduplicate preserving last-occurrence order with Tailwind group awareness.
  #
  # Key: use the class's conflict group when known, or the token itself for
  # unknown classes (falls back to exact-match deduplication).
  #
  # Algorithm: reverse → reduce keeping first-seen per key → reverse back.
  # "First seen in reversed list" == "last seen in original list" → last wins.
  defp dedup_last_wins(tokens) do
    {result, _seen} =
      tokens
      |> Enum.reverse()
      |> Enum.reduce({[], MapSet.new()}, fn token, {acc, seen} ->
        key = Groups.group_for(token) || token

        if MapSet.member?(seen, key) do
          {acc, seen}
        else
          {[token | acc], MapSet.put(seen, key)}
        end
      end)

    result
  end
end
