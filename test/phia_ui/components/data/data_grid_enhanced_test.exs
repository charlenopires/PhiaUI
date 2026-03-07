defmodule PhiaUi.Components.DataGridEnhancedTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.DataGrid

    def render_column_group(assigns) do
      ~H"""
      <table>
        <thead>
          <tr>
            <.data_grid_column_group colspan={2} label="Personal" />
            <.data_grid_column_group colspan={3} label="Work" />
          </tr>
        </thead>
      </table>
      """
    end

    def render_group_head(assigns) do
      ~H"""
      <table>
        <thead>
          <.data_grid_group_head>
            <.data_grid_column_group colspan={3} label="Identity" />
          </.data_grid_group_head>
        </thead>
      </table>
      """
    end

    def render_pinned_row(assigns) do
      ~H"""
      <table>
        <tbody>
          <.data_grid_pinned_row position={:bottom}>
            <td>Total</td>
          </.data_grid_pinned_row>
        </tbody>
      </table>
      """
    end

    def render_detail_row(assigns) do
      ~H"""
      <table>
        <tbody>
          <.data_grid_detail_row colspan={4}>
            <div>Detail panel</div>
          </.data_grid_detail_row>
        </tbody>
      </table>
      """
    end

    def render_group_row(assigns) do
      ~H"""
      <table>
        <tbody>
          <.data_grid_group_row label="Active Users" count={42} expanded={true} value="active" colspan={4} />
        </tbody>
      </table>
      """
    end

    def render_aggregation_row(assigns) do
      ~H"""
      <table>
        <tbody>
          <.data_grid_aggregation_row>
            <td>Total</td>
            <td>100</td>
          </.data_grid_aggregation_row>
        </tbody>
      </table>
      """
    end

    def render_export_button(assigns) do
      ~H"""
      <.data_grid_export_button
        id="export-btn"
        target_id="my-grid"
        filename="report.csv"
        label="Export CSV"
      />
      """
    end

    def render_density_toggle(assigns) do
      ~H"<.data_grid_density_toggle density={:normal} on_change=\"set_density\" />"
    end

    def render_filter_chip(assigns) do
      ~H"<.data_grid_filter_chip label=\"Role: Admin\" value=\"role\" on_remove=\"remove_filter\" />"
    end

    def render_active_filters(assigns) do
      filters = [
        %{label: "Role: Admin", value: "role"},
        %{label: "Status: Active", value: "status"}
      ]
      assigns = assign(assigns, :filters, filters)
      ~H"<.data_grid_active_filters filters={@filters} on_remove=\"remove_filter\" />"
    end

    def render_active_filters_empty(assigns) do
      ~H"<.data_grid_active_filters filters={[]} on_remove=\"remove_filter\" />"
    end
  end

  describe "data_grid_column_group/1" do
    test "renders th with colspan" do
      html = render_component(&H.render_column_group/1, %{})
      assert html =~ ~s(colspan="2")
      assert html =~ ~s(colspan="3")
    end

    test "renders group labels" do
      html = render_component(&H.render_column_group/1, %{})
      assert html =~ "Personal"
      assert html =~ "Work"
    end
  end

  describe "data_grid_group_head/1" do
    test "renders tr wrapper" do
      html = render_component(&H.render_group_head/1, %{})
      assert html =~ "<tr"
    end

    test "renders child column group" do
      html = render_component(&H.render_group_head/1, %{})
      assert html =~ "Identity"
    end
  end

  describe "data_grid_pinned_row/1" do
    test "renders sticky class for bottom" do
      html = render_component(&H.render_pinned_row/1, %{})
      assert html =~ "sticky"
      assert html =~ "bottom-0"
    end

    test "renders content" do
      html = render_component(&H.render_pinned_row/1, %{})
      assert html =~ "Total"
    end
  end

  describe "data_grid_detail_row/1" do
    test "renders tr with full-width td" do
      html = render_component(&H.render_detail_row/1, %{})
      assert html =~ ~s(colspan="4")
      assert html =~ "Detail panel"
    end

    test "has p-0 on td" do
      html = render_component(&H.render_detail_row/1, %{})
      assert html =~ "p-0"
    end
  end

  describe "data_grid_group_row/1" do
    test "renders group label" do
      html = render_component(&H.render_group_row/1, %{})
      assert html =~ "Active Users"
    end

    test "renders count badge" do
      html = render_component(&H.render_group_row/1, %{})
      assert html =~ "42"
    end

    test "has chevron icon" do
      html = render_component(&H.render_group_row/1, %{})
      assert html =~ "chevron-right"
    end

    test "fires on_toggle event" do
      html = render_component(&H.render_group_row/1, %{})
      assert html =~ ~s(phx-value-value="active")
    end
  end

  describe "data_grid_aggregation_row/1" do
    test "has border-t-2 class" do
      html = render_component(&H.render_aggregation_row/1, %{})
      assert html =~ "border-t-2"
    end

    test "has font-medium class" do
      html = render_component(&H.render_aggregation_row/1, %{})
      assert html =~ "font-medium"
    end

    test "renders slot content" do
      html = render_component(&H.render_aggregation_row/1, %{})
      assert html =~ "Total"
      assert html =~ "100"
    end
  end

  describe "data_grid_export_button/1" do
    test "renders with phx-hook" do
      html = render_component(&H.render_export_button/1, %{})
      assert html =~ ~s(phx-hook="PhiaGridExport")
    end

    test "has data-target-id" do
      html = render_component(&H.render_export_button/1, %{})
      assert html =~ ~s(data-target-id="my-grid")
    end

    test "has data-filename" do
      html = render_component(&H.render_export_button/1, %{})
      assert html =~ ~s(data-filename="report.csv")
    end

    test "renders label" do
      html = render_component(&H.render_export_button/1, %{})
      assert html =~ "Export CSV"
    end
  end

  describe "data_grid_density_toggle/1" do
    test "renders three buttons" do
      html = render_component(&H.render_density_toggle/1, %{})
      assert html =~ "Compact"
      assert html =~ "Normal"
      assert html =~ "Comfortable"
    end

    test "marks active density with aria-pressed=true" do
      html = render_component(&H.render_density_toggle/1, %{})
      assert html =~ ~s(aria-pressed="true")
    end

    test "fires on_change event" do
      html = render_component(&H.render_density_toggle/1, %{})
      assert html =~ "set_density"
    end
  end

  describe "data_grid_filter_chip/1" do
    test "renders label" do
      html = render_component(&H.render_filter_chip/1, %{})
      assert html =~ "Role: Admin"
    end

    test "renders remove button" do
      html = render_component(&H.render_filter_chip/1, %{})
      assert html =~ "phx-click"
      assert html =~ ~s(phx-value-key="role")
    end

    test "has rounded-full class" do
      html = render_component(&H.render_filter_chip/1, %{})
      assert html =~ "rounded-full"
    end
  end

  describe "data_grid_active_filters/1" do
    test "renders filter chips" do
      html = render_component(&H.render_active_filters/1, %{})
      assert html =~ "Role: Admin"
      assert html =~ "Status: Active"
    end

    test "renders clear all button" do
      html = render_component(&H.render_active_filters/1, %{})
      assert html =~ "Clear all"
    end

    test "renders nothing when filters empty" do
      html = render_component(&H.render_active_filters_empty/1, %{})
      refute html =~ "Clear all"
      refute html =~ "Role:"
    end
  end
end
