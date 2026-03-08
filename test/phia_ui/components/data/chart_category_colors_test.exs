defmodule PhiaUi.Components.Data.ChartCategoryColorsTest do
  use ExUnit.Case, async: true

  alias PhiaUi.Components.Data.ChartCategoryColors

  describe "build/2" do
    test "maps categories to default palette" do
      result = ChartCategoryColors.build(["Revenue", "Cost"])
      assert map_size(result) == 2
      assert is_binary(result["Revenue"])
      assert is_binary(result["Cost"])
      assert result["Revenue"] != result["Cost"]
    end

    test "returns empty map for empty categories" do
      assert ChartCategoryColors.build([]) == %{}
    end

    test "maps categories to custom palette" do
      result = ChartCategoryColors.build(["A", "B", "C"], ["red", "blue", "green"])
      assert result == %{"A" => "red", "B" => "blue", "C" => "green"}
    end

    test "wraps cyclically when more categories than palette colors" do
      result = ChartCategoryColors.build(["A", "B", "C"], ["red", "blue"])
      assert result["A"] == "red"
      assert result["B"] == "blue"
      assert result["C"] == "red"
    end
  end

  describe "get_color/3" do
    test "returns color for existing category" do
      color_map = %{"Revenue" => "blue"}
      assert ChartCategoryColors.get_color(color_map, "Revenue") == "blue"
    end

    test "returns fallback for missing category" do
      color_map = %{"Revenue" => "blue"}
      result = ChartCategoryColors.get_color(color_map, "Missing")
      assert is_binary(result)
    end

    test "returns custom fallback" do
      color_map = %{}
      assert ChartCategoryColors.get_color(color_map, "X", "gray") == "gray"
    end
  end

  describe "from_series/2" do
    test "builds colors from series list" do
      series = [%{name: "Revenue", data: []}, %{name: "Cost", data: []}]
      result = ChartCategoryColors.from_series(series)
      assert map_size(result) == 2
      assert Map.has_key?(result, "Revenue")
      assert Map.has_key?(result, "Cost")
    end
  end
end
