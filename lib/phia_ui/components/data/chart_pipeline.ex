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

  # Gap handling — manages nil/missing values in data series
  defp apply_step(series, {:gap, :skip}) do
    Enum.map(series, fn s ->
      %{s | data: Enum.reject(s.data, fn d -> is_nil(d.value) end)}
    end)
  end

  defp apply_step(series, {:gap, :zero}) do
    Enum.map(series, fn s ->
      data = Enum.map(s.data, fn d ->
        if is_nil(d.value), do: %{d | value: 0}, else: d
      end)
      %{s | data: data}
    end)
  end

  defp apply_step(series, {:gap, :interpolate}) do
    Enum.map(series, fn s ->
      data = interpolate_gaps(s.data)
      %{s | data: data}
    end)
  end

  defp apply_step(series, {:gap, :span}) do
    # Span connects across gaps (just removes nil points like :skip but preserves indices)
    Enum.map(series, fn s ->
      %{s | data: Enum.reject(s.data, fn d -> is_nil(d.value) end)}
    end)
  end

  # Group data by category for side-by-side rendering (e.g., grouped bars)
  defp apply_step(series, {:group, :by_category}) do
    categories =
      series
      |> Enum.flat_map(fn s -> Enum.map(s.data, & &1.label) end)
      |> Enum.uniq()

    Enum.map(series, fn s ->
      existing = Map.new(s.data, fn d -> {d.label, d} end)

      data =
        Enum.map(categories, fn cat ->
          Map.get(existing, cat, %{label: cat, value: 0})
        end)

      %{s | data: data}
    end)
  end

  # Percentage normalization — converts values to percentage of column total
  defp apply_step(series, {:percent, :of_total}) do
    # Build totals per label across all series
    totals =
      series
      |> Enum.flat_map(fn s -> Enum.map(s.data, fn d -> {d.label, abs(d.value)} end) end)
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
      |> Map.new(fn {label, values} -> {label, Enum.sum(values)} end)

    Enum.map(series, fn s ->
      data =
        Enum.map(s.data, fn d ->
          total = Map.get(totals, d.label, 1)
          pct = if total == 0, do: 0.0, else: d.value / total * 100.0
          %{d | value: Float.round(pct, 4)}
        end)

      %{s | data: data}
    end)
  end

  # Running cumulative sum within each series
  defp apply_step(series, {:cumulative, :running_sum}) do
    Enum.map(series, fn s ->
      {data, _acc} =
        Enum.map_reduce(s.data, 0, fn d, acc ->
          new_acc = acc + d.value
          {%{d | value: new_acc}, new_acc}
        end)

      %{s | data: data}
    end)
  end

  # Error bars — attach error_low/error_high to each data point
  defp apply_step(series, {:error_bars, spec}) do
    Enum.map(series, fn s ->
      data = Enum.map(s.data, fn d -> attach_error(d, spec) end)
      %{s | data: data}
    end)
  end

  # ---------------------------------------------------------------------------
  # Private — error bar computation
  # ---------------------------------------------------------------------------

  defp attach_error(point, {:fixed, amount}) do
    Map.merge(point, %{error_low: point.value - amount, error_high: point.value + amount})
  end

  defp attach_error(point, {:percent, pct}) do
    delta = abs(point.value) * pct / 100.0
    Map.merge(point, %{error_low: point.value - delta, error_high: point.value + delta})
  end

  defp attach_error(point, {:stddev, std_dev}) do
    Map.merge(point, %{error_low: point.value - std_dev, error_high: point.value + std_dev})
  end

  defp attach_error(point, {:custom, func}) when is_function(func, 1) do
    {low, high} = func.(point)
    Map.merge(point, %{error_low: low, error_high: high})
  end

  # ---------------------------------------------------------------------------
  # Private — gap interpolation
  # ---------------------------------------------------------------------------

  defp interpolate_gaps([]), do: []

  defp interpolate_gaps(data) do
    indexed = Enum.with_index(data)

    Enum.map(indexed, fn {item, i} ->
      if is_nil(item.value) do
        # Find prev and next non-nil values
        prev = Enum.find(Enum.reverse(Enum.take(data, i)), fn d -> not is_nil(d.value) end)
        next = Enum.find(Enum.drop(data, i + 1), fn d -> not is_nil(d.value) end)

        interpolated =
          cond do
            prev != nil and next != nil -> (prev.value + next.value) / 2.0
            prev != nil -> prev.value
            next != nil -> next.value
            true -> 0
          end

        %{item | value: interpolated}
      else
        item
      end
    end)
  end
end
