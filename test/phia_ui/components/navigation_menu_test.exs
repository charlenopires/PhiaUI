defmodule PhiaUi.Components.NavigationMenuTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.NavigationMenu

    def render_menu(assigns) do
      ~H"""
      <.navigation_menu class={assigns[:class]}>
        <.navigation_menu_list>
          <.navigation_menu_item>
            <.navigation_menu_link href="/home" active={assigns[:active_home] || false}>
              Home
            </.navigation_menu_link>
          </.navigation_menu_item>
          <.navigation_menu_item>
            <.navigation_menu_link href="/about">
              About
            </.navigation_menu_link>
          </.navigation_menu_item>
        </.navigation_menu_list>
      </.navigation_menu>
      """
    end

    def render_with_trigger(assigns) do
      ~H"""
      <.navigation_menu>
        <.navigation_menu_list>
          <.navigation_menu_item>
            <.navigation_menu_trigger label="Products" />
            <.navigation_menu_content>
              <ul>
                <li><a href="/products/a">Product A</a></li>
                <li><a href="/products/b">Product B</a></li>
              </ul>
            </.navigation_menu_content>
          </.navigation_menu_item>
        </.navigation_menu_list>
      </.navigation_menu>
      """
    end

    def render_link(assigns) do
      ~H"""
      <.navigation_menu_link
        href={assigns[:href] || "/home"}
        active={assigns[:active] || false}
        class={assigns[:class]}
      >
        {assigns[:label] || "Link"}
      </.navigation_menu_link>
      """
    end

    def render_trigger(assigns) do
      ~H"""
      <.navigation_menu_trigger
        label={assigns[:label] || "Menu"}
        class={assigns[:class]}
      />
      """
    end

    def render_content(assigns) do
      ~H"""
      <.navigation_menu_content class={assigns[:class]}>
        <span class="content-inner">Content here</span>
      </.navigation_menu_content>
      """
    end

    def render_full(assigns) do
      ~H"""
      <.navigation_menu>
        <.navigation_menu_list>
          <.navigation_menu_item>
            <.navigation_menu_link href="/home" active={true}>Home</.navigation_menu_link>
          </.navigation_menu_item>
          <.navigation_menu_item>
            <.navigation_menu_trigger label="Docs" />
            <.navigation_menu_content>
              <ul>
                <li><a href="/docs/getting-started">Getting Started</a></li>
                <li><a href="/docs/api">API Reference</a></li>
              </ul>
            </.navigation_menu_content>
          </.navigation_menu_item>
          <.navigation_menu_item>
            <.navigation_menu_link href="/contact">Contact</.navigation_menu_link>
          </.navigation_menu_item>
        </.navigation_menu_list>
      </.navigation_menu>
      """
    end
  end

  defp render_menu(attrs \\ %{}), do: render_component(&H.render_menu/1, attrs)
  defp render_with_trigger, do: render_component(&H.render_with_trigger/1, %{})
  defp render_link(attrs \\ %{}), do: render_component(&H.render_link/1, attrs)
  defp render_trigger(attrs \\ %{}), do: render_component(&H.render_trigger/1, attrs)
  defp render_content(attrs \\ %{}), do: render_component(&H.render_content/1, attrs)
  defp render_full, do: render_component(&H.render_full/1, %{})

  # ---------------------------------------------------------------------------
  # navigation_menu/1 — root wrapper
  # ---------------------------------------------------------------------------

  describe "navigation_menu/1 — structure" do
    test "renders a root nav element" do
      html = render_menu()
      assert html =~ "<nav"
    end

    test "nav has role=navigation or is a semantic nav element" do
      html = render_menu()
      assert html =~ "<nav"
    end

    test "custom class is applied to the root element" do
      html = render_menu(%{class: "my-nav"})
      assert html =~ "my-nav"
    end

    test "renders inner content" do
      html = render_menu()
      assert html =~ "Home"
      assert html =~ "About"
    end
  end

  # ---------------------------------------------------------------------------
  # navigation_menu_list/1
  # ---------------------------------------------------------------------------

  describe "navigation_menu_list/1 — list" do
    test "renders a list element (ul)" do
      html = render_menu()
      assert html =~ "<ul"
    end

    test "list renders item children" do
      html = render_menu()
      assert html =~ "<li"
    end
  end

  # ---------------------------------------------------------------------------
  # navigation_menu_item/1
  # ---------------------------------------------------------------------------

  describe "navigation_menu_item/1 — item" do
    test "renders an li element" do
      html = render_menu()
      assert html =~ "<li"
    end
  end

  # ---------------------------------------------------------------------------
  # navigation_menu_link/1
  # ---------------------------------------------------------------------------

  describe "navigation_menu_link/1 — link" do
    test "renders an anchor element" do
      html = render_link()
      assert html =~ "<a"
    end

    test "href is applied to the anchor" do
      html = render_link(%{href: "/dashboard"})
      assert html =~ ~s(href="/dashboard")
    end

    test "renders inner content" do
      html = render_link(%{label: "Dashboard"})
      assert html =~ "Dashboard"
    end

    test "active link has distinct styling" do
      html = render_link(%{active: true})

      assert html =~ "bg-accent" or html =~ "font-medium" or html =~ "text-foreground" or
               html =~ "active"
    end

    test "inactive link does not have active class" do
      active_html = render_link(%{active: true})
      inactive_html = render_link(%{active: false})
      refute active_html == inactive_html
    end

    test "active link has aria-current=page" do
      html = render_link(%{active: true})
      assert html =~ ~s(aria-current="page")
    end

    test "inactive link does not have aria-current=page" do
      html = render_link(%{active: false})
      refute html =~ ~s(aria-current="page")
    end

    test "custom class is applied" do
      assert render_link(%{class: "my-link"}) =~ "my-link"
    end
  end

  # ---------------------------------------------------------------------------
  # navigation_menu_trigger/1
  # ---------------------------------------------------------------------------

  describe "navigation_menu_trigger/1 — trigger button" do
    test "renders a button element" do
      assert render_trigger() =~ "<button"
    end

    test "renders the label text" do
      html = render_trigger(%{label: "Products"})
      assert html =~ "Products"
    end

    test "button has type=button" do
      html = render_trigger()
      assert html =~ ~s(type="button")
    end

    test "button has aria-haspopup or aria-expanded" do
      html = render_trigger()
      assert html =~ "aria-haspopup" or html =~ "aria-expanded"
    end

    test "renders a chevron or dropdown indicator" do
      html = render_trigger()
      assert html =~ "chevron" or html =~ "svg" or html =~ "arrow"
    end

    test "custom class is applied" do
      assert render_trigger(%{class: "my-trigger"}) =~ "my-trigger"
    end
  end

  # ---------------------------------------------------------------------------
  # navigation_menu_content/1
  # ---------------------------------------------------------------------------

  describe "navigation_menu_content/1 — content panel" do
    test "renders a container for dropdown content" do
      html = render_content()
      assert html =~ "<div" or html =~ "content-inner"
    end

    test "renders inner slot content" do
      html = render_content()
      assert html =~ "content-inner"
    end

    test "custom class is applied" do
      assert render_content(%{class: "my-content"}) =~ "my-content"
    end
  end

  # ---------------------------------------------------------------------------
  # Full composition
  # ---------------------------------------------------------------------------

  describe "full composition" do
    test "renders nav with links and trigger" do
      html = render_full()
      assert html =~ "Home"
      assert html =~ "Docs"
      assert html =~ "Contact"
    end

    test "active link has aria-current=page" do
      html = render_full()
      assert html =~ ~s(aria-current="page")
    end

    test "trigger has dropdown indicator" do
      html = render_full()
      assert html =~ "chevron" or html =~ "svg" or html =~ "arrow"
    end

    test "content panel renders links" do
      html = render_full()
      assert html =~ "Getting Started"
      assert html =~ "API Reference"
    end

    test "no hardcoded hex colors in style attributes" do
      html = render_full()
      refute html =~ ~r/style="[^"]*#[0-9a-fA-F]{3,6}/
    end
  end

  # ---------------------------------------------------------------------------
  # Semantic tokens
  # ---------------------------------------------------------------------------

  describe "semantic tokens" do
    test "uses semantic background tokens" do
      html = render_menu()
      assert html =~ "bg-background" or html =~ "bg-muted" or html =~ "bg-"
    end

    test "uses text-foreground or text-muted-foreground" do
      html = render_menu()
      assert html =~ "text-foreground" or html =~ "foreground"
    end

    test "no hardcoded hex colors" do
      html = render_menu()
      refute html =~ ~r/style="[^"]*#[0-9a-fA-F]{3,6}/
    end
  end
end
