defmodule PhiaUi.Components.Data.ChartComposeTest do
  use ExUnit.Case, async: true

  alias PhiaUi.Components.Data.ChartCompose

  @sample_series [
    %{
      name: "Revenue",
      type: :bar,
      data: [
        %{label: "Q1", value: 200},
        %{label: "Q2", value: 280},
        %{label: "Q3", value: 150}
      ]
    },
    %{
      name: "Trend",
      type: :line,
      data: [
        %{label: "Q1", value: 190},
        %{label: "Q2", value: 270},
        %{label: "Q3", value: 140}
      ]
    }
  ]

  describe "new/1" do
    test "creates a new composition context" do
      ctx = ChartCompose.new()

      assert is_map(ctx.viewport)
      assert is_map(ctx.theme)
      assert ctx.coord == nil
      assert ctx.series == []
      assert ctx.features == MapSet.new()
      assert ctx.elements == []
    end

    test "accepts viewport options" do
      ctx = ChartCompose.new(viewport: [vw: 600, vh: 400])
      assert ctx.viewport.vw == 600
      assert ctx.viewport.vh == 400
    end

    test "accepts theme overrides" do
      ctx = ChartCompose.new(theme: %{axis: %{font_size: "14"}})
      assert ctx.theme.axis.font_size == "14"
    end
  end

  describe "with_viewport/2" do
    test "overrides viewport" do
      ctx =
        ChartCompose.new()
        |> ChartCompose.with_viewport(vw: 800, vh: 600)

      assert ctx.viewport.vw == 800
    end
  end

  describe "with_theme/2" do
    test "merges theme overrides" do
      ctx =
        ChartCompose.new()
        |> ChartCompose.with_theme(%{axis: %{font_size: "16"}})

      assert ctx.theme.axis.font_size == "16"
      # Preserved other defaults
      assert ctx.theme.grid.stroke_width == "0.5"
    end
  end

  describe "with_coord/2" do
    test "sets coord to auto" do
      ctx =
        ChartCompose.new()
        |> ChartCompose.with_coord(:auto)

      assert ctx.coord == :auto
    end

    test "accepts explicit coord map" do
      coord = %{type: :cartesian2d, data_to_point: fn _, _ -> {0, 0} end}

      ctx =
        ChartCompose.new()
        |> ChartCompose.with_coord(coord)

      assert ctx.coord.type == :cartesian2d
    end
  end

  describe "with_series/2" do
    test "adds series to context" do
      ctx =
        ChartCompose.new()
        |> ChartCompose.with_series(@sample_series)

      assert length(ctx.series) == 2
    end

    test "appends to existing series" do
      extra = [%{name: "Extra", type: :line, data: [%{label: "Q1", value: 50}]}]

      ctx =
        ChartCompose.new()
        |> ChartCompose.with_series(@sample_series)
        |> ChartCompose.with_series(extra)

      assert length(ctx.series) == 3
    end
  end

  describe "with_feature/2" do
    test "registers feature idempotently" do
      ctx =
        ChartCompose.new()
        |> ChartCompose.with_feature(:grid)
        |> ChartCompose.with_feature(:grid)
        |> ChartCompose.with_feature(:legend)

      assert MapSet.size(ctx.features) == 2
      assert MapSet.member?(ctx.features, :grid)
      assert MapSet.member?(ctx.features, :legend)
    end
  end

  describe "build/1" do
    test "resolves coordinate system from series" do
      ctx =
        ChartCompose.new()
        |> ChartCompose.with_series(@sample_series)
        |> ChartCompose.build()

      assert ctx.coord.type == :cartesian2d
      assert is_list(ctx.categories)
      assert is_list(ctx.y_ticks)
      assert is_tuple(ctx.y_range)
    end

    test "generates visual elements" do
      ctx =
        ChartCompose.new()
        |> ChartCompose.with_series(@sample_series)
        |> ChartCompose.build()

      assert length(ctx.elements) > 0
      types = Enum.map(ctx.elements, & &1.type) |> Enum.uniq()
      assert :bar in types
      assert :line in types
    end

    test "builds legend items" do
      ctx =
        ChartCompose.new()
        |> ChartCompose.with_series(@sample_series)
        |> ChartCompose.build()

      assert length(ctx.legend_items) == 2
      labels = Enum.map(ctx.legend_items, & &1.label)
      assert "Revenue" in labels
      assert "Trend" in labels
    end

    test "builds y_tick_entries" do
      ctx =
        ChartCompose.new()
        |> ChartCompose.with_series(@sample_series)
        |> ChartCompose.build()

      assert is_list(ctx.y_tick_entries)
      assert length(ctx.y_tick_entries) > 0
      assert Map.has_key?(hd(ctx.y_tick_entries), :py)
      assert Map.has_key?(hd(ctx.y_tick_entries), :label)
    end

    test "builds x_label_entries" do
      ctx =
        ChartCompose.new()
        |> ChartCompose.with_series(@sample_series)
        |> ChartCompose.build()

      assert is_list(ctx.x_label_entries)
      labels = Enum.map(ctx.x_label_entries, & &1.label)
      assert "Q1" in labels
      assert "Q2" in labels
    end

    test "handles empty series" do
      ctx =
        ChartCompose.new()
        |> ChartCompose.with_series([])
        |> ChartCompose.build()

      assert ctx.elements == []
      assert ctx.categories == []
    end

    test "pipeline: new -> with_series -> with_feature -> build" do
      ctx =
        ChartCompose.new()
        |> ChartCompose.with_viewport(vw: 500, vh: 350)
        |> ChartCompose.with_theme(%{axis: %{font_size: "12"}})
        |> ChartCompose.with_series(@sample_series)
        |> ChartCompose.with_feature(:grid)
        |> ChartCompose.with_feature(:legend)
        |> ChartCompose.build()

      assert ctx.viewport.vw == 500
      assert ctx.theme.axis.font_size == "12"
      assert length(ctx.elements) > 0
      assert MapSet.member?(ctx.features, :grid)
    end
  end
end
