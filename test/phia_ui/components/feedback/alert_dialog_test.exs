defmodule PhiaUi.Components.AlertDialogTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helper module
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.AlertDialog

    def render_default(assigns) do
      ~H"""
      <.alert_dialog id="confirm-dialog" open={true}>
        <.alert_dialog_header>
          <.alert_dialog_title id="confirm-title">Delete item?</.alert_dialog_title>
          <.alert_dialog_description id="confirm-desc">
            This action cannot be undone.
          </.alert_dialog_description>
        </.alert_dialog_header>
        <.alert_dialog_footer>
          <.alert_dialog_cancel>Cancel</.alert_dialog_cancel>
          <.alert_dialog_action>Confirm</.alert_dialog_action>
        </.alert_dialog_footer>
      </.alert_dialog>
      """
    end

    def render_destructive(assigns) do
      ~H"""
      <.alert_dialog id="delete-dialog" open={true}>
        <.alert_dialog_header>
          <.alert_dialog_title>Delete?</.alert_dialog_title>
        </.alert_dialog_header>
        <.alert_dialog_footer>
          <.alert_dialog_cancel>Cancel</.alert_dialog_cancel>
          <.alert_dialog_action variant="destructive">Delete</.alert_dialog_action>
        </.alert_dialog_footer>
      </.alert_dialog>
      """
    end

    def render_closed(assigns) do
      ~H"""
      <.alert_dialog id="closed-dialog" open={false}>
        <.alert_dialog_header>
          <.alert_dialog_title>Title</.alert_dialog_title>
        </.alert_dialog_header>
        <.alert_dialog_footer>
          <.alert_dialog_cancel>Cancel</.alert_dialog_cancel>
        </.alert_dialog_footer>
      </.alert_dialog>
      """
    end

    def render_with_aria(assigns) do
      ~H"""
      <.alert_dialog
        id="aria-dialog"
        open={true}
        aria-labelledby="aria-dialog-title"
        aria-describedby="aria-dialog-desc"
      >
        <.alert_dialog_header>
          <.alert_dialog_title id="aria-dialog-title">Aria Title</.alert_dialog_title>
          <.alert_dialog_description id="aria-dialog-desc">Aria desc.</.alert_dialog_description>
        </.alert_dialog_header>
        <.alert_dialog_footer>
          <.alert_dialog_cancel>Cancel</.alert_dialog_cancel>
        </.alert_dialog_footer>
      </.alert_dialog>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # AC 1 & 2: Sub-components exist
  # ---------------------------------------------------------------------------

  describe "sub-components exports" do
    test "alert_dialog/1 is exported" do
      assert function_exported?(PhiaUi.Components.AlertDialog, :alert_dialog, 1)
    end

    test "alert_dialog_header/1 is exported" do
      assert function_exported?(PhiaUi.Components.AlertDialog, :alert_dialog_header, 1)
    end

    test "alert_dialog_footer/1 is exported" do
      assert function_exported?(PhiaUi.Components.AlertDialog, :alert_dialog_footer, 1)
    end

    test "alert_dialog_title/1 is exported" do
      assert function_exported?(PhiaUi.Components.AlertDialog, :alert_dialog_title, 1)
    end

    test "alert_dialog_description/1 is exported" do
      assert function_exported?(PhiaUi.Components.AlertDialog, :alert_dialog_description, 1)
    end

    test "alert_dialog_action/1 is exported" do
      assert function_exported?(PhiaUi.Components.AlertDialog, :alert_dialog_action, 1)
    end

    test "alert_dialog_cancel/1 is exported" do
      assert function_exported?(PhiaUi.Components.AlertDialog, :alert_dialog_cancel, 1)
    end
  end

  # ---------------------------------------------------------------------------
  # AC 1: role="alertdialog" and aria-modal="true"
  # ---------------------------------------------------------------------------

  describe "alert_dialog/1" do
    test "has role=alertdialog" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(role="alertdialog")
    end

    test "has aria-modal=true" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(aria-modal="true")
    end

    test "uses PhiaDialog hook for focus trap" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "PhiaDialog"
    end

    test "renders with the given id" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(id="confirm-dialog")
    end

    test "is visible when open=true (class attribute does not contain hidden)" do
      html = render_component(&H.render_default/1, %{})
      refute html =~ ~s(class="fixed inset-0 z-50 hidden")
    end

    test "is hidden when open=false" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ "hidden"
    end

    test "renders inner content" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Delete item?"
      assert html =~ "This action cannot be undone."
    end
  end

  # ---------------------------------------------------------------------------
  # AC 2: alert_dialog_action/1 — destructive variant
  # ---------------------------------------------------------------------------

  describe "alert_dialog_action/1" do
    test "default variant has bg-primary" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "bg-primary"
    end

    test "destructive variant has bg-destructive" do
      html = render_component(&H.render_destructive/1, %{})
      assert html =~ "bg-destructive"
    end

    test "destructive variant has text-destructive-foreground" do
      html = render_component(&H.render_destructive/1, %{})
      assert html =~ "text-destructive-foreground"
    end

    test "renders as a button element" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<button"
    end

    test "renders action content" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Confirm"
    end
  end

  # ---------------------------------------------------------------------------
  # AC 3: alert_dialog_cancel/1 — button with close behavior
  # ---------------------------------------------------------------------------

  describe "alert_dialog_cancel/1" do
    test "renders as a button element" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<button"
    end

    test "renders cancel text" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Cancel"
    end

    test "has border-input class (outline style)" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "border-input"
    end
  end

  # ---------------------------------------------------------------------------
  # AC 6: ARIA attributes — labelledby and describedby
  # ---------------------------------------------------------------------------

  describe "alert_dialog/1 — aria linkage" do
    test "aria-labelledby points to the title element" do
      html = render_component(&H.render_with_aria/1, %{})
      assert html =~ ~s(aria-labelledby="aria-dialog-title")
    end

    test "aria-describedby points to the description element" do
      html = render_component(&H.render_with_aria/1, %{})
      assert html =~ ~s(aria-describedby="aria-dialog-desc")
    end

    test "title renders with the given id" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(id="confirm-title")
    end

    test "description renders with the given id" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(id="confirm-desc")
    end
  end

  # ---------------------------------------------------------------------------
  # AC 7: Sub-component rendering
  # ---------------------------------------------------------------------------

  describe "alert_dialog_title/1" do
    test "renders title text" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Delete item?"
    end

    test "renders as h2 element" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<h2"
    end

    test "has font-semibold class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "font-semibold"
    end
  end

  describe "alert_dialog_description/1" do
    test "renders description text" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "This action cannot be undone."
    end

    test "uses muted-foreground for de-emphasized styling" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "text-muted-foreground"
    end
  end

  describe "alert_dialog_header/1" do
    test "renders header content" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Delete item?"
    end
  end

  describe "alert_dialog_footer/1" do
    test "renders footer content with action buttons" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "Cancel"
      assert html =~ "Confirm"
    end

    test "has sm:flex-row layout class" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "sm:flex-row"
    end
  end

  # ---------------------------------------------------------------------------
  # moduledoc
  # ---------------------------------------------------------------------------

  describe "moduledoc" do
    test "moduledoc is defined and non-empty" do
      assert Code.fetch_docs(PhiaUi.Components.AlertDialog) != :error
    end

    test "moduledoc mentions alertdialog role and PhiaDialog hook" do
      {:docs_v1, _, _, _, %{"en" => moduledoc}, _, _} =
        Code.fetch_docs(PhiaUi.Components.AlertDialog)

      assert moduledoc =~ "alertdialog"
      assert moduledoc =~ "PhiaDialog"
    end
  end
end
