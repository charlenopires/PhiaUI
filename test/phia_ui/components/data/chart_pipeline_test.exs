defmodule PhiaUi.Components.Data.ChartPipelineTest do
  use ExUnit.Case, async: true

  alias PhiaUi.Components.Data.ChartPipeline

  @sample_series [
    %{name: "Revenue", data: [
      %{label: "Q1", value: 100},
      %{label: "Q2", value: 200},
      %{label: "Q3", value: 150},
      %{label: "Q4", value: 300}
    ]},
    %{name: "Cost", data: [
      %{label: "Q1", value: 80},
      %{label: "Q2", value: 120},
      %{label: "Q3", value: 90},
      %{label: "Q4", value: 180}
    ]}
  ]

  describe "process/2" do
    test "empty steps returns series unchanged" do
      assert ChartPipeline.process(@sample_series, []) == @sample_series
    end

    test "normalize converts values to floats" do
      series = [%{name: "S1", data: [%{label: "A", value: 42}]}]
      [result] = ChartPipeline.process(series, [:normalize])
      assert hd(result.data).value == 42.0
      assert is_float(hd(result.data).value)
    end

    test "stack adds base field to data points" do
      result = ChartPipeline.process(@sample_series, [:stack])
      second_series = Enum.at(result, 1)
      first_point = hd(second_series.data)
      assert Map.has_key?(first_point, :base)
      assert first_point.base == 100
    end

    test "sort ascending orders by value" do
      result = ChartPipeline.process(@sample_series, [{:sort, :asc}])
      first_series = hd(result)
      values = Enum.map(first_series.data, & &1.value)
      assert values == Enum.sort(values)
    end

    test "sort descending orders by value" do
      result = ChartPipeline.process(@sample_series, [{:sort, :desc}])
      first_series = hd(result)
      values = Enum.map(first_series.data, & &1.value)
      assert values == Enum.sort(values, :desc)
    end

    test "filter removes data points" do
      result = ChartPipeline.process(@sample_series, [{:filter, fn d -> d.value > 100 end}])
      first_series = hd(result)
      assert length(first_series.data) < 4
      assert Enum.all?(first_series.data, fn d -> d.value > 100 end)
    end

    test "clamp constrains values" do
      result = ChartPipeline.process(@sample_series, [{:clamp, {100, 200}}])
      first_series = hd(result)
      values = Enum.map(first_series.data, & &1.value)
      assert Enum.all?(values, fn v -> v >= 100 and v <= 200 end)
    end

    test "multiple steps compose correctly" do
      result = ChartPipeline.process(@sample_series, [:normalize, {:sort, :asc}])
      first_series = hd(result)
      values = Enum.map(first_series.data, & &1.value)
      assert Enum.all?(values, &is_float/1)
      assert values == Enum.sort(values)
    end

    test "decimate reduces data points" do
      large_series = [%{name: "Big", data: Enum.map(1..100, fn i ->
        %{label: "p#{i}", value: :math.sin(i / 10.0) * 100}
      end)}]

      result = ChartPipeline.process(large_series, [{:decimate, 20}])
      first_series = hd(result)
      assert length(first_series.data) <= 20
    end

    test "decimate preserves series with fewer points than max" do
      result = ChartPipeline.process(@sample_series, [{:decimate, 100}])
      first_series = hd(result)
      assert length(first_series.data) == 4
    end
  end

  describe "stats/1" do
    test "computes basic statistics" do
      result = ChartPipeline.stats([10, 20, 30, 40, 50])

      assert result.min == 10
      assert result.max == 50
      assert_in_delta result.mean, 30.0, 0.01
      assert result.median == 30
      assert result.sum == 150
      assert result.count == 5
      assert_in_delta result.std_dev, 14.1421, 0.01
    end

    test "handles single value" do
      result = ChartPipeline.stats([42])

      assert result.min == 42
      assert result.max == 42
      assert_in_delta result.mean, 42.0, 0.01
      assert result.median == 42
      assert result.sum == 42
      assert result.count == 1
      assert_in_delta result.std_dev, 0.0, 0.01
    end

    test "handles empty list" do
      result = ChartPipeline.stats([])

      assert result.min == 0
      assert result.max == 0
      assert result.mean == 0.0
      assert result.count == 0
    end

    test "even count median is average of middle two" do
      result = ChartPipeline.stats([10, 20, 30, 40])
      assert result.median == 25.0
    end

    test "handles negative values" do
      result = ChartPipeline.stats([-10, -5, 0, 5, 10])

      assert result.min == -10
      assert result.max == 10
      assert_in_delta result.mean, 0.0, 0.01
      assert result.median == 0
    end

    test "handles float values" do
      result = ChartPipeline.stats([1.5, 2.5, 3.5])

      assert_in_delta result.mean, 2.5, 0.01
      assert result.median == 2.5
    end
  end

  describe "series_stats/1" do
    test "computes stats for each series" do
      result = ChartPipeline.series_stats(@sample_series)

      assert length(result) == 2
      assert hd(result).name == "Revenue"
      assert hd(result).stats.min == 100
      assert hd(result).stats.max == 300
    end

    test "handles empty series list" do
      assert ChartPipeline.series_stats([]) == []
    end

    test "handles single-point series" do
      series = [%{name: "S1", data: [%{label: "A", value: 42}]}]
      [result] = ChartPipeline.series_stats(series)

      assert result.name == "S1"
      assert result.stats.min == 42
      assert result.stats.max == 42
      assert result.stats.count == 1
    end
  end
end
