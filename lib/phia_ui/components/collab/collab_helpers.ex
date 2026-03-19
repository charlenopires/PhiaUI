defmodule PhiaUi.Components.Collab.CollabHelpers do
  @moduledoc """
  Shared helper functions for collaboration components.

  Provides utilities for time formatting, user display, color assignment,
  mention rendering, and text truncation used across the Collab Suite.
  """

  @doc """
  Formats a DateTime as a relative time string.

  Returns human-readable strings like "just now", "2 minutes ago",
  "Yesterday", "3 days ago", or a formatted date for older timestamps.

  ## Examples

      iex> format_relative_time(nil)
      ""

      iex> format_relative_time(~U[2026-03-19 12:00:00Z])
      "just now"  # if called within 5 seconds
  """
  @spec format_relative_time(DateTime.t() | nil) :: String.t()
  def format_relative_time(nil), do: ""

  def format_relative_time(%DateTime{} = datetime) do
    now = DateTime.utc_now()
    diff = DateTime.diff(now, datetime, :second)

    cond do
      diff < 0 -> "just now"
      diff < 5 -> "just now"
      diff < 60 -> "#{diff} seconds ago"
      diff < 120 -> "1 minute ago"
      diff < 3600 -> "#{div(diff, 60)} minutes ago"
      diff < 7200 -> "1 hour ago"
      diff < 86_400 -> "#{div(diff, 3600)} hours ago"
      diff < 172_800 -> "Yesterday"
      diff < 604_800 -> "#{div(diff, 86400)} days ago"
      true -> Calendar.strftime(datetime, "%b %d, %Y")
    end
  end

  @doc """
  Returns initials from a user name (up to 2 characters).

  Splits the name on whitespace, takes the first letter of the first
  two words, and uppercases them.

  ## Examples

      iex> user_initials("Jane Doe")
      "JD"

      iex> user_initials("alice")
      "A"

      iex> user_initials(nil)
      "?"
  """
  @spec user_initials(String.t() | nil) :: String.t()
  def user_initials(nil), do: "?"
  def user_initials(""), do: "?"

  def user_initials(name) when is_binary(name) do
    name
    |> String.split(~r/\s+/, trim: true)
    |> Enum.take(2)
    |> Enum.map(&String.first/1)
    |> Enum.join()
    |> String.upcase()
  end

  @doc """
  Deterministic OKLCH color from a user_id hash for consistent color assignment.

  Uses `:erlang.phash2/2` to generate a hue value (0-359) from the user_id
  string, producing the same color for the same user across sessions.

  ## Examples

      iex> collab_color("user-1")
      "oklch(0.7 0.15 42)"  # deterministic hue from hash
  """
  @spec collab_color(String.t() | any()) :: String.t()
  def collab_color(user_id) when is_binary(user_id) do
    hue = :erlang.phash2(user_id, 360)
    "oklch(0.7 0.15 #{hue})"
  end

  def collab_color(_), do: "oklch(0.7 0.15 260)"

  @doc """
  Formats an @mention as a display string.

  ## Examples

      iex> format_mention("Alice")
      "@Alice"
  """
  @spec format_mention(String.t()) :: String.t()
  def format_mention(name) when is_binary(name) do
    "@#{name}"
  end

  @doc """
  Truncates text to max_length characters with ellipsis appended.

  Returns the original text if it is shorter than or equal to max_length.

  ## Examples

      iex> truncate_preview("Hello world", 5)
      "Hello..."

      iex> truncate_preview("Hi", 10)
      "Hi"

      iex> truncate_preview(nil, 10)
      ""
  """
  @spec truncate_preview(String.t() | nil, non_neg_integer()) :: String.t()
  def truncate_preview(nil, _max), do: ""
  def truncate_preview(text, max) when is_binary(text) and byte_size(text) <= max, do: text

  def truncate_preview(text, max) when is_binary(text) do
    String.slice(text, 0, max) <> "..."
  end
end
