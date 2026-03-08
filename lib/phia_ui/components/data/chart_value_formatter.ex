defmodule PhiaUi.Components.Data.ChartValueFormatter do
  @moduledoc false
  # Configurable value formatting pipeline.
  # Inspired by Tremor's ValueFormatter type and defaultValueFormatter utility.
  # Not registered in ComponentRegistry — internal only.

  @doc """
  Default formatter — converts a number to a string.

  ## Examples

      iex> ChartValueFormatter.default_formatter().(1234)
      "1234"
  """
  def default_formatter do
    fn value -> to_string(value) end
  end

  @doc """
  Currency formatter with thousand separators.

  ## Examples

      iex> ChartValueFormatter.currency_formatter().(1234567)
      "$ 1,234,567"
  """
  def currency_formatter(symbol \\ "$") do
    fn value ->
      formatted = format_number(value)
      "#{symbol} #{formatted}"
    end
  end

  @doc """
  Percentage formatter.

  ## Examples

      iex> ChartValueFormatter.percent_formatter().(0.756)
      "75.6%"
  """
  def percent_formatter(decimals \\ 1) do
    fn value ->
      pct = value * 100
      "#{Float.round(pct * 1.0, decimals)}%"
    end
  end

  @doc """
  Compact number formatter (K, M, B suffixes).

  ## Examples

      iex> ChartValueFormatter.compact_formatter().(1_500_000)
      "1.5M"
  """
  def compact_formatter do
    fn value ->
      abs_val = abs(value)
      sign = if value < 0, do: "-", else: ""

      cond do
        abs_val >= 1_000_000_000 -> "#{sign}#{Float.round(abs_val / 1_000_000_000, 1)}B"
        abs_val >= 1_000_000 -> "#{sign}#{Float.round(abs_val / 1_000_000, 1)}M"
        abs_val >= 1_000 -> "#{sign}#{Float.round(abs_val / 1_000, 1)}K"
        is_float(abs_val) -> "#{sign}#{Float.round(abs_val, 1)}"
        true -> "#{sign}#{abs_val}"
      end
    end
  end

  @doc """
  Applies a formatter function to a value. Handles nil gracefully.

  ## Examples

      iex> ChartValueFormatter.format(1234, ChartValueFormatter.currency_formatter())
      "$ 1,234"

      iex> ChartValueFormatter.format(nil, ChartValueFormatter.default_formatter())
      ""
  """
  def format(nil, _formatter), do: ""
  def format(value, nil), do: to_string(value)
  def format(value, formatter) when is_function(formatter, 1), do: formatter.(value)

  @doc """
  Returns a formatter based on a format type atom.

  Supported types: :default, :currency, :percent, :compact
  """
  def for_type(:default), do: default_formatter()
  def for_type(:currency), do: currency_formatter()
  def for_type(:percent), do: percent_formatter()
  def for_type(:compact), do: compact_formatter()
  def for_type(_), do: default_formatter()

  # Private: format number with thousand separators
  defp format_number(value) when is_float(value), do: format_integer(trunc(value))
  defp format_number(value) when is_integer(value), do: format_integer(value)
  defp format_number(value), do: to_string(value)

  defp format_integer(n) when n < 0, do: "-" <> format_integer(-n)

  defp format_integer(n) do
    n
    |> Integer.to_string()
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.chunk_every(3)
    |> Enum.map_join(",", &Enum.join/1)
    |> String.reverse()
  end
end
