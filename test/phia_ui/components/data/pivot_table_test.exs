defmodule PhiaUi.Components.PivotTableTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  @row_headers [
    %{key: "north", label: "North"},
    %{key: "south", label: "South"}
  ]

  @col_headers [
    %{key: "q1", label: "Q1"},
    %{key: "q2", label: "Q2"}
  ]

  @data %{
    {"north", "q1"} => 100,
    {"north", "q2"} => 200,
    {"south", "q1"} => 150,
    {"south", "q2"} => 50
  }

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.PivotTable

    attr(:row_headers, :list, default: [])
    attr(:col_headers, :list, default: [])
    attr(:data, :any, default: %{})
    attr(:heatmap, :boolean, default: false)
    attr(:format, :atom, default: :default)
    attr(:row_totals, :boolean, default: false)
    attr(:col_totals, :boolean, default: false)

    def render_pivot(assigns) do
      ~H"""
      <.pivot_table
        row_headers={@row_headers}
        col_headers={@col_headers}
        data={@data}
        heatmap={@heatmap}
        format={@format}
        row_totals={@row_totals}
        col_totals={@col_totals}
      />
      """
    end

    attr(:value, :any, default: 42)
    attr(:formatted, :string, default: nil)
    attr(:heatmap_class, :string, default: nil)

    def render_cell(assigns) do
      ~H"""
      <table><tbody><tr>
        <.pivot_cell value={@value} formatted={@formatted} heatmap_class={@heatmap_class} />
      </tr></tbody></table>
      """
    end

    attr(:label, :string, default: "Row Label")

    def render_row_header(assigns) do
      ~H"""
      <table><tbody><tr>
        <.pivot_row_header label={@label} />
      </tr></tbody></table>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # pivot_table/1
  # ---------------------------------------------------------------------------

  describe "pivot_table/1" do
    test "renders table element" do
      html = render_component(&H.render_pivot/1, %{row_headers: @row_headers, col_headers: @col_headers, data: @data})
      assert html =~ "<table"
    end

    test "renders column headers" do
      html = render_component(&H.render_pivot/1, %{row_headers: @row_headers, col_headers: @col_headers, data: @data})
      assert html =~ "Q1"
      assert html =~ "Q2"
    end

    test "renders row headers" do
      html = render_component(&H.render_pivot/1, %{row_headers: @row_headers, col_headers: @col_headers, data: @data})
      assert html =~ "North"
      assert html =~ "South"
    end

    test "renders cell values" do
      html = render_component(&H.render_pivot/1, %{row_headers: @row_headers, col_headers: @col_headers, data: @data})
      assert html =~ "100"
      assert html =~ "200"
      assert html =~ "150"
      assert html =~ "50"
    end

    test "renders row totals when enabled" do
      html = render_component(&H.render_pivot/1, %{
        row_headers: @row_headers,
        col_headers: @col_headers,
        data: @data,
        row_totals: true
      })
      assert html =~ "Total"
      assert html =~ "300"
    end

    test "renders col totals when enabled" do
      html = render_component(&H.render_pivot/1, %{
        row_headers: @row_headers,
        col_headers: @col_headers,
        data: @data,
        col_totals: true
      })
      assert html =~ "Total"
    end

    test "does not render totals by default" do
      html = render_component(&H.render_pivot/1, %{row_headers: @row_headers, col_headers: @col_headers, data: @data})
      # Should not have the totals row — just check no "Total" header
      refute html =~ ">Total<"
    end

    test "heatmap adds background classes" do
      html = render_component(&H.render_pivot/1, %{
        row_headers: @row_headers,
        col_headers: @col_headers,
        data: @data,
        heatmap: true
      })
      assert html =~ "bg-primary/"
    end

    test "format :currency renders dollar sign" do
      html = render_component(&H.render_pivot/1, %{
        row_headers: @row_headers,
        col_headers: @col_headers,
        data: @data,
        format: :currency
      })
      assert html =~ "$"
    end

    test "format :percent renders percent sign" do
      html = render_component(&H.render_pivot/1, %{
        row_headers: @row_headers,
        col_headers: @col_headers,
        data: @data,
        format: :percent
      })
      assert html =~ "%"
    end

    test "accepts function as data source" do
      data_fn = fn _row_key, _col_key -> 42 end

      html = render_component(&H.render_pivot/1, %{
        row_headers: @row_headers,
        col_headers: @col_headers,
        data: data_fn
      })

      assert html =~ "42"
    end

    test "has overflow-auto for horizontal scroll" do
      html = render_component(&H.render_pivot/1, %{row_headers: @row_headers, col_headers: @col_headers, data: @data})
      assert html =~ "overflow-auto"
    end
  end

  # ---------------------------------------------------------------------------
  # pivot_cell/1
  # ---------------------------------------------------------------------------

  describe "pivot_cell/1" do
    test "renders td element" do
      html = render_component(&H.render_cell/1, %{value: 42})
      assert html =~ "<td"
    end

    test "renders value as string" do
      html = render_component(&H.render_cell/1, %{value: 42, formatted: nil})
      assert html =~ "42"
    end

    test "uses formatted string when provided" do
      html = render_component(&H.render_cell/1, %{value: 42, formatted: "$42.00"})
      assert html =~ "$42.00"
    end

    test "applies heatmap class" do
      html = render_component(&H.render_cell/1, %{value: 42, heatmap_class: "bg-primary/40"})
      assert html =~ "bg-primary/40"
    end

    test "has tabular-nums" do
      html = render_component(&H.render_cell/1, %{value: 42})
      assert html =~ "tabular-nums"
    end
  end

  # ---------------------------------------------------------------------------
  # pivot_row_header/1
  # ---------------------------------------------------------------------------

  describe "pivot_row_header/1" do
    test "renders th element" do
      html = render_component(&H.render_row_header/1, %{})
      assert html =~ "<th"
    end

    test "renders label" do
      html = render_component(&H.render_row_header/1, %{label: "North America"})
      assert html =~ "North America"
    end

    test "is sticky" do
      html = render_component(&H.render_row_header/1, %{})
      assert html =~ "sticky"
      assert html =~ "left-0"
    end

    test "has bg-background for sticky covering" do
      html = render_component(&H.render_row_header/1, %{})
      assert html =~ "bg-background"
    end

    test "has scope=row" do
      html = render_component(&H.render_row_header/1, %{})
      assert html =~ ~s(scope="row")
    end

    test "has whitespace-nowrap" do
      html = render_component(&H.render_row_header/1, %{})
      assert html =~ "whitespace-nowrap"
    end
  end
end
