defmodule PhiaUi.Components.ShellTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Shell

    attr :class, :string, default: nil

    def render_shell(assigns) do
      ~H"""
      <.shell class={@class}>
        <p>Content</p>
      </.shell>
      """
    end

    attr :class, :string, default: nil
    attr :id, :string, default: "sidebar-drawer"

    def render_sidebar(assigns) do
      ~H"""
      <.sidebar id={@id} class={@class}>
        <p>Nav</p>
      </.sidebar>
      """
    end

    attr :class, :string, default: nil

    def render_topbar(assigns) do
      ~H"""
      <.topbar class={@class}>
        <span>App</span>
      </.topbar>
      """
    end

    attr :target, :string, default: "#sidebar-drawer"
    attr :class, :string, default: nil

    def render_toggle(assigns) do
      ~H"""
      <.mobile_sidebar_toggle target={@target} class={@class} />
      """
    end

    def render_full(assigns) do
      ~H"""
      <.shell>
        <.topbar>
          <.mobile_sidebar_toggle />
          <span>My App</span>
        </.topbar>
        <div class="flex flex-1 overflow-hidden">
          <.sidebar>
            <p>Nav links</p>
          </.sidebar>
          <main class="flex-1 p-6">
            <p>Main content</p>
          </main>
        </div>
      </.shell>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # shell/1
  # ---------------------------------------------------------------------------

  describe "shell/1" do
    test "renders a div wrapper" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "<div"
    end

    test "has min-h-screen" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "min-h-screen"
    end

    test "has bg-background" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "bg-background"
    end

    test "renders inner_block content" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "Content"
    end

    test "accepts custom class" do
      html = render_component(&H.render_shell/1, %{class: "overflow-hidden"})
      assert html =~ "overflow-hidden"
    end
  end

  # ---------------------------------------------------------------------------
  # sidebar/1
  # ---------------------------------------------------------------------------

  describe "sidebar/1" do
    test "renders aside element" do
      html = render_component(&H.render_sidebar/1, %{})
      assert html =~ "<aside"
    end

    test "has hidden class (mobile — hidden by default)" do
      html = render_component(&H.render_sidebar/1, %{})
      assert html =~ "hidden"
    end

    test "has md:flex for desktop visibility" do
      html = render_component(&H.render_sidebar/1, %{})
      assert html =~ "md:flex"
    end

    test "has w-60 width (240px)" do
      html = render_component(&H.render_sidebar/1, %{})
      assert html =~ "w-60"
    end

    test "has border-r" do
      html = render_component(&H.render_sidebar/1, %{})
      assert html =~ "border-r"
    end

    test "uses provided id" do
      html = render_component(&H.render_sidebar/1, %{id: "my-sidebar"})
      assert html =~ ~s(id="my-sidebar")
    end

    test "defaults id to sidebar-drawer" do
      html = render_component(&H.render_sidebar/1, %{})
      assert html =~ ~s(id="sidebar-drawer")
    end

    test "renders slot content" do
      html = render_component(&H.render_sidebar/1, %{})
      assert html =~ "Nav"
    end

    test "accepts custom class" do
      html = render_component(&H.render_sidebar/1, %{class: "shadow-lg"})
      assert html =~ "shadow-lg"
    end
  end

  # ---------------------------------------------------------------------------
  # topbar/1
  # ---------------------------------------------------------------------------

  describe "topbar/1" do
    test "renders header element" do
      html = render_component(&H.render_topbar/1, %{})
      assert html =~ "<header"
    end

    test "has h-14 height" do
      html = render_component(&H.render_topbar/1, %{})
      assert html =~ "h-14"
    end

    test "has border-b" do
      html = render_component(&H.render_topbar/1, %{})
      assert html =~ "border-b"
    end

    test "has flex items-center" do
      html = render_component(&H.render_topbar/1, %{})
      assert html =~ "flex"
      assert html =~ "items-center"
    end

    test "renders slot content" do
      html = render_component(&H.render_topbar/1, %{})
      assert html =~ "App"
    end

    test "accepts custom class" do
      html = render_component(&H.render_topbar/1, %{class: "px-8"})
      assert html =~ "px-8"
    end
  end

  # ---------------------------------------------------------------------------
  # mobile_sidebar_toggle/1
  # ---------------------------------------------------------------------------

  describe "mobile_sidebar_toggle/1" do
    test "renders a button" do
      html = render_component(&H.render_toggle/1, %{})
      assert html =~ "<button"
    end

    test "has md:hidden (hidden on desktop)" do
      html = render_component(&H.render_toggle/1, %{})
      assert html =~ "md:hidden"
    end

    test "has type=button" do
      html = render_component(&H.render_toggle/1, %{})
      assert html =~ ~s(type="button")
    end

    test "has aria-label" do
      html = render_component(&H.render_toggle/1, %{})
      assert html =~ "aria-label"
    end

    test "has phx-click for JS.toggle" do
      html = render_component(&H.render_toggle/1, %{})
      assert html =~ "phx-click"
    end

    test "targets sidebar-drawer by default" do
      html = render_component(&H.render_toggle/1, %{})
      assert html =~ "sidebar-drawer"
    end

    test "accepts custom target" do
      html = render_component(&H.render_toggle/1, %{target: "#my-nav"})
      assert html =~ "my-nav"
    end

    test "accepts custom class" do
      html = render_component(&H.render_toggle/1, %{class: "text-primary"})
      assert html =~ "text-primary"
    end
  end

  # ---------------------------------------------------------------------------
  # Full composition
  # ---------------------------------------------------------------------------

  describe "full shell composition" do
    test "all sub-components render correctly together" do
      html = render_component(&H.render_full/1, %{})
      assert html =~ "<header"
      assert html =~ "<aside"
      assert html =~ "<button"
      assert html =~ "My App"
      assert html =~ "Nav links"
      assert html =~ "Main content"
    end
  end
end
