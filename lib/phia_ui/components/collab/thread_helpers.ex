defmodule PhiaUi.Components.Collab.ThreadHelpers do
  @moduledoc """
  Helper functions for thread management in collaboration components.

  Provides utilities for counting replies, extracting participants,
  checking resolution status, and sorting/filtering thread collections.
  """

  @doc """
  Count replies in a thread (excludes the root comment).

  ## Examples

      iex> thread_reply_count(%{comments: [%{}, %{}, %{}]})
      2

      iex> thread_reply_count(%{comments: []})
      0

      iex> thread_reply_count(%{})
      0
  """
  @spec thread_reply_count(map()) :: non_neg_integer()
  def thread_reply_count(%{comments: comments}) when is_list(comments) do
    max(0, length(comments) - 1)
  end

  def thread_reply_count(_), do: 0

  @doc """
  Get unique participant user IDs in a thread.

  ## Examples

      iex> thread_participants(%{comments: [%{user_id: "a"}, %{user_id: "b"}, %{user_id: "a"}]})
      ["a", "b"]
  """
  @spec thread_participants(map()) :: [String.t()]
  def thread_participants(%{comments: comments}) when is_list(comments) do
    comments
    |> Enum.map(& &1.user_id)
    |> Enum.uniq()
  end

  def thread_participants(_), do: []

  @doc """
  Check if a thread is resolved.

  ## Examples

      iex> thread_is_resolved(%{resolved: true})
      true

      iex> thread_is_resolved(%{resolved: false})
      false
  """
  @spec thread_is_resolved(map()) :: boolean()
  def thread_is_resolved(%{resolved: true}), do: true
  def thread_is_resolved(_), do: false

  @doc """
  Sort threads by the given strategy.

  Strategies:
  - `:date` — newest first by `created_at`
  - `:activity` — most recently active first (last comment time)
  - `:unresolved_first` — unresolved threads before resolved ones

  ## Examples

      iex> sort_threads(threads, :unresolved_first)
      [%{resolved: false, ...}, %{resolved: true, ...}]
  """
  @spec sort_threads([map()], atom()) :: [map()]
  def sort_threads(threads, :date) do
    Enum.sort_by(threads, &thread_sort_date/1, {:desc, DateTime})
  end

  def sort_threads(threads, :activity) do
    Enum.sort_by(
      threads,
      fn t ->
        last_comment = List.last(Map.get(t, :comments, []) || [])

        if last_comment,
          do: Map.get(last_comment, :created_at, DateTime.from_unix!(0)),
          else: thread_sort_date(t)
      end,
      {:desc, DateTime}
    )
  end

  def sort_threads(threads, :unresolved_first) do
    Enum.sort_by(threads, fn t -> if t.resolved, do: 1, else: 0 end)
  end

  def sort_threads(threads, _), do: threads

  @doc """
  Filter threads by criteria.

  Supported options:
  - `:user_id` — only threads where the user participated
  - `:resolved` — only threads matching the resolved status

  ## Examples

      iex> filter_threads(threads, user_id: "user-1")
      [%{...}]

      iex> filter_threads(threads, resolved: false)
      [%{resolved: false, ...}]
  """
  @spec filter_threads([map()], keyword()) :: [map()]
  def filter_threads(threads, opts) do
    threads
    |> maybe_filter_by_user(opts[:user_id])
    |> maybe_filter_by_resolved(opts[:resolved])
  end

  defp maybe_filter_by_user(threads, nil), do: threads

  defp maybe_filter_by_user(threads, user_id) do
    Enum.filter(threads, fn t ->
      Enum.any?(t.comments || [], &(&1.user_id == user_id))
    end)
  end

  defp maybe_filter_by_resolved(threads, nil), do: threads

  defp maybe_filter_by_resolved(threads, resolved) do
    Enum.filter(threads, &(&1.resolved == resolved))
  end

  defp thread_sort_date(thread) do
    Map.get(thread, :created_at) || DateTime.from_unix!(0)
  end
end
