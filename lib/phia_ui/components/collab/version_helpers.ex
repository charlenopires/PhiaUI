defmodule PhiaUi.Components.Collab.VersionHelpers do
  @moduledoc """
  Helper functions for document version history and diffing.

  Provides utilities for computing structural diffs between TipTap JSON
  documents, generating human-readable change summaries, formatting version
  timestamps, grouping versions by day, and calculating word count deltas.
  """

  # ---------------------------------------------------------------------------
  # Document Diffing
  # ---------------------------------------------------------------------------

  @doc """
  Compute a structural diff between two TipTap JSON documents.

  Compares the top-level `"content"` arrays node-by-node and returns a list
  of change maps describing additions, removals, and modifications.

  ## Return shape

      [%{type: :added | :removed | :modified, path: [integer()], ...}]

  ## Examples

      iex> old = %{"content" => [%{"type" => "paragraph", "text" => "Hello"}]}
      iex> new = %{"content" => [%{"type" => "paragraph", "text" => "Hello"}, %{"type" => "paragraph", "text" => "World"}]}
      iex> VersionHelpers.diff_documents(old, new)
      [%{type: :added, path: [1], content: %{"type" => "paragraph", "text" => "World"}}]
  """
  @spec diff_documents(map(), map()) :: [map()]
  def diff_documents(old_doc, new_doc) when is_map(old_doc) and is_map(new_doc) do
    old_content = Map.get(old_doc, "content", [])
    new_content = Map.get(new_doc, "content", [])
    compute_content_diff(old_content, new_content, [], 0)
  end

  def diff_documents(_, _), do: []

  defp compute_content_diff([], [], _path, _idx), do: []

  defp compute_content_diff([], new_nodes, path, idx) do
    new_nodes
    |> Enum.with_index(idx)
    |> Enum.map(fn {node, i} ->
      %{type: :added, path: path ++ [i], content: node}
    end)
  end

  defp compute_content_diff(old_nodes, [], path, idx) do
    old_nodes
    |> Enum.with_index(idx)
    |> Enum.map(fn {node, i} ->
      %{type: :removed, path: path ++ [i], content: node}
    end)
  end

  defp compute_content_diff([old_h | old_t], [new_h | new_t], path, idx) do
    current =
      if old_h == new_h do
        []
      else
        [%{type: :modified, path: path ++ [idx], old: old_h, new: new_h}]
      end

    current ++ compute_content_diff(old_t, new_t, path, idx + 1)
  end

  # ---------------------------------------------------------------------------
  # Change Summary
  # ---------------------------------------------------------------------------

  @doc """
  Generate a human-readable summary of changes from a diff result.

  ## Examples

      iex> VersionHelpers.diff_summary([%{type: :added}, %{type: :removed}])
      "1 added, 1 removed"

      iex> VersionHelpers.diff_summary([])
      "No changes"
  """
  @spec diff_summary([map()]) :: String.t()
  def diff_summary(changes) when is_list(changes) do
    added = Enum.count(changes, &(&1.type == :added))
    removed = Enum.count(changes, &(&1.type == :removed))
    modified = Enum.count(changes, &(&1.type == :modified))

    parts =
      []
      |> maybe_append(added, "added")
      |> maybe_append(removed, "removed")
      |> maybe_append(modified, "modified")

    case parts do
      [] -> "No changes"
      _ -> Enum.join(parts, ", ")
    end
  end

  def diff_summary(_), do: "No changes"

  defp maybe_append(parts, 0, _label), do: parts
  defp maybe_append(parts, count, label), do: parts ++ ["#{count} #{label}"]

  # ---------------------------------------------------------------------------
  # Date Formatting
  # ---------------------------------------------------------------------------

  @doc """
  Format a version timestamp for display.

  Returns a human-readable date string such as "March 19, 2026 at 02:30 PM".

  ## Examples

      iex> VersionHelpers.format_version_date(nil)
      ""

      iex> VersionHelpers.format_version_date(~U[2026-03-19 14:30:00Z])
      "March 19, 2026 at 02:30 PM"
  """
  @spec format_version_date(DateTime.t() | NaiveDateTime.t() | nil) :: String.t()
  def format_version_date(nil), do: ""

  def format_version_date(datetime) do
    Calendar.strftime(datetime, "%B %d, %Y at %I:%M %p")
  end

  # ---------------------------------------------------------------------------
  # Version Grouping
  # ---------------------------------------------------------------------------

  @doc """
  Group versions by day for timeline display.

  Takes a list of version maps (with `:created_at` or `"created_at"` key)
  and returns a list of `{date, versions}` tuples sorted by date descending.

  ## Examples

      iex> versions = [%{created_at: ~U[2026-03-19 10:00:00Z]}, %{created_at: ~U[2026-03-18 09:00:00Z]}]
      iex> VersionHelpers.group_versions_by_day(versions)
      [{~D[2026-03-19], [%{created_at: ~U[2026-03-19 10:00:00Z]}]}, {~D[2026-03-18], [%{created_at: ~U[2026-03-18 09:00:00Z]}]}]
  """
  @spec group_versions_by_day([map()]) :: [{Date.t(), [map()]}]
  def group_versions_by_day(versions) when is_list(versions) do
    versions
    |> Enum.group_by(fn v ->
      datetime = Map.get(v, :created_at) || Map.get(v, "created_at")

      if datetime do
        DateTime.to_date(datetime)
      else
        Date.utc_today()
      end
    end)
    |> Enum.sort_by(fn {date, _} -> date end, {:desc, Date})
  end

  def group_versions_by_day(_), do: []

  # ---------------------------------------------------------------------------
  # Word Count Delta
  # ---------------------------------------------------------------------------

  @doc """
  Calculate word count delta between two versions as a display string.

  ## Examples

      iex> VersionHelpers.word_count_delta(100, 120)
      "+20"

      iex> VersionHelpers.word_count_delta(100, 80)
      "-20"

      iex> VersionHelpers.word_count_delta(100, 100)
      "0"
  """
  @spec word_count_delta(integer(), integer()) :: String.t()
  def word_count_delta(old_count, new_count)
      when is_integer(old_count) and is_integer(new_count) do
    delta = new_count - old_count

    cond do
      delta > 0 -> "+#{delta}"
      delta < 0 -> "#{delta}"
      true -> "0"
    end
  end

  def word_count_delta(_, _), do: "0"
end
