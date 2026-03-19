defmodule PhiaUi.Components.Collab.MentionHelpers do
  @moduledoc """
  Helper functions for @mention parsing and rendering.

  Mentions follow the format `@[Display Name](user_id)` in raw text.
  This module provides utilities to parse, render, and extract user IDs
  from mention markup.
  """

  @mention_regex ~r/@\[([^\]]+)\]\(([^)]+)\)/

  @doc """
  Parse mentions from text.

  Returns a list of maps with `:start`, `:end`, `:user_id`, and `:name` keys.

  Mention format: `@[Display Name](user_id)`

  ## Examples

      iex> parse_mentions("Hello @[Alice](user-1) and @[Bob](user-2)")
      [
        %{start: 6, end: 26, user_id: "user-1", name: "Alice"},
        %{start: 31, end: 49, user_id: "user-2", name: "Bob"}
      ]

      iex> parse_mentions("No mentions here")
      []

      iex> parse_mentions(nil)
      []
  """
  @spec parse_mentions(String.t() | nil) :: [map()]
  def parse_mentions(text) when is_binary(text) do
    @mention_regex
    |> Regex.scan(text, return: :index)
    |> Enum.zip(Regex.scan(@mention_regex, text))
    |> Enum.map(fn {[{start, len} | _], [_full, name, user_id]} ->
      %{start: start, end: start + len, user_id: user_id, name: name}
    end)
  end

  def parse_mentions(_), do: []

  @doc """
  Replace mention markup with display names prefixed by @.

  Transforms `@[Display Name](user_id)` into `@Display Name`.

  ## Examples

      iex> render_mentions("Hello @[Alice](user-1)!")
      "Hello @Alice!"

      iex> render_mentions("No mentions")
      "No mentions"
  """
  @spec render_mentions(String.t(), map()) :: String.t()
  def render_mentions(text, _users_map \\ %{}) when is_binary(text) do
    Regex.replace(@mention_regex, text, fn _full, name, _user_id ->
      "@#{name}"
    end)
  end

  @doc """
  Extract unique user IDs mentioned in text.

  ## Examples

      iex> mentioned_user_ids("Hey @[Alice](u1) and @[Bob](u2) and @[Alice](u1)")
      ["u1", "u2"]

      iex> mentioned_user_ids("No mentions")
      []

      iex> mentioned_user_ids(nil)
      []
  """
  @spec mentioned_user_ids(String.t() | nil) :: [String.t()]
  def mentioned_user_ids(text) when is_binary(text) do
    text
    |> parse_mentions()
    |> Enum.map(& &1.user_id)
    |> Enum.uniq()
  end

  def mentioned_user_ids(_), do: []
end
