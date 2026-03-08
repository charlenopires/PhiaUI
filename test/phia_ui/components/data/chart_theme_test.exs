defmodule PhiaUi.Components.Data.ChartThemeTest do
  use ExUnit.Case, async: true

  alias PhiaUi.Components.Data.ChartTheme

  describe "default/0" do
    test "returns a map with all expected top-level keys" do
      theme = ChartTheme.default()
      assert Map.has_key?(theme, :axis)
      assert Map.has_key?(theme, :grid)
      assert Map.has_key?(theme, :legend)
      assert Map.has_key?(theme, :tooltip)
      assert Map.has_key?(theme, :point_label)
    end

    test "axis has expected defaults" do
      assert ChartTheme.default().axis.font_size == "9"
      assert ChartTheme.default().axis.label_class == "fill-muted-foreground"
      assert ChartTheme.default().axis.tick_size == 6
    end

    test "grid has expected defaults" do
      assert ChartTheme.default().grid.stroke_width == "0.5"
      assert ChartTheme.default().grid.stroke_class == "text-border"
      assert ChartTheme.default().grid.dash_array == nil
    end

    test "point_label has expected defaults" do
      assert ChartTheme.default().point_label.font_size == "8"
      assert ChartTheme.default().point_label.offset == 8
    end
  end

  describe "merge/1" do
    test "returns default when passed nil" do
      assert ChartTheme.merge(nil) == ChartTheme.default()
    end

    test "returns default when passed empty map" do
      assert ChartTheme.merge(%{}) == ChartTheme.default()
    end

    test "deep merges axis overrides" do
      theme = ChartTheme.merge(%{axis: %{font_size: "12"}})
      assert theme.axis.font_size == "12"
      # Other axis keys preserved
      assert theme.axis.label_class == "fill-muted-foreground"
      assert theme.axis.tick_size == 6
    end

    test "deep merges grid overrides" do
      theme = ChartTheme.merge(%{grid: %{stroke_width: "1", dash_array: "4 2"}})
      assert theme.grid.stroke_width == "1"
      assert theme.grid.dash_array == "4 2"
      assert theme.grid.stroke_class == "text-border"
    end

    test "preserves unrelated sections when overriding one" do
      theme = ChartTheme.merge(%{legend: %{font_size: "11"}})
      assert theme.axis == ChartTheme.default().axis
      assert theme.grid == ChartTheme.default().grid
      assert theme.tooltip == ChartTheme.default().tooltip
    end

    test "allows overriding multiple sections at once" do
      theme =
        ChartTheme.merge(%{
          axis: %{font_size: "14"},
          grid: %{stroke_class: "text-muted"}
        })

      assert theme.axis.font_size == "14"
      assert theme.grid.stroke_class == "text-muted"
    end

    test "replaces scalar values completely" do
      theme = ChartTheme.merge(%{axis: %{tick_size: 10}})
      assert theme.axis.tick_size == 10
    end
  end

  describe "merge/2 (two-level)" do
    test "merges global then chart overrides" do
      theme = ChartTheme.merge(%{axis: %{font_size: "12"}}, %{grid: %{stroke_width: "1"}})

      assert theme.axis.font_size == "12"
      assert theme.grid.stroke_width == "1"
      # Defaults preserved for other keys
      assert theme.legend.font_size == "9"
    end

    test "chart overrides take precedence over global" do
      theme = ChartTheme.merge(%{axis: %{font_size: "12"}}, %{axis: %{font_size: "14"}})

      assert theme.axis.font_size == "14"
    end
  end

  describe "merge/3 (three-level)" do
    test "merges global -> chart -> series overrides" do
      theme =
        ChartTheme.merge(
          %{axis: %{font_size: "12"}},
          %{grid: %{stroke_width: "1"}},
          %{point_label: %{offset: 12}}
        )

      assert theme.axis.font_size == "12"
      assert theme.grid.stroke_width == "1"
      assert theme.point_label.offset == 12
    end

    test "series overrides take highest precedence" do
      theme =
        ChartTheme.merge(
          %{axis: %{font_size: "12"}},
          %{axis: %{font_size: "14"}},
          %{axis: %{font_size: "16"}}
        )

      assert theme.axis.font_size == "16"
    end
  end

  describe "for_series/3" do
    test "returns base theme when opts is nil" do
      base = ChartTheme.default()
      assert ChartTheme.for_series(base, 0, nil) == base
    end

    test "returns base theme when opts is empty map" do
      base = ChartTheme.default()
      assert ChartTheme.for_series(base, 0, %{}) == base
    end

    test "merges series-specific overrides" do
      base = ChartTheme.default()
      result = ChartTheme.for_series(base, 0, %{point_label: %{font_size: "14"}})

      assert result.point_label.font_size == "14"
      # Other keys preserved
      assert result.axis == base.axis
    end
  end
end
