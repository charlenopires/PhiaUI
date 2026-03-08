defmodule PhiaUi.Components.Data.ChartAxisHelpers do
  @moduledoc false
  # Axis tick computation helpers for SVG chart components.
  # Not registered in ComponentRegistry — internal only.

  @doc """
  Computes a list of "nice" axis tick values for the range [min, max].

  - `count` is the approximate desired number of ticks (default 5).
  - Values are rounded to human-readable steps (1, 2, 5, 10, 20, …).
  """
  def nice_ticks(min, max, count \\ 5)

  def nice_ticks(v, v, _count), do: [v]

  def nice_ticks(min, max, count) when count > 0 do
    step = nice_step((max - min) / count)
    t_start = floor_to(min, step)
    t_end = ceil_to(max, step)
    n = round((t_end - t_start) / step)

    Enum.map(0..n, fn i -> Float.round(t_start + i * step, 6) end)
  end

  @doc """
  Formats a numeric tick value for display.

  - Values ≥ 1 000 000 are shown as "1.2M"
  - Values ≥ 1 000 are shown as "1.2K"
  - Floats are rounded to 1 decimal place
  - Integers are shown as-is
  """
  def format_tick(value, opts \\ []) do
    suffix = Keyword.get(opts, :suffix, "")

    cond do
      abs(value) >= 1_000_000 ->
        "#{Float.round(value / 1_000_000, 1)}M#{suffix}"

      abs(value) >= 1_000 ->
        "#{Float.round(value / 1_000, 1)}K#{suffix}"

      is_float(value) && Float.round(value, 1) != trunc(value) * 1.0 ->
        "#{Float.round(value, 1)}#{suffix}"

      true ->
        "#{trunc(value)}#{suffix}"
    end
  end

  @doc """
  Computes logarithmic tick values for a range [min, max].

  Generates ticks at 1, 2, 5 × 10^n intervals (matching Chart.js LogarithmicScale).
  `min` must be > 0. Falls back to `nice_ticks/3` if min <= 0.
  """
  def log_ticks(min, max, count \\ 5)
  def log_ticks(min, _max, _count) when min <= 0, do: nice_ticks(max(min, 0.1), max(min + 1, 1), 5)

  def log_ticks(min, max, _count) when min > 0 and max > min do
    start_exp = Float.floor(:math.log10(min))
    end_exp = Float.ceil(:math.log10(max))

    ticks =
      trunc(start_exp)..trunc(end_exp)
      |> Enum.flat_map(fn exp ->
        base = :math.pow(10, exp)

        [1.0, 2.0, 5.0]
        |> Enum.map(fn mult -> Float.round(mult * base, 10) end)
        |> Enum.filter(fn v -> v >= min and v <= max end)
      end)

    # Ensure boundaries are included
    ticks =
      cond do
        ticks == [] -> [min, max]
        hd(ticks) > min -> [min | ticks]
        true -> ticks
      end

    ticks =
      if List.last(ticks) < max, do: ticks ++ [max], else: ticks

    Enum.uniq(ticks)
  end

  @doc """
  Formats a logarithmic tick value for display.

  Uses scientific notation for very large/small values,
  otherwise delegates to `format_tick/2`.
  """
  def format_log_tick(value, opts \\ []) do
    cond do
      value >= 1_000_000 -> format_tick(value, opts)
      value >= 1 -> format_tick(value, opts)
      value >= 0.01 -> "#{Float.round(value, 2)}"
      true -> "#{:io_lib.format(~c"~.1e", [value])}"
    end
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp nice_step(rough) do
    mag = :math.pow(10, Float.floor(:math.log10(abs(rough) + 1.0e-10)))
    norm = rough / mag

    step =
      cond do
        norm <= 1.5 -> 1.0
        norm <= 3.0 -> 2.0
        norm <= 7.0 -> 5.0
        true -> 10.0
      end

    step * mag
  end

  defp floor_to(value, step), do: Float.floor(value / step) * step
  defp ceil_to(value, step), do: Float.ceil(value / step) * step
end
