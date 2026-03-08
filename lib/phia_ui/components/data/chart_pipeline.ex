defmodule PhiaUi.Components.Data.ChartPipeline do
  @moduledoc false
  # Composable data processing pipeline for chart components.
  # Inspired by eCharts Scheduler data processor stages.
  # Provides stats computation, normalization, stacking, decimation, sorting.
  # Not registered in ComponentRegistry — internal only.

  alias PhiaUi.Components.Data.ChartMathHelpers

  @doc """
  Processes a series list through a pipeline of transformation steps.

  ## Steps
  - `:normalize` — ensures all values are floats
  - `:stack` — stacks series (adds `:base` field to each data point)
  - `{:decimate, max_points}` — LTTB downsampling to max_points
  - `{:sort, :asc | :desc}` — sorts each series by value
  - `{:filter, fn}` — filters data points by predicate
  - `{:clamp, {min, max}}` — clamps values to range

  Returns the transformed series list.

  ## Examples

      series = [%{name: "A", data: [%{label: "x", value: 100}]}]
      ChartPipeline.process(series, [:normalize, :stack])
  """
  def process(series, []), do: series

  def process(series, [step | rest]) do
    transformed = apply_step(series, step)
    process(transformed, rest)
  end

  @doc """
  Computes descriptive statistics for a list of numeric values.

  Returns `%{min, max, mean, median, sum, count, std_dev}`.

  ## Examples

      ChartPipeline.stats([10, 20, 30, 40, 50])
      #=> %{min: 10, max: 50, mean: 30.0, median: 30, sum: 150, count: 5, std_dev: ~14.14}
  """
  def stats([]), do: %{min: 0, max: 0, mean: 0.0, median: 0, sum: 0, count: 0, std_dev: 0.0}

  def stats(values) when is_list(values) do
    sorted = Enum.sort(values)
    count = length(sorted)
    sum = Enum.sum(sorted)
    mean = sum / count
    min_val = hd(sorted)
    max_val = List.last(sorted)

    median =
      if rem(count, 2) == 0 do
        mid = div(count, 2)
        (Enum.at(sorted, mid - 1) + Enum.at(sorted, mid)) / 2
      else
        Enum.at(sorted, div(count, 2))
      end

    variance =
      sorted
      |> Enum.map(fn v -> (v - mean) * (v - mean) end)
      |> Enum.sum()
      |> Kernel./(count)

    std_dev = :math.sqrt(variance)

    %{
      min: min_val,
      max: max_val,
      mean: Float.round(mean * 1.0, 4),
      median: median,
      sum: sum,
      count: count,
      std_dev: Float.round(std_dev, 4)
    }
  end

  @doc """
  Computes statistics for each series in a list.

  Returns `[%{name: string, stats: stats_map}]`.

  ## Examples

      series = [%{name: "Revenue", data: [%{label: "Q1", value: 100}, %{label: "Q2", value: 200}]}]
      ChartPipeline.series_stats(series)
      #=> [%{name: "Revenue", stats: %{min: 100, max: 200, mean: 150.0, ...}}]
  """
  def series_stats(series) when is_list(series) do
    Enum.map(series, fn s ->
      values = Enum.map(s.data, & &1.value)
      %{name: s.name, stats: stats(values)}
    end)
  end

  # ---------------------------------------------------------------------------
  # Private — pipeline steps
  # ---------------------------------------------------------------------------

  defp apply_step(series, :normalize) do
    Enum.map(series, fn s ->
      data = Enum.map(s.data, fn d -> %{d | value: d.value * 1.0} end)
      %{s | data: data}
    end)
  end

  defp apply_step(series, :stack) do
    ChartMathHelpers.stack_series(series)
  end

  defp apply_step(series, {:decimate, max_points}) do
    Enum.map(series, fn s ->
      if length(s.data) > max_points do
        indexed = Enum.with_index(s.data)
        points = Enum.map(indexed, fn {d, i} -> %{x: i * 1.0, y: d.value * 1.0} end)
        decimated_points = ChartMathHelpers.decimate_lttb(points, max_points)

        decimated_indices =
          decimated_points
          |> Enum.map(fn %{x: x} -> round(x) end)
          |> MapSet.new()

        data =
          indexed
          |> Enum.filter(fn {_d, i} -> MapSet.member?(decimated_indices, i) end)
          |> Enum.map(fn {d, _i} -> d end)

        %{s | data: data}
      else
        s
      end
    end)
  end

  defp apply_step(series, {:sort, direction}) do
    sorter =
      case direction do
        :asc -> &(&1.value <= &2.value)
        :desc -> &(&1.value >= &2.value)
      end

    Enum.map(series, fn s ->
      %{s | data: Enum.sort(s.data, sorter)}
    end)
  end

  defp apply_step(series, {:filter, func}) when is_function(func, 1) do
    Enum.map(series, fn s ->
      %{s | data: Enum.filter(s.data, func)}
    end)
  end

  defp apply_step(series, {:clamp, {clamp_min, clamp_max}}) do
    Enum.map(series, fn s ->
      data = Enum.map(s.data, fn d ->
        %{d | value: max(clamp_min, min(clamp_max, d.value))}
      end)
      %{s | data: data}
    end)
  end
end
