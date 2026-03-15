defmodule PhiaUi.Components.Data.AdvancedHelpersTest do
  use ExUnit.Case, async: true

  alias PhiaUi.Components.Data.ChartMathHelpers
  alias PhiaUi.Components.Data.ChartHelpers
  alias PhiaUi.Components.Data.ChartPipeline
  alias PhiaUi.Components.Data.ChartDataValidator

  # ── Quartiles ──────────────────────────────────────────────────────────

  describe "quartiles/1" do
    test "computes quartiles for a simple dataset" do
      result = ChartMathHelpers.quartiles([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
      assert result.median == 5.5
      assert result.q1 > 0
      assert result.q3 > result.q1
      assert result.iqr == result.q3 - result.q1
      assert result.whisker_low <= result.q1
      assert result.whisker_high >= result.q3
    end

    test "returns zeros for empty list" do
      result = ChartMathHelpers.quartiles([])
      assert result.median == 0
      assert result.q1 == 0
      assert result.outliers == []
    end

    test "detects outliers" do
      result = ChartMathHelpers.quartiles([1, 2, 3, 4, 5, 6, 7, 8, 9, 100])
      assert 100 in result.outliers
    end

    test "handles single value" do
      result = ChartMathHelpers.quartiles([42])
      assert result.median == 42
    end

    test "handles two values" do
      result = ChartMathHelpers.quartiles([10, 20])
      assert result.median == 15.0
    end
  end

  # ── Kernel Density ─────────────────────────────────────────────────────

  describe "kernel_density/3" do
    test "returns density estimates" do
      kde = ChartMathHelpers.kernel_density([1, 2, 3, 4, 5], 20)
      assert length(kde) == 20
      assert Enum.all?(kde, fn %{x: _, y: y} -> y >= 0 end)
    end

    test "returns empty for empty input" do
      assert ChartMathHelpers.kernel_density([]) == []
    end

    test "peak is near the data center" do
      kde = ChartMathHelpers.kernel_density([5, 5, 5, 5, 5], 50)
      peak = Enum.max_by(kde, & &1.y)
      assert abs(peak.x - 5) < 2
    end

    test "all y values sum to positive" do
      kde = ChartMathHelpers.kernel_density([10, 20, 30], 30)
      total = Enum.reduce(kde, 0, fn %{y: y}, acc -> acc + y end)
      assert total > 0
    end
  end

  # ── Sunburst Arcs ──────────────────────────────────────────────────────

  describe "sunburst_arcs/2" do
    test "allocates arcs for flat data" do
      data = [%{label: "A", value: 50, children: []}, %{label: "B", value: 50, children: []}]
      arcs = ChartMathHelpers.sunburst_arcs(data)
      assert length(arcs) == 2
      assert Enum.all?(arcs, fn a -> a.depth == 0 end)
    end

    test "allocates arcs for nested data" do
      data = [%{label: "Root", value: 100, children: [
        %{label: "Child", value: 60, children: []},
        %{label: "Child2", value: 40, children: []}
      ]}]
      arcs = ChartMathHelpers.sunburst_arcs(data)
      assert length(arcs) == 3
      depths = Enum.map(arcs, & &1.depth) |> Enum.uniq() |> Enum.sort()
      assert depths == [0, 1]
    end

    test "returns empty for empty input" do
      assert ChartMathHelpers.sunburst_arcs([]) == []
    end

    test "arc angles span full circle for single root" do
      data = [%{label: "All", value: 100, children: []}]
      [arc] = ChartMathHelpers.sunburst_arcs(data)
      span = arc.end_angle - arc.start_angle
      assert_in_delta span, 2 * :math.pi(), 0.01
    end
  end

  # ── Sankey Layout ──────────────────────────────────────────────────────

  describe "sankey_layout/3" do
    test "positions nodes and creates link paths" do
      graph = %{
        nodes: [%{id: "a", label: "A"}, %{id: "b", label: "B"}],
        links: [%{source: "a", target: "b", value: 100}]
      }
      result = ChartMathHelpers.sankey_layout(graph, 400, 200)
      assert length(result.nodes) == 2
      assert length(result.links) == 1
      assert hd(result.links).path =~ "M"
    end

    test "nodes have x, y, width, height" do
      graph = %{
        nodes: [%{id: "x", label: "X"}, %{id: "y", label: "Y"}],
        links: [%{source: "x", target: "y", value: 50}]
      }
      result = ChartMathHelpers.sankey_layout(graph, 300, 150)
      Enum.each(result.nodes, fn node ->
        assert Map.has_key?(node, :x)
        assert Map.has_key?(node, :y)
        assert Map.has_key?(node, :width)
        assert Map.has_key?(node, :height)
      end)
    end

    test "handles multiple columns" do
      graph = %{
        nodes: [%{id: "a", label: "A"}, %{id: "b", label: "B"}, %{id: "c", label: "C"}],
        links: [%{source: "a", target: "b", value: 40}, %{source: "b", target: "c", value: 40}]
      }
      result = ChartMathHelpers.sankey_layout(graph, 500, 200)
      assert length(result.nodes) == 3
      xs = Enum.map(result.nodes, & &1.x) |> Enum.uniq()
      assert length(xs) == 3
    end
  end

  # ── Pack Circles ───────────────────────────────────────────────────────

  describe "pack_circles/2" do
    test "packs circles within bounding radius" do
      data = [%{label: "A", value: 50}, %{label: "B", value: 30}, %{label: "C", value: 20}]
      result = ChartMathHelpers.pack_circles(data, 100)
      assert length(result) == 3
      assert Enum.all?(result, fn c -> Map.has_key?(c, :cx) and Map.has_key?(c, :cy) end)
    end

    test "all circles have positive radius" do
      data = [%{label: "X", value: 100}, %{label: "Y", value: 50}]
      result = ChartMathHelpers.pack_circles(data, 150)
      assert Enum.all?(result, fn c -> c.r > 0 end)
    end

    test "preserves labels" do
      data = [%{label: "Alpha", value: 80}]
      [circle] = ChartMathHelpers.pack_circles(data, 100)
      assert circle.label == "Alpha"
    end
  end

  # ── Chord Layout ───────────────────────────────────────────────────────

  describe "chord_layout/2" do
    test "creates arcs and ribbons" do
      matrix = [[0, 10], [10, 0]]
      labels = ["A", "B"]
      result = ChartMathHelpers.chord_layout(matrix, labels)
      assert length(result.arcs) == 2
      assert length(result.ribbons) >= 1
    end

    test "arcs have start and end angles" do
      matrix = [[0, 5, 10], [5, 0, 8], [10, 8, 0]]
      labels = ["X", "Y", "Z"]
      result = ChartMathHelpers.chord_layout(matrix, labels)
      Enum.each(result.arcs, fn arc ->
        assert Map.has_key?(arc, :start_angle)
        assert Map.has_key?(arc, :end_angle)
        assert arc.end_angle > arc.start_angle
      end)
    end

    test "ribbons have source and target" do
      matrix = [[0, 10], [10, 0]]
      labels = ["A", "B"]
      result = ChartMathHelpers.chord_layout(matrix, labels)
      Enum.each(result.ribbons, fn ribbon ->
        assert Map.has_key?(ribbon, :source)
        assert Map.has_key?(ribbon, :target)
      end)
    end
  end

  # ── Wiggle Baseline ────────────────────────────────────────────────────

  describe "wiggle_baseline/1" do
    test "returns baseline offsets" do
      series = [
        %{name: "A", data: [%{label: "x", value: 10}, %{label: "y", value: 20}]},
        %{name: "B", data: [%{label: "x", value: 15}, %{label: "y", value: 25}]}
      ]
      result = ChartMathHelpers.wiggle_baseline(series)
      assert length(result) == 2
      assert Enum.all?(result, &is_number/1)
    end

    test "returns empty for empty series" do
      assert ChartMathHelpers.wiggle_baseline([]) == []
    end

    test "single series baseline is centered" do
      series = [%{name: "Solo", data: [%{label: "x", value: 10}]}]
      [offset] = ChartMathHelpers.wiggle_baseline(series)
      assert is_number(offset)
    end
  end

  # ── Word Cloud Layout ──────────────────────────────────────────────────

  describe "word_cloud_layout/2" do
    test "lays out words with positions and sizes" do
      words = [%{text: "Hello", value: 100}, %{text: "World", value: 50}]
      result = ChartMathHelpers.word_cloud_layout(words, %{width: 400, height: 300})
      assert length(result) == 2
      assert Enum.all?(result, fn w -> Map.has_key?(w, :x) and Map.has_key?(w, :font_size) end)
    end

    test "larger values get larger font sizes" do
      words = [%{text: "Big", value: 100}, %{text: "Small", value: 10}]
      result = ChartMathHelpers.word_cloud_layout(words, %{width: 400, height: 300})
      big = Enum.find(result, &(&1.text == "Big"))
      small = Enum.find(result, &(&1.text == "Small"))
      assert big.font_size > small.font_size
    end

    test "preserves text content" do
      words = [%{text: "Elixir", value: 50}]
      [word] = ChartMathHelpers.word_cloud_layout(words, %{width: 200, height: 200})
      assert word.text == "Elixir"
    end
  end

  # ── Easing Functions ───────────────────────────────────────────────────

  describe "easing functions" do
    test "ease_in_quad returns 0 at 0 and 1 at 1" do
      assert ChartMathHelpers.ease_in_quad(0.0) == 0.0
      assert ChartMathHelpers.ease_in_quad(1.0) == 1.0
    end

    test "ease_out_quad returns 0 at 0 and 1 at 1" do
      assert ChartMathHelpers.ease_out_quad(0.0) == 0.0
      assert ChartMathHelpers.ease_out_quad(1.0) == 1.0
    end

    test "ease_in_out_quad returns 0 at 0 and 1 at 1" do
      assert ChartMathHelpers.ease_in_out_quad(0.0) == 0.0
      assert ChartMathHelpers.ease_in_out_quad(1.0) == 1.0
    end

    test "ease_in_cubic returns 0 at 0 and 1 at 1" do
      assert ChartMathHelpers.ease_in_cubic(0.0) == 0.0
      assert ChartMathHelpers.ease_in_cubic(1.0) == 1.0
    end

    test "ease_in_quart returns 0 at 0 and 1 at 1" do
      assert ChartMathHelpers.ease_in_quart(0.0) == 0.0
      assert ChartMathHelpers.ease_in_quart(1.0) == 1.0
    end

    test "ease_out_quart returns 0 at 0 and 1 at 1" do
      assert_in_delta ChartMathHelpers.ease_out_quart(0.0), 0.0, 0.001
      assert_in_delta ChartMathHelpers.ease_out_quart(1.0), 1.0, 0.001
    end

    test "ease_in_out_quart returns 0 at 0 and 1 at 1" do
      assert_in_delta ChartMathHelpers.ease_in_out_quart(0.0), 0.0, 0.001
      assert_in_delta ChartMathHelpers.ease_in_out_quart(1.0), 1.0, 0.001
    end

    test "ease_in_sine returns 0 at 0 and 1 at 1" do
      assert_in_delta ChartMathHelpers.ease_in_sine(0.0), 0.0, 0.001
      assert_in_delta ChartMathHelpers.ease_in_sine(1.0), 1.0, 0.001
    end

    test "ease_out_sine returns 0 at 0 and 1 at 1" do
      assert_in_delta ChartMathHelpers.ease_out_sine(0.0), 0.0, 0.001
      assert_in_delta ChartMathHelpers.ease_out_sine(1.0), 1.0, 0.001
    end

    test "ease_in_out_sine returns 0 at 0 and 1 at 1" do
      assert_in_delta ChartMathHelpers.ease_in_out_sine(0.0), 0.0, 0.001
      assert_in_delta ChartMathHelpers.ease_in_out_sine(1.0), 1.0, 0.001
    end

    test "ease_in_expo returns 0 at 0 and approaches 1 at 1" do
      assert ChartMathHelpers.ease_in_expo(0.0) == 0.0
      assert_in_delta ChartMathHelpers.ease_in_expo(1.0), 1.0, 0.01
    end

    test "ease_in_expo starts slow" do
      assert ChartMathHelpers.ease_in_expo(0.1) < 0.05
    end

    test "ease_out_expo returns 1 at 1" do
      assert ChartMathHelpers.ease_out_expo(1.0) == 1.0
    end

    test "ease_in_out_expo returns 0 at 0 and 1 at 1" do
      assert ChartMathHelpers.ease_in_out_expo(0.0) == 0.0
      assert ChartMathHelpers.ease_in_out_expo(1.0) == 1.0
    end

    test "ease_in_circ returns 0 at 0 and 1 at 1" do
      assert_in_delta ChartMathHelpers.ease_in_circ(0.0), 0.0, 0.001
      assert_in_delta ChartMathHelpers.ease_in_circ(1.0), 1.0, 0.001
    end

    test "ease_out_circ returns 0 at 0 and 1 at 1" do
      assert_in_delta ChartMathHelpers.ease_out_circ(0.0), 0.0, 0.001
      assert_in_delta ChartMathHelpers.ease_out_circ(1.0), 1.0, 0.001
    end

    test "ease_in_out_circ returns 0 at 0 and 1 at 1" do
      assert_in_delta ChartMathHelpers.ease_in_out_circ(0.0), 0.0, 0.001
      assert_in_delta ChartMathHelpers.ease_in_out_circ(1.0), 1.0, 0.001
    end

    test "ease_in_back overshoots below 0 mid-range" do
      val = ChartMathHelpers.ease_in_back(0.2)
      assert val < 0
    end

    test "ease_out_back overshoots above 1 mid-range" do
      val = ChartMathHelpers.ease_out_back(0.8)
      assert val > 1
    end

    test "ease_in_out_back is symmetric around 0.5" do
      a = ChartMathHelpers.ease_in_out_back(0.25)
      b = ChartMathHelpers.ease_in_out_back(0.75)
      assert_in_delta(a + b, 1.0, 0.1)
    end

    test "ease_out_bounce returns 0 at 0 and 1 at 1" do
      assert_in_delta ChartMathHelpers.ease_out_bounce(0.0), 0.0, 0.001
      assert_in_delta ChartMathHelpers.ease_out_bounce(1.0), 1.0, 0.001
    end

    test "ease_in_bounce returns 0 at 0 and 1 at 1" do
      assert_in_delta ChartMathHelpers.ease_in_bounce(0.0), 0.0, 0.001
      assert_in_delta ChartMathHelpers.ease_in_bounce(1.0), 1.0, 0.001
    end

    test "ease_in_out_bounce returns 0 at 0 and 1 at 1" do
      assert_in_delta ChartMathHelpers.ease_in_out_bounce(0.0), 0.0, 0.001
      assert_in_delta ChartMathHelpers.ease_in_out_bounce(1.0), 1.0, 0.001
    end

    test "all easing functions return values between -0.2 and 1.2 at midpoint" do
      fns = [
        &ChartMathHelpers.ease_in_quad/1,
        &ChartMathHelpers.ease_out_quad/1,
        &ChartMathHelpers.ease_in_out_quad/1,
        &ChartMathHelpers.ease_in_cubic/1,
        &ChartMathHelpers.ease_out_cubic/1,
        &ChartMathHelpers.ease_in_out_cubic/1,
        &ChartMathHelpers.ease_in_sine/1,
        &ChartMathHelpers.ease_out_sine/1,
        &ChartMathHelpers.ease_in_out_sine/1
      ]

      Enum.each(fns, fn f ->
        val = f.(0.5)
        assert val >= -0.2 and val <= 1.2, "easing at 0.5 = #{val}"
      end)
    end
  end

  # ── Gap Handling Pipeline ──────────────────────────────────────────────

  describe "gap handling" do
    test "skip removes nil values" do
      series = [%{name: "A", data: [%{label: "x", value: 10}, %{label: "y", value: nil}, %{label: "z", value: 30}]}]
      result = ChartPipeline.process(series, [{:gap, :skip}])
      data = hd(result).data
      assert length(data) == 2
    end

    test "zero replaces nil with 0" do
      series = [%{name: "A", data: [%{label: "x", value: 10}, %{label: "y", value: nil}]}]
      result = ChartPipeline.process(series, [{:gap, :zero}])
      data = hd(result).data
      assert Enum.at(data, 1).value == 0
    end

    test "interpolate fills nil with average of neighbors" do
      series = [%{name: "A", data: [%{label: "x", value: 10}, %{label: "y", value: nil}, %{label: "z", value: 30}]}]
      result = ChartPipeline.process(series, [{:gap, :interpolate}])
      data = hd(result).data
      assert Enum.at(data, 1).value == 20.0
    end

    test "skip preserves non-nil values unchanged" do
      series = [%{name: "A", data: [%{label: "x", value: 10}, %{label: "z", value: 30}]}]
      result = ChartPipeline.process(series, [{:gap, :skip}])
      data = hd(result).data
      assert length(data) == 2
      assert hd(data).value == 10
    end

    test "span removes nils like skip" do
      series = [%{name: "A", data: [%{label: "x", value: 10}, %{label: "y", value: nil}, %{label: "z", value: 30}]}]
      result = ChartPipeline.process(series, [{:gap, :span}])
      data = hd(result).data
      assert length(data) == 2
    end
  end

  # ── Color Palettes ─────────────────────────────────────────────────────

  describe "color palettes" do
    test "categorical_10 returns 10 colors" do
      assert length(ChartHelpers.categorical_10()) == 10
    end

    test "categorical_10 colors are OKLCH strings" do
      Enum.each(ChartHelpers.categorical_10(), fn color ->
        assert color =~ "oklch("
      end)
    end

    test "sequential returns n colors" do
      colors = ChartHelpers.sequential(240, 5)
      assert length(colors) == 5
      assert Enum.all?(colors, &String.starts_with?(&1, "oklch("))
    end

    test "sequential returns 1 color for n=1" do
      colors = ChartHelpers.sequential(180, 1)
      assert length(colors) == 1
    end

    test "diverging returns n colors with neutral midpoint" do
      colors = ChartHelpers.diverging(0, 240, 5)
      assert length(colors) == 5
    end

    test "diverging returns odd number of colors" do
      colors = ChartHelpers.diverging(30, 270, 7)
      assert length(colors) == 7
    end
  end

  # ── Pareto Cumulative ──────────────────────────────────────────────────

  describe "pareto_cumulative/1" do
    test "sorts descending and computes cumulative percentages" do
      data = [%{label: "A", value: 10}, %{label: "B", value: 30}, %{label: "C", value: 20}]
      {sorted, pcts} = ChartHelpers.pareto_cumulative(data)
      assert hd(sorted).value == 30
      assert_in_delta List.last(pcts), 100.0, 0.01
    end

    test "single item is 100 percent" do
      data = [%{label: "Only", value: 50}]
      {sorted, pcts} = ChartHelpers.pareto_cumulative(data)
      assert length(sorted) == 1
      assert hd(pcts) == 100.0
    end

    test "cumulative percentages are ascending" do
      data = [%{label: "A", value: 40}, %{label: "B", value: 30}, %{label: "C", value: 20}, %{label: "D", value: 10}]
      {_sorted, pcts} = ChartHelpers.pareto_cumulative(data)
      assert pcts == Enum.sort(pcts)
    end
  end

  # ── Data Validator ─────────────────────────────────────────────────────

  describe "validate_series!/1" do
    test "passes for valid data" do
      assert ChartDataValidator.validate_series!([%{label: "A", value: 10}]) == :ok
    end

    test "passes for empty list" do
      assert ChartDataValidator.validate_series!([]) == :ok
    end

    test "raises for missing label key" do
      assert_raise ArgumentError, fn ->
        ChartDataValidator.validate_series!([%{value: 10}])
      end
    end

    test "raises for missing value key" do
      assert_raise ArgumentError, fn ->
        ChartDataValidator.validate_series!([%{label: "A"}])
      end
    end

    test "raises for non-list input" do
      assert_raise ArgumentError, fn ->
        ChartDataValidator.validate_series!("not a list")
      end
    end
  end

  describe "validate_ohlc!/1" do
    test "passes for valid OHLC data" do
      assert ChartDataValidator.validate_ohlc!([%{label: "Mon", open: 10, high: 20, low: 5, close: 15}]) == :ok
    end

    test "passes for empty list" do
      assert ChartDataValidator.validate_ohlc!([]) == :ok
    end

    test "raises for missing required OHLC keys" do
      assert_raise ArgumentError, fn ->
        ChartDataValidator.validate_ohlc!([%{label: "Mon", open: 10}])
      end
    end

    test "raises when high < low" do
      assert_raise ArgumentError, fn ->
        ChartDataValidator.validate_ohlc!([%{label: "Mon", open: 10, high: 5, low: 20, close: 15}])
      end
    end

    test "raises for non-list input" do
      assert_raise ArgumentError, fn ->
        ChartDataValidator.validate_ohlc!(%{label: "Mon", open: 10, high: 20, low: 5, close: 15})
      end
    end
  end

  describe "validate_hierarchical!/1" do
    test "passes for valid hierarchical data" do
      assert ChartDataValidator.validate_hierarchical!([%{label: "A", value: 10, children: []}]) == :ok
    end

    test "passes for nested children" do
      data = [%{label: "Root", value: 100, children: [
        %{label: "Child", value: 50, children: []}
      ]}]
      assert ChartDataValidator.validate_hierarchical!(data) == :ok
    end

    test "passes for empty list" do
      assert ChartDataValidator.validate_hierarchical!([]) == :ok
    end

    test "raises for missing label" do
      assert_raise ArgumentError, fn ->
        ChartDataValidator.validate_hierarchical!([%{value: 10}])
      end
    end

    test "raises for node without value or children" do
      assert_raise ArgumentError, fn ->
        ChartDataValidator.validate_hierarchical!([%{label: "A"}])
      end
    end

    test "raises for non-list input" do
      assert_raise ArgumentError, fn ->
        ChartDataValidator.validate_hierarchical!("not a list")
      end
    end
  end

  describe "validate_flow!/1" do
    test "passes for valid flow data" do
      data = %{nodes: [%{id: "a", label: "A"}], links: []}
      assert ChartDataValidator.validate_flow!(data) == :ok
    end

    test "passes for flow data with valid links" do
      data = %{
        nodes: [%{id: "a", label: "A"}, %{id: "b", label: "B"}],
        links: [%{source: "a", target: "b", value: 10}]
      }
      assert ChartDataValidator.validate_flow!(data) == :ok
    end

    test "raises for missing nodes key" do
      assert_raise ArgumentError, fn ->
        ChartDataValidator.validate_flow!(%{links: []})
      end
    end

    test "raises for missing links key" do
      assert_raise ArgumentError, fn ->
        ChartDataValidator.validate_flow!(%{nodes: []})
      end
    end

    test "raises for invalid node shape" do
      assert_raise ArgumentError, fn ->
        ChartDataValidator.validate_flow!(%{nodes: [%{name: "A"}], links: []})
      end
    end

    test "raises for invalid link source" do
      assert_raise ArgumentError, fn ->
        ChartDataValidator.validate_flow!(%{
          nodes: [%{id: "a", label: "A"}],
          links: [%{source: "b", target: "a", value: 10}]
        })
      end
    end

    test "raises for invalid link target" do
      assert_raise ArgumentError, fn ->
        ChartDataValidator.validate_flow!(%{
          nodes: [%{id: "a", label: "A"}, %{id: "b", label: "B"}],
          links: [%{source: "a", target: "c", value: 10}]
        })
      end
    end

    test "raises for non-map input" do
      assert_raise ArgumentError, fn ->
        ChartDataValidator.validate_flow!("not a map")
      end
    end
  end
end
