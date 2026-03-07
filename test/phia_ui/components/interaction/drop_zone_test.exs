defmodule PhiaUi.Components.DropZoneTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.DropZone

    def render_zone(assigns) do
      ~H"""
      <.drop_zone
        id={assigns[:id] || "zone-1"}
        state={assigns[:state] || "idle"}
        label={assigns[:label] || "Drop files here"}
        on_drop={assigns[:on_drop] || "zone_drop"}
        class={assigns[:class]}
      />
      """
    end

    def render_zone_with_icon(assigns) do
      ~H"""
      <.drop_zone id="zone-icon" state="idle" label="Drop here">
        <:icon>
          <span class="custom-icon" />
        </:icon>
      </.drop_zone>
      """
    end

    def render_transfer(assigns) do
      ~H"""
      <.drag_transfer_list
        id={assigns[:id] || "transfer-1"}
        source_label={assigns[:source_label] || "Available"}
        target_label={assigns[:target_label] || "Selected"}
        source_items={assigns[:source_items] || [%{id: "a", label: "Item A"}, %{id: "b", label: "Item B"}]}
        target_items={assigns[:target_items] || [%{id: "c", label: "Item C"}]}
        on_transfer={assigns[:on_transfer] || "items_transferred"}
        class={assigns[:class]}
      />
      """
    end
  end

  defp render_zone(attrs \\ %{}), do: render_component(&H.render_zone/1, attrs)
  defp render_zone_with_icon, do: render_component(&H.render_zone_with_icon/1, %{})
  defp render_transfer(attrs \\ %{}), do: render_component(&H.render_transfer/1, attrs)

  # ---------------------------------------------------------------------------
  # drop_zone/1
  # ---------------------------------------------------------------------------

  describe "drop_zone/1" do
    test "renders a div element" do
      assert render_zone() =~ "<div"
    end

    test "has phx-hook=PhiaDropZone" do
      assert render_zone() =~ ~s(phx-hook="PhiaDropZone")
    end

    test "has role=region" do
      assert render_zone() =~ ~s(role="region")
    end

    test "has aria-label from label attr" do
      assert render_zone(%{label: "Drop PDFs here"}) =~ ~s(aria-label="Drop PDFs here")
    end

    test "forwards id attribute" do
      assert render_zone(%{id: "my-zone"}) =~ ~s(id="my-zone")
    end

    test "has data-state attribute" do
      assert render_zone(%{state: "hover"}) =~ ~s(data-state="hover")
    end

    test "has data-on-drop attribute" do
      assert render_zone(%{on_drop: "file_dropped"}) =~ ~s(data-on-drop="file_dropped")
    end

    test "idle state uses muted styles" do
      html = render_zone(%{state: "idle"})
      assert html =~ "border-border"
      assert html =~ "bg-muted"
    end

    test "hover state uses primary styles" do
      html = render_zone(%{state: "hover"})
      assert html =~ "border-primary"
    end

    test "error state uses destructive styles" do
      html = render_zone(%{state: "error"})
      assert html =~ "destructive"
    end

    test "active state uses animation" do
      html = render_zone(%{state: "active"})
      assert html =~ "animate-"
    end

    test "renders label text" do
      assert render_zone(%{label: "Drop here"}) =~ "Drop here"
    end

    test "renders default SVG upload icon" do
      assert render_zone() =~ "<svg"
    end

    test "renders custom icon slot" do
      assert render_zone_with_icon() =~ "custom-icon"
    end

    test "applies custom class" do
      assert render_zone(%{class: "my-zone"}) =~ "my-zone"
    end

    test "has dashed border" do
      assert render_zone() =~ "border-dashed"
    end
  end

  # ---------------------------------------------------------------------------
  # drag_transfer_list/1
  # ---------------------------------------------------------------------------

  describe "drag_transfer_list/1" do
    test "renders a root div" do
      assert render_transfer() =~ "<div"
    end

    test "has phx-hook=PhiaDragTransferList" do
      assert render_transfer() =~ ~s(phx-hook="PhiaDragTransferList")
    end

    test "forwards id attribute" do
      assert render_transfer(%{id: "my-transfer"}) =~ ~s(id="my-transfer")
    end

    test "has data-on-transfer attribute" do
      assert render_transfer(%{on_transfer: "roles_updated"}) =~ ~s(data-on-transfer="roles_updated")
    end

    test "renders source list container" do
      assert render_transfer() =~ "data-transfer-source"
    end

    test "renders target list container" do
      assert render_transfer() =~ "data-transfer-target"
    end

    test "renders source label" do
      assert render_transfer(%{source_label: "Available roles"}) =~ "Available roles"
    end

    test "renders target label" do
      assert render_transfer(%{target_label: "Assigned roles"}) =~ "Assigned roles"
    end

    test "renders source items" do
      html = render_transfer()
      assert html =~ "Item A"
      assert html =~ "Item B"
    end

    test "renders target items" do
      assert render_transfer() =~ "Item C"
    end

    test "source items have draggable=true" do
      html = render_transfer()
      assert html =~ ~s(draggable="true")
    end

    test "source items have data-item-id" do
      assert render_transfer() =~ ~s(data-item-id="a")
    end

    test "renders transfer buttons" do
      html = render_transfer()
      assert html =~ "data-transfer-to-target"
      assert html =~ "data-transfer-to-source"
    end

    test "applies custom class" do
      assert render_transfer(%{class: "my-transfer"}) =~ "my-transfer"
    end
  end
end
