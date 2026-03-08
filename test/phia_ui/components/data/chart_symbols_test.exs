defmodule PhiaUi.Components.Data.ChartSymbolsTest do
  use ExUnit.Case, async: true

  alias PhiaUi.Components.Data.ChartSymbols

  describe "types/0" do
    test "returns 7 symbol types" do
      types = ChartSymbols.types()
      assert length(types) == 7
      assert :circle in types
      assert :cross in types
      assert :diamond in types
      assert :square in types
      assert :star in types
      assert :triangle in types
      assert :wye in types
    end
  end

  describe "supported?/1" do
    test "returns true for all supported types" do
      for type <- ChartSymbols.types() do
        assert ChartSymbols.supported?(type), "Expected #{type} to be supported"
      end
    end

    test "returns false for unsupported types" do
      refute ChartSymbols.supported?(:hexagon)
      refute ChartSymbols.supported?(:pentagon)
      refute ChartSymbols.supported?(:arrow)
    end
  end

  describe "path/2" do
    test "circle produces valid SVG path" do
      path = ChartSymbols.path(:circle, 5)
      assert is_binary(path)
      assert path =~ "M"
      assert path =~ "A"
      assert path =~ "Z"
    end

    test "cross produces valid SVG path" do
      path = ChartSymbols.path(:cross, 5)
      assert is_binary(path)
      assert path =~ "M"
      assert path =~ "Z"
    end

    test "diamond produces valid SVG path" do
      path = ChartSymbols.path(:diamond, 5)
      assert is_binary(path)
      assert path =~ "M"
      assert path =~ "L"
      assert path =~ "Z"
    end

    test "square produces valid SVG path" do
      path = ChartSymbols.path(:square, 5)
      assert is_binary(path)
      assert path =~ "M"
      assert path =~ "L"
      assert path =~ "Z"
    end

    test "star produces valid SVG path with 10 vertices" do
      path = ChartSymbols.path(:star, 5)
      assert is_binary(path)
      assert path =~ "M"
      assert path =~ "Z"
      # Star has 10 points (5 outer + 5 inner), so 9 L commands + M
      l_count = path |> String.split("L") |> length()
      assert l_count >= 10
    end

    test "triangle produces valid SVG path" do
      path = ChartSymbols.path(:triangle, 5)
      assert is_binary(path)
      assert path =~ "M"
      assert path =~ "L"
      assert path =~ "Z"
    end

    test "wye produces valid SVG path" do
      path = ChartSymbols.path(:wye, 5)
      assert is_binary(path)
      assert path =~ "M"
      assert path =~ "L"
      assert path =~ "Z"
    end

    test "all shapes start with M and end with Z" do
      for type <- ChartSymbols.types() do
        path = ChartSymbols.path(type, 5)
        assert String.starts_with?(path, "M"), "#{type} path should start with M"
        assert String.ends_with?(path, "Z"), "#{type} path should end with Z"
      end
    end

    test "size affects path coordinates" do
      small = ChartSymbols.path(:square, 3)
      large = ChartSymbols.path(:square, 10)
      # Larger size should produce larger coordinate values
      refute small == large
    end
  end
end
