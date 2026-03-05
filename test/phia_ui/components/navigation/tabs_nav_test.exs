defmodule PhiaUi.Components.TabsNavTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.TabsNav

    attr(:variant, :atom, default: :underline)
    attr(:class, :string, default: nil)

    def render_tabs_nav(assigns) do
      ~H"""
      <.tabs_nav variant={@variant} class={@class}>
        <.tabs_nav_item href="/home" variant={@variant}>Home</.tabs_nav_item>
        <.tabs_nav_item href="/settings" variant={@variant}>Settings</.tabs_nav_item>
      </.tabs_nav>
      """
    end

    attr(:variant, :atom, default: :underline)

    def render_tabs_nav_with_active(assigns) do
      ~H"""
      <.tabs_nav variant={@variant}>
        <.tabs_nav_item href="/home" variant={@variant} active>Active Tab</.tabs_nav_item>
        <.tabs_nav_item href="/other" variant={@variant}>Other Tab</.tabs_nav_item>
      </.tabs_nav>
      """
    end

    def render_tabs_nav_with_disabled(assigns) do
      ~H"""
      <.tabs_nav>
        <.tabs_nav_item href="/locked" disabled>Disabled Tab</.tabs_nav_item>
        <.tabs_nav_item href="/open">Open Tab</.tabs_nav_item>
      </.tabs_nav>
      """
    end

    def render_item_only(assigns) do
      ~H"""
      <.tabs_nav_item
        href={assigns[:href] || "/tab"}
        active={assigns[:active] || false}
        disabled={assigns[:disabled] || false}
        variant={assigns[:variant] || :underline}
        class={assigns[:class]}
      >
        {assigns[:label] || "Tab Label"}
      </.tabs_nav_item>
      """
    end

    def render_tabs_nav_rest(assigns) do
      ~H"""
      <.tabs_nav data-testid="my-tabs">
        <.tabs_nav_item href="/tab">Tab</.tabs_nav_item>
      </.tabs_nav>
      """
    end

    def render_item_rest(assigns) do
      ~H"""
      <.tabs_nav_item href="/tab" data-testid="my-item">Item</.tabs_nav_item>
      """
    end
  end

  defp render_nav(attrs \\ %{}) do
    render_component(&H.render_tabs_nav/1, attrs)
  end

  defp render_nav_with_active(attrs \\ %{}) do
    render_component(&H.render_tabs_nav_with_active/1, attrs)
  end

  defp render_nav_with_disabled do
    render_component(&H.render_tabs_nav_with_disabled/1, %{})
  end

  defp render_item(attrs \\ %{}) do
    render_component(&H.render_item_only/1, attrs)
  end

  # ---------------------------------------------------------------------------
  # tabs_nav/1 — container element and role
  # ---------------------------------------------------------------------------

  describe "tabs_nav container element" do
    test "renders a nav element" do
      assert render_nav() =~ "<nav"
    end

    test "has role=\"tablist\"" do
      assert render_nav() =~ ~s(role="tablist")
    end

    test "has aria-orientation=\"horizontal\"" do
      assert render_nav() =~ ~s(aria-orientation="horizontal")
    end

    test "renders inner_block content" do
      html = render_nav()
      assert html =~ "Home"
      assert html =~ "Settings"
    end
  end

  # ---------------------------------------------------------------------------
  # tabs_nav/1 — variant classes on container
  # ---------------------------------------------------------------------------

  describe "variant :underline (default) — container" do
    test "renders with border-b class" do
      assert render_nav(%{variant: :underline}) =~ "border-b"
    end

    test "renders with border-border class" do
      assert render_nav(%{variant: :underline}) =~ "border-border"
    end

    test "renders with w-full class" do
      assert render_nav(%{variant: :underline}) =~ "w-full"
    end

    test "renders with gap-4 class" do
      assert render_nav(%{variant: :underline}) =~ "gap-4"
    end

    test "does not render bg-muted on container" do
      refute render_nav(%{variant: :underline}) =~ "bg-muted"
    end
  end

  describe "variant :pills — container" do
    test "renders with gap-1 class" do
      assert render_nav(%{variant: :pills}) =~ "gap-1"
    end

    test "does not render border-b on container" do
      html = render_nav(%{variant: :pills})
      # The nav element should not have border-b (items may, but not the container)
      [nav_tag | _] = Regex.run(~r/<nav[^>]*>/, html)
      refute nav_tag =~ "border-b"
    end
  end

  describe "variant :segment — container" do
    test "renders with bg-muted class on container" do
      [nav_tag | _] = Regex.run(~r/<nav[^>]*>/, render_nav(%{variant: :segment}))
      assert nav_tag =~ "bg-muted"
    end

    test "renders with rounded-lg class on container" do
      [nav_tag | _] = Regex.run(~r/<nav[^>]*>/, render_nav(%{variant: :segment}))
      assert nav_tag =~ "rounded-lg"
    end

    test "renders with p-1 class on container" do
      [nav_tag | _] = Regex.run(~r/<nav[^>]*>/, render_nav(%{variant: :segment}))
      assert nav_tag =~ "p-1"
    end
  end

  # ---------------------------------------------------------------------------
  # tabs_nav/1 — class override and @rest
  # ---------------------------------------------------------------------------

  describe "tabs_nav class override" do
    test "applies custom class to the nav element" do
      html = render_nav(%{class: "my-custom-nav"})
      assert html =~ "my-custom-nav"
    end
  end

  describe "tabs_nav @rest passthrough" do
    test "passes data-testid to nav element" do
      html = render_component(&H.render_tabs_nav_rest/1, %{})
      assert html =~ ~s(data-testid="my-tabs")
    end
  end

  # ---------------------------------------------------------------------------
  # tabs_nav_item/1 — element, role, and aria attributes
  # ---------------------------------------------------------------------------

  describe "tabs_nav_item element and accessibility" do
    test "renders an anchor element" do
      assert render_item() =~ "<a"
    end

    test "has role=\"tab\"" do
      assert render_item() =~ ~s(role="tab")
    end
  end

  describe "tabs_nav_item — active state aria and tabindex" do
    test "active item has aria-selected=\"true\"" do
      html = render_item(%{active: true})
      assert html =~ ~s(aria-selected="true")
    end

    test "inactive item has aria-selected=\"false\"" do
      html = render_item(%{active: false})
      assert html =~ ~s(aria-selected="false")
    end

    test "active item has tabindex=\"0\"" do
      html = render_item(%{active: true})
      assert html =~ ~s(tabindex="0")
    end

    test "inactive item has tabindex=\"-1\"" do
      html = render_item(%{active: false})
      assert html =~ ~s(tabindex="-1")
    end
  end

  # ---------------------------------------------------------------------------
  # tabs_nav_item/1 — href attribute
  # ---------------------------------------------------------------------------

  describe "tabs_nav_item href" do
    test "renders the given href" do
      html = render_item(%{href: "/dashboard"})
      assert html =~ ~s(href="/dashboard")
    end

    test "disabled item has no href attribute" do
      html = render_item(%{disabled: true, href: "/protected"})
      refute html =~ ~s(href="/protected")
    end
  end

  # ---------------------------------------------------------------------------
  # tabs_nav_item/1 — disabled state
  # ---------------------------------------------------------------------------

  describe "tabs_nav_item disabled" do
    test "renders pointer-events-none when disabled" do
      html = render_item(%{disabled: true})
      assert html =~ "pointer-events-none"
    end

    test "renders opacity-50 when disabled" do
      html = render_item(%{disabled: true})
      assert html =~ "opacity-50"
    end

    test "does not render pointer-events-none when enabled" do
      html = render_item(%{disabled: false})
      refute html =~ "pointer-events-none"
    end

    test "does not render opacity-50 when enabled" do
      html = render_item(%{disabled: false})
      refute html =~ "opacity-50"
    end

    test "disabled item in full nav renders pointer-events-none" do
      assert render_nav_with_disabled() =~ "pointer-events-none"
    end

    test "disabled item in full nav renders opacity-50" do
      assert render_nav_with_disabled() =~ "opacity-50"
    end
  end

  # ---------------------------------------------------------------------------
  # tabs_nav_item/1 — base classes
  # ---------------------------------------------------------------------------

  describe "tabs_nav_item base classes" do
    test "renders inline-flex" do
      assert render_item() =~ "inline-flex"
    end

    test "renders items-center" do
      assert render_item() =~ "items-center"
    end

    test "renders justify-center" do
      assert render_item() =~ "justify-center"
    end

    test "renders whitespace-nowrap" do
      assert render_item() =~ "whitespace-nowrap"
    end

    test "renders text-sm" do
      assert render_item() =~ "text-sm"
    end

    test "renders font-medium" do
      assert render_item() =~ "font-medium"
    end

    test "renders transition-all" do
      assert render_item() =~ "transition-all"
    end

    test "renders cursor-pointer" do
      assert render_item() =~ "cursor-pointer"
    end

    test "renders focus-visible:ring-2" do
      assert render_item() =~ "focus-visible:ring-2"
    end
  end

  # ---------------------------------------------------------------------------
  # tabs_nav_item/1 — variant classes
  # ---------------------------------------------------------------------------

  describe "tabs_nav_item variant :underline active" do
    test "renders border-primary" do
      html = render_item(%{variant: :underline, active: true})
      assert html =~ "border-primary"
    end

    test "renders text-foreground" do
      html = render_item(%{variant: :underline, active: true})
      assert html =~ "text-foreground"
    end

    test "renders border-b-2" do
      html = render_item(%{variant: :underline, active: true})
      assert html =~ "border-b-2"
    end
  end

  describe "tabs_nav_item variant :underline inactive" do
    test "renders border-transparent" do
      html = render_item(%{variant: :underline, active: false})
      assert html =~ "border-transparent"
    end

    test "renders text-muted-foreground" do
      html = render_item(%{variant: :underline, active: false})
      assert html =~ "text-muted-foreground"
    end

    test "renders hover:text-foreground" do
      html = render_item(%{variant: :underline, active: false})
      assert html =~ "hover:text-foreground"
    end
  end

  describe "tabs_nav_item variant :pills active" do
    test "renders bg-primary" do
      html = render_item(%{variant: :pills, active: true})
      assert html =~ "bg-primary"
    end

    test "renders text-primary-foreground" do
      html = render_item(%{variant: :pills, active: true})
      assert html =~ "text-primary-foreground"
    end

    test "renders rounded-md" do
      html = render_item(%{variant: :pills, active: true})
      assert html =~ "rounded-md"
    end

    test "renders shadow-sm" do
      html = render_item(%{variant: :pills, active: true})
      assert html =~ "shadow-sm"
    end
  end

  describe "tabs_nav_item variant :pills inactive" do
    test "renders text-muted-foreground" do
      html = render_item(%{variant: :pills, active: false})
      assert html =~ "text-muted-foreground"
    end

    test "renders hover:bg-accent" do
      html = render_item(%{variant: :pills, active: false})
      assert html =~ "hover:bg-accent"
    end

    test "renders hover:text-accent-foreground" do
      html = render_item(%{variant: :pills, active: false})
      assert html =~ "hover:text-accent-foreground"
    end

    test "does not render bg-primary" do
      html = render_item(%{variant: :pills, active: false})
      refute html =~ "bg-primary"
    end
  end

  describe "tabs_nav_item variant :segment active" do
    test "renders bg-background" do
      html = render_item(%{variant: :segment, active: true})
      assert html =~ "bg-background"
    end

    test "renders text-foreground" do
      html = render_item(%{variant: :segment, active: true})
      assert html =~ "text-foreground"
    end

    test "renders shadow-sm" do
      html = render_item(%{variant: :segment, active: true})
      assert html =~ "shadow-sm"
    end

    test "renders rounded-md" do
      html = render_item(%{variant: :segment, active: true})
      assert html =~ "rounded-md"
    end
  end

  describe "tabs_nav_item variant :segment inactive" do
    test "renders text-muted-foreground" do
      html = render_item(%{variant: :segment, active: false})
      assert html =~ "text-muted-foreground"
    end

    test "renders hover:text-foreground" do
      html = render_item(%{variant: :segment, active: false})
      assert html =~ "hover:text-foreground"
    end

    test "does not render bg-background" do
      html = render_item(%{variant: :segment, active: false})
      refute html =~ "bg-background"
    end
  end

  # ---------------------------------------------------------------------------
  # tabs_nav_item/1 — inner_block content
  # ---------------------------------------------------------------------------

  describe "tabs_nav_item inner_block content" do
    test "renders provided text label" do
      html = render_item(%{label: "Dashboard"})
      assert html =~ "Dashboard"
    end

    test "renders default label in H helper" do
      assert render_item() =~ "Tab Label"
    end

    test "full nav renders all item labels" do
      html = render_nav()
      assert html =~ "Home"
      assert html =~ "Settings"
    end

    test "active item label is rendered" do
      html = render_nav_with_active()
      assert html =~ "Active Tab"
      assert html =~ "Other Tab"
    end
  end

  # ---------------------------------------------------------------------------
  # tabs_nav_item/1 — class override and @rest
  # ---------------------------------------------------------------------------

  describe "tabs_nav_item class override" do
    test "applies custom class" do
      html = render_item(%{class: "my-tab"})
      assert html =~ "my-tab"
    end
  end

  describe "tabs_nav_item @rest passthrough" do
    test "passes data-testid to anchor element" do
      html = render_component(&H.render_item_rest/1, %{})
      assert html =~ ~s(data-testid="my-item")
    end
  end

  # ---------------------------------------------------------------------------
  # Integration — active + inactive rendered together
  # ---------------------------------------------------------------------------

  describe "integration — active and inactive items in the same nav" do
    test "active item has aria-selected=true and inactive has aria-selected=false" do
      html = render_nav_with_active()
      assert html =~ ~s(aria-selected="true")
      assert html =~ ~s(aria-selected="false")
    end

    test "active item has tabindex=0 and inactive has tabindex=-1" do
      html = render_nav_with_active()
      assert html =~ ~s(tabindex="0")
      assert html =~ ~s(tabindex="-1")
    end

    test "only one item has the active primary styling in pills variant" do
      html = render_nav_with_active(%{variant: :pills})
      # Only one anchor should have bg-primary (the active one)
      active_matches = Regex.scan(~r/bg-primary/, html)
      assert length(active_matches) == 1
    end
  end
end
