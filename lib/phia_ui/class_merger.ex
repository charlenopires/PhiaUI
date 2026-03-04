defmodule PhiaUi.ClassMerger do
  @moduledoc """
  Native Tailwind CSS class merger for PhiaUi.

  Provides `cn/1` — the primary utility for composing and merging Tailwind
  class strings. It is the Elixir equivalent of the JavaScript combination of
  `clsx` (conditional class joining) and `tailwind-merge` (conflict resolution).

  Designed to be imported in component modules:

      import PhiaUi.ClassMerger, only: [cn: 1]

  ## Behaviour

  - Accepts a list of class strings, `nil`, or `false` values.
  - Falsy values (`nil`, `false`) are silently discarded, making it safe to
    pass conditional expressions directly in the list.
  - Individual strings may contain multiple space-separated tokens.
  - Exact duplicate tokens are deduplicated; the **last** occurrence wins,
    matching the standard CSS cascade convention.
  - When two classes belong to the same Tailwind **conflict group** (i.e. they
    both target the same CSS property — see `PhiaUi.ClassMerger.Groups`), the
    last one wins and the earlier one is removed entirely.
  - Results are memoised in `PhiaUi.ClassMerger.Cache` (an ETS table) for
    zero-cost repeated calls with the same inputs.

  ## Conflict Resolution Examples

  Padding axis conflict — `px-2` and `px-4` both set `padding-inline`;
  the later `px-4` wins:

      iex> PhiaUi.ClassMerger.cn(["px-2 py-1", "px-4"])
      "py-1 px-4"

  Background colour conflict — only one `bg-*` class is kept:

      iex> PhiaUi.ClassMerger.cn(["bg-blue-500", "bg-red-600"])
      "bg-red-600"

  Text size conflict — `text-sm` and `text-lg` both set `font-size`:

      iex> PhiaUi.ClassMerger.cn(["text-sm font-bold", "text-lg"])
      "font-bold text-lg"

  Text colour vs text size — these are different groups and are both kept:

      iex> PhiaUi.ClassMerger.cn(["text-sm", "text-red-500"])
      "text-sm text-red-500"

  Falsy values are silently ignored:

      iex> PhiaUi.ClassMerger.cn(["px-4 py-2", nil, false, "font-semibold"])
      "px-4 py-2 font-semibold"

  Exact duplicates are deduplicated; last occurrence wins:

      iex> PhiaUi.ClassMerger.cn(["px-4 py-2", "font-semibold", nil, "px-4"])
      "py-2 font-semibold px-4"

  Empty list returns an empty string:

      iex> PhiaUi.ClassMerger.cn([])
      ""

  ## Usage in Components

  Every PhiaUI component uses `cn/1` to merge its base classes with the
  caller-supplied `class` override attribute:

      def button(assigns) do
        ~H\"\"\"
        <button class={cn(["px-4 py-2 rounded", @variant_class, @class])}>
          <%= render_slot(@inner_block) %>
        </button>
        \"\"\"
      end

  This lets callers override individual utilities without duplicating the
  component's full class list:

      # Replaces px-4 with px-8; everything else is unchanged.
      <.button class="px-8">Wide Button</.button>

  ## Performance

  `cn/1` is called on every component render. The first call for a given
  list of inputs runs the full resolution pipeline (tokenise → dedup → join)
  and writes the result to the ETS cache. Subsequent calls with identical
  inputs return the cached string directly from ETS in O(1) time, bypassing
  the pipeline entirely.

  Because the ETS table is configured with `read_concurrency: true`, reads from
  concurrent LiveView processes are lock-free and do not serialise through any
  single GenServer process.
  """

  alias PhiaUi.ClassMerger.Cache
  alias PhiaUi.ClassMerger.Groups

  @doc """
  Merges a list of class values into a single, conflict-resolved class string.

  Accepts `String.t()`, `nil`, or `false` elements. Returns `""` for an
  empty or fully-falsy list. When multiple classes target the same Tailwind
  utility group, the last one in the list wins and all earlier ones are
  removed.

  Results are memoised in ETS. The first call for a given input list runs the
  full resolution pipeline; subsequent identical calls are O(1) cache hits.

  ## Examples

      iex> PhiaUi.ClassMerger.cn(["px-4 py-2", "font-semibold", nil, "px-4"])
      "py-2 font-semibold px-4"

      iex> PhiaUi.ClassMerger.cn(["bg-primary", "bg-secondary"])
      "bg-secondary"

      iex> PhiaUi.ClassMerger.cn([nil, false, nil])
      ""
  """
  @spec cn([String.t() | nil | false]) :: String.t()
  def cn(classes) when is_list(classes) do
    # Check the ETS cache before doing any string work. The cache key is the
    # raw input list, so structurally identical lists (same elements, same
    # order) always hit the same cache entry.
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

  # Runs the full resolution pipeline for a cache miss:
  # 1. Flatten all input items into individual tokens (discarding nil/false).
  # 2. Deduplicate with last-wins and Tailwind group awareness.
  # 3. Rejoin into a single space-separated string.
  defp resolve(classes) do
    classes
    |> Enum.flat_map(&tokenise/1)
    |> dedup_last_wins()
    |> Enum.join(" ")
  end

  # Convert a single item to a list of trimmed, non-empty tokens.
  # nil and false are valid list elements (conditional class patterns) and
  # simply produce no tokens — they are silently discarded.
  defp tokenise(nil), do: []
  defp tokenise(false), do: []

  defp tokenise(class) when is_binary(class) do
    # Split on any run of whitespace so tabs, newlines, and multiple spaces
    # in a class string are all treated as token separators.
    String.split(class, ~r/\s+/, trim: true)
  end

  # Deduplicate preserving last-occurrence order with Tailwind group awareness.
  #
  # The key insight: two classes may conflict even when they are not identical
  # strings (e.g. "px-2" and "px-4"). We ask Groups.group_for/1 to map each
  # token to its conflict group atom. If two tokens share a group atom, they
  # target the same CSS property and only the last should be kept.
  #
  # For tokens without a known group, the token itself is used as the key,
  # falling back to exact-match deduplication — the safe behaviour for custom
  # or arbitrary class names that are not in the Tailwind conflict table.
  #
  # Algorithm: reverse → reduce keeping first-seen per key → reverse back.
  # "First seen in reversed list" == "last seen in original list" → last wins.
  # This is O(n) in time and space where n is the number of tokens.
  defp dedup_last_wins(tokens) do
    {result, _seen} =
      tokens
      |> Enum.reverse()
      |> Enum.reduce({[], MapSet.new()}, fn token, {acc, seen} ->
        # Use the conflict group atom as the dedup key when available.
        # Unknown classes fall back to the token string itself so that
        # "my-custom-class" appearing twice is still deduplicated correctly.
        key = Groups.group_for(token) || token

        if MapSet.member?(seen, key) do
          # A later occurrence (earlier in the original list) already claimed
          # this conflict group — discard this earlier token.
          {acc, seen}
        else
          # First time we've seen this key (in reverse order = last in the
          # original list): keep the token and mark the key as seen.
          {[token | acc], MapSet.put(seen, key)}
        end
      end)

    result
  end
end
