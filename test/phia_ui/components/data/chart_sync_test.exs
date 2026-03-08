defmodule PhiaUi.Components.Data.ChartSyncTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  alias PhiaUi.Components.Data.ChartSync

  describe "chart_sync/1" do
    test "renders a div wrapper with hook" do
      html =
        render_component(&ChartSync.chart_sync/1, %{
          id: "sync-1",
          sync_id: "group-a",
          sync_mode: :crosshair,
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "child content" end}]
        })

      assert html =~ ~s[id="sync-1"]
      assert html =~ ~s[phx-hook="PhiaChartSync"]
      assert html =~ ~s[data-sync-id="group-a"]
      assert html =~ ~s[data-sync-mode="crosshair"]
    end

    test "renders with brush sync mode" do
      html =
        render_component(&ChartSync.chart_sync/1, %{
          id: "sync-2",
          sync_id: "group-b",
          sync_mode: :brush,
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "content" end}]
        })

      assert html =~ ~s[data-sync-mode="brush"]
    end

    test "renders with both sync mode" do
      html =
        render_component(&ChartSync.chart_sync/1, %{
          id: "sync-3",
          sync_id: "group-c",
          sync_mode: :both,
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "content" end}]
        })

      assert html =~ ~s[data-sync-mode="both"]
    end

    test "applies custom class" do
      html =
        render_component(&ChartSync.chart_sync/1, %{
          id: "sync-4",
          sync_id: "group-d",
          sync_mode: :crosshair,
          class: "my-custom-class",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "content" end}]
        })

      assert html =~ "my-custom-class"
    end
  end
end
