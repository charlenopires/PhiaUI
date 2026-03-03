defmodule PhiaUi.Components.ShellTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.Shell

    # shell/1 — with topbar
    attr(:class, :string, default: nil)

    def render_shell(assigns) do
      ~H"""
      <.shell class={@class}>
        <:topbar>
          <span>Topbar</span>
        </:topbar>
        <:sidebar>
          <p>Sidebar Nav</p>
        </:sidebar>
        <p>Content</p>
      </.shell>
      """
    end

    # shell/1 — without topbar slot
    def render_shell_no_topbar(assigns) do
      ~H"""
      <.shell>
        <:sidebar>
          <p>Sidebar Nav</p>
        </:sidebar>
        <p>Content</p>
      </.shell>
      """
    end

    # sidebar/1 standalone
    attr(:class, :string, default: nil)
    attr(:id, :string, default: "sidebar-drawer")
    attr(:collapsed, :boolean, default: false)

    def render_sidebar(assigns) do
      ~H"""
      <.sidebar id={@id} class={@class} collapsed={@collapsed}>
        <:brand><span>Brand</span></:brand>
        <:nav_items><p>Nav</p></:nav_items>
        <:footer_items><p>Footer</p></:footer_items>
      </.sidebar>
      """
    end

    # sidebar/1 inner_block fallback
    def render_sidebar_inner(assigns) do
      ~H"""
      <.sidebar>
        <p>Legacy Nav</p>
      </.sidebar>
      """
    end

    # topbar/1 standalone
    attr(:class, :string, default: nil)

    def render_topbar(assigns) do
      ~H"""
      <.topbar class={@class}>
        <span>App</span>
      </.topbar>
      """
    end

    # mobile_sidebar_toggle/1
    attr(:target, :string, default: "#sidebar-drawer")
    attr(:class, :string, default: nil)

    def render_toggle(assigns) do
      ~H"""
      <.mobile_sidebar_toggle target={@target} class={@class} />
      """
    end

    # full composition
    def render_full(assigns) do
      ~H"""
      <.shell>
        <:topbar>
          <.mobile_sidebar_toggle />
          <span>My App</span>
        </:topbar>
        <:sidebar>
          <.sidebar>
            <:brand><span>Acme</span></:brand>
            <:nav_items>
              <p>Nav links</p>
            </:nav_items>
          </.sidebar>
        </:sidebar>
        <main class="flex-1 p-6">
          <p>Main content</p>
        </main>
      </.shell>
      """
    end
  end

  # ---------------------------------------------------------------------------
  # shell/1 — named slots
  # ---------------------------------------------------------------------------

  describe "shell/1 named slots" do
    test "renders :sidebar slot content" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "Sidebar Nav"
    end

    test "renders :topbar slot content when provided" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "Topbar"
    end

    test "renders :inner_block (main content)" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "Content"
    end

    test "topbar renders a header element when slot is provided" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "<header"
    end

    test "topbar is not rendered when slot is omitted" do
      html = render_component(&H.render_shell_no_topbar/1, %{})
      refute html =~ "<header"
    end

    test "sidebar is rendered in an aside element" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "<aside"
    end

    test "main content is rendered in a main element" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "<main"
    end
  end

  # ---------------------------------------------------------------------------
  # shell/1 — layout classes
  # ---------------------------------------------------------------------------

  describe "shell/1 layout" do
    test "has h-screen" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "h-screen"
    end

    test "has overflow-hidden" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "overflow-hidden"
    end

    test "has md:grid for desktop CSS Grid" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "md:grid"
    end

    test "has md:grid-cols-[240px_1fr] for desktop layout" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "md:grid-cols-"
    end

    test "accepts custom class" do
      html = render_component(&H.render_shell/1, %{class: "my-custom"})
      assert html =~ "my-custom"
    end

    test "wrapper has flex flex-col for mobile full-width stack" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "flex-col"
    end
  end

  # ---------------------------------------------------------------------------
  # shell/1 — mobile sidebar drawer overlay
  # ---------------------------------------------------------------------------

  describe "shell/1 mobile drawer overlay" do
    test "aside has fixed positioning for mobile overlay" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "fixed"
    end

    test "aside has inset-y-0 for full-height overlay" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "inset-y-0"
    end

    test "aside has left-0 for left-edge placement" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "left-0"
    end

    test "aside has z-50 for stacking above content" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "z-50"
    end

    test "aside has md:static to reset fixed positioning on desktop" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "md:static"
    end

    test "aside has w-60 for 240px width" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "w-60"
    end
  end

  # ---------------------------------------------------------------------------
  # shell/1 — CSS custom properties for backgrounds
  # ---------------------------------------------------------------------------

  describe "shell/1 CSS custom properties" do
    test "main area references --background custom property" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "--background"
    end

    test "sidebar aside references --sidebar-background custom property" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "--sidebar-background"
    end

    test "topbar header references --background custom property" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "--background"
    end
  end

  # ---------------------------------------------------------------------------
  # shell/1 — sidebar aside mobile visibility
  # ---------------------------------------------------------------------------

  describe "shell/1 sidebar mobile visibility" do
    test "aside has hidden class (hidden on mobile by default)" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "hidden"
    end

    test "aside has md:flex for desktop visibility" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "md:flex"
    end

    test "aside has id=mobile-sidebar for JS.toggle targeting" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ ~s(id="mobile-sidebar")
    end
  end

  # ---------------------------------------------------------------------------
  # sidebar/1 — named slots
  # ---------------------------------------------------------------------------

  describe "sidebar/1 named slots" do
    test "renders :brand slot content" do
      html = render_component(&H.render_sidebar/1, %{})
      assert html =~ "Brand"
    end

    test "renders :nav_items slot content" do
      html = render_component(&H.render_sidebar/1, %{})
      assert html =~ "Nav"
    end

    test "renders :footer_items slot content" do
      html = render_component(&H.render_sidebar/1, %{})
      assert html =~ "Footer"
    end

    test "renders aside element" do
      html = render_component(&H.render_sidebar/1, %{})
      assert html =~ "<aside"
    end

    test "has w-60 width" do
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

    test "accepts custom class" do
      html = render_component(&H.render_sidebar/1, %{class: "shadow-lg"})
      assert html =~ "shadow-lg"
    end
  end

  # ---------------------------------------------------------------------------
  # sidebar/1 — :collapsed attr
  # ---------------------------------------------------------------------------

  describe "sidebar/1 collapsed attr" do
    test "collapsed defaults to false" do
      html = render_component(&H.render_sidebar/1, %{})
      refute html =~ "translate-x-full"
    end

    test "collapsed=false renders sidebar normally" do
      html = render_component(&H.render_sidebar/1, %{collapsed: false})
      assert html =~ "Nav"
    end

    test "collapsed=true adds collapsed class" do
      html = render_component(&H.render_sidebar/1, %{collapsed: true})
      assert html =~ "-translate-x-full"
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

    test "phx-click encodes slide-in transition (duration-300)" do
      html = render_component(&H.render_toggle/1, %{})
      assert html =~ "duration-300"
    end

    test "phx-click encodes translate-x-0 as visible end state" do
      html = render_component(&H.render_toggle/1, %{})
      assert html =~ "translate-x-0"
    end

    test "phx-click encodes -translate-x-full as hidden start/end state" do
      html = render_component(&H.render_toggle/1, %{})
      assert html =~ "-translate-x-full"
    end

    test "renders icon/1 svg instead of Unicode ☰" do
      html = render_component(&H.render_toggle/1, %{})
      assert html =~ "<svg"
      refute html =~ "☰"
    end

    test "icon uses name=\"menu\"" do
      html = render_component(&H.render_toggle/1, %{})
      assert html =~ ~s(href="/icons/lucide-sprite.svg#icon-menu")
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
      assert html =~ "Acme"
      assert html =~ "Nav links"
      assert html =~ "Main content"
    end
  end
end
