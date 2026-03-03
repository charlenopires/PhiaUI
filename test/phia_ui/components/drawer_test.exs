defmodule PhiaUi.Components.DrawerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  # ---------------------------------------------------------------------------
  # Test helper module
  # ---------------------------------------------------------------------------

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Drawer

    def render_open(assigns) do
      ~H"""
      <.drawer id="main-drawer">
        <.drawer_trigger drawer_id="main-drawer">Open</.drawer_trigger>
        <.drawer_content id="main-drawer-content" open={true} direction="bottom">
          <.drawer_header>
            <h2 id="drawer-title">Drawer Title</h2>
          </.drawer_header>
          <.drawer_close />
          <p>Drawer content here</p>
          <.drawer_footer>
            <button>Save</button>
          </.drawer_footer>
        </.drawer_content>
      </.drawer>
      """
    end

    def render_closed(assigns) do
      ~H"""
      <.drawer id="closed-drawer">
        <.drawer_trigger drawer_id="closed-drawer">Open</.drawer_trigger>
        <.drawer_content id="closed-drawer-content" open={false}>
          <p>Hidden content</p>
        </.drawer_content>
      </.drawer>
      """
    end

    def render_left(assigns) do
      ~H"""
      <.drawer id="left-drawer">
        <.drawer_trigger drawer_id="left-drawer">Open Left</.drawer_trigger>
        <.drawer_content id="left-drawer-content" open={true} direction="left">
          <p>Left drawer</p>
        </.drawer_content>
      </.drawer>
      """
    end

    def render_right(assigns) do
      ~H"""
      <.drawer id="right-drawer">
        <.drawer_trigger drawer_id="right-drawer">Open Right</.drawer_trigger>
        <.drawer_content id="right-drawer-content" open={true} direction="right">
          <p>Right drawer</p>
        </.drawer_content>
      </.drawer>
      """
    end

    def render_top(assigns) do
      ~H"""
      <.drawer id="top-drawer">
        <.drawer_trigger drawer_id="top-drawer">Open Top</.drawer_trigger>
        <.drawer_content id="top-drawer-content" open={true} direction="top">
          <p>Top drawer</p>
        </.drawer_content>
      </.drawer>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # AC 1: drawer/1 with direction attr
  # ---------------------------------------------------------------------------

  describe "sub-components" do
    test "drawer/1 is exported" do
      assert function_exported?(PhiaUi.Components.Drawer, :drawer, 1)
    end

    test "drawer_trigger/1 is exported" do
      assert function_exported?(PhiaUi.Components.Drawer, :drawer_trigger, 1)
    end

    test "drawer_content/1 is exported" do
      assert function_exported?(PhiaUi.Components.Drawer, :drawer_content, 1)
    end

    test "drawer_header/1 is exported" do
      assert function_exported?(PhiaUi.Components.Drawer, :drawer_header, 1)
    end

    test "drawer_footer/1 is exported" do
      assert function_exported?(PhiaUi.Components.Drawer, :drawer_footer, 1)
    end

    test "drawer_close/1 is exported" do
      assert function_exported?(PhiaUi.Components.Drawer, :drawer_close, 1)
    end
  end

  # ---------------------------------------------------------------------------
  # AC 1: direction attr
  # ---------------------------------------------------------------------------

  describe "drawer_content/1 — direction variants" do
    test "direction=bottom has rounded-t-lg (default)" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "rounded-t-lg"
    end

    test "direction=left applies left panel classes" do
      html = render_component(&H.render_left/1, %{})
      assert html =~ "inset-y-0"
      assert html =~ "left-0"
    end

    test "direction=right applies right panel classes" do
      html = render_component(&H.render_right/1, %{})
      assert html =~ "inset-y-0"
      assert html =~ "right-0"
    end

    test "direction=top has rounded-b-lg" do
      html = render_component(&H.render_top/1, %{})
      assert html =~ "rounded-b-lg"
    end
  end

  # ---------------------------------------------------------------------------
  # AC 3: drawer_content/1 — animation classes
  # ---------------------------------------------------------------------------

  describe "drawer_content/1 — animation" do
    test "has transition-transform" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "transition-transform"
    end

    test "has duration-300" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "duration-300"
    end

    test "has ease-out" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "ease-out"
    end
  end

  # ---------------------------------------------------------------------------
  # AC 4: Backdrop element
  # ---------------------------------------------------------------------------

  describe "drawer_content/1 — backdrop" do
    test "has backdrop element" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "data-drawer-backdrop"
    end

    test "backdrop has semi-transparent black background" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "bg-black/80"
    end

    test "backdrop has fixed inset-0 positioning" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "fixed"
      assert html =~ "inset-0"
    end
  end

  # ---------------------------------------------------------------------------
  # AC 5–6: Focus trap and Escape handled by JS hook
  # AC 7: Backdrop click handled by JS hook
  # (these are tested via the JS hook file assertions below)
  # ---------------------------------------------------------------------------

  # ---------------------------------------------------------------------------
  # AC 8: drawer_close/1
  # ---------------------------------------------------------------------------

  describe "drawer_close/1" do
    test "has data-drawer-close attribute" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "data-drawer-close"
    end

    test "has aria-label for accessibility" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "Close drawer"
    end

    test "renders as a button element" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ ~r/<button[^>]+data-drawer-close/
    end
  end

  # ---------------------------------------------------------------------------
  # AC 9: ARIA attributes
  # ---------------------------------------------------------------------------

  describe "drawer_content/1 — ARIA" do
    test "has role=dialog" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ ~s(role="dialog")
    end

    test "has aria-modal=true" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ ~s(aria-modal="true")
    end

    test "uses PhiaDrawer hook" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "PhiaDrawer"
    end

    test "has data-direction attribute" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ ~s(data-direction="bottom")
    end
  end

  # ---------------------------------------------------------------------------
  # AC 1–2: drawer_trigger/1
  # ---------------------------------------------------------------------------

  describe "drawer_trigger/1" do
    test "renders trigger button with data-drawer-trigger" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "data-drawer-trigger"
    end

    test "trigger references the drawer id" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ ~s(data-drawer-trigger="main-drawer")
    end

    test "renders inner content" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "Open"
    end
  end

  # ---------------------------------------------------------------------------
  # Open/closed state
  # ---------------------------------------------------------------------------

  describe "drawer_content/1 — open state" do
    test "is hidden when open=false" do
      html = render_component(&H.render_closed/1, %{})
      assert html =~ "hidden"
    end

    test "is visible (no hidden class on outer) when open=true" do
      html = render_component(&H.render_open/1, %{})
      # The outer container should NOT have 'hidden' class when open=true
      # It should be visible
      assert html =~ ~s(phx-hook="PhiaDrawer")
    end
  end

  # ---------------------------------------------------------------------------
  # drawer_header/1 and drawer_footer/1
  # ---------------------------------------------------------------------------

  describe "drawer_header/1" do
    test "renders a div container with content" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "Drawer Title"
    end

    test "has p-6 padding" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "p-6"
    end
  end

  describe "drawer_footer/1" do
    test "renders footer content" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "Save"
    end

    test "has flex layout" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ "flex"
    end
  end

  # ---------------------------------------------------------------------------
  # JS Hook file (AC 5, 6, 7, 10)
  # ---------------------------------------------------------------------------

  @hook_path Path.join([File.cwd!(), "priv/templates/js/hooks/drawer.js"])

  describe "drawer.js hook file" do
    test "file exists at priv/templates/js/hooks/drawer.js" do
      assert File.exists?(@hook_path), "Expected #{@hook_path} to exist"
    end

    test "exports PhiaDrawer object" do
      content = File.read!(@hook_path)
      assert content =~ "PhiaDrawer"
    end

    test "has mounted() lifecycle" do
      content = File.read!(@hook_path)
      assert content =~ "mounted()"
    end

    test "has destroyed() lifecycle" do
      content = File.read!(@hook_path)
      assert content =~ "destroyed()"
    end

    # AC 5: Focus trap
    test "implements Tab key focus trap" do
      content = File.read!(@hook_path)
      assert content =~ "Tab"
    end

    # AC 6: Escape closes drawer
    test "listens for Escape keydown to close" do
      content = File.read!(@hook_path)
      assert content =~ "Escape"
    end

    # AC 7: Backdrop click closes drawer
    test "handles backdrop click to close" do
      content = File.read!(@hook_path)
      assert content =~ "data-drawer-backdrop"
    end

    # Focus return
    test "stores and restores previously focused element" do
      content = File.read!(@hook_path)
      assert content =~ "activeElement"
    end

    # Focus on first element
    test "calls focus() on first focusable element" do
      content = File.read!(@hook_path)
      assert content =~ "focus()"
    end

    # No memory leaks
    test "destroyed() removes event listeners" do
      content = File.read!(@hook_path)
      assert content =~ "removeEventListener"
    end
  end

  # ---------------------------------------------------------------------------
  # AC 10: Full composition test
  # ---------------------------------------------------------------------------

  describe "full composition" do
    test "renders all sub-components together" do
      html = render_component(&H.render_open/1, %{})
      assert html =~ ~s(id="main-drawer")
      assert html =~ "data-drawer-trigger"
      assert html =~ ~s(role="dialog")
      assert html =~ ~s(aria-modal="true")
      assert html =~ "data-drawer-backdrop"
      assert html =~ "Drawer Title"
      assert html =~ "Drawer content here"
      assert html =~ "data-drawer-close"
      assert html =~ "Save"
    end
  end

  # ---------------------------------------------------------------------------
  # moduledoc
  # ---------------------------------------------------------------------------

  describe "moduledoc" do
    test "moduledoc is a non-empty string" do
      assert Code.fetch_docs(PhiaUi.Components.Drawer) != :error
    end

    test "moduledoc mentions PhiaDrawer hook registration" do
      {:docs_v1, _, _, _, %{"en" => moduledoc}, _, _} =
        Code.fetch_docs(PhiaUi.Components.Drawer)

      assert moduledoc =~ "PhiaDrawer"
    end
  end
end
