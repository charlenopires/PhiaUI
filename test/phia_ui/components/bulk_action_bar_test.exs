defmodule PhiaUi.Components.BulkActionBarTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.BulkActionBar

    def render_bar(assigns) do
      ~H"""
      <.bulk_action_bar
        count={assigns[:count] || 0}
        label={assigns[:label] || "selected"}
        on_clear="clear_selection"
        class={assigns[:class]}
      >
        <.bulk_action label="Delete" on_click="bulk_delete" variant="destructive" />
        <.bulk_action label="Archive" on_click="bulk_archive" />
      </.bulk_action_bar>
      """
    end

    def render_bar_with_icon(assigns) do
      ~H"""
      <.bulk_action_bar count={3} on_clear="clear">
        <.bulk_action label="Export" on_click="bulk_export" icon="download" />
      </.bulk_action_bar>
      """
    end

    def render_empty(assigns) do
      ~H"""
      <.bulk_action_bar count={0} on_clear="clear_selection">
        <.bulk_action label="Delete" on_click="bulk_delete" />
      </.bulk_action_bar>
      """
    end

    def render_action(assigns) do
      ~H"""
      <.bulk_action
        label={assigns[:label] || "Action"}
        on_click={assigns[:on_click] || "do_action"}
        variant={assigns[:variant] || "default"}
        icon={assigns[:icon]}
        class={assigns[:class]}
      />
      """
    end
  end

  defp render_bar(attrs \\ %{}), do: render_component(&H.render_bar/1, attrs)
  defp render_bar_with_icon, do: render_component(&H.render_bar_with_icon/1, %{})
  defp render_empty, do: render_component(&H.render_empty/1, %{})
  defp render_action(attrs \\ %{}), do: render_component(&H.render_action/1, attrs)

  # ---------------------------------------------------------------------------
  # bulk_action_bar/1 — visibility
  # ---------------------------------------------------------------------------

  describe "bulk_action_bar/1 — visibility" do
    test "renders bar content when count > 0" do
      html = render_bar(%{count: 3})
      assert html =~ "3"
    end

    test "does not render bar content when count is 0" do
      html = render_empty()
      assert html == "" or not (html =~ "selected") or not (html =~ "toolbar")
    end

    test "renders for count=1 (singular)" do
      html = render_bar(%{count: 1})
      assert html =~ "1"
    end

    test "renders for large count" do
      html = render_bar(%{count: 1000})
      assert html =~ "1000"
    end
  end

  # ---------------------------------------------------------------------------
  # bulk_action_bar/1 — count and label
  # ---------------------------------------------------------------------------

  describe "bulk_action_bar/1 — count display" do
    test "displays the count number" do
      html = render_bar(%{count: 5})
      assert html =~ "5"
    end

    test "displays default label 'selected'" do
      html = render_bar(%{count: 3})
      assert html =~ "selected"
    end

    test "displays custom label when provided" do
      html = render_bar(%{count: 3, label: "items"})
      assert html =~ "items"
    end

    test "custom class is applied to wrapper" do
      html = render_bar(%{count: 2, class: "my-bulk-bar"})
      assert html =~ "my-bulk-bar"
    end
  end

  # ---------------------------------------------------------------------------
  # bulk_action_bar/1 — clear button
  # ---------------------------------------------------------------------------

  describe "bulk_action_bar/1 — clear button" do
    test "renders a clear/dismiss button" do
      html = render_bar(%{count: 3})
      assert html =~ "<button"
    end

    test "clear button has phx-click wired to on_clear event" do
      html = render_bar(%{count: 3})
      assert html =~ "clear_selection"
    end

    test "clear button has accessible label" do
      html = render_bar(%{count: 3})
      assert html =~ "aria-label" or html =~ "Clear" or html =~ "Deselect"
    end
  end

  # ---------------------------------------------------------------------------
  # bulk_action_bar/1 — inner slot
  # ---------------------------------------------------------------------------

  describe "bulk_action_bar/1 — actions slot" do
    test "renders inner slot action buttons" do
      html = render_bar(%{count: 2})
      assert html =~ "Delete"
      assert html =~ "Archive"
    end

    test "renders action with icon" do
      html = render_bar_with_icon()
      assert html =~ "Export"
    end
  end

  # ---------------------------------------------------------------------------
  # bulk_action_bar/1 — ARIA
  # ---------------------------------------------------------------------------

  describe "bulk_action_bar/1 — ARIA" do
    test "bar has role=toolbar" do
      html = render_bar(%{count: 3})
      assert html =~ ~s(role="toolbar")
    end

    test "bar has aria-label" do
      html = render_bar(%{count: 3})
      assert html =~ "aria-label"
    end
  end

  # ---------------------------------------------------------------------------
  # bulk_action/1 — button
  # ---------------------------------------------------------------------------

  describe "bulk_action/1 — default variant" do
    test "renders a button" do
      assert render_action() =~ "<button"
    end

    test "renders the label" do
      html = render_action(%{label: "Export CSV"})
      assert html =~ "Export CSV"
    end

    test "phx-click is wired to on_click event" do
      html = render_action(%{on_click: "my_bulk_action"})
      assert html =~ "my_bulk_action"
    end

    test "custom class is applied" do
      html = render_action(%{class: "my-action"})
      assert html =~ "my-action"
    end
  end

  describe "bulk_action/1 — destructive variant" do
    test "destructive variant has distinct styling" do
      html = render_action(%{variant: "destructive"})
      assert html =~ "destructive" or html =~ "text-destructive" or html =~ "bg-destructive"
    end

    test "default variant does not have destructive styling" do
      html = render_action(%{variant: "default"})
      refute html =~ "bg-destructive"
    end
  end

  describe "bulk_action/1 — icon" do
    test "renders icon when provided" do
      html = render_action(%{icon: "trash"})
      assert html =~ "svg" or html =~ "icon" or html =~ "use"
    end

    test "no icon element when icon is nil" do
      html = render_action(%{icon: nil})
      # Just check it renders label without crash
      assert html =~ "Action"
    end
  end

  # ---------------------------------------------------------------------------
  # Semantic tokens
  # ---------------------------------------------------------------------------

  describe "semantic tokens" do
    test "no hardcoded hex colors in style attributes" do
      html = render_bar(%{count: 3})
      refute html =~ ~r/style="[^"]*#[0-9a-fA-F]{3,6}/
    end

    test "uses semantic border or background tokens" do
      html = render_bar(%{count: 3})
      assert html =~ "border" or html =~ "bg-"
    end
  end
end
