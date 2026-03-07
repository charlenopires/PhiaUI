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
