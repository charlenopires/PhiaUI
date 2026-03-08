defmodule PhiaUi.Components.Data.ChartCellTest do
  use ExUnit.Case, async: true

  alias PhiaUi.Components.Data.ChartCell

  @sample_elements [
    %{type: :bar, color: "blue", opacity: 1, x: 10},
    %{type: :bar, color: "blue", opacity: 1, x: 30},
    %{type: :bar, color: "blue", opacity: 1, x: 50}
  ]

  describe "apply_cells/2" do
    test "returns elements unchanged when cells is empty" do
      result = ChartCell.apply_cells(@sample_elements, [])
      assert result == @sample_elements
    end

    test "returns elements unchanged when cells is nil" do
      result = ChartCell.apply_cells(@sample_elements, nil)
      assert result == @sample_elements
    end

    test "overrides color per element" do
      cells = [%{color: "red"}, %{}, %{color: "green"}]
      result = ChartCell.apply_cells(@sample_elements, cells)

      assert Enum.at(result, 0).color == "red"
      assert Enum.at(result, 1).color == "blue"
      assert Enum.at(result, 2).color == "green"
    end

    test "overrides opacity per element" do
      cells = [%{opacity: 0.5}, %{opacity: 0.3}, %{}]
      result = ChartCell.apply_cells(@sample_elements, cells)

      assert Enum.at(result, 0).opacity == 0.5
      assert Enum.at(result, 1).opacity == 0.3
      assert Enum.at(result, 2).opacity == 1
    end

    test "overrides class per element" do
      cells = [%{class: "highlight"}, %{}, %{}]
      result = ChartCell.apply_cells(@sample_elements, cells)

      assert Enum.at(result, 0).class == "highlight"
      refute Map.has_key?(Enum.at(result, 1), :class)
    end

    test "handles cells shorter than elements" do
      cells = [%{color: "red"}]
      result = ChartCell.apply_cells(@sample_elements, cells)

      assert Enum.at(result, 0).color == "red"
      assert Enum.at(result, 1).color == "blue"
      assert Enum.at(result, 2).color == "blue"
    end

    test "preserves non-cell keys in elements" do
      cells = [%{color: "red"}]
      result = ChartCell.apply_cells(@sample_elements, cells)

      assert Enum.at(result, 0).x == 10
      assert Enum.at(result, 0).type == :bar
    end
  end

  describe "cells_from/2" do
    test "generates cells from data with 2-arity mapper" do
      data = [%{value: 100}, %{value: 200}, %{value: 300}]

      cells =
        ChartCell.cells_from(data, fn item, _i ->
          if item.value > 150, do: %{color: "red"}, else: %{}
        end)

      assert length(cells) == 3
      assert Enum.at(cells, 0) == %{}
      assert Enum.at(cells, 1) == %{color: "red"}
      assert Enum.at(cells, 2) == %{color: "red"}
    end

    test "generates cells from data with 1-arity mapper" do
      data = [%{value: 50}, %{value: 200}]

      cells = ChartCell.cells_from(data, fn item ->
        %{opacity: if(item.value > 100, do: 1, else: 0.5)}
      end)

      assert length(cells) == 2
      assert Enum.at(cells, 0).opacity == 0.5
      assert Enum.at(cells, 1).opacity == 1
    end
  end
end
