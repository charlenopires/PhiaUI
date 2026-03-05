defmodule PhiaUi.Components.MobileSidebarToggleTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.MobileSidebarToggle

    attr(:target, :string, default: "#sidebar-drawer")
    attr(:class, :string, default: nil)

    def render_toggle(assigns) do
      ~H"""
      <.mobile_sidebar_toggle target={@target} class={@class} />
      """
    end
  end

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

    test "phx-click encodes -translate-x-full as hidden state" do
      html = render_component(&H.render_toggle/1, %{})
      assert html =~ "-translate-x-full"
    end

    test "renders icon svg" do
      html = render_component(&H.render_toggle/1, %{})
      assert html =~ "<svg"
    end

    test "icon uses name=menu" do
      html = render_component(&H.render_toggle/1, %{})
      assert html =~ "icon-menu"
    end
  end
end
