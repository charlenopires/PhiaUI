defmodule PhiaUi.Components.ToastTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Toast

    def render_container(assigns) do
      ~H"""
      <.toast id="toast-viewport" />
      """
    end

    def render_container_custom(assigns) do
      ~H"""
      <.toast id="toast-vp" max_toasts={3} class="custom-viewport" />
      """
    end

    def render_title(assigns) do
      ~H"""
      <.toast_title>Operation successful</.toast_title>
      """
    end

    def render_description(assigns) do
      ~H"""
      <.toast_description>Your changes have been saved.</.toast_description>
      """
    end

    def render_action(assigns) do
      ~H"""
      <.toast_action on_click="undo">Undo</.toast_action>
      """
    end

    def render_close(assigns) do
      ~H"""
      <.toast_close />
      """
    end

    def render_full_toast(assigns) do
      ~H"""
      <div class="toast-item">
        <.toast_title>Saved</.toast_title>
        <.toast_description>Record updated successfully.</.toast_description>
        <.toast_action on_click="undo">Undo</.toast_action>
        <.toast_close />
      </div>
      """
    end

    def render_variants(assigns) do
      ~H"""
      <div>
        <.toast id="t-default" variant={:default} />
        <.toast id="t-success" variant={:success} />
        <.toast id="t-destructive" variant={:destructive} />
        <.toast id="t-warning" variant={:warning} />
      </div>
      """
    end
  end

  defp render_container, do: render_component(&H.render_container/1, %{})
  defp render_container_custom, do: render_component(&H.render_container_custom/1, %{})
  defp render_title, do: render_component(&H.render_title/1, %{})
  defp render_description, do: render_component(&H.render_description/1, %{})
  defp render_action, do: render_component(&H.render_action/1, %{})
  defp render_close, do: render_component(&H.render_close/1, %{})
  defp render_full_toast, do: render_component(&H.render_full_toast/1, %{})
  defp render_variants, do: render_component(&H.render_variants/1, %{})

  # ---------------------------------------------------------------------------
  # toast/1 — container / viewport
  # ---------------------------------------------------------------------------

  describe "toast/1 — container" do
    test "renders container element" do
      assert render_container() =~ ~s(id="toast-viewport")
    end

    test "has phx-hook='PhiaToast'" do
      assert render_container() =~ ~s(phx-hook="PhiaToast")
    end

    test "has role='status'" do
      assert render_container() =~ ~s(role="status")
    end

    test "has aria-live='polite'" do
      assert render_container() =~ ~s(aria-live="polite")
    end

    test "has data-max-toasts with default 5" do
      assert render_container() =~ ~s(data-max-toasts="5")
    end

    test "custom max_toasts sets data-max-toasts" do
      assert render_container_custom() =~ ~s(data-max-toasts="3")
    end

    test "accepts :class and merges via cn/1" do
      assert render_container_custom() =~ "custom-viewport"
    end
  end

  # ---------------------------------------------------------------------------
  # toast_title/1
  # ---------------------------------------------------------------------------

  describe "toast_title/1" do
    test "renders title text" do
      assert render_title() =~ "Operation successful"
    end

    test "has font-semibold styling" do
      assert render_title() =~ "font-semibold"
    end
  end

  # ---------------------------------------------------------------------------
  # toast_description/1
  # ---------------------------------------------------------------------------

  describe "toast_description/1" do
    test "renders description text" do
      assert render_description() =~ "Your changes have been saved."
    end

    test "has text-sm styling" do
      assert render_description() =~ "text-sm"
    end
  end

  # ---------------------------------------------------------------------------
  # toast_action/1
  # ---------------------------------------------------------------------------

  describe "toast_action/1" do
    test "renders action button text" do
      assert render_action() =~ "Undo"
    end

    test "has phx-click with on_click event" do
      assert render_action() =~ ~s(phx-click="undo")
    end

    test "renders as button element" do
      assert render_action() =~ "<button"
    end
  end

  # ---------------------------------------------------------------------------
  # toast_close/1
  # ---------------------------------------------------------------------------

  describe "toast_close/1" do
    test "renders a button" do
      assert render_close() =~ "<button"
    end

    test "has aria-label='Close'" do
      assert render_close() =~ ~s(aria-label="Close")
    end

    test "has data-toast-close marker" do
      assert render_close() =~ "data-toast-close"
    end
  end

  # ---------------------------------------------------------------------------
  # full toast composition
  # ---------------------------------------------------------------------------

  describe "full toast composition" do
    test "renders all sub-components together" do
      html = render_full_toast()
      assert html =~ "Saved"
      assert html =~ "Record updated successfully."
      assert html =~ "Undo"
      assert html =~ ~s(aria-label="Close")
    end
  end

  # ---------------------------------------------------------------------------
  # variants
  # ---------------------------------------------------------------------------

  describe "toast/1 — variants" do
    test "accepts :default, :success, :destructive, :warning variants" do
      # All four should render without error
      html = render_variants()
      assert html =~ ~s(id="t-default")
      assert html =~ ~s(id="t-success")
      assert html =~ ~s(id="t-destructive")
      assert html =~ ~s(id="t-warning")
    end
  end
end
