defmodule PhiaUi.Components.AppShellTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.AppShell

    def render_shell(assigns) do
      ~H"""
      <.app_shell>
        <:header><p>Header</p></:header>
        <:sidebar><p>Sidebar</p></:sidebar>
        <p>Main Content</p>
      </.app_shell>
      """
    end

    def render_with_aside(assigns) do
      ~H"""
      <.app_shell with_aside={true}>
        <:header><p>H</p></:header>
        <:sidebar><p>S</p></:sidebar>
        <:aside><p>Aside</p></:aside>
        <p>Main</p>
      </.app_shell>
      """
    end

    def render_with_footer(assigns) do
      ~H"""
      <.app_shell with_footer={true}>
        <:footer><p>Footer</p></:footer>
        <p>Main</p>
      </.app_shell>
      """
    end

    def render_sidebar_sm(assigns) do
      ~H"""
      <.app_shell sidebar_width={:sm}>
        <:sidebar><p>S</p></:sidebar>
        <p>Main</p>
      </.app_shell>
      """
    end

    def render_header_component(assigns) do
      ~H"""
      <.app_shell_header>My Header</.app_shell_header>
      """
    end

    def render_header_sm(assigns) do
      ~H"""
      <.app_shell_header height={:sm}>Header</.app_shell_header>
      """
    end

    def render_sidebar_component(assigns) do
      ~H"""
      <.app_shell_sidebar>Sidebar Content</.app_shell_sidebar>
      """
    end

    def render_sidebar_collapsed(assigns) do
      ~H"""
      <.app_shell_sidebar collapsed={true}>Content</.app_shell_sidebar>
      """
    end

    def render_aside_component(assigns) do
      ~H"""
      <.app_shell_aside>Aside Content</.app_shell_aside>
      """
    end

    def render_footer_component(assigns) do
      ~H"""
      <.app_shell_footer>Footer Content</.app_shell_footer>
      """
    end

    def render_main_lg(assigns) do
      ~H"""
      <.app_shell_main padding={:lg}>Main</.app_shell_main>
      """
    end

    def render_main_none(assigns) do
      ~H"""
      <.app_shell_main padding={:none}>Main</.app_shell_main>
      """
    end
  end

  describe "app_shell/1" do
    test "renders root div" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "<div"
    end

    test "renders header slot" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "Header"
    end

    test "renders sidebar slot" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "Sidebar"
    end

    test "renders main content" do
      html = render_component(&H.render_shell/1, %{})
      assert html =~ "Main Content"
    end

    test "renders aside when with_aside=true" do
      html = render_component(&H.render_with_aside/1, %{})
      assert html =~ "Aside"
    end

    test "renders footer when with_footer=true" do
      html = render_component(&H.render_with_footer/1, %{})
      assert html =~ "Footer"
    end

    test "sidebar_width :sm sets 16rem" do
      html = render_component(&H.render_sidebar_sm/1, %{})
      assert html =~ "16rem"
    end
  end

  describe "app_shell_header/1" do
    test "renders header element" do
      html = render_component(&H.render_header_component/1, %{})
      assert html =~ "<header"
    end

    test "has sticky top-0" do
      html = render_component(&H.render_header_component/1, %{})
      assert html =~ "sticky"
      assert html =~ "top-0"
    end

    test "height :sm applies h-14" do
      html = render_component(&H.render_header_sm/1, %{})
      assert html =~ "h-14"
    end
  end

  describe "app_shell_sidebar/1" do
    test "renders aside element" do
      html = render_component(&H.render_sidebar_component/1, %{})
      assert html =~ "<aside"
    end

    test "has border-r" do
      html = render_component(&H.render_sidebar_component/1, %{})
      assert html =~ "border-r"
    end

    test "collapsed=true adds w-0" do
      html = render_component(&H.render_sidebar_collapsed/1, %{})
      assert html =~ "w-0"
    end
  end

  describe "app_shell_aside/1" do
    test "renders aside element" do
      html = render_component(&H.render_aside_component/1, %{})
      assert html =~ "<aside"
    end

    test "has border-l" do
      html = render_component(&H.render_aside_component/1, %{})
      assert html =~ "border-l"
    end
  end

  describe "app_shell_footer/1" do
    test "renders footer element" do
      html = render_component(&H.render_footer_component/1, %{})
      assert html =~ "<footer"
    end

    test "has sticky bottom-0" do
      html = render_component(&H.render_footer_component/1, %{})
      assert html =~ "sticky"
      assert html =~ "bottom-0"
    end
  end

  describe "app_shell_main/1" do
    test "renders main element" do
      html = render_component(&H.render_main_lg/1, %{})
      assert html =~ "<main"
    end

    test "padding :lg applies p-8" do
      html = render_component(&H.render_main_lg/1, %{})
      assert html =~ "p-8"
    end

    test "padding :none has no padding class" do
      html = render_component(&H.render_main_none/1, %{})
      refute html =~ "p-6"
      refute html =~ "p-8"
    end
  end
end
