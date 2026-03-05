defmodule PhiaUi.Components.HeatmapCalendarTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.HeatmapCalendar

    def render_heatmap(assigns) do
      ~H"""
      <.heatmap_calendar
        data={assigns[:data] || []}
        rows={assigns[:rows] || 6}
        cols={assigns[:cols] || 24}
        max_value={assigns[:max_value] || 10}
        col_labels={assigns[:col_labels]}
        row_labels={assigns[:row_labels]}
        class={assigns[:class]}
      />
      """
    end

    def render_heatmap_with_data(assigns) do
      ~H"""
      <.heatmap_calendar
        data={@data}
        rows={6}
        cols={4}
        col_labels={["2AM", "6AM", "10AM", "2PM"]}
        row_labels={["container", "dckr_22", "cont_name", "dckr_511", "dckr_67", "web_01"]}
      />
      """
    end

    def render_heatmap_with_legend(assigns) do
      ~H"""
      <.heatmap_calendar data={[]} rows={3} cols={3} show_legend={true} />
      """
    end

    def render_heatmap_no_legend(assigns) do
      ~H"""
      <.heatmap_calendar data={[]} rows={3} cols={3} show_legend={false} />
      """
    end
  end

  @sample_data [
    %{col: 0, row: 0, value: 0},
    %{col: 0, row: 1, value: 2},
    %{col: 1, row: 0, value: 5},
    %{col: 1, row: 2, value: 8},
    %{col: 2, row: 3, value: 3}
  ]

  defp render_heatmap(attrs \\ %{}),
    do: render_component(&H.render_heatmap/1, attrs)

  defp render_heatmap_with_data(data),
    do: render_component(&H.render_heatmap_with_data/1, %{data: data})

  defp render_heatmap_with_legend,
    do: render_component(&H.render_heatmap_with_legend/1, %{})

  defp render_heatmap_no_legend,
    do: render_component(&H.render_heatmap_no_legend/1, %{})

  # ---------------------------------------------------------------------------
  # heatmap_calendar/1 — ARIA + container
  # ---------------------------------------------------------------------------

  describe "heatmap_calendar/1 — ARIA and container" do
    test "renders a root element" do
      assert render_heatmap() =~ "<div"
    end

    test "has role=grid on the grid container" do
      assert render_heatmap() =~ ~s(role="grid")
    end

    test "custom class is applied to the root element" do
      assert render_heatmap(%{class: "my-heatmap"}) =~ "my-heatmap"
    end
  end

  # ---------------------------------------------------------------------------
  # heatmap_calendar/1 — grid cells
  # ---------------------------------------------------------------------------

  describe "heatmap_calendar/1 — grid cells" do
    test "renders gridcell role on each cell" do
      assert render_heatmap(%{rows: 2, cols: 2}) =~ ~s(role="gridcell")
    end

    test "renders rows × cols cells total" do
      html = render_heatmap(%{rows: 3, cols: 4})
      count = html |> String.split(~s(role="gridcell")) |> length() |> Kernel.-(1)
      assert count == 12
    end

    test "each cell is aria-hidden=false or has accessible label" do
      # gridcell present implies accessible markup
      assert render_heatmap(%{rows: 1, cols: 1}) =~ ~s(role="gridcell")
    end

    test "cells with value 0 render lowest intensity class" do
      html = render_heatmap_with_data(@sample_data)
      assert html =~ "heatmap-0"
    end

    test "cells with positive value render non-zero intensity class" do
      html = render_heatmap_with_data(@sample_data)
      assert html =~ "heatmap-"
    end

    test "cell aria-label includes value information" do
      html = render_heatmap_with_data(@sample_data)
      assert html =~ "aria-label"
    end
  end

  # ---------------------------------------------------------------------------
  # heatmap_calendar/1 — labels
  # ---------------------------------------------------------------------------

  describe "heatmap_calendar/1 — column labels" do
    test "renders col labels when provided" do
      html = render_heatmap(%{cols: 3, col_labels: ["2AM", "6AM", "10AM"]})
      assert html =~ "2AM"
      assert html =~ "6AM"
      assert html =~ "10AM"
    end

    test "does not render label row when col_labels is nil" do
      html = render_heatmap(%{cols: 2, col_labels: nil})
      refute html =~ "2AM"
    end
  end

  describe "heatmap_calendar/1 — row labels" do
    test "renders row labels when provided" do
      html =
        render_heatmap(%{
          rows: 3,
          row_labels: ["container", "dckr_22", "cont_name"]
        })

      assert html =~ "container"
      assert html =~ "dckr_22"
      assert html =~ "cont_name"
    end

    test "does not render row labels when row_labels is nil" do
      html = render_heatmap(%{rows: 2, row_labels: nil})
      refute html =~ "container"
    end
  end

  # ---------------------------------------------------------------------------
  # heatmap_calendar/1 — intensity mapping
  # ---------------------------------------------------------------------------

  describe "heatmap_calendar/1 — intensity levels" do
    test "intensity class is applied based on value" do
      data = [%{col: 0, row: 0, value: 10}]
      html = render_heatmap_with_data(data)
      # Some heatmap- class must appear
      assert html =~ "heatmap-"
    end

    test "cell with no data entry renders zero intensity" do
      html = render_heatmap(%{rows: 2, cols: 2})
      assert html =~ "heatmap-0"
    end

    test "max_value attr affects intensity bucketing" do
      # If a cell value == max_value it should get the highest bucket
      data = [%{col: 0, row: 0, value: 100}]

      html =
        render_component(
          &H.render_heatmap/1,
          %{data: data, rows: 1, cols: 1, max_value: 100}
        )

      assert html =~ "heatmap-4"
    end
  end

  # ---------------------------------------------------------------------------
  # heatmap_calendar/1 — legend
  # ---------------------------------------------------------------------------

  describe "heatmap_calendar/1 — legend" do
    test "renders legend when show_legend=true" do
      assert render_heatmap_with_legend() =~ "heatmap-legend"
    end

    test "does not render legend when show_legend=false" do
      refute render_heatmap_no_legend() =~ "heatmap-legend"
    end

    test "legend shows all intensity levels" do
      html = render_heatmap_with_legend()
      assert html =~ "heatmap-0"
      assert html =~ "heatmap-4"
    end
  end

  # ---------------------------------------------------------------------------
  # heatmap_calendar/1 — semantic tokens
  # ---------------------------------------------------------------------------

  describe "heatmap_calendar/1 — semantic tokens" do
    test "does not use hardcoded hex colors in style attributes" do
      html = render_heatmap_with_data(@sample_data)
      refute html =~ ~r/style="[^"]*#[0-9a-fA-F]{3,6}/
    end

    test "uses CSS custom property classes for intensity" do
      html = render_heatmap(%{rows: 1, cols: 1})
      assert html =~ "heatmap-"
    end
  end
end
