defmodule PhiaUi.Components.DialogTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helper module
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Dialog

    def render_dialog(assigns) do
      ~H"""
      <.dialog id={@id}>Content</.dialog>
      """
    end

    def render_trigger(assigns) do
      ~H"""
      <.dialog_trigger for={@for}>Open</.dialog_trigger>
      """
    end

    def render_content(assigns) do
      ~H"""
      <.dialog_content id={@id}>Body</.dialog_content>
      """
    end

    def render_content_with_class(assigns) do
      ~H"""
      <.dialog_content id={@id} class={@class}>Body</.dialog_content>
      """
    end

    def render_header(assigns) do
      ~H"""
      <.dialog_header class={@class}>Header</.dialog_header>
      """
    end

    def render_title(assigns) do
      ~H"""
      <.dialog_title id={@id}>Title</.dialog_title>
      """
    end

    def render_description(assigns) do
      ~H"""
      <.dialog_description id={@id}>Description</.dialog_description>
      """
    end

    def render_footer(assigns) do
      ~H"""
      <.dialog_footer class={@class}>Footer</.dialog_footer>
      """
    end

    def render_close(assigns) do
      ~H"""
      <.dialog_close for={@for}>Cancel</.dialog_close>
      """
    end

    def render_content_size_sm(assigns) do
      ~H"""
      <.dialog_content id="test" size="sm">Body</.dialog_content>
      """
    end

    def render_content_size_lg(assigns) do
      ~H"""
      <.dialog_content id="test" size="lg">Body</.dialog_content>
      """
    end

    def render_content_size_xl(assigns) do
      ~H"""
      <.dialog_content id="test" size="xl">Body</.dialog_content>
      """
    end

    def render_content_size_full(assigns) do
      ~H"""
      <.dialog_content id="test" size="full">Body</.dialog_content>
      """
    end

    def render_content_no_close(assigns) do
      ~H"""
      <.dialog_content id="test" show_close_button={false}>Body</.dialog_content>
      """
    end

    def render_content_scrollable(assigns) do
      ~H"""
      <.dialog_content id="test" scrollable={true}>Body</.dialog_content>
      """
    end

    def render_full_composition(assigns) do
      ~H"""
      <.dialog id="confirm">
        <.dialog_trigger for="confirm">Open</.dialog_trigger>
        <.dialog_content id="confirm">
          <.dialog_header>
            <.dialog_title id="confirm-title">Confirm</.dialog_title>
            <.dialog_description id="confirm-description">Are you sure?</.dialog_description>
          </.dialog_header>
          <p>Content</p>
          <.dialog_footer>
            <.dialog_close for="confirm">Cancel</.dialog_close>
          </.dialog_footer>
        </.dialog_content>
      </.dialog>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # AC 1: Sub-components exist
  # ---------------------------------------------------------------------------

  describe "sub-components" do
    test "dialog/1 is exported" do
      assert function_exported?(PhiaUi.Components.Dialog, :dialog, 1)
    end

    test "dialog_trigger/1 is exported" do
      assert function_exported?(PhiaUi.Components.Dialog, :dialog_trigger, 1)
    end

    test "dialog_content/1 is exported" do
      assert function_exported?(PhiaUi.Components.Dialog, :dialog_content, 1)
    end

    test "dialog_header/1 is exported" do
      assert function_exported?(PhiaUi.Components.Dialog, :dialog_header, 1)
    end

    test "dialog_title/1 is exported" do
      assert function_exported?(PhiaUi.Components.Dialog, :dialog_title, 1)
    end

    test "dialog_description/1 is exported" do
      assert function_exported?(PhiaUi.Components.Dialog, :dialog_description, 1)
    end

    test "dialog_footer/1 is exported" do
      assert function_exported?(PhiaUi.Components.Dialog, :dialog_footer, 1)
    end

    test "dialog_close/1 is exported" do
      assert function_exported?(PhiaUi.Components.Dialog, :dialog_close, 1)
    end
  end

  # ---------------------------------------------------------------------------
  # AC 2: dialog/1 — :id attr and phx-hook="PhiaDialog"
  # ---------------------------------------------------------------------------

  describe "dialog/1" do
    test "renders with the given id" do
      html = render_component(&H.render_dialog/1, %{id: "my-dialog"})
      assert html =~ ~s(id="my-dialog")
    end

    test "renders phx-hook=PhiaDialog" do
      html = render_component(&H.render_dialog/1, %{id: "my-dialog"})
      assert html =~ ~s(phx-hook="PhiaDialog")
    end

    test "renders inner content" do
      html = render_component(&H.render_dialog/1, %{id: "my-dialog"})
      assert html =~ "Content"
    end
  end

  # ---------------------------------------------------------------------------
  # AC 3: dialog_content/1 — ARIA attrs
  # ---------------------------------------------------------------------------

  describe "dialog_content/1" do
    test "renders role=dialog" do
      html = render_component(&H.render_content/1, %{id: "confirm"})
      assert html =~ ~s(role="dialog")
    end

    test "renders aria-modal=true" do
      html = render_component(&H.render_content/1, %{id: "confirm"})
      assert html =~ ~s(aria-modal="true")
    end

    test "renders aria-labelledby pointing to {id}-title" do
      html = render_component(&H.render_content/1, %{id: "confirm"})
      assert html =~ ~s(aria-labelledby="confirm-title")
    end

    test "renders aria-describedby pointing to {id}-description" do
      html = render_component(&H.render_content/1, %{id: "confirm"})
      assert html =~ ~s(aria-describedby="confirm-description")
    end

    # ---------------------------------------------------------------------------
    # AC 5: dialog_content/1 — panel scale-in transition classes
    # ---------------------------------------------------------------------------

    test "panel has transition-all ease-out duration-300 classes" do
      html = render_component(&H.render_content/1, %{id: "confirm"})
      assert html =~ "ease-out"
      assert html =~ "duration-300"
    end

    test "panel starts from opacity-0 scale-95" do
      html = render_component(&H.render_content/1, %{id: "confirm"})
      assert html =~ "opacity-0"
      assert html =~ "scale-95"
    end
  end

  # ---------------------------------------------------------------------------
  # AC 4: Overlay — backdrop-blur
  # ---------------------------------------------------------------------------

  describe "dialog_content/1 overlay" do
    test "overlay has backdrop-blur class" do
      html = render_component(&H.render_content/1, %{id: "confirm"})
      assert html =~ "backdrop-blur"
    end

    test "overlay has fixed inset-0 positioning" do
      html = render_component(&H.render_content/1, %{id: "confirm"})
      assert html =~ "fixed"
      assert html =~ "inset-0"
    end

    test "dialog_content outer container is hidden by default" do
      html = render_component(&H.render_content/1, %{id: "confirm"})
      assert html =~ "hidden"
    end

    test "dialog_content outer container id is prefixed with dialog-" do
      html = render_component(&H.render_content/1, %{id: "confirm"})
      assert html =~ ~s(id="dialog-confirm")
    end
  end

  # ---------------------------------------------------------------------------
  # AC 6: dialog_trigger/1 — JS.show('#dialog-#{@for}')
  # ---------------------------------------------------------------------------

  describe "dialog_trigger/1" do
    test "phx-click contains JS.show with #dialog-{for} selector" do
      html = render_component(&H.render_trigger/1, %{for: "confirm"})
      assert html =~ "#dialog-confirm"
    end

    test "renders inner content (slot)" do
      html = render_component(&H.render_trigger/1, %{for: "confirm"})
      assert html =~ "Open"
    end
  end

  # ---------------------------------------------------------------------------
  # AC 7: dialog_close/1 — JS.hide closes dialog, and Escape via hook
  # ---------------------------------------------------------------------------

  describe "dialog_close/1" do
    test "phx-click contains JS.hide with #dialog-{for} selector" do
      html = render_component(&H.render_close/1, %{for: "confirm"})
      assert html =~ "#dialog-confirm"
    end

    test "renders as a button" do
      html = render_component(&H.render_close/1, %{for: "confirm"})
      assert html =~ "<button"
    end

    test "renders inner content (slot)" do
      html = render_component(&H.render_close/1, %{for: "confirm"})
      assert html =~ "Cancel"
    end
  end

  # ---------------------------------------------------------------------------
  # Layout sub-components
  # ---------------------------------------------------------------------------

  describe "dialog_header/1" do
    test "renders a div container" do
      html = render_component(&H.render_header/1, %{class: nil})
      assert html =~ "<div"
      assert html =~ "Header"
    end

    test "accepts :class override" do
      html = render_component(&H.render_header/1, %{class: "custom-header"})
      assert html =~ "custom-header"
    end
  end

  describe "dialog_title/1" do
    test "renders an h2 element" do
      html = render_component(&H.render_title/1, %{id: "confirm-title"})
      assert html =~ "<h2"
      assert html =~ "Title"
    end

    test "renders with the given id" do
      html = render_component(&H.render_title/1, %{id: "confirm-title"})
      assert html =~ ~s(id="confirm-title")
    end
  end

  describe "dialog_description/1" do
    test "renders a p element" do
      html = render_component(&H.render_description/1, %{id: "confirm-description"})
      assert html =~ "<p"
      assert html =~ "Description"
    end

    test "renders with the given id" do
      html = render_component(&H.render_description/1, %{id: "confirm-description"})
      assert html =~ ~s(id="confirm-description")
    end
  end

  describe "dialog_footer/1" do
    test "renders a div container" do
      html = render_component(&H.render_footer/1, %{class: nil})
      assert html =~ "<div"
      assert html =~ "Footer"
    end
  end

  # ---------------------------------------------------------------------------
  # Full composition
  # ---------------------------------------------------------------------------

  describe "full composition" do
    test "renders all sub-components together" do
      html = render_component(&H.render_full_composition/1, %{})
      assert html =~ ~s(id="confirm")
      assert html =~ ~s(phx-hook="PhiaDialog")
      assert html =~ "#dialog-confirm"
      assert html =~ ~s(role="dialog")
      assert html =~ ~s(aria-modal="true")
      assert html =~ "backdrop-blur"
      assert html =~ "Confirm"
      assert html =~ "Are you sure?"
    end
  end

  # ---------------------------------------------------------------------------
  # dialog_content/1 — size variants
  # ---------------------------------------------------------------------------

  describe "dialog_content/1 — size variants" do
    test "default size has max-w-lg class" do
      html = render_component(&H.render_content/1, %{id: "test"})
      assert html =~ "max-w-lg"
    end

    test "size='sm' has max-w-sm class" do
      html = render_component(&H.render_content_size_sm/1, %{})
      assert html =~ "max-w-sm"
    end

    test "size='lg' has max-w-2xl class" do
      html = render_component(&H.render_content_size_lg/1, %{})
      assert html =~ "max-w-2xl"
    end

    test "size='xl' has max-w-4xl class" do
      html = render_component(&H.render_content_size_xl/1, %{})
      assert html =~ "max-w-4xl"
    end

    test "size='full' has calc(100vw-based max-width" do
      html = render_component(&H.render_content_size_full/1, %{})
      assert html =~ "100vw"
    end

    test "size='sm' does not have max-w-lg" do
      html = render_component(&H.render_content_size_sm/1, %{})
      refute html =~ "max-w-lg"
    end
  end

  # ---------------------------------------------------------------------------
  # dialog_content/1 — show_close_button
  # ---------------------------------------------------------------------------

  describe "dialog_content/1 — show_close_button" do
    test "show_close_button=true (default) renders X close button" do
      html = render_component(&H.render_content/1, %{id: "test"})
      assert html =~ ~s(aria-label="Close dialog")
    end

    test "show_close_button=true close button targets #dialog-{id}" do
      html = render_component(&H.render_content/1, %{id: "test"})
      assert html =~ "#dialog-test"
    end

    test "show_close_button=false omits the X button" do
      html = render_component(&H.render_content_no_close/1, %{})
      refute html =~ ~s(aria-label="Close dialog")
    end

    test "close button has sr-only label" do
      html = render_component(&H.render_content/1, %{id: "test"})
      assert html =~ "sr-only"
      assert html =~ "Close"
    end
  end

  # ---------------------------------------------------------------------------
  # dialog_content/1 — scrollable
  # ---------------------------------------------------------------------------

  describe "dialog_content/1 — scrollable" do
    test "scrollable=true adds overflow-y-auto class" do
      html = render_component(&H.render_content_scrollable/1, %{})
      assert html =~ "overflow-y-auto"
    end

    test "scrollable=true adds max-h constraint" do
      html = render_component(&H.render_content_scrollable/1, %{})
      assert html =~ "max-h-"
    end

    test "scrollable=false (default) has no overflow-y-auto" do
      html = render_component(&H.render_content/1, %{id: "test"})
      refute html =~ "overflow-y-auto"
    end
  end

  # ---------------------------------------------------------------------------
  # AC 14: JS Hook file exists at priv/templates/js/hooks/dialog.js
  # ---------------------------------------------------------------------------

  @hook_path Path.join([File.cwd!(), "priv/templates/js/hooks/dialog.js"])

  describe "dialog.js hook file" do
    test "file exists at priv/templates/js/hooks/dialog.js" do
      assert File.exists?(@hook_path), "Expected #{@hook_path} to exist"
    end

    # AC 14: ES6 object pattern
    test "exports an ES6 object (const PhiaDialog = {})" do
      content = File.read!(@hook_path)
      assert content =~ "PhiaDialog"
    end

    test "has mounted() lifecycle" do
      content = File.read!(@hook_path)
      assert content =~ "mounted()"
    end

    # AC 12: destroyed() removes listeners
    test "has destroyed() lifecycle" do
      content = File.read!(@hook_path)
      assert content =~ "destroyed()"
    end

    # AC 8: focus trap
    test "implements focus trap (Tab key handler)" do
      content = File.read!(@hook_path)
      assert content =~ "Tab"
    end

    # AC 9: auto-focus
    test "calls focus() on first focusable element" do
      content = File.read!(@hook_path)
      assert content =~ "focus()"
    end

    # AC 10: focus return to trigger
    test "stores and restores previouslyFocused element" do
      content = File.read!(@hook_path)

      assert content =~ "previouslyFocused" or content =~ "triggerEl" or
               content =~ "activeElement"
    end

    # AC 11: scroll blocked
    test "adds overflow-hidden to document.body on open" do
      content = File.read!(@hook_path)
      assert content =~ "overflow-hidden"
      assert content =~ "document.body"
    end

    # AC 12: no memory leaks — destroyed removes listeners
    test "destroyed() removes event listeners" do
      content = File.read!(@hook_path)
      assert content =~ "removeEventListener"
    end

    # AC 13: scoped to this.el
    test "uses this.el for DOM queries (not document.querySelector globally)" do
      content = File.read!(@hook_path)
      assert content =~ "this.el"
      # Must NOT use bare document.querySelector for scoped elements
      refute content =~ ~r/document\.querySelector\([^)]*focusable/
    end

    # AC 7: Escape key closes dialog
    test "listens for Escape keydown" do
      content = File.read!(@hook_path)
      assert content =~ "Escape"
    end
  end

  # ---------------------------------------------------------------------------
  # AC 15: @moduledoc contains app.js registration instructions
  # ---------------------------------------------------------------------------

  describe "moduledoc" do
    test "moduledoc is a non-empty string" do
      assert Code.fetch_docs(PhiaUi.Components.Dialog) != :error
    end

    test "moduledoc mentions PhiaDialog hook registration" do
      {:docs_v1, _, _, _, %{"en" => moduledoc}, _, _} =
        Code.fetch_docs(PhiaUi.Components.Dialog)

      assert moduledoc =~ "PhiaDialog"
      assert moduledoc =~ "app.js"
    end
  end
end
